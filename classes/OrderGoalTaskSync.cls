public without sharing class OrderGoalTaskSync
{
	public static final String ORDERSTATUSNEW = 'New';
	public static final String ORDERSTATUSRESCHEDULED = 'Order Rescheduled';
	public static final String ORDERSTATUSSUBMITTED = 'Order Submitted';
	public static final String ORDERSTATUSVERIFIED = 'Order Verified';
	public static final String SLOT_CONFIRMED = 'Slot Confirmed';

	public List<Order__c> ordersToProcess = new List<Order__c>();
	public Map<String, List<OrderProcessingRule__mdt>> processingRulesPerCryoType;

	public OrderGoalTaskSync(List<Order__c> ordersToProcess)
	{
		this.ordersToProcess = ordersToProcess;
	}

	public OrderGoalTaskSync(Set<Id> orderIds)
	{
		this(((OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType)).selectOrdersByOrderId(orderIds));
	}

	public Map<String, List<OrderProcessingRule__mdt>> getActiveOrderProcessingRulesPerCryoType()
	{
		Map<String, List<OrderProcessingRule__mdt>> teststst = new OrderProcessingRulesSelector().getActiveRulesPerCryoType();
		return teststst;
	}

	public void processOrderUpdateRules(fflib_ISObjectUnitOfWork uow, Map<Id, Case> carePlanInfo,
			Map<Id, Set<HealthCloudGA__CarePlanGoal__c>> carePlanIdNRelatedGoals,
			Map<Id, Set<String>> changedFieldsPerRec, Map<Id, Set<Task>> goalAndRelatedTasks)
	{
		try
		{
			OrderProcessingRule__mdt rule = new OrderProcessingRule__mdt();
			Map<String, List<OrderProcessingRule__mdt>> rulesPerCryoType = getActiveOrderProcessingRulesPerCryoType();
			String goalStatusField = HealthCloudGA__CarePlanGoal__c.status__C.getDescribe().getName();
			String taskStatusField = Task.Status.getDescribe().getName();
			Set<Id> relevantGoalIdsForTaskUpdate = new Set<Id>();

			for (Order__c order : ordersToProcess)
			{
				if (String.isBlank(order.CryoSiteType__c) || !rulesPerCryoType.containsKey(order.CryoSiteType__c.toLowerCase()))
				{
					continue;
				}

				rule = getSatisFieldRuleInfo(carePlanInfo.get(order.CarePlanID__c), order, rulesPerCryoType.get(order.CryoSiteType__c.toLowerCase()), changedFieldsPerRec.get(order.Id),
						carePlanIdNRelatedGoals.get(order.CarePlanID__c), carePlanInfo.get(order.CarePlanID__c).Tasks);

				if (rule != null && rule.MasterLabel != null)
				{
					Application.logEntry.debug('Satisfied Rule Number :' + rule.RuleOrder__c + ' and Rule Info : ' + JSON.serialize(rule));
					processOrderUpdate(order, rule);
					processCarePlanUpdate(uow, carePlanInfo.get(order.CarePlanID__c), rule.CarePlanUpdateInfo__c);
					processRelevantGoalUpdateNPassGoalIds(uow, rule.GoalsUpdateInfo__c, carePlanIdNRelatedGoals.get(order.CarePlanID__c), goalStatusField);
					processRelevantTasksUpdate(uow, rule.TaskUpdateInfo__c, carePlanInfo.get(order.CarePlanID__c).Tasks, taskStatusField);
				}
			}
			processOrdersIfNontriggerContext(uow, ordersToProcess);
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
		}
	}

	private void processOrdersIfNontriggerContext(fflib_ISObjectUnitOfWork uow,List<SObject> ordersToProcess)
	{
		if (!Trigger.isExecuting)
		{
			uow.registerDirty(ordersToProcess);
			fflib_SObjectDomain.getTriggerEvent(Orders.class).disableAll();
		}
	}

	public void processRelevantTasksUpdate(fflib_ISObjectUnitOfWork uow, String taskStatusUpdateInfo, List<Task> activities,String fieldName)
	{
		if (String.isNotBlank(taskStatusUpdateInfo) && !activities.isEmpty())
		{
			List<TaskUpdateNode> tasksStatusUpdateInfo = (List<TaskUpdateNode>) JSON.deserialize(taskStatusUpdateInfo, List<TaskUpdateNode>.class);
			String goalNameOnTask = Task.GoalName__c.getDescribe().getName();
			for (TaskUpdateNode taskUpdateInfo : tasksStatusUpdateInfo)
			{
				for (Task activity : activities)
				{
					if (taskUpdateInfo.taskSubject.equalsIgnoreCase(activity.Subject) && verifyTaskRelatedGoalName(activity, taskUpdateInfo.goalNameForTasksFilter, goalNameOnTask))
					{
						uow.registerDirty(processSobjectUpdate(activity, fieldName, taskUpdateInfo.taskStatusToSet));
					}
				}
			}
		}
	}

	public Set<Id> processRelevantGoalUpdateNPassGoalIds(fflib_ISObjectUnitOfWork uow, String goalStatusUpdateInfo, Set<HealthCloudGA__CarePlanGoal__c> goals, String fieldName)
	{
		Set<Id> relevantGoalIdsForTaskUpdate = new Set<Id>();
		if (String.isNotBlank(goalStatusUpdateInfo) && !goals.isEmpty())
		{
			List<GoalUpdateNode> goalsStatusUpdateInfo = (List<GoalUpdateNode>) JSON.deserialize(goalStatusUpdateInfo, List<GoalUpdateNode>.class);
			for (GoalUpdateNode goalInUpdatefo : goalsStatusUpdateInfo)
			{
				for (HealthCloudGA__CarePlanGoal__c goal : goals)
				{
					if (goalInUpdatefo.goalName.equalsIgnoreCase(goal.Name))
					{
						uow.registerDirty(processSobjectUpdate(goal, fieldName, goalInUpdatefo.goalStatusToSet));
						relevantGoalIdsForTaskUpdate.add(goal.Id);
					}
				}
			}
		}
		return relevantGoalIdsForTaskUpdate;
	}

	private void processCarePlanUpdate(fflib_ISObjectUnitOfWork uow,SObject record, String fieldUpdateInfo)
	{
		if (String.isNotBlank(fieldUpdateInfo))
		{
			List<FieldUpdateNode> fieldsUpdateInfo = (List<FieldUpdateNode>) JSON.deserialize(fieldUpdateInfo, List<FieldUpdateNode>.class);
			for (FieldUpdateNode fieldInfoToSet : fieldsUpdateInfo)
			{
				record.put(fieldInfoToSet.fieldName, fieldInfoToSet.valueToSet);
				uow.registerDirty(record);
			}
		}
	}

	private SObject processSobjectUpdate(SObject record, String fieldName, String value)
	{
		record.put(fieldName, value);
		return record;
	}

	public Order__c processOrderUpdate(Order__c order, OrderProcessingRule__mdt rule)
	{
		setOrderStatusWhenSlotIsConfirmed(order);
		if (String.isNotBlank(rule.OrderUpdateInfo__c))
		{
			List<FieldUpdateNode> fieldsUpdateInfo = (List<FieldUpdateNode>) JSON.deserialize(rule.OrderUpdateInfo__c, List<FieldUpdateNode>.class);
			for (FieldUpdateNode fieldInfoToSet : fieldsUpdateInfo)
			{
				order.put(fieldInfoToSet.fieldName, fieldInfoToSet.valueToSet);
			}
		}
		return order;
	}

	public void setOrderStatusWhenSlotIsConfirmed(Order__c order)
	{
		Set<String> orderStatusSet = new Set<String>{ORDERSTATUSNEW,ORDERSTATUSVERIFIED,ORDERSTATUSSUBMITTED,ORDERSTATUSRESCHEDULED};
		if(SLOT_CONFIRMED.equals(order.SlotStatus__c)
				&& String.isNotBlank(order.OrderPlacementInfo__c)
				&& orderStatusSet.contains(order.OrderStatus__c))
		{
			order.OrderStatus__c = order.OrderPlacementInfo__c;
		}
	}

	private OrderProcessingRule__mdt getSatisFieldRuleInfo(Case carePlan, Order__c order, List<OrderProcessingRule__mdt> rules, Set<String> changedFields,
			Set<HealthCloudGA__CarePlanGoal__c> goals, List<Task> tasks)
	{
		OrderProcessingRule__mdt satisFieldRule;
		List<HealthCloudGA__CarePlanGoal__c> goalsList = new List<HealthCloudGA__CarePlanGoal__c>(goals);
		for (OrderProcessingRule__mdt rule : rules)
		{
			if (isRecSatisfyingTheRuleCondition(order, rule.OrderConditionsInfo__c) && isRecSatisfyingTheRuleCondition(carePlan, rule.CarePlanConditionsInfo__c) &&
					checkForChangedFieldsEligibility(rule.APINamesOfChangedFieldsToRunLogic__c, changedFields) &&
					areRecsSatisfyingRuleCondition(getAppropriateRecsToCheck(goalsList, rule.GoalsConditionsInfo__c, StaticConstants.NAMELABEL), rule.GoalsConditionsInfo__c)
					&& areRecsSatisfyingRuleCondition(getAppropriateRecsToCheck(tasks, rule.TaskConditionsInfo__c, StaticConstants.SUBJECTLABEL), rule.TaskConditionsInfo__c))
			{
				satisFieldRule = rule;
			}
		}

		return satisFieldRule;
	}

	private Boolean compareWhetherValuesAreEqual(String valueToCompare, String valueToCompareAganist)
	{
		return String.isBlank(valueToCompareAganist) || (String.isNotBlank(valueToCompare) && valueToCompareAganist.split(StaticConstants.COMMA).contains(valueToCompare));
	}

	private Boolean checkForChangedFieldsEligibility(String fieldsListToCheck, Set<String> changedFieldsCollection)
	{
		if (String.isNotBlank(fieldsListToCheck) && (changedFieldsCollection == null || changedFieldsCollection.isEmpty()))
		{
			return false;
		}
		List<String> fieldsListToValidate = String.isNotBlank(fieldsListToCheck) ? fieldsListToCheck.split(StaticConstants.COMMA)
				: new List<String>();
		for (String fieldName : fieldsListToValidate)
		{
			if (!changedFieldsCollection.contains(fieldName))
			{
				return false;
			}
		}
		return true;
	}

	private Boolean areRecsSatisfyingRuleCondition(List<SObject> records, String conditionsInfo)
	{
		Boolean isSatisfied = true;
		for (SObject record : records)
		{
			if (!isRecSatisfyingTheRuleCondition(record, conditionsInfo))
			{
				isSatisfied = false;
				break;
			}
		}
		return isSatisfied;
	}

	private Boolean isRecSatisfyingTheRuleCondition(SObject record, String conditionInfo)
	{
		try
		{
			Boolean isSatisfied = true;
			String goalNameOnTask = Task.GoalName__c.getDescribe().getName();
			if (String.isNotBlank(conditionInfo) && record != null)
			{
				List<ConditionsNode> conditions = (List<ConditionsNode>) JSON.deserialize(conditionInfo, List<ConditionsNode>.class);
				for (ConditionsNode condition : conditions)
				{
					if (!compareWhetherValuesAreEqual((String) record.get(condition.fieldName), condition.valueToCompare))
					{
						isSatisfied = false;
						break;
					}
				}
			}
			return isSatisfied;
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
			return false;
		}
	}

	private Boolean verifyTaskRelatedGoalName(SObject record, String goalNameFilter, String goalNameOnTask)
	{
		return String.isBlank(goalNameFilter) || compareWhetherValuesAreEqual((String) record.get(goalNameOnTask), goalNameFilter);
	}

	private List<sObject> getAppropriateRecsToCheck(List<SObject> records, String conditionInfo, String fieldNameToFilter)
	{
		List<sObject> targetRecords = new List<sObject>();
		SObject targetRecord;
		String taskObjectGoalNameField = Task.GoalName__c.getDescribe().getName();
		if (String.isNotBlank(conditionInfo))
		{
			List<ConditionsNode> conditions = (List<ConditionsNode>) JSON.deserialize(conditionInfo, List<ConditionsNode>.class);

			for (ConditionsNode condition : conditions)
			{
				for (SObject record : records)
				{
					if (validateGoalNameIfTaskSObject(record,condition.goalNameOrTaskSub,taskObjectGoalNameField) &&
							isAppropriateRecToCheck(condition.goalNameOrTaskSub, record, fieldNameToFilter))
					{
						targetRecords.add(record);
					}
				}
			}
		}
		return targetRecords;
	}

	private Boolean validateGoalNameIfTaskSObject(SObject record,String goalNameForTasksFilter,String taskObjectGoalNameField)
	{
		return Task.SObjectType != record.Id.getSObjectType() ||
				compareWhetherValuesAreEqual(goalNameForTasksFilter,(String) record.get(taskObjectGoalNameField));
	}

	private Boolean isAppropriateRecToCheck(String recName, SObject record, String fieldNameToFilter)
	{
		return String.isBlank(recName) || (record.get(fieldNameToFilter) != null &&
				String.valueOf(record.get(fieldNameToFilter)).equalsIgnoreCase(recName));
	}


	class ConditionsNode
	{
		public String goalNameOrTaskSub { get; set; }
		String fieldName { get; set; }
		String valueToCompare { get; set; }
		public String goalNameForTasksFilter { get; set; }
	}

	class FieldUpdateNode
	{
		String fieldName { get; set; }
		String valueToSet { get; set; }
	}

	class GoalUpdateNode
	{
		String goalName { get; set; }
		String goalStatusToSet { get; set; }
	}

	class TaskUpdateNode
	{
		String taskSubject { get; set; }
		String taskStatusToSet { get; set; }
		String goalNameForTasksFilter { get; set; }
	}
}