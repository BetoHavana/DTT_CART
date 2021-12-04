public with sharing class TasksSelector extends fflib_SObjectSelector
{
	public static final String parentId = Task.WhatId.getDescribe().getName();
	public static final String status = Task.Status.getDescribe().getName();
	public static final String STATUS_COMPLETED = 'Completed';
	public static final String OWNER_ID = Task.OwnerId.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Task.GoalName__c,
            	Task.Id,
				Task.Status,
				Task.Subject,
				Task.OwnerId,
				Task.WhatId
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Task.SObjectType;
	}

	public List<Task> selectTasksByGoals(List<HealthCloudGA__CarePlanGoal__c> goals)
	{
		return (List<Task>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__CarePlanGoal__c')
						.setCondition('HealthCloudGA__CarePlanGoal__c IN: goals')
						.toSOQL()
		);
	}

	public List<Task> selectByCarePlanIdAndGoalNameAndSubject(Set<Id> carePlanIdSet, String goalName, List<String> taskSubjectsList)
	{
		return (List<Task>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__CarePlanGoal__c')
						.setCondition('HealthCloudGA__CarePlanGoal__r.Name =: goalName AND WhatId IN: carePlanIdSet AND Subject IN: taskSubjectsList')
						.toSOQL()
		);
	}

	public List<Task> selectTasksByCarePlanIds(Set<Id> parentIds)
	{
		return (List<Task>) Database.query(
				newQueryFactory()
						.setCondition(status + ' != : STATUS_COMPLETED AND ' + parentId + ' IN : parentIds')
						.toSOQL()
		);
	}
	
	public List<Task> selectAllTasks()
	{
		return (List<Task>) Database.query
		(
				newQueryFactory()
						.toSOQL()
		);
	}

	public List<Task> selectTasksByOwnerId(Set<Id> ownerIds)
	{
		return (List<Task>) Database.query(
				newQueryFactory()
						.setCondition(OWNER_ID + ' IN : ownerIds')
						.toSOQL()
		);
	}
}