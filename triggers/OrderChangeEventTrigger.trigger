trigger OrderChangeEventTrigger on Order__ChangeEvent (after insert)
{
	OrdersService.getShipmentStatusFromSAP(Trigger.new);
}