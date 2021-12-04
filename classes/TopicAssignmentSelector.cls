public without sharing class TopicAssignmentSelector extends fflib_SObjectSelector
{    
    public static final String TOPIC_ASSIGMENT = TopicAssignment.topicId.getDescribe().getName();

    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
            TopicAssignment.EntityId
		};
    }

    public SObjectType getSObjectType()
	{
		return TopicAssignment.SObjectType;
    }

    public List<TopicAssignment> elevatedSelectByTopicId(String topicId)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByTopicId(topicId);
    }

    private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		TopicAssignmentSelector selector;

		public ElevateContext(TopicAssignmentSelector selector)
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

		public List<TopicAssignment> elevatedSelectByTopicId(String topicId)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('EntityId');
			queryFactory.setCondition(TOPIC_ASSIGMENT + ' =: topicId');
			return (List<TopicAssignment>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

	}

}