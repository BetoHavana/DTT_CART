@isTest(seeAllData=false)
public with sharing class OrderPlacementControllerTest
{
	static final String ACCOUNTROLE = 'AccountRole';
	static final String THIRDPARTY = '3rd party';
	static final String CONTENTTYPE = 'Content-Type';
	static final String APPLICATIONJSON = 'application/json';
	static final String ERPSITEID = 'CRY0001';
	static final String CONTACTROLE = 'ContactRole';
	static final String JNJPRODUCT = 'JNJ-4528';
	static final String TESTCAREPROGRAM = 'Test Care Program';
	static final String TESTLOCATION = 'Test Location';
	static final String OK = 'OK';
	static final String ORDERSTATUSSUBMITTED = 'Order Submitted';
	static final String ORDERRESCHEDULED = 'Order Rescheduled';
	static final String ORDERSTATUSNEW = 'New';
	static final String SLOTREQUESTED = 'Slot Requested';

	//GIVEN test data to confirm Slot Booking for an Order
	@testSetup
	private static void setUpTestData()
	{
		List<String> listOfSitesNames = new List<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName, StaticConstants.APHERESISSITE, StaticConstants.CRYOSITE};
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		for (String siteName : listOfSitesNames)
		{
			accToBeInserted.add(TestDataFactory.getBusinessAccountToInsert(siteName));
		}
		insert accToBeInserted;

		AccountsSelector accInstanceRecords = new AccountsSelector();
		String cryorecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.CRYOSITE).getRecordTypeId();
		List<Account> cryoSiteRec = accInstanceRecords.selectByDeveloperName(cryorecTypeId);
		cryoSiteRec[0].ERPSiteID__c = ERPSITEID;
		cryoSiteRec[0].Type = THIRDPARTY;
		update cryoSiteRec;
		List<Schema.Location> locationsList = TestDataFactory.getLocationRecords('Test location', 1);
		insert locationsList;
		List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecords(new Map<Id, Id> {cryoSiteRec[0].Id => locationsList[0].Id});
		insert assLocList;
		List<Contact> contactList = new List<Contact>();
		String PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.PatientRecordTypeDeveloperName).getRecordTypeId();
		for (Account site : accToBeInserted)
		{
			if (!PatientRecordTypeId.equals(site.RecordTypeId))
			{
				contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
			}
		}

		insert contactList;
		insertContactRole(accToBeInserted, contactList);
	}

	private static void insertContactRole(List<Account>accToBeInserted, List<Contact>contactList)
	{
		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(StaticConstants.CARTCOORDINATOR, CONTACTROLE);
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole(StaticConstants.APHERESISSITELABEL, ACCOUNTROLE);
		HealthCloudGA__ReciprocalRole__c cryoSiteRole1 = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, ACCOUNTROLE);
		roleList.add(carTRole);
		roleList.add(aphSiteRole1);
		roleList.add(cryoSiteRole1);
		insert roleList;

		insertCareProgramAndRelatedInfo(accToBeInserted[0].Id);
		insertLocationDataForAccount(accToBeInserted[0].Id);
		AccountsSelector accinstanceRecords = new AccountsSelector();
		String PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.PatientRecordTypeDeveloperName).getRecordTypeId();
		List<Account> accList = accinstanceRecords.selectAllContactsForAccount(PatientRecordTypeId);
		List<Contact> conList = new List<Contact>();
		List<Contact> patientContactsList = new List<Contact>();
		for (Account acc : accList)
		{
			if (PatientRecordTypeId.equals(acc.RecordTypeId))
			{
				patientContactsList.add(acc.Contacts);

			}
			conList.add(acc.Contacts);
		}

		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();
		HealthCloudGA__ContactContactRelation__c conRel1 = TestDataFactory.getContactRelationsToInsert(contactList[0].Id, conList[0].Id, carTRole.Id);
		conRelationList.add(conRel1);
		HealthCloudGA__ContactContactRelation__c conRel2 = TestDataFactory.getContactRelationsToInsert(contactList[1].Id, conList[1].Id, carTRole.Id);
		conRelationList.add(conRel2);
		insert conRelationList;
		List<HealthCloudGA__AccountAccountRelation__c> accRelationList = new List<HealthCloudGA__AccountAccountRelation__c>();
		HealthCloudGA__AccountAccountRelation__c accRel1 = TestDataFactory.getAccountRelationsToInsert(accToBeInserted[0].Id, accToBeInserted[1].Id, aphSiteRole1.Id);
		accRelationList.add(accRel1);
		HealthCloudGA__AccountAccountRelation__c accRel2 = TestDataFactory.getAccountRelationsToInsert(accToBeInserted[1].Id, accToBeInserted[3].Id, cryoSiteRole1.Id);
		accRelationList.add(accRel2);
		insert accRelationList;
		insertOrder(patientContactsList);

		String treatmentSiteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.TreatmentSiteRecordTypeDeveloperName).getRecordTypeId();
		List<Account> TreatmentsiteList = accInstanceRecords.selectByDeveloperName(treatmentSiteRecTypeId);
		insertLocationDataForAccount(TreatmentsiteList[0].Id);

	}
	private static void insertOrder(List<contact> patientContactsList)
	{
		List<Case> caseList = TestDataFactory.getCareplanCasesList(patientContactsList);
		insert caseList;
		OrdersSelector selectorInstance = new OrdersSelector();
		List<Order__c> ordersList = selectorInstance.selectAll();
		ordersList[0].CryoType__c = StaticConstants.CryoSiteCentral;
		for (Order__c ord : ordersList)
		{
			ord.ApheresisPickUpDate__c = Date.Today().addDays(5);
		}
		update ordersList;
	}

	private static void insertCareProgramAndRelatedInfo(Id patientId)
	{
		List<CareProgram> careProgramsList = TestDataFactory.getCareProgramsList(TESTCAREPROGRAM, 1);
		insert careProgramsList;
		List<Product2> productList = TestDataFactory.getProductsList(JNJPRODUCT, 1);
		insert productList;
		List<CareProgramProduct> cppList = TestDataFactory.getCareProgramProductRecords(new Map<Id, Id> {careProgramsList[0].Id => productList[0].Id});
		insert cppList;
		List<CareProgramEnrollee> cpeList = TestDataFactory.getCareProgramEnrolleeRecords(new Map<Id, Id> {patientId => careProgramsList[0].Id});
		insert cpeList;
		List<CareProgramEnrolleeProduct> cpepList = TestDataFactory.getCareProgramEnrolleeProductRecords(new Map<Id, Id> {cpeList[0].Id => cppList[0].Id});
		insert cpepList;
	}

	private static void insertLocationDataForAccount(Id accountId)
	{
		List<Schema.Location> locationsList = TestDataFactory.getLocationRecords(TESTLOCATION, 10);
		insert locationsList;
		List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecords(new Map<Id, Id> {accountId => locationsList[0].Id});
		insert assLocList;
	}

	@isTest
	private static void itShouldConfirmSlotBooking()
	{
		//GIVEN that I'm on an Order record
		OrdersSelector selectorInstance = new OrdersSelector();
		List<Order__c> obtainedRecords = selectorInstance.selectAll();
		//WHEN Order is submitted
		Test.startTest();
		String respBody = '{"code":"JNJ101","message":" ","status":"Success","cryoSiteId":"CRY0001","slotConfirmed": "2020-09-05","slotId": "112020MFG0001"}';
		SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(200, OK, respBody, new Map<String, String> {CONTENTTYPE => APPLICATIONJSON});
		Test.setMock(HttpCalloutMock.class, mockCallout);
		OrderPlacementController.validateOrderRequiredFieldsBeforeScheduling(obtainedRecords);
		String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"2020-10-18","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"New","sourceOfRequest":"CCM","therapyType":"Commercial"}';
		SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
		inputRequest.orderId = obtainedRecords[0].Id;
		OrderPlacementController.sendSlotBookingRequest(inputRequest);
		List<Order__c> updatedOrder = selectorInstance.selectOrdersByOrderId(new Set<Id> {obtainedRecords[0].Id});
		Test.stopTest();
		//THEN Slot Status should be updated to ' Slot Requested' and Cryo Site is populated on order
		system.assertEquals(SLOTREQUESTED, updatedOrder[0].SlotStatus__c);
		system.assertEquals(ERPSITEID, updatedOrder[0].CryoSite__r.ERPSiteID__c);

		try
		{
			String slotBookingAndUpdateInfos = '{"apheresisSiteERPId":"","aphPickUpDate":"2023-10-18","cryoType":"Central","projectedDeliveryDate":"","requestType":"","sourceOfRequest":""}';
			SlotAndOrderUpdateInfo inputRequests = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfos, SlotAndOrderUpdateInfo.class);
			inputRequest.orderId = obtainedRecords[0].Id;
			OrderPlacementController.sendSlotBookingRequest(inputRequests);
		}
		catch (Exception e)
		{
			system.assertEquals(AuraHandledException.class.getName(), e.getTypeName());
		}
	}

	@isTest
	private static void itShouldSendSlotBookingRequest()
	{
		//GIVEN that I'm on an TCP Schedule Apheresis Screen of a Patient
		OrdersSelector selectorInstance = new OrdersSelector();
		Map<Id, Account> mapAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectPatients().getById();
		//WHEN Order is submitted
		Test.startTest();
		String respBody = '{"code":"JNJ101","message":" ","status":"Success","cryoSiteId":"","slotConfirmed": "2020-09-05","slotId": "112020MFG0001"}';
		SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(200, OK, respBody, new Map<String, String> {CONTENTTYPE => APPLICATIONJSON});
		Test.setMock(HttpCalloutMock.class, mockCallout);
		String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"2020-10-18","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"New","sourceOfRequest":"TCP","therapyType":"Commercial"}';
		SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
		inputRequest.patientId = mapAccounts.values()[0].Id;
		OrderPlacementController.elevatedSendSlotBookingRequest(inputRequest);
		List<Order__c> updatedOrder = selectorInstance.selectOrdersByPatientId(new Set<Id> {mapAccounts.values()[0].Id});
		Test.stopTest();
		//THEN Slot Status should be updated to ' Slot Requested' on order
		system.assertEquals(SLOTREQUESTED, updatedOrder[0].SlotStatus__c);

		try
		{
			String slotBookingAndUpdateInfos = '{"apheresisSiteERPId":"","aphPickUpDate":"2023-10-18","cryoType":"Central","projectedDeliveryDate":"","requestType":"","sourceOfRequest":""}';
			SlotAndOrderUpdateInfo inputRequests = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfos, SlotAndOrderUpdateInfo.class);
			inputRequest.patientId = mapAccounts.values()[0].Id;
			OrderPlacementController.elevatedSendSlotBookingRequest(inputRequests);
		}
		catch (Exception e)
		{
			system.assertEquals(AuraHandledException.class.getName(), e.getTypeName());
		}
	}

	@isTest
	private static void itShouldSendSlotBookingBadRequest()
	{
		//GIVEN that I'm on an TCP Schedule Apheresis Screen of a Patient

		OrdersSelector selectorInstance = new OrdersSelector();
		Map<Id, Account> mapAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectPatients().getById();
		//WHEN Order is submitted
		Test.startTest();
		SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(400, 'Failure', 'Bad request', new Map<String, String> {CONTENTTYPE => APPLICATIONJSON});
		Test.setMock(HttpCalloutMock.class, mockCallout);
		String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"Commercial","sourceOfRequest":"CCM","therapyType":"Commercial"}';
		SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
		inputRequest.patientId = mapAccounts.values()[0].Id;
		OrderPlacementController.elevatedSendSlotBookingRequest(inputRequest);
		List<Order__c> updatedOrder = selectorInstance.selectOrdersByPatientId(new Set<Id> {mapAccounts.values()[0].Id});
		Test.stopTest();
		//THEN Slot Status will remains Blank on order as there is Bad request from JSON
		system.assert(String.isBlank(updatedOrder[0].SlotStatus__c));
	}

	@isTest
	private static void itShouldRescheduleOrder()
	{
		//GIVEN that I'm on an Order record
		OrdersSelector selectorInstance = new OrdersSelector();
		List<Order__c> obtainedRecords = selectorInstance.selectAll();
		//WHEN Order is submitted
		Test.startTest();
		String respBody = '{"code":"JNJ101","message":" ","status":"Success","cryoSiteId":"CRY0001","slotConfirmed": "2020-09-05","slotId": "112020MFG0001"}';
		SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(200, OK, respBody, new Map<String, String> {CONTENTTYPE => APPLICATIONJSON});
		Test.setMock(HttpCalloutMock.class, mockCallout);
		String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"2020-10-18","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"Reschedule","sourceOfRequest":"CCM","therapyType":"Commercial"}';
		SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
		inputRequest.orderId = obtainedRecords[0].Id;
		OrderPlacementRescheduleController.sendSlotBookingRequest(inputRequest);
		List<Order__c> updatedOrder = selectorInstance.selectOrdersByOrderId(new Set<Id> {obtainedRecords[0].Id});
		Test.stopTest();
		//THEN Slot Status should be updated to ' Slot Requested'
		system.assertEquals(SLOTREQUESTED, updatedOrder[0].SlotStatus__c);
	}

	@isTest
	private static void itShouldShowUnavailableSlotsRescheduleFlow()
	{
		try
		{
			//GIVEN I'm on Order record
			OrdersSelector selectorInstance = new OrdersSelector();
			List<Order__c> obtainedRecords = selectorInstance.selectAll();
			obtainedRecords[0].orderStatus__c = ORDERSTATUSNEW;
			Test.startTest();
			//WHEN Order is submitted and there are no available slots
			String respBody = '{"errorCode":"JNJ007","errorMessage":"Slot is unavailable. Please select another Apheresis Pickup Date.","numberOfRecords":0,"cryoSiteId":"CRY1234"}';
			SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(200, OK, respBody, new Map<String, String> {CONTENTTYPE => APPLICATIONJSON});
			Test.setMock(HttpCalloutMock.class, mockCallout);
			String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"2020-10-18","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"Reschedule","sourceOfRequest":"CCM","therapyType":"Commercial"}';
			SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
			inputRequest.orderId = obtainedRecords[0].Id;
			OrderPlacementRescheduleController.sendSlotBookingRequest(inputRequest);
			List<Order__c> updatedOrders = selectorInstance.selectAll();
			Test.stopTest();
			//THEN the order status should not be updated to Rescheduled
			system.assertNotEquals(ORDERRESCHEDULED, updatedOrders[0].SlotStatus__c);
		}
		catch (Exception e)
		{
			system.assertEquals(AuraHandledException.class.getName(), e.getTypeName());
		}
	}

	@isTest
	private static void itShouldShowUnavailableSlotsNewFlow()
	{
		try
		{
			//GIVEN I'm on Order record
			OrdersSelector selectorInstance = new OrdersSelector();
			List<Order__c> obtainedRecords = selectorInstance.selectAll();
			obtainedRecords[0].orderStatus__c = ORDERSTATUSNEW;
			Test.startTest();
			//WHEN Order is submitted and there are no available slots
			String respBody = '{"errorCode":"JNJ007","errorMessage":"Slot is unavailable. Please select another Apheresis Pickup Date.","numberOfRecords":0,"cryoSiteId":"CRY1234"}';
			SlotBookingHttpCalloutMock mockCallout = new SlotBookingHttpCalloutMock(200, OK, respBody, new Map<String, String> {'CONTENTTYPE' => APPLICATIONJSON});
			Test.setMock(HttpCalloutMock.class, mockCallout);
			String slotBookingAndUpdateInfo = '{"apheresisSiteERPId":"CCMAPH505","aphPickUpDate":"2020-10-18","cryoType":"Central","projectedDeliveryDate":"2020-10-20","requestType":"Reschedule","sourceOfRequest":"CCM","therapyType":"Commercial"}';
			SlotAndOrderUpdateInfo inputRequest = (SlotAndOrderUpdateInfo) JSON.deserialize(slotBookingAndUpdateInfo, SlotAndOrderUpdateInfo.class);
			inputRequest.orderId = obtainedRecords[0].Id;
			OrderPlacementController.sendSlotBookingRequest(inputRequest);
			List<Order__c> updatedOrders = selectorInstance.selectAll();
			Test.stopTest();
			//THEN the order status should not be updated to Submitted
			system.assertNotEquals(ORDERSTATUSSUBMITTED, updatedOrders[0].SlotStatus__c);
		}
		catch (Exception e)
		{
			system.assertEquals(AuraHandledException.class.getName(), e.getTypeName());
		}
	}


	@IsTest static void itShouldGetOrderDetails()
	{
		List<Order__c> returnListOfOrders = new List<Order__c>();
		List<Id> listOfOrderIds = new List<Id>();
		//WHEN - The order Id has been passed to the server-side method named getOrderDetails() of the Orders class.
		Test.startTest();
		OrdersSelector selectorInstance = new OrdersSelector();
		List<Order__c> listOfOrders = selectorInstance.selectAll();

		for (Order__c order : listOfOrders)
		{
			listOfOrderIds.add(order.Id);
		}

		returnListOfOrders = OrderPlacementController.getOrderDetails(listOfOrderIds);
		Test.stopTest();
		//THEN - The order data has been returned for the order ids that were passed to the getOrderDetails() method of the Orders class.
		System.assertEquals(returnListOfOrders.size(), listOfOrders.size());

		try
		{
			returnListOfOrders = OrderPlacementController.getOrderDetails(null);
		}
		catch (Exception e)
		{
			System.assertEquals(e.getMessage(), e.getMessage());
		}
	}

}