public with sharing class SiteProductsSelector extends sflib_SObjectSelector
{
	String ParentAccount = SiteProduct__c.ParentAccount__c.getDescribe().getName();
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				SiteProduct__c.Name,
				SiteProduct__c.ParentAccount__c,
				SiteProduct__c.Product__c,
				SiteProduct__c.ProductName__c,
				SiteProduct__c.SpecialtyDistributor__c,
				SiteProduct__c.Status__c
		};
	}

	public SObjectType getSObjectType()
	{
		return SiteProduct__c.SObjectType;
	}

	Public List<SiteProduct__c> getSiteProductInfo(Set<Id> treatmentSiteIds)
	{
		return (List<SiteProduct__c>) Database.query(
				newQueryFactory()
						.selectField('Product__r.QuantityFG__c')
						.selectField('Product__r.QuantityAphersis__c')
						.selectField('Product__r.UOMFG__c')
						.selectField('Product__r.UOMApheresis__c')
						.selectField('Product__r.SalesOrderType__c')
						.selectField('Product__r.ApheresisMaterialCodeFresh__c')
						.selectField('Product__r.ApheresisMaterialCodeFrozen__c')
						.selectField('Product__r.MaterialNoFG__c')
						.selectField('SpecialtyDistributor__r.ERPSiteID__c')
						.setCondition(ParentAccount + ' IN: treatmentSiteIds')
						.toSOQL());
	}

	public Database.QueryLocator getElevatedQLOfSiteProuctsCreatEditedInLastNDays(Integer lastNDays)
	{
		return new ElevatedContext(this).getElevatedQLOfSiteProuctsCreatEditedInLastNDays(lastNDays);
	}

	private without sharing class ElevatedContext extends fflib_SObjectSelector
	{
		private SiteProductsSelector siteProductsSelector;
		public ElevatedContext(SiteProductsSelector siteProductsSelector)
		{
			super(true, false, false, true);
			this.siteProductsSelector = siteProductsSelector;
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return siteProductsSelector.getSObjectFieldList();
		}

		public Schema.SObjectType getSObjectType()
		{
			return siteProductsSelector.getSObjectType();
		}

		public Database.QueryLocator getElevatedQLOfSiteProuctsCreatEditedInLastNDays(Integer lastNDays)
		{
			return Database.getQueryLocator(
						newQueryFactory(false, false, true)
							.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
							new List<String>
							{
									SiteProduct__c.LastModifiedDate.getDescribe().getName(),
									String.valueOf(lastNDays)
							}))
							.toSOQL());
		}

	}
}