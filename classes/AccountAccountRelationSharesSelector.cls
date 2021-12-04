public with sharing class AccountAccountRelationSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector
{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__AccountAccountRelation__Share.Id,
				HealthCloudGA__AccountAccountRelation__Share.ParentId,
				HealthCloudGA__AccountAccountRelation__Share.AccessLevel,
				HealthCloudGA__AccountAccountRelation__Share.UserOrGroupId,
                HealthCloudGA__AccountAccountRelation__Share.RowCause

		};
	}

	public SObjectType getSObjectType()
	{
		return HealthCloudGA__AccountAccountRelation__Share.SObjectType;
	}

	public List<HealthCloudGA__AccountAccountRelation__Share> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<HealthCloudGA__AccountAccountRelation__Share>) selectByFieldInIdSet(HealthCloudGA__AccountAccountRelation__Share.ParentId, SObjectIds);
	}

	public Map<Id, List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
	{
		return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(HealthCloudGA__AccountAccountRelation__Share.ParentId);
	}

}