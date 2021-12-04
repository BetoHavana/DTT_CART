public with sharing class OrderSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Order__Share.Id,
                Order__Share.ParentId,
				Order__Share.AccessLevel,
				Order__Share.UserOrGroupId,
                Order__Share.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return Order__Share.SObjectType;
	}
    
	public List<Order__Share> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<Order__Share>) selectByFieldInIdSet(Order__Share.ParentId, SObjectIds);
	}
    
    public Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
    {
      return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(Order__Share.ParentId);   
    }

}