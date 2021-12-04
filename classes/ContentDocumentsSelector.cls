public with sharing class ContentDocumentsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				ContentDocument.Id,
				ContentDocument.Title

		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return ContentDocument.sObjectType;
	}

	public List<ContentDocument> selectByTitle(String title)
	{
		return (List<ContentDocument>) Database.query(String.escapeSingleQuotes(
				newQueryFactory()
						.setCondition('Title = :title')
						.toSOQL()
		));
	}
}
