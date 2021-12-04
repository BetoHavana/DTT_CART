public with sharing class PatientServicesEnrolleesService
{
	static final String ELIGIBLE = 'Eligible';
	static final String PATIENTSERVICEENROLLEEQUEUE = 'PatientServicesEnrolleeQueue';
	private static final String PatientServicesEnrolleeObject = 'PatientServicesEnrollee__c';

	public void createTasksForPatientServiceEnrollees(PatientServicesEnrollees patientServiceEnrolleees)
	{
		List<PatientServicesEnrollee__c> pseRecods = patientServiceEnrolleees.getRecords();

		if (pseRecods.isEmpty()) return;

		createTasksForPatientServiceEnrollees(pseRecods);
	}

	public void createTasksForPatientServiceEnrollees(List<PatientServicesEnrollee__c> pseRecords)
	{
		PatientServiceEnrolleeTaskConfigSelector pseSelector =
				(PatientServiceEnrolleeTaskConfigSelector) Application.Selector.newInstance(PatientServiceEnrolleeTaskConfig__mdt.SObjectType);

		Map<String, List<PatientServiceEnrolleeTaskConfig__mdt>> pseStatusAndTaskConfigInfo =
				pseSelector.selectActivePSEnrolleeTaskConfigInfoPerStatus();
		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType)).
				selectBusinessHoursByName(Label.BusinessHoursNameForPatientServiceEnrolleeTasks);

		if (pseRecords.isEmpty() || businessHours.isEmpty() || pseStatusAndTaskConfigInfo.isEmpty()) return;

		List<Task> tasksToCreate = ((TasksService) Application.Service.newInstance(TasksService.Class)).
				getTasksForPatientServiceEnrollee(pseRecords, pseStatusAndTaskConfigInfo, businessHours[0].Id);

		try
		{
			if (tasksToCreate.isEmpty()) return;

			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
			unitOfWork.registerNew(tasksToCreate);
			unitOfWork.commitWork();
		}
		catch (Exception exceptionWhileTaskCreation)
		{
			Application.logEntry.error(exceptionWhileTaskCreation);
		}
	}

	public List<PatientServicesEnrollee__c> getPatientServiceEnrolleeRecordsForCarePlans(List<Case> carePlans)
	{
		Set<Id> patientIds = new Set<Id>();
		patientIds=sflib_ArrayUtils.pluckIdField(carePlans, Case.AccountId);
		Map<Id,Account> patientsInfo = new Map<Id,Account>();
		patientsInfo = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectById(patientIds).getById();
		Map<Id,Contact> patientIdNCareGiverInfo = new Map<Id,Contact>();

		if(!patientsInfo.isEmpty())
		{
			patientIdNCareGiverInfo = ((AccountsService) Application.Service.newInstance(AccountsService.class)).
					getCareGiverInformationPerPatient(sflib_ArrayUtils.pluckIdField(patientsInfo.values(),Account.PersonContactId));
		}

		List<PatientServicesEnrollee__c> patientServiceEnrollees = new List<PatientServicesEnrollee__c>();
		PatientServicesEnrollee__c pse = new PatientServicesEnrollee__c();
		Id ownerIdForPSERecords = getPatientServiceEnrolleeRecsOwnerId();

		for(Case carePlan : carePlans)
		{
			pse = new PatientServicesEnrollee__c(CarePlan__c = carePlan.Id, OwnerId = ownerIdForPSERecords);
			setPatientInfo(pse,patientsInfo.get(carePlan.AccountId));
			setCaregiverInfo(pse,patientIdNCareGiverInfo.get(carePlan.AccountId));
			patientServiceEnrollees.add(pse);
		}

		return patientServiceEnrollees;
	}
	void setPatientInfo(PatientServicesEnrollee__c pse,Account patientInfo)
	{
		if (patientInfo == null) return;

		pse.Patient__c = patientInfo.Id;
	}

	void setCaregiverInfo(PatientServicesEnrollee__c pse,Contact careGiver)
	{
		if (careGiver == null) return;

		pse.CaregiverFirstName__c = careGiver.FirstName;
		pse.CaregiverMiddleName__c = careGiver.MiddleName;
		pse.CaregiverLastName__c = careGiver.LastName;
	}

	Id getPatientServiceEnrolleeRecsOwnerId() {
		List<Group> pseQueue = ((GroupsSelector) Application.Selector.newInstance(Group.SObjectType))
									.selectQueuesByDeveloperName(
									new Set<String>{PATIENTSERVICEENROLLEEQUEUE	});
		return pseQueue.isEmpty() ? UserInfo.getUserId() : pseQueue[0].Id ;
	}

	public void sendPatientServicesLetters(Map<String,Set<Id>> pseIdsByEmailTemplateDeveloperNames)
	{
		List<EmailTemplate> emailTemplateList = ((EmailTemplatesSelector) Application.Selector.newInstance(EmailTemplate.SObjectType))
												.selectAll();
		
		EmailTemplates emailTemplates = (EmailTemplates) Application.Domain.newInstance(emailTemplateList);
		
		PatientServicesEnrolleesLetterService pseLetterService = new PatientServicesEnrolleesLetterService(
															emailTemplates.getEmailTemplatesByDeveloperName(), 
															pseIdsByEmailTemplateDeveloperNames);
		System.enqueueJob(pseLetterService);
	}

	public static String getPDFNameByDevelopername(String developerName)
	{
		String PDFName = '';

		if(developerName.equalsIgnoreCase(Label.PSETemplateForThePatientDevName))
		{
			PDFName = Label.PatientServicesEligibilityLetterPatient;
		}
		else if(developerName.equalsIgnoreCase(Label.PSETemplateForTheCARTCoordinatorDevName))
		{
			PDFName = Label.PatientServicesEligibilityLetterCARTCoordinator;
		}
		else if(developerName.equalsIgnoreCase(Label.PSITemplateForThePatientDevName))
		{
			PDFName = Label.PatientServicesIneligibilityLetterPatient;
		}
		else if(developerName.equalsIgnoreCase(Label.PSITemplateForTheCARTCoordinatorDevName))
		{
			PDFName = Label.PatientServicesIneligibilityLetterCARTCoordinator;
		}

		return PDFName += '.pdf';
	}

	public Id getPatientIdForEmailTemplate(Id pseId)
	{
		List<PatientServicesEnrollee__c> pseList = ((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SObjectType))
				.selectById(new Set<Id>{pseId});

		return pseList[0].Patient__c;
	}

	public static Map<Id, PatientServicesEnrollee__c> fetchPatientServicesStatus(Set<Id> carePlanIds)
	{
		return new PatientServicesEnrollees(((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SObjectType))
				.selectByCarePlanId(carePlanIds)).getPatientServicesByCareplanId();
	}

	public List<HealthCloudGA__ContactContactRelation__c>  getRelatedContactForEmailTemplate(Id patientId)
	{
		return ((ContactContactRelationSelector) Application.Selector.newInstance(HealthCloudGA__ContactContactRelation__c.SObjectType))
				.selectAssociatedContactsByPatientAndSitePersona(new Set<Id>{patientId},new Set<String>{Label.CARTCoordinator});
	}

	public List<AssociatedLocation>  getTreatmentSiteForEmailTemplate(List<HealthCloudGA__ContactContactRelation__c> contactContactRelationsList)
	{
		return ((AssociatedLocationsSelector) Application.Selector.newInstance(AssociatedLocation.SObjectType))
            	.getAddressesForSites(new Set<Id> {contactContactRelationsList[0].HealthCloudGA__Contact__r.AccountId});
	}

	public void grantAccessToPublicGroups(PatientServicesEnrollees pse)
	{
		fflib_ISObjectUnitOfWork elevatedGroupUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToRelatedPublicGroups(elevatedGroupUnitOfWork, pse.getRecords());
		elevatedGroupUnitOfWork.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<PatientServicesEnrollee__c> pseList)
    {
        Map<Id, Id> pseIdByAccountIdToCloneMap = new Map<Id, Id>();
        
        for(PatientServicesEnrollee__c pse : pseList)
        {
            pseIdByAccountIdToCloneMap.put(pse.Id, pse.Patient__c);
        }

        if(! pseIdByAccountIdToCloneMap.isEmpty())
        {
            new RecordsSharingService().cloneSharingSettings(uow, pseIdByAccountIdToCloneMap, AccountShare.SObjectType);
        }
	}
	
	public void fetchNotificationAlertDetails(List<PatientServicesEnrollee__c> changedRecords, List<PatientServicesEnrollee__c> existingRecords, Set<Schema.SObjectField> sObjectFieldSet)
	{
		List<String> fieldschema = new List<String>();
		for (Schema.SObjectField sfield : sObjectFieldSet)
		{
			fieldschema.add('' + sfield);
		}
		NotificationEngineSelector notificationEngineSelector = (NotificationEngineSelector) Application.Selector.newInstance(NotificationEngine__mdt.SObjectType);
		List<NotificationEngine__mdt> notificationEngineList = new List<NotificationEngine__mdt>();
		notificationEngineList =
				notificationEngineSelector.selectNotificationAlert(PatientServicesEnrolleeObject,
						fieldschema, existingRecords[0].PatientServicesStatus__c,
						changedRecords[0].PatientServicesStatus__c);

		if (notificationEngineList.isEmpty()) return ;

		List<HealthCloudGA__ContactContactRelation__c> cartCoordinatorContactRecord = getRelatedContactForEmailTemplate(changedRecords[0].Patient__c);

		UsersSelector usersSelectorInstance = (UsersSelector) Application.Selector.newInstance(User.SObjectType);
		List<User> cartCoordinatorList = usersSelectorInstance.selectByContactId(new Set<Id> {cartCoordinatorContactRecord[0].HealthCloudGA__Contact__c});
		if (cartCoordinatorList.isEmpty()) return ;

		AccountsSelector accountsSelectorInstance = (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
		List<Account> patientsList = (List<Account>) accountsSelectorInstance.selectById(new Set<Id> {changedRecords[0].Patient__c}).getRecords();

		createNotificationAlert(patientsList, notificationEngineList, cartCoordinatorList);
	}

	public void createNotificationAlert(List<Account> patientsList, List<NotificationEngine__mdt> notificationEngineList, List<User> cartCoordinatorList)
	{
		NotificationsService notificationsServiceInstance = (NotificationsService) Application.Service.newInstance(NotificationsService.class);
		notificationsServiceInstance.createNotificationRecords(patientsList, notificationEngineList, cartCoordinatorList, null);
	}
	
	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void eventPublish(List<SObject> objList)
		{
			//not implemented
		}

		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}
			Database.emptyRecycleBin(objList);
		}

	}

}