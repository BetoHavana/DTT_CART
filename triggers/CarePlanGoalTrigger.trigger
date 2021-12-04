trigger CarePlanGoalTrigger on HealthCloudGA__CarePlanGoal__c (after insert) 
{
    fflib_SObjectDomain.triggerHandler(CarePlanGoals.class);
}