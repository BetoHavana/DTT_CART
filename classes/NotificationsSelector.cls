public with sharing class NotificationsSelector extends fflib_SObjectSelector
{
	String assignedTo = Notification__c.AssignedTo__c.getDescribe().getName();
	String notificationReadStatus = Notification__c.ReadStatus__c.getDescribe().getName();
	String notificationRelatedRecordId = Notification__c.RelatedRecordId__c.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Notification__c.AssignedTo__c,
				Notification__c.Id,
				Notification__c.Message__c,
				Notification__c.Name,
				Notification__c.ReadDate__c,
				Notification__c.ReadStatus__c,
				Notification__c.RelatedRecordId__c,
				Notification__c.Status__c,
				Notification__c.Subject__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Notification__c.SObjectType;
	}

	public List<Notification__c> selectAll()
	{
		return (List<Notification__c>) Database.query(
				newQueryFactory()
						.toSOQL()
		);
	}

	public Notifications selectById(Set<Id> notificationId)
	{
		return (Notifications) Application.Domain.newInstance(
				(List<Notification__c>) selectSObjectsById(notificationId)
		);
	}

	public Notifications selectByAssignedToWithStatusWithLimit(Set<id> assignedUserId, Set<String> status)
	{
		return (Notifications) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setCondition(assignedTo + ' IN: assignedUserId AND ' + notificationReadStatus + ' IN: status')
								.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
								.setLimit(Integer.valueOf(System.Label.notificationCountLimit))
								.toSOQL()
				)
		);
	}

	public Notifications selectByAssignedToWithStatus(Set<Id> assignedUserId, Set<String> status)
	{
		return (Notifications) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setCondition(assignedTo + ' IN: assignedUserId AND ' + notificationReadStatus + ' IN: status')
								.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
								.toSOQL()
				)
		);
	}

	public Notifications selectRelatedRecordId(Set<Id> relatedRecordId, Set<String> status)
	{
		return (Notifications) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.setCondition(notificationRelatedRecordId + ' IN: relatedRecordId AND ' + notificationReadStatus + ' IN: status')
								.setOrdering('LastModifiedDate', fflib_QueryFactory.SortOrder.DESCENDING)
								.toSOQL()
				)
		);
	}
}