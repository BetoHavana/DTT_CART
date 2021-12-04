public with sharing class ContentVersionsSelector extends fflib_SObjectSelector
{
	private final static String cvId = ContentVersion.Id.getDescribe().getName();
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				ContentVersion.ContentDocumentId,
				ContentVersion.ContentUrl,
				ContentVersion.FileExtension,
				ContentVersion.FileType,
				ContentVersion.Id,
				ContentVersion.PathOnClient
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return ContentVersion.getSObjectType();
	}

	public List<ContentVersion> elevatedGetContentVersionByDocumentIds(Set<Id> idSet)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedGetContentVersionByDocumentId(idSet);
	}

	public List<ContentVersion> getContentVersionById(Set<Id> cvIds)
	{
		return (List<ContentVersion>) Database.query(
				newQueryFactory()
						.setCondition(cvId + ' IN :cvIds')
						.toSOQL());
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		ContentVersionsSelector selector;

		public ElevateContext(ContentVersionsSelector selector)
		{
			super(true, false, false, true);
			this.selector = selector;
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return selector.getSObjectFieldList();
		}

		public Schema.SObjectType getSObjectType()
		{
			return selector.getSObjectType();
		}

		private List<ContentVersion> elevatedGetContentVersionByDocumentId(Set<Id> idSet)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.setCondition('ContentDocumentId IN :idSet');
			return (List<ContentVersion>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}

}