public with sharing class UsersSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				User.Id,
				User.UserRoleId
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return User.SObjectType;
	}

	public List<User> selectByProfileName(Set<String> profileNames)
	{
		return (List<User>) Database.query(
				newQueryFactory()
						.setCondition('Profile.Name IN:profileNames AND IsActive = true')
						.toSOQL()
		);
	}

	public List<User> selectByIds(Set<Id> userIds)
	{
		return((List<User>) Database.query(
				newQueryFactory()
						.selectField('AccountId')
						.selectField('ContactId')
						.selectField('CreatedById')
						.setCondition('Id IN:userIds')
						.toSOQL()
		));
	}

	public List<User> selectByContacts(Set<Id> contactIds)
	{
		return((List<User>) Database.query(
				newQueryFactory()
						.selectField('AccountId')
						.selectField('ContactId')
						.selectField('CreatedById')
						.setCondition('contactId IN: contactIds')
						.toSOQL()
		));
	}

	public List<User> selectByContactId(Set<Id> contactId)
	{
		return((List<User>) Database.query(
				newQueryFactory()
						.setCondition('ContactId IN:contactId')
						.toSOQL()
		));
	}

}
