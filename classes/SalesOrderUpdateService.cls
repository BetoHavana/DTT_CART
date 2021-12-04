public inherited sharing class SalesOrderUpdateService
{
    static final String SALESORDERUPDATEFAILEDWITHBELOWRESPONSE =
            'Sales Order Update Failed With Below Response : ';
    static final String SALESORDERUPDATE='SalesOrderUpdate';

	public void callSAPToUpdateSalesOrder(Set<Id> orderIds)
	{

		Map<Id, String> orderIdNServiceInputBody = new SalesOrderUpdateServiceHelper().getCalloutInputRequestBody(orderIds);

		if (orderIdNServiceInputBody.isEmpty()) return;

		HttpRequest request = new HttpRequest();
		List<Order__c> orderUpdateInfo = new List<Order__c>();

		for (Id orderId : orderIds)
		{
			if (string.isBlank(orderIdNServiceInputBody.get(orderId))) continue;

			try
			{
				request = new HttpRequest();
				request.setMethod(CalloutConstants.POST);
				request.setEndpoint(CalloutConstants.CALLOUTCOLON + SALESORDERUPDATE);
				request.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
				request.setHeader(CalloutConstants.CLIENT_ID, CalloutConstants.CREDENTIAL_USERNAMEMERGEFIELD);
				request.setHeader(CalloutConstants.CLIENT_SECRET, CalloutConstants.CREDENTIAL_PWDMERGEFIELD);
				request.setBody(orderIdNServiceInputBody.get(orderId));
				request.setTimeout(CalloutConstants.CALLOUTIMEOUT);

				system.debug('request is '+request.getBody());

				handleCalloutResponse(new Http().send(request), orderId, orderUpdateInfo);
			}
			catch (Exception excp)
			{
                Application.logEntry.error(excp);
                updateOrdersToFailed(orderIds);
			}
		}
        updateSalesOrderToSAPStatus(orderUpdateInfo);
	}
    
    void updateSalesOrderToSAPStatus(List<Order__c> ordersToUpdateSalesOrderToSAPStatus)
    {
        if(ordersToUpdateSalesOrderToSAPStatus.isEmpty()) return ;
        
        ((OrdersService) Application.Service.newInstance(OrdersService.class))
        					.updateOrders(ordersToUpdateSalesOrderToSAPStatus);
    }
    
   void updateOrdersToFailed(Set<Id> orderIds)
   {
       List<Order__c> ordersToUpdateFailureStatus = new List<Order__c>();
       for(Id orderId : orderIds)
       {
           ordersToUpdateFailureStatus.add(new Order__c(Id=orderId,SalesOrderToSAPStatus__c=CalloutConstants.FAILURE));
       }
       
       ((OrdersService) Application.Service.newInstance(OrdersService.class))
        					.updateOrders(ordersToUpdateFailureStatus);
   }

	void handleCalloutResponse(HttpResponse response, Id OrderId, List<Order__c> orderUpdateInfo)
	{
		System.debug('Response is '+response.getBody());

		CalloutOutputUtility output = (CalloutOutputUtility) JSON.deserialize(response.getBody(), CalloutOutputUtility.Class);
		output.orderId = OrderId;

		boolean transactionSucceeded = determineWhetherServiceFailedOrSucceeded(response.getStatusCode(), output);

		orderUpdateInfo.add(new Order__c(Id = orderId,
				                            SalesOrderToSAPStatus__c = transactionSucceeded ?  
                                            CalloutConstants.SUCCESS : CalloutConstants.FAILURE));
		if (!transactionSucceeded)
		{
			Application.logEntry.error(SALESORDERUPDATEFAILEDWITHBELOWRESPONSE + JSON.serializePretty(output));
		}
	}

	boolean determineWhetherServiceFailedOrSucceeded(Integer statusCode, CalloutOutputUtility output)
	{
		return CalloutConstants.TWO_HUNDRED_AND_ONE == statusCode && output != null && CalloutConstants.SUCCESS.equalsIgnoreCase(output.status);
	}
}