@isTest(seeAllData=false)
public with sharing class AvailabilityCalendarControllerTest
{
	public static final String ACCOUNTROLE = 'AccountRole';
	public static final String APHERESISSITE = 'ApheresisSite';
	public static final String APHERESISSITELABEL = 'Apheresis Site';
	public static final String TREATMENTSITELABEL = 'Treatment Site';
	public static final String TREATMENTSITE = 'TreatmentSite';
	public static final string strSuccess = 'SUCCESS';

	@testSetup static void testDataSetup()
	{
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		Account trtSite = TestDataFactory.getBusinessAccountToInsert(TREATMENTSITE);
		accToBeInserted.add(trtSite);
		Account aphSite = TestDataFactory.getBusinessAccountToInsert(APHERESISSITE);
		accToBeInserted.add(aphSite);
		insert accToBeInserted;

		List<Contact> contactList = new List<Contact>();
		Contact trtSiteContact = TestDataFactory.getBusinessAccRelatedContacts(TREATMENTSITELABEL, trtSite.Id);
		contactList.add(trtSiteContact);
		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole(APHERESISSITELABEL, ACCOUNTROLE);
		roleList.add(aphSiteRole1);
		insert roleList;

		List<HealthCloudGA__AccountAccountRelation__c> accRelationList = new List<HealthCloudGA__AccountAccountRelation__c>();
		HealthCloudGA__AccountAccountRelation__c accRel1 = TestDataFactory.getAccountRelationsToInsert(trtSite.Id, aphSite.Id, aphSiteRole1.Id);
		accRelationList.add(accRel1);
		insert accRelationList;

	}

	@isTest static void itShouldFetchApheresisSites()
	{
		//GIVEN - Apheresis and Treatment Sites are pre-configured in the system
		Test.startTest();
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {TREATMENTSITE}))
				.getById();

		//WHEN - A CO navigates to Availability Calendar screen for a treatment Site
		List<HealthCloudGA__AccountAccountRelation__c> accountAccountRelations = AvailabilityCalendarController.fetchApheresisSites(treatmentSiteAccountsByIds.values()[0].Id);

		//THEN - The CO should be shown List of Apheresis Sites of the corresponding treatment Site
		System.assertEquals(accountAccountRelations.size(), 1, 'Success');
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetSlotSchedulingStepDetails()
	{
		String strAvailabilityJSON;
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled in the system
			strAvailabilityJSON = AvailabilityCalendarController.getSlotSchedulingStepDetails();
			//WHEN - A Community user wants to fetch Patient Slot Scheduling Details
			PatientEnrollmentStepsSelector selectorInstance = new PatientEnrollmentStepsSelector();
			List<PatientEnrollmentSteps__mdt> obtainedRecords = selectorInstance.selectSlotSchedulingSteps();
			String strExpectedJSON = JSON.serialize(obtainedRecords);
			//THEN - Slot Scheduling Details for the patient should be retrieved
			System.assertEquals(strExpectedJSON, strAvailabilityJSON, strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), 'Script-thrown exception', strSuccess);
		}
		Test.stopTest();
	}
}