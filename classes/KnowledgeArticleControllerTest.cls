@IsTest(SeeAllData=false)
public class KnowledgeArticleControllerTest {
    
    public static final String PAGE_TYPE = 'Resources';
    public static final String SYSTEM_ADMIN = 'System Administrator';

    @TestSetup static void testDataSetup()
	{
        List<User> lstUser = new List<User>();
        lstUser.addAll(TestDataFactory.getUsersToInsert(SYSTEM_ADMIN, 2));
        insert lstUser;       
    }

    @IsTest static void getTopicArticleTest()
	{
        
        String returnListOfTopic;
        List<KnowledgeArticleVersion> lstArt = new List<KnowledgeArticleVersion>();
        Set<String> userProfileName = new Set<String>{SYSTEM_ADMIN};
        List<User> userList = ((UsersSelector) Application.Selector.newInstance(User.SObjectType)).selectByProfileName(userProfileName);
        
        //GIVEN I am an Administrator and have knowledge permission assign
        System.runAs(userList[0]) {

            //GIVEN - Topic and Article record
            Id topicIdTest;
            Id articleId; 
            List<Topic> lstTopic = new List<Topic>();
            lstTopic.add(TestDataFactory.getTopic()); 
            insert lstTopic;

            List<knowledge__kav> lstKnowledgeArticle = new List<knowledge__kav>();
            lstKnowledgeArticle.add(TestDataFactory.getArticle());
            insert lstKnowledgeArticle;

            List<TopicAssignment> lstTopicAssignment = new List<TopicAssignment>();
            for (Topic topicId: lstTopic)
            {
                topicIdTest = topicId.Id;
                for (knowledge__kav articleIds: lstKnowledgeArticle)
                {
                    articleId = articleIds.Id;
                }
            }

            lstTopicAssignment.add(TestDataFactory.getTopicAssignment(topicIdTest, articleId));
            insert lstTopicAssignment;

            Test.startTest();
            //WHEN - Call an article and a topic
            returnListOfTopic = KnowledgeArticleController.getTopicList(PAGE_TYPE);
            lstArt = KnowledgeArticleController.getArticles(topicIdTest);
            Test.stopTest();

            //THEN - It should return a topics and article
            System.assertEquals(String.isNotBlank(returnListOfTopic), true);
            System.assert(lstArt.isEmpty());
        }
    }    
}