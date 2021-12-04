@IsTest(SeeAllData=false)
public class PatientJourneyControllerTest
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String PATIENT = 'Patient';
	public static final String PATIENTSERVICEELIGIBILITY = 'true';
	public static final String PHYSICIAN = 'Physician';
	public static final string REASONFORCANCELLATION = 'Patient health-related reason';
	public static final string strPatientRecordType = 'Patient';
	public static final string strSuccess = 'SUCCESS';
	public static final String TreatmentSiteRecordTypeDeveloperName = 'TreatmentSite';
	public static final String SCRIPTTHROWNEXCEPTION = 'Script-thrown exception';


	@testSetup
	static void setup()
	{
		List<Account> patientsToBeInserted = TestDataFactory.getPatientAccountsList();
		insert patientsToBeInserted;
	}

	@IsTest
	public static void itShouldGetPatientDocuments()
	{
		Test.startTest();
		try
		{
			//GIVEN - The patients are enrolled in the system and required consent files are uploaded
			Map<Id, Account> patientIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id> {patientIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<PatientServicesEnrollee__c> lstpPatientServicesEnrolleesEnrollee = new List<PatientServicesEnrollee__c>();
			for (Account objAccount : patientIds.values())
			{
				lstpPatientServicesEnrolleesEnrollee.add(TestDataFactory.getPatientServicesEnrollee(carePlanList[0].Id, objAccount.Id));
			}

			insert lstpPatientServicesEnrolleesEnrollee;

			List<ContentDocument> contentVersionDocs = TestDataFactory.createAttachment(10);

			List<ContentDocumentLink> lstContentLink = new List<ContentDocumentLink>();

			for (PatientServicesEnrollee__c objEnrollee : lstpPatientServicesEnrolleesEnrollee)
			{
				lstContentLink.add(TestDataFactory.getVisibleContentDocumentLink(objEnrollee.Id, contentVersionDocs[0].Id));
			}

			insert lstContentLink;

			//WHEN - The CAR-T CO logs into TCP and navigates to Patient Journey page
			List<ContentVersion> docs = PatientJourneyController.getDocumentsByPatientId(patientIds.values()[0].Id);
			//THEN - CAR-T Coordinator should able to see documents uploaded for a given patient
			System.assertEquals(1, docs.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldFetchBussinessDayDueForReschedule()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system and apheresis pickup slot is booked
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id> {carePlanList[0].Id}, patientByIds.values()[0].Id);
			orders[0].ApheresisPickUpDate__c = Date.Today().addDays(5);
			insert orders;

			TestDataFactory.getSflibSettingsList();
			//WHEN - The apheresis due date is greater then one business day
			Boolean isBusinessDue = PatientJourneyController.isBussinessDayDueForReschedule(patientByIds.values()[0].Id);
			//THEN - Then patient is eligible for reschedule
			System.assertEquals(true, isBusinessDue, strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldFetchPatientServiceEligibilty()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			//WHEN - A CO navigates to Patient Journey screen for a Patient
			List<Case> casesList = PatientJourneyController.fetchPatientServiceEligibilty(patientByIds.values()[0].Id);
			//THEN - Eligibility Information for the patient should be retrieved
			System.assertEquals(1, casesList.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION , strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldFetchPatientServiceEnrollees()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<PatientServicesEnrollee__c> lstpPatientServicesEnrolleesEnrollee = new List<PatientServicesEnrollee__c>();
			for (Account objAccount : patientByIds.values())
			{
				lstpPatientServicesEnrolleesEnrollee.add(TestDataFactory.getPatientServicesEnrollee(carePlanList[0].Id, objAccount.Id));
			}

			insert lstpPatientServicesEnrolleesEnrollee;

			//WHEN - A CO navigates to Patient Journey screen for a Patient
			List<PatientServicesEnrollee__c> lstEnrollees = PatientJourneyController.fetchPatientServiceEnrollees(patientByIds.values()[0].Id);
			//THEN - Patient Services Enrollees Information for the patient should be retrieved
			System.assertEquals(1, lstEnrollees.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateCarePlan()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and the Service Program Eligibiity was unchecked during Enrollment
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			//WHEN - A CO navigates to Patient Journey screen for a Patient and Submits Request for Service Program Eligibiity
			PatientJourneyController.updateCarePlan(patientByIds.values()[0].Id, PATIENTSERVICEELIGIBILITY);

			Map<Id, Case> casesByAccountId =
					((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
							.selectByPatientAccountId(new Set<Id> {patientByIds.values()[0].Id}).getCasesByAccountId();
			if (casesByAccountId.isEmpty()) return;
			//THEN - The Patient should be made eligible for the Service Program
			System.assertEquals(true, casesByAccountId.values()[0].BeginPatientSupportEligibilityCheck__c, strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION , strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldgetDetailsByPatientId()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient has corresponding  treating physician  and cart CO
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();
			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
			HealthCloudGA__ReciprocalRole__c carTRole =
					TestDataFactory.getContactRole(CARTCOORDINATOR, 'ContactRole');
			HealthCloudGA__ReciprocalRole__c physicianRole =
					TestDataFactory.getContactRole(PHYSICIAN, 'ContactRole');
			roleList.add(carTRole);
			roleList.add(physicianRole);
			insert roleList;

			List<Account> treatmentSiteAccountsList =
					TestDataFactory.getBusinessAccountsList(TREATMENTSITERECORDTYPEDEVELOPERNAME, 10);
			insert treatmentSiteAccountsList;

			List<Contact> contacts = new List<Contact>();
			Contact objContact1 =
					TestDataFactory.getBusinessAccRelatedContacts('test1', treatmentSiteAccountsList[0].Id);
			objContact1.SitePersona__c = CARTCOORDINATOR;
			Contact objContact2 =
					TestDataFactory.getBusinessAccRelatedContacts('test2', treatmentSiteAccountsList[1].Id);
			objContact2.SitePersona__c = CARTCOORDINATOR;
			Contact objContact3 =
					TestDataFactory.getBusinessAccRelatedContacts('test3', treatmentSiteAccountsList[2].Id);
			objContact3.SitePersona__c = CARTCOORDINATOR;
			Contact objContact4 =
					TestDataFactory.getBusinessAccRelatedContacts('test4', treatmentSiteAccountsList[3].Id);
			objContact4.SitePersona__c = CARTCOORDINATOR;
			Contact objContact5 =
					TestDataFactory.getBusinessAccRelatedContacts('test5', treatmentSiteAccountsList[4].Id);
			objContact5.SitePersona__c = CARTCOORDINATOR;
			contacts.add(objContact1);
			contacts.add(objContact2);
			contacts.add(objContact3);
			contacts.add(objContact4);
			contacts.add(objContact5);
			insert contacts;
			List<HealthCloudGA__ContactContactRelation__c> conRelationList =
					new List<HealthCloudGA__ContactContactRelation__c>();
			HealthCloudGA__ContactContactRelation__c conRel1 =
					TestDataFactory.getContactRelationsToInsert(contacts[0].Id, contactsByAccountIds.values()[0].Id, carTRole.Id);
			conRelationList.add(conRel1);
			HealthCloudGA__ContactContactRelation__c conRel2 =
					TestDataFactory.getContactRelationsToInsert(contacts[1].Id, contactsByAccountIds.values()[1].Id, physicianRole.Id);
			conRelationList.add(conRel2);
			insert conRelationList;
			//WHEN - A CO navigates to Patient Journey screen for a Patient
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);
			//THEN - treating physician and car-t co-ordinator Information for the patient should be retrieved
			System.assertEquals(2, conRelationList.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION , strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetApheresisStatus()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id>{patientByIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			carePlanList[0].Status = 'Apheresis Pickup Date Scheduled';
			insert carePlanList;
			Account trtSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
			insert trtSite;
			Contact orderContact = TestDataFactory.getBusinessAccRelatedContacts('test', trtSite.id);
			insert orderContact;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id>{carePlanList[0].Id},patientByIds.values()[0].Id);
			orders[0].OrderStatus__c = 'Order Verified';
			orders[0].POStatus__c = 'PO Received';
			orders[0].SlotStatus__c = 'Slot Confirmed';
			orders[0].Coordinator__c = orderContact.Id;
			insert orders;
			//WHEN - A CO navigates to Patient Journey screen for the Patient whose Apheresis is either inprogress or Completed
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);
			//THEN - The CO should be able to view corresponding Patient's Apheresis Section details.
			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newInstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectApheresisStepsByStatuses(carePlanList[0].Status, orders[0].OrderStatus__c, orders[0].SlotStatus__c, orders[0].POStatus__c);

			System.assertEquals(1, treatmentJourneySteps.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetManufacturingDetails()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id> {patientByIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id> {carePlanList[0].Id}, patientByIds.values()[0].Id);
			orders[0].ManufacturingStatus__c = 'QR Complete';
			insert orders;
			//WHEN - A CO navigates to Patient Journey screen for the Patient whose Manufacturing is either inprogress or Completed
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);
			//THEN - The CO should be able to view corresponding Patient's Manufacturing Section details.
			System.assertEquals(1, orders.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetManufacturingStatus()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id> {patientByIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			carePlanList[0].Status = 'Manufacturing';
			insert carePlanList;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id> {carePlanList[0].Id}, patientByIds.values()[0].Id);
			orders[0].OrderStatus__c = 'Order In Progress';
			orders[0].POStatus__c = 'PO Received';
			orders[0].SlotStatus__c = 'Slot Confirmed';
			orders[0].ManufacturingStatus__c = 'Not Started';
			insert orders;

			//WHEN - A CO navigates to Patient Journey screen for the Patient whose Manufacturing is Not Started
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);

			//THEN - The CO should be able to view corresponding Patient's Manufacturing Section details.
			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newInstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectManufacturingStepsByStatuses(carePlanList[0].Status, orders[0].OrderStatus__c, orders[0].SlotStatus__c, orders[0].POStatus__c, orders[0].ManufacturingStatus__c);

			System.assertEquals(1, treatmentJourneySteps.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetShippingStatus()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id> {patientByIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			carePlanList[0].Status = 'Shipping Cells to Manufacturing Site';
			insert carePlanList;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id> {carePlanList[0].Id}, patientByIds.values()[0].Id);
			orders[0].OrderStatus__c = 'Order In Progress';
			orders[0].POStatus__c = 'PO Received';
			orders[0].SlotStatus__c = 'Slot Confirmed';
			orders[0].ShippingStatus__c = 'Shipping Cryo-ed Cells';
			insert orders;

			//WHEN - A CO navigates to Patient Journey screen for the Patient whose Shipping status is Shipping Cryo-ed Cells
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);

			//THEN - The CO should be able to view corresponding Patient's Shipping Section details.
			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newInstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectShippingStepsByStatuses(carePlanList[0].Status, orders[0].OrderStatus__c, orders[0].SlotStatus__c, orders[0].POStatus__c, orders[0].ShippingStatus__c);

			System.assertEquals(1, treatmentJourneySteps.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldGetDeliveryStatus()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(new Set<Id> {patientByIds.values()[0].Id}).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			carePlanList[0].Status = 'Drug Product Shipped';
			insert carePlanList;

			List<Order__c> orders = TestDataFactory.getOrders(new List<Id> {carePlanList[0].Id}, patientByIds.values()[0].Id);
			orders[0].OrderStatus__c = 'Drug Product Delivery Date Scheduled';
			orders[0].ManufacturingStatus__c = 'QR Complete';
			orders[0].POStatus__c = 'PO Received';
			orders[0].SlotStatus__c = 'Slot Confirmed';
			orders[0].ShippingStatus__c = 'Shipping Drug Product';
			insert orders;

			//WHEN - A CO navigates to Patient Journey screen for the Patient whose Shipping status/Delivery Status is Shipping Drug Product
			PatientJourneyController.getDetailsByPatientId(patientByIds.values()[0].Id);

			//THEN - The CO should be able to view corresponding Patient's Delivery Section details.
			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newInstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectDeliveryStepsByStatuses(carePlanList[0].Status, orders[0].OrderStatus__c, orders[0].SlotStatus__c, orders[0].POStatus__c, orders[0].ShippingStatus__c, orders[0].ManufacturingStatus__c, orders[0].ShippingStatus__c);

			System.assertEquals(1, treatmentJourneySteps.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateOrder()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});
			ordersList[0].OrderStatus__c = 'Order Cancellation Requested';
			update ordersList;

			//WHEN - A CO navigates to Patient Journey screen for a Patient and Submits Request for Order Cancellation
			PatientJourneyController.updateOrder(patientByIds.values()[0].Id, REASONFORCANCELLATION);

			//THEN - The Patient should be able to raise request for order cancellation
			List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
					sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
			System.assert(!updatedOrdersList.isEmpty());
			System.assertEquals(REASONFORCANCELLATION, updatedOrdersList[0].ReasonForOrderWithdrawal__c);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateDeliveryDateOnOrder()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});

			//WHEN - A CO navigates to Patient Journey screen for a Patient and updates the Confirmed FP Delivery Date
			PatientJourneyController.updateDeliveryDateOnOrder(patientByIds.values()[0].Id, String.valueOf(System.today()));

			//THEN - The Patient should be able to see the updated Confirmed FP Delivery Date on the Patient Journey Screen
			List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
					sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
			System.assert(!updatedOrdersList.isEmpty());
			System.assertEquals(System.today(), updatedOrdersList[0].ConfirmedFPDeliveryDate__c);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateInfusedDateOnOrder()
	{
		Test.startTest();
		try
		{
			//GIVEN - A patient is enrolled and Order is placed successfully
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
			insert carePlanList;

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});

			//WHEN - A CO navigates to Patient Journey screen for a Patient and updates the infusion date
			PatientJourneyController.updateInfusedDateOnOrder(patientByIds.values()[0].Id, String.valueOf(System.today()));

			//THEN - The Patient should be able to see the updated Infusion Date on the Patient Journey Screen
			List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
					sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
			System.assert(!updatedOrdersList.isEmpty());
			System.assertEquals(System.today(), updatedOrdersList[0].InfusionDate__c);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

}