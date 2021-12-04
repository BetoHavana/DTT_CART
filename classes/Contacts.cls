public with sharing class Contacts extends fflib_SObjectDomain
{
	public Contacts(List<Contact> records)
	{
		super(records);
	}

	public Map<Id, Id> getAccountIdByContactId()
	{
		Map<Id, Id> accountIdByContactIdMap = new Map<Id, Id>();
		for (Contact record : (List<Contact>) records)
		{
			if (record.AccountId != null && record.Id != null)
			{
				accountIdByContactIdMap.put(record.Id, record.AccountId);
			}
		}
		return accountIdByContactIdMap;
	}

	public Map<Id, Contact> getContactsByAccountId()
	{
		Map<Id, Contact> contactsByAccountIdMap = new Map<Id, Contact>();
		for (Contact record : (List<Contact>) records)
		{
			if (record.AccountId != null)
			{
				contactsByAccountIdMap.put(record.AccountId, record);
			}
		}
		return contactsByAccountIdMap;
	}

	public Map<Id,String> getNameById()
	{
		return new sflib_SObjects(records).asStringFieldByIdField(Contact.Id, Contact.Name);
	}

	public Set<Id> getAccountIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, Contact.AccountId);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Contacts(sObjectList);
		}
	}

	public List<Contact> setStatus(String status)
	{
		List<Contact> contactList = (List<Contact>) Records;

		for(Contact record: contactList)
		{
			record.Status__c = status;
		}

		return contactList;
	}

	public Set<Id> getUserIds()
	{
		Set<Id> userIds = new Set<Id>();
		for(Contact ctc : (List<Contact>) Records)
		{
			for(User user : ctc.Users)
			{
				userIds.add(user.Id);
			}
		}
		
		return userIds;
	}

}
