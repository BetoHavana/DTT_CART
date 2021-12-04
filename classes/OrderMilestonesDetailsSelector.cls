public with sharing class OrderMilestonesDetailsSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				OrderMilestonesDetails__mdt.eventName__c,
				OrderMilestonesDetails__mdt.eventSource__c,
				OrderMilestonesDetails__mdt.eventType__c,
				OrderMilestonesDetails__mdt.SourceFieldAPIName__c,
				OrderMilestonesDetails__mdt.TargetFieldAPIName__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return OrderMilestonesDetails__mdt.sObjectType;
	}

	public List<OrderMilestonesDetails__mdt> selectAll()
	{
		return (List<OrderMilestonesDetails__mdt>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}
}