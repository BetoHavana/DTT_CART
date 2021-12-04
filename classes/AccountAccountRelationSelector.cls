public with sharing class AccountAccountRelationSelector extends fflib_SObjectSelector
{
	private static final String accountAccountId = HealthCloudGA__AccountAccountRelation__c.Id
													.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__AccountAccountRelation__c.Id,
				HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__Account__c,
				HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__RelatedAccount__c,
				HealthCloudGA__AccountAccountRelation__c.PrimarySite__c,
				HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__InverseRelationship__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__AccountAccountRelation__c.SObjectType;
	}

	public List<HealthCloudGA__AccountAccountRelation__c> selectPrimarySitesByAccountIds(Set<Id> accountIds)
	{
		Set<String> fieldSet = new Set<String>();
		fieldSet.add('HealthCloudGA__Role__r.Name');
		fieldSet.add('HealthCloudGA__RelatedAccount__r.RecordTypeId');
		return (List<HealthCloudGA__AccountAccountRelation__c>) Database.query(
				newQueryFactory()
						.selectFields(fieldSet)
						.setCondition('HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__Account__c IN :accountIds AND HealthCloudGA__AccountAccountRelation__c.PrimarySite__c = \'Yes\'')
						.toSOQL()
		);
	}

	public List<HealthCloudGA__AccountAccountRelation__c> selectById(Set<Id> accountAccountIds)
	{
		Id accountRoleRecTypeId = Schema.SObjectType.HealthCloudGA__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get('AccountRole').getRecordTypeId();
		return((List<HealthCloudGA__AccountAccountRelation__c>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__Role__r.Name')
						.setCondition(accountAccountId + ' IN : accountAccountIds AND HealthCloudGA__Role__r.RecordTypeId =:accountRoleRecTypeId ')
						.toSOQL()));
	}

	public List<HealthCloudGA__AccountAccountRelation__c> elevatedSelectPrimarySitesByAccountIds(Set<Id> accountIds)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectPrimarySitesByAccountIds(accountIds);
	}

	public List<HealthCloudGA__AccountAccountRelation__c> elevatedSelectByAccountIdsAndRoles(Set<Id> accountIds, Set<String> roles)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectByAccountIdsAndRoles(accountIds, roles);
	}

	public List<HealthCloudGA__AccountAccountRelation__c> selectByAccountIds(Set<Id> accountIds)
	{
		Set<String> fieldSet = new Set<String>();
		fieldSet.add('HealthCloudGA__Role__r.Name');
		fieldSet.add('HealthCloudGA__RelatedAccount__r.RecordTypeId');
		return (List<HealthCloudGA__AccountAccountRelation__c>) Database.query(
				newQueryFactory()
						.selectFields(fieldSet)
						.setCondition('HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__Account__c IN :accountIds')
						.toSOQL()
		);
	}

	public Database.QueryLocator getElevatedQLOfAccntAccntRelsCreatEditedInLastNDays(Integer lastNDays)
	{
		return new ElevatedContext(newQueryFactory()).getElevatedQLOfAccntAccntRelsCreatEditedInLastNDays(lastNDays);
	}

	private without sharing class ElevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private ElevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

		private List<HealthCloudGA__AccountAccountRelation__c> elevatedSelectByAccountIdsAndRoles(Set<Id> accountIds, Set<String> roles)
		{
			queryFactory.selectField('HealthCloudGA__Account__r.ERPSiteID__c');
			queryFactory.selectField('HealthCloudGA__Account__r.Name');
			queryFactory.selectField('HealthCloudGA__RelatedAccount__r.ERPSiteID__c');
			queryFactory.selectField('HealthCloudGA__RelatedAccount__r.Name');
			queryFactory.selectField('HealthCloudGA__RelatedAccount__r.Type');
			queryFactory.selectField('HealthCloudGA__Role__r.Name');
			queryFactory.setCondition('HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__Account__c IN :accountIds AND HealthCloudGA__Role__r.name IN :roles');
			return (List<HealthCloudGA__AccountAccountRelation__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		private List<HealthCloudGA__AccountAccountRelation__c> elevatedSelectPrimarySitesByAccountIds(Set<Id> accountIds)
		{
			Set<String> fieldSet = new Set<String>();
			fieldSet.add('HealthCloudGA__Role__r.Name');
			fieldSet.add('HealthCloudGA__RelatedAccount__r.RecordTypeId');
			String isPrimarySites = 'Yes';
			queryFactory.selectFields(fieldSet);
			queryFactory.setCondition('HealthCloudGA__AccountAccountRelation__c.HealthCloudGA__Account__c IN :accountIds AND HealthCloudGA__AccountAccountRelation__c.PrimarySite__c = :isPrimarySites');
			return (List<HealthCloudGA__AccountAccountRelation__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public Database.QueryLocator getElevatedQLOfAccntAccntRelsCreatEditedInLastNDays(Integer lastNDays)
		{
			return Database.getQueryLocator(
					queryFactory.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
							new List<String>
							{
									HealthCloudGA__AccountAccountRelation__c.LastModifiedDate.getDescribe().getName(),
									String.valueOf(lastNDays)
							}))
							.toSOQL());
		}
	}

}