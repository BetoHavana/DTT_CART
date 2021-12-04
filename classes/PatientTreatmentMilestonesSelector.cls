public with sharing class PatientTreatmentMilestonesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				PatientLandingPageStatusValue__mdt.Active__c,
				PatientLandingPageStatusValue__mdt.CarePlanStatus__c,
				PatientLandingPageStatusValue__mdt.DeveloperName,
				PatientLandingPageStatusValue__mdt.Id,
				PatientLandingPageStatusValue__mdt.MasterLabel,
				PatientLandingPageStatusValue__mdt.OrderStatus__c,
				PatientLandingPageStatusValue__mdt.PatientJourneyStatus__c,
				PatientLandingPageStatusValue__mdt.PatientStatus__c,
				PatientLandingPageStatusValue__mdt.PatientTreatmentMilestoneStatus__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return PatientLandingPageStatusValue__mdt.SObjectType;
	}

	public List<PatientLandingPageStatusValue__mdt> selectAll()
	{
		return (List<PatientLandingPageStatusValue__mdt>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}

}