public with sharing class KnowledgeDataCategorySelector extends fflib_SObjectSelector{

    public List<Schema.SObjectField> getSObjectFieldList() 
    { 
        return new List<Schema.SObjectField>
		{
            KnowledgeDataCategory__mdt.label,
            KnowledgeDataCategory__mdt.IconName__c,
            KnowledgeDataCategory__mdt.PageType__c
		};
    }

    public SObjectType getSObjectType()
	{
		return KnowledgeDataCategory__mdt.SObjectType;
    }

    public List<KnowledgeDataCategory__mdt> selectAll()
	{      
        return (List<KnowledgeDataCategory__mdt>) 
                Database.query(
                    newQueryFactory()
                        .toSOQL()
                );
    }
}