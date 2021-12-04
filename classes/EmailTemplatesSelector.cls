public with sharing class EmailTemplatesSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
			EmailTemplate.DeveloperName,
			EmailTemplate.Id,
            EmailTemplate.Name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return EmailTemplate.SObjectType;
	}

	public List<EmailTemplate> selectAll()
	{
		//Disabled CRUD for temporary fix need
		// TO DO : delete this class and use sflib_EmailTemplateSelectorelevatedImp
		return (List<EmailTemplate>) Database.query(
				newQueryFactory(false, false, true)
						.toSOQL()
		);
	}

}