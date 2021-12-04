public with sharing class CareProgramEnrolleeProductSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CareProgramEnrolleeProductShare.Id,
				CareProgramEnrolleeProductShare.ParentId,
				CareProgramEnrolleeProductShare.AccessLevel,
				CareProgramEnrolleeProductShare.UserOrGroupId,
                CareProgramEnrolleeProductShare.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return CareProgramEnrolleeProductShare.SObjectType;
	}

	public List<CareProgramEnrolleeProductShare> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		String parentId = CareProgramEnrolleeProductShare.ParentId.getDescribe().getName();
		return (List<CareProgramEnrolleeProductShare>) Database.query(
					newQueryFactory(false, false, true)
							.setCondition(parentId + ' IN: SObjectIds')
							.toSOQL());
	}

	public Map<Id, List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
	{
		Map<Id, List<SObject>> result = new Map<Id, List<SObject>>();
		for (SObject record : selectSObjectSharesBySObjectIds(SObjectIds))
		{
			Id fieldId = (Id) record.get(CareProgramEnrolleeProductShare.parentId);
			if (!result.containsKey(fieldId))
			{
				result.put(fieldId, new List<SObject>());
			}
			result.get(fieldId).add(record);
		}
		return result;
	}
}