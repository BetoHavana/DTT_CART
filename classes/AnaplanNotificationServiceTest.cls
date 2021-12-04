@IsTest(SeeAllData=false)
public with sharing class AnaplanNotificationServiceTest
{

	private static final String RETRY = 'Retry';

	//GIVEN - A care plan has been created for a patient, and order has been generated.
	@TestSetup static void testDataSetup()
	{
		List<Account> accountToBeInserted = TestDataFactory.getPatientAccountsList();
		insert accountToBeInserted;

		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		for (Account patient : accountToBeInserted)
		{
			patient.RecordTypeId = PatientRecordTypeId;
		}
		update accountToBeInserted;

		List<Order__c> lstOrder = new List<Order__c>();
		lstOrder.add(new Order__c(Patient__c = accountToBeInserted[0].Id, AtlasOrderId__c = '574121', CartOrderId__c = 'ORD-0057'));
		insert lstOrder;
	}

	@isTest
	static void itShouldValidateASNToAnaplanStatus()
	{
		//WHEN ASNToAnaplanStatus__c of an Order is updated as 'Retry'
		Test.setMock(HttpCalloutMock.class, new AnaplanNotificationServiceMock(true));
		Test.enableChangeDataCapture();
		Test.startTest();
		OrdersSelector orderSelect = new OrdersSelector();
		List<Order__c> orders = orderSelect.SelectAll();
		List<Order__c> lstOrderToUpdate = new List<Order__c>();
		Set<Id> sOrderId = new set<Id>();

		for (Order__c order : orders)
		{
			sOrderId.add(order.id);
			Order__c ord = new Order__c();
			ord.Id = order.Id;
			ord.FreshCellPickupDateAndTime__c = Date.today();
			ord.CryoCellPickupDateAndTime__c = Date.today();
			ord.ASNToAnaplanStatus__c = RETRY;
			lstOrderToUpdate.add(ord);
		}
		update lstOrderToUpdate;
		List<Order__c> listOrders = orderSelect.selectOrdersByOrderId(sOrderId);

		//THEN ASNToAnaplanStatus__c  is updated success
		System.assert(!listOrders.isempty());
		System.assertEquals(listOrders[0].ASNToAnaplanStatus__c, RETRY);
		Test.stopTest();
	}
}
