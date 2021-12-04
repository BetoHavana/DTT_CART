public with sharing class Groups extends fflib_SObjectDomain
{
	public Groups(List<Group> records)
	{
		super(records, Group.SObjectType);
	}

	public Map<Id, Group> getById()
	{
		return new Map<Id, Group>((List<Group>) records);
	}

	public Map<String, Group> getByName()
	{
		Map<String, Group> mapOfGroupsByName = new Map<String, Group>();
		for (Group record : (List<Group>) records)
		{
			mapOfGroupsByName.put(record.Name, record);
		}
		return mapOfGroupsByName;
	}

	public static void createPublicGroupsForAccounts(List<Account> accounts, fflib_ISObjectUnitOfWork unitOfWork)
	{
		GroupsService.elevatedCreatePublicGroupsForAccounts(accounts, unitOfWork);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Groups(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new Groups(sObjectList);
		}
	}


}
