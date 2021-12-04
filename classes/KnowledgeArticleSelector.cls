public with sharing class KnowledgeArticleSelector extends fflib_SObjectSelector
{
    public static final String STATUS = 'Online';
    public static final String STATUS_ARTICLE = KnowledgeArticleVersion.PublishStatus.getDescribe().getName();

    public List<Schema.SObjectField> getSObjectFieldList()
    {
      return new List<Schema.SObjectField>
      {
            KnowledgeArticleVersion.Id,
            KnowledgeArticleVersion.ArticleNumber,
            KnowledgeArticleVersion.UrlName,
            KnowledgeArticleVersion.Title,
            KnowledgeArticleVersion.KnowledgeArticleId

      };
    }

    public SObjectType getSObjectType()
    {
      return KnowledgeArticleVersion.SObjectType;
    }

    public List<KnowledgeArticleVersion> elevatedSelectByTopicAssigmentsId(Set<id> topicAssigmentsIds)
	  {
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByTopicAssigmentsId(topicAssigmentsIds);
    }

    private without sharing class ElevateContext extends fflib_SObjectSelector
	  {
		KnowledgeArticleSelector selector;

		public ElevateContext(KnowledgeArticleSelector selector)
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

		public List<KnowledgeArticleVersion> elevatedSelectByTopicAssigmentsId(Set<id> topicAssigmentsIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Title');
			queryFactory.selectField('KnowledgeArticleId');
			queryFactory.setCondition(STATUS_ARTICLE + '=:STATUS AND Id IN: topicAssigmentsIds');
			return (List<KnowledgeArticleVersion>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

	}
}