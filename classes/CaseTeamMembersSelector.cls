public with sharing class CaseTeamMembersSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CaseTeamMember.Id,
				CaseTeamMember.MemberId
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CaseTeamMember.SObjectType;
	}

	public List<CaseTeamMember> getCaseTeamMembersList(Set<Id> caseIds)
	{
		Set<String> fieldSet = new Set<String>();
		fieldSet.add('MemberId');
		fieldSet.add('TeamRole.Name');
		fieldSet.add('ParentId');
		return ((List<CaseTeamMember>)Database.query(
				newQueryFactory()
						.selectFields(fieldSet)
						.setCondition('ParentId IN:caseIds')
						.toSOQL()
		));
	}
}