public with sharing class CareProgramProducts extends fflib_SObjectDomain
{
	public CareProgramProducts(List<CareProgramProduct> records)
	{
		super(records);
	}

	public Map<Id, CareProgramProduct> getByCareProgramIds()
	{
		Map<Id, CareProgramProduct> careProgramProductsByCareProgramId = new Map<Id, CareProgramProduct>();
		for (CareProgramProduct objCareProgramProduct : (List<CareProgramProduct>) records)
		{
			careProgramProductsByCareProgramId.put(objCareProgramProduct.CareProgramId, objCareProgramProduct);
		}
		return careProgramProductsByCareProgramId;
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CareProgramProducts(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}

}