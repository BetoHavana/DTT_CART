public with sharing class OrderProcessingRulesSelector extends sflib_SObjectSelector
{
	public static List<OrderProcessingRule__mdt> orderProcessingRules
	{
		get
		{
			if (orderProcessingRules == null)
			{
				orderProcessingRules = ((OrderProcessingRulesSelector) Application.Selector.newInstance(getObjectType()))
						.selectAllActiveRules();
			}
			return orderProcessingRules;
		}
		private set;
	}
	public sObjectType getSobjectType()
	{
		return OrderProcessingRule__mdt.sObjectType;
	}
	public static sobjectType getObjectType()
	{
		return OrderProcessingRule__mdt.sObjectType;
	}
	public List<sObjectField> getSObjectFieldList()
	{
		return new List<sObjectField>
		{
				OrderProcessingRule__mdt.CarePlanConditionsInfo__c,
                OrderProcessingRule__mdt.CarePlanUpdateInfo__c,
                OrderProcessingRule__mdt.OrderConditionsInfo__c,
				OrderProcessingRule__mdt.CryoType__c,
                OrderProcessingRule__mdt.GoalsConditionsInfo__c,
				OrderProcessingRule__mdt.GoalsUpdateInfo__c,
				OrderProcessingRule__mdt.IsActive__c,
				OrderProcessingRule__mdt.ApiNamesOfChangedFieldsToRunLogic__c,
                OrderProcessingRule__mdt.MasterLabel,
				OrderProcessingRule__mdt.OrderUpdateInfo__c,
				OrderProcessingRule__mdt.RuleOrder__c,
				OrderProcessingRule__mdt.TaskUpdateInfo__c,
                OrderProcessingRule__mdt.TaskConditionsInfo__c
		};
	}

	public List<OrderProcessingRule__mdt> selectAllActiveRules()
	{
		return selectActive(true);
	}

	private List<OrderProcessingRule__mdt> selectActive(Boolean isActive)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		queryFactory.setCondition(OrderProcessingRule__mdt.isActive__c.getDescribe().getName() + ' = :IsActive');
		return (List<OrderProcessingRule__mdt>) Database.query(queryFactory.toSOQL());
	}
	public override String getOrderBy()
	{
		return OrderProcessingRule__mdt.RuleOrder__c.getDescribe().getName() + ' DESC';
	}
	public Map<String, List<OrderProcessingRule__mdt>> getActiveRulesPerCryoType()
	{
		Map<String, List<OrderProcessingRule__mdt>> rulesPerCryoType = new Map<String, List<OrderProcessingRule__mdt>>();
		String cryoType;
		for (OrderProcessingRule__mdt rule : orderProcessingRules)
		{
			cryoType = '';
			cryoType = rule.CryoType__c.toLowerCase();
			if (rulesPerCryoType.containsKey(cryoType))
			{
				rulesPerCryoType.get(cryoType).add(rule);
			}
			else
			{
				rulesPerCryoType.put(cryoType, new List<OrderProcessingRule__mdt> {rule});
			}
		}
		return rulesPerCryoType;
	}
}