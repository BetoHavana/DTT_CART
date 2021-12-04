trigger ContactContactRelationTrigger on HealthCloudGA__ContactContactRelation__c (after insert)
{
	fflib_SObjectDomain.triggerHandler(ContactContactRelations.class);
}