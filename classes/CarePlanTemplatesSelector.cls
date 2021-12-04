public with sharing class CarePlanTemplatesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__CarePlanTemplate__c.HealthCloudGA__Active__c,
				HealthCloudGA__CarePlanTemplate__c.Id,
				HealthCloudGA__CarePlanTemplate__c.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__CarePlanTemplate__c.SObjectType;
	}

	public List<HealthCloudGA__CarePlanTemplate__c> selectActive()
	{
		String active = HealthCloudGA__CarePlanTemplate__c.HealthCloudGA__Active__c.getDescribe().getName();
		return ((List<HealthCloudGA__CarePlanTemplate__c>) Database.query(
				newQueryFactory()
						.setCondition(active + ' = true')
						.toSOQL()
		));
	}
}