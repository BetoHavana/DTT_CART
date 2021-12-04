public with sharing class CaseTeamRoleSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CaseTeamRole.Id,
				CaseTeamRole.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CaseTeamRole.SObjectType;
	}

	public List<CaseTeamRole> selectAll()
	{
		return (List<CaseTeamRole>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}
}