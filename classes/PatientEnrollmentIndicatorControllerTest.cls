@IsTest
public class PatientEnrollmentIndicatorControllerTest
{
	public static final String CarePlanRecordTypeDeveloperName = 'CarePlan';
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final string strPhysician = 'physician';
	public static final string strSuccess = 'SUCCESS';
	public static final string strWilliam = 'William';
	public static final String TREATMENTSITERECORDTYPEDEVELOPERNAME = 'TreatmentSite';

	static List<User> userList;
	static List<User> ExternalUserList;

	@testSetup
	static void setup()
	{
		init();
		System.runAs(userList[0])
		{
			List<CareProgram> careProgramList = TestDataFactory.getCareProgramsList('Test Care Program', 10);
			insert careProgramList;

			List<Product2> productList = TestDataFactory.getProductsList('JNJ-4528', 1);
			insert productList;
			List<CareProgramProduct> cppList = TestDataFactory.getCareProgramProductRecords(new Map<Id, Id> {careProgramList[0].Id => productList[0].Id});
			insert cppList;

			CarePlanTemplateSetup();


			List<Account> treatmentSiteAccountsList = TestDataFactory.getBusinessAccountsList(TREATMENTSITERECORDTYPEDEVELOPERNAME, 5);
			insert treatmentSiteAccountsList;

			List<Contact> contacts = new List<Contact>();
			Contact objContact1 = TestDataFactory.getBusinessAccRelatedContacts('test1', treatmentSiteAccountsList[0].Id);
			objContact1.SitePersona__c = CARTCOORDINATOR;
			Contact objContact2 = TestDataFactory.getBusinessAccRelatedContacts('test2', treatmentSiteAccountsList[1].Id);
			objContact2.SitePersona__c = CARTCOORDINATOR;
			Contact objContact3 = TestDataFactory.getBusinessAccRelatedContacts('test3', treatmentSiteAccountsList[2].Id);
			objContact3.SitePersona__c = CARTCOORDINATOR;
			Contact objContact4 = TestDataFactory.getBusinessAccRelatedContacts('test4', treatmentSiteAccountsList[3].Id);
			objContact4.SitePersona__c = CARTCOORDINATOR;
			Contact objContact5 = TestDataFactory.getBusinessAccRelatedContacts('test5', treatmentSiteAccountsList[4].Id);
			objContact5.SitePersona__c = CARTCOORDINATOR;
			contacts.add(objContact1);
			contacts.add(objContact2);
			contacts.add(objContact3);
			contacts.add(objContact4);
			contacts.add(objContact5);
			insert contacts;
		}

	}

	@IsTest
	public static void itShouldGetPatientEnrollmentStepDetails()
	{
		String strPatientEnrollmentJSON;
		Test.startTest();
		//GIVEN - Patient Enrollment Steps are pre-configured in the system
		strPatientEnrollmentJSON = PatientEnrollmentIndicatorController.getStepDetails();
		Test.stopTest();
		//WHEN - A Community user wants to enroll a Patient
		PatientEnrollmentStepsSelector selectorInstance = new PatientEnrollmentStepsSelector();
		List<PatientEnrollmentSteps__mdt> obtainedRecords = selectorInstance.selectPatients();
		String strExpectedJSON = JSON.serialize(obtainedRecords);
		//THEN - The community user should be able to see the pre-configured steps
		System.assertEquals(strExpectedJSON, strPatientEnrollmentJSON, strSuccess);
	}

	@IsTest
	public static void itShouldGetRelationshipToPatientValues()
	{
		String strRolesJSON;
		Test.startTest();
		//GIVEN - Caregiver-Patient roles are pre-configured in the system
		strRolesJSON = PatientEnrollmentIndicatorController.getRelationshipToPatientValues();
		Test.stopTest();
		//WHEN - A community user wants to associate caregiver with a Patient during enrollment
		ReciprocalRoleSelector selectorInstance = new ReciprocalRoleSelector();
		List<HealthCloudGA__ReciprocalRole__c> obtainedRecords = selectorInstance.selectAll();
		String strExpectedJSON = JSON.serialize(obtainedRecords);
		//THEN - The roles should be available for selection for the community user
		System.assertEquals(strExpectedJSON, strRolesJSON, strSuccess);
	}

	@IsTest
	public static void itShouldFetchPhysicianCoordinatorByAccId()
	{
		Test.startTest();
		//GIVEN - Site Personnels of varied personas exist for a Treatment Site in the system
		List<Contact> contacts = new List<Contact>();
		Account objAccount = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		insert objAccount;
		Contact objContact1 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact1.SitePersona__c = 'CAR-T Coordinator';
		Contact objContact2 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact2.SitePersona__c = strPhysician;
		Contact objContact3 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact3.SitePersona__c = strPhysician;
		Contact objContact4 = TestDataFactory.getBusinessAccRelatedContacts('Sony', objAccount.Id);
		objContact4.SitePersona__c = strPhysician;
		Contact objContact5 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact5.SitePersona__c = 'Pharmacist';
		contacts.add(objContact1);
		contacts.add(objContact2);
		contacts.add(objContact3);
		contacts.add(objContact4);
		contacts.add(objContact5);
		insert contacts;
		//WHEN - A Community user searches for a Physician during Patient Enrollment
		List<LookupSearchResult> lstSearchResults = PatientEnrollmentIndicatorController.fetchPhysicianCoordinator(objAccount.Id);
		//THEN - Retrieve results based on the search parameters
		System.assertEquals(4, lstSearchResults.size(), strSuccess);
		Test.stopTest();
	}

	@IsTest
	public static void itShouldCreateEnrollment()
	{
		Test.startTest();
		//GIVEN - Person Accounts are set up in the system
		String strPatientJSON = '{"First Name":"patient","MI":"m","Last Name":"test","Salutation":"Mr.","Medical Record Number (MRN)":"232111","Date of Birth":"2020-07-01","Gender":"Male","Phone Number":"2123223322","Email Address":"testpatient@test.com","Address Type":"pickup","Address Line 1":"al1","Address Line 2":"al2","City":"washington","State":"AL","Zip Code":"22222","Country":"US"}';
		String strPhysicianJSON = '{}';
		String strPatientServiceProgramJSON = '';
		//WHEN - A Community user enrolls a Patient and associates a CareGiver in TCP
		PatientEnrollmentIndicatorController.createEnrollment(strPatientJSON, strPhysicianJSON, strPatientServiceProgramJSON);
		//THEN - Person Accounts for Patient and CareGiver are created in the system
		Map<Id, Account> mapAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectPatients().getById();
		System.assertEquals(1, mapAccounts.values().size(), strSuccess);
		//WHEN - Duplicate Caregiver Records are passed to Controller Method
		try
		{
			PatientEnrollmentIndicatorController.createEnrollment(strPatientJSON,  strPhysicianJSON, strPatientServiceProgramJSON);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), 'Script-thrown exception', strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldFetchDuplicatePatients()
	{
		Test.startTest();
		//GIVEN - Patients are already enrolled in the system
		List<Account> accountsList = TestDataFactory.getPatientAccountsList();
		insert accountsList;
		//WHEN - A community user is tryng to enroll a patient with exact same Name fields as existing Patient
		String strPatientJSON = '{"First Name":"Test","MI":"","Last Name":"Patient1","Salutation":"Mr.","Medical Record Number (MRN)":"232111","Date of Birth":"1995-14-05","Gender":"Male","Phone Number":"2123223322","Email Address":"testpatient@test.com","Address Type":"pickup","Address Line 1":"al1","Address Line 2":"al2","City":"washington","State":"AL","Zip Code":"22222","Country":"US"}';
		List<Account> duplicateAccountsList = PatientEnrollmentIndicatorController.fetchDuplicatePatients(strPatientJSON);
		//THEN - The matching patient is shown to the community user to prevent duplicates
		System.assertEquals(1, duplicateAccountsList.size(), 'SUCCESS');
		Test.stopTest();
	}

	@IsTest
	public static void itShouldCreateCarePlan()
	{
		Test.startTest();
		ExternalUserList = new List<User>();
		//GIVEN - Treatment Site(s) public group(s) are created in the System and appropriate Site Personnel are set up for Treatment Site(s)
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		// WHEN - Community access for the Site Personnel is enabled
		List<User> users = TestDataFactory.getUsersToInsert('External Base User', 4);
		for (Integer i = 0; i < 5; i++)
		{
			User objUser = users[i];
			objUser.ContactId = contactsByAccountIds.values()[i].Id;
			ExternalUserList.add(objUser);
		}
		insert ExternalUserList;

		Set<String> permissionSets = new Set<String>();
		permissionSets.add('PatientManagementExternal');

		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
		for (Integer i = 0; i < 5; i++)
		{
			permissionSetAssignments.addAll(TestDataFactory.assignPermissionSets(permissionSets, ExternalUserList[i]));
		}
		insert permissionSetAssignments;

		System.runAs(ExternalUserList[0])
		{
			List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
			HealthCloudGA__ReciprocalRole__c carTRole =
					TestDataFactory.getContactRole(CARTCOORDINATOR, 'ContactRole');
			HealthCloudGA__ReciprocalRole__c physicianRole =
					TestDataFactory.getContactRole(strPhysician, 'ContactRole');
			physicianRole.HealthCloudGA__InverseRole__c = 'Patient';
			carTRole.HealthCloudGA__InverseRole__c = 'Patient';
			roleList.add(physicianRole);
			roleList.add(carTRole);
			insert roleList;

			//GIVEN - Person Accounts are set up in the system
			String strPatientJSON = '{"First Name":"CaseTest","MI":"m","Last Name":"test","Salutation":"Mr.","Medical Record Number (MRN)":"232111","Date of Birth":"2020-07-01","Gender":"Male","Phone Number":"2123223322","Email Address":"testpatient@test.com","Address Type":"pickup","Address Line 1":"al1","Address Line 2":"al2","City":"washington","State":"AL","Zip Code":"22222","Country":"US"}';
			String strCaregiverJSON = '{"First Name":"caseTestCare","MI":"b","Last Name":"test","Salutation":"Mrs.","Phone Number":"8888888888","Email Address":"caretest@test.com","Address Type":"pickup","Address Line 1":"careal1","Address Line 2":"careal2","City":"carecitywashing","State":"CO","Zip Code":"44444","Country":"US","Relationship to Patient":""}';
			String strPhysicianJSON = '{}';
			String strPatientServiceProgramJSON = '';
			//WHEN - A Community user enrolls a Patient and associates a CareGiver in TCP
			PatientEnrollmentIndicatorController.createEnrollment(strPatientJSON, strPhysicianJSON, strPatientServiceProgramJSON);
		}
		//THEN - Person Accounts for Patient and CareGiver along with careplan are created in the system
		Map<Id, Account> mapAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectPatients().getById();
		Map<Id, Case> casesByAccountIds = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId(mapAccounts.keySet()).getCasesByAccountId();
		System.assertEquals(1, casesByAccountIds.values().size(), strSuccess);
		Cases carePlan = new Cases(casesByAccountIds.values()).selectCasesByRecordTypeDeveloperName(new Set<String> {CarePlanRecordTypeDeveloperName});
		System.assertEquals(1, carePlan.getRecords().size(), strSuccess);
		Test.stopTest();

	}

	public static void CarePlanTemplateSetup()
	{
		List<HealthCloudGA__CarePlanTemplate__c> carePlanTemplateList = TestDataFactory.getCarePlanTemplateList('Test Care Plan', 10);
		insert carePlanTemplateList;

		List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoals = TestDataFactory.getCarePlanTemplateGoalList('Template Goal', 5, carePlanTemplateList[0].Id);
		insert carePlanTemplateGoals;

		List<HealthCloudGA__CarePlanTemplateTask__c> carePlanTemplateTasks = TestDataFactory.getCarePlanTemplateTaskList('Template Task', 5, carePlanTemplateGoals[0]);
		insert carePlanTemplateTasks;

	}

	static void init()
	{
		List<UserRole> lstRole = ((UserRolesSelector) Application.Selector.newInstance(UserRole.SObjectType)).selectByName(new Set<String> {'Internal Site Administrator'});
		userList = TestDataFactory.getUsersToInsert('Internal Base User', 9);
		for (User objUser : userList)
		{
			objUser.UserRoleId = lstRole[0].Id;
		}
		insert userList;

		Set<String> permissionSets = new Set<String>();
		permissionSets.add('PatientManagement');
		permissionSets.add('SiteManagement');
		permissionSets.add('UserManagementPermissionSet');
		permissionSets.add('CareProgramManagement');

		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
		for (Integer i = 0; i < 10; i++)
		{
			permissionSetAssignments.addAll(TestDataFactory.assignPermissionSets(permissionSets, userList[i]));
		}
		insert permissionSetAssignments;

	}

	@IsTest
	public static void itShouldcreateContactContactRelationForPhysician()
	{
		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c carTRole =
				TestDataFactory.getContactRole(CARTCOORDINATOR, 'ContactRole');
		HealthCloudGA__ReciprocalRole__c physicianRole =
				TestDataFactory.getContactRole(strPhysician, 'ContactRole');
		physicianRole.HealthCloudGA__InverseRole__c = 'Patient';
		carTRole.HealthCloudGA__InverseRole__c = 'Patient';
		roleList.add(physicianRole);
		roleList.add(carTRole);
		insert roleList;

		List<Contact> contacts = new List<Contact>();
		Account objAccount = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		insert objAccount;
		Contact objContact1 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact1.SitePersona__c = 'CAR-T Coordinator';
		Contact objContact2 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact2.SitePersona__c = strPhysician;
		Contact objContact3 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact3.SitePersona__c = strPhysician;
		Contact objContact4 = TestDataFactory.getBusinessAccRelatedContacts('Sony', objAccount.Id);
		objContact4.SitePersona__c = strPhysician;
		Contact objContact5 = TestDataFactory.getBusinessAccRelatedContacts(strWilliam, objAccount.Id);
		objContact5.SitePersona__c = 'Pharmacist';
		contacts.add(objContact1);
		contacts.add(objContact2);
		contacts.add(objContact3);
		contacts.add(objContact4);
		contacts.add(objContact5);
		insert contacts;

		Test.startTest();
		//GIVEN - Person Accounts are set up in the system
		String strPatientJSON = '{"First Name":"patient","MI":"m","Last Name":"test","Salutation":"Mr.","Medical Record Number (MRN)":"232111","Date of Birth":"2020-07-01","Gender":"Male","Phone Number":"2123223322","Email Address":"testpatient@test.com","Address Type":"pickup","Address Line 1":"al1","Address Line 2":"al2","City":"washington","State":"AL","Zip Code":"22222","Country":"US"}';
		String strPhysicianJSON = '[{"place_id":"' + objContact4.Id + '"}]';
		String strPatientServiceProgramJSON = '';
		//WHEN - A Community user enrolls a Patient and associates a CareGiver in TCP
		PatientEnrollmentIndicatorController.createEnrollment(strPatientJSON, strPhysicianJSON, strPatientServiceProgramJSON);
		//THEN - Person Accounts for Patient and CareGiver are created in the system
		Map<Id, Account> mapAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectPatients().getById();
		System.assertEquals(1, mapAccounts.values().size(), strSuccess);
		Test.stopTest();
	}

}
