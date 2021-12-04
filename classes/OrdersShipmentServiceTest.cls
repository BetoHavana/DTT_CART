@IsTest(SeeAllData=false)
public with sharing class OrdersShipmentServiceTest {

	//GIVEN - A care plan has been created for a patient, and order has been generated.
	@TestSetup static void testDataSetup()
	{
		List<Account> accountToBeInserted = TestDataFactory.getPatientAccountsList();
        insert accountToBeInserted;
        
		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		for(Account a : accountToBeInserted){
			a.RecordTypeId = PatientRecordTypeId;
		}
		update accountToBeInserted;

		List<Order__c> lstOr = new List<Order__c>();
		lstOr.add(new Order__c(Patient__c = accountToBeInserted[0].Id, AtlasOrderId__c = '574121', CartOrderId__c = 'ORD-0057'));
		insert lstOr;
	}

    @isTest 
    static void itShouldValidateShipmentStatusToSAP(){
        //WHEN DPOkToShipToSAPStatus__c of an Order is updated as 'Retry'
		Test.setMock(HttpCalloutMock.class, new OrdersShipmentServiceMock());
		Test.enableChangeDataCapture();
		Test.startTest();
		OrdersSelector orderSelect = new OrdersSelector();
		List<Order__c> orders = orderSelect.SelectAll();
		List<Order__c> lstOrderToUpdate = new List<Order__c>();
		set<Id> sOrderId = new set<Id>();
        for (Order__c order : orders){
				sOrderId.add(order.id);
				Order__c ord = new Order__c();
				ord.Id = order.Id;
				ord.ConfirmedFPDeliveryDate__c =  Date.today();
				ord.AtlasOrderId__c = '574121';
				ord.CartOrderId__c = 'ORD-0057';
				ord.DPOkToShipToSAPStatus__c = 'Retry';
				lstOrderToUpdate.add(ord);
        }
		update lstOrderToUpdate;
		List<Order__c> listOrders = orderSelect.selectOrdersByOrderId(sOrderId);
        //THEN DPOkToShipToSAPStatus__c  is updated success
		System.assert(!listOrders.isempty());
		System.assertEquals(listOrders[0].DPOkToShipToSAPStatus__c, 'Retry');
		Test.stopTest();
		Test.getEventBus().deliver();
    }

}