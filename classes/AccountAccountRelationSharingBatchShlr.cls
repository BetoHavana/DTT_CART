public with sharing class AccountAccountRelationSharingBatchShlr implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String ACCOUNTSHARERECORDCREATIONFAILED = 'Account Share Creation Failed for AccountId :';
	private static final String ACCOUNTACCOUNTRELATIONSHAREFAILED = 'AccountAccountRelation Share Creation Failed for AARelationId';
	private static final String ACCOUNTID = AccountShare.AccountId.getDescribe().getName();
	private static final String PARENTID = HealthCloudGA__AccountAccountRelation__Share.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDACCOUNTS = ' And Processed {2} AccountsAccountRelations';
	public static final String BATCHNAME = 'Sharing AccountAccountRelation Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingAcntAcntRelationsBatchLastNDays') ;
				LASTNOOFDAYS = string.isBlank(lastNDays) ? 1 : Integer.valueOf(lastNDays);
			}
			return LASTNOOFDAYS;
		}
		set;
	}
	private static AccountAccountRelationsService accountAccountRelationsService
	{
		get
		{
			if (null == accountAccountRelationsService)
			{
				accountAccountRelationsService = (AccountAccountRelationsService) Application.Service.newInstance(AccountAccountRelationsService.class);
			}
			return accountAccountRelationsService;
		}
		private set;
	}
	private static final String STARTED = ' Started';
	private static final String WITHERROR = 'With Error ';

	private Integer noOfRecordsProcessed = 0;

	public static void scheduleBatch()
	{
		System.schedule(BATCHNAME.trim() + HYPEN + DateTime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new AccountAccountRelationSharingBatchShlr());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new AccountAccountRelationSharingBatchShlr());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		AccountAccountRelationSelector accntAccntRelationsSelector = (AccountAccountRelationSelector) Application.Selector.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType);
		return accntAccntRelationsSelector.getElevatedQLOfAccntAccntRelsCreatEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new AccountAccountAndAccountShareDML());
			accountAccountRelationsService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
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
		AccountContactRelationSharingBatchShlr.start();
	}

	private inherited sharing class AccountAccountAndAccountShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			String errorMessage = ACCOUNTACCOUNTRELATIONSHAREFAILED;
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