public with sharing class CareProgramEnrolleeProductsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CareProgramEnrolleeProduct.Name,
                CareProgramEnrolleeProduct.CareProgramEnrolleeId    
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CareProgramEnrolleeProduct.SObjectType;
	}

	public List<CareProgramEnrolleeProduct> selectByCPEId(Set<Id> careProgramEnrolleeIds)
	{
		return (List<CareProgramEnrolleeProduct>) Database.query(
				newQueryFactory()
						.selectField('CareProgramProduct.Product.Name')
						.selectField('CareProgramProduct.Product.TherapyType__c')
						.selectField('CareProgramEnrollee.AccountId')
						.setCondition('CareProgramEnrolleeId IN:careProgramEnrolleeIds')
						.toSOQL());
	}

	public List<CareProgramEnrolleeProduct> elevatedSelectByCPEnrolleeId(Set<Id> careProgramEnrolleeIds)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByCPEnrolleeId(careProgramEnrolleeIds);
	}

	public Database.QueryLocator getElevatedQLOfCPEProuctsCreatEditedInLastNDays(Integer lastNDays)
	{
		return new ElevateContext(this).getElevatedQLOfCPEProuctsCreatEditedInLastNDays(lastNDays);
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		CareProgramEnrolleeProductsSelector selector;

		public ElevateContext(CareProgramEnrolleeProductsSelector selector)
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

		public List<CareProgramEnrolleeProduct> elevatedSelectByCPEnrolleeId(Set<Id> careProgramEnrolleeIds)
		{
			return (List<CareProgramEnrolleeProduct>) Database.query(
					newQueryFactory()
							.selectField('CareProgramProductId')
							.setCondition('CareProgramEnrolleeId IN:careProgramEnrolleeIds')
							.toSOQL());
		}

		public Database.QueryLocator getElevatedQLOfCPEProuctsCreatEditedInLastNDays(Integer lastNDays)
		{
			return Database.getQueryLocator(
					newQueryFactory(false, false, true)
							.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
							new List<String>
							{
									CareProgramEnrolleeProduct.LastModifiedDate.getDescribe().getName(),
									String.valueOf(lastNDays)
							}))
							.toSOQL());
		}

	}
}