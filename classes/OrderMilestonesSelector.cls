public with sharing class OrderMilestonesSelector extends sflib_SObjectSelector
{
	string OrderIds = OrderMilestones__c.Order__c.getDescribe().getName();
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				OrderMilestones__c.MilestoneDatetime__c,
				OrderMilestones__c.MilestoneDetail__c,
				OrderMilestones__c.MilestoneType__c,
				OrderMilestones__c.Name,
				OrderMilestones__c.Order__c,
				OrderMilestones__c.MilestoneSource__c
		};
	}

	public SObjectType getSObjectType()
	{
		return OrderMilestones__c.SObjectType;
	}

    public List<OrderMilestones__c> selectById(Set<Id> orderMilestoneIds)
	{
		return (List<OrderMilestones__c>) Database.query(
				newQueryFactory()
            			.selectField('Order__r.CartOrderId__c')
						.setCondition(OrderMilestones__c.Id.getDescribe().getName()+' IN :orderMilestoneIds')
						.toSOQL());
    }

    public List<OrderMilestones__c> selectByOrderIds(Set<Id> orderIds)
    {
       return (List<OrderMilestones__c>) selectByFieldInIdSet(OrderMilestones__c.Order__c,orderIds);
    }

	public List<OrderMilestones__c> selectByOrderIdAndMilestoneNames(Set<Id> setOfOrderIds, List<String> milestoneNames)
	{
		return (List<OrderMilestones__c>) Database.query(
				newQueryFactory()
						.selectField('Order__r.ManufacturingStatus__c')
						.selectField('Order__r.ManufacturingMilestoneDateTime__c')
						.selectField('Order__r.ShippingStatus__c')
						.selectField('Order__r.FinalDPDropOffDateAndTime__c')
						.selectField('Order__r.FinalDPPickupDateAndTime__c')
						.selectField('Order__r.FreshCellDropOffDateAndTime__c')
						.selectField('Order__r.FreshCellPickupDateAndTime__c')
						.selectField('Order__r.CryoCellDropOffDateAndTime__c')
						.selectField('Order__r.CryoCellPickupDateAndTime__c')
						.selectField('Order__r.FinalDPDateinVineti__c')
						.selectField('Order__r.OrderRescheduledinVineti__c')
						.selectField('Order__r.VinetiCOI__c')
						.setCondition('Order__c IN: setOfOrderIds AND Name IN: milestoneNames')
						.toSOQL()
		);
	}

	public List<OrderMilestones__c> selectByOrderIdsAndOldMileStoneIds(Set<Id> orderIds,Set<Id> mileStoneIds)
	{
		return (List<OrderMilestones__c>) Database.query(
				newQueryFactory()
						.setCondition('Order__c IN :orderIds AND Id NOT IN :mileStoneIds')
						.toSOQL()
		);
	}

}