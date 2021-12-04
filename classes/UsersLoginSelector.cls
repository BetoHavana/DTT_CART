public with sharing class UsersLoginSelector extends fflib_SObjectSelector
{
	static string userId = UserLogin.UserId.getDescribe().getName();
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				UserLogin.Id,
				UserLogin.UserId,
				UserLogin.IsFrozen
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return UserLogin.SObjectType;
	}

	public List<UserLogin> selectByUserIds(Set<Id> userIds)
	{
		return((List<UserLogin>) Database.query(
				newQueryFactory()
						.setCondition(userId + ' IN : userIds')
						.toSOQL()
		));
	}

}