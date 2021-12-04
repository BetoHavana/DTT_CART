public with sharing class NotificationEngineSelector extends fflib_SObjectSelector
{

	public static final Boolean ACTIVESTATUS = TRUE;

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				NotificationEngine__mdt.Active__c,
				NotificationEngine__mdt.FinalStatus__c,
				NotificationEngine__mdt.InitialStatus__c,
				NotificationEngine__mdt.NotificationBody__c,
				NotificationEngine__mdt.NotificationSubject__c,
				NotificationEngine__mdt.ObjectAPIName__c,
				NotificationEngine__mdt.SourceFieldAPIName__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return NotificationEngine__mdt.sObjectType;
	}

	public List<NotificationEngine__mdt> selectAll()
	{
		return (List<NotificationEngine__mdt>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}

	public List<NotificationEngine__mdt> selectNotificationAlert(String objectAPIName, List<String> sourceFieldAPIName, String initialStatus, String finalStatus)
	{
		String objectAPI = NotificationEngine__mdt.ObjectAPIName__c.getDescribe().getName();
		String sourceFieldAPI = NotificationEngine__mdt.SourceFieldAPIName__c.getDescribe().getName();
		String activeStatus = NotificationEngine__mdt.Active__c.getDescribe().getName();
		String initialManufacturingStatus = NotificationEngine__mdt.InitialStatus__c.getDescribe().getName();
		String finalManufacturingStatus = NotificationEngine__mdt.FinalStatus__c.getDescribe().getName();
		return (List<NotificationEngine__mdt>) Database.query(
				newQueryFactory()
						.setCondition(objectAPI + ' =:objectAPIName AND ' + sourceFieldAPI + ' IN : sourceFieldAPIName AND ' + activeStatus + ' = TRUE  AND ' + initialManufacturingStatus + ' =:initialStatus AND ' + finalManufacturingStatus + ' =:finalStatus')
						.toSOQL()
		);
	}
}
