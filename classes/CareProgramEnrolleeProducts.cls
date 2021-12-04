public with sharing class CareProgramEnrolleeProducts extends fflib_SObjectDomain
{

	private CareProgramEnrolleeProductsService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (CareProgramEnrolleeProductsService) Application.Service.newInstance(CareProgramEnrolleeProductsService.class);
			}
			return Service;
		}
		set;
	}

	public CareProgramEnrolleeProducts(List<CareProgramEnrolleeProduct> records)
	{
		super(records, CareProgramEnrolleeProduct.SObjectType);
		Configuration.disableTriggerCRUDSecurity();
	}

    public Map<Id,String> getProductNamesByCpeId(Map<Id,String> productNameMap)
    {
        for(CareProgramEnrolleeProduct cpepObj:(List<CareProgramEnrolleeProduct>) records)
        {
            productNameMap.put(cpepObj.CareProgramEnrollee.AccountId,cpepObj.CareProgramProduct.Product.Name);
        }
        return productNameMap;
    }

	public override void onAfterInsert()
	{
		grantAccessToPublicGroups();
		Configuration.enforceTriggerCRUDSecurity();
	}

	public void grantAccessToPublicGroups()
	{
		Service.grantAccessToPublicGroups(this);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CareProgramEnrolleeProducts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
}