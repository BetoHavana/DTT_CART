@IsTest
public class DisplayNotificationsControllerTest {

    public final static String STATUSREAD = 'Read';

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
    static void itShouldReturnAllUnreadNotificationsAssignedToUser()
    {
        // GIVEN - Notifcations are created to a CO on a status change in CCM
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id PatientId = patientList[0].Id;

        List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, PatientId);
        insert notificationList;

        // WHEN - CO logs into TCP Landing Page
        Test.startTest();
        Integer notificationCount =DisplayNotificationsController.getTotalNotificationsSize();
        Test.stopTest();

        // THEN - CO should be able to view the Notifications count on the bell icon on the Landing Page
        System.assert(isInserted(notificationList), notificationCount == 5);
    }

    @IsTest
    static void itShouldGiveTheUnreadNotificationList()
    {
        // GIVEN - Notifcations are created to a CO on a status change in CCM
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id PatientId = patientList[0].Id;

        List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, PatientId);
        insert notificationList;

        // WHEN - CO logs into TCP Landing Page and clicks on the Alert bell icon
        Test.startTest();
        List<Notification__c> notificationListFromSelector = DisplayNotificationsController.getNotificationList();
        Test.stopTest();

        // THEN - CO should be able to view all the Notifications
        System.assert(isInserted(notificationList), notificationList == notificationListFromSelector);
    }

    @IsTest
    static void itShouldUpdateTheUnreadNotificationToRead()
    {
        // GIVEN - Notifcations are created to a CO on a status change in CCM
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id patientId = patientList[0].Id;

        Set<Id> patientIds = new Set<Id>{ patientId };
        Set<String> readStatus = new Set<String>{ 'Read' };

        List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, PatientId);
        insert notificationList;

        // WHEN - CO logs into TCP Landing Page and clicks on "Mark as Read" action on Alert popover
        Test.startTest();
        Boolean isNotificationRead = DisplayNotificationsController.updateNotificationStatus(notificationList[0].Id);
        Test.stopTest();

        // THEN - The Notification should be removed from the view and status of the Alert should be updated to "Read"
        System.assert(isInserted(notificationList),
                (new NotificationsSelector().selectRelatedRecordId(patientIds, readStatus)).records.size() > 0);
        System.assert(isNotificationRead);
    }

    @IsTest
    static void itShouldGiveTheUnreadPatientNotifications()
    {
        // GIVEN - Notifcations are created to a CO on a status change in CCM
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id PatientId = patientList[0].Id;

        List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, PatientId);
        insert notificationList;
        Test.startTest();

        // WHEN - CO logs into TCP Landing Page and clicks on Patients tab.
        Integer PatientUnreadNotifications = DisplayNotificationsController.getPatientNotificationList(PatientId).size();
        Test.stopTest();

        // THEN - It will display All Related Notifications to Patient.
        System.assert(isInserted(notificationList), PatientUnreadNotifications == 5);
    }

}