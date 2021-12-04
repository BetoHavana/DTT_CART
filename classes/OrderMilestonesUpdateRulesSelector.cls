public with sharing class OrderMilestonesUpdateRulesSelector extends fflib_SObjectSelector
{
    public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
            	OrderMilestonesUpdateRules__mdt.CryoType__c,
				OrderMilestonesUpdateRules__mdt.MilestoneName__c,
				OrderMilestonesUpdateRules__mdt.OrderMilestoneStatus__c,
				OrderMilestonesUpdateRules__mdt.MilestoneSource__c,
				OrderMilestonesUpdateRules__mdt.MilestoneType__c,
				OrderMilestonesUpdateRules__mdt.SourceFieldAPIName__c,
				OrderMilestonesUpdateRules__mdt.TargetFieldAPIName__c,
				OrderMilestonesUpdateRules__mdt.TargetStatusAPIName__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return OrderMilestonesUpdateRules__mdt.sObjectType;
	}

	public List<OrderMilestonesUpdateRules__mdt> selectAll()
	{
		return (List<OrderMilestonesUpdateRules__mdt>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}
}