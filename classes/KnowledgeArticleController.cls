public class KnowledgeArticleController
{

    private KnowledgeArticleController()
    {
    }

	private static KnowledgeTopicService topicService
    {
        get
        {
            if (null == topicService)
            {
                topicService = (KnowledgeTopicService) Application.Service.newInstance(KnowledgeTopicService.class);
            }
            return topicService;
        }
        set;
    }

    private static KnowledgeArticleService articleService
    {
        get
        {
            if (null == articleService)
            {
                articleService = (KnowledgeArticleService) Application.Service.newInstance(KnowledgeArticleService.class);
            }
            return articleService;
        }
        set;
    }

    @AuraEnabled(cacheable=true)
    public static String getTopicList(String pageType)
    {
    	return topicService.getTopicsWithIcons(pageType);
		      
    }

    @AuraEnabled(cacheable=true)
    public static List<KnowledgeArticleVersion> getArticles(String topicId)
    {

    	return articleService.getTopicAssigment(topicId);
    }
}