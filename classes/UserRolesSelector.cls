public with sharing class UserRolesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				UserRole.Id
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return UserRole.SObjectType;
	}

	public List<UserRole> selectByName(Set<String> roleNames)
	{
		String name = UserRole.Name.getDescribe().getName();
		return (List<UserRole>) Database.query(
				newQueryFactory()
						.setCondition(name+' IN:roleNames')
						.toSOQL()
		);
	}
}
