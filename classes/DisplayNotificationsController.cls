public with sharing class DisplayNotificationsController
{
	public final static String STATUSREAD = 'Read';
	public final static String STATUSUNREAD = 'Unread';

	@AuraEnabled(cacheable=true)
	public static Integer getTotalNotificationsSize()
	{
		Set<Id> assignedUserIds = new Set<Id>();
		Set<String> readStatus = new Set<String>();
		assignedUserIds.add(UserInfo.getUserId());
		readStatus.add(STATUSUNREAD);
		List<Notification__c> notifications =
				(new NotificationsSelector().selectByAssignedToWithStatus(assignedUserIds, readStatus)).records ;
		return notifications.size();
	}

	@AuraEnabled(cacheable=true)
	public static List<Notification__c> getNotificationList()
	{
		Set<Id> assignedUserIds = new Set<Id>();
		Set<String> readStatus = new Set<String>();
		assignedUserIds.add(UserInfo.getUserId());
		readStatus.add(STATUSUNREAD);
		List<Notification__c> notifications =
				(new NotificationsSelector().selectByAssignedToWithStatusWithLimit(assignedUserIds, readStatus)).records ;
		return notifications;
	}

	@AuraEnabled
	public static Boolean updateNotificationStatus(Id notificationId)
	{
		Boolean success = false;
		Set<Id> notificationsIds = new Set<Id> {notificationId};
		List<Notification__c> notificationsToUpdate = new List<Notification__c>();
		List<Notification__c> notifications =
				(new NotificationsSelector().selectById(notificationsIds)).records ;

		if (!notifications.isEmpty())
		{
			for (Notification__c notification : notifications)
			{
				notification.ReadStatus__c = STATUSREAD;
				notification.ReadDate__c = System.Date.today();
				notificationsToUpdate.add(notification);
			}
		}

		try
		{
			fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
			unitOfWork.registerDirty(notificationsToUpdate);
			unitOfWork.commitWork();
			success = true;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
		return success;
	}

	@AuraEnabled(cacheable=true)
	public static List<Notification__c> getPatientNotificationList(String patientId)
	{
		Set<Id> patientIds = new Set<Id>{ patientId };
		Set<String> readStatus = new Set<String>{ STATUSUNREAD };

		List<Notification__c> notifications =
				(new NotificationsSelector().selectRelatedRecordId(patientIds, readStatus)).records ;
		return notifications;
	}
}