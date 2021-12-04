public class CareProgramEnrolleesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				CareProgramEnrollee.Id
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return CareProgramEnrollee.SObjectType;
	}

	public List<CareProgramEnrollee> selectByAccountId(Set<Id> accountIds)
	{
		return (List<CareProgramEnrollee>) Database.query(
				newQueryFactory()
						.setCondition('AccountId =:accountIds')
						.toSOQL());
	}

	public List<CareProgramEnrollee> elevatedSelectById(Set<Id> careProgramEnrolleeIds)
	{
		return new ElevateContext(this).elevatedSelectById(careProgramEnrolleeIds);
	}

	public List<CareProgramEnrollee> elevatedSelectByAccountId(Set<Id> accountIds){
		ElevateContext elevateContext = new ElevateContext(this);
		return elevateContext.elevatedSelectByAccountId(accountIds);
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		CareProgramEnrolleesSelector selector;

		public ElevateContext(CareProgramEnrolleesSelector selector)
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

		public List<CareProgramEnrollee> elevatedSelectByAccountId(Set<Id> accountIds){
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('AccountId');
			queryFactory.setCondition('AccountId IN :accountIds');
			return (List<CareProgramEnrollee>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<CareProgramEnrollee> elevatedSelectById(Set<Id> careProgramEnrolleeIds)
		{
			return (List<CareProgramEnrollee>) Database.query(
					newQueryFactory(false, false, true)
							.selectField('AccountId')
							.setCondition('Id IN : careProgramEnrolleeIds')
							.toSOQL());
		}
	}
}