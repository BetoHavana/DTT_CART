public with sharing class CarePlanGoalsSharingBatchScheduler implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String CAREPLANGOALSSHARERECORDCREATIONFAILED = 'CarePlanGoal Share Creation Failed for GoalId :';
	private static final String GOALID = HealthCloudGA__CarePlanGoal__Share.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDCAREPLANGOALS = ' And Processed {2} CarePlan Goals';
	public static final String BATCHNAME = 'Sharing CarePlan Goals Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingGoalRecordsBatchLastNDays') ;
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
		System.schedule(BATCHNAME.trim() + HYPEN + datetime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new CarePlanGoalsSharingBatchScheduler());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new CarePlanGoalsSharingBatchScheduler());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		CarePlanGoalsSelector carePlanGoalsSelector = (CarePlanGoalsSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanGoal__c.SObjectType);
		return carePlanGoalsSelector.getQLOfGoalsCreatedEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new CarePlanGoalsShareDML());
			CarePlanGoalsService carePlanGoalsService = (CarePlanGoalsService) Application.Service.newInstance(CarePlanGoalsService.class);
			carePlanGoalsService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDCAREPLANGOALS, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
		PatientServicesEnrolleeSharingBatchSchlr.start();
	}

	private inherited sharing class CarePlanGoalsShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(CAREPLANGOALSSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(GOALID)
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