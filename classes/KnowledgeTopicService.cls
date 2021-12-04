public with sharing class KnowledgeTopicService {
    public static final String DEFAULTICON = 'utility:diamond';

    public  String getTopicsWithIcons(String pageType) 
    {
        List<TopicIconWrapper> tiwList = new List<TopicIconWrapper>();

        List<Topic> topicList = new List<Topic>();
        KnowledgeTopicSelector knowTopSelector = (KnowledgeTopicSelector)
                                                Application.Selector.newInstance(Topic.SObjectType);

            topicList = knowTopSelector.selectAll();

        KnowledgeDataCategorySelector dcIconSelector = (KnowledgeDataCategorySelector)
                                                        Application.Selector.newInstance(KnowledgeDataCategory__mdt.SObjectType);

        List<KnowledgeDataCategory__mdt> dcIconList = dcIconSelector.selectAll();
        TopicIconWrapper tiw;

        for(Topic topicItem : topicList){
            tiw = new TopicIconWrapper();
            tiw.topicId = topicItem.Id;
            tiw.name = topicItem.Name;
            
            for(KnowledgeDataCategory__mdt dataCategory : dcIconList){
                if(topicItem.Name.equals(dataCategory.label) && pageType.equals(dataCategory.PageType__c)){
                    tiw.icon = dataCategory.IconName__c;
                    tiwList.add(tiw);
                }
            }
        } 

        return JSON.serialize(tiwList);

    }
    
    public class TopicIconWrapper
    {
        public String topicId { get; set; }
        public String name { get; set; }
        public String icon { get; set; }

    }
}