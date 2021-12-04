public with sharing class SiteProductsService
{
	public Map<Id, SiteProduct__c> getSiteIdNsiteProductInfo(Set<Id> siteIds)
	{
		Map<Id, SiteProduct__c> spIdNSpecialtyDistributorInfo = new Map<Id, SiteProduct__c>();

		if (siteIds == null || siteIds.isEmpty()) return spIdNSpecialtyDistributorInfo;

		for (SiteProduct__c siteProduct : ((SiteProductsSelector) Application.Selector
                                            .newInstance(SiteProduct__c.SObjectType))
                                            .getSiteProductInfo(siteIds))
		{
			spIdNSpecialtyDistributorInfo.put(siteProduct.ParentAccount__c, siteProduct);
		}
		return spIdNSpecialtyDistributorInfo;
	}

	public void shareSiteWithRelevantPublicGroups(SiteProducts siteProducts)
	{
		Set<Id> siteProductIds = siteProducts.getRecordIds();
		if (siteProductIds.isEmpty())
		{
			return ;
		}

		shareSiteWithRelevantPublicGroups(siteProductIds);
	}

	@Future
	public static void shareSiteWithRelevantPublicGroups(Set<Id> siteProductIds)
	{
		List<SiteProduct__c> siteProducts = ((SiteProducts) Application.Domain.newInstance(siteProductIds))
				.getRecords();
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		SiteProductsService siteProuctsService = (SiteProductsService) Application.Service.newInstance(SiteProductsService.class);
		siteProuctsService.getSiteShareRecords(uow, siteProducts);
		uow.commitWork();
	}

	public void getSiteShareRecords(fflib_ISObjectUnitOfWork uow, List<SiteProduct__c> siteProducts)
	{
		RecordShareConfigSelector recSharingConfigSelector = (RecordShareConfigSelector) Application.Selector.newInstance(RecordShareConfig__mdt.SObjectType);
		Map<String, List<RecordShareConfig__mdt>> recShareConfigsGrpByProductName = recSharingConfigSelector.selectRecShareConfigsGrpByPName();
		Map<Id,Id> treatmentSiteAndHSInfo = ((AccountsService) Application.Service.newInstance(AccountsService.class)).
				getTreatmentSiteHealthSystemInfo(sflib_ArrayUtils.pluckIdField(siteProducts,SiteProduct__c.ParentAccount__c));
		List<RecordsShareConfigsWrapper> recordsSharesConfigs = new List<RecordsShareConfigsWrapper>();

		for (SiteProduct__c siteProduct : siteProducts)
		{
			if (String.isBlank(siteProduct.ParentAccount__c) || string.isBlank(siteProduct.ProductName__c))
			{
				continue;
			}
			setShareRecordConfig(recordsSharesConfigs, new Set<Id>{siteProduct.ParentAccount__c,siteProduct.SpecialtyDistributor__c,treatmentSiteAndHSInfo.get(siteProduct.ParentAccount__c)}, recShareConfigsGrpByProductName.get(siteProduct.ProductName__c));
		}

		new RecordsSharingService().getSObjectShareRecords(uow, recordsSharesConfigs, Account.SObjectType);
	}

	private void setShareRecordConfig(List<RecordsShareConfigsWrapper> recordsSharesConfigs, Set<Id> treatmentSiteOrSDIds, List<RecordShareConfig__mdt> recordShareConfigs)
	{
		if(recordShareConfigs == null || recordShareConfigs.isEmpty())
		{
			return ;
		}

		treatmentSiteOrSDIds.remove(null);
		for (RecordShareConfig__mdt config : recordShareConfigs)
		{
			for(Id treatmentSiteIdOrSDId : treatmentSiteOrSDIds)
			{
				recordsSharesConfigs.add(new RecordsShareConfigsWrapper(config.AccessLevel__c, config.GroupName__c, treatmentSiteIdOrSDId));
			}
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