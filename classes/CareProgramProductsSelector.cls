public with sharing class CareProgramProductsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CareProgramProduct.CareProgramId,
				CareProgramProduct.Id,
				CareProgramProduct.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CareProgramProduct.SObjectType;
	}

	public List<CareProgramProduct> elevatedSelectById(Set<Id> careProgramProductIds)
	{
		ElevateContext elevateContext = new ElevateContext(this);
		return elevateContext.elevatedSelectById(careProgramProductIds);
	}

	public List<CareProgramProduct> elevatedSelectByCareProgramId(Set<Id> careProgramIds)
	{
		ElevateContext elevateContext = new ElevateContext(this);
		return elevateContext.elevatedSelectByCareProgramId(careProgramIds);
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		CareProgramProductsSelector selector;

		public ElevateContext(CareProgramProductsSelector selector)
		{
			super(true, false, false, true);
			this.selector = selector;
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return selector.getSObjectFieldList();
		}

		public Schema.SObjectType getSObjectType()
		{
			return selector.getSObjectType();
		}

		public List<CareProgramProduct> elevatedSelectById(Set<Id> careProgramProductIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Product.TherapyType__c');
			queryFactory.selectField('Product.Name');
			queryFactory.setCondition('Id IN:careProgramProductIds');
			return (List<CareProgramProduct>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<CareProgramProduct> elevatedSelectByCareProgramId(Set<Id> careProgramIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Product.TherapyType__c');
			queryFactory.selectField('Product.Name');
			queryFactory.setCondition('CareProgramId IN:careProgramIds');
			return (List<CareProgramProduct>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}

}