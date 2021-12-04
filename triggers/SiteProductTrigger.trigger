trigger SiteProductTrigger on SiteProduct__c (after insert, after update) 
{
    fflib_SObjectDomain.triggerHandler(SiteProducts.class);
}