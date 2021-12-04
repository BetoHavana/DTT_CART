@IsTest
public with sharing class TestDataFactory
{
	Private Static Final String CAREPROGRAMPRODUCT = 'Test Care Program Product';
	private static final String PICKUP = 'Pickup';
	private static final String DROPOFF = 'Drop Off';
	private static final String INDUSTRIESBUSINESS = 'IndustriesBusiness';
	private static final String ACTIVE = 'Active';
	private static final String MILESTONEJSONREQUEST = '{"COINumber": "COI-12345"},{"DIN": "DIN-12345"}';
	private static final String SPECIALTYDISTRIBUTOR = 'SpecialtyDistributor';
	private static final String TESTLOCATION = 'Test Location';
	private static final String TESTCAREPROGRAM = 'testCareProgram';
	private static final String TREATMENTSITE = 'Treatment Site';

    public static String getUniqueUserNameOrEmail() {

        String orgId = UserInfo.getOrganizationId();
    	String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
    	Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
    	String uniqueName = orgId + dateString + randomInt;
        String uniqueEmailOrUserName = uniqueName + '@test' + orgId + '.org' ;

        return uniqueEmailOrUserName;
    }

	public static List<Account> getPatientAccountsList()
	{
		List<Account> patientAccountsList = new List<Account>();
		Account account = new Account();
		Set<Integer> loopCount = new Set<Integer> {1, 2, 3, 4, 5, 6, 7};
		for (Integer count : loopCount)
		{
			account = TestDataFactory.getPatientAccountsToInsert(count);
			patientAccountsList.add(account);
		}
		return patientAccountsList;
	}

	public static List<Account> getBusinessAccountsList(String recTypeName, Integer noOfRecordsToInsert)
	{
		List<Account> businessAccountsList = new List<Account>();
		for (Integer i = 0; i < noOfRecordsToInsert; i++)
		{
			Account account = new Account();
			account = TestDataFactory.getBusinessAccountToInsert(recTypeName);
			businessAccountsList.add(account);
		}
		return businessAccountsList;
	}

	public static Account getBusinessAccountToInsert(String recTypeName)
	{
		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
		Account acc = new Account();
		Integer erpId = Integer.valueOf(
            Math.floor(
            	((Math.random() * Math.random()) * 1000000000) / (Math.random() * 10)
            )
        );
		acc.Name = 'Test Treatment Site';
		acc.Phone = '342627';
		acc.Status__c = 'Active';
		acc.Type = 'Local';
		acc.RecordTypeId = recTypeId;
		acc.ERPSiteID__c = String.valueOf(erpId);
		return acc;
	}

	public static Account getAccountToInsert(String recTypeName, String firstName, String lastName)
	{
		Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
		Account acc = new Account();
		acc.FirstName = firstName;
		acc.LastName = lastName;
		acc.RecordTypeId = recTypeId;
		return acc;
	}

	public static HealthCloudGA__ContactContactRelation__c getContactRelationsToInsert(Id contactId, Id relContactId, Id recRoleId)
	{
		HealthCloudGA__ContactContactRelation__c conRel = new HealthCloudGA__ContactContactRelation__c();
		conRel.HealthCloudGA__Contact__c = contactId;
		conRel.HealthCloudGA__RelatedContact__c = relContactId;
		conRel.HealthCloudGA__Role__c = recRoleId;

		return conRel;
	}

	public static HealthCloudGA__AccountAccountRelation__c getAccountRelationsToInsert(Id accountId, Id relatedAccountId, Id recRoleId)
	{

		HealthCloudGA__AccountAccountRelation__c accContactRel = new HealthCloudGA__AccountAccountRelation__c();
		accContactRel.HealthCloudGA__Account__c = accountId;
		accContactRel.HealthCloudGA__RelatedAccount__c = relatedAccountId;
		accContactRel.HealthCloudGA__Role__c = recRoleId;
		accContactRel.PrimarySite__c = 'Yes';

		return accContactRel;
	}

	public static List<HealthCloudGA__AccountAccountRelation__c> getAccountRelationsToInsertBasedOnSites
			(List<Id> accountIds, List<Id> relatedAccountIds, Id reciprocalRoleId, Integer count)
	{
		List<HealthCloudGA__AccountAccountRelation__c> accRelList = new List<HealthCloudGA__AccountAccountRelation__c>();
		for (Integer i = 0; i < count; i++)
		{
			accRelList.add(new HealthCloudGA__AccountAccountRelation__c(
					HealthCloudGA__Account__c = accountIds.get(i),
					HealthCloudGA__RelatedAccount__c = relatedAccountIds.get(i),
					HealthCloudGA__Role__c = reciprocalRoleId,
					PrimarySite__c = 'Yes'
			));
		}
		return accRelList;
	}

	public static Contact getBusinessAccRelatedContacts(String conName, Id accId)
	{
		Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('IndustriesBusiness').getRecordTypeId();
		Contact con = new Contact();
		con.AccountId = accId;
		con.FirstName = 'Test';
		con.LastName = conName;
		con.RecordTypeId = recTypeId;
        con.Email = getUniqueUserNameOrEmail();

		return con;
	}

	public static List<AccountContactRelation> getAccountContactRelationsToInsert
			(List<Account> accounts,List<Contact> Contacts, Integer count)
	{
		List<AccountContactRelation> accRelList = new List<AccountContactRelation>();
		for (Integer i = 0; i < count; i++)
		{
			accRelList.add(new AccountContactRelation(
					AccountId = accounts[i].Id,
					ContactId = Contacts[i].Id,
					Roles = TREATMENTSITE,
					MedicalRecordNumber__c = '434242' + i

			));
		}
		return accRelList;
	}

	public static List<Order__c> getOrders(List<Id> listOfCaseIds, Id patientId)
	{
		List<Order__c> listOfOrders = new List<Order__c>();
		Order__c order = new Order__c();

		for (Id caseId : listOfCaseIds)
		{
			order = new Order__c();
			order.ApheresisPickUpDate__c = Date.today();
			order.CarePlanID__c = caseId;
			order.Patient__c = patientId;
			order.ConfirmedFPDeliveryDate__c =  Date.today();
			order.AtlasOrderId__c = '574121';
			Order.CartOrderId__c = 'ORD-0057';
			listOfOrders.add(order);

		}
		return listOfOrders;
	}

	public static List<HealthCloudGA__CarePlanGoal__c> getGoals(List<Id> listOfCaseIds, String goalName)
	{
		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = new List<HealthCloudGA__CarePlanGoal__c>();
		if (!listOfCaseIds.isEmpty())
		{
			for (Id caseId : listOfCaseIds)
			{
				HealthCloudGA__CarePlanGoal__c goal = new HealthCloudGA__CarePlanGoal__c();
				goal.HealthCloudGA__CarePlan__c = caseId;
				goal.Name = goalName;
				listOfGoals.add(goal);
			}
		}
		return listOfGoals;
	}

	public static List<HealthCloudGA__CarePlanGoal__c> getGoalsForCaseIds(List<Id> listOfCaseIds)
	{
		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = new List<HealthCloudGA__CarePlanGoal__c>();
		Set<String> goalNamesList = new Set<String>();
		goalNamesList.add(Label.OrderPlacementGoal);
		goalNamesList.add(Label.ShippingApheresisSiteToCryoSite);
		goalNamesList.add(Label.ShippingCryoSiteToManufacturingSite);
		goalNamesList.add(Label.ShippingManufacturingSiteToInfusionSite);
		goalNamesList.add(Label.ManufacturingDrugProductGoal);
        goalNamesList.add(Label.Infusion);
		if (!listOfCaseIds.isEmpty())
		{
			for (Id caseId : listOfCaseIds)
			{
				for (String goalName : goalNamesList)
				{
					listOfGoals.add(new HealthCloudGA__CarePlanGoal__c(
							HealthCloudGA__CarePlan__c = caseId,
							Name = goalName,
							Status__c = StaticConstants.inProgressStatus
					));
				}
			}
		}
		return listOfGoals;
	}


	public static List<Task> getTasksForGoalIds(List<HealthCloudGA__CarePlanGoal__c> listOfGoals)
	{
		List<Task> listOfTasks = new List<Task>();
		Set<String> taskNamesList = new Set<String>();
		taskNamesList.add(Label.PickupCellsFromAphSiteLocationPerAphPickupDate);
		taskNamesList.add(Label.ConfirmAndUpdateFinalProductDeliveryDate);
		taskNamesList.add(Label.PickingFinalProductFromManufacturingSitP);
		taskNamesList.add(StaticConstants.deliveryOfFinalProductToInfusionTreatmentSite);
		taskNamesList.add(Label.ConfirmationCryoPreservedCellsPickedUpFromTheCryoSitePickupLocation);
		taskNamesList.add(Label.SelectAnApheresisPickupDateTask);
		taskNamesList.add(Label.SubmitTheRequestForSchedulingApheresisPickupTask);
		taskNamesList.add(Label.AcknowledgeSoftSlotIsBookedOrAllocated);
		taskNamesList.add(Label.NotifyStakeholdersAboutOrderPlacement);
		taskNamesList.add(Label.ConfirmPOIsRecordedfromPharmacistSD);
		taskNamesList.add(Label.ConfirmationCryoPreservedCellsDeliveredToTheManufacturingSite);
		taskNamesList.add(Label.ConfirmationFromCryoSiteAboutCellDelivery);
		taskNamesList.add(StaticConstants.RECORDINFUSIONDATE);

		if (!listOfGoals.isEmpty())
		{
			for (HealthCloudGA__CarePlanGoal__c goal : listOfGoals)
			{
				for (String taskName : taskNamesList)
				{
					listOfTasks.add(new Task(
							HealthCloudGA__CarePlanGoal__c = goal.Id,
							WhatId = goal.HealthCloudGA__CarePlan__c,
							Subject = taskName,
							Status = StaticConstants.inProgressStatus
					));
				}
			}
		}
		return listOfTasks;
	}

	public static List<Task> getTasks(Id goalId, List<String> listOfTaskSubjects)
	{
		List<Task> listOfTasks = new List<Task>();

		for (String subject : listOfTaskSubjects)
		{
			Task tsk = new Task();
			tsk.HealthCloudGA__CarePlanGoal__c = goalId;
			tsk.Status = StaticConstants.inProgressStatus;
			tsk.Subject = subject;
			listOfTasks.add(tsk);
		}
		return listOfTasks;
	}

	public static List<Task> getCarePlanTasks(Id carePlanId, List<String> listOfTaskSubjects)
	{
		List<Task> listOfTasks = new List<Task>();

		for (String subject : listOfTaskSubjects)
		{
			Task tsk = new Task();
			tsk.WhatId = carePlanId;
			tsk.Status = StaticConstants.inProgressStatus;
			tsk.Subject = subject;
			listOfTasks.add(tsk);
		}
		return listOfTasks;

	}

	public static List<OrderMilestones__c> getOrderMilestonesForManufacturing(List<Order__c> ordersList, List<String> milestoneNamesList, List<String> milestoneTypesList, Map<String, String> manufacturingMilestones, Integer numberOfRecords)
	{
		List<OrderMilestones__c> orderMilestonesList = new List<OrderMilestones__c>();
		OrderMilestones__c orderMilestone;

		for (Integer count = 0; count <= numberOfRecords; count++)
		{
			orderMilestone = new OrderMilestones__c();
			orderMilestone = TestDataFactory.getOrderMilestone(ordersList[count], milestoneTypesList[0], milestoneNamesList[count], manufacturingMilestones.get(milestoneNamesList[count]), count);
			orderMilestonesList.add(orderMilestone);
		}

		return orderMilestonesList;
	}

	public static List<OrderMilestones__c> getOrderMilestones(List<Order__c> ordersList, List<String> milestoneNamesList, List<String> milestoneTypesList, List<String> milestoneSourceList, Integer numberOfRecords)
	{
		List<OrderMilestones__c> orderMilestonesList = new List<OrderMilestones__c>();
		OrderMilestones__c orderMilestone;

		for (Integer count = 0; count <= numberOfRecords; count++)
		{
			orderMilestone = new OrderMilestones__c();
			orderMilestone = TestDataFactory.getOrderMilestone(ordersList[count], milestoneTypesList[0], milestoneNamesList[count], milestoneSourceList[0],count);
			orderMilestonesList.add(orderMilestone);
		}

		return orderMilestonesList;
	}

	public static OrderMilestones__c getOrderMilestone(Order__c order, String milestoneType, String milestoneName, String milestonesource, Integer count)
	{
		OrderMilestones__c orderMilestone = new OrderMilestones__c();

		orderMilestone.Order__c = order.Id;
		orderMilestone.MilestoneType__c = milestoneType;
		orderMilestone.Name = milestoneName;
		orderMilestone.MilestoneSource__c = milestonesource;
		orderMilestone.MilestoneDatetime__c = System.now().addDays(count);
		orderMilestone.MilestoneDetail__c = MILESTONEJSONREQUEST;

		return orderMilestone;
	}

	public static List<Case> getCareplanCasesList(List<Contact> contactList)
	{
		CareProgram careProgramRecord = getCareProgramsList(TESTCAREPROGRAM, 1)[0];
		insert careProgramRecord;

		List<CareProgramEnrollee> careProgramEnrollees = new List<CareProgramEnrollee>();
		List<Case> casesToBeInserted = new List<Case>();
		for (Contact con : contactList)
		{
			careProgramEnrollees.add(getCareProgramEnrolleeRecords(new Map<Id, Id> {con.accountId => careProgramRecord.Id}).get(0));
			casesToBeInserted.add(getCasestoInsert(con.Id, con.AccountId));
		}
		insert careProgramEnrollees;
		return casesToBeInserted;
	}


	public static List<CareProgram> getCareProgramsList(String careProgramName, Integer count)
	{
		List<CareProgram> careProgramsList = new List<CareProgram>();
		for (Integer i = 0; i <= count; i++)
		{
			CareProgram obj = new CareProgram();
			obj.Name = careProgramName + count;
			careProgramsList.add(obj);
		}
		return careProgramsList;
	}

	public static List<HealthCloudGA__CarePlanTemplateGoal__c> getCarePlanTemplateGoalList(String carePlanTemplateGoalName, Integer count, Id carePlanTemplateId)
	{
		List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoalsList = new List<HealthCloudGA__CarePlanTemplateGoal__c>();
		for (Integer i = 0; i <= count; i++)
		{
			HealthCloudGA__CarePlanTemplateGoal__c obj = new HealthCloudGA__CarePlanTemplateGoal__c();
			obj.Name = carePlanTemplateGoalName + count;
			obj.HealthCloudGA__CarePlanTemplate__c = carePlanTemplateId;
			obj.HealthCloudGA__SortOrder__c = count;
			carePlanTemplateGoalsList.add(obj);
		}
		return carePlanTemplateGoalsList;
	}

	public static List<HealthCloudGA__CarePlanTemplateTask__c> getCarePlanTemplateTaskList(String carePlanTemplateTaskName, Integer count, HealthCloudGA__CarePlanTemplateGoal__c carePlanTemplateGoal)
	{
		List<HealthCloudGA__CarePlanTemplateTask__c> carePlanTemplateTaskList= new List<HealthCloudGA__CarePlanTemplateTask__c>();
		for (Integer i = 0; i <= count; i++)
		{
			HealthCloudGA__CarePlanTemplateTask__c obj = new HealthCloudGA__CarePlanTemplateTask__c();
			obj.Name = carePlanTemplateTaskName + count;
			obj.HealthCloudGA__Subject__c = carePlanTemplateTaskName;
			obj.HealthCloudGA__CarePlanTemplateGoal__c = carePlanTemplateGoal.Id;
			obj.HealthCloudGA__SortOrder__c = count;
			obj.HealthCloudGA__Active__c = true;
			obj.HealthCloudGA__Offset__c = 100;
			obj.HealthCloudGA__Status__c = 'Not Started';
			obj.HealthCloudGA__Type__c	 = 'Automated';
			carePlanTemplateTaskList.add(obj);
		}
		return carePlanTemplateTaskList;
	}

	public static List<HealthCloudGA__CarePlanTemplate__c> getCarePlanTemplateList(String carePlanTemplateName, Integer count)
	{
		List<HealthCloudGA__CarePlanTemplate__c> carePlanTemplateList = new List<HealthCloudGA__CarePlanTemplate__c>();
		for (Integer i = 0; i <= count; i++)
		{
			HealthCloudGA__CarePlanTemplate__c obj = new HealthCloudGA__CarePlanTemplate__c();
			obj.Name = carePlanTemplateName + count;
			carePlanTemplateList.add(obj);
		}
		return carePlanTemplateList;
	}

	public static HealthCloudGA__ReciprocalRole__c getContactRole(String roleName, String recTypeName)
	{
		Id conRoleId = Schema.SObjectType.HealthCloudGA__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get(recTypeName).getRecordTypeId();
		HealthCloudGA__ReciprocalRole__c rol = new HealthCloudGA__ReciprocalRole__c();
		rol.HealthCloudGA__InverseRole__c = roleName;
		rol.Name = roleName;
		rol.RecordTypeId = conRoleId;

		return rol;
	}

	public static Case getCasestoInsert(Id contactId, Id accountId)
	{
		Id carePlanRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('CarePlan').getRecordTypeId();
		Case cs = new Case();
		cs.AccountId = accountId;
		cs.ContactId = contactId;
		cs.Description = 'Careplan Case';
		cs.RecordTypeId = carePlanRecTypeId;
		cs.Status = 'New';

		return cs;
	}

	public static List<Schema.Location> getLocationRecords(String locationName, Integer count)
	{
		List<Schema.Location> locationList = new List<Schema.Location>();
		for (Integer i = 0; i <= count; i++)
		{
			locationList.add(new Schema.Location(
					AddressLine1__c = 'Test Address line 1',
					AddressLine2__c = 'Test Address line 2',
					City__c = 'Los Angeles',
					State__c = 'CA',
					Country__c = 'US',
					PostalCode__c = '90005',
					LocationType = 'Patient',
					Name = locationName + count));
		}
		return locationList;
	}

	public static List<Schema.AssociatedLocation> getAssociatedLocationRecords(Map<Id, Id> accountLocationMap)
	{
		List<Schema.AssociatedLocation> assLocationList = new List<Schema.AssociatedLocation>();
		for (Id accId : accountLocationMap.keySet())
		{
			assLocationList.add(new Schema.AssociatedLocation(
					ParentRecordId = accId,
					LocationId = accountLocationMap.get(accId)
			));
		}
		return assLocationList;
	}

	public static List<Schema.AssociatedLocation> getAssociatedLocationRecordsBasedOnSiteName(List<Id> siteIds, List<Schema.Location> locationList, Integer count)
	{
		List<Schema.AssociatedLocation> assLocationList = new List<Schema.AssociatedLocation>();
		for (Integer i = 0; i < count; i++)
		{
			for (Integer j = 0; j < 2; j++)
			{
				String siteType = '';
				if (math.mod(j, 2) == 0)
				{
					siteType = PICKUP;
				}
				else
				{
					siteType = DROPOFF;
				}
				assLocationList.add(new Schema.AssociatedLocation(
						ParentRecordId = siteIds.get(i),
						LocationId = locationList.get(i).Id,
						Type = siteType
				));
			}
		}
		return assLocationList;
	}

	public static List<CareProgramEnrolleeProduct> getCareProgramEnrolleeProductRecords(Map<Id, Id> careProgramEnrolleeAndProductMap)
	{
		List<CareProgramEnrolleeProduct> careProgEnrolleeProductList = new List<CareProgramEnrolleeProduct>();
		for (Id careProgramEnrolleeId : careProgramEnrolleeAndProductMap.keySet())
		{
			careProgEnrolleeProductList.add(new CareProgramEnrolleeProduct(
					CareProgramEnrolleeId = careProgramEnrolleeId,
					CareProgramProductId = careProgramEnrolleeAndProductMap.get(careProgramEnrolleeId),
					Name = 'Test Care Program Enrollee Product Record'));
		}
		return careProgEnrolleeProductList;
	}

	public static List<CareProgramProduct> getCareProgramProductRecords(Map<Id, Id> careProgramAndProductMap)
	{
		List<CareProgramProduct> careProgProductList = new List<CareProgramProduct>();
		for (Id careProgramId : careProgramAndProductMap.keySet())
		{
			careProgProductList.add(new CareProgramProduct(
					CareProgramId = careProgramId,
					ProductId = careProgramAndProductMap.get(careProgramId),
					Name = 'Test'));
		}
		return careProgProductList;
	}

	public static List<CareProgramEnrollee> getCareProgramEnrolleeRecords(Map<Id, Id> accountAndEnrolleeMap)
	{
		List<CareProgramEnrollee> careProgEnrolleeList = new List<CareProgramEnrollee>();
		for (Id accountId : accountAndEnrolleeMap.keySet())
		{
			careProgEnrolleeList.add(new CareProgramEnrollee(
					AccountId = accountId,
					CareProgramId = accountAndEnrolleeMap.get(accountId),
					Name = 'Test'));
		}
		return careProgEnrolleeList;
	}

	public static List<Product2> getProductsList(String productName, Integer count)
	{
		List<Product2> productsList = new List<Product2>();
		for (Integer i = 0; i <= count; i++)
		{
			productsList.add(new Product2(
					Name = productName,
                	Description = 'test'+count,
					IsActive = true,
					TherapyType__c = 'Commercial'));
		}
		return productsList;
	}

	public static Account getPatientAccountsToInsert(Integer count)
	{
		Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
		Account patientRecord = new Account();
		patientRecord.FirstName = 'Test';
		patientRecord.HealthCloudGA__Gender__pc = 'Male';
		patientRecord.LastName = 'Patient' + count;
		patientRecord.PersonBirthdate = Date.newInstance(1995, 14, 5);
		patientRecord.PersonEmail = 'test@abc.com';
		patientRecord.Phone = '3457876';
		patientRecord.RecordTypeId = PatientRecordTypeId;
		patientRecord.Status__c = 'Pending Verification';

		return patientRecord;
	}

	public static List<User> getUsersToInsert(String profileName, Integer count)
	{
		List<Profile> adminProfiles = ((ProfilesSelector) Application.Selector.newInstance(Profile.SObjectType)).
				selectByName(profileName);
		List<User> usersList = new List<User>();
		for (Integer i = 0; i <= count; i++)
		{
			User user = new User();
			user.Alias = 'admUser';
			user.Email = 'User' + Math.random() * 100 + '@testuser.com';
			user.EmailEncodingKey = 'UTF-8';
			user.LastName = 'User' + count;
			user.FirstName = 'Admin';
			user.LanguageLocaleKey = 'en_US';
			user.LocaleSidKey = 'en_US';
			user.Username = 'User' + Math.random() * 100 + '@test.com';
			user.Country = 'Belgium';
			user.TimeZoneSidKey = 'GMT';
			user.ProfileId = adminProfiles[0].Id;
			user.UserPermissionsKnowledgeUser = true;
			user.isActive = true;
			usersList.add(user);
		}
		return usersList;
	}

	public static List<PermissionSetAssignment> assignPermissionSets(Set<String> permissionSetName, User user)
	{
		List<PermissionSetAssignment> lstPermissionSetAssignments = new List<PermissionSetAssignment>();
		List<PermissionSet> permissionSets = ((PermissionSetSelector) Application.Selector.newInstance(PermissionSet.SObjectType))
				.selectByNames(permissionSetName);
		for (PermissionSet objPermissionSet : permissionSets)
		{
			lstPermissionSetAssignments.add(new PermissionSetAssignment(AssigneeId = user.Id, PermissionSetId = objPermissionSet.Id));
		}
		return lstPermissionSetAssignments;
	}

	public static List<HealthCloudGA__ContactContactRelation__c> getAssociatedContactRelationsToInsert(List<Id> contactIdList, List<Id> relContactIdList, Id recRoleId, Integer numberOfRecords)
	{
		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();
		HealthCloudGA__ContactContactRelation__c conRel;
		for (Integer count = 0; count < numberOfRecords; count++)
		{
			conRel = new HealthCloudGA__ContactContactRelation__c();
			conRel.HealthCloudGA__Contact__c = contactIdList.get(count);
			conRel.HealthCloudGA__RelatedContact__c = relContactIdList.get(count);
			conRel.HealthCloudGA__Role__c = recRoleId;
			conRelationList.add(conRel);
		}

		return conRelationList;
	}

	public static CareProgramEnrollee getCareProgramEnrollee(Id careProgramId, Id patientId)
	{
		CareProgramEnrollee carePrograEnrolleeObj = new CareProgramEnrollee();
		carePrograEnrolleeObj.Name = 'CareProgramEnrolle' + Math.random() * 100;
		carePrograEnrolleeObj.AccountId = patientId;
		carePrograEnrolleeObj.CareProgramId = careProgramId;
		carePrograEnrolleeObj.Status = 'In-progress';
		return carePrograEnrolleeObj;
	}

	public static PatientServicesEnrollee__c getPatientServicesEnrollee(Id carePlanId, Id patientId)
	{
		PatientServicesEnrollee__c patientServicesEnrolleeObj = new PatientServicesEnrollee__c();
		patientServicesEnrolleeObj.Patient__c = patientId;
		patientServicesEnrolleeObj.CarePlan__c = carePlanId;
		patientServicesEnrolleeObj.CaregiverFirstName__c = 'Test';
		patientServicesEnrolleeObj.CaregiverMiddleName__c = 'John';
		patientServicesEnrolleeObj.CaregiverLastName__c = 'Ricky';
		patientServicesEnrolleeObj.PatientServicesStatus__c = 'New Patient Services Request';
		return patientServicesEnrolleeObj;
	}

	public static List<ContentDocument> createAttachment(Integer count)
	{
		String title = 'Attachment' + Integer.valueof(Math.random() * 100);
		List<ContentVersion> lstContentVersions = new List<ContentVersion>();
		for (Integer i = 0; i < count; i++)
		{
			lstContentVersions.add(
					new ContentVersion(
							Title = title,
							PathOnClient = 'Attachment.jpg',
							VersionData = Blob.valueOf('Test Content'),
							IsMajorVersion = true
					)
			);
		}
		insert lstContentVersions;

		List<ContentDocument> lstContentDocuments =
				((ContentDocumentsSelector) Application.Selector.newInstance(ContentDocument.SObjectType))
						.selectByTitle(title);
		return lstContentDocuments;
	}

	public static ContentDocumentLink getVisibleContentDocumentLink(Id linkEntityId, Id contentDocumentId)
	{
		ContentDocumentLink contentlink = new ContentDocumentLink(
				LinkedEntityId = linkEntityId,
				ShareType = 'V',
				ContentDocumentId = contentDocumentId,
				Visibility = 'AllUsers'
		);
		return contentlink;
	}

	public static List<HealthCloudGA__ContactContactRelation__c> getAssociatedContactRelationsToInsert(List<Id> contactIdList, List<Id> relContactIdList, String reciprocalRole, String recipRoleRecTypeName, Integer numberOfRecords)
	{
		List<HealthCloudGA__ReciprocalRole__c> reciprocalRolesList = ((ReciprocalRoleSelector) Application.Selector.newInstance(HealthCloudGA__ReciprocalRole__c.SObjectType))
				.selectByRoleName(reciprocalRole, recipRoleRecTypeName);
		List<HealthCloudGA__ContactContactRelation__c> conRelationList = new List<HealthCloudGA__ContactContactRelation__c>();

		HealthCloudGA__ContactContactRelation__c conRel;
		for (Integer count = 0; count < numberOfRecords; count++)
		{
			conRel = new HealthCloudGA__ContactContactRelation__c();
			conRel.HealthCloudGA__Contact__c = contactIdList.get(count);
			conRel.HealthCloudGA__RelatedContact__c = relContactIdList.get(count);
			conRel.HealthCloudGA__Role__c = reciprocalRolesList[0].Id;
			conRelationList.add(conRel);
		}
		return conRelationList;
	}

	public static List<Notification__c> getNotificationList(Integer count, Id PatientId)
	{
		List<Notification__c> notificationList = new List<Notification__c>();
		for (Integer i = 0; i < count; i++)
		{
			Notification__c notificationRecord = new Notification__c();
			notificationRecord.AssignedTo__c = UserInfo.getUserId();
			notificationRecord.Message__c = 'Test Message' + count;
			notificationRecord.ReadStatus__c = 'Unread';
			notificationRecord.Subject__c = 'Read';
			notificationRecord.RelatedRecordId__c = PatientId;
			notificationList.add(notificationRecord);
		}
		return notificationList;
	}

	public static List<SiteProduct__c> getSiteProducts(List<Id> treatmentSiteIds, List<Id> sdAccountIds, List<Product2> productList)
	{
		List<SiteProduct__c> siteProductList = new List<SiteProduct__c>();
		for (Integer count = 0; count < 3; count++)
		{
			SiteProduct__c sitePro = new SiteProduct__c();
			sitePro.ParentAccount__c = treatmentSiteIds[count];
			sitePro.SpecialtyDistributor__c = sdAccountIds[count];
			sitePro.Product__c = productList[count].Id;
			sitePro.Status__c = ACTIVE;
			siteProductList.add(sitePro);
		}
		return siteProductList;
	}

	@isTest
	public static void createOrders()
	{
		CareProgram careProgramRecord = TestDataFactory.getCareProgramsList(TESTCAREPROGRAM, 1)[0];
		insert careProgramRecord;

		CareProgramProduct CareProgramProductRecord = new CareProgramProduct();
		CareProgramProductRecord.Name = CAREPROGRAMPRODUCT;
		CareProgramProductRecord.CareProgramId = CareProgramRecord.Id;
		CareProgramProductRecord.Status = ACTIVE;
		insert CareProgramProductRecord;

		List<String> listOfSitesNames = new List<String>();
		List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
		listOfSitesNames.add(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
		listOfSitesNames.add(StaticConstants.APHERESISSITE);
		listOfSitesNames.add(StaticConstants.CRYOSITE);
		listOfSitesNames.add(SPECIALTYDISTRIBUTOR);

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
		Id specialtyDistributorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
				.get(SPECIALTYDISTRIBUTOR)
				.getRecordTypeId();
		List<Id> treatmentSiteIds = new List<Id>();
		List<Id> apheresisSiteIds = new List<Id>();
		List<Id> cryoSiteIds = new List<Id>();
		List<Id> SDIds = new List<Id>();
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
				if (trtSiteRecordTypeId.equals(site.RecordTypeId))
				{
					treatmentSiteIds.add(site.Id);
				}
				else if (aphSiteRecordTypeId.equals(site.RecordTypeId))
				{
					apheresisSiteIds.add(site.Id);
				}
				else if (cryoSiteRecordTypeId.equals(site.RecordTypeId))
				{
					cryoSiteIds.add(site.Id);
				}
				else
				{
					SDIds.add(site.Id);
				}
			}
		}
		update accountsToBeUpdated;
		List<Product2> productList = TestDataFactory.getProductsList('JNJ-4528', 3);
		insert productList;
		List<SiteProduct__c> siteProductsList = TestDataFactory.getSiteProducts(treatmentSiteIds, SDIds, productList);
		insert siteProductsList;
		insert contactList;
		List<Schema.Location> locationsList = TestDataFactory.getLocationRecords(TESTLOCATION, 3);
		insert locationsList;
		List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(cryoSiteIds, locationsList, 3);
		insert assLocList;
		List<Schema.AssociatedLocation> assLocListforTreatmentSites = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(treatmentSiteIds,locationsList,3);
		insert assLocListforTreatmentSites;
		system.assertNotEquals(NULL, assLocList[0].Id);
		List<Contact> businessContactsList = ((ContactsSelector) Application.Selector
				.newInstance(Contact.SObjectType))
				.selectAllByRecTypeDeveloperName(new Set<String> {INDUSTRIESBUSINESS});
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
		List<CareProgramEnrollee> CareProgramEnrollee = TestDataFactory.getCareProgramEnrolleeRecords(new Map<Id, Id>{accountsList[0].Id => careProgramRecord.Id});
		insert CareProgramEnrollee;

		List<CareProgramEnrolleeProduct> CareProgramEnrolleeProductList = TestDataFactory.getCareProgramEnrolleeProductRecords(new map<Id, Id> {CareProgramEnrollee[0].Id => CareProgramProductRecord.Id});
		insert CareProgramEnrolleeProductList;

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
		associatedContactsList = TestDataFactory.getAssociatedContactRelationsToInsert(contactIdList, conIdList, carTCoordinatorRole.Name, StaticConstants.contactRole, 2);
		insert associatedContactsList;

		List<HealthCloudGA__AccountAccountRelation__c> accRelationList =
				new List<HealthCloudGA__AccountAccountRelation__c>();
		accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(treatmentSiteIds, apheresisSiteIds, aphSiteRole.Id, 2));
		accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(apheresisSiteIds, cryoSiteIds, cryoSiteRole.Id, 2));

		insert accRelationList;
		system.assertNotEquals(NULL, accRelationList[0].Id);

		List<Case> caseList = TestDataFactory.getCareplanCasesList(conList);
		insert caseList;
		List<PatientServicesEnrollee__c> PSEList = new List<PatientServicesEnrollee__c>();
		for(Case Cse : caseList){
			PSEList.add(TestDataFactory.getPatientServicesEnrollee(cse.Id , cse.AccountId));
		}
		insert PSEList;

		List<Id> carePlanIdList = new List<Id>();
		carePlanIdList.addAll(sflib_ArrayUtils.pluckIdField(caseList, Case.Id));

		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = TestDataFactory.getGoalsForCaseIds(carePlanIdList);
		insert listOfGoals;

		List<Task> taskList = TestDataFactory.getTasksForGoalIds(listOfGoals);
		insert taskList;


		List<Account> cryoSiteAccountsList = new AccountsSelector().selectByDeveloperName(cryoSiteRecordTypeId);

		List<Order__c> ordersList = new OrdersSelector().selectOrdersByCarePlanId((new Map<Id, Case>(caseList)).keySet());
		List<Order__c> updatedOrders = new List<Order__c>();

		for (Order__c order : ordersList)
		{
			order.CryoSite__c = cryoSiteAccountsList[0].Id;
			order.Coordinator__c = contactList.get(0).Id;
			updatedOrders.add(order);
		}

		update updatedOrders;
	}

	public static Contact getSitePersonnelContact(String conName, Id accId)
	{
		Id recTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName().get('SitePersonnel').getRecordTypeId();
		Contact result = new Contact();
		result.AccountId = accId;
		result.FirstName = 'Test';
		result.LastName = conName;
		result.Phone = '1234567';
		result.Email = 'test@test.com';
		result.status__c = 'Active';
		result.SitePersona__c = Label.CARTCoordinator;
		result.RecordTypeId = recTypeId;

		return result;
	}
	
	public static Topic getTopic()
	{
		Topic result = new Topic();
		result.Name = 'TipicTest';
		return result;
	} 

	public static knowledge__kav getArticle()
	{
		knowledge__kav result = new knowledge__kav();
		result.URLName = 'Apex-Test-URLName';
		result.Title = 'Title';
		result.Summary = 'Summary';
		result.Language = 'en_US';
		result.ArticleSource__c = '1234';
		result.SubmissionCode__c = '3123';
		return result;
	}

	public static TopicAssignment getTopicAssignment(Id topicId, Id EntityId)
	{
		TopicAssignment result = new TopicAssignment();
		result.EntityId = EntityId;
		result.TopicId = topicId;
		return result;
	}

	@isTest
	public static void getSflibSettingsList()
	{
		List<sflib_Settings__c> sflibSettingsList = new List<sflib_Settings__c>();

		sflib_Settings.set(
				new Map<String, String>
				{
						'Number Of Business Days Excluded' => '2',
						'Number of Days For Reschedule' => '1'
				}
		);
	}
}
