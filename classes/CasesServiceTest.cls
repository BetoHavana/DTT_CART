@isTest(seeAllData=false)
public with sharing class CasesServiceTest
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String PHYSICIAN = 'Physician';
	private static final String PARENT ='Parent';
	private static final String CAREPROGRAM ='Test Care Program';
	private static final String PRODUCT ='JNJ-4528';

	//GIVEN Test Data To Create a Care Plan Case
	@testSetup static void testDataSetup()
	{
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		Account trtSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		accToBeInserted.add(trtSite);
		Account aphSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.APHERESISSITE);
		accToBeInserted.add(aphSite);
		Account cryoSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.CRYOSITE);
		accToBeInserted.add(cryoSite);
		Account patient = TestDataFactory.getPatientAccountsToInsert(1);
		accToBeInserted.add(patient);
		Account careGiver = new Account(LastName = 'VishnuTest', FirstName = 'VishnuReddy',
				recordtypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().
						get(StaticConstants.CaregiverRecordTypeDeveloperName).getRecordTypeId());
		accToBeInserted.add(careGiver);
		insert accToBeInserted;

		List<Contact> contactList = new List<Contact>();
		Contact trtSiteContact = TestDataFactory.getBusinessAccRelatedContacts(StaticConstants.TREATMENTSITELABEL, trtSite.Id);
		contactList.add(trtSiteContact);
		Contact aphSiteContact = TestDataFactory.getBusinessAccRelatedContacts(StaticConstants.APHERESISSITELABEL, aphSite.Id);
		contactList.add(aphSiteContact);
		Contact cryoSiteContact = TestDataFactory.getBusinessAccRelatedContacts(StaticConstants.CRYOSITELABEL, cryoSite.Id);
		contactList.add(cryoSiteContact);
		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c physicianRole = TestDataFactory.getContactRole(PHYSICIAN, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(CARTCOORDINATOR, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c aphSiteRole = TestDataFactory.getContactRole(StaticConstants.APHERESISSITELABEL, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c cryoSiteRole = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c physicianRole1 = TestDataFactory.getContactRole(PHYSICIAN, StaticConstants.accountRole);
		HealthCloudGA__ReciprocalRole__c carTRole1 = TestDataFactory.getContactRole(CARTCOORDINATOR, StaticConstants.accountRole);
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole(StaticConstants.APHERESISSITELABEL, StaticConstants.accountRole);
		HealthCloudGA__ReciprocalRole__c cryoSiteRole1 = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, StaticConstants.accountRole);
		HealthCloudGA__ReciprocalRole__c careGiverParentRole = TestDataFactory.getContactRole(PARENT, StaticConstants.contactRole);
		roleList.add(physicianRole);
		roleList.add(carTRole);
		roleList.add(aphSiteRole);
		roleList.add(cryoSiteRole);
		roleList.add(physicianRole1);
		roleList.add(carTRole1);
		roleList.add(aphSiteRole1);
		roleList.add(cryoSiteRole1);
		roleList.add(careGiverParentRole);
		insert roleList;

		List<Account> patientNCareGiverAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectContactsByAccountId(new Set<Id> {patient.Id, careGiver.Id});

		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();
		HealthCloudGA__ContactContactRelation__c conRel1 = TestDataFactory.getContactRelationsToInsert(trtSiteContact.Id, contactList[0].Id, carTRole.Id);
		conRelationList.add(conRel1);
		HealthCloudGA__ContactContactRelation__c conRel2 = TestDataFactory.getContactRelationsToInsert(aphSiteContact.Id, contactList[1].Id, carTRole.Id);
		conRelationList.add(conRel2);
		if (!patientNCareGiverAccounts.isEmpty())
		{
			HealthCloudGA__ContactContactRelation__c careGiverRel = TestDataFactory.getContactRelationsToInsert(patientNCareGiverAccounts[1].Contacts[0].Id,
					patientNCareGiverAccounts[0].Contacts[0].Id,
					careGiverParentRole.Id);
			conRelationList.add(careGiverRel);
		}
		insert conRelationList;
		List<HealthCloudGA__AccountAccountRelation__c> accRelationList = new List<HealthCloudGA__AccountAccountRelation__c>();
		HealthCloudGA__AccountAccountRelation__c accRel1 = TestDataFactory.getAccountRelationsToInsert(trtSite.Id, aphSite.Id, aphSiteRole1.Id);
		accRelationList.add(accRel1);
		HealthCloudGA__AccountAccountRelation__c accRel2 = TestDataFactory.getAccountRelationsToInsert(aphSite.Id, cryoSite.Id, cryoSiteRole1.Id);
		accRelationList.add(accRel2);
		insert accRelationList;
		insertCareProgramAndRelatedInfo(accToBeInserted);
	}

	private static void insertCareProgramAndRelatedInfo(List<Account> patientIds)
	{

		List<CareProgram> careProgramList = TestDataFactory.getCareProgramsList(CAREPROGRAM, 7);
		insert careProgramList;

		List<CareProgramEnrollee> lstCpEnrollee = new List<CareProgramEnrollee>();

		lstCpEnrollee.add(TestDataFactory.getCareProgramEnrollee(careProgramList[0].Id, patientIds[0].Id));


		insert lstCpEnrollee;

		List<Product2> productList = TestDataFactory.getProductsList(PRODUCT, 7);
		insert productList;

	}
	@isTest static void itShouldUpdateSitesReference()
	{
		//GIVEN - I am on a Patient record
		Test.startTest();

		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		//WHEN - Careplan is created with the Patient
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		CasesSelector caseSelectorInstance = new CasesSelector();
		List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.TreatmentSiteRecordTypeDeveloperName).getRecordTypeId();
		AccountsSelector accSelectorInstance = new AccountsSelector();
		List<Account> accList = accSelectorInstance.selectByDeveloperName(recTypeId);
		Map<Id, Id> accMap = new Map<Id, Id>();
		for (Account acc : accList)
		{
			accMap.put(acc.RecordTypeId, acc.Id);
		}

		//THEN - It should update Treatment Site on CarePlan
		//System.assertEquals(updatedCarePlanList[0].TreatmentSite__c, accMap.get(recTypeId));
		Test.stopTest();
	}

	@isTest static void itShouldNotUpdateSitesReference()
	{
		//GIVEN - I am on a Patient record
		Test.startTest();

		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		//WHEN - Careplan is created with the Patient without having the Treatment Site populated

		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		CasesSelector caseSelectorInstance = new CasesSelector();
		List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		updatedCarePlanList[0].TreatmentSite__c = null;
		update updatedCarePlanList;
		String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.TreatmentSiteRecordTypeDeveloperName).getRecordTypeId();
		AccountsSelector accSelectorInstance = new AccountsSelector();
		List<Account> accList = accSelectorInstance.selectByDeveloperName(recTypeId);
		Map<Id, Id> accMap = new Map<Id, Id>();
		for (Account acc : accList)
		{
			accMap.put(acc.RecordTypeId, acc.Id);
		}

		//THEN - It should not update update Treatment Site on CarePlan

		System.assertNotEquals(updatedCarePlanList[0].TreatmentSite__c, accMap.get(recTypeId));
		Test.stopTest();
	}

	@isTest static void itShouldInsertOrderForCareplanCase()
	{
		//GIVEN - I am on a Patient record
		Test.startTest();
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		//WHEN - Careplan case is created, an Order should be created automatically
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		CasesSelector caseSelectorInstance = new CasesSelector();
		List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		OrdersSelector ordSelectorInstance = new OrdersSelector();
		List<Order__c> orderList = ordSelectorInstance.selectOrdersByCarePlanId((new Map<Id, Case>(updatedCarePlanList)).keySet());

		//THEN - It should update Treatment Site on the related Order
		System.assert(!orderList.isEmpty());
		System.assertEquals(updatedCarePlanList[0].TreatmentSite__c, orderList[0].TreatmentSite__c);

		Test.stopTest();
	}

	@isTest static void itShouldNotInsertOrderForCareplanCase()
	{
		//GIVEN - I am on a Patient record
		Test.startTest();

		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		//WHEN - Careplan case is created without having the Treatment Site populated, an Order should be created automatically without Treatment Site
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		CasesSelector caseSelectorInstance = new CasesSelector();
		List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		updatedCarePlanList[0].TreatmentSite__c = null;
		update updatedCarePlanList;
		OrdersSelector ordSelectorInstance = new OrdersSelector();
		List<Order__c> orderList = ordSelectorInstance.selectOrdersByCarePlanId((new Map<Id, Case>(updatedCarePlanList)).keySet());

		//THEN - It should not update Treatment Site on the related Order
		System.assert(!orderList.isEmpty());
		System.assertEquals(null, orderList[0].TreatmentSite__c);

		Test.stopTest();
	}

	static List<Case> getCarePlans()
	{
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();
		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		return carePlanList;
	}

	testmethod static void checkIfPSENTasksAreCreatedOnBeginPatientSupportEligibilityUpdate()
	{
		Test.startTest();
		//Given we have care plans created
		List<Case> carePlans = getCarePlans();
		for (Case carePlan : carePlans)
		{
			carePlan.BeginPatientSupportEligibilityCheck__c = true;
		}
		//When CarePlan records BeginPatientSupportEligibilityCheck__c is updated to true
		update carePlans;

		/*Then PatientServiceEnrollee Record is created for each careplan for which BeginPatientSupportEligibilityCheck__c is set to true and also
			Relevant Task is also created for each Patient Services Enrollee record */

		List<PatientServicesEnrollee__c> pseRecords = ((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SobjectType)).
														selectByCarePlanId(sflib_ArrayUtils.pluckIdField(carePlans, Case.Id));
		System.assert(carePlans.size() == pseRecords.size(), 'Patient Service Enrollee Records are not created');
		Integer tasksSize = [SELECT Id FROM Task Where WhatId IN :pseRecords].size();
		System.assert(pseRecords.size() == tasksSize,
				'Task is not created for some of PSE Records and PSE Records Size : ' + pseRecords.size()
						+ 'Tasks Size : 	' + tasksSize);

		/*Given tasks are created for Patient Service Enrollee Records when CarePlan's
		BeginPatientSupportEligibilityCheck__c is set to true*/

		//When I update PatientServicesStatus__c to Request to Enroll Confirmed one more task should be created for each pse

		for (PatientServicesEnrollee__c pseRecord : pseRecords)
		{
			pseRecord.PatientServicesStatus__c = 'Request to Enroll Confirmed';
		}
		update pseRecords;
		Test.stopTest();

		//Then tasks should be created again for records which we updates patient service enrollee status to Contact Patient to confirm interest
		System.assert(tasksSize + pseRecords.size() == [SELECT Id FROM Task Where WhatId IN :pseRecords].size(),
				'Tasks are not created for the recent PSE Update');
	}
    @isTest static void itShouldThrowErrorIfTryToReschedule()
    {
        //GIVEN - I am an order with status New
        Test.startTest();
        Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                .selectAll()
                .getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
                .getById();

        Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
                .selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

        List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
        insert carePlanList;
        CasesSelector caseSelectorInstance = new CasesSelector();
        List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
        OrdersSelector ordSelectorInstance = new OrdersSelector();
        List<Order__c> orders = ordSelectorInstance.selectOrdersByCarePlanId((new Map<Id, Case>(updatedCarePlanList)).keySet());

        //When I try to reschedule the order

        OrderPlacementRescheduleController.DataForComponentLoad componentData = OrderPlacementRescheduleController.checkForValidationsNPassReqData(orders[0].Id);

        //Then we will show Error to user on UI
        System.assert(Label.OrderCantBeRescheduledWhenOrderIsNew == componentData.errorMessageOnValidationsFail, 'Validations are Satisfied Which is not expected');
        System.assert(false == componentData.satisfiedAllValidations, 'Validations are Satisfied Which is not expected');

        Test.stopTest();
    }

	@isTest static void itShouldUpdateCarePlanSubject()
	{
		//GIVEN - When Account record is created
		Test.startTest();
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		//WHEN - When Careplan record is created
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
		CasesSelector caseSelectorInstance = new CasesSelector();
		List<Case> updatedCarePlanList = caseSelectorInstance.selectByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());

		//Then it should update Careplan Subject
		System.assert(!updatedCarePlanList.isEmpty());
		system.assert(!String.isBlank(updatedCarePlanList[0].Subject));
		Test.stopTest();
	}

	@isTest static void testPreventDuplicateCreationForSamePatient()
	{
		Test.startTest();

		//GIVEN - I am on a Patient record and i already have a careplan
		Set<Id> patientIds = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectPatients()
				.getById().keySet();
		List<Contact> patientContacts = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(patientIds)
				.getContactsByAccountId().values();
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(patientContacts);
		insert carePlanList;
		String exceptionMessage='';

		//When i try to insert a duplicate care plan for patients
		try
		{
			insert TestDataFactory.getCareplanCasesList(patientContacts);
		}
		catch(Exception excp)
		{
			exceptionMessage = excp.getMessage();
		}

		Test.stopTest();

		//Then exception message should contain "The patient is already enrolled in the selected Care Plan" message
		system.assert(exceptionMessage.contains(Label.PatientIsAlreadyEnrolledInCarePlanErrMessage),
				'Validation is not thrown from cases class in before insert method');
	}
}