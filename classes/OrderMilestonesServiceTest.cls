@isTest
public class OrderMilestonesServiceTest
{

	public static final String APHDELIVERYAT3RDPARTYCRYOSTATUSDATE = 'Apheresis DroppedOff at CentralCryo';
	public static final String APHDELIVERYATMANUFACTURINGSITESTATUSDATE = 'Apheresis DroppedOff at Manufacturing';
	public static final String APHPICKUPFROM3RDPARTYCRYOSTATUSDATE = 'Apheresis PickedUp at CentralCryo';
	public static final String APHPICKUPFROMQTCSTATUSANDDATE = 'Apheresis PickedUp from QualifiedTreatmentCenter';
	public static final String CRYOEDCELLSDELIVERED = 'Cryo-ed Cells Delivered';
	public static final String DRUGPRODUCTDELIVERED = 'Drug Product Delivered';
	public static final String DRUGPRODUCTDROPOFFATINFUSIONSITESTATUSDATE = 'DrugProduct DroppedOff at InfusionSite';
	public static final String DRUGPRODUCTPICKUPATMANUFACTURINGSITESTATUSDATE = 'DrugProduct PickedUp from Manufacturing';
	public static final String FINALDPDATEUPDATED = 'Final DP Date updated';
	public static final String FRESHCELLSDELIVERED = 'Fresh Cells Delivered';
	private static final String INDUSTRIESBUSINESS = 'IndustriesBusiness';
	public static final String MANUFACTURINGCOMPLETE = 'Manufacturing Complete';
	public static final String MANUFACTURINGSTARTED = 'Manufacturing Started';
	public static final String MES = 'MES';
	public static final String MILESTONESOURCE = 'Atlas';
	public static final String MILESTONETYPEASMANUFACTURING = 'Manufacturing';
	public static final String QCQACOMPLETE = 'QC/QA Complete';
	public static final String QRCOMPLETE = 'QR Complete';
	public static final String SHIPMENT = 'COI-COC';
	public static final String SHIPPINGFRESHCELLS = 'Shipping Fresh Cells';
	public static final String SHIPPINGCELLSTOMANUFACTURINGSITE = 'Shipping Cells to Manufacturing Site';
	public static final String SHIPPINGCRYOEDCELLS = 'Shipping Cryo-ed Cells';
	public static final String SHIPPINGDRUGPRODUCT = 'Shipping Drug Product';
	public static final String SOURCEVINETI = 'Vineti';
	private static final String TESTLOCATION = 'Test Location';
	public static final String THIRDPARTY = '3rd party';
	public static final String VINETICOINUMBERUPDATED = 'OrderApproved';

	//GIVEN - Test Data for Updating an Order & its related records
	@TestSetup
	private static void setUpTestData()
	{
		List<String> listOfSitesNames = new List<String>();
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		listOfSitesNames.add(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		listOfSitesNames.add(StaticConstants.APHERESISSITE);
		listOfSitesNames.add(StaticConstants.CRYOSITE);

		for (String siteName : listOfSitesNames)
		{
			accToBeInserted.addAll(TestdataFactory.getBusinessAccountsList(siteName, 3));
		}
		insert accToBeInserted;

		List<Account> accountsToBeUpdated = new List<Account>();
		List<Contact> contactList = new List<Contact>();
		Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		Id trtSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(StaticConstants.TreatmentSiteRecordTypeDeveloperName)
				.getRecordTypeId();
		Id aphSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(StaticConstants.APHERESISSITE)
				.getRecordTypeId();
		Id cryoSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(StaticConstants.CRYOSITE)
				.getRecordTypeId();
		List<Id> treatmentSiteIds = new List<Id>();
		List<Id> apheresisSiteIds = new List<Id>();
		List<Id> cryoSiteIds = new List<Id>();
		for (Account site : accToBeInserted)
		{
			if (patientRecordTypeId.equals(site.RecordTypeId))
			{
				site.Status__c = StaticConstants.PatientStatusVerified;
				accountsToBeUpdated.add(site);
			}
			else
			{
				contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
				site.Type = StaticConstants.cryoSiteLocal;
				accountsToBeUpdated.add(site);
				if(trtSiteRecordTypeId.equals(site.RecordTypeId))
				{
					treatmentSiteIds.add(site.Id);
				}
				else if(aphSiteRecordTypeId.equals(site.RecordTypeId))
				{
					apheresisSiteIds.add(site.Id);
				}
				else
				{
					cryoSiteIds.add(site.Id);
				}
			}
		}
		update accountsToBeUpdated;
		insert contactList;
		List<Schema.Location> locationsList = TestDataFactory.getLocationRecords(TESTLOCATION, 3);
		insert locationsList;
		List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(cryoSiteIds,locationsList,3);
		insert assLocList;
		system.assertNotEquals(NULL,assLocList[0].Id);
		List<Contact> businessContactsList = ((ContactsSelector) Application.Selector
				.newInstance(Contact.SObjectType))
				.selectAllByRecTypeDeveloperName(new Set<String>{INDUSTRIESBUSINESS});
		system.assertNotEquals(NULL, businessContactsList[0].Id);

		List<HealthCloudGA__ReciprocalRole__c> reciprocalRolesList = new List<HealthCloudGA__ReciprocalRole__c>();

		HealthCloudGA__ReciprocalRole__c carTCoordinatorRole = TestDataFactory.getContactRole(StaticConstants.CARTCOORDINATOR, StaticConstants.contactRole);
		reciprocalRolesList.add(carTCoordinatorRole);
		HealthCloudGA__ReciprocalRole__c aphSiteRole = TestDataFactory.getContactRole(Label.RoleAphresisSite, StaticConstants.accountRole);
		reciprocalRolesList.add(aphSiteRole);
		HealthCloudGA__ReciprocalRole__c cryoSiteRole = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, StaticConstants.accountRole);
		reciprocalRolesList.add(cryoSiteRole);

		insert reciprocalRolesList;

		List<Account> accountsList = new AccountsSelector().selectAllContactsForAccount(patientRecordTypeId);
		List<Contact> conList = new List<Contact>();
		for (Account acc : accountsList)
		{
			conList.add(acc.Contacts);
		}
		List<Id> conIdList = new List<Id>();
		conIdList.addAll(sflib_ArrayUtils.pluckIdField(conList, Contact.Id));

		List<Id> contactIdList = new List<Id>();
		contactIdList.addAll(sflib_ArrayUtils.pluckIdField(businessContactsList, Contact.Id));

		List<HealthCloudGA__ContactContactRelation__c> associatedContactsList = new List<HealthCloudGA__ContactContactRelation__c>();
		associatedContactsList = TestDataFactory.getAssociatedContactRelationsToInsert(contactIdList,conIdList,carTCoordinatorRole.Name,StaticConstants.contactRole,2);
		insert associatedContactsList;

		List<HealthCloudGA__AccountAccountRelation__c> accRelationList = new List<HealthCloudGA__AccountAccountRelation__c>();
		accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(treatmentSiteIds,apheresisSiteIds,aphSiteRole.Id,2));
		accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(apheresisSiteIds,cryoSiteIds,cryoSiteRole.Id,2));

		insert accRelationList;
		system.assertNotEquals(NULL,accRelationList[0].Id);

		List<Case> caseList = TestDataFactory.getCareplanCasesList(conList);
		insert caseList;

		List<Id> carePlanIdList = new List<Id>();
		carePlanIdList.addAll(sflib_ArrayUtils.pluckIdField(caseList, Case.Id));

		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = TestDataFactory.getGoalsForCaseIds(carePlanIdList);
		insert listOfGoals;

		List<Task> taskList = TestDataFactory.getTasksForGoalIds(listOfGoals);
		insert taskList;

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectByDeveloperName(cryoSiteRecordTypeId);

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(caseList)).keySet());

		List<String> manufacturingMilestoneNameList = new List<String>();

		manufacturingMilestoneNameList.add(MANUFACTURINGCOMPLETE);
		manufacturingMilestoneNameList.add(MANUFACTURINGSTARTED);
		manufacturingMilestoneNameList.add(QCQACOMPLETE);
		manufacturingMilestoneNameList.add(QRCOMPLETE);

		Map<String, String> manufacturingMilestonesMap = new Map<String, String>();
		manufacturingMilestonesMap.put(MANUFACTURINGCOMPLETE, MES);
		manufacturingMilestonesMap.put(MANUFACTURINGSTARTED, MES);
		manufacturingMilestonesMap.put(QCQACOMPLETE, MILESTONESOURCE);
		manufacturingMilestonesMap.put(QRCOMPLETE, MILESTONESOURCE);

		List<String> shipmentMilestoneNameList = new List<String>();
		shipmentMilestoneNameList.add(APHPICKUPFROMQTCSTATUSANDDATE);
		shipmentMilestoneNameList.add(APHDELIVERYAT3RDPARTYCRYOSTATUSDATE);
		shipmentMilestoneNameList.add(APHPICKUPFROM3RDPARTYCRYOSTATUSDATE);
		shipmentMilestoneNameList.add(APHDELIVERYATMANUFACTURINGSITESTATUSDATE);
		shipmentMilestoneNameList.add(DRUGPRODUCTPICKUPATMANUFACTURINGSITESTATUSDATE);
		shipmentMilestoneNameList.add(DRUGPRODUCTDROPOFFATINFUSIONSITESTATUSDATE);
		shipmentMilestoneNameList.add(VINETICOINUMBERUPDATED);

		List<OrderMilestones__c> orderMileStonesList = new List<OrderMilestones__c>();

		orderMileStonesList.addAll(TestDataFactory.getOrderMilestonesForManufacturing(ordersList, manufacturingMilestoneNameList, new List<String> {MILESTONETYPEASMANUFACTURING}, manufacturingMilestonesMap, 3));
		orderMileStonesList.addAll(TestDataFactory.getOrderMilestones(ordersList, shipmentMilestoneNameList, new List<String> {SHIPMENT}, new List<String> {SOURCEVINETI}, 6));
		insert orderMileStonesList;

	}

	testmethod static void testOrderMilestoneCreationShouldTriggerCallout()
	{
		Test.startTest();
		//Given I am on order record
		List<Order__c> order = [SELECT id from Order__c LIMIT 1];
		Test.setMock(HttpCalloutMock.class, new ManufacturingMilestonesUpdateServiceMock(true));

		//When i create Order milestone Record of type Manufacturing
		insert new OrderMileStones__c(Order__c=order[0].Id , MilestoneType__c='Manufacturing',
				MilestoneDatetime__c = system.now());
		Test.stopTest();
		//Then related order record ManufacturingMilestoneToAnaplanStatus__c field should be set to 'Success'
		System.assert(CalloutConstants.SUCCESS.equalsIgnoreCase(
				[SELECT ManufacturingMilestoneToAnaplanStatus__c FROM Order__C where Id=:order[0].Id]
						.ManufacturingMilestoneToAnaplanStatus__c),'Callout didnot return success response');
	}

	testmethod static void testManufacturingMilestoneToAnaplanStatusUdpateTriggerCallout()
	{
		Test.startTest();
		//Given I am on order record and milsstone record is created but callout failed
		Test.setMock(HttpCalloutMock.class, new ManufacturingMilestonesUpdateServiceMock(false));
		List<Order__c> order = [SELECT id,ManufacturingMilestoneToAnaplanStatus__c from Order__c WHERE ManufacturingMilestoneToAnaplanStatus__c!='Retry' LIMIT 1];
		insert new OrderMileStones__c(Order__c=order[0].Id , MilestoneType__c='Manufacturing',
				MilestoneDatetime__c = system.now());
		order[0].ManufacturingMilestoneToAnaplanStatus__c=CalloutConstants.FAILURE;
		update order;
		//When i update ManufacturingMilestoneToAnaplanStatus__c to retry
		order[0].ManufacturingMilestoneToAnaplanStatus__c=CalloutConstants.RETRY;
		update order;
		Test.setMock(HttpCalloutMock.class, new ManufacturingMilestonesUpdateServiceMock(true));
		Test.stopTest();
		//Then callout should be retriggered and related order record ManufacturingMilestoneToAnaplanStatus__c field should be set to 'Success' if service is on
		System.assert(CalloutConstants.SUCCESS.equalsIgnoreCase(
				[SELECT ManufacturingMilestoneToAnaplanStatus__c FROM Order__C where Id=:order[0].Id]
						.ManufacturingMilestoneToAnaplanStatus__c),'Callout didnot return success response');
	}

	@IsTest
	private static void itShouldUpdateOrderManufacturingStatusToQCQACOMPLETEWhenMilestoneIsQCQACOMPLETE()
	{
		//GIVEN - An order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Manufacturing' and Milestone Name as 'Apheresis Release to Manufacturing'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {QCQACOMPLETE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the manufacturing status of the related order to 'Manufacturing Started' and populate the 'Manufacturing Milestone Date Time'
		System.assertEquals(QCQACOMPLETE, orderMilestonesList[0].Order__r.ManufacturingStatus__c);
		System.assertEquals(orderMilestonesList[0].MilestoneDatetime__c, orderMilestonesList[0].Order__r.ManufacturingMilestoneDateTime__c,orderMilestonesList[0].MilestoneSource__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderManufacturingStatusToManufacturingCompleteWhenMilestoneIsManufacturingComplete()
	{
		//GIVEN - An order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Manufacturing' and Milestone Name as 'Manufacturing Complete'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {MANUFACTURINGCOMPLETE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the manufacturing status of the related order to 'Manufacturing Complete' and populate the 'Manufacturing Milestone Date Time'
		System.assertEquals(MANUFACTURINGCOMPLETE, orderMilestonesList[0].Order__r.ManufacturingStatus__c);
		System.assertEquals(orderMilestonesList[0].MilestoneDatetime__c, orderMilestonesList[0].Order__r.ManufacturingMilestoneDateTime__c, orderMilestonesList[0].MilestoneSource__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderManufacturingStatusToQRCompleteWhenMilestoneIsQRComplete()
	{
		//GIVEN - An order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Manufacturing' and Milestone Name as 'QR Complete'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {QRCOMPLETE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the manufacturing status of the related order to 'QR Complete' and populate the 'Manufacturing Milestone Date Time'
		System.assertEquals(QRCOMPLETE, orderMilestonesList[0].Order__r.ManufacturingStatus__c);
		System.assertEquals(orderMilestonesList[0].MilestoneDatetime__c, orderMilestonesList[0].Order__r.ManufacturingMilestoneDateTime__c,orderMilestonesList[0].MilestoneSource__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderManufacturingStatusToManufacturingStartedWhenMilestoneIsManufacturingStarted()
	{
		//GIVEN - An order milestone is created with Milestone Type as 'Manufacturing' and Milestone Name as 'Manufacturing Started'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {MANUFACTURINGSTARTED});
		System.assert(!orderMilestonesList.isEmpty());

		Test.startTest();

		//THEN - It should update the manufacturing status of the related order to 'Manufacturing Started' and populate the 'Manufacturing Milestone Date Time'
		System.assertEquals(MANUFACTURINGSTARTED, orderMilestonesList[0].Order__r.ManufacturingStatus__c);
		System.assertEquals(orderMilestonesList[0].MilestoneDatetime__c, orderMilestonesList[0].Order__r.ManufacturingMilestoneDateTime__c, orderMilestonesList[0].MilestoneSource__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateFreshCellPickupDateandTimeOnOrderWhenMilestoneIsAphPickupfromQTCStatusNDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Aph Pickup from QTC Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {APHPICKUPFROMQTCSTATUSANDDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update Fresh Cell Pick Up Date and Time with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.CryoCellPickupDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateFreshCellDropOffDateandTimeOnOrderWhenMilestoneIsAphDeliveryAt3rdPartyCryoStatusNDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Aph Delivery at 3rd party Cryo Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {APHDELIVERYAT3RDPARTYCRYOSTATUSDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the Fresh Cell Dropoff Date and Time of the related order with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.FreshCellDropOffDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCryoCellPickUpDateandTimeOnOrderWhenMilestoneIsAphPickupFrom3rdpartyCryoStatusNDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Aph PickUp from 3rd party Cryo Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {APHPICKUPFROM3RDPARTYCRYOSTATUSDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the Cryo Cell Pickup Date and Time with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.CryoCellPickupDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCryoCellDropOffDateandTimeOnOrderWhenMilestoneIsAphDeliveryatManufacturingSiteStatusDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Aph Delivery at Manufacturing Site Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {APHDELIVERYATMANUFACTURINGSITESTATUSDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the 'Cryo Cells Drop-off date and time' with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.CryoCellDropOffDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateFinalDPPickupDateNtimeOnOrderWhenMilestoneIsDrugProductPickupAtManufacturingSiteStatusDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as ' Drug Product pickup at Manufacturing Site Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {DRUGPRODUCTPICKUPATMANUFACTURINGSITESTATUSDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the 'Final DP Pickup Date and time' with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.FinalDPPickupDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateFinalDPDropOffDateNtimeOnOrderWhenMilestoneIsDrugProductdropoffatInfusionSiteStatusDate()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Drug Product drop off at Infusion Site Status & Date'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {DRUGPRODUCTDROPOFFATINFUSIONSITESTATUSDATE});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the 'Final DP Drop-off date and time' with Milestone Date and time
		System.assertEquals(orderMilestonesList[0].Order__r.FinalDPDropOffDateAndTime__c, orderMilestonesList[0].MilestoneDatetime__c);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateVinetiCOINumberVinetiCOINumberUpdated()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order milestone is created with Milestone Type as 'Shipment' and Milestone Name as 'Vineti COI Number updated'
		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {VINETICOINUMBERUPDATED});
		System.assert(!orderMilestonesList.isEmpty());

		//THEN - It should update the Vineti COI Number of the related order with the 'Manufacturing Milestone Date Time'
		system.assert(String.isNotBlank(orderMilestonesList[0].Order__r.VinetiCOI__c));

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderManufacturingStatusToManufacturingCompleteOnAfterUpdateEvent()
	{
		//GIVEN - An Order is created
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		//WHEN - An order milestone is created with Milestone Type as 'Manufacturing' and Milestone Name as 'Manufacturing Complete'
		Test.startTest();

		List<OrderMilestones__c> orderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIds((new Map<Id, Order__c>(ordersList)).keySet());
		orderMilestonesList[0].MilestoneType__c = MILESTONETYPEASMANUFACTURING;
		update orderMilestonesList;

		List<OrderMilestones__c> updatedOrderMilestonesList = new OrderMilestonesSelector()
				.selectByOrderIdAndMilestoneNames((new Map<Id, Order__c>(ordersList)).keySet(), new List<String> {MANUFACTURINGCOMPLETE});
		System.assert(!updatedOrderMilestonesList.isEmpty());

		Test.stopTest();

		//THEN - It should update the manufacturing status of the related order to 'Manufacturing Complete' and populate the 'Manufacturing Milestone Date Time'
		System.assertEquals(MANUFACTURINGCOMPLETE, updatedOrderMilestonesList[0].Order__r.ManufacturingStatus__c);
		System.assertEquals(updatedOrderMilestonesList[0].MilestoneDatetime__c, updatedOrderMilestonesList[0].Order__r.ManufacturingMilestoneDateTime__c, orderMilestonesList[0].MilestoneSource__c);

	}
}