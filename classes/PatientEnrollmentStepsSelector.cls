public with sharing class PatientEnrollmentStepsSelector extends fflib_SObjectSelector
{
	public static final String ORDER = 'Order';
	public static final String PATIENT = 'Patient';
	String module = PatientEnrollmentSteps__mdt.Module__c.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				PatientEnrollmentSteps__mdt.DeveloperName,
				PatientEnrollmentSteps__mdt.Id,
				PatientEnrollmentSteps__mdt.MasterLabel,
				PatientEnrollmentSteps__mdt.Module__c,
				PatientEnrollmentSteps__mdt.Order__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return PatientEnrollmentSteps__mdt.sObjectType;
	}

	public List<PatientEnrollmentSteps__mdt> selectPatients()
	{
		return (List<PatientEnrollmentSteps__mdt>) Database.query(
				newQueryFactory()
						.selectField('Module__c')
						.setCondition(module + '=:' +PATIENT)
						.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()
		);
	}

	public List<PatientEnrollmentSteps__mdt> selectSlotSchedulingSteps()
	{
		return (List<PatientEnrollmentSteps__mdt>) Database.query(
				newQueryFactory()
						.selectField('Module__c')
						.setCondition(module + '=:' +ORDER)
						.setOrdering('Order__c', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()
		);
	}
}