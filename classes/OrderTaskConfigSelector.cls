public inherited sharing class OrderTaskConfigSelector extends sflib_SObjectSelector 
{
	public static List<OrderTaskConfig__mdt> orderTasksConfig
	{
		get
		{
			if (orderTasksConfig == null)
			{
				orderTasksConfig = ((OrderTaskConfigSelector) Application.Selector.newInstance(getObjectType()))
						.getActiveOrderTaskConfigInfo();
			}
			return orderTasksConfig;
		}
		private set;
	}

	public SObjectType getSObjectType()
	{
		return OrderTaskConfig__mdt.SobjectType;
	}

	public static sobjectType getObjectType()
	{
		return OrderTaskConfig__mdt.sObjectType;
	}

	public List<SObjectField> getSObjectFieldList()
	{
		return new List<SObjectField>
		{
				OrderTaskConfig__mdt.IsActive__c,
				OrderTaskConfig__mdt.DaysToReachDueDate__c,
				OrderTaskConfig__mdt.TaskPriority__c,
				OrderTaskConfig__mdt.TaskStatus__c,
				OrderTaskConfig__mdt.TaskSubject__c,
                OrderTaskConfig__mdt.TaskType__c
		};
	}

	public List<OrderTaskConfig__mdt> getActiveOrderTaskConfigInfo()
	{
		return selectOrderTaskConfigInfo(true);
	}

	public List<OrderTaskConfig__mdt> selectOrderTaskConfigInfo(Boolean isActive)
	{

		fflib_QueryFactory queryFactory = newQueryFactory();
		queryFactory.setCondition(OrderTaskConfig__mdt.isActive__c.getDescribe().getName() +
				' = :IsActive');
		return (List<OrderTaskConfig__mdt>) Database.query(queryFactory.toSOQL());
	}

	public Map<String, List<OrderTaskConfig__mdt>> selectActiveOrderTaskConfigInfoPerStatus()
	{
		Map<String, List<OrderTaskConfig__mdt>> orderTaskConfig = new Map<String, List<OrderTaskConfig__mdt>>();
		for (OrderTaskConfig__mdt objOrderTaskConfig : orderTasksConfig)
		{
			if (orderTaskConfig.containsKey(objOrderTaskConfig.TaskSubject__c))
			{
				orderTaskConfig.get(objOrderTaskConfig.TaskSubject__c).add(objOrderTaskConfig);
			}
			else
			{
				orderTaskConfig.put(objOrderTaskConfig.TaskSubject__c, new List<OrderTaskConfig__mdt> {objOrderTaskConfig});
			}
		}
		return orderTaskConfig;
	}

}