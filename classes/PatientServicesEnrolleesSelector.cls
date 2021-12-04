public with sharing class PatientServicesEnrolleesSelector extends sflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				PatientServicesEnrollee__c.CarePlan__c,
				PatientServicesEnrollee__c.Name,
				PatientServicesEnrollee__c.Patient__c,
				PatientServicesEnrollee__c.PatientServicesStatus__c
		};
	}

	public SObjectType getSObjectType()
	{
		return PatientServicesEnrollee__c.SObjectType;
	}
    
	public List<PatientServicesEnrollee__c> selectByCarePlanId(Set<Id> carePlanIds)
	{
		return (List<PatientServicesEnrollee__c>) selectByFieldInIdSet(PatientServicesEnrollee__c.CarePlan__c, carePlanIds);
	}

	public List<PatientServicesEnrollee__c> selectById(Set<Id> pseIds)
	{
		return ((List<PatientServicesEnrollee__c>) Database.query(
				newQueryFactory()
						.selectField('Patient__c')
						.setCondition( 'Id IN :pseIds')
						.toSOQL()));
	}

	public List<PatientServicesEnrollee__c> elevatedSelectByAccountId(Set<Id> accountIds){
		ElevateContext elevateContext = new ElevateContext(this);
		return elevateContext.elevatedSelectByAccountId(accountIds);
	}
    
    public Database.QueryLocator getQLOfPSESCreatedEditedInLastNDays(Integer lastNDays)
	{
		return Database.getQueryLocator(
						newQueryFactory()
						.setCondition(String.format('{0} = LAST_N_DAYS:{1}',
						new List<String>{
								Account.LastModifiedDate.getDescribe().getName(),
								String.valueOf(lastNDays)}))
						.toSOQL());
	}

	private without sharing class ElevateContext extends sflib_SObjectSelector
	{
		PatientServicesEnrolleesSelector selector;

		public ElevateContext(PatientServicesEnrolleesSelector selector)
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

		public List<PatientServicesEnrollee__c> elevatedSelectByAccountId(Set<Id> accountIds){
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Patient__c');
			queryFactory.setCondition('Patient__c IN :accountIds');
			return (List<PatientServicesEnrollee__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

	}
	
	public List<PatientServicesEnrollee__c> selectAll()
	{
		return ((List<PatientServicesEnrollee__c>) Database.query(
				newQueryFactory().toSOQL()));
	}
}