public with sharing class CarePlanTemplateGoalsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__CarePlanTemplateGoal__c.HealthCloudGA__CarePlanTemplate__c,
				HealthCloudGA__CarePlanTemplateGoal__c.HealthCloudGA__Description__c,
				HealthCloudGA__CarePlanTemplateGoal__c.HealthCloudGA__SortOrder__c,
				HealthCloudGA__CarePlanTemplateGoal__c.Id,
				HealthCloudGA__CarePlanTemplateGoal__c.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__CarePlanTemplateGoal__c.SObjectType;
	}

	public List<HealthCloudGA__CarePlanTemplateGoal__c> selectByCarePlanTemplateIds(Set<Id> carePlanTemplateIds)
	{
		String carePlanTemplate = HealthCloudGA__CarePlanTemplateGoal__c.HealthCloudGA__CarePlanTemplate__c.getDescribe().getName();
		return ((List<HealthCloudGA__CarePlanTemplateGoal__c>) Database.query(
				newQueryFactory()
						.setCondition(carePlanTemplate+' IN:carePlanTemplateIds')
						.setOrdering('HealthCloudGA__SortOrder__c', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()
		));
	}

}
