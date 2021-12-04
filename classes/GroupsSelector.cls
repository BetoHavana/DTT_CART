public with sharing class GroupsSelector extends fflib_SObjectSelector
{
	static final String QUEUE = 'Queue';
	static final String DEVELOPER_NAME = Group.DeveloperName.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Group.Id,
				Group.Name,
				Group.DeveloperName
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Group.SObjectType;
	}

	public Groups selectByName(Set<String> names)
	{
		String name = Group.Name.getDescribe().getName();
		return (Groups) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setCondition(name+' IN:names')
								.toSOQL()
				));
	}

	public List<Group> selectQueuesByDeveloperName(Set<String> developerNames)
	{
		String developerName = Group.DeveloperName.getDescribe().getName();
		String type = Group.Type.getDescribe().getName();
		return (List<Group>) Database.query(string.escapeSingleQuotes(
				newQueryFactory()
						.setCondition(developerName+' IN:developerNames AND '+type+' = :QUEUE')
						.toSOQL()));
	}
	public List<Group> selectAll()
	{
		return (List<Group>) Database.query(
				newQueryFactory()
						.toSOQL());
	}

}