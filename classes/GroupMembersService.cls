public with sharing class GroupMembersService
{
	public static final String TREATMENTSITE = 'Treatment Site';

	public static void elevatedCreateGroupMembersForTreatmentSitePersonnel(Map<Id, User> customerUsersByAccountId, Map<String, Group> mapOfGroupsByName, Map<Id, Account> mapOfAccountsByIds, fflib_ISObjectUnitOfWork unitOfWork)
	{
		new ElevatedContextDML().elevatedCreateGroupMembersForTreatmentSitePersonnel(customerUsersByAccountId, mapOfGroupsByName, mapOfAccountsByIds, unitOfWork);
	}

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			insert objList;
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void eventPublish(List<SObject> objList)
		{
			//not implemented
		}

		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}
			Database.emptyRecycleBin(objList);
		}

		public void elevatedCreateGroupMembersForTreatmentSitePersonnel(Map<Id, User> customerUsersByAccountId, Map<String, Group> mapOfGroupsByName, Map<Id, Account> mapOfAccountsByIds, fflib_ISObjectUnitOfWork unitOfWork)
		{
			List<GroupMember> groupMembers = new List<GroupMember>();
			for (Id accountId : customerUsersByAccountId.keySet())
			{
				GroupMember objMember = new GroupMember();
				objMember.UserOrGroupId = customerUsersByAccountId.get(accountId).Id;
				String groupName = TREATMENTSITE +' - '+mapOfAccountsByIds.get(accountId).AccountIdentifier__c;
				if (mapOfGroupsByName.containsKey(groupName))
				{
					objMember.GroupId = mapOfGroupsByName.get(groupName).Id;
				}
				groupMembers.add(objMember);
			}
			unitOfWork.registerNew(groupMembers);
		}
	}
}
