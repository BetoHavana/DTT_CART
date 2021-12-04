Public inherited sharing class BusinessHoursSelector extends sflib_SObjectSelector
{

	Public SObjectType getSObjectType()
	{
		return BusinessHours.SObjectType;
	}

	Public List<SObjectField> getSObjectFieldList()
	{
		return new List<SObjectField>
		{
				BusinessHours.IsActive,
				BusinessHours.IsDefault,
				BusinessHours.Name
		};
	}

	Public List<BusinessHours> selectBusinessHoursByName(String businessHours)
	{
		return selectBusinessHoursByName(new Set<String> {businessHours});
	}

	Public List<BusinessHours> selectBusinessHoursByName(Set<String> businessHoursNames)
	{
		return (List<BusinessHours>) Database.query(
					newQueryFactory()
							.setCondition(BusinessHours.Name.getDescribe().getName() + ' IN :businessHoursNames')
							.toSOQL());
	}

}