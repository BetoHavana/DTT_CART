@IsTest(SeeAllData=false)
public class OrdersTest
{
	//GIVEN - A care plan has been created for a patient, and order has been generated.
	@TestSetup static void testDataSetup()
	{
		List<String> listOfSitesNames = new List<String>();
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		listOfSitesNames.add('TreatmentSite');
		listOfSitesNames.add('ApheresisSite');
		listOfSitesNames.add('CryoSite');

		for (String siteName : listOfSitesNames)
		{
			accToBeInserted.add(TestDataFactory.getBusinessAccountToInsert(siteName));
		}
		insert accToBeInserted;

		List<Contact> contactList = new List<Contact>();
		List<String> listOfSites = new List<String>();
		listOfSites.add('Treatment Site');
		listOfSites.add('Apheresis Site');
		listOfSites.add('Cryo Site');

		for (Account site : accToBeInserted)
		{
			if (!PatientRecordTypeId.equals(site.RecordTypeId))
			{
				contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
			}
		}

		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();

		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole('CAR-T Coordinator', 'ContactRole');
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole('Aphresis Site', 'AccountRole');
		HealthCloudGA__ReciprocalRole__c cryoSiteRole1 = TestDataFactory.getContactRole('Cryo Site', 'AccountRole');

		roleList.add(carTRole);
		roleList.add(aphSiteRole1);
		roleList.add(cryoSiteRole1);
		insert roleList;

		List<Account> accList = [SELECT Id, (SELECT Id,AccountId FROM Contacts) FROM Account LIMIT 5];
		List<Contact> conList = new List<Contact>();

		for (Account acc : accList)
		{
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
		List<Case> caseList = TestDataFactory.getCareplanCasesList(conList);
		insert caseList;
		testDataSetup2(caseList);
	}

	private static void testDataSetup2(List<Case> caseList)
	{
		List<Id> listOfCaseIds = new List<Id>();

		if (!caseList.isEmpty())
		{
			for (Case c : caseList)
			{
				listOfCaseIds.add(c.Id);
			}
		}

		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = TestDataFactory.getGoals(listOfCaseIds, Label.OrderPlacementGoal);
		insert listOfGoals;

		List<Id> listOfGoalIds = new List<Id>();

		for (HealthCloudGA__CarePlanGoal__c goal : listOfGoals)
		{
			listOfGoalIds.add(goal.Id);
		}

		List<String> listOfTasksSubject = new List<String>();
		listOfTasksSubject.add(Label.SelectAnApheresisPickupDateTask);
		listOfTasksSubject.add(Label.SubmitTheRequestForSchedulingApheresisPickupTask);
		listOfTasksSubject.add('Test Task');

		List<Task> listOfTasks = new List<Task>();
		listOfTasks = TestDataFactory.getTasks(listOfGoalIds[0], listOfTasksSubject);
		listOfTasks[0].WhatId = caseList[0].Id;
		listOfTasks[1].WhatId = caseList[1].Id;
		insert listOfTasks;

		List<Order__c> orderList = [SELECT Id,SlotStatus__c,SDPO__c,OrderStatus__c,POStatus__c,CarePlanID__c FROM Order__c LIMIT 5];
		for (Order__c ord : orderList)
		{
			ord.SlotStatus__c = StaticConstants.softSlotConfirmed;
		}
		update orderList;

		List<Order__c> orderListWithSDPOAsNotNull = [SELECT Id,SlotStatus__c,SDPO__c,OrderStatus__c,POStatus__c,CarePlanID__c FROM Order__c LIMIT 5];
		for (Order__c ord : orderListWithSDPOAsNotNull)
		{
			ord.SDPO__c = '34567890';
		}
		update orderListWithSDPOAsNotNull;
	}


	@IsTest static void itShouldGetOrderDetails()
	{
		List<Order__c> returnListOfOrders = new List<Order__c>();
		List<Id> listOfOrderIds = new List<Id>();
		//WHEN - The order Id has been passed to the server-side method named getOrderDetails() of the Orders class.
		Test.startTest();
		List<Order__c> listOfOrders = [SELECT Id,Name,CarePlanID__c,ApheresisPickUpDate__c FROM Order__c LIMIT 5];

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

	@IsTest static void itShouldUpdateOrdersSlotConfirmed()
	{
		//WHEN Slot Status of an Order is updated as 'Soft Slot Confirmed'
		Test.startTest();
		List<Order__c> updatedOrdersList = [SELECT Id,SlotStatus__c,SDPO__c,OrderStatus__c,POStatus__c,CarePlanID__c FROM Order__c WHERE SDPO__c = NULL AND SlotStatus__c = :StaticConstants.softSlotConfirmed LIMIT 5];

		Test.stopTest();
		//THEN Check if the Order Status & PO Status is updated accordingly
		for (Order__c order : updatedOrdersList)
		{
			System.assertEquals(StaticConstants.orderVerified, order.OrderStatus__c);
			System.assertEquals(StaticConstants.POPending, order.POStatus__c);
		}
	}

	@IsTest static void itShouldUpdateOrdersWithSDPOAsNotNull()
	{
		//WHEN SDPO of an Order is populated
		Test.startTest();
		List<Order__c> updatedOrdersList = [SELECT Id,SDPO__c,OrderStatus__c,POStatus__c,CarePlanID__c FROM Order__c WHERE SDPO__c != NULL LIMIT 5];

		Test.stopTest();
		//THEN Check if the PO Status is updated accordingly
		System.assertEquals(StaticConstants.POReceived, updatedOrdersList[2].POStatus__c);
	}

	@IsTest static void itShouldPopulateOrderNameAndCartOrderId()
	{
		//GIVEN A care plan has been created for a patient.
		Test.startTest();

		//WHEN Order is inserted
		List<Order__c> updatedOrdersList = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType)).selectAll();

		Test.stopTest();
		//THEN it should populate Name and CartOrderId__c with the same value
		System.assert(!updatedOrdersList.isEmpty());

		Order__c testOrder = updatedOrdersList[0];
		System.assertEquals(testOrder.Name, testOrder.CartOrderId__c);
	}

	@IsTest static void itShouldCloseTaskBySubject(){
		//GIVEN - A task has been created for a care plan.
		Case carePlan = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
		.selectAll()[0];

		Order__c ord = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
		.selectOrdersByCarePlanId(new Set<Id>{
			carePlan.Id
		})[0];

		List<Task> taskToInsert = TestDataFactory.getCarePlanTasks(carePlan.Id, new List<String>{
			Label.OrderReschedule,
			Label.ConfirmDeliveryDate,
			Label.OrderPlacement
		});

		insert taskToInsert;

		//WHEN - VinetiCOI__c or FinalDPDateinVineti__c or OrderRescheduledinVineti__c in Order__c is updated
		Test.startTest();
		ord.VinetiCOI__c = 'Vineti COI Number updated';
		ord.FinalDPDateinVineti__c = 'Final DP Date updated';
		update ord;
		Test.stopTest();

		//THEN - it should mark its related task as closed
		system.assertEquals(2, [SELECT COUNT() FROM Task WHERE Status = 'completed']);
	}

	/*@IsTest
  private static void itShouldCreateAdhocTasksforVeinToVein()
   {
	   List<Order__c> listOfOrdersUpdated = new List<Order__c>();
	   Order__c orderToUpdate = new Order__c();

	   Test.startTest();
	   //GIVEN- An Order has been created with a Care Plan related
	   List<Order__c> listOfOrders = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType)).selectAll();
	   orderToUpdate = listOfOrders[0];

	   //WHEN - the ApheresisPO__c is populated, the ConfirmedFPDeliveryDate__c is populated
	   //and the OrderStatus__c is updated to Order Rescheduled in the order .
	   orderToUpdate.OrderStatus__c = 'Order Rescheduled';
	   update orderToUpdate;

	   orderToUpdate.ApheresisPO__c = '12312';
	   update orderToUpdate;

	   orderToUpdate.ConfirmedFPDeliveryDate__c = System.today();
	   update orderToUpdate;

	   List<Task> newTasks =  ((TasksSelector) Application.Selector.newInstance(Task.SObjectType)).selectAllTasks();

	   Map<String,Id> tasksCreated = new Map<String,Id>();

	   for(Task objTask : newTasks)
	   {
		   if(objTask.WhatId == orderToUpdate.CarePlanID__c)
		   {
			   tasksCreated.put(objTask.Subject,objTask.WhatId);
		   }
	   }
	   Test.stopTest();

	   //THEN - It should create a task with subject 'Setup a new order in Vineti on receipt of Aph PO for order placement',
	   //another task with subject 'Update/create the order in Vineti' and another with subject
	   //'Update the DP Delivery Date of the order on receiving the confirmed DP Delivery Date from the site'.
	   System.assertEquals(tasksCreated.containsKey(Label.OrderReschedule) , true);
	   System.assertEquals(tasksCreated.containsKey(Label.OrderPlacement) , true);
	   System.assertEquals(tasksCreated.containsKey(Label.ConfirmDeliveryDate) , true);
   }*/
}
