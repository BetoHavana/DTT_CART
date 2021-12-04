@isTest
public class OrdersServiceTest
{
	public static final String APHERESISPOSTATUS = 'Aph PO Pending';
	public static final String APHERESISPICKUPDATESCHEDULED = 'Apheresis Pickup Date Scheduled';
	public static final String APHERESISPONUMBER = '123ABC';
	public static final String CAREPLANSTATUSASDRUGPRODUCTSHIPPED = 'Drug Product Shipped';
	public static final String CELLSDELIVEREDTOMANUFACTURINGSITE = 'Cells Delivered to Manufacturing Site';
	public static final String CRYOCELLSDELIVERED = 'Cryo-ed Cells Delivered';
	public static final String CRYOTYPELOCAL = 'Local';
	public static final String CRYOTYPERARITAN = 'Raritan';
	public static final String COMPLETEDSTATUS = 'Completed';
	public static final String DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE =
			'Confirmation on delivery of final product to the Infusion/ Treatment Site';
	public static final String DRUGPRODUCTDELIVERYDATESCHEDULED = 'Drug Product Delivery Date Scheduled';
	public static final String FINALPRODUCTDELIVERED = 'Drug Product Delivered';
	public static final String FRESHCELLSDELIVERED = 'Fresh Cells Delivered';
	public static final Date INFUSIONDATE = Date.newInstance(2020, 12, 1);
	public static final String INPROGRESSSTATUS = 'In Progress';
	public static final String MANUFACTURING = 'Manufacturing';
	public static final String ORDERINPROGRESSSTATUS = 'Order In Progress';
	public static final String ORDERRESCHEDULED =  'Order Rescheduled';
	public static final String PATIENT_RECORDTYPE_DEVELOPERNAME = 'Patient';
	public static final String PORECEIVED = 'PO Received';
	public static final String QCQACOMPLETE = 'QC/QA Complete';
	public static final String REASON_FOR_RESCHEDULE ='Patient Health';
	public static final String SALESORDERUPDATE = 'SalesOrderUpdate';
	public static final String SHIPPINGCELLSTOMANUFACTURINGSITE = 'Shipping Cells to Manufacturing Site';
	public static final String SHIPPINGCRYOCELLS = 'Shipping Cryo-ed Cells';
	public static final String SHIPPINGFINALPRODUCT = 'Shipping Drug Product';
	public static final String SHIPPINGFRESHCELLS = 'Shipping Fresh Cells';
	public static final String SOFTSLOTCONFIRMED = 'Slot Confirmed';
	public static final String THIRDPARTY = '3rd party';

	@testSetup
	private static void setUpTestData()
	{
		TestDataFactory.createOrders();
	}

	@IsTest
	private static void itShouldStartOrderPlacementGoalAndRelatedTasksForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for Cryo type Local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		Test.startTest();

		//WHEN - An order is submitted and slot status is updated to Soft Slot Requested
		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[1].OrderStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Order Placement goal to 'In Progress' and related tasks to 'In Progress'
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[3].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartOrderPlacementGoalAndRelatedTasksForCryoCentral()
	{
		//GIVEN - An order on a patient account is created for cryo type local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - An order is submitted and slot status is updated to Soft Slot Requested
		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[1].OrderStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Order Placement goal to 'In Progress' and related tasks to 'In progress'
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[3].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartOrderPlacementGoalAndRelatedTasksForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - An order is submitted and slot status is updated to Soft Slot Requested
		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderSubmitted, ordersToBeUpdatedList[1].OrderStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotRequested, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Order Placement goal to 'In Progress' and related tasks to 'In Progress'
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.inProgressStatus, updatedTasksList[3].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartShippingAphToCryoSiteGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Fresh Cells Pickup Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FreshCellPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FreshCellPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Shipping Fresh Cells"
		* Care Plan Status to "Shipping Cells to Manufacturing Site"
		* Confirmation from Apheresis Site about cell pickup to "Completed"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
		(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGFRESHCELLS, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGFRESHCELLS, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.PickupCellsFromAphSiteLocationPerAphPickupDate};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingApheresisSiteToCryoSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartShippingAphToCryoSiteGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Fresh Cells Pickup Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FreshCellPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FreshCellPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Shipping Fresh Cells"
		* Care Plan Status to "Shipping Cells to Manufacturing Site"
		* Confirmation from Apheresis Site about cell pickup to "Completed"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGFRESHCELLS, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGFRESHCELLS, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.PickupCellsFromAphSiteLocationPerAphPickupDate};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingApheresisSiteToCryoSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteShippingAphToCryoSiteGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Fresh Cells DropOff Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FreshCellDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FreshCellDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Fresh Cells Delivered"
		* Shipping (Apheresis Site to Cryo Site) Goal is "Completed" and Tasks Status to "Completed"
		**/
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(FRESHCELLSDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(FRESHCELLSDELIVERED, updatedOrdersList[1].ShippingStatus__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingApheresisSiteToCryoSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationFromCryoSiteAboutCellDelivery};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingApheresisSiteToCryoSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteShippingAphToCryoSiteGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Fresh Cells DropOff Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FreshCellDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FreshCellDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Fresh Cells Delivered"
		* Shipping (Apheresis Site to Cryo Site) Goal is "Completed" and Tasks Status to "Completed"
		**/
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(FRESHCELLSDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(FRESHCELLSDELIVERED, updatedOrdersList[1].ShippingStatus__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingApheresisSiteToCryoSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationFromCryoSiteAboutCellDelivery};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingApheresisSiteToCryoSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartShippingCryoToManufacturingSiteGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells Pickup Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Shipping Cryo-ed Cells'
		//and the task Confirmation for pickup of Cryo cells from Cryo site should be updated to "Completed"
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				(new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsPickedUpFromTheCryoSitePickupLocation};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartShippingCryoToManufacturingSiteGoalForCryoRaritan()
	{
		// //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells Pickup Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Shipping Cryo Cells'
		//and the task Confirmation for pickup of Cryo cells from Cryo site should be updated to "Completed"
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsPickedUpFromTheCryoSitePickupLocation};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartShippingCryoToManufacturingSiteGoalForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells Pickup Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Shipping Cryo Cells'
		//and Careplan status to 'Shipping Cells to Manufacturing Site'
		//and the task Confirmation for pickup of Cryo cells from Cryo site should be updated to "Completed"
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				(new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGCRYOCELLS, updatedOrdersList[1].ShippingStatus__c);

		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(SHIPPINGCELLSTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsPickedUpFromTheCryoSitePickupLocation};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteShippingCryoToManufacturingSiteGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells Dropoff Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Cryo-ed Cells delivered'
		//Careplan Status should be updated to 'Cells Delivered to Manufacturing Site'
		//and goal Shipping (Cryo Site to Manufacturing Site) goal to "Completed"
		//and the task Confirmation for delivery of cells to Manufacturing site should be updated to "Completed"
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[1].ShippingStatus__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingCryoSiteToManufacturingSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsDeliveredToTheManufacturingSite};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteShippingCryoToManufacturingSiteGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells Dropoff Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Cryo-ed Cells delivered'
		//Careplan Status should be updated to 'Cells Delivered to Manufacturing Site'
		//and goal Shipping (Cryo Site to Manufacturing Site) goal to "Completed"
		//and the task Confirmation for delivery of cells to Manufacturing site should be updated to "Completed"
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[1].ShippingStatus__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingCryoSiteToManufacturingSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsDeliveredToTheManufacturingSite};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteShippingCryoToManufacturingSiteGoalForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Cryo Cells DropOff Date and Time is populated
		ordersList[0].CarePlanId__c = carePlanList[0].Id;
		ordersList[0].CryoCellDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanId__c = carePlanList[1].Id;
		ordersList[1].CryoCellDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;
		System.assert(!ordersToBeUpdatedList.isEmpty());

		//THEN - Shipping Status on Order should be updated to 'Shipping Cryo Cells'
		//Careplan Status should be updated to 'Cells Delivered to Manufacturing Site'
		//and goal Shipping (Cryo Site to Manufacturing Site) goal to "Completed"
		//and goal Shipping (Apheresis Site to Cryo Site) goal to "Completed" and tasks to "Completed"
		//and the task Confirmation for delivery of cells to Manufacturing site should be updated to "Completed"
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!updatedcarePlanList_afterOrderUpdate.isEmpty());
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CELLSDELIVEREDTOMANUFACTURINGSITE, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(CRYOCELLSDELIVERED, updatedOrdersList[1].ShippingStatus__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanApheresisToCryoSiteGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingApheresisSiteToCryoSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanApheresisToCryoSiteGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanApheresisToCryoSiteGoals[1].Status__c);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				sflib_ArrayUtils.pluckIdField(updatedOrdersList, Order__c.CarePlanID__c), Label.ShippingCryoSiteToManufacturingSite);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmationCryoPreservedCellsDeliveredToTheManufacturingSite};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingCryoSiteToManufacturingSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		List<String> ApheresisToCryoSitetasksToBeUpdatedList = new List<String> {Label.ConfirmationFromCryoSiteAboutCellDelivery};
		List<Task> ApheresisToCryoSiteupdatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingApheresisSiteToCryoSite,
				ApheresisToCryoSitetasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, ApheresisToCryoSiteupdatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, ApheresisToCryoSiteupdatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingDrugProductGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.ManufacturingStatus__c = QCQACOMPLETE;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[0].ManufacturingStatus__c);
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[1].ManufacturingStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Manufacturing Status in QCQA Complete
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[0].ManufacturingStatus__c = QCQACOMPLETE;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[1].ManufacturingStatus__c = QCQACOMPLETE;


		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Careplan Status to "Manufacturing"
		* Manufacturing Drug Product Goal and Tasks Status to "In progess"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[1].Status);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ManufacturingDrugProductGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmAndUpdateFinalProductDeliveryDate};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ManufacturingDrugProductGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingDrugProductGoalForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.ManufacturingStatus__c = QCQACOMPLETE;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[0].ManufacturingStatus__c);
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[1].ManufacturingStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Manufacturing status is QCQAComplete
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[0].ManufacturingStatus__c = QCQACOMPLETE;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[1].ManufacturingStatus__c = QCQACOMPLETE;


		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Careplan Status to "Manufacturing"
		* Manufacturing Drug Product Goal and Tasks Status to "In progess"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[1].Status);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ManufacturingDrugProductGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmAndUpdateFinalProductDeliveryDate};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ManufacturingDrugProductGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingDrugProductGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.ManufacturingStatus__c = QCQACOMPLETE;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[0].ManufacturingStatus__c);
		System.assertEquals(QCQACOMPLETE, prerequisiteOrdersToBeUpdatedList[1].ManufacturingStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Manufacturing status is QCQAComplete
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[0].ManufacturingStatus__c = QCQACOMPLETE;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = ORDERINPROGRESSSTATUS;
		ordersList[1].ManufacturingStatus__c = QCQACOMPLETE;


		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Careplan Status to "Manufacturing"
		* Manufacturing Drug Product Goal and Tasks Status to "In progess"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(MANUFACTURING, updatedcarePlanList_afterOrderUpdate[1].Status);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ManufacturingDrugProductGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmAndUpdateFinalProductDeliveryDate};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ManufacturingDrugProductGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingToInfusionGoallForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[1].OrderStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Order Status is Drug product delivery date scheduled
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Manufacturing to Infusion Goal to In progress and Tasks Status to "In progess"
		**/
		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);
		List<String> SecondtasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};
		List<Task> updatedTasksListforManToInfuGoal = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, SecondtasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingToInfusionGoallForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[1].OrderStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Order Status is Drug product delivery date scheduled
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Manufacturing to Infusion Goal to In progress and Tasks Status to "In progess"
		**/
		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);
		List<String> SecondtasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};
		List<Task> updatedTasksListforManToInfuGoal = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, SecondtasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldStartManufacturingToInfusionGoallForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Order__c> prerequisiteOrdersToBeUpdatedList = new List<Order__c>();
		for (Order__c order : ordersList)
		{
			order.OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
			prerequisiteOrdersToBeUpdatedList.add(order);
		}
		update prerequisiteOrdersToBeUpdatedList;

		System.assert(!prerequisiteOrdersToBeUpdatedList.isEmpty());
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(DRUGPRODUCTDELIVERYDATESCHEDULED, prerequisiteOrdersToBeUpdatedList[1].OrderStatus__c);

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Order Status is Drug product delivery date scheduled
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].OrderStatus__c = DRUGPRODUCTDELIVERYDATESCHEDULED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Manufacturing to Infusion Goal to In progress and Tasks Status to "In progess"
		**/
		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(INPROGRESSSTATUS, updatedCarePlanGoals[1].Status__c);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersToBeUpdatedList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksList[1].Status);

		List<String> secondTasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};
		List<Task> updatedTasksListforManToInfuGoal = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, secondTasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[0].Status);
		System.assertEquals(INPROGRESSSTATUS, updatedTasksListforManToInfuGoal[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseTaskOnShipMfgToInfusionGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Pickup Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Shipping Drug Product"
		* Care Plan Status to "Drug Product Shipped"
		* Confirmation on picking final product from Manufacturing Site Task Status to "In Progress"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseTaskOnShipMfgToInfusionGoalForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Pickup Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Shipping Drug Product"
		* Care Plan Status to "Drug Product Shipped"
		* Confirmation on picking final product from Manufacturing Site Task Status to "In Progress"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseTaskOnShipMfgToInfusionGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Pickup Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPPickupDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPPickupDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Shipping Drug Product"
		* Care Plan Status to "Drug Product Shipped"
		* Confirmation on picking final product from Manufacturing Site Task Status to "In Progress"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(CAREPLANSTATUSASDRUGPRODUCTSHIPPED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(SHIPPINGFINALPRODUCT, updatedOrdersList[1].ShippingStatus__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.PickingFinalProductFromManufacturingSitP};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseShipMfgToInfusionGoalForCryoRaritan()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Drop Off Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());

		/**THEN - It should update the following :
		* Order Shipping Status to "Drug Product Delivered"
		* Care Plan Status to "Drug Product Delivered"
		* Order Status to "Drug Product Delivered"
		* Confirmation on delivery of final product to the Infusion/ Treatment Site Task Status to "Completed"
		* Manufacturing to Infusion goal to "Completed"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseShipMfgToInfusionGoalForCryo3rdParty()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Drop Off Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());


		/**THEN - It should update the following :
		* Order Shipping Status to "Drug Product Delivered"
		* Care Plan Status to "Drug Product Delivered"
		* Order Status to "Drug Product Delivered"
		* Confirmation on delivery of final product to the Infusion/ Treatment Site Task Status to "Completed"
		* Manufacturing to Infusion goal to "Completed"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@IsTest
	private static void itShouldCloseShipMfgToInfusionGoalForCryoLocal()
	{
		 //GIVEN that Patient status is 'Verified'
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assert(!carePlanList.isEmpty());

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId(
				(new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(
				new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Final DP Drop Off Date and Time is populated
		ordersList[0].CarePlanID__c = carePlanList[0].Id;
		ordersList[0].FinalDPDropOffDateAndTime__c = Date.today();
		ordersList[1].CarePlanID__c = carePlanList[1].Id;
		ordersList[1].FinalDPDropOffDateAndTime__c = Date.today();

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());


		/**THEN - It should update the following :
		* Order Shipping Status to "Drug Product Delivered"
		* Care Plan Status to "Drug Product Delivered"
		* Order Status to "Drug Product Delivered"
		* Confirmation on delivery of final product to the Infusion/ Treatment Site Task Status to "Completed"
		* Manufacturing to Infusion goal to "Completed"
		**/
		List<Case> updatedcarePlanList_afterOrderUpdate = new CasesSelector().selectByPatientAccountId(
				(new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[0].Status);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedcarePlanList_afterOrderUpdate[1].Status);

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId(
				sflib_ArrayUtils.pluckIdField(ordersList, Order__c.Id));
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].ShippingStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(FINALPRODUCTDELIVERED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> updatedCarePlanIdsSet = ((Orders) Application.Domain.newInstance(ordersList)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(
				updatedCarePlanIdsSet, Label.ShippingManufacturingSiteToInfusionSite);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(COMPLETEDSTATUS, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {DELIVERYOFFINALPRODUCTTOINFUSIONTREATMENTSITE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c},
				Label.ShippingManufacturingSiteToInfusionSite, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		Test.stopTest();
	}

	@isTest
	private static void itShouldUpdateCryoSiteInfoForLocal()
	{
		Test.startTest();

		//GIVEN the Cryo Type defined on the Order is 'Central' AND Apheresis Site associated to the Order has Cryo Type defined as 'Local'
		List<Order__c> ordersList = new OrdersSelector().selectAll();
		ordersList[0].CryoType__c = StaticConstants.CryoSiteCentral;
		ordersList[1].CryoType__c = StaticConstants.CryoSiteCentral;
		List<Order__c> ordersTobeUpdated = new List<Order__c>();
		ordersTobeUpdated.add(ordersList[0]);
		ordersTobeUpdated.add(ordersList[1]);
		update ordersTobeUpdated;

		//WHEN user change the Cryo Type to 'Local'
		ordersTobeUpdated[0].CryoType__c = StaticConstants.cryoSiteLocal;
		ordersTobeUpdated[1].CryoType__c = StaticConstants.cryoSiteLocal;
		List<Order__c> ordersTobeUpdatedToLocal = new List<Order__c>();
		ordersTobeUpdatedToLocal.add(ordersTobeUpdated[0]);
		ordersTobeUpdatedToLocal.add(ordersTobeUpdated[1]);
		update ordersTobeUpdatedToLocal;

		//THEN  the Cryo Type on the Order is updated to 'Local' and Values in the Cryo Site field is populated
		//Values in the Cryo Site Pick-up Address and Cryo Site Drop-off Address should be updated
		List<Order__c> updatedOrdersList = new OrdersSelector()
				.selectOrdersByOrderId(new Set<Id> {ordersTobeUpdatedToLocal[0].Id, ordersTobeUpdatedToLocal[1].Id});
		Test.stopTest();
		system.assertEquals(StaticConstants.cryoSiteLocal, updatedOrdersList[0].CryoType__c);
		system.assertNotEquals(NULL, updatedOrdersList[0].CryoSite__c);
	}

	testmethod static void testUpdateSalesOrderUpdateSuccessMock()
	{
		test.startTest();
		//Given an Order Record

		Test.setMock(HttpCalloutMock.class, new SalesOrderUpdateServiceMock(true));
		List<Order__c> order = [SELECT id,SDPO__c from Order__c LIMIT 1];
		order[0].SDPO__c = '12345' ;
		//When SDPO__c field is changed

		Update order;
		test.stopTest();
		//Then order SalesOrderToSAPStatus__c is Success

		//System.assert(CalloutConstants.SUCCESS.equalsIgnoreCase(
		//		[SELECT SalesOrderToSAPStatus__c FROM Order__c where Id = :order[0].Id LIMIT 1].SalesOrderToSAPStatus__c),
		//		'Callout Didnt return Success Response');
	}

	static void updateOrderStatus(String orderStatus, List<Order__c> orders)
	{
		for (Order__c order : orders)
		{
			order.OrderStatus__c = orderStatus;
		}
		update orders;
	}

	testmethod static void testOrderCancellationShouldCreateOrderCancellationCase()
	{

		Test.startTest();

		//GIVEN Order Records with status other than New, Drug Product Delivered, Order Cancellation, Infusion Complete

		OrdersSelector ordersSelector = (OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType);
		List<Order__c> orders = ordersSelector.selectAll();
		updateOrderStatus('Withdrawn', orders);

		//WHEN Order Status is Updated   to Order Cancellation Requested

		updateOrderStatus('Order Cancellation Requested', orders);

		Test.stopTest();

		//Then Order Cancellation Case Should be created for all the orders updated above

		List<Case> orderCancellationCases = [SELECT Id,Status from Case where OrderId__c IN :orders and recordtype.developername = 'OrderCancellationCase'];
		System.assert(orders.size() == orderCancellationCases.size(), 'Order Cancellation Case is not created');

		for (Case caseRecord : orderCancellationCases)
		{
			caseRecord.Status = 'Closed - Order to be Cancelled';
		}

		update orderCancellationCases;

		for (Order__c order : ordersSelector.selectAll())
		{
			system.assert(order.DateOfCancellationRequest__c != null, 'Order Cancellation Request Initiated Date is not updated on to order');
		}
	}

	@IsTest
	private static void itShouldUpdateTheCarePlanStatusAndTheTasksRelatedToTheOrderPlacementGoalForCryoCentral()
	{
		//GIVEN - An order on a patient account is created for cryo type Central
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//WHEN - The slot status is updated to Slot Confirmed
		Test.startTest();

		ordersList[0].SlotStatus__c = StaticConstants.softSlotConfirmed;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotConfirmed;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Care Plan Status and the Tasks related to the Order Placement Goal
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateTheCarePlanStatusAndTheTasksRelatedToTheOrderPlacementGoalForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for cryo type local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoSiteLocal;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoSiteLocal, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//WHEN - The slot status is updated to Slot Confirmed
		Test.startTest();

		ordersList[0].SlotStatus__c = StaticConstants.softSlotConfirmed;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotConfirmed;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Care Plan Status and the Tasks related to the Order Placement Goal
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateTheCarePlanStatusAndTheTasksRelatedToTheOrderPlacementGoalForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[0].SlotStatus__c = StaticConstants.softSlotRequested;
		ordersList[1].OrderStatus__c = StaticConstants.orderSubmitted;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotRequested;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//WHEN - The slot status is updated to Slot Confirmed
		Test.startTest();

		ordersList[0].SlotStatus__c = StaticConstants.softSlotConfirmed;
		ordersList[1].SlotStatus__c = StaticConstants.softSlotConfirmed;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.softSlotConfirmed, ordersToBeUpdatedList[1].SlotStatus__c);

		//THEN - It should update the Care Plan Status and the Tasks related to the Order Placement Goal
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupRequestedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.inProgressStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseInfusionGoalAndRecordInfusionDateTaskForCryoCentral()
	{
		//GIVEN - An order on a patient account is created for cryo type Central
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Infusion Date field is populated
		ordersList[0].InfusionDate__c = INFUSIONDATE;
		ordersList[1].InfusionDate__c = INFUSIONDATE;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Infusion Goal and Record Infusion Date Task
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(INFUSIONDATE, updatedOrdersList[0].InfusionDate__c);
		System.assertEquals(INFUSIONDATE, updatedOrdersList[1].InfusionDate__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.Infusion);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {StaticConstants.RECORDINFUSIONDATE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.Infusion, tasksToBeUpdatedList);

		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseInfusionGoalAndRecordInfusionDateTaskForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for cryo type Local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoSiteLocal;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoSiteLocal, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Infusion Date field is populated
		ordersList[0].InfusionDate__c = INFUSIONDATE;
		ordersList[1].InfusionDate__c = INFUSIONDATE;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Infusion Goal and Record Infusion Date Task
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(INFUSIONDATE, updatedOrdersList[0].InfusionDate__c);
		System.assertEquals(INFUSIONDATE, updatedOrdersList[1].InfusionDate__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.Infusion);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {StaticConstants.RECORDINFUSIONDATE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.Infusion, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseInfusionGoalAndRecordInfusionDateTaskForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - Infusion Date field is populated
		ordersList[0].InfusionDate__c = INFUSIONDATE;
		ordersList[1].InfusionDate__c = INFUSIONDATE;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Infusion Goal and Record Infusion Date Task
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(INFUSIONDATE, updatedOrdersList[0].InfusionDate__c);
		System.assertEquals(INFUSIONDATE, updatedOrdersList[1].InfusionDate__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderInfusionComplete, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.carePlanStatusAsInfused, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.Infusion);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {StaticConstants.RECORDINFUSIONDATE};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.Infusion, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseOrderPlacementGoalAndRelatedTaskForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		ordersList[0].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[1].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[1].POStatus__c = StaticConstants.POReceived;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Slot Status field is changed to Slot Confirmed
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[1].SlotStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated, Label.ConfirmPOIsRecordedFromPharmacistOrSD, Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[6].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[7].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[8].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[9].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseOrderPlacementGoalAndRelatedTaskForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for cryo type Local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoSiteLocal;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoSiteLocal, cryoSiteAccountsList[0].Type);

		ordersList[0].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[1].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[1].POStatus__c = StaticConstants.POReceived;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Slot Status field is changed to Slot Confirmed
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[1].SlotStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated, Label.ConfirmPOIsRecordedFromPharmacistOrSD, Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[6].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[7].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[8].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[9].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateCarePlanAndOrderStatusAndCloseOrderPlacementGoalAndRelatedTaskForCryoCentral()
	{
		//GIVEN - An order on a patient account is created for cryo type Central
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		ordersList[0].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[1].ApheresisPOStatus__c = StaticConstants.apheresisPOReceived;
		ordersList[1].POStatus__c = StaticConstants.POReceived;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Slot Status field is changed to Slot Confirmed
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;


		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[0].SlotStatus__c);
		System.assertEquals(StaticConstants.hardSlotReserved, updatedOrdersList[1].SlotStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[0].Status);
		System.assertEquals(StaticConstants.apheresisPickupConfirmedStatus, updatedCarePlansList[1].Status);

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask, Label.AcknowledgeSoftSlotIsBookedOrAllocated, Label.ConfirmPOIsRecordedFromPharmacistOrSD, Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[2].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[3].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[4].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[5].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[6].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[7].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[8].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[9].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderStatusAndCloseOrderPlacementGoalAndARelatedTaskForCryoCentral()
	{
		//GIVEN - An order on a patient account is created for cryo type Central
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[1].POStatus__c = StaticConstants.POReceived;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Apheresis PO # field is Populated
		ordersList[0].ApheresisPO__c = APHERESISPONUMBER;
		ordersList[1].ApheresisPO__c = APHERESISPONUMBER;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);

		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderStatusAndCloseOrderPlacementGoalAndARelatedTaskForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for cryo type Local
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoSiteLocal;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoSiteLocal, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[1].POStatus__c = StaticConstants.POReceived;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Apheresis PO # field is Populated
		ordersList[0].ApheresisPO__c = APHERESISPONUMBER;
		ordersList[1].ApheresisPO__c = APHERESISPONUMBER;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldUpdateOrderStatusAndCloseOrderPlacementGoalAndARelatedTaskForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = StaticConstants.cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(StaticConstants.cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		ordersList[0].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[0].POStatus__c = StaticConstants.POReceived;
		ordersList[0].SlotStatus__c = StaticConstants.hardSlotReserved;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = StaticConstants.OrderRescheduled;
		ordersList[1].POStatus__c = StaticConstants.POReceived;
		ordersList[1].SlotStatus__c = StaticConstants.hardSlotReserved;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		Test.startTest();

		//WHEN - Apheresis PO # field is Populated
		ordersList[0].ApheresisPO__c = APHERESISPONUMBER;
		ordersList[1].ApheresisPO__c = APHERESISPONUMBER;

		ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;


		//THEN - It should update the Care Plan and Order Status and should close the Order Placement Goal and Related Tasks
		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(StaticConstants.orderVerified, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();

		List<HealthCloudGA__CarePlanGoal__c> updatedCarePlanGoals = new CarePlanGoalsSelector().selectByCarePlanIdAndName(carePlanIdsSet, Label.OrderPlacementGoal);
		System.assert(!updatedCarePlanGoals.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[0].Status__c);
		System.assertEquals(StaticConstants.completedStatus, updatedCarePlanGoals[1].Status__c);

		List<String> tasksToBeUpdatedList = new List<String> {Label.NotifyStakeholdersAboutOrderPlacement};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[0].Status);
		System.assertEquals(StaticConstants.completedStatus, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTasksOnOrderPlacementGoalAndRelatedTasksForCryoLocalResh()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - An order is rescheduled and slot status is updated to Soft Slot Confirmed
		ordersList[0].POStatus__c = POReceived;
		ordersList[0].SlotStatus__c = softSlotConfirmed;
		ordersList[0].ApheresisPOStatus__c = APHERESISPOSTATUS;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].POStatus__c = POReceived;
		ordersList[1].SlotStatus__c = softSlotConfirmed;
		ordersList[1].ApheresisPOStatus__c = APHERESISPOSTATUS;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(softSlotConfirmed, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(softSlotConfirmed, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[0].ApheresisPOStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[1].ApheresisPOStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		Order Status to 'Order Rescheduled'
		and complete the tasks under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask,Label.AcknowledgeSoftSlotIsBookedOrAllocated,Label.ConfirmPOIsRecordedFromPharmacistOrSD};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[2].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[3].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[4].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[5].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[6].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[7].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTasksOnOrderPlacementGoalAndRelatedTasksForCryoRarResh()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = cryoTypeRaritan;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(cryoTypeRaritan, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - An order is rescheduled and slot status is updated to Soft Slot Confirmed
		ordersList[0].POStatus__c = POReceived;
		ordersList[0].SlotStatus__c = softSlotConfirmed;
		ordersList[0].ApheresisPOStatus__c = APHERESISPOSTATUS;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].POStatus__c = POReceived;
		ordersList[1].SlotStatus__c = softSlotConfirmed;
		ordersList[1].ApheresisPOStatus__c = APHERESISPOSTATUS;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(softSlotConfirmed, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(softSlotConfirmed, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[0].ApheresisPOStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[1].ApheresisPOStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		Order Status to 'Order Rescheduled'
		and complete the tasks under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask,Label.AcknowledgeSoftSlotIsBookedOrAllocated,Label.ConfirmPOIsRecordedFromPharmacistOrSD};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[2].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[3].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[4].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[5].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[6].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[7].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTasksOnOrderPlacementGoalAndRelatedTasksForCryo3rdPartyResh()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);

		Test.startTest();

		//WHEN - An order is rescheduled and slot status is updated to Soft Slot Confirmed
		ordersList[0].POStatus__c = POReceived;
		ordersList[0].SlotStatus__c = SOFTSLOTCONFIRMED;
		ordersList[0].ApheresisPOStatus__c = APHERESISPOSTATUS;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].POStatus__c = POReceived;
		ordersList[1].SlotStatus__c = SOFTSLOTCONFIRMED;
		ordersList[1].ApheresisPOStatus__c = APHERESISPOSTATUS;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[0].ApheresisPOStatus__c);
		System.assertEquals(APHERESISPOSTATUS, ordersToBeUpdatedList[1].ApheresisPOStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		Order Status to 'Order Rescheduled'
		and complete the tasks under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, updatedOrdersList[1].OrderStatus__c);

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.SelectAnApheresisPickupDateTask, Label.SubmitTheRequestForSchedulingApheresisPickupTask,Label.AcknowledgeSoftSlotIsBookedOrAllocated,Label.ConfirmPOIsRecordedFromPharmacistOrSD};

		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[2].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[3].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[4].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[5].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[6].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[7].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTaskConfirmSDPOOnOrderPlacementGoalAndRelatedTasksForCryo3rdParty()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = THIRDPARTY;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(THIRDPARTY, cryoSiteAccountsList[0].Type);
		Test.startTest();

		//WHEN - An order is rescheduled ,PO status is PO Received and slot status is updated to Soft Slot Confirmed
		ordersList[0].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[0].POStatus__c = PORECEIVED;
		ordersList[0].SlotStatus__c = SOFTSLOTCONFIRMED;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[1].POStatus__c = PORECEIVED;
		ordersList[1].SlotStatus__c = SOFTSLOTCONFIRMED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[1].OrderStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		and complete the task 'Confirm SD PO# is recorded' under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmPOIsRecordedFromPharmacistOrSD};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTaskConfirmSDPOOnOrderPlacementGoalAndRelatedTasksForCryoLocal()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPELOCAL;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPELOCAL, cryoSiteAccountsList[0].Type);
		Test.startTest();

		//WHEN - An order is rescheduled ,PO status is PO Received and slot status is updated to Soft Slot Confirmed
		ordersList[0].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[0].POStatus__c = PORECEIVED;
		ordersList[0].SlotStatus__c = SOFTSLOTCONFIRMED;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[1].POStatus__c = PORECEIVED;
		ordersList[1].SlotStatus__c = SOFTSLOTCONFIRMED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[1].OrderStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		and complete the task 'Confirm SD PO# is recorded' under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmPOIsRecordedFromPharmacistOrSD};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);

		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
	private static void itShouldCompleteTaskConfirmSDPOOnOrderPlacementGoalAndRelatedTasksForCryoRaritan()
	{
		//GIVEN - An order on a patient account is created for cryo type Raritan
		Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
				.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {PATIENT_RECORDTYPE_DEVELOPERNAME}))
				.getById();

		List<Case> carePlanList = new CasesSelector().selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(carePlanList)).keySet());
		System.assert(!ordersList.isEmpty());

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectById(new Set<Id> {ordersList[0].CryoSite__c}).getRecords();
		cryoSiteAccountsList[0].Type = CRYOTYPERARITAN;
		update cryoSiteAccountsList;

		System.assert(!cryoSiteAccountsList.isEmpty());
		System.assertEquals(CRYOTYPERARITAN, cryoSiteAccountsList[0].Type);
		Test.startTest();

		//WHEN - An order is rescheduled ,PO status is PO Received and slot status is updated to Soft Slot Confirmed
		ordersList[0].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[0].POStatus__c = PORECEIVED;
		ordersList[0].SlotStatus__c = SOFTSLOTCONFIRMED;
		ordersList[0].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].ReasonforReschedule__c = REASON_FOR_RESCHEDULE;
		ordersList[1].OrderStatus__c = ORDERRESCHEDULED;
		ordersList[1].POStatus__c = PORECEIVED;
		ordersList[1].SlotStatus__c = SOFTSLOTCONFIRMED;

		List<Order__c> ordersToBeUpdatedList = new List<Order__c>();
		ordersToBeUpdatedList.add(ordersList[0]);
		ordersToBeUpdatedList.add(ordersList[1]);
		update ordersToBeUpdatedList;

		System.assert(!ordersToBeUpdatedList.isEmpty());
		System.assertEquals(POReceived, ordersToBeUpdatedList[0].POStatus__c);
		System.assertEquals(POReceived, ordersToBeUpdatedList[1].POStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[0].SlotStatus__c);
		System.assertEquals(SOFTSLOTCONFIRMED, ordersToBeUpdatedList[1].SlotStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[0].OrderStatus__c);
		System.assertEquals(ORDERRESCHEDULED, ordersToBeUpdatedList[1].OrderStatus__c);

		/*THEN - It should update careplan status to 'Apheresis pickupdate Scheduled'
		and complete the task 'Confirm SD PO# is recorded' under Order Placement goal */

		List<Order__c> updatedOrdersList = new OrdersSelector().selectOrdersByOrderId((new Map<Id, Order__c>(ordersToBeUpdatedList)).keySet());
		System.assert(!updatedOrdersList.isEmpty());

		Set<Id> carePlanIdsSet = ((Orders) Application.Domain.newInstance(updatedOrdersList)).getCarePlanIds();
		List<Case> updatedCarePlansList = new CasesSelector().selectByCarePlanId(carePlanIdsSet);
		System.assert(!updatedCarePlansList.isEmpty());
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[0].Status);
		System.assertEquals(APHERESISPICKUPDATESCHEDULED, updatedCarePlansList[1].Status);

		List<String> tasksToBeUpdatedList = new List<String> {Label.ConfirmPOIsRecordedFromPharmacistOrSD};
		List<Task> updatedTasksList = new TasksSelector().selectByCarePlanIdAndGoalNameAndSubject(
				new Set<Id> {updatedOrdersList[0].CarePlanID__c, updatedOrdersList[1].CarePlanID__c}, Label.OrderPlacementGoal, tasksToBeUpdatedList);
		System.assert(!updatedTasksList.isEmpty());
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[0].Status);
		System.assertEquals(COMPLETEDSTATUS, updatedTasksList[1].Status);

		Test.stopTest();
	}

	@IsTest
    private static void itShouldGetSalesOrderUpdateSuccessMock()
	{
		//GIVEN - An Order Record
		Test.setMock(HttpCalloutMock.class, new SalesOrderUpdateServiceMock(true));
		List<Order__c> ordersList = new OrdersSelector().selectAll();
        HttpRequest request = new HttpRequest();
		request.setMethod(CalloutConstants.POST);
		request.setEndpoint(CalloutConstants.CALLOUTCOLON + SALESORDERUPDATE);
		request.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
		request.setHeader(CalloutConstants.CLIENT_ID, CalloutConstants.CREDENTIAL_USERNAMEMERGEFIELD);
		request.setHeader(CalloutConstants.CLIENT_SECRET, CalloutConstants.CREDENTIAL_PWDMERGEFIELD);
		request.setBody(ordersList[0].Id);
		request.setTimeout(CalloutConstants.CALLOUTIMEOUT);

		test.startTest();
        //WHEN - new request is send
        HttpResponse res = new Http().send(request);
        CalloutOutputUtility output = (CalloutOutputUtility) JSON.deserialize(res.getBody(), CalloutOutputUtility.Class);
		output.code = String.valueOf(CalloutConstants.TWOHUNDRED);
        output.message = CalloutConstants.SUCCESS;
        output.CARTOrderId = CalloutConstants.JNJ101;
		
		test.stopTest();
		//THEN - the response is Success
		System.assert(CalloutConstants.SUCCESS.equalsIgnoreCase(output.status));
	}

}
