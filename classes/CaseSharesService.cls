public with sharing class CaseSharesService
{

	public static final String EDIT = 'Edit';

	public void createCaseShareRecordForAccountsPublicGroup(List<Case> caseList)
	{
		Id currentUserId = UserInfo.getUserId();
		List<User> lstUsers = ((UsersSelector) Application.Selector.newInstance(User.SObjectType)).selectByIds(new Set<Id> {currentUserId});
		if (lstUsers == null || lstUsers[0].AccountId == null) return;
		Map<String, Account> mapAccountsByGroupName = AccountsService.getTreatmentSitesByGroupNameForAccountIds(new Set<Id> {lstUsers[0].AccountId});
		if (mapAccountsByGroupName.isEmpty()) return;
		Map<String, Group> groupsByName = ((GroupsSelector) Application.Selector.newInstance(Group.SObjectType)).selectByName(mapAccountsByGroupName.keySet()).getByName();
		if (groupsByName.isEmpty()) return;
		Map<Id, Id> groupIdByCaseId = new Map<Id, Id>();
		for (Case objCase : caseList)
		{
			for (Group objGroup : groupsByName.values())
			{
				groupIdByCaseId.put(objCase.Id, objGroup.Id);
			}
		}
		fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		new ElevatedContextDML().elevatedCreateCaseShareRecordForPublicGroups(groupIdByCaseId, elevatedUnitOfWork);
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

		public void elevatedCreateCaseShareRecordForPublicGroups(Map<Id, Id> groupIdsByCaseIds, fflib_ISObjectUnitOfWork unitOfWork)
		{
			List<CaseShare> lstCaseShares = new List<CaseShare>();
			for (Id objCaseId : groupIdsByCaseIds.keySet())
			{
				CaseShare objCaseShare = new CaseShare();
				objCaseShare.CaseId = objCaseId;
				objCaseShare.UserOrGroupId = groupIdsByCaseIds.get(objCaseId);
				objCaseShare.CaseAccessLevel = EDIT;
				lstCaseShares.add(objCaseShare);
			}
			unitOfWork.registerNew(lstCaseShares);
		}

	}

}