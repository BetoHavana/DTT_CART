public with sharing class ContactContactRelationSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector
{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__ContactContactRelation__Share.Id,
				HealthCloudGA__ContactContactRelation__Share.ParentId,
				HealthCloudGA__ContactContactRelation__Share.AccessLevel,
				HealthCloudGA__ContactContactRelation__Share.UserOrGroupId,
                HealthCloudGA__ContactContactRelation__Share.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return HealthCloudGA__ContactContactRelation__Share.SObjectType;
	}

	public List<HealthCloudGA__ContactContactRelation__Share> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<HealthCloudGA__ContactContactRelation__Share>) selectByFieldInIdSet(HealthCloudGA__ContactContactRelation__Share.ParentId, SObjectIds);
	}

	public Map<Id, List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
	{
		return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(HealthCloudGA__ContactContactRelation__Share.ParentId);
	}
}