trigger AccountAccountRelationTrigger on HealthCloudGA__AccountAccountRelation__c (after insert, after update) 
{
	fflib_SObjectDomain.triggerHandler(AccountAccountRelations.class);
}