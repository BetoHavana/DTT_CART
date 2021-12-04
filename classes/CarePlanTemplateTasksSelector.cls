public with sharing class CarePlanTemplateTasksSelector extends fflib_SObjectSelector
{
	private static final String assignedTo = HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__AssignedTo__c.getDescribe().getName();
	private static final String templateGoalParent = HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__CarePlanTemplateGoal__c.getDescribe().getName();
	
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__CarePlanTemplateGoal__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Description__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Offset__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Priority__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Status__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Subject__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__SortOrder__c,
				HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Type__c,
				HealthCloudGA__CarePlanTemplateTask__c.Id
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__CarePlanTemplateTask__c.SObjectType;
	}

	public List<HealthCloudGA__CarePlanTemplateTask__c> selectByCarePlanTemplateGoalIds(Set<Id> carePlanTemplateGoalIds)
	{
		String carePlanTemplateGoal = HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__CarePlanTemplateGoal__c.getDescribe().getName();

		return ((List<HealthCloudGA__CarePlanTemplateTask__c>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__CarePlanTemplateGoal__r.Name')
						.setCondition(carePlanTemplateGoal+' IN:carePlanTemplateGoalIds')
						.setOrdering('HealthCloudGA__CarePlanTemplateGoal__r.HealthCloudGA__SortOrder__c', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()
		));
	}

	public List<HealthCloudGA__CarePlanTemplateTask__c> selectRelatedToTemplateGoalByRole(String role)
	{
		return ((List<HealthCloudGA__CarePlanTemplateTask__c>) Database.query(
			newQueryFactory()
					.selectField('Name')
					.setCondition(assignedTo + '= : role AND '+ templateGoalParent +' != null')
					.toSOQL()
		));
	}

}
