@isTest(SeeAllData=false)
public with sharing class PurchaseOrderServiceTest
{
	public static final String APHERESISSITE = 'ApheresisSite';
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String CONTACTROLE = 'ContactRole';
	public static final String TREATMENTSITE = 'TreatmentSite';
	private static final String RETRY = 'Retry';

	@testSetup static void testDataSetup()
	{
		List<Account> accountToBeInserted = TestDataFactory.getPatientAccountsList();

		List<String> listOfSitesNames = new List<String>();
		listOfSitesNames.add(TREATMENTSITE);
		listOfSitesNames.add(APHERESISSITE);

		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		for (String siteName : listOfSitesNames)
		{
			accountToBeInserted.add(TestDataFactory.getBusinessAccountToInsert(siteName));
		}
		insert accountToBeInserted;

		List<Contact> siteContactList = new List<Contact>();
		Set<Id> patientIds = new Set<Id>();
		List<Account> businessAccounts = new List<Account>();
		for (Account site : accountToBeInserted)
		{
			if (PatientRecordTypeId.equals(site.RecordTypeId))
			{
				patientIds.add(site.Id);
			}
			else
			{
				siteContactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
				businessAccounts.add(site);
			}
		}
		insert siteContactList;

		Map<Id, Contact> contactsByAccountMap =
				((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
						.selectByAccountId(patientIds).getContactsByAccountId();
		List<AccountContactRelation> accConRelationList = new List<AccountContactRelation>();
		accConRelationList.addAll(TestDataFactory.getAccountContactRelationsToInsert(businessAccounts, contactsByAccountMap.values(), 2));
		insert accConRelationList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(CARTCOORDINATOR, CONTACTROLE);
		roleList.add(carTRole);
		insert roleList;

		List<Account> accountContactList = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectContactsByAccountId(patientIds);
		List<Contact> personaccContactList = new List<Contact>();

		for (Account accounts : accountContactList)
		{
			personaccContactList.add(accounts.Contacts);
		}

		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();
		HealthCloudGA__ContactContactRelation__c conConRelation = TestDataFactory.getContactRelationsToInsert(siteContactList[0].Id, personaccContactList[0].Id, carTRole.Id);
		conRelationList.add(conConRelation);
		insert conRelationList;

		List<Case> caseList = TestDataFactory.getCareplanCasesList(personaccContactList);
		insert caseList;

	}

	@isTest static void itShouldValidateQTCPOtoSDStatus()
	{
		Test.startTest();

		Test.setMock(HttpCalloutMock.class, new PurchaseOrderServiceMock(true));
		Test.enableChangeDataCapture();

		//GIVEN - An order has been selected.
		OrdersSelector orderSelect = new OrdersSelector();
		List<Order__c> orders = orderSelect.selectAll();
		List<Order__c> lstOrderToUpdate = new List<Order__c>();
		Set<Id> sOrderId = new Set<Id>();

		//WHEN QTCPOtoSDStatus__c of an Order is updated as 'Retry'
		for (Order__c order : orders)
		{
			sOrderId.add(order.Id);
			Order__c ord = new Order__c();
			ord.Id = order.Id;
			ord.SitePO__c = '12334';
			ord.AtlasOrderId__c = '32332';
			ord.QTCPOtoSDStatus__c = RETRY;
			lstOrderToUpdate.add(ord);
		}
		update lstOrderToUpdate;
		List<Order__c> listOrders = orderSelect.selectOrdersByOrderId(sOrderId);

		//THEN QTCPOtoSDStatus__c  is updated success
		System.assert(!listOrders.isEmpty());
		System.assertEquals(listOrders[0].QTCPOtoSDStatus__c, RETRY);
		Test.stopTest();
	}
}
