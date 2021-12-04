public with sharing class CPEProductSharingBatchScheduler implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String CPEPRODUCTSHARERECORDCREATIONFAILED = 'CPEProduct Share Creation Failed for AccountId :';
	private static final String PARENTID = CareProgramEnrolleeProductShare.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDCPEPRODUCTS = ' And Processed {2} CPEPRoducts';
	public static final String BATCHNAME = 'Sharing CPEProduct Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingCPEProductRecordsBatchLastNDays') ;
				LASTNOOFDAYS = string.isBlank(lastNDays) ? 1 : Integer.valueOf(lastNDays);
			}
			return LASTNOOFDAYS;
		}
		set;
	}

	private CareProgramEnrolleeProductsService careProgramEnrolleeProductsService
	{
		get
		{
			if (null == careProgramEnrolleeProductsService)
			{
				careProgramEnrolleeProductsService = (CareProgramEnrolleeProductsService) Application.Service.newInstance(CareProgramEnrolleeProductsService.class);
			}
			return careProgramEnrolleeProductsService;
		}
		set;
	}
	private static final String STARTED = ' Started';
	private static final String WITHERROR = 'With Error ';

	private Integer noOfRecordsProcessed = 0;

	public static void scheduleBatch()
	{
		System.schedule(BATCHNAME.trim() + HYPEN + DateTime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new CPEProductSharingBatchScheduler());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new CPEProductSharingBatchScheduler());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		CareProgramEnrolleeProductsSelector cpeProductSelector = (CareProgramEnrolleeProductsSelector) Application.Selector.newInstance(CareProgramEnrolleeProduct.SObjectType);
		return cpeProductSelector.getElevatedQLOfCPEProuctsCreatEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new CPEProductsShareDML());
			careProgramEnrolleeProductsService.grantAccessToPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDCPEPRODUCTS, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
		CasesSharingBatchScheduler.start();
	}

	private inherited sharing class CPEProductsShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(CPEPRODUCTSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(PARENTID)
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
