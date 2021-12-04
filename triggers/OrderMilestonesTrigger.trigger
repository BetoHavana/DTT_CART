trigger OrderMilestonesTrigger on OrderMilestones__c (before insert, after insert, before update,
                                                      after update, before delete, after delete, after undelete)
{
    fflib_SObjectDomain.triggerHandler(OrderMilestones.class);
}