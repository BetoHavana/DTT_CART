public with sharing class PatientServicesEnrolleeSharingBatchSchlr implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String PSESSHARERECORDCREATIONFAILED = 'PatientServicesEnrollee Share Creation Failed for PatientServicesEnrolleeId :';
	private static final String PATIENTSERVICEENROLLEEID = PatientServicesEnrollee__Share.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDPSES = ' And Processed {2} PatientServicesEnrollees';
	public static final String BATCHNAME = 'Sharing PatientServicesEnrollee Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingPSERecordsBatchLastNDays') ;
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
		System.schedule(BATCHNAME.trim() + HYPEN + datetime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new PatientServicesEnrolleeSharingBatchSchlr());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new PatientServicesEnrolleeSharingBatchSchlr());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
	    PatientServicesEnrolleesSelector patientServicesEnrolleesSelector = (PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SObjectType);

        return patientServicesEnrolleesSelector.getQLOfPSESCreatedEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
            fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new PatientServicesEnrolleesShareDML());
			PatientServicesEnrolleesService pseService = (PatientServicesEnrolleesService) Application.Service.newInstance(PatientServicesEnrolleesService.class);
		    pseService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDPSES, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
		OrdersSharingBatchScheduler.start();
	}

	private inherited sharing class PatientServicesEnrolleesShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(PSESSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(PATIENTSERVICEENROLLEEID)
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