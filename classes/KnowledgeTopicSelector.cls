public with sharing class KnowledgeTopicSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Topic.Id,
				Topic.Name
		};
    }

    public SObjectType getSObjectType()
	{
		return Topic.SObjectType;
	}

    public List<Topic> selectAll()
	{
		String name = 'Name';
		return (List<Topic>)
				Database.query(
					newQueryFactory()
						.setOrdering(name, fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()
				);
	}
}