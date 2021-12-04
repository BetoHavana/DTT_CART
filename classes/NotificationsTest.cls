@IsTest
public class NotificationsTest {

    static boolean isInserted(List<Notification__c> notificationList)
    {
        Boolean status = true;
        for (Notification__c notificationRecord : notificationList)
        {
            if (notificationRecord.Id == null)
            {
                status = false;
            }
        }
        return status;
    }

    @IsTest
    static void itShouldGiveNotificationsId()
    {
        // GIVEN - Notifcations are created to a CO on a status change in CCM
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(1, null);
        Test.startTest();
        insert notificationList;

        // WHEN - CO logs into TCP Landing Page
        List<Notification__c> notificationListFromSelector = DisplayNotificationsController.getNotificationList();
        Notifications notificationObj = new Notifications(notificationList);
        notificationObj.getById();
        Test.stopTest();

        // THEN - CO should be able to view the Notification on click of the bell icon on the Landing Page
        System.assert(isInserted(notificationListFromSelector),notificationObj!=null);
    }

}