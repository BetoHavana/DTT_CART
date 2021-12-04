trigger AccountTrigger on Account (before update, after update, before insert, after insert, before delete, after delete) {
    fflib_SObjectDomain.triggerHandler(Accounts.class);
}