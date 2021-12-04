public with sharing class OrderPlacementRescheduleController
{
	private OrderPlacementRescheduleController() //Empty Constructor
	{
	}

	public inherited sharing class DataForComponentLoad
	{
		@AuraEnabled
		public Boolean satisfiedAllValidations { get; set; }
		@AuraEnabled
		public Order__c order { get; set; }
		@AuraEnabled
		public String errorMessageOnValidationsFail { get; set; }

		public DataForComponentLoad(Boolean satisfiedAllValidations,
				Order__c order,
				String errorMessageOnValidationsFail)
		{
			this.satisfiedAllValidations = satisfiedAllValidations;
			this.order = order;
			this.errorMessageOnValidationsFail = errorMessageOnValidationsFail;
		}

	}

	@AuraEnabled
	public static DataForComponentLoad checkForValidationsNPassReqData(String orderId)
	{
		try
		{
			List<Order__c> orders = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
													  .selectOrdersByOrderId(new Set<Id> {orderId});
			return isOrderStatusSubmittedOrVerified(orders[0]) ? checkForFurtherValidationsNPassData(orders[0]) :
																 getOnLoadData(orders[0],
																 getError(orders[0].OrderStatus__c));
		}
		catch (Exception excp)
		{
			throw logExceptionNGetAuraHandledException(excp);
		}
	}

	static String getError(String orderStatus)
	{
		return StaticConstants.REQUESTTYPENEW.equalsIgnoreCase(orderStatus) ? Label.OrderCantBeRescheduledWhenOrderIsNew : Label.OrderCantBeRescheduledViaSystemAsOrderIsInProgress;
	}

	static Boolean isOrderStatusSubmittedOrVerified(Order__c order)
	{
		return StaticConstants.orderSubmitted.equalsIgnoreCase(order.OrderStatus__c) ||
				StaticConstants.orderVerified.equalsIgnoreCase(order.OrderStatus__c);
	}

	static DataForComponentLoad getOnLoadData(Order__c order, String errorMessage)
	{
		return new DataForComponentLoad(string.isBlank(errorMessage), order, errorMessage);
	}

	static DataForComponentLoad checkForFurtherValidationsNPassData(Order__c order)
	{
		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType))
				.selectBusinessHoursByName(Label.BusinessHoursNameForOrderSubmissionRescheduling);
		BusinessHoursCalculatorImp bhCalculatorImp = new BusinessHoursCalculatorImp(businessHours[0].Id);
		Integer noOfDays = Integer.valueOf(bhCalculatorImp.getDifferenceBetweenTimeSpans(Date.today(), order.ApheresisPickUpDate__c) / BusinessHoursCalculator.oneDayToMilliSeconds);
		return getOnLoadData(order, noOfDays >= 0 && noOfDays <= 1 ? Label.OrderCantBeRescheduledViaSystemAsOrderIsInProgress : '');
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
	static AuraHandledException logExceptionNGetAuraHandledException(Exception excp)
	{
		Application.logEntry.error(excp);
		AuraHandledException auraHandledException = new AuraHandledException(excp.getMessage());
		auraHandledException.setMessage(excp.getStackTraceString());
		return auraHandledException;
	}
}
