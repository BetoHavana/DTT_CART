@isTest(seeAllData=false)
public with sharing class UsersTest
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String TREATMENTSITERECORDTYPEDEVELOPERNAME = 'TreatmentSite';

	static List<User> userList;

	static void init()
	{
		List<UserRole> lstRole = ((UserRolesSelector) Application.Selector.newInstance(UserRole.SObjectType)).selectByName(new Set<String> {'Internal Site Administrator'});
		userList = TestDataFactory.getUsersToInsert('Internal Base User', 9);
		for (User objUser : userList)
		{
			objUser.UserRoleId = lstRole[0].Id;
		}
		insert userList;

		Set<String> permissionSets = new Set<String>();
		permissionSets.add('PatientManagement');
		permissionSets.add('UserManagementPermissionSet');

		List<PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
		for (Integer i = 0; i < 10; i++)
		{
			permissionSetAssignments.addAll(TestDataFactory.assignPermissionSets(permissionSets, userList[i]));
		}
		insert permissionSetAssignments;

	}

	@testSetup static void testDataSetup()
	{
		init();
		System.runAs(userList[0])
		{
			List<Account> treatmentSiteAccountsList = TestDataFactory.getBusinessAccountsList(TREATMENTSITERECORDTYPEDEVELOPERNAME, 5);
			insert treatmentSiteAccountsList;

			List<Contact> contacts = new List<Contact>();
			Contact objContact1 = TestDataFactory.getBusinessAccRelatedContacts('test1', treatmentSiteAccountsList[0].Id);
			objContact1.SitePersona__c = CARTCOORDINATOR;
			Contact objContact2 = TestDataFactory.getBusinessAccRelatedContacts('test2', treatmentSiteAccountsList[1].Id);
			objContact2.SitePersona__c = CARTCOORDINATOR;
			Contact objContact3 = TestDataFactory.getBusinessAccRelatedContacts('test3', treatmentSiteAccountsList[2].Id);
			objContact3.SitePersona__c = CARTCOORDINATOR;
			Contact objContact4 = TestDataFactory.getBusinessAccRelatedContacts('test4', treatmentSiteAccountsList[3].Id);
			objContact4.SitePersona__c = CARTCOORDINATOR;
			Contact objContact5 = TestDataFactory.getBusinessAccRelatedContacts('test5', treatmentSiteAccountsList[4].Id);
			objContact5.SitePersona__c = CARTCOORDINATOR;
			contacts.add(objContact1);
			contacts.add(objContact2);
			contacts.add(objContact3);
			contacts.add(objContact4);
			contacts.add(objContact5);
			insert contacts;
		}
	}

	@isTest
	static void itShouldCreateGroupMembersForTreatmentSiteAccounts()
	{

		//GIVEN - Treatment Site(s) public group(s) are created in the System and appropriate Site Personnel are set up for Treatment Site(s)
		Map<Id, Account> treatmentSiteAccountsByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
				.selectAll()
				.getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName}))
				.getById();

		Map<Id, Contact> contactsByAccountIds = ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
				.selectByAccountId(treatmentSiteAccountsByIds.keySet()).getContactsByAccountId();

		Test.startTest();
		// WHEN - Community access for the Site Personnel is enabled
		List<User> externalUsers = new List<User>();
		List<User> users = TestDataFactory.getUsersToInsert('External Base User', 4);
		for (Integer i = 0; i < 5; i++)
		{
			User objUser = users[i];
			objUser.ContactId = contactsByAccountIds.values()[i].Id;
			externalUsers.add(objUser);
		}
		insert externalUsers;
		Test.stopTest();
		// THEN - Community user(s) should be successfully added to the Treatment Site Public Group
		List<GroupMember> groupMembers = ((GroupMembersSelector) Application.Selector.newInstance(GroupMember.SObjectType)).selectAll();
		System.assertNotEquals(0, groupMembers.size(), 'Success');
	}
}
