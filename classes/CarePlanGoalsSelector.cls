public with sharing class CarePlanGoalsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__CarePlanGoal__c.HealthCloudGA__CarePlan__c,
				HealthCloudGA__CarePlanGoal__c.Id,
				HealthCloudGA__CarePlanGoal__c.Name,
				HealthCloudGA__CarePlanGoal__c.Status__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__CarePlanGoal__c.SObjectType;
	}

	public List<HealthCloudGA__CarePlanGoal__c> selectByCarePlanIdAndName(Set<Id> setOfCarePlanIds, String goalName)
	{
		return (List<HealthCloudGA__CarePlanGoal__c>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__CarePlan__c')
						.setCondition('HealthCloudGA__CarePlan__c IN: setOfCarePlanIds AND Name =: goalName')
						.toSOQL()
		);
	}

	public List<HealthCloudGA__CarePlanGoal__c> selectByCarePlanId(Set<Id> setOfCarePlanIds)
	{
		return (List<HealthCloudGA__CarePlanGoal__c>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__CarePlan__c')
						.setCondition('HealthCloudGA__CarePlan__c IN: setOfCarePlanIds')
						.toSOQL()
		);
	}

	public List<HealthCloudGA__CarePlanGoal__c> selectByCarePlanIdAndGoalNames(Set<Id> setOfCarePlanIds, Set<String> goalNames)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		queryFactory.setCondition('HealthCloudGA__CarePlan__c IN: setOfCarePlanIds AND Name IN: goalNames');
		return (List<HealthCloudGA__CarePlanGoal__c>) Database.query(
				String.escapeSingleQuotes(queryFactory.toSOQL())
		);
	}

	public Database.QueryLocator getQLOfGoalsCreatedEditedInLastNDays(Integer lastNDays)
	{
		return Database.getQueryLocator(
				newQueryFactory(false, false, true)
						.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
						new List<String>
						{
								HealthCloudGA__CarePlanGoal__c.LastModifiedDate.getDescribe().getName(),
								String.valueOf(lastNDays)
						}))
						.toSOQL());
	}
}