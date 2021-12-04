public with sharing class SiteProductsSharingBatchScheduler implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String ACCOUNTSHARERECORDCREATIONFAILED = 'SP Account Share Creation Failed for AccountId :';
	private static final String ACCOUNTID = AccountShare.AccountId.getDescribe().getName();
	private static final String ANDPROCESSEDACCOUNTS = ' And Processed {2} Accounts';
	public static final String BATCHNAME = 'Sharing SiteProduct Accounts Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingSPAccountsRecordsBatchLastNDays') ;
				LASTNOOFDAYS = string.isBlank(lastNDays) ? 1 : Integer.valueOf(lastNDays);
			}
			return LASTNOOFDAYS;
		}
		set;
	}
	private static SiteProductsService siteProductsService
	{
		get
		{
			if (null == siteProductsService)
			{
				siteProductsService = (SiteProductsService) Application.Service.newInstance(SiteProductsService.class);
			}
			return siteProductsService;
		}
		private set;
	}
	private static final String STARTED = ' Started';
	private static final String WITHERROR = 'With Error ';

	private Integer noOfRecordsProcessed = 0;

	public static void scheduleBatch()
	{
		System.schedule(BATCHNAME.trim() + HYPEN + DateTime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new SiteProductsSharingBatchScheduler());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new SiteProductsSharingBatchScheduler());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		SiteProductsSelector siteProductsSelector = (SiteProductsSelector) Application.Selector.newInstance(SiteProduct__c.SObjectType);
		return siteProductsSelector.getElevatedQLOfSiteProuctsCreatEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new AccountsShareDML());
			siteProductsService.getSiteShareRecords(unitOfWork, scope);
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
		AccountAccountRelationSharingBatchShlr.start();
	}

	private inherited sharing class AccountsShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(ACCOUNTSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(ACCOUNTID)
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
