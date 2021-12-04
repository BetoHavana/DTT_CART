public abstract inherited sharing class CareProgramsSelector extends fflib_SObjectSelector
{

	public CareProgramsSelector()
	{
		super();
	}

	public CareProgramsSelector(Boolean includeFieldSetFields, Boolean enforceCRUD, Boolean enforceFLS)
	{
		super(includeFieldSetFields,enforceCRUD,enforceFLS);
	}

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Schema.CareProgram.Id,
				Schema.CareProgram.name
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Schema.CareProgram.SObjectType;
	}

	public List<Schema.CareProgram> selectAll()
	{
		return ((List<Schema.CareProgram>) Database.query(
				newQueryFactory()
						.toSOQL()
		));
	}

}
