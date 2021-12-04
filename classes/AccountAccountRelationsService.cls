public with sharing class AccountAccountRelationsService
{

	public Map<String, String> getRelatedSitesInfo(Set<Id> siteIds)
	{
		Map<String, Id> relatedSiteMap = new Map<String, Id>();
		List<HealthCloudGA__AccountAccountRelation__c> accAccountRelList = new List<HealthCloudGA__AccountAccountRelation__c>();
		AccountAccountRelationSelector assocLocSelector =
				(AccountAccountRelationSelector) Application.Selector.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType);
		accAccountRelList = assocLocSelector.selectByAccountIds(siteIds);
		AccountAccountRelations accAccRelation = new AccountAccountRelations(accAccountRelList);
		relatedSiteMap = accAccRelation.getRelatedSites();
		return relatedSiteMap;
	}

	public void grantAccessToRelatedPublicGroups(AccountAccountRelations accountAccountRelations)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToRelatedPublicGroups(uow, accountAccountRelations.getRecords());
		uow.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<HealthCloudGA__AccountAccountRelation__c> accountAccountRelationList)
	{
		if (accountAccountRelationList == null || accountAccountRelationList.isEmpty())
		{
			return;
		}
		Map<Id, Id> sObjectIdByObjectIdToCloneMap = new Map<Id, Id>();
		Map<Id, Id> accAccRelationIdByObjectIdToCloneMap = new Map<Id, Id>();
		RecordsSharingService rss = new RecordsSharingService();
		Set<Id> siteInformationIds = sflib_ArrayUtils.pluckIdField(accountAccountRelationList, HealthCloudGA__AccountAccountRelation__c.Id);
		List<HealthCloudGA__AccountAccountRelation__c> siteInformationList = ((AccountAccountRelationSelector) Application.Selector
																					.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType))
																					.selectById(siteInformationIds);

		for (HealthCloudGA__AccountAccountRelation__c aar : siteInformationList)
		{
			if (aar.HealthCloudGA__InverseRelationship__c != null)
			{
				sObjectIdByObjectIdToCloneMap.put(aar.HealthCloudGA__RelatedAccount__c, aar.HealthCloudGA__Account__c);
				accAccRelationIdByObjectIdToCloneMap.put(aar.Id, aar.HealthCloudGA__Account__c);
				accAccRelationIdByObjectIdToCloneMap.put(aar.HealthCloudGA__InverseRelationship__c, aar.HealthCloudGA__Account__c);
			}
		}

		if (!sObjectIdByObjectIdToCloneMap.isEmpty() && !accAccRelationIdByObjectIdToCloneMap.isEmpty())
		{
			rss.cloneSharingSettings(uow, sObjectIdByObjectIdToCloneMap, AccountShare.SObjectType);
			rss.cloneSharingSettings(uow, accAccRelationIdByObjectIdToCloneMap, AccountShare.SObjectType);
		}
	}

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}

			Database.emptyRecycleBin(objList);
		}
		public void eventPublish(List<SObject> objList)
		{
		}
	}

}