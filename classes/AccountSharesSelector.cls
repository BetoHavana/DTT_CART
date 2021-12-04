public with sharing class AccountSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				AccountShare.Id,
                AccountShare.AccountId,
				AccountShare.AccountAccessLevel,
				AccountShare.UserOrGroupId,
                AccountShare.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return AccountShare.SObjectType;
	}
    
	public List<AccountShare> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<AccountShare>) selectByFieldInIdSet(AccountShare.AccountId, SObjectIds);
	}
    
    public Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
    {
      return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(AccountShare.AccountId);   
    }

}