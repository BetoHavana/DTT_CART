public with sharing class PatientServicesEnrollees extends sflib_SObjectDomain
{
	static final String INELIGIBLE = 'Ineligible';
	static final String ELIGIBLE = 'Eligible';

	public Type getType()
	{
		return PatientServicesEnrollees.Class;
	}

	public PatientServicesEnrollees(List<PatientServicesEnrollee__c> records)
	{
		super(records, PatientServicesEnrollee__c.SObjectType);
	}

	private PatientServicesEnrolleesService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (PatientServicesEnrolleesService) Application.Service.newInstance(PatientServicesEnrolleesService.class);
            }
            return Service;
        }
        set;
    }

	public override void onAfterInsert()
	{
		createTasksForPatientServiceEnrollees();
		grantAccessToPublicGroups(Records);
	}

	public override void onBeforeUpdate(Map<Id, Sobject> existingRecords)
	{
		onChangedFieldsCreateRelevantTasks();
	}

    public override void onAfterUpdate(Map<Id, Sobject> existingRecords)
    {
		sendPatientServicesEnrolleesLetters();
	    onPatientServicesEligibility(existingRecords);
	    onChangedFieldsCarePlan();
    }

	public void onChangedFieldsCarePlan()
	{
		List<PatientServicesEnrollee__c> cpChangedRecords = (List<PatientServicesEnrollee__c>) getChangedRecords(new Set<Schema.SObjectField>{
															PatientServicesEnrollee__c.CarePlan__c});
		if (cpChangedRecords.isEmpty())
		{
			return;
		}
		grantAccessToPublicGroups(cpChangedRecords);
	}
	
	public void onPatientServicesEligibility(Map<Id, SObject> existingRecords)
	{
		Set<Schema.SObjectField> sObjectField = new Set<Schema.SObjectField> {PatientServicesEnrollee__c.PatientServicesStatus__c};
		List<SObject> changedRecords = getChangedRecords(sObjectField);
		if (changedRecords.isEmpty()) return ;
		fetchNotificationAlertDetails(changedRecords, existingRecords.values(), sObjectField);
	}

	public void fetchNotificationAlertDetails(List<SObject> changedRecords, List<SObject> existingRecords, Set<Schema.SObjectField> sObjectField)
	{
		Service.fetchNotificationAlertDetails((List<PatientServicesEnrollee__c>)
				new sflib_SObjects(changedRecords).getSObjects(),
				(List<PatientServicesEnrollee__c>) new sflib_SObjects(existingRecords).getSObjects(), sObjectField);
	}

	public void onChangedFieldsCreateRelevantTasks()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerTaskCreation());
		if (changedRecords.isEmpty()) return;
		new PatientServicesEnrollees(changedRecords).createTasksForPatientServiceEnrollees();
	}

	Set<Schema.SObjectField> fieldsToTriggerTaskCreation()
	{
		return new Set<Schema.SObjectField> {PatientServicesEnrollee__c.PatientServicesStatus__c};
	}

	public void createTasksForPatientServiceEnrollees()
	{
		PatientServicesEnrolleesService service = (PatientServicesEnrolleesService) Application.Service
				.newInstance(PatientServicesEnrolleesService.class);
		service.createTasksForPatientServiceEnrollees(selectPSESWithPatientServiceStatus());
	}

	public PatientServicesEnrollees selectPSESWithPatientServiceStatus()
	{
		List<PatientServicesEnrollee__c> psesWithPSStatus = (List<PatientServicesEnrollee__c>) new sflib_SObjects(Records)
				.filter(new sflib_Criteria()
						.notEqualTo(PatientServicesEnrollee__c.PatientServicesStatus__c, null))
				.getSobjects();
		return new PatientServicesEnrollees(psesWithPSStatus);
	}

	public Class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new PatientServicesEnrollees(sObjectList);
		}
		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new PatientServicesEnrollees(sObjectList);
		}
	}

	public void sendPatientServicesEnrolleesLetters()
	{
		List<PatientServicesEnrollee__c> pseChangedRecords = getChangedRecords(new Set<Schema.SObjectField>{
																PatientServicesEnrollee__c.PatientServicesStatus__c});
		
		Set<Id> pseEligibles = getPatientServicesEnrolleesByStatus(pseChangedRecords, ELIGIBLE);
		Set<Id> pseIneligibles = getPatientServicesEnrolleesByStatus(pseChangedRecords, INELIGIBLE);

		Service.sendPatientServicesLetters(new Map<String,Set<Id>>{
			Label.PSETemplateForTheCARTCoordinatorDevName => pseEligibles,
			Label.PSETemplateForThePatientDevName => pseEligibles,
			Label.PSITemplateForTheCARTCoordinatorDevName => pseIneligibles,
			Label.PSITemplateForThePatientDevName => pseIneligibles
		});
	}

	public Set<Id> getPatientServicesEnrolleesByStatus(List<PatientServicesEnrollee__c> pseList, String status)
	{
		Set<Id> pseIds = new Set<Id>();

		for(PatientServicesEnrollee__c pse : pseList)
		{
			if(pse.PatientServicesStatus__c.equalsIgnoreCase(status))
			{
				pseIds.add(PSE.Id);
			}
		}

		return pseIds;
	}

	public Map<Id, PatientServicesEnrollee__c> getPatientServicesByCareplanId()
	{
		Map<Id, PatientServicesEnrollee__c> patientServicesEnrolleeByCarePlanIdMap = new Map<Id, PatientServicesEnrollee__c>();
		for (PatientServicesEnrollee__c record : (List<PatientServicesEnrollee__c>) records)
		{
			if (record.CarePlan__c != null)
			{
				patientServicesEnrolleeByCarePlanIdMap.put(record.CarePlan__c, record);
			}
		}
		return patientServicesEnrolleeByCarePlanIdMap;
	}
	
	public void grantAccessToPublicGroups(List<PatientServicesEnrollee__c> pseList)
	{
		Service.grantAccessToPublicGroups(new PatientServicesEnrollees(pseList));
	}
    
}