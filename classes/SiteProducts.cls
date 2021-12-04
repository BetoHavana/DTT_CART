public with sharing class SiteProducts extends sflib_SObjectDomain
{
    public SiteProducts(List<SiteProduct__c> records)
    {
        super(records, SiteProduct__c.SObjectType);
    }

	private SiteProductsService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (SiteProductsService) Application.Service.newInstance(SiteProductsService.class);
            }
            return Service;
        }
        set;
    }

    public Type getType()
	{
		return SiteProducts.class;
    }

	public override void onAfterInsert()
	{
		handleSiteProductsSharing();
	}

	public override void onAfterUpdate(Map<Id,SObject> existingRecords)
	{
		handleSiteProductsSharing();
	}

	public void handleSiteProductsSharing()
	{
		Service.shareSiteWithRelevantPublicGroups(selectSiteProductsWithProducts());
	}

	public SiteProducts selectSiteProductsWithProducts()
	{
		List<SObject> siteProducts =  matching(new sflib_Criteria().notEqualTo(SiteProduct__c.ProductName__c,null));
		return new SiteProducts(siteProducts);
	}

    public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new SiteProducts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}

}