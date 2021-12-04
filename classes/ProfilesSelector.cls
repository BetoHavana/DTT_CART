public with sharing class ProfilesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Profile.Id,
				Profile.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Profile.SObjectType;
	}

	public List<Profile> selectByName(String profileName)
	{
		return ((List<Profile>) Database.query(
				newQueryFactory()
						.selectField('Name')
						.setCondition('Name =:profileName')
						.toSOQL()
		));
	}
}