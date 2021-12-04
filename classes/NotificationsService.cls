public with sharing class NotificationsService
{
	private static final String activeStatus = 'Active';
	private static final String OTHERREASONFORRESCHEDULE = 'Other';
	private static final String readStatus = 'Unread';

	public void createNotificationRecords(List<Account> patientsList, List<NotificationEngine__mdt> notificationEngineList, List<User> cartCoordinatorRecords, List<Order__c> orderRecords)
	{
		List<Notification__c> notificationAlerts = new List<Notification__c>();
		for (Account patientInstance : patientsList)
		{
			Notification__c notificationsInstance = new Notification__c();
			notificationsInstance.AssignedTo__c = cartCoordinatorRecords[0].id;
			notificationsInstance.OwnerId = cartCoordinatorRecords[0].id;
			notificationsInstance.RelatedRecordId__c = patientInstance.Id;
			notificationsInstance.Subject__c = notificationEngineList[0].NotificationSubject__c.replace('<Patient Name>', (patientInstance.FirstName != null ? patientInstance.LastName + ', ' + patientInstance.FirstName : ''));
			notificationsInstance.Message__c = notificationEngineList[0].NotificationBody__c.replace('<Patient Name>', (patientInstance.FirstName != null ? patientInstance.LastName + ', ' + patientInstance.FirstName : ''));
			updateNotificationBodyForPickupDateAndReason(notificationsInstance, orderRecords);
			notificationsInstance.ReadStatus__c = readStatus;
			notificationsInstance.Status__c = activeStatus;
			notificationAlerts.add(notificationsInstance);
		}
		if (!notificationAlerts.isEmpty())
		{
			NotificationsService.createAlertNotifications(notificationAlerts);
		}
	}

	@TestVisible
	private void updateNotificationBodyForPickupDateAndReason(Notification__c notificationsInstance, List<Order__c> orderRecords)
	{
		if (notificationsInstance.Message__c.contains('<Apheresis Pick-Up Date>') && orderRecords[0].ApheresisPickUpDate__c != null)
		{
			String ApheresisPickUpDate = 'MMM dd, yyyy';
			Datetime formattedDate = Datetime.newInstance(orderRecords[0].ApheresisPickUpDate__c.year(), orderRecords[0].ApheresisPickUpDate__c.month(), orderRecords[0].ApheresisPickUpDate__c.day());
			notificationsInstance.Message__c = notificationsInstance.Message__c.replace('<Apheresis Pick-Up Date>', (orderRecords[0].ApheresisPickUpDate__c != null ? formattedDate.format(ApheresisPickUpDate) : ''));
			if (orderRecords[0].ReasonforReschedule__c == OTHERREASONFORRESCHEDULE && orderRecords[0].ReasonforReschedule__c != null)
			{
				notificationsInstance.Message__c = notificationsInstance.Message__c.replace('<Reason for Rescheduling>', (orderRecords[0].SpecifyTheOtherReasonForReschedule__c != null ? orderRecords[0].SpecifyTheOtherReasonForReschedule__c : ''));
			}
			else
			{
				notificationsInstance.Message__c = notificationsInstance.Message__c.replace('<Reason for Rescheduling>', (orderRecords[0].ReasonforReschedule__c != null ? orderRecords[0].ReasonforReschedule__c : ''));
			}
		}
	}

	public static void createAlertNotifications(List<Notification__c> notificationAlerts)
	{
		try
		{
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerNew(notificationAlerts);
			uow.commitWork();
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
		}
	}
}