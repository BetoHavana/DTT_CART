public with sharing class Users extends fflib_SObjectDomain
{

	public Users(List<User> records)
	{
		super(records, User.SObjectType);
	}

	private UsersService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (UsersService) Application.Service.newInstance(UsersService.class);
			}
			return Service;
		}
		set;
	}

	public Map<Id, User> getCustomerUsersByAccountIds()
	{
		Map<Id, User> customerUsersByAccountIds = new Map<Id, User>();
		for (User record : (List<User>) records)
		{
			if (record.AccountId != null)
			{
				customerUsersByAccountIds.put(record.AccountId, record);
			}
		}
		return customerUsersByAccountIds;
	}

	public override void onAfterInsert()
	{
		createGroupMembersForTreatmentSiteAccounts();
	}

	public void createGroupMembersForTreatmentSiteAccounts()
	{
		Map<Id, User> customerUsersByAccountIds = getCustomerUsersByAccountIds();
		if(customerUsersByAccountIds.isEmpty()) return;
		Service.createGroupMembersForSitePersonnel(customerUsersByAccountIds);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Users(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new Users(sObjectList);
		}
	}


}
