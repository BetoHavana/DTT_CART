public with sharing class Cases extends sflib_SObjectDomain
{

	static final Id CAREPLANRECORDTYPEID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('CarePlan').getRecordTypeId();
	static final String CLOSEDORDERTOBECANCELLEDSTATUS = 'Closed - Order to be Cancelled';
	static final String STATUSFIELD = Case.Status.getDescribe().getName();
	static final String SPACE = ' ';

	public Type getType()
	{
		return Cases.class;
	}

	private CasesService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (CasesService) Application.Service.newInstance(CasesService.class);
			}
			return Service;
		}
		set;
	}

	public Cases(List<Case> records)
	{
		super(records, Schema.Case.SObjectType);
	}

    public Set<Id> getContactIds()
    {
        return sflib_ArrayUtils.pluckIdField(Records, Case.ContactId);
    }

	public Set<Id> getAccountIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, Case.AccountId);
	}

    public Set<Id> getTreatmentSiteIds()
    {
        return sflib_ArrayUtils.pluckIdField(Records, Case.TreatmentSite__c);
    }

	public Map<Id, Case> getCasesByAccountId()
	{
		Map<Id, Case> caseByAccountIdMap = new Map<Id, Case>();
		for (Case record : (List<Case>) records)
		{
			if (record.AccountId != null)
			{
				caseByAccountIdMap.put(record.AccountId, record);
			}
		}
		return caseByAccountIdMap;
	}

	public Cases selectWithContactId()
	{
		List<Case> casesWithContacts = new List<Case>();
		for (Case record : (List<Case>) records)
		{
			if (record.ContactId != null)
			{
				casesWithContacts.add(record);
			}
		}
		return new Cases(casesWithContacts);
	}

	public Map<Id, Id> getContactIdById()
	{
		return new sflib_SObjects(records).asIdFieldByIdField(Case.Id, Case.ContactId);
	}

	public override void onBeforeInsert()
	{
		preventCarePlanCreationIfPatientIsntEnrolledInCP();
		preventDuplicateCarePlanCreation();
		setSitePersonnelToFindSiteInfo();
		Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
		if (carePlan.getRecords().isEmpty()) return;
		new Cases(carePlan.getRecords()).setCareplanSubject();
	}

	public void preventCarePlanCreationIfPatientIsntEnrolledInCP()
	{
		CareProgramEnrolleesService cpeService = (CareProgramEnrolleesService) Application.Service
											        .newInstance(CareProgramEnrolleesService.class);
		Map<Id, CareProgramEnrollee> patientIdAndCPEInfo = cpeService.getPatientAndCareProgramEnrolleeInfo(
				                                                sflib_ArrayUtils.pluckIdField(Records, Case.AccountId));
		throwErrorIfPatientIsntEnrolledInCareProgram(patientIdAndCPEInfo);
	}

	void throwErrorIfPatientIsntEnrolledInCareProgram(Map<Id, SObject> patientIdAndCPEInfo)
	{
		String patientNeedsToBeEnrolledInCPEFirst = Label.PatientNeedsToBeEnrolledIntoCareProgramBeforeCarePlanErrorMessage;
		Boolean patientCPEInfoIsEmpty = patientIdAndCPEInfo == null || patientIdAndCPEInfo.isEmpty();
		for (Case carePlan : (List<Case> ) Records)
		{
			if (checkIsCaseOfCarePlanRecType(carePlan.RecordTypeId) && (patientCPEInfoIsEmpty || !patientIdAndCPEInfo.containsKey(carePlan.AccountId)))
			{
				addSObjectError(carePlan, patientNeedsToBeEnrolledInCPEFirst);
			}
		}
	}

	public void preventDuplicateCarePlanCreation()
	{
		Map<Id, List<SObject>> patientIdAndCarePlanInfo = Service.getPatientIdAndActiveCarePlan(
				sflib_ArrayUtils.pluckIdField(Records, Case.AccountId),
				new Set<Id>{CAREPLANRECORDTYPEID});
		if (patientIdAndCarePlanInfo == null || patientIdAndCarePlanInfo.isEmpty())
		{
			return ;
		}
		throwErrorForDuplicateCarePlans(patientIdAndCarePlanInfo);
	}

	void throwErrorForDuplicateCarePlans(Map<Id, List<SObject>> patientIdAndCarePlanInfo)
	{
		String cannotCreateDuplicateCarePlanErrorMessage = Label.PatientIsAlreadyEnrolledInCarePlanErrMessage;

		for (Case carePlan : (List<Case>) Records)
		{
			if (checkIsCaseOfCarePlanRecType(carePlan.RecordTypeId) && patientIdAndCarePlanInfo.containsKey(carePlan.AccountId))
			{
				addSObjectError(carePlan, cannotCreateDuplicateCarePlanErrorMessage);
			}
		}
	}

	Boolean checkIsCaseOfCarePlanRecType(Id caseRecordTypeId)
	{
		return CAREPLANRECORDTYPEID == caseRecordTypeId ;
	}

	void addSObjectError(SObject sObjectRecord, String errorMessage)
	{
		sObjectRecord.addError(errorMessage);
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		onChangedFieldsCreateRelevantPSEs();
		Map<Id, Set<String>> caseNChangedFields = new Utility().getChangedFieldsPerRecord(fieldsToCompareWhetherChanged(), ExistingRecords, Records);
		if (caseNChangedFields == null || caseNChangedFields.isEmpty()) return;
		setSitePersonnelToFindSiteInfo();
	}

	public override void onAfterInsert()
	{
		createCaseTeamMembers();
		createOrderForCarePlanCase();
		createPSESForCarePlans();
		grantAccessToPublicGroups();
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		shareCasesOnChangedRecordTypeToCarePlan();
        onApheresisScheduled(existingRecords);
		onChangedFieldsUpdateOrder();
		Map<Id, Set<String>> caseNChangedFields = new Utility().getChangedFieldsPerRecord(fieldsToCompareWhetherChanged(), ExistingRecords, Records);
		if (caseNChangedFields == null || caseNChangedFields.isEmpty()) return;
		elevatedCreateCaseTeamMembers();
		elevatedCreateOrderForCarePlanCase();
	}

	public void onApheresisScheduled(Map<Id, SObject> existingRecords)
	{
		Set<Schema.SObjectField> sObjectField = new Set<Schema.SObjectField> {Case.Status};
		List<SObject> changedRecords = getChangedRecords(sObjectField);
		if (changedRecords.isEmpty()) return ;
		fetchNotificationAlertDetails(changedRecords, existingRecords.values(), sObjectField);
	}

	public void fetchNotificationAlertDetails(List<SObject> changedRecords, List<SObject> existingRecords, Set<Schema.SObjectField> sObjectField)
	{
		Service.fetchNotificationAlertDetails((List<Case>)
				new sflib_SObjects(changedRecords).getSObjects(), (List<Case>) new sflib_SObjects(existingRecords).getSObjects(), sObjectField);
	}

	public Cases selectCasesByRecordTypeDeveloperName(Set<String> recordTypeDeveloperNames)
	{
		List<Case> result = new List<Case>();

        Map<Id, String> recordTypeIdByDevNameMap = sflib_RecordTypesSelector.selectRecordTypeByDeveloperNames(Case.SObjectType, recordTypeDeveloperNames);

		for (Case caseInstance : (List<Case>) records)
		{
            if(recordTypeIdByDevNameMap.containsKey(caseInstance.RecordTypeId))
            {
				result.add(caseInstance);
            }
		}
		return new Cases(result);
	}

	public void setCareplanSubject()
	{
		try
		{
			Service.updateSubjectForCareplanCase(this);
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	public void updateSubject(Map<String, String> accNameMap, Map<Id, String> productNameMap)
	{
		for (Case casObj : (List<Case>) Records)
		{
			casObj.Subject = productNameMap.get(casObj.AccountId) + SPACE + label.CareplanSubject + SPACE + accNameMap.get(casObj.AccountId);
		}
	}

	public void setSitePersonnelToFindSiteInfo()
	{
        try
        {
            Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
        	Service.updateSitesReference(carePlan.getRecords());
        }
        catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	public void createCaseTeamMembers()
	{
        try
        {
            Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
        	Service.addCareTeamMember(carePlan.getRecords());
        }
        catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	public void createOrderForCarePlanCase()
	{
        try
        {
            Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
        	Service.insertOrderForCareplanCase(carePlan.getRecords());
        }
        catch(Exception e)
		{
			Application.logEntry.error(e);
		}
	}


	Set<Schema.SObjectField> fieldsToTriggerOrderUpdate()
	{
		return new Set<Schema.SObjectField> {Case.Status};
	}

	public void onChangedFieldsUpdateOrder()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerOrderUpdate());
		if (changedRecords.isEmpty()) return;
		new Cases(changedRecords).selectCasesByClosedOrderToBeCancelledStatus().updateOrderCancellationInfo();
	}

	public void shareCasesOnChangedRecordTypeToCarePlan()
	{
		List<SObject> caregapToCarePlanConvertedCases = getChangedRecords(new Set<Schema.SObjectField> {Case.RecordTypeId});
		if (caregapToCarePlanConvertedCases.isEmpty()) return;
		new Cases(caregapToCarePlanConvertedCases).grantAccessToPublicGroups();
	}

	Public void onChangedFieldsCreateRelevantPSEs()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerPSECreation());
		if (changedRecords.isEmpty()) return;
		new Cases(changedRecords).createPSESForCarePlans();
	}

	Set<Schema.SObjectField> fieldsToTriggerPSECreation()
	{
		return new Set<Schema.SObjectField> {Case.BeginPatientSupportEligibilityCheck__c};
	}

	Public void createPSESForCarePlans()
	{
		CasesService casesService = (CasesService) Application.Service.newInstance(CasesService.class);
		casesService.createPatientServiceEnrolleesForCarePlans(selectCarePlansWithPSELigibility());
	}

	Public Cases selectCarePlansWithPSELigibility()
	{
		List<Case> carePlansWithPSEEligibility = (List<Case>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.equalTo(Case.BeginPatientSupportEligibilityCheck__c, true)).getSobjects();
		return new Cases(carePlansWithPSEEligibility);
	}

	public void elevatedCreateCaseTeamMembers()
	{
		try
		{
			Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
			Service.elevatedAddCareTeamMember(carePlan.getRecords());
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	public void elevatedCreateOrderForCarePlanCase()
	{
		try
		{
			Cases carePlan = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
			Service.elevatedInsertOrderForCareplanCase(carePlan.getRecords());
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	private Set<Schema.SObjectField> fieldsToCompareWhetherChanged()
	{
		return new Set<Schema.SObjectField>
		{
				Case.RecordTypeId
		};
	}

	public Cases selectCasesByClosedOrderToBeCancelledStatus()
	{
		List<Case> filteredRecords = (List<Case>) new sflib_SObjects(Records)
				.filter(new sflib_Criteria()
						.equalTo(Case.Status, CLOSEDORDERTOBECANCELLEDSTATUS)).getSObjects();
		return new Cases(filteredRecords);
	}

	public void updateOrderCancellationInfo()
	{
		if (Records.isEmpty())
		{
			return;
		}

		Service.updateCaseRelatedOrderCancellationInfo(Records);
	}

	public Cases setRecordType(Id recordTypeId)
	{
		setField(Case.RecordTypeId, recordTypeId);
		return this;
	}

	public Cases setOwner(Id ownerId)
	{
		setField(Case.OwnerId, ownerId);
		return this;
	}

	public Cases setStatus(String status)
	{
		setField(Case.Status, status);
		return this;
	}
	public Cases setPriority(String priority)
	{
		setField(Case.Priority, priority);
		return this;
	}

	public Cases setReasonForCancellation(Map<Id,String> cancellationReasonByOrderId)
	{
		for (Case caseObj : (List<Case>) Records)
		{
			if (cancellationReasonByOrderId.containsKey(caseObj.OrderID__c))
            {
                caseObj.ReasonForCancellation__c = cancellationReasonByOrderId.get(caseObj.OrderID__c);
            }
		}
		return this;
	}

	public void grantAccessToPublicGroups()
    {
		Cases carePlans = selectCasesByRecordTypeDeveloperName(new Set<String> {StaticConstants.CarePlanRecordTypeDeveloperName});
		Service.grantAccessToPublicGroups(carePlans);
    }

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Cases(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
}
