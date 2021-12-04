public with sharing class PermissionSetSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				PermissionSet.Id,
				PermissionSet.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return PermissionSet.SObjectType;
	}

	public List<PermissionSet> selectByNames(Set<String> setPermissionSetNames)
	{
		return (List<PermissionSet>) Database.query(
				newQueryFactory()
						.setCondition('Name IN :setPermissionSetNames')
						.toSOQL()
		);
	}
}
