public with sharing class UsersService
{
	public void createGroupMembersForSitePersonnel(Map<Id, User> customerUsersByAccountId)
	{
		Map<Id, Account> mapOfAccountsByIds = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectById(customerUsersByAccountId.keySet())
				.getById();

		Map<String, Account> treatmentSitesByGroupName = AccountsService.getTreatmentSitesByGroupNameForAccountIds(mapOfAccountsByIds.keySet());
		if (treatmentSitesByGroupName.isEmpty()) return;
		Map<String, Group> mapOfGroupsByName = ((GroupsSelector) Application.Selector.newInstance(Group.SObjectType))
				.selectByName(treatmentSitesByGroupName.keySet())
				.getByName();

		fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		GroupMembers.createGroupMembersForTreatmentSitePersonnel(customerUsersByAccountId, mapOfGroupsByName, mapOfAccountsByIds, elevatedUnitOfWork);
		elevatedUnitOfWork.commitWork();
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
	}
}