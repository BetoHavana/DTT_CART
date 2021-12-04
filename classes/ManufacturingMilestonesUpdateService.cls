public inherited sharing class ManufacturingMilestonesUpdateService {

    static final String MFNGMILESTONEUPDATESERVICEWITHBELOWRESPONSE =
            'Manufacturing Milestones update Failed With Below Response : ';
    static final String SHIPMENTNMILESTONEMANUFACTURING ='ShipmentAndMilestoneManufacturing';

	public void callAnaplanToUpdateManufacturingMilestones(Set<Id> orderMileStoneIds)
    {
        Map<Id, String> orderIdNServiceInputBody = new ManufacturingMilestonesUpdteSrvceHelper()
          											 		.getCalloutInputRequestBody(orderMileStoneIds);
        if(orderIdNServiceInputBody == null || orderIdNServiceInputBody.isEmpty()) return ;

        HttpRequest request = new HttpRequest();
		List<Order__c> orderUpdateInfo = new List<Order__c>();
		for (Id orderId : orderIdNServiceInputBody.keySet())
		{
			if (string.isBlank(orderIdNServiceInputBody.get(orderId))) continue;

			try
			{
				request = new HttpRequest();
				request.setMethod(CalloutConstants.PUT);
				request.setEndpoint(CalloutConstants.CALLOUTCOLON + SHIPMENTNMILESTONEMANUFACTURING);
				request.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
				request.setHeader(CalloutConstants.CLIENT_ID, CalloutConstants.CREDENTIAL_USERNAMEMERGEFIELD);
				request.setHeader(CalloutConstants.CLIENT_SECRET, CalloutConstants.CREDENTIAL_PWDMERGEFIELD);
				request.setBody(orderIdNServiceInputBody.get(orderId));
				request.setTimeout(CalloutConstants.CALLOUTIMEOUT);
				System.debug('Request## '+request.getBody());
				handleCalloutResponse(new Http().send(request), orderId, orderUpdateInfo);
			}
			catch (Exception excp)
			{
                Application.logEntry.error(excp);
                updateOrdersToFailed(orderIdNServiceInputBody.keySet());
			}
		}

         updateManufacturingMilestoneToAnaplanStatus(orderUpdateInfo);
    }

    void updateManufacturingMilestoneToAnaplanStatus(List<Order__c> ordersToUpdateMfngMilestoneToAnaplanStatu)
    {
        if(ordersToUpdateMfngMilestoneToAnaplanStatu.isEmpty()) return ;

        ((OrdersService) Application.Service.newInstance(OrdersService.class))
        					.updateOrders(ordersToUpdateMfngMilestoneToAnaplanStatu);
    }

    void updateOrdersToFailed(Set<Id> orderIds)
   {
       List<Order__c> ordersToUpdateFailureStatus = new List<Order__c>();
       for(Id orderId : orderIds)
       {
           ordersToUpdateFailureStatus.add(new Order__c(Id=orderId,
				   	                           ManufacturingMilestoneToAnaplanStatus__c = CalloutConstants.FAILURE));
       }

       ((OrdersService) Application.Service.newInstance(OrdersService.class))
        					.updateOrders(ordersToUpdateFailureStatus);
   }

	void handleCalloutResponse(HttpResponse response, Id OrderId, List<Order__c> orderUpdateInfo)
	{
		System.debug('Response## '+response.getBody());
        CalloutOutputUtility output = (CalloutOutputUtility) JSON.deserialize(
		                              string.escapeSingleQuotes(response.getBody()), CalloutOutputUtility.Class);
		output.orderId = OrderId;

		boolean transactionSucceeded = determineWhetherServiceFailedOrSucceeded(response.getStatusCode(), output);

		orderUpdateInfo.add(new Order__c(Id = orderId,
				                            ManufacturingMilestoneToAnaplanStatus__c = transactionSucceeded ?
                                            CalloutConstants.SUCCESS : CalloutConstants.FAILURE));
		if (!transactionSucceeded)
		{
			Application.logEntry.error(MFNGMILESTONEUPDATESERVICEWITHBELOWRESPONSE + JSON.serializePretty(output));
		}
	}

	boolean determineWhetherServiceFailedOrSucceeded(Integer statusCode, CalloutOutputUtility output)
	{
        return CalloutConstants.TWOHUNDRED == statusCode && output != null && CalloutConstants.SUCCESS.equalsIgnoreCase(output.status);
	}
}
