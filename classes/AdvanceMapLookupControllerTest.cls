@isTest
public with sharing class AdvanceMapLookupControllerTest
{

	private static final String PICKUP = 'Pickup';
	private static final String DROPOFF = 'Drop Off';
	private static final String PICKUPnDROPOFF = 'Pickup and Drop Off';
	private static final String PATIENT = 'Patient';
	private static final String PATIENTCAREGIVER = 'Caregiver';
	private static final String ERRORMESSAGE = 'Didnot fetch expected values';

	@isTest
	static void itShouldFetchLocationTypesForAddress()
	{
		Test.startTest();
		// GIVEN - We are creating an Associated location
		List<AdvanceMapLookupController.AddressTypeData> picklistInfo = new List<AdvanceMapLookupController.AddressTypeData>();
		// WHEN - We are selecting an Address type
		picklistInfo = (List<AdvanceMapLookupController.AddressTypeData>) AdvanceMapLookupController.getPicklistDataForAddressType();
		Test.stopTest();
		// THEN - It should fetch matching and relevant location types available for an Address.
		System.assertEquals(picklistInfo[0].value, PICKUP, ERRORMESSAGE);
		System.assertEquals(picklistInfo[1].value, DROPOFF, ERRORMESSAGE);
		System.assertEquals(picklistInfo[2].value, PICKUPnDROPOFF, ERRORMESSAGE);
		System.assertEquals(picklistInfo[3].value, PATIENT, ERRORMESSAGE);
		System.assertEquals(picklistInfo[4].value, PATIENTCAREGIVER, ERRORMESSAGE);
	}
}
