trigger TaskTrigger on Task (before insert) 
{
    fflib_SObjectDomain.triggerHandler(Tasks.class);
}