@isTest
public with sharing class LocationTest
{
	private static final String ADDRESSINFO = '{"addressLine1":"Audelia RoadLake Highlands","city":"Dallas","state":"TX","country":"US","zipCode":"75243","locationType":"Pickup"}';
	private static final String APICALLTYPE = 'getInfoOnPlaceId';
	private static final String AUTOCOMPLETEAPI = 'autocompleteAPI';
    private static final String CASEMANAGER = 'CaseManager';
	private static final String EXPECTEDADDRESSLINE1 = '1122 Lois Lane';
	private static final String INTERNALBASEUSER = 'Internal Base User';
	private static final String MOCKMSG = 'Mock Class Didnt return Expected Value';
	private static final String PATIENTMANAGEMENT = 'PatientManagement';
	private static final String PLACEID = 'ChIJ55Of1dEquIcRAOuraYBeznU';
	private static final String SEARCHPHRASE = '1122';
	private static final String SITEMANAGEMENT = 'SiteManagement';
	private static final String UNSUCCESSFULLLOCATIONCREATION = 'Location Record Creation Unsucessfull';


	@isTest static void itShouldSearchLocationOnGoogleAPI()
	{
		//GIVEN We have access to Google API.
		Test.setMock(HttpCalloutMock.class, new GoogleAPIMockHttpResponse(AUTOCOMPLETEAPI));
		Test.startTest();
		//WHEN User enter the search string in the search bar.
		List<LookupSearchResult> address = AddressSearchController.placeSearch(SEARCHPHRASE);
		Test.stopTest();
		//THEN - It should return an available address for the searched phrase.
		System.assertEquals(address.size(), 1, MOCKMSG);
	}

	@isTest static void itShouldGetEntireAddressInfoBasedOnPlaceId()
	{
		//GIVEN - We have list of available addresses options.
		Test.setMock(HttpCalloutMock.class, new GoogleAPIMockHttpResponse(APICALLTYPE));
		Test.startTest();
		String placeId = PLACEID;
		String expectedAddressLine1 = EXPECTEDADDRESSLINE1;
		//WHEN User selects one address from the list of options.
		AddressSearchController.AddressInfo address = AddressSearchController.getEntireAddressInfoBasedOnPlaceId(placeId);
		Test.stopTest();
		//THEN It should get the entire address information of selected address.
		System.assertEquals(address.addressLine1, expectedAddressLine1, MOCKMSG);
	}

	@isTest static void itShouldCreateLocationRecord()
	{
		//GIVEN When User is Internal Base User and has Site Management and Patient Management permission sets assigned.
		Id profileId = ((ProfilesSelector) Application.Selector.newInstance(Profile.SObjectType)).selectByName(INTERNALBASEUSER)[0].Id;

		User user = new User(Alias = 'testName', Email = 'test@test.com',
				EmailEncodingKey = 'UTF-8', LastName = 'testName', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = profileId, IsActive = true,
				TimeZoneSidKey = 'America/New_York', Username = 'testNametest@test.com');

		insert user;
		List<PermissionSetAssignment> psets = new List<PermissionSetAssignment>();
		PermissionSetAssignment pset = new PermissionSetAssignment();
		pset.PermissionSetId = ((PermissionSetSelector) Application.Selector.newInstance(PermissionSet.SObjectType))
				.selectByNames(new Set<String>{PATIENTMANAGEMENT})[0].Id;
		pset.AssigneeId = user.Id;
		psets.add(pset);
		pset = new PermissionSetAssignment();
		pset.PermissionSetId = ((PermissionSetSelector) Application.Selector.newInstance(PermissionSet.SObjectType))
				.selectByNames(new Set<String>{SITEMANAGEMENT})[0].Id;
		pset.AssigneeId = user.Id;
		psets.add(pset);
        pset = new PermissionSetAssignment();
		pset.PermissionSetId = ((PermissionSetSelector) Application.Selector.newInstance(PermissionSet.SObjectType))
				.selectByNames(new Set<String>{CASEMANAGER})[0].Id;
		pset.AssigneeId = user.Id;
		psets.add(pset);
		insert psets;
		Test.startTest();
		//WHEN User tries to save the address information.
		Id accountID;
		System.runAs(user)
		{
			Account account = TestDataFactory.getPatientAccountsToInsert(1);
			insert account;
			accountID = account.Id;
			String addressInfo = ADDRESSINFO;
			AddressSearchController.createLocationRecord(addressInfo, account.Id);
		}
		Test.stopTest();
		//THEN It should create location and associated location record.
		System.assert(![SELECT Id FROM Location].isEmpty(), UNSUCCESSFULLLOCATIONCREATION);
		System.assert(!((AssociatedLocationsSelector) Application.Selector
				.newInstance(Schema.AssociatedLocation.SObjectType))
				.getAddressesForSites(new Set<Id>{accountID}).isEmpty(), UNSUCCESSFULLLOCATIONCREATION);
	}
}