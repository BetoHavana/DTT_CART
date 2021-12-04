public with sharing class CasesSharingBatchScheduler implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String CASESSHARERECORDCREATIONFAILED = 'Case Share Creation Failed for CaseId :';
	private static final Set<String> CASERECORDTYPEDEVELOPERNAMES = new Set<String> {'CarePlan'};
	private static final String CASEID = CaseShare.CaseId.getDescribe().getName();
	private static final String ANDPROCESSEDCASES = ' And Processed {2} Cases';
	public static final String BATCHNAME = 'Sharing Cases Records Batch';
	private static final String BATCHLOGGINGMESSAGE = BATCHNAME + ' {0}{1}';
	private static final String CRONEXPR_FORDAILYSTARTOFDAY = '0 0 0 ? * * *';
	private static final String FINISHED = ' Finished';
	private static final String HYPEN = ' - ';
	private static final Integer LASTNOOFDAYS
	{
		get
		{
			if (null == LASTNOOFDAYS)
			{
				String lastNDays = sflib_Settings.get('SharingCaseRecordsBatchLastNDays') ;
				LASTNOOFDAYS = string.isBlank(lastNDays) ? 1 : Integer.valueOf(lastNDays);
			}
			return LASTNOOFDAYS;
		}
		set;
	}
	private static final String STARTED = ' Started';
	private static final String WITHERROR = 'With Error ';

	private Integer noOfRecordsProcessed = 0;

	public static void scheduleBatch()
	{
		System.schedule(BATCHNAME.trim() + HYPEN + datetime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new CasesSharingBatchScheduler());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new CasesSharingBatchScheduler());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		Set<Id> recordTypeIds = sflib_RecordTypesSelector.selectRecordTypeByDeveloperNames(Case.SObjectType, CASERECORDTYPEDEVELOPERNAMES)
				.keySet();
		CasesSelector casesSelector = (CasesSelector) Application.Selector.newInstance(Case.SObjectType);
		return casesSelector.getQLOfCasesCreatedEditedInLastNDays(LASTNOOFDAYS, recordTypeIds);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new CasesShareDML());
			CasesService casesService = (CasesService) Application.Service.newInstance(CasesService.class);
			casesService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDCASES, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
		CarePlanGoalsSharingBatchScheduler.start();
	}

	private inherited sharing class CasesShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(CASESSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(CASEID)
							+ WITHERROR + saveResults.get(iteration)?.getErrors());
				}
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}

			Database.emptyRecycleBin(objList);
		}
		public void eventPublish(List<SObject> objList)
		{
		}
	}

}