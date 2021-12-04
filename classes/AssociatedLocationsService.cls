public with sharing class AssociatedLocationsService
{
	static final String DROPOFF = 'Drop Off';

	public Map<Id, Schema.AssociatedLocation> getAccountsAddressInfo(Set<Id> accountIds)
	{
		Map<Id, Schema.AssociatedLocation> addressInfoPerPatient = new Map<Id, Schema.AssociatedLocation>();

		AssociatedLocationsSelector associatedLocationSelector = (AssociatedLocationsSelector)
				Application.Selector.newInstance(Schema.AssociatedLocation.SObjectType);

		for (Schema.AssociatedLocation locationInfo : associatedLocationSelector.selectAccountAddressInfo(accountIds))
		{
			if (DROPOFF.equals(LocationInfo.Type))
			{
				addressInfoPerPatient.put(locationInfo.ParentRecordId, locationInfo);
			}
		}

		return addressInfoPerPatient;
	}
}