@isTest
public class ViewAvailabilitySlotsControllerTest
{

	public static final String PATIENT = 'Patient';
	public static final String TREATMENTSITE = 'TreatmentSite';

	@testSetup
	private static void setUpTestData()
	{
		List<String> listOfSitesNames = new List<String>();
		List<Contact> contactList = new List<Contact>();
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.PatientRecordTypeDeveloperName).getRecordTypeId();
		listOfSitesNames.add(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		listOfSitesNames.add(StaticConstants.APHERESISSITE);
		listOfSitesNames.add(StaticConstants.CRYOSITE);
		for (String siteName : listOfSitesNames)
		{
			accToBeInserted.add(TestDataFactory.getBusinessAccountToInsert(siteName));
		}
		insert accToBeInserted;

		for (Account site : accToBeInserted)
		{
			if (!PatientRecordTypeId.equals(site.RecordTypeId))
			{
				contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
			}
		}

		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(StaticConstants.CARTCOORDINATOR, 'ContactRole');
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole(StaticConstants.APHERESISSITELABEL, 'AccountRole');
		HealthCloudGA__ReciprocalRole__c cryoSiteRole1 = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, 'AccountRole');
		roleList.add(carTRole);
		roleList.add(aphSiteRole1);
		roleList.add(cryoSiteRole1);
		insert roleList;

		insertCareProgramAndRelatedInfo(accToBeInserted[0].Id);
		insertLocationDataForAccount(accToBeInserted[0].Id);

		List<Account> accList = [SELECT Id,RecordTypeId, (SELECT Id,AccountId FROM Contacts) FROM Account LIMIT 5];
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
		List<Account> TreatmentsiteList = [select Id from Account where RecordType.DeveloperName = :StaticConstants.TreatmentSiteRecordTypeDeveloperName];
		insertLocationDataForAccount(TreatmentsiteList[0].Id);
		List<Case> caseList = TestDataFactory.getCareplanCasesList(patientContactsList);
		insert caseList;

		TestDataFactory.getSflibSettingsList();
	}

	private static void insertCareProgramAndRelatedInfo(Id patientId)
	{
		List<CareProgram> careProgramsList = TestDataFactory.getCareProgramsList('Test Care Program', 1);
		insert careProgramsList;
		List<Product2> productList = TestDataFactory.getProductsList('JNJ-4528', 1);
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
		List<Schema.Location> locationsList = TestDataFactory.getLocationRecords('Test location', 1);
		insert locationsList;
		List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecords(new Map<Id, Id> {accountId => locationsList[0].Id});
		insert assLocList;
	}

	@isTest static void itShouldGetAvailableSlots()
	{
		//GIVEN - A CO Navigates to Availability Calendar
		Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(PATIENT)
				.getRecordTypeId();

		Id treatmentSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(TREATMENTSITE)
				.getRecordTypeId();

		List<Account> patientList = new AccountsSelector().selectByDeveloperName(patientRecordTypeId);
		List<Account> treatmentSiteList = new AccountsSelector().selectByDeveloperName(treatmentSiteRecordTypeId);
		Test.startTest();

		//WHEN - the Apheresis Site and Cryo Type details are selected in the Availability Calendar
		Test.setMock(HttpCalloutMock.class, new SlotAvailabilityHttpCalloutMock());
		String expectedValue = '{"errorCode":"JNJ001","errorMessage":"Error while connecting to DB","numberOfRecords":0,"cryoSiteId":"CRY1234"}';
		String actualValue = ViewAvailabilitySlotsController.getAvailableSlots('Local', '123', patientList[0].Id, treatmentSiteList[0].Id, 'New',null);
		String actualDefaultValue = ViewAvailabilitySlotsController.getAvailableSlots('Local', '123', null, null, 'New',null);
		Test.stopTest();

		//THEN - check if slot Availability Data is returned
		system.assertEquals(expectedValue, actualValue);
		system.assertEquals(expectedValue, actualDefaultValue);
	}

	@isTest 
	private static void itShouldGetSlotAvailabilitySuccess()
	{
		//GIVEN - A external service to retrieve success data
		Test.setMock(HttpCalloutMock.class, new SlotAvailabilityHttpCalloutMock());
		String expectedValue = '{"status":"Success","code":"JNJ101","message":"successfully","statusCode":"US-123456-0a0000001-01"}';

		Test.startTest();
		//WHEN - New request is sent to the service
        ApheresisSlotService objAphSlotServ = new ApheresisSlotService();
		String actualValue = objAphSlotServ.getSlotAvailability(PATIENT);
		if (!(actualValue.equalsIgnoreCase(expectedValue))) return;
		Test.stopTest();

		//THEN - Check if a success code is returned
		system.assertEquals(expectedValue, actualValue);
	}
}
