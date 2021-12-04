public with sharing class PurchaseOrderServiceHelper implements ICalloutServiceHelper
{
	private static final String TREATMENTSITE = 'Treatment Site';

	public Map<Id, String> getCalloutInputRequestBody(Set<Id> orderIds)
	{
		Map<Id, String> orderIdNInputBody = new Map<Id, String>();

		List<Order__c> orders = ((OrdersSelector) Application.Selector
				.newInstance(Order__c.SObjectType))
				.selectOrdersByOrderId(orderIds);

		Set<Id> treatmentSiteIds = sflib_ArrayUtils.pluckIdField(orders, Order__c.TreatmentSite__c);

		if (treatmentSiteIds.isEmpty())
		{
			return orderIdNInputBody;
		}

		Map<Id, Account> treatmentSitesInfo = ((AccountsSelector) Application.Selector.newInstance
				(Account.SObjectType)).selectById(treatmentSiteIds).getById();

		SDNotificationServiceInput input = new SDNotificationServiceInput();
		Set<Id> patientIds = sflib_ArrayUtils.pluckIdField(orders, Order__c.Patient__c);
		Map<Id, String> patientMRNInfo = getPatientMRNInfo(patientIds);

		for (Order__c order : orders)
		{
			if (order.TreatmentSite__c == null || order.TreatmentSite__r.ERPSiteID__c == null)
			{
				continue;
			}
			input = new SDNotificationServiceInput();
			input.CARTOrderId = order.CartOrderId__c;
			input.TreatmentSiteID = order.TreatmentSite__r.ERPSiteID__c;
			input.QTCPO = String.valueOf(order.SitePO__c);
			input.MRN = patientMRNInfo ?.get(order.Patient__c);
			orderIdNInputBody.put(order.Id, JSON.serialize((SDNotificationServiceInput) input));
		}
		return orderIdNInputBody;
	}

	Map<Id, String> getPatientMRNInfo(Set<Id> patientIds)
	{
		AccountContactRelationsSelector acrSelector = (AccountContactRelationsSelector) Application.Selector
				.newInstance(AccountContactRelation.SObjectType);
		Map<Id, String> patientAndMRNInfo = new Map<Id, String>();
		for (AccountContactRelation acr : acrSelector.selectByContactAccountId(patientIds))
		{
			if (String.isNotBlank(acr.Roles) && acr.Roles.split(';').contains(TREATMENTSITE))
			{
				patientAndMRNInfo.put(acr.Contact.AccountId, acr.MedicalRecordNumber__c);
			}
		}
		return patientAndMRNInfo;
	}
}
