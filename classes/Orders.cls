public with sharing class Orders extends sflib_SObjectDomain
{
	private static final String APHPOPENDING = 'Aph PO Pending';
	private static final String APHPORECEIVED = 'Aph PO Received';
	private static final String DROPOFF = 'Drop Off';
	private static final String OrderCancelled = 'Order Cancelled';
	private static final String OrderWithdrawn = 'Withdrawn';
	private static final String ORDERCANCELLATIONREQUESTED = 'Order Cancellation Requested';
	private static final String ORDERSUBMITTED = 'Order Submitted';
	private static final String ORDER_VERIFIED = 'Order Verified';
    private static final String SLOT_CONFIRMED = 'Slot Confirmed';
	private static final String ORDERRESCHEDULED = 'Order Rescheduled';
	private static final String PICKUP = 'Pickup';
	private static final String QRCOMPLETE = 'QR Complete';
	private static final String RETRY = 'Retry';

	public Type getType()
	{
		return Orders.class;
	}
	private OrdersService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (OrdersService) Application.Service.newInstance(OrdersService.class);
			}
			return Service;
		}
		set;
	}

	public Orders(List<Order__c> records)
	{
		super(records, Order__c.SObjectType);
	}

	public Map<Id, Order__c> getOrdersByAccountId()
	{
		Map<Id, Order__c> ordersByAccountIdMap = new Map<Id, Order__c>();
		for (Order__c record : (List<Order__c>) Records)
		{
			if (record.Patient__c != null)
			{
				ordersByAccountIdMap.put(record.Patient__c, record);
			}
		}
		return ordersByAccountIdMap;
	}

	public override void onBeforeInsert()
	{
		Service.generateOrderId((List<Order__c>) Records);
	}

	public override void onAfterInsert()
	{
		grantAccessToPublicGroups();
		callSAPToUpdateSalesOrder();
		callAnaplanToUpdateManufacturingMilestone();
	}

	public override void onBeforeUpdate(Map<Id, SObject> existingRecords)
	{
		updateCryoTypeForOrders();
		updateOrdersWithSoftSlotConfirmed();
		getOrderIdMapForChangedFreshCellPickupDateAndTime();
		updateOrdersWithEstimatedDrugProductDeliveryDate();
		updateAphPOStatus((List<Order__c>) Records);
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		TasksService tsksService = (TasksService) Application.Service.newInstance(TasksService.class);

		callSAPIfSDPOPopulatedNSalesOrderToSAPStatusUpdate();
		callSAPIfFreshOrCryoCellPickupDateAndTimePopulatedOrASNToAnaplanStatusUpdate();
		callAnaplanManufacturingMilestoneStatusChanged();
		sendRequestToSpecialityDistributorOnPurchaseOrder();
		tsksService.closeTasks((List<Order__c>) Records, (Map<Id, Order__c>) existingRecords);
		createAdhocTasksforVeinToVein();
		updateConfirmedInfusionDateinPSEnrollee();
		onChangedOrderStatusToCanceledCreateCase(existingRecords);
		updateCaseCancellationReason((Map<Id,Order__c>)existingRecords);
		onOrderManufacturingStatusChange(existingRecords);
		onOrderRescheduled(existingRecords);
	}

	public void onOrderRescheduled(Map<Id, SObject> existingRecords)
	{
		Set<Schema.SObjectField> sObjectField = new Set<Schema.SObjectField> {Order__c.OrderStatus__c};
		List<SObject> changedRecords = getChangedRecords(sObjectField);
		if (changedRecords.isEmpty()) return ;
		fetchNotificationAlertDetails(changedRecords, existingRecords.values(), sObjectField);
	}

	public void updateAphPOStatus(List<Order__c> orderList)
	{
		for (Order__c order : orderList)
		{
			setApheresisPOStatus(String.isNotBlank(order.ApheresisPO__c) ? APHPORECEIVED : APHPOPENDING);
		}
	}

	public void onOrderManufacturingStatusChange(Map<Id, SObject> existingRecords)
	{
		Set<Schema.SObjectField> sObjectField = new Set<Schema.SObjectField> {Order__c.ManufacturingStatus__c};
		List<SObject> changedRecords = getChangedRecords(sObjectField);
		if (changedRecords.isEmpty()) return ;
		fetchNotificationAlertDetails(changedRecords, existingRecords.values(), sObjectField);
	}

	public void fetchNotificationAlertDetails(List<SObject> changedRecords, List<SObject> existingRecords, Set<Schema.SObjectField> sObjectField)
	{
		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.fetchNotificationAlertDetails((List<Order__c>)
				new sflib_SObjects(changedRecords).getSObjects(), (List<Order__c>) new sflib_SObjects(existingRecords).getSObjects(), sObjectField);
	}

	public void callSAPIfSDPOPopulatedNSalesOrderToSAPStatusUpdate()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerSAPCallout());
		if (changedRecords.isEmpty()) return ;
		new Orders(changedRecords).callSAPToUpdateSalesOrder();
	}

	public void callSAPToUpdateSalesOrder()
	{
		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.callSAPToUpdateSalesOrder(selectOrdersWithSDPOOrSalesOrderToSAPStatusRetry());
	}

	public void sendRequestToSpecialityDistributorOnPurchaseOrder()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerToNotifySitePOToSDCallout());
		if (changedRecords.isEmpty())
		{
			return ;
		}
		new Orders(changedRecords).Service.sendRequestToSpecialityDistributorOnPurchaseOrder(selectOrdersToSendToPurchaseOrder());
	}

	public Orders selectOrdersToSendToPurchaseOrder()
	{
		List<Order__c> filteredRecords = (List<Order__c>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.andCriteria()
						.notEqualTo(Order__c.SitePO__c, null)
						.addOrCriteria(new sflib_Criteria()
								.equalTo(Order__c.QTCPOtoSDStatus__c, null)
								.equalTo(Order__c.QTCPOtoSDStatus__c, CalloutConstants.RETRY))
				).getSobjects();
		return new Orders(filteredRecords);
	}

	public Orders selectOrdersWithSDPOOrSalesOrderToSAPStatusRetry()
	{
		List<Order__c> filteredRecords = (List<Order__c>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.andCriteria()
						.notEqualTo(Order__c.SDPO__c, null)
						.addOrCriteria(new sflib_Criteria()
								.equalTo(Order__c.SalesOrderToSAPStatus__c, null)
								.equalTo(Order__c.SalesOrderToSAPStatus__c, CalloutConstants.RETRY))
				).getSobjects();
		return new Orders(filteredRecords);
	}

	public Orders selectOrdersWithQRComplete()
	{
		List<Order__c> filteredRecords = (List<Order__c>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.andCriteria()
						.addOrCriteria(new sflib_Criteria()
								.equalTo(Order__c.ManufacturingStatus__c, QRCOMPLETE))
				).getSobjects();
		return new Orders(filteredRecords);
	}

	public void callSAPIfFreshOrCryoCellPickupDateAndTimePopulatedOrASNToAnaplanStatusUpdate()
	{
		List<SObject> changedRecords = getChangedRecords(fieldsToTriggerAphShipNoticeAnaplanCallout());
		if (changedRecords.isEmpty()) return ;
		new Orders(changedRecords).notifyApheresisShipmentToAnaplan();
	}

	public void notifyApheresisShipmentToAnaplan()
	{
		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.notifyApheresisShipmentToAnaplan(selectOrdersWithFreshOrCryoCellPickupDateAndTimeOrASNToAnaplanStatusRetry());
	}

	public Orders selectOrdersWithFreshOrCryoCellPickupDateAndTimeOrASNToAnaplanStatusRetry()
	{
		List<Order__c> filteredRecords = (List<Order__c>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.andCriteria()
						.addOrCriteria(new sflib_Criteria()
								.notEqualTo(Order__c.CryoCellPickupDateAndTime__c, null)
								.notEqualTo(Order__c.FreshCellPickupDateAndTime__c, null))
						.addOrCriteria(new sflib_Criteria()
								.equalTo(Order__c.ASNToAnaplanStatus__c, null)
								.equalTo(Order__c.ASNToAnaplanStatus__c, RETRY))
				).getSobjects();
		return new Orders(filteredRecords);
	}

	Set<Schema.SObjectField> fieldsToTriggerSAPCallout()
	{
		return new Set<Schema.SObjectField> {Order__c.SDPO__c, Order__c.SalesOrderToSAPStatus__c};
	}

	Set<Schema.SObjectField> fieldsToTriggerToNotifySitePOToSDCallout()
	{
		return new Set<Schema.SObjectField> {Order__c.SitePO__c, Order__c.QTCPOtoSDStatus__c};
	}


	public void getOrderIdMapForChangedFreshCellPickupDateAndTime()
	{
		Map<Id, Set<String>> orderNChangedFields = new Utility().getChangedFieldsPerRecord(fieldsToCompareWhetherChanged(), ExistingRecords, Records);
		if (orderNChangedFields == null || orderNChangedFields.isEmpty()) return;
		Service.updateOrderRelatedCarePlanGoalsAndTasks(Trigger.new, orderNChangedFields);
	}

	Set<Schema.SObjectField> fieldsToTriggerAphShipNoticeAnaplanCallout()
	{
		return new Set<Schema.SObjectField> {Order__c.FreshCellPickupDateAndTime__c, Order__c.CryoCellPickupDateAndTime__c, Order__c.ASNToAnaplanStatus__c};
	}

	public Set<Id> getCarePlanIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, Order__c.CarePlanId__c);
	}

	public Set<Id> getCryoSiteIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, Order__c.CryoSite__c);
	}

	public void updateOrdersWithSoftSlotConfirmed()
	{
		Order__c oldOrder = new Order__c();

		for (Order__c order : (List<Order__c>) Records)
		{
			oldOrder = (Order__c) Trigger.oldMap.get(order.Id);
			Service.updatePOStatusIfSDPOIsNotNull(order, oldOrder);
		}
	}

	public void updateCryoTypeForOrders()
	{
		List<SObject> changedOrderRecords = getChangedRecords(
				new Set<Schema.SObjectField>
				{
						Order__c.CryoType__c
				}
		);
		if (changedOrderRecords.isEmpty()) return;
		new Orders(changedOrderRecords).updateCryoSiteForOrders();
	}

	public void updateOrdersWithEstimatedDrugProductDeliveryDate()
	{
		List<SObject> changedOrderRecords = getChangedRecords(
				new Set<Schema.SObjectField>
				{
						Order__c.ManufacturingStatus__c
				}
		);
		if (changedOrderRecords.isEmpty()) return;
		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.updateEstimatedDPDeliveryDate(new Orders(changedOrderRecords).selectOrdersWithQRComplete());
	}

	public void updateCryoSiteForOrders()
	{
		Service.updateCryoSiteInfo(this);
	}

	public Set<Id> getOrderIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, Order__c.Id);
	}

	public Map<String, Set<Id>> checkCryoSiteChangesOnOrder(List<Order__c> orderRecords)
	{
		Map<Id, String> apheresisTypeMap = new Map<Id, String>();
		Set<Id> apheresisIds = new Set<Id>();
		Set<Id> orderIdCentralSet = new Set<Id>();
		Set<Id> orderIdLocalSet = new Set<Id>();
		Map<String, Set<Id>> cryoSiteMap = new Map<String, Set<Id>>();
		for (Order__c ord : orderRecords)
		{
			apheresisTypeMap.put(ord.Id, ord.ApheresisSite__r.Type);
		}
		for (Order__c ord : (List<Order__c>) Records)
		{
			Order__c oldRecord = (Order__c) Trigger.oldMap.get(ord.Id);
			String aphType = apheresisTypeMap.get(ord.Id);
			Boolean cryoSiteCentralFlag = ((StaticConstants.cryoSiteLocal).equals(oldRecord.CryoType__c))
					&& ((StaticConstants.CryoSiteCentral).equals(ord.CryoType__c))
					&& ((StaticConstants.cryoSiteLocal).equals(aphType));
			Boolean cryoSiteLocalFlag = ((StaticConstants.CryoSiteCentral).equals(oldRecord.CryoType__c))
					&& ((StaticConstants.cryoSiteLocal).equals(ord.CryoType__c))
					&& ((StaticConstants.cryoSiteLocal).equals(aphType));

			if (cryoSiteCentralFlag)
			{
				orderIdCentralSet.add(ord.Id);
			}
			else if (cryoSiteLocalFlag)
			{
				apheresisIds.add(ord.ApheresisSite__c);
				orderIdLocalSet.add(ord.Id);
			}
		}
		if (!orderIdCentralSet.isEmpty())
		{
			cryoSiteMap.put('orderIdsCentral', orderIdCentralSet);
		}
		if (!apheresisIds.isEmpty())
		{
			cryoSiteMap.put('orderIdsLocal', orderIdLocalSet);
			cryoSiteMap.put('apheresisSiteIds', apheresisIds);
		}
		return cryoSiteMap;
	}

	public void clearCryoSiteInfoOnOrderForCentral(Set<Id> orderIds)
	{
		for (Order__c record : (List<Order__c>) Records)
		{
			if (orderIds.contains(record.Id) && (record.SlotStatus__c == null))
			{
				record.CryoSite__c = NULL;
				record.CryoSitePickupAddress__c = '';
				record.CryoSiteDropOffAddress__c = '';
			}
		}
	}

	public void updateCryoSiteInfoOnOrderForLocal(Set<Id> orderIds, Map<String, String> cryoSiteAddressMap, Map<String, Id> cryoSiteMap)
	{
		for (Order__c record : (List<Order__c>) Records)
		{
			if (orderIds.contains(record.Id))
			{
				String cryoSiteId = cryoSiteMap.get(record.ApheresisSite__c);
				String pickupAddress = cryoSiteAddressMap.get(cryoSiteId + ',' + PICKUP);
				String dropoffAddress = cryoSiteAddressMap.get(cryoSiteId + ',' + DROPOFF);
				record.CryoSite__c = cryoSiteId;
				record.CryoSitePickupAddress__c = pickupAddress;
				record.CryoSiteDropOffAddress__c = dropoffAddress;
			}
		}
	}

	private Set<Schema.SObjectField> fieldsToCompareWhetherChanged()
	{
		return new Set<Schema.SObjectField>
		{
				Order__c.ApheresisPickUpDate__c,
				Order__c.ApheresisPO__c,
				Order__c.ApheresisPOStatus__c,
				Order__c.CarePlanID__c,
				Order__c.CryoCellPickupDateAndTime__c,
				Order__c.CryoCellDropOffDateAndTime__c,
				Order__c.ConfirmedFPDeliveryDate__c,
				Order__c.FreshCellDropOffDateAndTime__c,
				Order__c.FreshCellPickupDateAndTime__c,
				Order__c.FinalDPDropOffDateAndTime__c,
				Order__c.FinalDPPickupDateAndTime__c,
				Order__c.InfusionDate__c,
				Order__c.ManufacturingStatus__c,
				Order__c.OrderPlacementInfo__c,
				Order__c.OrderStatus__c,
				Order__c.POStatus__c,
				Order__c.SlotStatus__c,
				Order__c.ShippingStatus__c
		};
	}

	public Map<Id, List<String>> validateOrderForRequiredValues(List<Order__c> orders)
	{
		Map<Id, List<String>> orderNMandatoryFields = new Map<Id, List<String>>();
		for (Order__c order : orders)
		{
			for (Schema.FieldSetMember fld : SObjectType.Order__c.fieldSets.SubmitOrderValidation.getFields())
			{
				if (order.get(fld.getFieldPath()) == null)
				{
					addOrderNRelatedFields(orderNMandatoryFields, order.Id, fld.getLabel());
				}
			}
		}
		return orderNMandatoryFields;
	}

	private void addOrderNRelatedFields(Map<Id, List<String>> orderNMandatoryFields, Id orderId, String field)
	{
		if (orderNMandatoryFields.containsKey(orderId))
		{
			orderNMandatoryFields.get(orderId).add(field);
		}
		else
		{
			orderNMandatoryFields.put(orderId, new List<String> {field});
		}
	}

	public void callAnaplanManufacturingMilestoneStatusChanged()
	{
		List<SObject> changedRecords = getChangedRecords(new Set<Schema.SObjectField> {Order__c.ManufacturingMilestoneToAnaplanStatus__c});
		if (changedRecords.isEmpty()) return ;

		new Orders(changedRecords).callAnaplanToUpdateManufacturingMilestone();
	}

	public void callAnaplanToUpdateManufacturingMilestone()
	{
		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.callAnaplanToUpdateManufacturingMilestone(selectOrdersWithMfngMilestoneToAnaplanStatusRetry());
	}

	public Orders selectOrdersWithMfngMilestoneToAnaplanStatusRetry()
	{
		List<Order__c> filteredRecords = (List<Order__c>) new sflib_SObjects(Records)
				.filter(new sflib_Criteria()
						.EqualTo(Order__c.ManufacturingMilestoneToAnaplanStatus__c,
								CalloutConstants.RETRY)).getSobjects();
		return new Orders(filteredRecords);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Orders(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
	
	@TestVisible
	private void createAdhocTasksforVeinToVein()
	{
		List<Order__c> deliveryDateChangedRecords = (List<Order__c>) getChangedRecords(new Set<Schema.SObjectField>
		{
				Order__c.ConfirmedFPDeliveryDate__c
		});
		if (!deliveryDateChangedRecords.IsEmpty())
		{
			Service.createAdhocTasksforVeinToVein(deliveryDateChangedRecords, Label.ConfirmDeliveryDate);
		}

		List<Order__c> rescheduledOrders = new List<Order__c>();
		List<Order__c> ordersWithOrderStatusChanged = (List<Order__c>) getChangedRecords(new Set<Schema.SObjectField>
		{
			Order__c.SlotStatus__c
		});
		for(Order__c newOrder : ordersWithOrderStatusChanged){
			
			if(isOrderGotRescheduled(newOrder)){
				rescheduledOrders.add(newOrder);
			}
		}
		if(!rescheduledOrders.isEmpty()){
			Service.createAdhocTasksforVeinToVein(rescheduledOrders, Label.OrderReschedule);
		}
		
		List<Order__c> apheresisChangedRecords = (List<Order__c>) getChangedRecords(new Set<Schema.SObjectField>
		{
				Order__c.ApheresisPO__c
		});
		if (!apheresisChangedRecords.IsEmpty())
		{
			Service.createAdhocTasksforVeinToVein(apheresisChangedRecords, Label.OrderPlacement);
		}
	}

	public Orders setConfirmedFPDeliveryDate(Date value)
	{
		setField(Order__c.ConfirmedFPDeliveryDate__c, value);
		return this;
	}

	public Orders setInfusionDate(Date value)
	{
		setField(Order__c.InfusionDate__c, value);
		return this;
	}

	public Orders setOrderPlacementInfo(String value)
	{
		setField(Order__c.OrderPlacementInfo__c, value);
		return this;
	}

	public Orders setOrderStatus(String value)
	{
		setField(Order__c.OrderStatus__c, value);
		return this;
	}

	public Orders setReasonForCancellation(String value){
		setField(Order__c.ReasonForOrderWithdrawal__c, value);
		return this;
	}

	public Orders setDateOfCancellationRequestTCP(Date value){
		setField(Order__c.DateOfCancellationRequestTCP__c, value);
		return this;
	}

	public Orders setResonForReschedule(String value)
	{
		setField(Order__c.ReasonforReschedule__c, value);
		return this;
	}

	public Orders setSpecifyResonForReschedule(String value)
	{
		setField(Order__c.SpecifyTheOtherReasonForReschedule__c, value);
		return this;
	}

	public Orders setSlotStatus(String value)
	{
		setField(Order__c.SlotStatus__c, value);
		return this;
	}

	public Orders setCryoSitePickupAddress(String value)
	{
		setField(Order__c.CryoSitePickupAddress__c, value);
		return this;
	}

	public Orders setCryoSiteDropOffAddress(String value)
	{
		setField(Order__c.CryoSiteDropOffAddress__c, value);
		return this;
	}

	public Orders setApheresisSite(String value)
	{
		setField(Order__c.ApheresisSite__c, value);
		return this;
	}

	public Orders setApheresisPickUpDate(Date value)
	{
		setField(Order__c.ApheresisPickUpDate__c, value);
		return this;
	}

	public Orders setProjectedProductDeliveryDate(Date value)
	{
		setField(Order__c.ProjectedDeliveryDate__c, value);
		return this;
	}

	public Orders setSitePO(String value)
	{
		setField(Order__c.SitePO__c, value);
		return this;
	}

	public Orders setAttestedForCompletion(String value)
	{
		setField(Order__c.AttestedForCompletion__c, value);
		return this;
	}

	public Orders setCryoSite(Id value)
	{
		setField(Order__c.CryoSite__c, value);
		return this;
	}

	public Orders setCryoType(String value)
	{
		setField(Order__c.CryoType__c, value);
		return this;
	}

	public Orders setApheresisPOStatus(String value)
	{
		setField(Order__c.ApheresisPOStatus__c, value);
		return this;
	}

	public void updateConfirmedInfusionDateinPSEnrollee()
	{
		List<Order__C> changedRecords = (List<Order__c>) getChangedRecords(new Set<Schema.SObjectField>
		{
				Order__c.InfusionDate__c
		});
		if (changedRecords.IsEmpty()) return;

		Service.updateConfirmedInfusionDateinPSEnrollee(changedRecords);
	}

	public Map<Id, Order__c> getByCarePlanIdOrderMap(Orders OrdersList)
	{
		Map<Id, Order__c> result = new Map<Id, Order__c>();

		for (Order__c record : (List<Order__c>) OrdersList.getRecords())
		{
			if (!result.containsKey(record.CarePlanID__c) &&
					(record.OrderStatus__c != OrderWithdrawn && record.OrderStatus__c != OrderCancelled))
			{
				result.put(record.CarePlanID__c, record);
			}
		}
		return result;
	}

	private void onChangedOrderStatusToCanceledCreateCase(Map<Id, SObject> existingRecords)
	{
		List<SObject> cancellationReqOrders  = new sflib_SObjects(Records)
													.filter(new sflib_Criteria()
													.equalTo(Order__c.OrderStatus__c,ORDERCANCELLATIONREQUESTED))
													.getSObjects();

		if (cancellationReqOrders.isEmpty())
		{
			return ;
		}

		Set<Object> orderStatusValuesToBypass = new Set<Object>{'New',OrderCancelled,'Drug Product Delivered',
													'Infusion Complete',ORDERCANCELLATIONREQUESTED};

		Set<Id> eligibleOrderIds = new Orders(existingRecords.values())
										.selectByStatusNotIn(orderStatusValuesToBypass)
										.getRecordIds();

		if(eligibleOrderIds.isEmpty())
		{
			return ;
		}

		new Orders(cancellationReqOrders)
				.selectById(eligibleOrderIds)
				.createOrderCancellationCases();

	}

	public void createOrderCancellationCases()
	{
		Service.createOrderCancellationCases(this);
	}

	public Orders selectByStatusNotIn(Set<Object> statusesToFilter)
	{
		List<SObject> orders = new sflib_SObjects(Records)
								.filter(new sflib_Criteria()
								.notInSet(Order__c.OrderStatus__c, statusesToFilter)).getSObjects();
		return new Orders(orders);
	}

	public Orders selectById(Set<Id> orderIds)
	{
		return new Orders(new sflib_SObjects(Records).filter(new sflib_Criteria()
				.inSet(Order__c.Id,orderIds))
				.getSobjects());
	}

	private void updateCaseCancellationReason(Map<Id, Order__C> existingRecords)
	{
		List<Order__c> changedRecords = (List<Order__c>) getChangedRecords(new Set<Schema.SObjectField> {Order__c.ReasonForOrderWithdrawal__c});
		Service.updateReasonForCancellationInCase(changedRecords);
	}

	public void grantAccessToPublicGroups()
    {
        Service.grantAccessToPublicGroups(this);
	}
	
	public Boolean isOrderGotRescheduled(Order__c currentOrder)
	{
		return String.isNotBlank(currentOrder.ReasonforReschedule__c) && 
			SLOT_CONFIRMED.equalsIgnoreCase(currentOrder.SlotStatus__c)
            && ORDER_VERIFIED.equalsIgnoreCase(currentOrder.OrderStatus__c);
	}
	
}