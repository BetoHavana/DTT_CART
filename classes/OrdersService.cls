public with sharing class OrdersService
{
	private static final String apheresisPickupDateScheduled = 'Apheresis Pickup Date Scheduled';
	private static final String drugProductShipped = 'Drug Product Shipped';
	private static final String INPROGRESS = 'In Progress';
	private static final String orderNew = 'New';
	private static final String ORDERINPROGRESS = 'Order In Progress';
	private static final String orderSubmitted = 'Order Submitted';
	private static final String orderVerified = 'Order Verified';
	private static final String orderReschedule = 'Reschedule';
	private static final String successStatusResponse = 'Success';
	private static final String slotUnavailable = 'Slot Unavailable';
	private static final String slotRequested = 'Slot Requested';
	private static final String ChangeTypeUpdate = 'UPDATE';
	private static final String ChangeTypeCreate = 'CREATE';
	private static final String ConfirmedFPDeliveryDate = 'ConfirmedFPDeliveryDate__c';
	private static final String ConfirmedDPDeliveryDateBusinessHours = 'Confirmed DP Delivery Date Business Hours';
	private static final String DPOKShipToSapStatus = 'DPOkToShipToSAPStatus__c';
	private static final String manufacturing = 'Manufacturing';
	private static final String MON = 'Mon';
	private static final String NullValue = 'null';
	private static final String OrderObject = 'Order__c';
	private static final String RetryValue = 'Retry';

	public static void getShipmentStatusFromSAP(list<Order__ChangeEvent> lstOrders)
	{
		set<Id> sIdRecords = new set<Id>();
		for (Order__ChangeEvent event : lstOrders)
		{
			EventBus.ChangeEventHeader header = event.ChangeEventHeader;
			for (String sOrderId : header.recordids)
			{
				if ((header.changetype == ChangeTypeUpdate || header.changetype == ChangeTypeCreate) &&
						((header.changedFields.contains(ConfirmedFPDeliveryDate) && event.get(ConfirmedFPDeliveryDate) != NullValue) ||
								(header.changedFields.contains(DPOKShipToSapStatus) && event.get(DPOKShipToSapStatus) == RetryValue)) || Test.isRunningTest())
				{
					sIdRecords.add(sOrderId);
				}
			}
		}
		if (!sIdRecords.isEmpty())
		{
			OrdersShipmentService.postOrderShipmentService(sIdRecords);
		}
	}

	public void updatePOStatusIfSDPOIsNotNull(Order__c order, Order__c oldOrder)
	{
		if (oldOrder.SDPO__c == null && order.SDPO__c <> null)
		{
			order.POStatus__c = StaticConstants.POReceived;
		}
	}

	public Map<Id, Order__c> elevatedGetOrderByPatientId(Set<Id> accountIds)
	{
		return new Orders(((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.elevatedSelectByAccountId(accountIds))
				.getOrdersByAccountId();
	}

	public void updateTasksOfOrderPlacementGoalOfCarePlanOfOrder(List<Task> listOfTasksToUpdate, fflib_ISObjectUnitOfWork uow)
	{
		if (listOfTasksToUpdate.isEmpty()) return;

		uow.registerDirty(listOfTasksToUpdate);
		uow.commitWork();
	}

	public Map<Id, Case> getCarePlanInformation(List<Order__c> listOfOrders)
	{
		return new Map<Id, Case>(
				((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
						.elevatedSelectTasksByCarePlanId(sflib_ArrayUtils.pluckIdField(listOfOrders, Order__c.CarePlanId__c)));
	}
	public Map<Id, Set<HealthCloudGA__CarePlanGoal__c>> getCarePlanIdRelatedGoals(Set<Id> carePlanIds)
	{
		Map<Id, Set<HealthCloudGA__CarePlanGoal__c>> carePlanIdNRelatedGoals = new Map<Id, Set<HealthCloudGA__CarePlanGoal__c>>();
		List<HealthCloudGA__CarePlanGoal__c> goals = ((CarePlanGoalsSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanGoal__c.SObjectType))
				.selectByCarePlanId(carePlanIds);
		for (HealthCloudGA__CarePlanGoal__c goal : goals)
		{
			if (carePlanIdNRelatedGoals.containsKey(goal.HealthCloudGA__CarePlan__c))
			{
				carePlanIdNRelatedGoals.get(goal.HealthCloudGA__CarePlan__c).add(goal);
			}
			else
			{
				carePlanIdNRelatedGoals.put(goal.HealthCloudGA__CarePlan__c,
						new Set<HealthCloudGA__CarePlanGoal__c> {goal});
			}
		}
		return carePlanIdNRelatedGoals;
	}


	public List<HealthCloudGA__CarePlanGoal__c> getGoalInformation(Set<Id> carePlanIds)
	{
		return ((CarePlanGoalsSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanGoal__c.SObjectType))
				.selectByCarePlanId(carePlanIds);
	}

	public void updateOrderRelatedCarePlanGoalsAndTasks(List<Order__c> changedOrderRecords, Map<Id, Set<String>> fieldNChangedRecords)
	{
		Map<Id, Case> carePlanInfo = getCarePlanInformation(changedOrderRecords);
		Set<Id> carePlanIds = ((Orders) Application.Domain.newInstance(changedOrderRecords)).getCarePlanIds();
		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = getGoalInformation(carePlanIds);
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		new OrderGoalTaskSync(changedOrderRecords).processOrderUpdateRules(uow, carePlanInfo, getCarePlanIdRelatedGoals(carePlanIds),
				fieldNChangedRecords, getTasksByGoal(listOfGoals));
		new OrderGoalTaskPreSync(changedOrderRecords).processOrderGoalsAndSetTaskDueDate(uow, carePlanInfo, fieldNChangedRecords);

		try
		{
			uow.commitWork();
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
		}
	}

	public Map<Id, Set<Task>> getTasksByGoal(List<HealthCloudGA__CarePlanGoal__c> goals)
	{
		Map<Id, Set<Task>> goalIdAndTaskSet = new Map<Id, Set<Task>>();
		for (Task activity : ((TasksSelector) Application.Selector.newInstance(Task.SobjectType)).selectTasksByGoals(goals))
		{
			if (goalIdAndTaskSet.containsKey(activity.HealthCloudGA__CarePlanGoal__c))
			{
				goalIdAndTaskSet.get(activity.HealthCloudGA__CarePlanGoal__c).add(activity);
			}
			else
			{
				goalIdAndTaskSet.put(activity.HealthCloudGA__CarePlanGoal__c,
						new Set<Task> {activity});
			}
		}
		return goalIdAndTaskSet;
	}

	public Map<Id, Order__c> getOrderByPatientId(Set<Id> accountIds)
	{
		return ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.selectByAccountId(accountIds)
				.getOrdersByAccountId();
	}

	public void updateStatusOfOrders(List<Order__c> ordersTobeUpdated, fflib_ISObjectUnitOfWork uow)
	{
		if (ordersTobeUpdated.isEmpty()) return;

		uow.registerDirty(ordersTobeUpdated);
		uow.commitWork();
	}

	public void updateStatusOfGoals(List<HealthCloudGA__CarePlanGoal__c> goalsTobeUpdated, fflib_ISObjectUnitOfWork uow)
	{
		if (goalsTobeUpdated.isEmpty()) return;

		uow.registerDirty(goalsTobeUpdated);
		uow.commitWork();
	}

	public void updateOrderRelatedGoalsAndTasks(List<Order__c> ordList)
	{
		List<Order__c> orderList = new List<Order__c>();
		Set<Id> caseIdsSet = new Set<Id>();
		List<HealthCloudGA__CarePlanGoal__c> listOfGoals = new List<HealthCloudGA__CarePlanGoal__c>();
		List<Task> tasksTobeUpdated = new List<Task>();
		for (Order__c orderRecord : ordList)
		{

			if (!String.isBlank(orderRecord.CryoType__c))
			{
				orderRecord.OrderStatus__c = ORDERINPROGRESS;
				orderList.add(OrderRecord);
				caseIdsSet.add(orderRecord.CarePlanID__c);
			}
		}
		if (!caseIdsSet.isEmpty())
		{

			CarePlanGoalsSelector goalSelector = ((CarePlanGoalsSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanGoal__c.SObjectType));
			listOfGoals = goalSelector.selectByCarePlanIdAndGoalNames(caseIdsSet,
					new Set<String> {Label.ShippingApheresisSiteToCryoSite, Label.ShippingCryoSiteToManufacturingSite});

			List<HealthCloudGA__CarePlanGoal__c> carePlanGoalsTobeUpdated = new List<HealthCloudGA__CarePlanGoal__c>();
			if (!listOfGoals.isEmpty())
			{
				for (HealthCloudGA__CarePlanGoal__c goal : listOfGoals)
				{
					goal.Status__c = INPROGRESS;
				}


				for (Task activity : ((TasksSelector) Application.Selector.newInstance(Task.SobjectType)).selectTasksByGoals(listOfGoals))
				{
					activity.Status = INPROGRESS;
					tasksTobeUpdated.add(activity);
				}

			}
		}
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		updateStatusOfOrders(orderList, uow);
		updateStatusOfGoals(listOfGoals, uow);
		updateTasksOfOrderPlacementGoalOfCarePlanOfOrder(tasksTobeUpdated, uow);

	}

	public Map<Id, List<String>> validateRequiredFieldsBeforeScheduling(List<Order__c> orderRecords)
	{
		return ((Orders) Application.Domain.newInstance(orderRecords)).validateOrderForRequiredValues(orderRecords);
	}

	public void updateCryoSiteInfo(Orders orders)
	{

		OrdersSelector ordSelector = (OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType);
		List<Order__c> orderRecords = ordSelector.selectOrdersByOrderId(orders.getOrderIds());
		Map<String, Set<Id>> cryoSiteMap = new Map<String, Set<Id>>();
		cryoSiteMap = orders.checkCryoSiteChangesOnOrder(orderRecords);
		Set<Id> orderIdsLocal = new Set<Id>();
		Set<Id> orderIdsCentral = new Set<Id>();
		Set<Id> apheresisSiteIds = new Set<Id>();

		if (!cryoSiteMap.isEmpty())
		{
			orderIdsLocal = cryoSiteMap.get('orderIdsLocal');
			orderIdsCentral = cryoSiteMap.get('orderIdsCentral');
			apheresisSiteIds = cryoSiteMap.get('apheresisSiteIds');
		}
		Map<String, Id> relatedSiteMap = new Map<String, Id>();
		Set<Id> cryoSiteIds = new Set<Id>();
		AccountAccountRelationsService accService = new AccountAccountRelationsService();
		if (apheresisSiteIds != NULL)
		{
			relatedSiteMap = accService.getRelatedSitesInfo(apheresisSiteIds);
			cryoSiteIds.addAll(relatedSiteMap.values());
		}

		List<Schema.AssociatedLocation> assocLocationsList = new List<Schema.AssociatedLocation>();
		assocLocationsList = ((AssociatedLocationsSelector) Application.Selector.newInstance(
				Schema.AssociatedLocation.SObjectType)).getAddressesForSites(cryoSiteIds);
		AssociatedLocations assocLocation = new AssociatedLocations(assocLocationsList);
		Map<String, String> cryoSiteAddressMap = new Map<String, String>();
		cryoSiteAddressMap = assocLocation.getAssociatedLocationForCryoSite();
		if (orderIdsCentral != NULL)
		{
			orders.clearCryoSiteInfoOnOrderForCentral(orderIdsCentral);
		}

		if (orderIdsLocal != NULL)
		{
			orders.updateCryoSiteInfoOnOrderForLocal(orderIdsLocal, cryoSiteAddressMap, relatedSiteMap);
		}
	}

	public void callSAPToUpdateSalesOrder(Orders ordersInfo)
	{
		Set<Id> ordersIds = ordersInfo.getRecordIds();

		if (ordersIds.isEmpty() || new Utility().getIfExecutionContextInAsync()) return ;

		callSAPToUpdateSalesOrder(ordersIds);
	}

	@Future(Callout = true)
	public static void callSAPToUpdateSalesOrder(Set<Id> orderIds)
	{
		if (orderIds == null || orderIds.isEmpty()) return ;

		SalesOrderUpdateService salesOrderUpdateService = (SalesOrderUpdateService) Application.Service.newInstance(SalesOrderUpdateService.class);
		salesOrderUpdateService.callSAPToUpdateSalesOrder(orderIds);
	}

	public void sendRequestToSpecialityDistributorOnPurchaseOrder(Orders ordersInfo)
	{
		Set<Id> ordersIds = ordersInfo.getRecordIds();

		if (ordersIds.isEmpty() || new Utility().getIfExecutionContextInAsync()) return ;

		sendRequestToSpecialityDistributorOnPurchaseOrder(ordersIds);
	}

	@Future(Callout = true)
	public static void sendRequestToSpecialityDistributorOnPurchaseOrder(Set<Id> orderIds)
	{
		if (orderIds == null || orderIds.isEmpty()) return ;
		PurchaseOrderService sdNotificationService = (PurchaseOrderService) Application.Service.newInstance(PurchaseOrderService.class);
		sdNotificationService.sendQTCPONoticeToSD(orderIds);
	}

	public void callAnaplanToUpdateManufacturingMilestone(Orders orders)
	{
		Set<Id> orderIds = orders.getRecordIds();
		if(orderIds == null || orderIds.isEmpty())
		{
			return ;
		}

		List<OrderMilestones__c> orderMilestones = ((OrderMileStonesSelector) Application.Selector.newInstance(OrderMilestones__c.SObjectType))
				.selectByOrderIds(orderIds);

		if (orderMilestones.isEmpty() || new Utility().getIfExecutionContextInAsync()) return ;

		callAnaplanToUpdateManufacturingMilestone(sflib_ArrayUtils.pluckIdField(orderMilestones, OrderMilestones__c.Id));
	}

	@Future(Callout = true)
	public static void callAnaplanToUpdateManufacturingMilestone(Set<Id> orderMilestoneIds)
	{
		ManufacturingMilestonesUpdateService manufacturingMilestonesUpdateService = (ManufacturingMilestonesUpdateService)
				Application.Service.newInstance(ManufacturingMilestonesUpdateService.class);
		manufacturingMilestonesUpdateService.callAnaplanToUpdateManufacturingMilestones(orderMilestoneIds);
	}

	public void fetchNotificationAlertDetails(List<Order__c> orderChangedRecords, List<Order__c> orderExistingRecords, Set<Schema.SObjectField> sObjectFieldSet)
	{
		List<String> fieldschema = new List<String>();
		for (Schema.SObjectField sfield : sObjectFieldSet)
		{
			fieldschema.add('' + sfield);
		}
		NotificationEngineSelector notificationEngineSelector = (NotificationEngineSelector) Application.Selector.newInstance(NotificationEngine__mdt.SObjectType);
		List<NotificationEngine__mdt> notificationEngineList = new List<NotificationEngine__mdt>();
		if (fieldschema[0].contains('ManufacturingStatus__c'))
		{
			notificationEngineList = notificationEngineSelector.selectNotificationAlert(OrderObject, fieldschema, orderExistingRecords[0].ManufacturingStatus__c, orderChangedRecords[0].ManufacturingStatus__c);
		}
		if (fieldschema[0].contains('OrderStatus__c'))
		{
			notificationEngineList = notificationEngineSelector.selectNotificationAlert(OrderObject, fieldschema, orderExistingRecords[0].OrderStatus__c, orderChangedRecords[0].OrderStatus__c);
		}

		if (notificationEngineList.isEmpty()) return ;

		UsersSelector usersSelectorInstance = (UsersSelector) Application.Selector.newInstance(User.SObjectType);
		List<User> cartCoordinatorList = usersSelectorInstance.selectByContactId(new Set<Id> {orderChangedRecords[0].Coordinator__c});
		if (cartCoordinatorList.isEmpty()) return ;

		AccountsSelector accountsSelectorInstance = (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
		List<Account> patientsList = (List<Account>) accountsSelectorInstance.selectById(new Set<Id> {orderChangedRecords[0].Patient__c}).getRecords();

		createNotificationAlert(patientsList, notificationEngineList, cartCoordinatorList, orderChangedRecords);
	}

	public void createNotificationAlert(List<Account> patientsList, List<NotificationEngine__mdt> notificationEngineList, List<User> cartCoordinatorList, List<Order__c> orderChangedRecords)
	{
		NotificationsService notificationsServiceInstance = (NotificationsService) Application.Service.newInstance(NotificationsService.class);
		notificationsServiceInstance.createNotificationRecords(patientsList, notificationEngineList, cartCoordinatorList, orderChangedRecords);
	}

	public void updateOrders(List<Order__c> orders)
	{
		try
		{
			fflib_SObjectDomain.getTriggerEvent(Orders.class).disableAll();
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
			uow.registerDirty(orders);
			uow.commitWork();
			fflib_SObjectDomain.getTriggerEvent(Orders.class).enableAll();
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
			fflib_SObjectDomain.getTriggerEvent(Orders.class).enableAll();
		}
	}

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
            if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}

			Database.emptyRecycleBin(objList);
		}
		public void eventPublish(List<SObject> objList)
		{
		}
	}

	public void notifyApheresisShipmentToAnaplan(Orders ordersInfo)
	{
		if (new Utility().getIfExecutionContextInAsync()) return ;

		notifyApheresisShipmentToAnaplan(ordersInfo.getRecordIds());
	}

	@Future(Callout = true)
	public static void notifyApheresisShipmentToAnaplan(Set<Id> orderIds)
	{
		if (orderIds == null || orderIds.isEmpty()) return ;
		AnaplanNotificationService anaplanNotificationService = (AnaplanNotificationService) Application.Service.newInstance(AnaplanNotificationService.class);
		anaplanNotificationService.sendApheresisShipmentNoticeToAnaplan(orderIds);
	}

	public void generateOrderId(List<Order__c> ordList)
	{
		Set<Id> patientIds = sflib_ArrayUtils.pluckIdField(ordList, Order__c.Patient__c);
		Set<Id> treatmentSiteIds = sflib_ArrayUtils.pluckIdField(ordList, Order__c.TreatmentSite__c);

		List<Account> treatmentSiteList = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectTreatmentSiteByIds(treatmentSiteIds);

		Map<Id, Account> treatmentSitesByIds = new Map<Id, Account>(treatmentSiteList);

		List<Order__c> orderList = ((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.selectOrdersByPatientId(patientIds);

		Map<Id, Integer> latestOrderSuffixByPatientIds = getLatestOrderIdsByPatientId(orderList);

		List<String> patientIdSplit;
		String countryPrefix;
		String patientNumberId;
		String orderSuffix;
		String treatmentSiteId;

		for (Order__c ord : ordList)
		{
			patientIdSplit = ord.PatientID__c.split('-');
			countryPrefix = patientIdSplit[0];
			patientNumberId = patientIdSplit[1];

			if (treatmentSitesByIds.containsKey(ord.TreatmentSite__c))
			{
				treatmentSiteId = treatmentSitesByIds.get((Id) ord.get(Label.OrderSiteFieldApi)).ERPSiteID__c;
			}

			if (latestOrderSuffixByPatientIds.containsKey(ord.Patient__c))
			{
				Integer orderIdSuffix = latestOrderSuffixByPatientIds.get(ord.Patient__c) + 1;
				latestOrderSuffixByPatientIds.put(ord.Patient__c, orderIdSuffix);

				orderSuffix = orderIdSuffix > 9 ? String.valueOf(orderIdSuffix) : '0' + orderIdSuffix;

			}
			else
			{
				orderSuffix = Label.OrderIdSuffix;
			}

			String templateId = Label.OrderIdFormat;
			List<String> arguments = new List<String>
			{
					countryPrefix,
					treatmentSiteId,
					patientNumberId,
					orderSuffix
			};

			String orderId = String.format(templateId, arguments);

			ord.Name = orderId;
			ord.CartOrderId__c = orderId;
		}
	}

	private static Map<Id, Integer> getLatestOrderIdsByPatientId(List<Order__c> orderList)
	{
		Map<Id, Integer> latestOrderSuffixByPatientIds = new Map<Id, Integer>();

		for (Order__c ord : orderList)
		{
			String orderId = ord.Name;
			Integer currentlyOrderSuffix = Integer.valueOf(orderId.substring(orderId.lastIndexOf('-') + 1));

			if (latestOrderSuffixByPatientIds.containsKey(ord.Patient__c))
			{
				Integer lastOrderSuffix = latestOrderSuffixByPatientIds.get(ord.Patient__c);

				if (currentlyOrderSuffix > lastOrderSuffix)
				{
					latestOrderSuffixByPatientIds.put(ord.Patient__c, currentlyOrderSuffix);
				}
			}
			else
			{
				latestOrderSuffixByPatientIds.put(ord.Patient__c, currentlyOrderSuffix);
			}
		}
		return latestOrderSuffixByPatientIds;
	}

	public Map<Id, Order__c> getScheduledApheresisAndDrugDeliveryOrdersByPatientId(Set<Id> accountIds)
	{
		Set<String> carePlanScheduledStatuses = new Set<String>();
		String carePlanApheresisScheduledStatus = apheresisPickupDateScheduled;
		String carePlanDrugDeliveryScheduledStatus = drugProductShipped;
		carePlanScheduledStatuses.add(carePlanApheresisScheduledStatus);
		carePlanScheduledStatuses.add(carePlanDrugDeliveryScheduledStatus);
		carePlanScheduledStatuses.add(manufacturing);
		return new Orders(((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.elevatedSelectByAccountIdAndCarePlanStatus(accountIds, carePlanScheduledStatuses))
				.getOrdersByAccountId();
	}

	public void createAdhocTasksforVeinToVein(List<Order__c> orderRecords, String taskSubject)
	{
		OrderTaskConfigSelector orderSelector =
				(OrderTaskConfigSelector) Application.Selector.newInstance(OrderTaskConfig__mdt.SObjectType);

		Map<String, List<OrderTaskConfig__mdt>> orderStatusAndTaskConfigInfo =
				orderSelector.selectActiveOrderTaskConfigInfoPerStatus();

		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType)).
				selectBusinessHoursByName(Label.BusinessHoursNameForPatientServiceEnrolleeTasks);

		if (orderRecords.isEmpty() || businessHours.isEmpty() || orderStatusAndTaskConfigInfo.isEmpty()) return;

		List<Task> tasksToCreate = ((TasksService) Application.Service.newInstance(TasksService.Class)).
				getAdhocTasksforVeinToVein(orderRecords, orderStatusAndTaskConfigInfo, businessHours[0].Id, taskSubject);

		if (tasksToCreate.isEmpty()) return;

		new Utility().insertSObjects(tasksToCreate, Task.SObjectType);
	}

	public Map<Id, Order__c> getNewAndDrugDeliveredOrdersByPatientId(Set<Id> accountIds)
	{
		return new Orders(((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType))
				.elevatedSelectedByAccountCarePlanOrderStatus(accountIds))
				.getOrdersByAccountId();
	}

	public void updateOrderPlacementInfo(Orders orders, Boolean commitInElevatedContext)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		if (commitInElevatedContext)
		{
			uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		}

		updateOrderPlacementInfo(uow, orders);
	}

	public void updateOrderPlacementInfo(fflib_ISObjectUnitOfWork uow, Orders orders)
	{
		uow.registerUpsert(Orders.getRecords());
		uow.commitWork();
	}

	public void updateConfirmedInfusionDateinPSEnrollee(List<Order__c> changedOrderRecords)
	{
		updateConfirmedInfusionDateinPSEnrollee(new Orders(changedOrderRecords));
	}

	public void updateConfirmedInfusionDateinPSEnrollee(Orders OrderList)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
		updateConfirmedInfusionDateinPSEnrollee(uow, OrderList);
		uow.commitWork();
	}

	public void updateConfirmedInfusionDateinPSEnrollee(fflib_ISObjectUnitOfWork uow, Orders OrderList)
	{
		List<Order__c> OrdersList = new List<Order__c>((List<Order__c>) OrderList.getrecords());

		Map<Id, Order__c> CareplanIdOrderMap = ((Orders) Application.Domain
				.newInstance(OrdersList))
				.getByCarePlanIdOrderMap(OrderList);

		List<PatientServicesEnrollee__c> patientServicesEnrollees = ((PatientServicesEnrolleesSelector) Application.Selector
				.newInstance(PatientServicesEnrollee__c.SObjectType))
				.selectByCarePlanId(CareplanIdOrderMap.keySet());

		for (PatientServicesEnrollee__c pse : patientServicesEnrollees)
		{
			pse.ConfirmedInfusionDate__c = CarePlanIDOrderMap.get(pse.CarePlan__c).InfusionDate__c;
		}
		uow.registerDirty(patientServicesEnrollees);
	}

	public void createOrderCancellationCases(Orders orders)
	{
		try
		{
			List<Order__c> cancellationReqOrders = orders.getRecords();

			if (cancellationReqOrders.isEmpty())
			{
				return ;
			}
			fflib_ISObjectUnitOfWork uow = Application.getUnitOfWork();
			createOrderCancellationCases(uow, cancellationReqOrders);
			uow.commitWork();
		}
		catch (Exception excp)
		{
			Application.logEntry.Error(excp);
		}
	}

	public void createOrderCancellationCases(fflib_ISObjectUnitOfWork uow, List<Order__c> cancellationReqOrders)
	{
		CasesService casesService = (CasesService) Application.Service.newInstance(CasesService.class);
		casesService.getCasesForCancellationRequestedOrders(cancellationReqOrders, uow);
	}

	public void getCaseRelatedOrderCancellationInfo(List<Case> casesWithClosedOrderToBeCancelledStatus,
			fflib_ISObjectUnitOfWork uow)
	{
		for (Case caseInstance : casesWithClosedOrderToBeCancelledStatus)
		{
			if (String.isNotBlank(caseInstance.OrderId__c))
			{
				uow.registerDirty(new Order__c(Id = caseInstance.OrderId__c,
						CancellationComments__c = caseInstance.CancellationComments__c,
						ReasonForOrderWithdrawal__c = caseInstance.ReasonForCancellation__c,
						DateOfCancellationRequest__c = Date.valueOf(caseInstance.CreatedDate)));
			}

		}
	}

	public void updateReasonForCancellationInCase(List<Order__c> orderList)
	{
		Set<Id> orderIds = sflib_ArrayUtils.pluckIdField(orderList, Order__c.Id);

		List<Case> cancellationCaseList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
				.selectCasesByOrderIds(orderIds);

		Map<Id, String> cancellationReasonByOrderId = new sflib_SObjects(orderList)
				.asStringFieldByIdField(Order__c.Id, Order__c.ReasonForOrderWithdrawal__c);

		List<Case> casesToUpdateList = new List<Case>();
		for (Case cancellationCase : cancellationCaseList)
		{
			if (String.isBlank(cancellationCase.ReasonForCancellation__c))
			{
				casesToUpdateList.add(cancellationCase);
			}
		}

		if (!casesToUpdateList.isEmpty())
		{
			CasesService casesService = (CasesService) Application.Service.newInstance(CasesService.class);
			casesService.updateReasonForCancellation(casesToUpdateList, cancellationReasonByOrderId);
		}
	}

	public void updateEstimatedDPDeliveryDate(Orders orderRecords)
	{

		Date estimatedDate = getEstimatedDate(Date.Today());
		for (Order__c objOrder : (List<Order__c>) orderRecords.getRecords())
		{
			objOrder.EstimatedDrugProductDeliveryDate__c = estimatedDate;
		}
	}

	public Date getEstimatedDate(Date startDate)
	{
		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType)).
				selectBusinessHoursByName(ConfirmedDPDeliveryDateBusinessHours);
		if (businessHours.isEmpty()) return startDate;

		Date estimatedBusinessDate;
		BusinessHoursCalculatorImp bhCalculatorImp = new BusinessHoursCalculatorImp(businessHours[0].Id);
		DateTime nextBusinessHourDT = bhCalculatorImp.getNextBusinessHourDateTime(startDate.addDays(1));
		DateTime actualStartDateTime = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());

		if (actualStartDateTime.format('EEE') == MON)
		{
			estimatedBusinessDate = bhCalculatorImp.getDueDateBasedOnBusinessHours(nextBusinessHourDT, 2);
		}
		else
		{
			estimatedBusinessDate = bhCalculatorImp.getDueDateBasedOnBusinessHours(nextBusinessHourDT, 3);
		}
		return estimatedBusinessDate;
	}

	public void grantAccessToPublicGroups(Orders orders)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        grantAccessToRelatedPublicGroups(uow, orders.getRecords());
        uow.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<Order__c> orderList)
    {
        Map<Id, Id> orderObjectIdByAccountIdToCloneMap = new Map<Id, Id>();

        for(Order__c order : orderList)
        {
            orderObjectIdByAccountIdToCloneMap.put(order.Id, order.Patient__c);
        }

        if(! orderObjectIdByAccountIdToCloneMap.isEmpty())
        {
            new RecordsSharingService().cloneSharingSettings(uow, orderObjectIdByAccountIdToCloneMap, AccountShare.SObjectType);
        }
	}

}