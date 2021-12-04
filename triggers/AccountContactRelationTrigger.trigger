trigger AccountContactRelationTrigger on AccountContactRelation (after insert, after update)
{
    fflib_SObjectDomain.triggerHandler(AccountContactRelations.class);
}