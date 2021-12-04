public with sharing class OrderMilestonesService
{
	private static String COINumber = 'COINumber';
	private static String COMMA = ',';
	private static String DIN = 'DIN';
    
	public void callAnaplanToUpdateManuFactutingMilestones(OrderMilestones orderMilestones)
	{
		Set<Id> ordersMileStoneIds = orderMilestones.getRecordIds();

		if (ordersMileStoneIds.isEmpty() || new Utility().getIfExecutionContextInAsync()) return ;

		callAnaplanToUpdateManuFactutingMilestones(ordersMileStoneIds);
	}

	@Future(Callout = true)
	public static void callAnaplanToUpdateManuFactutingMilestones(Set<Id> ordersMileStoneIds)
	{
		if (ordersMileStoneIds == null || ordersMileStoneIds.isEmpty()) return ;

		ManufacturingMilestonesUpdateService manufacturingMilestonesUpdateService = (ManufacturingMilestonesUpdateService) Application.Service
				.newInstance(ManufacturingMilestonesUpdateService.class);
		manufacturingMilestonesUpdateService.callAnaplanToUpdateManufacturingMilestones(ordersMilestoneIds);
	}

	public void checkMilestoneDetailsOnOrders(OrderMilestones milestones){

		List<OrderMilestones__c> ordMilestones = new List<OrderMilestones__c>();
		List<OrderMilestones__c> ordMilestonesListForShipment = new List<OrderMilestones__c>();
		ordMilestones = ((OrderMileStonesSelector) Application.Selector.newInstance(OrderMilestones__c.SObjectType))
				.selectByOrderIdsAndOldMileStoneIds(milestones.getOrderIds(),milestones.getRecordIds());
		Map<String,DateTime> orderMileStoneDateTimeMap = new Map<String,DateTime>();
		orderMileStoneDateTimeMap = milestones.getLatestOrderMileStoneRecordsForOrder(ordMilestones);
		List<OrderMilestones__c> ordMilestonesTobeUpdated = new List<OrderMilestones__c>();
		ordMilestonesTobeUpdated = milestones.getOrderMileStoneRecordsTobeUpdated(orderMileStoneDateTimeMap);

		if (!ordMilestonesTobeUpdated.isEmpty())
		{
			updateMilestoneDetailsOnOrders(ordMilestonesTobeUpdated);
			for (OrderMilestones__c milestone : ordMilestonesTobeUpdated)
			{
				if (milestone.MilestoneDetail__c <> NULL)
				{
					ordMilestonesListForShipment.add(milestone);
				}
			}
			if (!ordMilestonesListForShipment.isEmpty())
			{
				updateOrderShipmentMilestoneDetailsOnOrders(ordMilestonesListForShipment);
			}
		}
	}

	public void updateMilestoneDetailsOnOrders(List<OrderMilestones__c> orderMilestonesList)
	{
		List<OrderMilestonesUpdateRules__mdt> metadataRecordsList = new OrderMilestonesUpdateRulesSelector().selectAll();
		if (metadataRecordsList.isEmpty()) return;
		Map<String, OrderMilestonesUpdateRules__mdt> cryoTypeMetadataRecordsMap = new Map<String, OrderMilestonesUpdateRules__mdt>();
		Map<String, OrderMilestonesUpdateRules__mdt> metadataRecordsMap = new Map<String, OrderMilestonesUpdateRules__mdt>();
		for (OrderMilestonesUpdateRules__mdt record : metadataRecordsList)
		{
			metadataRecordsMap.put(record.MilestoneName__c, record);
			if (record.CryoType__c != NULL)
			{
				String keyValue = record.CryoType__c + COMMA + record.MilestoneName__c;
				cryoTypeMetadataRecordsMap.put(keyValue, record);
			}
		}

		Set<Id> orderIdsSet = ((OrderMilestones) Application.Domain.newInstance(orderMilestonesList)).getOrderIds();
		List<Order__c> relatedOrdersList = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.selectOrdersByOrderId(orderIdsSet);
		Map<Id, Order__c> relatedOrderIdWithOrderMap = new Map<Id, Order__c>(relatedOrdersList);
		Boolean isRecSatisfying = false;
		Order__c relatedOrderRec;
		OrderMilestonesUpdateRules__mdt orderManufacturingStatusUpdateRuleRecord;
		List<Order__c> orderRecordsToBeUpdated = new List<Order__c>();
		for (OrderMilestones__c orderMilestone : orderMilestonesList)
		{
			relatedOrderRec = new Order__c();
			orderManufacturingStatusUpdateRuleRecord = new OrderMilestonesUpdateRules__mdt();
			isRecSatisfying = (!metadataRecordsMap.isEmpty()
					&& metadataRecordsMap.keySet().contains(orderMilestone.Name))
					&& ((metadataRecordsMap.get(orderMilestone.Name).MilestoneType__c).equals(orderMilestone.MilestoneType__c))
					&& ((metadataRecordsMap.get(orderMilestone.Name).MilestoneSource__c).equals(orderMilestone.MilestoneSource__c))
					&& !relatedOrderIdWithOrderMap.isEmpty()
					&& relatedOrderIdWithOrderMap.containsKey(orderMilestone.Order__c);

			if (isRecSatisfying)
			{
				relatedOrderRec = relatedOrderIdWithOrderMap.get(orderMilestone.Order__c);
				String mapKeyValue = relatedOrderRec.CryoType__c + COMMA + orderMileStone.Name;
				if (cryoTypeMetadataRecordsMap.containsKey(mapKeyValue))
				{
					orderManufacturingStatusUpdateRuleRecord = cryoTypeMetadataRecordsMap.get(mapKeyValue);
				}
				else
				{
					orderManufacturingStatusUpdateRuleRecord = metadataRecordsMap.get(orderMilestone.Name);
				}
				
				if (String.isNotBlank(orderManufacturingStatusUpdateRuleRecord.OrderMilestoneStatus__c))
				{
					relatedOrderRec.put(orderManufacturingStatusUpdateRuleRecord.TargetStatusAPIName__c, orderManufacturingStatusUpdateRuleRecord.OrderMilestoneStatus__c);
				}
				relatedOrderRec.put(orderManufacturingStatusUpdateRuleRecord.TargetFieldAPIName__c,
						orderMilestone.get(orderManufacturingStatusUpdateRuleRecord.SourceFieldAPIName__c));

				orderRecordsToBeUpdated.add(relatedOrderIdWithOrderMap.get(orderMilestone.Order__c));
			}
		}
		if (!orderRecordsToBeUpdated.isEmpty())
		{
			fflib_ISObjectUnitOfWork orderUnitOfWork = Application.UnitOfWork.newInstance();
			orderUnitOfWork.registerDirty(orderRecordsToBeUpdated);
			orderUnitOfWork.commitWork();
		}
	}

	public void updateOrderShipmentMilestoneDetailsOnOrders(List<OrderMilestones__c> milestonesList)
	{
		Set<String> shipmentMilestonesSet = new Set<String>();
		List<OrderMilestonesDetails__mdt> metadataRecordsList = new OrderMilestonesDetailsSelector().selectAll();
		if (metadataRecordsList.isEmpty()) return;
		Map<String, List<OrderMilestonesDetails__mdt>> metadataRecordsMap = new Map<String, List<OrderMilestonesDetails__mdt>>();
		for (OrderMilestonesDetails__mdt record : metadataRecordsList)
		{
			shipmentMilestonesSet.add(record.eventName__c);
			if (!metadataRecordsMap.containsKey(record.eventName__c))
			{
				metadataRecordsMap.put(record.eventName__c, new List<OrderMilestonesDetails__mdt> {record});
			}
			else
			{
				metadataRecordsMap.get(record.eventName__c).add(record);
			}
		}
		List<OrderMilestones__c> finalMileStonesList = new List<OrderMilestones__c>();
		for (OrderMilestones__c ordMileStone : milestonesList)
		{
			if (shipmentMilestonesSet.contains(ordMilestone.Name))
			{
				finalMileStonesList.add(ordMilestone);
			}
		}
		List<Order__c> ordersTobeUpdated = new List<Order__c>();
		if (!finalMileStonesList.isEmpty())
		{
			for (OrderMilestones__c ord : finalMileStonesList)
			{
				Order__c orderRec = new Order__c();
				orderRec.Id = ord.Order__c;
				eventDetails eventWrapper = eventDetails.parse(ord.MilestoneDetail__c);
				for (OrderMilestonesDetails__mdt metadataRec : metadataRecordsMap.get(ord.Name))
				{
					if (!String.isBlank(eventWrapper.DIN)
							&& metadataRec.SourceFieldAPIName__c.equals(DIN))
					{
						orderRec.put(metadataRec.TargetFieldAPIName__c, eventWrapper.DIN);
					}
					if (!String.isBlank(eventWrapper.COINumber)
							&& metadataRec.SourceFieldAPIName__c.equals(COINumber))
					{
						orderRec.put(metadataRec.TargetFieldAPIName__c, eventWrapper.COINumber);
					}
				}
				ordersTobeUpdated.add(orderRec);
			}
		}

		if (!ordersTobeUpdated.isEmpty())
		{
			fflib_ISObjectUnitOfWork orderUnitOfWork = Application.UnitOfWork.newInstance();
			orderUnitOfWork.registerDirty(ordersTobeUpdated);
			orderUnitOfWork.commitWork();
		}
	}
	public class eventDetails
	{
		String DIN { get; set; }
		String COINumber { get; set; }
		public eventDetails(JSONParser parser)
		{
			while (parser.nextToken() != System.JSONToken.END_OBJECT)
			{
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
				{
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL)
					{
						switch on text
						{
							when 'DIN'
							{
								DIN = parser.getText();
							}
							when 'COINumber'
							{
								COINumber = parser.getText();
							}
						}
					}
				}
			}
		}
	}
	public static eventDetails parse(String json)
	{
		System.JSONParser parser = System.JSON.createParser(json);
		return new eventDetails(parser);
	}
}