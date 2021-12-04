public without sharing class KnowledgeArticleService
{
    public List<KnowledgeArticleVersion> getTopicAssigment(String topicId) 
    {
        List<TopicAssignment> topicAssignmentList = new List<TopicAssignment>();
        TopicAssignmentSelector topicAssigmentSelector = (TopicAssignmentSelector)
                                                        Application.Selector.newInstance(TopicAssignment.SObjectType);

        topicAssignmentList = (topicAssigmentSelector.elevatedSelectByTopicId(topicId));

        Set<Id> topicAssigmentsIds = sflib_ArrayUtils.pluckIdField(topicAssignmentList, TopicAssignment.EntityId);

        KnowledgeArticleSelector articlesSelector = (KnowledgeArticleSelector)
                                                    Application.Selector.newInstance(KnowledgeArticleVersion.SObjectType);

        return new List<KnowledgeArticleVersion> (articlesSelector.elevatedSelectByTopicAssigmentsId(topicAssigmentsIds));
    }
}