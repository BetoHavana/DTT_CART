@IsTest(SeeAllData=false)
private class PatientsListViewControllerTest
{
    private static final String CASEMANAGER = 'CaseManager';
    public static final String INTERNALBASEUSER = 'Internal Base User';
	public static final String PATIENT = 'Patient';
    public static final String PATIENTMANAGEMENT = 'PatientManagement';
	static List<User> userList;
    
	static void init()
	{
		userList = TestDataFactory.getUsersToInsert(INTERNALBASEUSER, 10);
		insert userList;

		Set<String> permissionSets = new Set<String>();
		permissionSets.add(PATIENTMANAGEMENT);
        permissionSets.add(CASEMANAGER);

		List<PermissionSetAssignment> permissionSetAssignments = TestDataFactory.assignPermissionSets(permissionSets, userList[0]);
		insert permissionSetAssignments;

	}

	@TestSetup
	static void testSetupMethod()
	{
		init();
		System.runAs(userList[0])
		{
			List<Account> accountsList = TestDataFactory.getPatientAccountsList();
			insert accountsList;

			List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, null);
			Integer i = 0;
			for (Notification__c notification : notificationList)
			{
				notification.RelatedRecordId__c = accountsList[i].id;
				i++;
			}
			notificationList[i-1].RelatedRecordId__c = accountsList[0].id;
			insert notificationList;
		}
	}

	static testMethod void itShouldGetAllAccounts()
	{
		//GIVEN - The patients are enrolled in the system
		Test.startTest();
		//WHEN - Community user lands on the TCP landing page
		String strPatientDetails = PatientsListViewController.fetchPatientDetails();
		Test.stopTest();
		List<PatientsWrapper> lstPatients = (List<PatientsWrapper>) JSON.deserialize(strPatientDetails, List<PatientsWrapper>.Class);
		//THEN - Community user should be able to see the enrolled patients
		System.assertEquals(7, lstPatients.size());
	}

	static testMethod void itShouldGetPatientTreatmentMilestone()
	{
		//GIVEN - The patients are enrolled in the system
		Test.startTest();
		//WHEN - Community user lands on the TCP landing page
		Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT}))
				.getById();
		for (Account objAccount : patientByIds.values())
		{
			objAccount.Status__c = 'Verified';
		}
		update patientByIds.values();

		Map<Id, Contact> contactsByAccountIds =
				((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
						.selectByAccountId(new Set<Id> {patientByIds.values()[0].Id}).getContactsByAccountId();

		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		carePlanList[0].Status = 'Manufacturing';
		insert carePlanList;

		List<Order__c> ordersList = ((OrdersSelector) Application.Selector
				.newInstance(Order__c.SObjectType))
				.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});
		ordersList[0].OrderStatus__c = 'Drug Product Delivery Date Scheduled';
		update ordersList;

		String strPatientDetails = PatientsListViewController.fetchPatientDetails();
		Test.stopTest();
		List<PatientsWrapper> lstPatients = (List<PatientsWrapper>) JSON.deserialize(strPatientDetails, List<PatientsWrapper>.Class);
		//THEN - Community user should be able to see the enrolled patients
		System.assertEquals(7, lstPatients.size(), 'Success');
	}

	static testMethod void itShouldFetchPatientDetailsForSiteCalendar()
	{
		//GIVEN - The patients are enrolled in the system
		Test.startTest();
		//WHEN - Community user lands on the TCP landing page
		Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT}))
				.getById();
		Map<Id, Contact> contactsByAccountIds =
				((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
						.selectByAccountId(new Set<Id>{patientByIds.values()[0].Id}).getContactsByAccountId();
		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		carePlanList[0].Status = 'Apheresis Pickup Date Scheduled';
		insert carePlanList;
		List<Order__c> orders = TestDataFactory.getOrders(new List<Id>{carePlanList[0].Id},patientByIds.values()[0].Id);
		orders[0].ApheresisPickUpDate__c = Date.Today().addDays(5);
		insert orders;
		String strPatientDetails = PatientsListViewController.fetchPatientDetailsForSiteCalendar(null);
		Test.stopTest();
		List<PatientsWrapper> lstPatients = (List<PatientsWrapper>) JSON.deserialize(strPatientDetails, List<PatientsWrapper>.Class);
		//THEN - Community user should be able to see the enrolled patients
		System.assertEquals(1, lstPatients.size(), 'Success');
	}
}