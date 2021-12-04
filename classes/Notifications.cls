public with sharing class Notifications extends fflib_SObjectDomain {

	public Notifications(List<Notification__c> records)
	{
		super(records);
	}

	public Map<Id, Notification__c> getById()
	{
		return new Map<Id, Notification__c>((List<Notification__c>) records);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Notifications(sObjectList);
		}
		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
}