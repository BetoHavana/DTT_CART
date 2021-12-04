public with sharing class CasesSelector extends fflib_SObjectSelector
{
	private static String orderId = Case.OrderID__c.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Case.AccountId,
				Case.BeginPatientSupportEligibilityCheck__c,
				Case.ContactId,
				Case.Id,
				Case.OrderID__c,
				Case.ReasonForCancellation__c,
				Case.Status,
				Case.Subject,
				Case.TreatmentSite__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Case.SObjectType;
	}

	public Cases selectByPatientAccountId(Set<Id> accountIds)
	{
		return (Cases) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.selectField('Account.Name')
								.selectField('BeginPatientSupportEligibilityCheck__c')
								.selectField('RecordTypeId')
								.selectField('Status')
								.setCondition('AccountId IN :accountIds')
								.toSOQL()
				)
		);
	}

    public List<Case> selectByCarePlanId(Set<Id> setOfCarePlanIds)
    {
        return (List<Case>) Database.query(
                newQueryFactory()
					.selectField('TreatmentSite__r.CellTherapyOrderSpecialist__c')
                    .setCondition('Id IN: setOfCarePlanIds')
                    .toSOQL()
        );
    }

	public List<Case> elevatedSelectTasksByCarePlanId(Set<Id> setOfCarePlanIds)
	{
		return new ElevateContext(this).elevatedSelectTasksByCarePlanId(setOfCarePlanIds);
	}

	public List<Case> selectAll()
	{
		return (List<Case>) Database.query(
				newQueryFactory()
					.toSOQL()
		);
	}

	public List<Case> elevatedSelectByAccountId(Set<Id> accountIds)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByAccountId(accountIds);
	}

	public List<Case> elevatedSelectByCarePlanId(Set<Id> setOfCarePlanIds)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByCarePlanId(setOfCarePlanIds);
	}

	public List<Case> selectCasesByPatientIds(Set<Id> accountIds,Set<Id> recordTypeIds)
	{
		return (List<Case>) Database.query(
									 newQueryFactory(true,true,false)
													.selectField('AccountId')
													.setCondition('AccountId IN :accountIds AND RecordTypeId IN :recordTypeIds')
													.toSOQL());
	}

	public List<Case> selectCasesByOrderIds(Set<Id> orderIds)
	{
		return (List<Case>) Database.query(
				newQueryFactory()
						.setCondition( orderId + ' IN : orderIds')
						.toSOQL());
	}

	public Database.QueryLocator getQLOfCasesCreatedEditedInLastNDays(Integer lastNDays, Set<Id> recordTypeIds)
	{
		return Database.getQueryLocator(
				newQueryFactory(false, false, false)
            			.selectField(Case.AccountId.getDescribe().getName())
						.setCondition(String.format('{0} = LAST_N_DAYS:{1} AND RecordTypeId IN :recordTypeIds',
						new List<String>
						{
								Case.LastModifiedDate.getDescribe().getName(),
								String.valueOf(lastNDays)
						}))
						.toSOQL());
	}


	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		CasesSelector selector;

		public ElevateContext(CasesSelector selector)
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

		public List<Case> elevatedSelectByAccountId(Set<Id> accountIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('Account.Name');
			queryFactory.selectField('BeginPatientSupportEligibilityCheck__c');
			queryFactory.selectField('RecordTypeId');
			queryFactory.selectField('Status');
			queryFactory.setCondition('AccountId IN :accountIds');
			return (List<Case>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<Case> elevatedSelectByCarePlanId(Set<Id> setOfCarePlanIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('TreatmentSite__r.CellTherapyOrderSpecialist__c');
			queryFactory.setCondition('Id IN: setOfCarePlanIds');
			return (List<Case>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<Case> elevatedSelectTasksByCarePlanId(Set<Id> setOfCarePlanIds)
		{
			String goalName = Schema.Task.GoalName__c.getDescribe().getName();
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.setCondition('Id IN :setOfCarePlanIds');
			new TasksSelector().addQueryFactorySubselect(queryFactory, 'Tasks').setCondition(goalName + ' !=null ');
			return (List<Case>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}

}