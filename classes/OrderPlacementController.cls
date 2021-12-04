public with sharing class OrderPlacementController
{
	private static OrdersService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (OrdersService) Application.Service.newInstance(OrdersService.class);
			}
			return Service;
		}
		set;
	}

	@AuraEnabled
	public static List<Order__c> getOrderDetails(List<Id> listOfOrderIds)
	{
		try
		{
			return ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
					.selectOrdersByOrderId(new Set<Id> (listOfOrderIds));
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static Map<Id, List<String>> validateOrderRequiredFieldsBeforeScheduling(List<Order__c> listOfOrders)
	{
		try
		{
			return Service.validateRequiredFieldsBeforeScheduling(listOfOrders);
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static String sendSlotBookingRequest(Object confirmSlotAndOrderUpdateInfo)
	{
		try
		{
			SlotAndOrderUpdateInfo slotAndOrderUpdateInfo = (SlotAndOrderUpdateInfo) JSON.deserialize(JSON.serialize(confirmSlotAndOrderUpdateInfo),
					SlotAndOrderUpdateInfo.class);
			slotAndOrderUpdateInfo.order = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
                							.selectOrdersByOrderId(new Set<Id>{slotAndOrderUpdateInfo.orderId})[0];
			return new ConfirmApheresisSlotService().confirmApheresisSlot(slotAndOrderUpdateInfo);
		}
		catch (Exception excp)
		{
			throw logExceptionNGetAuraHandledException(excp);
		}
	}

	@AuraEnabled
	public static String elevatedSendSlotBookingRequest(Object confirmSlotAndOrderUpdateInfo)
	{
		try
		{
			SlotAndOrderUpdateInfo slotAndOrderUpdateInfo = (SlotAndOrderUpdateInfo) JSON.deserialize(JSON.serialize(confirmSlotAndOrderUpdateInfo),
					SlotAndOrderUpdateInfo.class);
			slotAndOrderUpdateInfo.order = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
											.elevatedSelectByAccountId(new Set<Id> {slotAndOrderUpdateInfo.patientId})[0];
			return new ConfirmApheresisSlotService().confirmApheresisSlot(slotAndOrderUpdateInfo);
		}
		catch (Exception excp)
		{
			throw logExceptionNGetAuraHandledException(excp);
		}
	}
	static AuraHandledException logExceptionNGetAuraHandledException(Exception excp)
	{
		Application.logEntry.error(excp);
		AuraHandledException auraHandledException = new AuraHandledException(excp.getMessage());
		auraHandledException.setMessage(excp.getStackTraceString());
		return auraHandledException;
	}
}