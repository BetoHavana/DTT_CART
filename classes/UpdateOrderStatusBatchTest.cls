@isTest(seeAllData=false)
public class UpdateOrderStatusBatchTest
{
	public static final String CENTRAL = 'Central';
	public static final String THIRDPARTY = '3rd party';

	//GIVEN Test Data for Updating the Order & related records status to In Progress
	@testSetup
	private static void setUpTestData()
	{
		List<String> listOfSitesNames = new List<String>();
		List<Contact> contactList = new List<Contact>();
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
		List<Account> accountsToBeUpdated = new List<Account>();
		for (Account site : accToBeInserted)
		{
			if (PatientRecordTypeId.equals(site.RecordTypeId))
			{
				site.Status__c = StaticConstants.PatientStatusVerified;
				accountsToBeUpdated.add(site);
			}
			else
			{
				contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
			}
		}
		update accountsToBeUpdated;
		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();

		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole('CAR-T Coordinator', 'ContactRole');
		HealthCloudGA__ReciprocalRole__c aphSiteRole1 = TestDataFactory.getContactRole('Aphresis Site', 'AccountRole');
		HealthCloudGA__ReciprocalRole__c cryoSiteRole1 = TestDataFactory.getContactRole('Cryo Site', 'AccountRole');

		roleList.add(carTRole);
		roleList.add(aphSiteRole1);
		roleList.add(cryoSiteRole1);
		insert roleList;

		List<Account> accList = [select Id, (select Id,AccountId from Contacts) from Account LIMIT 5];
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

		Id cryoSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
				.get(StaticConstants.CRYOSITELABEL)
				.getRecordTypeId();

		List<Account> cryoSiteAccountsList = new AccountsSelector().selectByDeveloperName(cryoSiteRecordTypeId);
		cryoSiteAccountsList[0].Type = THIRDPARTY;

		update cryoSiteAccountsList;

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(caseList)).keySet());
		List<Order__c> updatedOrders = new List<Order__c>();

		for (Order__c order : ordersList)
		{
			order.CryoSite__c = cryoSiteAccountsList[0].Id;
			updatedOrders.add(order);
		}

		update updatedOrders;

		testDataSetup2(caseList);
	}

	private static void testDataSetup2(List<Case> caseList)
	{
		List<Id> caseIds = new List<Id>();
		for (Case cs : caseList)
		{
			caseIds.add(cs.Id);
		}
		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = TestDataFactory.getGoalsForCaseIds(caseIds);
		insert listOfGoals;

		List<Task> taskList = TestDataFactory.getTasksForGoalIds(listOfGoals);
		insert taskList;

		List<Order__c> orderList = [select Id,SlotStatus__c,OrderStatus__c,PatientStatus__c,CarePlanId__c,CryoType__c,CryoSite__c,CryoSite__r.Type,ApheresisPickUpDate__c from Order__c where CarePlanId__c IN:caseIds LIMIT 5];
		for (Order__c ord : orderList)
		{
			ord.CryoType__c = CENTRAL;
			ord.ApheresisPickUpDate__c = system.today();
		}
		update orderList;

	}

	@isTest static void itShouldExecuteOrderStatusBatch()
	{
		//WHEN the Order PO Status is PO Received and Slot Status is Soft Slot Confirmed and Cryo Site is Central and Apheresis Pickup Date is Today and Patient Status is Verified
		String CRON_EXP = '0 0 0 15 3 ? *';

		Test.startTest();
		String jobId = System.schedule('Test', CRON_EXP, new UpdateOrderStatusBatchSchedulable());
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
		System.assertEquals(CRON_EXP, ct.CronExpression);
		System.assertEquals(0, ct.TimesTriggered);
		UpdateOrderStatusBatch bt = new UpdateOrderStatusBatch();
		Database.executeBatch(bt);
		Test.stopTest();
		List<Order__c> ordList = [select Id,OrderStatus__c,CarePlanId__r.Status,CryoType__c from Order__c where OrderStatus__c = :StaticConstants.orderInProgressStatus LIMIT 5];
		Map<Id, HealthCloudGA__CarePlanGoal__c> goalsMap = new Map<Id, HealthCloudGA__CarePlanGoal__c>([select Id,name,Status__c from HealthCloudGA__CarePlanGoal__c where Status__c = :StaticConstants.inProgressStatus LIMIT 5]);
		List<Task> tasksList = [select Status from Task where Status = :StaticConstants.inProgressStatus];

		//THEN the Goal Status and related Tasks Status should be updated as In Progress
		system.assert(!goalsMap.values().isEmpty());
		system.assert(!tasksList.isEmpty());
	}

}