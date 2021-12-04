public with sharing class OrdersSharingBatchScheduler implements Database.Batchable<SObject>, Schedulable, Database.stateful
{

	private static final String ORDERSSHARERECORDCREATIONFAILED = 'Order Share Creation Failed for GoalId :';
	private static final String ORDERID = Order__Share.ParentId.getDescribe().getName();
	private static final String ANDPROCESSEDORDERS = ' And Processed {2} Orders';
	public static final String BATCHNAME = 'Sharing Order Records Batch';
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
				String lastNDays = sflib_Settings.get('SharingOrderRecordsBatchLastNDays') ;
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
		System.schedule(BATCHNAME.trim() + HYPEN + datetime.now().format(), CRONEXPR_FORDAILYSTARTOFDAY, new OrdersSharingBatchScheduler());
	}

	public void execute(SchedulableContext sc)
	{
		start();
	}

	public static void start()
	{
		Id batchProcessId = Database.executeBatch(new OrdersSharingBatchScheduler());
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE, new List<String> {(String) batchProcessId, STARTED});
	}

	public Database.queryLocator start(Database.BatchableContext bc)
	{
		OrdersSelector OrdersSelector = (OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType);
		return ordersSelector.getQLOfOrdersCreatedEditedInLastNDays(LASTNOOFDAYS);
	}

	public void execute(Database.BatchableContext bc, List<SObject> scope)
	{
		try
		{
			noOfRecordsProcessed += scope.size();
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new OrdersShareDML());
			OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
			ordersService.grantAccessToRelatedPublicGroups(unitOfWork, scope);
			unitOfWork.commitWork();
		}
		catch (Exception excp)
		{
			Application.LogEntry.error(excp);
		}
	}

	public void finish(Database.BatchableContext bc)
	{
		Application.LogEntry.info(BATCHNAME + BATCHLOGGINGMESSAGE + ANDPROCESSEDORDERS, new List<String> {(String) bc.getJobId(), FINISHED, String.valueOf(noOfRecordsProcessed)});
	}

	private inherited sharing class OrdersShareDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			List<Database.SaveResult> saveResults = Database.insert(objList, false);
			for (Integer iteration = 0; iteration < saveResults.size(); iteration++)
			{
				if (!saveResults.get(iteration).isSuccess())
				{
					Application.LogEntry.error(ORDERSSHARERECORDCREATIONFAILED + objList.get(iteration)?.get(ORDERID)
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