public with sharing class AssociatedLocationsSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Schema.AssociatedLocation.Id,
				Schema.AssociatedLocation.ParentRecordId,
				Schema.AssociatedLocation.Address__c,
				Schema.AssociatedLocation.LocationId,
				Schema.AssociatedLocation.Type
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Schema.AssociatedLocation.SObjectType;
	}

	public List<Schema.AssociatedLocation> getAddressesForSites(Set<Id> accountIds)
	{
		return ((List<Schema.AssociatedLocation>) Database.query(
				newQueryFactory()
						.selectFields(getSObjectFieldList())
						.selectField('Location.Country__c')
						.selectField('ParentRecord.Name')
						.selectField('ParentRecord.recordTypeId')
						.setCondition('ParentRecordId IN:accountIds')
						.toSOQL()
		));
	}

	public List<Schema.AssociatedLocation> elevatedGetAddressesForSites(Set<Id> accountIds)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedGetAddressesForSites(accountIds);
	}

	public List<Schema.AssociatedLocation> selectAccountAddressInfo(Set<Id> accountIds)
	{
		return ((List<Schema.AssociatedLocation>) Database.query(
				newQueryFactory()
						.selectFields(getSObjectFieldList())
						.selectField('Location.Country__c')
						.selectField('Location.City__c')
						.selectField('Location.AddressLine1__c')
						.selectField('Location.AddressLine2__c')
						.selectField('Location.State__c')
						.selectField('Location.PostalCode__c')
						.selectField('ParentRecord.Name')
						.setCondition('ParentRecordId IN:accountIds')
						.toSOQL()
		));
	}

	private without sharing class elevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private elevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

		private List<AssociatedLocation> elevatedGetAddressesForSites(Set<Id> accountIds)
		{
			Set<String> fieldSet = new Set<String>();
			fieldSet.add('ParentRecord.recordTypeId');
			fieldSet.add('Location.Country__c');
			queryFactory.selectFields(fieldSet);
			queryFactory.setCondition('ParentRecordId IN:accountIds');
			return (List<AssociatedLocation>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}
}