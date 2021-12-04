public inherited sharing class PurchaseOrderService
{

	static final Integer ERRORCODE_TWOHUNDRED = 200;
	static final String QTCPOUPDATEFAILEDWITHBELOWRESPONSE = 'QTC PO Update Failed With Below Response : ';

	public void sendQTCPONoticeToSD(Set<Id> orderIds)
	{

		Map<Id, String> orderIdNServiceInputBody = new PurchaseOrderServiceHelper().getCalloutInputRequestBody(orderIds);

		if (orderIdNServiceInputBody.isEmpty())
		{
			return;
		}

		HttpRequest request = new HttpRequest();
		List<Order__c> orderUpdateInfo = new List<Order__c>();

		for (Id orderId : orderIds)
		{
			if (String.isBlank(orderIdNServiceInputBody.get(orderId)))
			{
				continue;
			}

			try
			{
				request = new HttpRequest();
				request.setMethod(CalloutConstants.POST);
				request.setEndpoint('callout:PurchaseOrderConnection');
				request.setHeader('Content-Type', 'application/json;');
				request.setHeader('client_id', '{!$Credential.UserName}');
				request.setHeader('client_secret', '{!$Credential.Password}');
				request.setBody(orderIdNServiceInputBody.get(orderId));
				request.setTimeout(Integer.valueOf(Label.RequestTimeout));
				Application.logEntry.info('Request is INT-03 ' + request.getBody());

				handleCalloutResponse(new Http().send(request), orderId, orderUpdateInfo);
			}
			catch (Exception excp)
			{
				Application.logEntry.error(excp);
				updateOrdersToFailed(orderIds);
			}
		}
		updateQTCPOToSAPStatus(orderUpdateInfo);
	}

	void updateQTCPOToSAPStatus(List<Order__c> ordersToUpdateQTCPOToSDStatus)
	{
		if (ordersToUpdateQTCPOToSDStatus.isEmpty()) return ;

		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Order__c.SObjectType});
		uow.registerDirty(ordersToUpdateQTCPOToSDStatus);
		uow.commitWork();
	}

	void updateOrdersToFailed(Set<Id> orderIds)
	{
		List<Order__c> ordersToUpdateFailureStatus = new List<Order__c>();
		for (Id orderId : orderIds)
		{
			ordersToUpdateFailureStatus.add(new Order__c(Id = orderId, QTCPOtoSDStatus__c = CalloutConstants.FAILURE));
		}

		fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Order__c.SObjectType});
		uow.registerDirty(ordersToUpdateFailureStatus);
		uow.commitWork();
	}

	void handleCalloutResponse(HttpResponse response, Id OrderId, List<Order__c> orderUpdateInfo)
	{
		Application.logEntry.info('Response is INT-03 ' + response.getBody());
		SDNotificationServiceOutput output = (SDNotificationServiceOutput) JSON.deserialize(String.escapeSingleQuotes(response.getBody()), SDNotificationServiceOutput.Class);
		output.orderId = OrderId;
		Boolean transactionSucceeded = determineWhetherServiceFailedOrSucceeded(response.getStatusCode(), output);

		orderUpdateInfo.add(new Order__c(Id = OrderId,
				QTCPOtoSDStatus__c = transactionSucceeded ?
						CalloutConstants.SUCCESS : CalloutConstants.FAILURE));
		if (!transactionSucceeded)
		{
			Application.logEntry.error(QTCPOUPDATEFAILEDWITHBELOWRESPONSE + JSON.serializePretty(output));
		}
	}

	Boolean determineWhetherServiceFailedOrSucceeded(Integer statusCode, SDNotificationServiceOutput output)
	{
		return ERRORCODE_TWOHUNDRED == statusCode && output != null && CalloutConstants.SUCCESS.equalsIgnoreCase(output.status);
	}
}
