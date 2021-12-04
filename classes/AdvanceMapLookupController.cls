public with sharing class AdvanceMapLookupController
{
	private AdvanceMapLookupController()
	{

	}
	@AuraEnabled(Cacheable=true)
	public static List<AddressTypeData> getPicklistDataForAddressType()
	{
		try
		{
			List<AddressTypeData> picklistInfos = new List<AddressTypeData>();
			Schema.DescribeFieldResult fieldResult =
					Location.LocationType.getDescribe();
			List<Schema.PicklistEntry> picklistEntryList= fieldResult.getPicklistValues();
			for (Schema.PicklistEntry ple : picklistEntryList)
			{
				picklistInfos.add(new AddressTypeData(ple.getLabel(), ple.getValue()));
			}
			return picklistInfos;
		}
		catch (Exception exp)
		{
			AuraHandledException auraHandledException = new AuraHandledException(exp.getMessage());
			auraHandledException.setMessage(exp.getStackTraceString());
			throw auraHandledException;
		}
	}

	public class AddressTypeData
	{
		@AuraEnabled
		public String label { get; set; }
		@AuraEnabled
		public String value { get; set; }
		public AddressTypeData(String label, String value)
		{
			this.label = label;
			this.value = value;
		}
	}
}
