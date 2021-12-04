public with sharing class ContactsSelector extends fflib_SObjectSelector
{
    String accountId = Contact.AccountId.getDescribe().getName();
    String contactId = User.ContactId.getDescribe().getName();
    String statusField = Contact.Status__c.getDescribe().getName();
    
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Contact.Id,
				Contact.AccountId,
				Contact.Birthdate
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Contact.SObjectType;
	}

	public List<Contact> selectByIdWithAccountsRecordType(Set<Id> idSet)
	{
		return (List<Contact>) Database.query(
				newQueryFactory()
						.selectField('Account.RecordTypeId')
						.setCondition('Id IN :idSet')
						.toSOQL()
		);
	}

	public List<Contact> elevatedSelectById(Set<Id> contactIds)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectById(contactIds);
	}

	public Contacts selectByAccountId(Set<Id> accountIds)
	{
		return (Contacts) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setCondition('AccountId IN :accountIds')
								.toSOQL()
				)
		);
	}

	private without sharing class elevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private elevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

		private List<Contact> elevatedSelectById(Set<Id> contactIds)
		{
			queryFactory.selectField('Name');
			queryFactory.setCondition('Id IN :contactIds');
			return (List<Contact>) Database.query(queryFactory.toSOQL());
		}
	}

	public List<Contact> selectAllByRecTypeDeveloperName(Set<String> recTypeNames)
	{
		return((List<Contact>) Database.query(
				newQueryFactory()
						.setCondition('RecordType.DeveloperName IN: recTypeNames')
						.setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()));
	}

	public List<Contact>  selectContactsByAccountsIdAndStatus(Set<Id> deactivatedAccountIds, Set<String> sitePersonasSet, String contactStatus)
	{
		fflib_QueryFactory queryFactory = newQueryFactory()
				.setCondition(accountId + ' IN :deactivatedAccountIds AND ' + statusField + ' = : contactStatus AND SitePersona__c IN :sitePersonasSet');
		
        queryFactory
				.subSelectQuery('Users')
				.selectField('Id');
            
		return (List<Contact>) Database.query(
            String.escapeSingleQuotes(queryFactory.toSOQL())
        );
	}

}