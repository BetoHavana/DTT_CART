@isTest 
private class TasksServiceTest {
    private static final String CART_COORDINATOR = 'CAR-T Coordinator';
	private static final String PHYSICIAN = 'Physician';
	private static final String PARENT ='Parent';
    private static final String PRODUCT ='JNJ-4528';
    private static final String PATIENT_QUALITY_CHECK = 'Perform quality check of patient enrollment';
	private static final String THERAPY_SPECIALIST = 'Therapy Specialist';
	private static final String INTERNAL_OPERATIONS_COORDINATOR = 'CellTherapyOrderSpecialist';
	private static final String INTERNAL_BASE_USER = 'Internal Base User';
	
	@testSetup static void testDataSetup()
	{
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		Account trtSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		accToBeInserted.add(trtSite);
		Account patient = TestDataFactory.getPatientAccountsToInsert(1);
		accToBeInserted.add(patient);
		Account careGiver = TestDataFactory.getAccountToInsert(StaticConstants.CaregiverRecordTypeDeveloperName, 'Some', 'careGiver');
		accToBeInserted.add(careGiver);

		
		User cellTherapySpecialist = TestDataFactory.getUsersToInsert(INTERNAL_BASE_USER, 1)[0];
		cellTherapySpecialist.FirstName = THERAPY_SPECIALIST;

		insert cellTherapySpecialist;
		trtSite.CellTherapyOrderSpecialist__c = cellTherapySpecialist.Id;
		
		insert accToBeInserted;

		List<Contact> contactList = new List<Contact>();
		Contact trtSiteContact = TestDataFactory.getBusinessAccRelatedContacts(StaticConstants.TREATMENTSITELABEL, trtSite.Id);
		contactList.add(trtSiteContact);
		insert contactList;

		List<HealthCloudGA__ReciprocalRole__c> roleList = new List<HealthCloudGA__ReciprocalRole__c>();
		HealthCloudGA__ReciprocalRole__c physicianRole = TestDataFactory.getContactRole(PHYSICIAN, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(CART_COORDINATOR, StaticConstants.contactRole);
		HealthCloudGA__ReciprocalRole__c careGiverParentRole = TestDataFactory.getContactRole(PARENT, StaticConstants.contactRole);
		roleList.add(physicianRole);
		roleList.add(carTRole);
		roleList.add(careGiverParentRole);
		insert roleList;

		List<Account> patientNCareGiverAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
													.selectContactsByAccountId(new Set<Id> {patient.Id, careGiver.Id});

		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();
		HealthCloudGA__ContactContactRelation__c conRel1 = TestDataFactory.getContactRelationsToInsert(trtSiteContact.Id, contactList[0].Id, carTRole.Id);
		conRelationList.add(conRel1);
		if (!patientNCareGiverAccounts.isEmpty())
		{
			HealthCloudGA__ContactContactRelation__c careGiverRel = TestDataFactory.getContactRelationsToInsert(patientNCareGiverAccounts[1].Contacts[0].Id,
																	patientNCareGiverAccounts[0].Contacts[0].Id,
																	careGiverParentRole.Id);
			conRelationList.add(careGiverRel);
		}
		insert conRelationList;

		HealthCloudGA__CarePlanTemplate__c carePlanTemplate = TestDataFactory.getCarePlanTemplateList(PRODUCT, 1)[0];
        carePlanTemplate.HealthCloudGA__Active__c = true;
        insert carePlanTemplate;
    
        HealthCloudGA__CarePlanTemplateGoal__c carePlanTemplateGoal = TestDataFactory.getCarePlanTemplateGoalList('Patient Enrollment', 1, carePlanTemplate.Id)[0];
        insert carePlanTemplateGoal;
    
        HealthCloudGA__CarePlanTemplateTask__c carePlanTemplateTask = TestDataFactory.getCarePlanTemplateTaskList(PATIENT_QUALITY_CHECK, 1,  carePlanTemplateGoal)[0];
        carePlanTemplateTask.HealthCloudGA__AssignedTo__c = INTERNAL_OPERATIONS_COORDINATOR;
        insert carePlanTemplateTask;
	}

    @isTest
    static void itShouldAssignTheTaskOwnershipToTherapySpecialist(){
        //GIVEN a careplan has been created:
		Account treatmentSite = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
								.selectAll()
								.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName})[0];

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
												.selectByAccountId(new Set<Id>{treatmentSite.Id}).getContactsByAccountId();

		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		for (Case carePlan : carePlanList)
		{
			careplan.TreatmentSite__c = treatmentSite.Id;
		}	
		insert carePlanList;

		Test.startTest();
        //WHEN a task is created for the careplan and the name match some care plan task template subject
        
		List<Task> tasks = new List<Task>();
        Task taskObj;
        
        for (Case carePlan : carePlanList)
		{
			taskObj = new Task();
			taskObj.Priority = 'High';
			taskObj.subject = PATIENT_QUALITY_CHECK;
			taskObj.WhatId = careplan.Id;
			tasks.add(taskObj);
        }

        insert tasks;
        Test.stopTest();

        //THEN it should assign the ownership to the cell therapy specialist related to the treatmentSite
		List<Task> taskList =  ((TasksSelector) Application.Selector.newInstance(Task.SObjectType))
								.selectTasksByOwnerId(new Set<Id>{treatmentSite.CellTherapyOrderSpecialist__c});

		System.assertEquals(carePlanList.size(), taskList.size());
    }
}
