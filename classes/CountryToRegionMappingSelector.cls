public class CountryToRegionMappingSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CountryToRegionMapping__mdt.Country__c,
				CountryToRegionMapping__mdt.DeveloperName,
				CountryToRegionMapping__mdt.Region__c,
				CountryToRegionMapping__mdt.MasterLabel
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CountryToRegionMapping__mdt.sObjectType;
	}

	public List<CountryToRegionMapping__mdt> selectAll(String Country)
	{
		return (List<CountryToRegionMapping__mdt>) Database.query(
				newQueryFactory()
						.setCondition('MasterLabel =:Country')
						.toSOQL()
		);
	}
}