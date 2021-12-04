public with sharing class GroupMembers extends fflib_SObjectDomain
{
	public GroupMembers(List<Group> records)
	{
		super(records, GroupMember.SObjectType);
	}

	public static void createGroupMembersForTreatmentSitePersonnel(Map<Id, User> customerUsersByAccountId, Map<String, Group> mapOfGroupsByName, Map<Id, Account> mapOfAccountsByIds, fflib_ISObjectUnitOfWork unitOfWork)
	{
		GroupMembersService.elevatedCreateGroupMembersForTreatmentSitePersonnel(customerUsersByAccountId, mapOfGroupsByName, mapOfAccountsByIds, unitOfWork);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new GroupMembers(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new GroupMembers(sObjectList);
		}
	}

}
