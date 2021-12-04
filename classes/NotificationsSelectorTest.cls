@IsTest
public class NotificationsSelectorTest {
    
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
    static void itShouldGiveNotifications()
    {
        // GIVEN - Notifications are created with status as an unread and assigned to CAR-T coordinator
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(50, null);
        Test.startTest();
        insert notificationList;
        
        // WHEN - CO logs into TCP Landing Page 
        List<Notification__c> notificationListFromSelector = DisplayNotificationsController.getNotificationList();
        
        // THEN - CO should be able to view all Notification created on click of the bell icon on the Landing Page
        System.assert(isInserted(notificationListFromSelector),notificationListFromSelector.Size()==50);
    }
    
    @IsTest
    static void itShouldGive20AssignedNotifications()
    {
        // GIVEN - Notifcations are created which are assigned to CAR-T coordinator with Status Unread
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(45, null);
        Test.startTest();
        insert notificationList;
        
        //When CAR-T Coordinator clicks on bell icon.
        NotificationsSelector NotificationsSelectorObj = new NotificationsSelector();
        Notifications CARTCoordinatorUnreadNotification = NotificationsSelectorObj.selectByAssignedToWithStatusWithLimit(new Set<Id>{UserInfo.getUserId()},new Set<String>{'Unread'});
        
        
        // THEN - CO should be able to view only 20 Notification on click of the bell icon on the Landing Page
        System.assert(isInserted(notificationList),CARTCoordinatorUnreadNotification!=null);
        System.assert(CARTCoordinatorUnreadNotification.records.size()==20);
    }

    @IsTest
    static void itShouldReturnAllUnreadAssignedNotifications()
    {
        // GIVEN - Notifcations are created which are assigned to current user with Status Unread
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(45, null);
        Test.startTest();
        insert notificationList;
        
        //When CAR-T Coordinator clicks on bell icon.
        NotificationsSelector NotificationsSelectorObj = new NotificationsSelector();
        Notifications CARTCoordinatorUnreadNotification = NotificationsSelectorObj.selectByAssignedToWithStatus(new Set<Id>{UserInfo.getUserId()},new Set<String>{'Unread'});
        
        
        // THEN - CO should be able to view All Notification on click of the bell icon on the Landing Page
        System.assert(isInserted(notificationList),CARTCoordinatorUnreadNotification!=null);
        System.assert(CARTCoordinatorUnreadNotification.records.size()==45);
    }

    @IsTest
    static void itShouldReturnAllUnreadNotificationsAssignedToUser()
    {
        // GIVEN - Notifcations are created which are assigned to current user with Status Unread
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id PatientId = patientList[0].Id;
        
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(5, PatientId);
        insert notificationList;
        
        // WHEN - CO logs into Patient detail page
        Test.startTest();
        NotificationsSelector NotificationsSelectorObj = new NotificationsSelector();
        Notifications PatientUnreadNotifications = NotificationsSelectorObj.selectRelatedRecordId(new Set<Id>{PatientId},new Set<String>{'Unread'});
        Test.stopTest();
        
        // THEN - CO should be able to view the count of unread Notifications realted to the patient on the bell icon in patient detail page.
        System.assert(isInserted(notificationList), PatientUnreadNotifications.records.size() == 5);
    }
    
    @IsTest
    static void itShouldReturnNotificationsByID()
    {
        // GIVEN - Notifications are created which are assigned to current user with Status Unread
        List<Account> patientList = TestDataFactory.getPatientAccountsList();
        insert patientList;
        Id PatientId = patientList[0].Id;
        Set<Id> notificationIdSet = new Set<Id>();
        List<Notification__c> notificationList = TestDataFactory.getNotificationList(50, PatientId);
        insert notificationList;
        For(Notification__c notificationObj : notificationList)
        {
            notificationIdSet.add(notificationObj.Id);
        }
        
        // WHEN - Creating insatnce of NotificationsSelector and calling method selectById to get list of notifications from ID
        Test.startTest();
        NotificationsSelector NotificationsSelectorObj = new NotificationsSelector();
        Notifications PatientUnreadNotifications = NotificationsSelectorObj.selectById(notificationIdSet);
        Test.stopTest();
        
        // THEN - List of notifications size should be same as size of notification Id set.
        System.assert(isInserted(notificationList), PatientUnreadNotifications.records.size() ==notificationIdSet.size());
    }
}