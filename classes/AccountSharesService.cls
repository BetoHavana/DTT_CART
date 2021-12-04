public with sharing class AccountSharesService
{
	public static final String EDIT = 'Edit';

	public void createShareRecordForPublicGroup(Map<Id, Id> groupIdsByAccountIds)
	{
		fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		new ElevatedContextDML().elevatedCreateShareRecordForPublicGroups(groupIdsByAccountIds, elevatedUnitOfWork);
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

		public void elevatedCreateShareRecordForPublicGroups(Map<Id, Id> groupIdsByAccountIds, fflib_ISObjectUnitOfWork unitOfWork)
		{
			List<AccountShare> lstAccountShares = new List<AccountShare>();
			for (Id objAccountId : groupIdsByAccountIds.keySet())
			{
				AccountShare objPatientShare = new AccountShare();
				objPatientShare.AccountId = objAccountId;
				objPatientShare.UserOrGroupId = groupIdsByAccountIds.get(objAccountId);
				objPatientShare.AccountAccessLevel = EDIT;
				objPatientShare.OpportunityAccessLevel = EDIT;
				lstAccountShares.add(objPatientShare);
			}
			unitOfWork.registerNew(lstAccountShares);
		}

	}
}