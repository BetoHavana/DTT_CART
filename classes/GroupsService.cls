public with sharing class GroupsService
{
	public static final String TREATMENTSITE = 'Treatment Site';
	public static final String REGULAR = 'Regular';

	public static void elevatedCreatePublicGroupsForAccounts(List<Account> accounts, fflib_ISObjectUnitOfWork unitOfWork)
	{
		new ElevatedContextDML().elevatedCreatePublicGroupsForAccounts(accounts, unitOfWork);
	}

	public Map<Id, Id> fetchGroupIdsByTreatmentSiteIds(Set<Id> treatmentSiteIds)
	{
		Map<Id, Id> groupIdByTreatmentSiteId = new Map<Id, Id>();

		Map<String, Account> mapAccountsByGroupName = AccountsService.getTreatmentSitesByGroupNameForAccountIds(treatmentSiteIds);
		if (mapAccountsByGroupName.isEmpty())
			return groupIdByTreatmentSiteId ;

		Map<String, Group> groupsByName =
				((GroupsSelector) Application.Selector.newInstance(Group.SObjectType)).
						selectByName(mapAccountsByGroupName.keySet()).getByName();
		if (groupsByName.isEmpty())
			return groupIdByTreatmentSiteId;

		for (String objGroupName : mapAccountsByGroupName.keySet())
		{
			if (groupsByName.containsKey(objGroupName))
			{
				groupIdByTreatmentSiteId.put(mapAccountsByGroupName.get(objGroupName).Id, groupsByName.get(objGroupName).Id);
			}
		}
		return groupIdByTreatmentSiteId;
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

		public void elevatedCreatePublicGroupsForAccounts(List<Account> accounts, fflib_ISObjectUnitOfWork unitOfWork)
		{
			List<Group> groupsListToCreate = new List<Group>();
			for (Account objAccount : accounts)
			{
				Group objGroup = new Group();
				objGroup.Name = TREATMENTSITE + ' - ' + objAccount.AccountIdentifier__c;
				objGroup.Type = REGULAR;
				groupsListToCreate.add(objGroup);
			}
			unitOfWork.registerNew(groupsListToCreate);
		}
	}

}
