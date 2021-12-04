@isTest(seeAllData=false)
public with sharing class NotificationsServiceTest
{
	public static final String SCRIPTTHROWNEXCEPTION = 'Script-thrown exception';
	public static final string strSuccess = 'SUCCESS';

	@testSetup
	static void setup()
	{
		List<Account> patientAccountsList = TestDataFactory.getPatientAccountsList();
		insert patientAccountsList;

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector
				.newInstance(Contact.SObjectType))
				.selectByAccountId(new Set<Id> {patientAccountsList[0].Id})
				.getContactsByAccountId();

		List<Case> carePlanList = TestDataFactory.getCareplanCasesList(contactsByAccountIds.values());
		insert carePlanList;
	}

	@IsTest
	public static void itShouldCreateNotificationRecords()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
					.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
					.getById();

			List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});

			List<NotificationEngine__mdt> notificationEngineList = ((NotificationEngineSelector) Application.Selector
					.newInstance(NotificationEngine__mdt.SObjectType))
					.selectAll();

			List<UserRole> lstRole = ((UserRolesSelector) Application.Selector.newInstance(UserRole.SObjectType)).selectByName(new Set<String> {'Internal Site Administrator'});
			List<User> userList = TestDataFactory.getUsersToInsert('Internal Base User', 9);
			for (User objUser : userList)
			{
				objUser.UserRoleId = lstRole[0].Id;
			}
			insert userList;

			//WHEN - Notifications are being initiated for creation

			System.runAs(userList[0])
			{
				new NotificationsService().createNotificationRecords(new List<Account> {patientAccountsByIds.values()[0]}, notificationEngineList, userList, ordersList);
			}

			List<Notification__c> notificationsList = ((NotificationsSelector) Application.Selector.newInstance(Notification__c.SObjectType)).selectAll();

			//THEN - Notifications Alerts are being created for patients
			System.assertEquals(1, notificationsList.size(), strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateNotificationMessage()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
					.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
					.getById();

			List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});
			ordersList[0].OrderStatus__c = 'Order Rescheduled';
			ordersList[0].ApheresisPickUpDate__c = System.today();
			ordersList[0].ReasonforReschedule__c = 'Patient Health';
			update ordersList;

			//WHEN - Order status is changed to meet the above criteria

			String initialNotificationMessage = 'Test Notification' + '<Apheresis Pick-Up Date>';
			Notification__c objNotification = new Notification__c();
			objNotification.Message__c = initialNotificationMessage;

			new NotificationsService().updateNotificationBodyForPickupDateAndReason(objNotification, ordersList);

			//THEN - Notifications Alerts are being created for patients
			System.assertNotEquals(objNotification.Message__c, initialNotificationMessage, strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

	@IsTest
	public static void itShouldUpdateNotificationMessageForOther()
	{
		Test.startTest();
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientAccountsByIds = new Accounts(((AccountsSelector) Application.Selector
					.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.PatientRecordTypeDeveloperName}))
					.getById();

			List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId((new Map<Id, Account>(patientAccountsByIds)).keySet()).getRecords();

			List<Order__c> ordersList = ((OrdersSelector) Application.Selector
					.newInstance(Order__c.SObjectType))
					.selectOrdersByCarePlanId(new Set<Id> {carePlanList[0].Id});
			ordersList[0].OrderStatus__c = 'Order Rescheduled';
			ordersList[0].ApheresisPickUpDate__c = System.today();
			ordersList[0].ReasonforReschedule__c = 'Other';
			ordersList[0].SpecifyTheOtherReasonForReschedule__c = 'Test Reason';
			update ordersList;

			//WHEN - Order status is changed to meet the above criteria

			String initialNotificationMessage = 'Test Notification' + '<Apheresis Pick-Up Date>' + '<Reason for Rescheduling>';
			Notification__c objNotification = new Notification__c();
			objNotification.Message__c = initialNotificationMessage;

			new NotificationsService().updateNotificationBodyForPickupDateAndReason(objNotification, ordersList);

			//THEN - Notifications Alerts are being created for patients
			System.assertNotEquals(objNotification.Message__c, initialNotificationMessage, strSuccess);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		Test.stopTest();
	}

}