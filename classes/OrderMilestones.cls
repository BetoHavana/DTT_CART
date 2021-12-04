public with sharing class OrderMilestones extends sflib_SObjectDomain
{
    static final String MANUFACTURING = 'Manufacturing';
	static final String COMMA = ',';

	private OrderMilestonesService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (OrderMilestonesService) Application.Service.newInstance(OrderMilestonesService.class);
			}
			return Service;
		}
		set;
	}

    public OrderMilestones(List<OrderMilestones__c> records)
    {
        super(records, OrderMilestones__c.SObjectType);
    }

    public Type getType()
    {
        return OrderMilestones.Class;
    }

	public Set<Id> getOrderIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, OrderMilestones__c.Order__c);
	}

    public override void onAfterInsert()
    {
        callAnaplanToUpdateManufacturingMilestones();
	    updateOrderForOrderMilestone();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        callAnaplanToUpdateManufacturingMilestonesIfEligible();
    }

    public void callAnaplanToUpdateManufacturingMilestonesIfEligible()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerAnaplanCallout());
		if(changedRecords.isEmpty()) return ;
		new OrderMilestones(changedRecords).callAnaplanToUpdateManufacturingMilestones();
	}

	public void callAnaplanToUpdateManufacturingMilestones()
	{
		OrderMilestonesService orderMilestonesService = (OrderMilestonesService) Application.Service.newInstance(OrderMilestonesService.class);
		orderMilestonesService.callAnaplanToUpdateManuFactutingMilestones(selectOrderMilestonesWithManufacturingType());
	}

	public OrderMilestones selectOrderMilestonesWithManufacturingType()
	{
        List<OrderMilestones__c> filteredRecords = (List<OrderMilestones__c> ) new sflib_SObjects(Records)
													.filter(new sflib_Criteria()
													.EqualTo(OrderMilestones__c.MilestoneType__c,MANUFACTURING))
		                                            .getSobjects();
		return new OrderMilestones(filteredRecords);
	}

	Set<Schema.SObjectField> fieldsToTriggerAnaplanCallout()
	{
		return new Set<Schema.SObjectField>{OrderMilestones__c.MilestoneType__c};
	}

	public void updateOrderForOrderMilestone()
	{
		try
		{
			List<OrderMilestones__c> orderMilestonesList = new List<OrderMilestones__c>();

			for(OrderMilestones__c orderMilestone : (List<OrderMilestones__c>) records)
			{
				if(orderMilestone.MilestoneType__c <> null && orderMilestone.Name <> null && orderMilestone.MilestoneDatetime__c <> null && orderMilestone.order__c <> null)
				{
					orderMilestonesList.add(orderMilestone);
				}
			}

			if (orderMilestonesList.isEmpty()) return;
			new OrderMilestones(orderMilestonesList).updateOrderBasedOnOrderMilestone();
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
	}

	public void updateOrderBasedOnOrderMilestone()
	{
		Service.checkMilestoneDetailsOnOrders(this);
	}

	public Map<String, DateTime> getLatestOrderMileStoneRecordsForOrder(List<OrderMilestones__c> orderMileStonesList)
	{
		Map<String, DateTime> dateTimeMap = new Map<String, DateTime>();
		for (OrderMilestones__c record : orderMilestonesList)
		{
			String keyValue = record.MilestoneType__c + COMMA + record.Order__c;
			if (!dateTimeMap.containsKey(keyValue))
			{
				dateTimeMap.put(keyValue, record.MilestoneDatetime__c);
			}

			else
			{
				DateTime dateTimeValue = dateTimeMap.get(keyValue);
				if (record.MilestoneDatetime__c > dateTimeValue)
				{
					dateTimeMap.put(keyValue, record.MilestoneDatetime__c);
				}
			}
		}
		return dateTimeMap;
	}

	public List<OrderMilestones__c> getOrderMileStoneRecordsTobeUpdated(Map<String, DateTime> mileStoneDateTimeMap)
	{
		List<OrderMilestones__c> milestoneList = new List<OrderMilestones__c>();

		for (OrderMilestones__c newRecord : (List<OrderMilestones__c>) records)
		{
			String newKeyVal = newRecord.MilestoneType__c + COMMA + newRecord.Order__c;

			if (!mileStoneDateTimeMap.containsKey(newKeyVal))
			{
				milestoneList.add(newRecord);
			}
			else
			{
				if (newRecord.MilestoneDatetime__c > mileStoneDateTimeMap.get(newKeyVal))
				{
					milestoneList.add(newRecord);
				}
			}
		}
		return milestoneList;
	}

    public class Constructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new OrderMilestones(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return construct(sObjectList);
        }
    }
}