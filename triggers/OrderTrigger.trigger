trigger OrderTrigger on Order__c (before update, after update, before insert, after insert)
{
	fflib_SObjectDomain.triggerHandler(Orders.class);
}