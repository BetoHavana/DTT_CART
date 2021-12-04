public with sharing class ContentDocumentLinksSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				ContentDocumentLink.ContentDocumentId,
				ContentDocumentLink.LinkedEntityId
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return ContentDocumentLink.getSObjectType();
	}

	public List<ContentDocumentLink> elevatedSelectByLinkedEntity(Id entityIds){
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByLinkedEntity(entityIds);
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		ContentDocumentLinksSelector selector;

		public ElevateContext(ContentDocumentLinksSelector selector)
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

		private List<ContentDocumentLink> elevatedSelectByLinkedEntity(Id idSet){
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Id');
			queryFactory.setCondition('LinkedEntityId  =: idSet');
			return (List<ContentDocumentLink>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

	}
}
