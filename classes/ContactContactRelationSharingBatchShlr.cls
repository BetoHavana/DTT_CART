public with sharing class ContactContactRelationSharingBatchShlr implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String ACCOUNTSHARERECORDCREATIONFAILED = 'Account Share Creation Failed for AccountId :';
	private static final String CONTACTCONTACTRELATIONSHAREFAILED = 'ContactAccountRelation Share Creation Failed for CCRelationId';
	private static final String ACCOUNTID = AccountShare.AccountId.getDescribe().getName();
	private static final String PARENTID = HealthCloudGA__ContactContactRelation__Share.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDACCOUNTS = ' And Processed {2} AccountsAccountRelations';
	public static final String BATCHNAME = 'Sharing ContactContact Relation Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingContContRelationsBatchLastNDays') ;
				LASTNOOFDAYS = string.isBlank(lastNDays) ? 1 : Integer.valueOf(lastNDays);
			}
			return LASTNOOFDAYS;
		}
		set;
	}
	private static ContactContactRelationsService contactContactRelationsService
	{
		get
		{
			if (null == contactContactRelationsService)
			{
				contactContactRelationsService = (ContactContactRelationsService) Application.Service.newInstance(ContactContactRelationsService.class);
			}
			return contactContactRelationsService;
		}
		private set;
	}
	private static final String STARTED = ' Started';
	private static final String WITHERROR = 'With Error ';

	private Integer noOfRecordsProcessed = 0;

	public static void scheduleBatch()
	{
		System.schedule(BATCHNAME.trim() + HYPEN + DateTime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new ContactContactRelationSharingBatchShlr());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new ContactContactRelationSharingBatchShlr());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		ContactContactRelationSelector contactContactRelationSelector = (ContactContactRelationSelector) Application.Selector.newInstance(HealthCloudGA__ContactContactRelation__c.SObjectType);
		return contactContactRelationSelector.getElevatedQLOfContContRelsCreatEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new AccountsShareDML());
			contactContactRelationsService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDACCOUNTS, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
		CPEProductSharingBatchScheduler.start();
	}

	private inherited sharing class AccountsShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			String errorMessage = CONTACTCONTACTRELATIONSHAREFAILED;
			String parentIdFieldName = PARENTID;
			if (objList.getSObjectType() == AccountShare.SObjectType)
			{
				parentIdFieldName = ACCOUNTID;
				errorMessage = ACCOUNTSHARERECORDCREATIONFAILED;
			}
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(errorMessage + objList.get(iteration)?.get(parentIdFieldName)
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
