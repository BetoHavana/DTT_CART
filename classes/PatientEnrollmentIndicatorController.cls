public with sharing class PatientEnrollmentIndicatorController
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String CONTACTROLERECORDTYPEDEVELOPERNAME = 'ContactRole';
	public static final String PATIENT = 'Patient';
	public static final String PHYSICIAN = 'Physician';
	public static final String TREATMENTSITE = 'Treatment Site';

	private static CarePlanGoalsService CarePlanGoalsService
	{
		get
		{
			if (null == CarePlanGoalsService)
			{
				CarePlanGoalsService = (CarePlanGoalsService) Application.Service.newInstance(CarePlanGoalsService.class);
			}
			return CarePlanGoalsService;
		}
		set;
	}

	private static CareProgramEnrolleesService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (CareProgramEnrolleesService) Application.Service.newInstance(CareProgramEnrolleesService.class);
			}
			return Service;
		}
		set;
	}

	private static CareProgramEnrolleeProductsService CareProgramEnrolleeProductsService
	{
		get
		{
			if (null == CareProgramEnrolleeProductsService)
			{
				CareProgramEnrolleeProductsService = (CareProgramEnrolleeProductsService) Application.Service.newInstance(CareProgramEnrolleeProductsService.class);
			}
			return CareProgramEnrolleeProductsService;
		}
		set;
	}

	private static CasesService CasesService
	{
		get
		{
			if (null == CasesService)
			{
				CasesService = (CasesService) Application.Service.newInstance(CasesService.class);
			}
			return CasesService;
		}
		set;
	}

	private static CaseSharesService CaseSharesService
	{
		get
		{
			if (null == CaseSharesService)
			{
				CaseSharesService = (CaseSharesService) Application.Service.newInstance(CaseSharesService.class);
			}
			return CaseSharesService;
		}
		set;
	}

	private static TasksService TasksService
	{
		get
		{
			if (null == TasksService)
			{
				TasksService = (TasksService) Application.Service.newInstance(TasksService.class);
			}
			return TasksService;
		}
		set;
	}

	@AuraEnabled(cacheable=true)
	public static String getStepDetails()
	{
		try
		{
			List<PatientEnrollmentSteps__mdt> formFields =
					((PatientEnrollmentStepsSelector) Application.Selector.newInstance(PatientEnrollmentSteps__mdt.SObjectType))
							.selectPatients();
			return JSON.serialize(formFields);
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}

	}

	@AuraEnabled(cacheable=true)
	public static List<LookupSearchResult> fetchPhysicianCoordinator(Id accountId)
	{
		try
		{
			Set<String> personas = new Set<String>();
			personas.add(PHYSICIAN);
			personas.add(CARTCOORDINATOR);
			List<AccountContactRelation> physicians = ((AccountContactRelationsSelector) Application.Selector.newInstance(AccountContactRelation.SObjectType))
					.selectByAccountIdAndPersonas(accountId, personas);
			List<LookupSearchResult> results = new List<LookupSearchResult>();
			for (AccountContactRelation objPhysician : physicians)
			{
				results.add(
						new LookupSearchResult(
								objPhysician.Id,
								'AccountContactRelation',
								'standard:contact',
								objPhysician.Contact.Name,
								objPhysician.Contact.SitePersona__c,
								objPhysician.ContactId
						)
				);
			}
			return results;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static Account createEnrollment(String strPatientJSON, String strPhysicianJSON, String strPatientServiceProgramJSON)
	{
		Account patient = new Account();
		try
		{
			if (strPatientJSON != '' && strPatientJSON != '{}')
			{
				patient = createPersonAccountWithLocation(strPatientJSON, StaticConstants.PatientRecordTypeDeveloperName);
			}

			if (patient.Id != null)
			{
				createEnrollee(patient);
				createPatientSiteRelation(patient,strPatientJSON);
				createContactContactRelationForCART(patient);
				if (strPhysicianJSON != '' && strPhysicianJSON != '{}')
				{
					createContactContactRelationForPhysician(patient, strPhysicianJSON);
				}
				createCarePlan(patient,strPatientServiceProgramJSON);
			}

		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			throw auraHandledException;
		}
		return patient;
	}

	public static Account createPersonAccountWithLocation(String strJSON, String strRecordTypeName)
	{
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(strJSON);
		Account objAccount = new Account();
		if (obj.get(System.Label.FirstName) != '')
		{
			Id objRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(strRecordTypeName).getRecordTypeId();
			objAccount.FirstName = String.valueOf(obj.get(System.Label.FirstName));
			objAccount.LastName = String.valueOf(obj.get(System.Label.LastName));
			objAccount.RecordTypeId = objRecordTypeId;
			objAccount.PersonEmail = String.valueOf(obj.get(System.Label.EmailAddress));
			objAccount.Phone = String.valueOf(obj.get(System.Label.PrimaryContactNumber));
			objAccount.PrimaryContactNumberType__c = String.valueOf(obj.get(System.Label.PrimaryPhoneNumberType));
			objAccount.PreferredMethodOfCommunication__c = String.valueOf(obj.get(System.Label.PreferredMethodofCommunication));
			objAccount.Salutation = String.valueOf(obj.get(System.Label.Salutation));
			objAccount.MiddleName = String.valueOf(obj.get(System.Label.MI));

			if (obj.get(System.Label.DateofBirth) != null && obj.get(System.Label.DateofBirth) != '')
			{
				String DOB = String.valueOf(obj.get(System.Label.DateofBirth));
				List<String> elements = DOB.split('-');
				String PersonBirthDate = elements[1] + '/' + elements[2] + '/' + elements[0];
				objAccount.PersonBirthdate = date.parse(PersonBirthDate);
			}

			objAccount.HealthCloudGA__Gender__pc = String.valueOf(obj.get(System.Label.Gender));
			fflib_ISObjectUnitOfWork accountUnitOfWork = Application.UnitOfWork.newInstance();
			accountUnitOfWork.registerNew(objAccount);
			accountUnitOfWork.commitWork();

		}
		return objAccount;
	}

	public static void createPatientSiteRelation(Account objAccount, String strPatientJSON)
	{
		Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(strPatientJSON);
		Id currentUserId = UserInfo.getUserId();
		List<User> lstUsers = ((UsersSelector) Application.Selector.newInstance(User.SObjectType)).selectByIds(new Set<Id> {currentUserId});
		if (lstUsers != null && lstUsers[0].AccountId != null)
		{
			AccountContactRelation accountContactRelation = new AccountContactRelation ();
			accountContactRelation.AccountId = lstUsers[0].AccountId;
			accountContactRelation.Roles = TREATMENTSITE;
			accountContactRelation.MedicalRecordNumber__c = String.valueOf(obj.get(System.Label.MedicalRecordNumber));
			List<Account> accounts = new AccountsSelector().selectContactsByAccountId(new Set<Id> {objAccount.Id});
			if (accounts != null && !accounts.isEmpty() && accounts[0].isPersonAccount && accounts[0].contacts != null && !accounts[0].contacts.isEmpty())
			{
				accountContactRelation.ContactId = accounts[0].contacts[0].Id;
			}
			fflib_ISObjectUnitOfWork accConRelUnitOfWork = Application.UnitOfWork.newInstance();
			accConRelUnitOfWork.registerNew(accountContactRelation);
			accConRelUnitOfWork.commitWork();
		}
	}

	@AuraEnabled(cacheable=true)
	public static String getRelationshipToPatientValues()
	{
		try
		{
			List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles = ((ReciprocalRoleSelector) Application.Selector
					.newInstance(HealthCloudGA__ReciprocalRole__c.SObjectType)).selectAll();
			return JSON.serialize(reciprocalRoles);
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static void createEnrollee(Account objAccount)
	{
		CareProgramsSelector elevatedSelector = (CareProgramsSelector) Application.ElevatedSelector.newInstance(CareProgram.SObjectType);
		List<CareProgram> lstCarePrograms = (List<CareProgram>) elevatedSelector.selectAll();
		if (lstCarePrograms.isEmpty()) return;
		Map<Account, CareProgram> careProgramsByAccounts = new Map<Account, CareProgram>();
		careProgramsByAccounts.put(objAccount, lstCarePrograms[0]);
		List<CareProgramEnrollee> enrollees = Service.createCareProgramEnrollee(careProgramsByAccounts);
		CareProgramEnrolleeProductsService.createCareProgramEnrolleeProduct(enrollees);
	}

	public static void createContactContactRelationForPhysician(Account objAccount, String strPhysician)
	{
		List<Object> obj = (List<Object>) JSON.deserializeUntyped(strPhysician);
		if (!obj.isEmpty())
		{
			List<Account> accounts = new AccountsSelector().selectContactsByAccountId(new Set<Id> {objAccount.Id});
			String objPhysician = JSON.serialize(obj[0]);
			Map<String, Object> objPhysicianMap = (Map<String, Object>) JSON.deserializeUntyped(objPhysician);
			HealthCloudGA__ContactContactRelation__c conRel = new HealthCloudGA__ContactContactRelation__c();
			conRel.HealthCloudGA__Contact__c = Id.valueOf((String) objPhysicianMap.get('place_id'));
			if (accounts != null && !accounts.isEmpty() && accounts[0].isPersonAccount && accounts[0].contacts != null && !accounts[0].contacts.isEmpty())
			{
				conRel.HealthCloudGA__RelatedContact__c = accounts[0].contacts[0].Id;
			}
			List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles = ((ReciprocalRoleSelector) Application.Selector.newInstance(HealthCloudGA__ReciprocalRole__c.SObjectType)).selectByNameAndInverseRole(PHYSICIAN, PATIENT, CONTACTROLERECORDTYPEDEVELOPERNAME);
			if (reciprocalRoles.isEmpty()) return;
			conRel.HealthCloudGA__Role__c = reciprocalRoles[0].Id;
			fflib_ISObjectUnitOfWork conRelUnitOfWork = Application.UnitOfWork.newInstance();
			conRelUnitOfWork.registerNew(conRel);
			conRelUnitOfWork.commitWork();
		}
	}

	public static void createContactContactRelationForCART(Account objAccount)
	{
		Id currentUserId = UserInfo.getUserId();
		List<User> lstUsers = ((UsersSelector) Application.Selector.newInstance(User.SObjectType)).selectByIds(new Set<Id> {currentUserId});
		if (lstUsers != null && lstUsers[0].ContactId != null)
		{
			HealthCloudGA__ContactContactRelation__c conRel = new HealthCloudGA__ContactContactRelation__c();
			conRel.HealthCloudGA__Contact__c = lstUsers[0].ContactId;
			List<Account> accounts = new AccountsSelector().selectContactsByAccountId(new Set<Id> {objAccount.Id});
			if (accounts != null && !accounts.isEmpty() && accounts[0].isPersonAccount && accounts[0].contacts != null && !accounts[0].contacts.isEmpty())
			{
				conRel.HealthCloudGA__RelatedContact__c = accounts[0].contacts[0].Id;
			}
			List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles = ((ReciprocalRoleSelector) Application.Selector.newInstance(HealthCloudGA__ReciprocalRole__c.SObjectType)).selectByNameAndInverseRole(CARTCOORDINATOR, PATIENT, CONTACTROLERECORDTYPEDEVELOPERNAME);
			if (reciprocalRoles.isEmpty()) return;
			conRel.HealthCloudGA__Role__c = reciprocalRoles[0].Id;
			fflib_ISObjectUnitOfWork conRelUnitOfWork = Application.UnitOfWork.newInstance();
			conRelUnitOfWork.registerNew(conRel);
			conRelUnitOfWork.commitWork();
		}
	}


	@AuraEnabled
	public static List<Account> fetchDuplicatePatients(String patientJson)
	{
		try
		{
			Map<String, Object> obj = (Map<String, Object>) JSON.deserializeUntyped(patientJson);
			List<Account> patientAccounts = new List<Account>();
			if (obj.get(System.Label.FirstName) != '')
			{
				String firstName = String.valueOf(obj.get(System.Label.FirstName));
				String gender = String.valueOf(obj.get(System.Label.Gender));
				String lastName = String.valueOf(obj.get(System.Label.LastName));
				String middleName = String.valueOf(obj.get(System.Label.MI));
				Date personBirthdateVal;
				if (obj.get(System.Label.DateofBirth) != null && obj.get(System.Label.DateofBirth) != '')
				{
					String DOB = String.valueOf(obj.get(System.Label.DateofBirth));
					List<String> elements = DOB.split('-');
					personBirthdateVal = date.newInstance(Integer.valueOf(elements[0]), Integer.valueOf(elements[1]), Integer.valueOf(elements[2]));
				}
				patientAccounts = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectByNameGenderAndDateOfBirth(firstName, middleName, lastName, gender, personBirthdateVal);
			}
			return patientAccounts;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static void createCarePlan(Account patient, String strPatientServiceProgram)
	{
		Boolean isPatientServiceOpted = Boolean.valueOf(strPatientServiceProgram);
		List<HealthCloudGA__CarePlanTemplate__c> lstCarePlanTemplates = ((CarePlanTemplatesSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanTemplate__c.SObjectType)).selectActive();
		if (lstCarePlanTemplates.isEmpty()) return;

		Map<Account, HealthCloudGA__CarePlanTemplate__c> carePlanTemplatesByAccounts = new Map<Account, HealthCloudGA__CarePlanTemplate__c>();
		carePlanTemplatesByAccounts.put(patient, lstCarePlanTemplates[0]);

		Id currentUserId = UserInfo.getUserId();
		List<User> lstUsers = ((UsersSelector) Application.Selector.newInstance(User.SObjectType)).selectByIds(new Set<Id> {currentUserId});
		if (lstUsers == null || lstUsers[0].ContactId == null) return;

		Map<Account, User> cartCoordinatorByPatient = new Map<Account, User>();
		cartCoordinatorByPatient.put(patient, lstUsers[0]);

		Map<Account, Boolean> isPatientServiceOptedByAccount = new Map<Account, Boolean>();
		isPatientServiceOptedByAccount.put(patient, isPatientServiceOpted);

		List<Case> caseList = CasesService.elevatedCreateCarePlan(carePlanTemplatesByAccounts, cartCoordinatorByPatient, isPatientServiceOptedByAccount);
		if (caseList.isEmpty()) return;
		createCarePlanGoalsAndTasks(caseList, lstCarePlanTemplates[0]);
		createCarePlanShareRecordForTreatmentSitesPublicGroup(caseList);
	}

	public static void createCarePlanGoalsAndTasks(List<Case> lstCases, HealthCloudGA__CarePlanTemplate__c carePlanTemplate)
	{
		List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoals =
				((CarePlanTemplateGoalsSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanTemplateGoal__c.SObjectType))
						.selectByCarePlanTemplateIds(new Set<Id> {carePlanTemplate.Id});
		if (carePlanTemplateGoals.isEmpty()) return;

		Map<Case, HealthCloudGA__CarePlanTemplate__c> carePlanTemplateByCases = new Map<Case, HealthCloudGA__CarePlanTemplate__c>();
		carePlanTemplateByCases.put(lstCases[0], carePlanTemplate);

		List<HealthCloudGA__CarePlanGoal__c> lstCarePlanGoals = CarePlanGoalsService.elevatedCreateCarePlanGoals(carePlanTemplateByCases, carePlanTemplateGoals);
		createCarePlanTasks(carePlanTemplateGoals, lstCarePlanGoals);
	}

	public static void createCarePlanTasks(List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoals, List<HealthCloudGA__CarePlanGoal__c> lstCarePlanGoals)
	{
		TasksService.elevatedCreateCarePlanTasks(carePlanTemplateGoals, lstCarePlanGoals);
	}

	public static void createCarePlanShareRecordForTreatmentSitesPublicGroup(List<Case> caseList)
	{
		CaseSharesService.createCaseShareRecordForAccountsPublicGroup(caseList);
	}
}
