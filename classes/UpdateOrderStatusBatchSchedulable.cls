global with sharing class UpdateOrderStatusBatchSchedulable implements Schedulable
{
	global void execute(SchedulableContext sc)
	{
		UpdateOrderStatusBatch b = new UpdateOrderStatusBatch();
		Database.executebatch(b);
	}
}