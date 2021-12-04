trigger CaseTrigger on Case (before insert, before update, after insert, after update)
{
	fflib_SObjectDomain.triggerHandler(Cases.class);
}