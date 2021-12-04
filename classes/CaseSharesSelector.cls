public with sharing class CaseSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CaseShare.Id,
                CaseShare.CaseId,
				CaseShare.CaseAccessLevel,
				CaseShare.UserOrGroupId,
                CaseShare.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return CaseShare.SObjectType;
	}
    
	public List<CaseShare> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<CaseShare>) selectByFieldInIdSet(CaseShare.CaseId, SObjectIds);
	}
    
    public Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
    {
      return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(CaseShare.CaseId);   
    }

}