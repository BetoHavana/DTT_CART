public with sharing class OrderGoalTaskPreSync
{
	private static final String COMMA = ',';
	private static final String TODAYSTRING = 'Today';

	private List<Order__c> orders = new List<Order__c>();

	public OrderGoalTaskPreSync(List<Order__c> orders)
	{
		this.orders = orders;
	}

	public void processOrderGoalsAndSetTaskDueDate(fflib_ISObjectUnitOfWork uow, Map<Id, Case> carePlanInfo, Map<Id, Set<String>> changedFieldsPerRec)
	{
		List<CarePlanTasksConfigs__mdt> taskDueDateConfigs = ((CarePlanTasksConfigsSelector) Application.Selector.newInstance(CarePlanTasksConfigs__mdt.SObjectType)).selectAllActiveRules();
		if (taskDueDateConfigs.isEmpty())
		{
			return ;
		}

		for (Order__c order : orders)
		{
			for (CarePlanTasksConfigs__mdt taskDueDateConfig : taskDueDateConfigs)
			{
				if (checkIfRuleIsSatisfied(order, changedFieldsPerRec.get(order.Id), taskDueDateConfig))
				{
					Application.logEntry.Debug('Satisfied Rule Name' + taskDueDateConfig.MasterLabel);
					setTaskDueDate(uow, carePlanInfo.get(order.CarePlanID__c), taskDueDateConfig, order);
				}
			}
		}
	}

	private Boolean checkIfRuleIsSatisfied(Order__c order, Set<String> changedFieldsOfOrder, CarePlanTasksConfigs__mdt rule)
	{
		return checkIfRelevantFieldsAreUpdated(changedFieldsOfOrder, rule.APINamesOfChangedFieldsToRunLogic__c) && validateOrderConditions(order, rule.OrderConditionsInfo__c);
	}

	private Boolean checkIfRelevantFieldsAreUpdated(Set<String> changedFieldsOfOrder, String apiNamesOfChangedFieldsToRun)
	{
		return String.isBlank(apiNamesOfChangedFieldsToRun) || checkIfSetContainsAllElements(changedFieldsOfOrder, apiNamesOfChangedFieldsToRun.split(COMMA));
	}

	private Boolean checkIfSetContainsAllElements(Set<String> allElements, List<String> elementsListToCheck)
	{
		if (allElements == null || allElements.isEmpty())
		{
			return false;
		}

		for (String element : elementsListToCheck)
		{
			if (!allElements.contains(element))
			{
				return false;
			}
		}
		return true;
	}

	private Boolean validateOrderConditions(Order__c order, String orderConditionsInfo)
	{
		if (string.isBlank(OrderConditionsInfo))
		{
			return true;
		}

		List<OrderCondition> conditions = (List<OrderCondition>) JSON.deserialize(orderConditionsInfo, List<OrderCondition>.class);

		for (OrderCondition condition : conditions)
		{
			if (!condition.value.split(COMMA).contains((string) order.get(condition.fieldName)))
			{
				return false;
			}
		}
		return true;
	}

	private void setTaskDueDate(fflib_ISObjectUnitOfWork uow, Case carePlan, CarePlanTasksConfigs__mdt taskUpdateConfig, Order__c order)
	{
		if (carePlan == null || carePlan.tasks == null || carePlan.tasks.isEmpty())
		{
			return ;
		}

		TaskUpdateCondition condition = (TaskUpdateCondition) JSON.deserialize(taskUpdateConfig.TasksConditionsInfo__c, TaskUpdateCondition.class);
		Date activityDate = null;
		for (Task taskRecord : getGoalRelatedTasks(condition, carePlan.tasks))
		{
			activityDate = getDueDate(order, taskUpdateConfig.InheritDueDateFromOrderField__c, Integer.valueOf(taskUpdateConfig.NoOfDaysToAddToInheritedDate__c));
			if (activityDate != null)
			{
				taskRecord.ActivityDate = activityDate;
				uow.registerDirty(taskRecord);
			}
		}
	}

	private Date getDueDate(Order__c order, String fieldNameToInheritFrom, Integer noOfDaysToAdd)
	{
		Date dueDate = Date.Today();

		if (TODAYSTRING.equalsIgnoreCase(fieldNameToInheritFrom))
		{
			dueDate = dueDate.addDays(noOfDaysToAdd);
		}
		else if (order.get(fieldNameToInheritFrom) != null)
		{
			dueDate = Date.valueOf(order.get(fieldNameToInheritFrom)).addDays(noOfDaysToAdd);
		}
		return dueDate;
	}

	private List<Task> getGoalRelatedTasks(TaskUpdateCondition condition, List<Task> tasks)
	{
		List<Task> filteredTasks = new List<Task>();
		for (Task taskRecord : tasks)
		{
			if (String.valueOf(condition.subject).equalsIgnoreCase(taskRecord.Subject)
					&& String.valueOf(condition.goalName).equalsIgnoreCase(taskRecord.GoalName__c))
			{
				filteredTasks.add(taskRecord);
			}
		}
		return filteredTasks;
	}

	Class OrderCondition
	{
		String fieldName { get; set; }
		String value { get; set; }
	}

	Class TaskUpdateCondition
	{
		String subject { get; set; }
		String goalName { get; set; }
	}
}