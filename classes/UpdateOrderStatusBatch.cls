global with sharing class UpdateOrderStatusBatch implements Database.Batchable<sObject>
{
	global Database.QueryLocator start(Database.BatchableContext bc)
	{
		return ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.selectByApheresisDueDate();
	}

	global void execute(Database.BatchableContext bc, List<Order__c> orderList)
	{
		try
		{
			OrdersService ordSer = new OrdersService();
			ordSer.updateOrderRelatedGoalsAndTasks(orderList);
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	global void finish(Database.BatchableContext bc)
	{
		Application.logEntry.info(
				'Batch {0} for order,goal and task status update is finished',
				new List<String> {(String) bc.getJobId()}
		);
	}
}