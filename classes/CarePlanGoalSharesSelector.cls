public with sharing class CarePlanGoalSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__CarePlanGoal__Share.Id,
                HealthCloudGA__CarePlanGoal__Share.ParentId,
				HealthCloudGA__CarePlanGoal__Share.AccessLevel,
				HealthCloudGA__CarePlanGoal__Share.UserOrGroupId,
				HealthCloudGA__CarePlanGoal__Share.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return HealthCloudGA__CarePlanGoal__Share.SObjectType;
	}
    
	public List<HealthCloudGA__CarePlanGoal__Share> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<HealthCloudGA__CarePlanGoal__Share>) selectByFieldInIdSet(HealthCloudGA__CarePlanGoal__Share.ParentId, SObjectIds);
	}
    
    public Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
    {
      return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(HealthCloudGA__CarePlanGoal__Share.ParentId);   
    }

}