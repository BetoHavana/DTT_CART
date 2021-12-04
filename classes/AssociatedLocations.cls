public with sharing class AssociatedLocations extends fflib_SObjectDomain
{
	public AssociatedLocations(List<Schema.AssociatedLocation> records)
	{
		super(records, Schema.AssociatedLocation.SObjectType);
	}

	public Map<String, String> getAssociatedLocationForCryoSite()
	{
		Map<String, String> cryoSiteAddressMap = new Map<String, String>();
		for (Schema.AssociatedLocation assoc : (List<Schema.AssociatedLocation>) records)
		{
			String mapKey = assoc.ParentRecordId + ',' + assoc.Type;
			if (!cryoSiteAddressMap.containsKey(mapKey))
			{
				cryoSiteAddressMap.put(mapKey, assoc.Address__c);
			}
		}
		return cryoSiteAddressMap;
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AssociatedLocations(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
}