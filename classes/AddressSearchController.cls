public with sharing class AddressSearchController
{
	private static final String ADMINISTRATIVE_AREA_LEVEL_1 = 'administrative_area_level_1';
	private static final String AUTO_COMPLETE = 'autocomplete';
	private static final String AND_KEYEQUALS = '&key=';
	private static final String SPACE = ' ';
	private static final String COUNTRY_LABEL = 'country';
	private static final String DETAILS = 'details';
	private static final String GET = 'GET';
	private static final String LOCALITY = 'locality';
	private static final String POSTAL_CODE = 'postal_code';
	private static final String REPLACEME = 'REPLACEME';
	private static final String ROUTE = 'route';
	private static final String STREET_NUMBER = 'street_number';
	private static final String TYPEEQUALS_GEOCODE = '&types=geocode';
	private static final String UTF_8 = 'UTF-8';

	@AuraEnabled(Cacheable=true)
	public static List<LookupSearchResult> placeSearch(String searchPhrase)
	{
		try
		{
			String googleApiEndpointURL = Label.AddressSearchGoogleAPiEndpoint;
			googleApiEndpointURL = googleApiEndpointURL.replace(REPLACEME, AUTO_COMPLETE);
			googleApiEndpointURL += 'input=' +
					urlEncode(searchPhrase, UTF_8) + TYPEEQUALS_GEOCODE + getKey();
			List<LookupSearchResult> results = new List<LookupSearchResult>();

			String response = getResponse(googleApiEndpointURL);
			List<PlaceFinder.Address> aList = PlaceFinder.parse(response);
			for (PlaceFinder.Address s : aList)
			{
				results.add(
						new LookupSearchResult(
								s.placeId,
								'',
								'custom:custom106',
								s.description,
								'',
								s.placeId
						)
				);
			}
			return results;
		}
		catch (Exception exp)
		{
			AuraHandledException auraHandledException = new AuraHandledException(exp.getMessage());
			auraHandledException.setMessage(exp.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static AddressInfo getEntireAddressInfoBasedOnPlaceId(String placeId)
	{
		try
		{
			String googleApiEndpointURL = Label.AddressSearchGoogleAPiEndpoint;
			googleApiEndpointURL = googleApiEndpointURL.replace(REPLACEME, DETAILS);
			googleApiEndpointURL += 'placeid=' + urlEncode(placeId, UTF_8) + getKey();
			return parseResponseNPassToUI(getResponse(googleApiEndpointURL));
		}
		catch (Exception exp)
		{
			AuraHandledException auraHandledException = new AuraHandledException(exp.getMessage());
			auraHandledException.setMessage(exp.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static Boolean createLocationRecord(String addressInfo, String accountId)
	{
		Boolean creationSucessFull = false;
		Savepoint sp = Database.setSavepoint();
		try
		{
			if (addressInfo != null)
			{
				AddressInfo address = (AddressInfo) JSON.deserialize(addressInfo, AddressInfo.class);
				Schema.Location newLocationRecord = new Schema.Location();
				newLocationRecord.AddressLine1__c = address.addressLine1;
				newLocationRecord.AddressLine2__c = address.addressLine2;
				newLocationRecord.City__c = address.city;
				newLocationRecord.State__c = address.state;
				newLocationRecord.Country__c = address.country;
				newLocationRecord.PostalCode__c = address.zipCode;
				newLocationRecord.LocationType = address.locationType;
				newLocationRecord.Name = address.addressLine2 == null ? address.locationType + SPACE + Label.Address + SPACE + address.addressLine1 : address.locationType + SPACE + Label.Address + SPACE + address.addressLine2;

				AssociatedLocation assosciatedLocation = createAssocitedLocation(accountId, address.locationType);
				fflib_ISObjectUnitOfWork locationUnitOfWork = Application.UnitOfWork.newInstance();
				locationUnitOfWork.registerNew(newLocationRecord);
				locationUnitOfWork.registerNew(assosciatedLocation, AssociatedLocation.LocationId, newLocationRecord);
				locationUnitOfWork.commitWork();
				creationSucessFull = true;
			}
			else
			{
				creationSucessFull = false;
			}
			return creationSucessFull;
		}
		catch (Exception exp)
		{
			Database.rollback(sp);
			AuraHandledException auraHandledException = new AuraHandledException(exp.getMessage());
			auraHandledException.setMessage(exp.getStackTraceString());
			throw auraHandledException;
		}
	}

	private AddressSearchController()
	{

	}

	private static String getResponse(String strURL)
	{
		Http httpHeader = new Http();
		HttpRequest req = new HttpRequest();
		String responseBody;
		HttpResponse res = new HttpResponse();
		req.setMethod(GET);
		req.setEndpoint(strURL);
		req.setTimeout(120000);
		res = httpHeader.send(req);
		responseBody = res.getBody();
		return responseBody;
	}

	private static String getKey()
	{
		return AND_KEYEQUALS + System.Label.APIKey;
	}

	private static String urlEncode(String content, String format)
	{
		return EncodingUtil.urlEncode(content, format);
	}

	private static AddressInfo parseResponseNPassToUI(String response)
	{
		AddressInfo addressInfo = new AddressInfo();
		if (String.isNotBlank(response))
		{
			AddressSearchController output = new AddressSearchController();
			output = (AddressSearchController) JSON.deserialize(response, AddressSearchController.class);
			if (output != null && output.result != null)
			{
				Result result = new Result();
				result = output.result;
				List<Address_components> adressList = new List<Address_components>();
				adressList = result.address_components;
				addressInfo = processAddressList(adressList);
			}
		}
		return addressInfo;
	}

	private static AddressInfo processPostalCode(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(POSTAL_CODE))
		{
			addressInfo.zipCode = address.long_name;
		}
		return addressInfo;
	}

	private static AddressInfo processCountry(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(COUNTRY_LABEL))
		{
			addressInfo.country = address.short_name;
		}
		return addressInfo;
	}

	private static AddressInfo processState(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(ADMINISTRATIVE_AREA_LEVEL_1))
		{
			addressInfo.state = address.short_name;
		}
		return addressInfo;
	}

	private static AddressInfo processCity(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(LOCALITY))
		{
			addressInfo.city = address.long_name;
		}
		return addressInfo;
	}

	private static AddressInfo processStreetNumber(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(STREET_NUMBER))
		{
			addressInfo.addressLine1 = addressInfo.addressLine1 == null ? address.long_name : addressInfo.addressLine1 + SPACE + address.long_name;
		}
		return addressInfo;
	}

	private static AddressInfo processRoute(List<String> types, AddressInfo addressInfo, Address_Components address)
	{
		if (types.contains(ROUTE))
		{
			addressInfo.addressLine1 = addressInfo.addressLine1 == null ? address.long_name : addressInfo.addressLine1 + SPACE + address.long_name;
		}
		return addressInfo;
	}

	private static AddressInfo processAddressList(List<Address_components> adressList)
	{
		AddressInfo addressInfo = new AddressInfo();
		if (!adressList.isEmpty())
		{
			List<String> types = new List<String>();
			for (Address_components address : adressList)
			{
				types = address.types;
				if (!types.isEmpty())
				{
					processPostalCode(types, addressInfo, address);
					processCountry(types, addressInfo, address);
					processState(types, addressInfo, address);
					processCity(types, addressInfo, address);
					processStreetNumber(types, addressInfo, address);
					processRoute(types, addressInfo, address);
				}
			}
		}
		return addressInfo;
	}

	private static AssociatedLocation createAssocitedLocation(String AccountId, String addressType)
	{
		AssociatedLocation newAssociatedLocation = new AssociatedLocation();
		List<Account> accounts = new AccountsSelector().selectContactsByAccountId(new Set<Id> {AccountId});
		if (accounts != null && !accounts.isEmpty() && accounts[0].isPersonAccount && accounts[0].contacts != null && !accounts[0].contacts.isEmpty())
		{
			newAssociatedLocation.Contact__c = accounts[0].contacts[0].Id;
		}
		newAssociatedLocation.ParentRecordId = AccountId;
		newAssociatedLocation.Type = addressType;
		return newAssociatedLocation;
	}

	public class AddressInfo
	{
		@AuraEnabled
		public String addressLine1 { get; set; }
		@AuraEnabled
		public String addressLine2 { get; set; }
		@AuraEnabled
		public String city { get; set; }
		@AuraEnabled
		public String state { get; set; }
		@AuraEnabled
		public String country { get; set; }
		@AuraEnabled
		public String zipCode { get; set; }
		@AuraEnabled
		public String locationType { get; set; }
	}

	public class Address_components
	{
		private String long_name;
		private String short_name;
		private List<String> types;
	}

	public class Result
	{
		private List<Address_components> address_components;
	}

	public Result result;
}
