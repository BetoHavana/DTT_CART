public with sharing class GroupMembersSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				GroupMember.Id
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return GroupMember.SObjectType;
	}

	public List<GroupMember> selectAll()
	{
		return (List<GroupMember>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}
}