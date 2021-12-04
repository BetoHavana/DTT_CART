@IsTest
public class AccountsTest {

    public static final String ACTIVE = 'Active';
    public static final String INACTIVE = 'Inactive';
    public static final String SYSTEMADMIN = 'System Administrator';
    public static final String TREATMENTSITERECORDTYPEDEVELOPERNAME = 'TreatmentSite';

    @TestSetup
    static void setup()
    {
        Account treatmentSite = TestDataFactory.getBusinessAccountToInsert(TREATMENTSITERECORDTYPEDEVELOPERNAME);
        treatmentSite.status__c = 'Active';
        insert treatmentSite;

        Contact personnelContact = TestDataFactory.getSitePersonnelContact('personnel', treatmentSite.Id);
        insert personnelContact;

        Set<String> userProfileName = new Set<String>{SYSTEMADMIN};
        List<User> userList = new UsersSelector().selectByProfileName(userProfileName);
        User usr = new User();

        for(User user : userList){
            if(user.UserRoleId != null)
            {
                usr = user;
            }
        }
        System.runAs(usr)
        {
            User user = TestDataFactory.getUsersToInsert('External Base User', 1)[0];
        	user.contactId = personnelContact.Id;
        	insert user;
        }
    }

    static boolean isInserted(List<Account> accountsList)
    {
        Boolean status = true;
        for (Account accountRec : accountsList)
        {
            if (accountRec.Id == null)
            {
                status = false;
            }
        }
        return status;
    }

    @isTest
    static void createPatientRecordTest()
    {
        // GIVEN - We have retrieved test patient data
        List<Account> patientAccountsList = TestDataFactory.getPatientAccountsList();
        Test.startTest();
        // WHEN - We create test data records
        insert patientAccountsList;
        Test.stopTest();
        // THEN - It should validate if the test data records have been created successfully
        System.assert(isInserted(patientAccountsList), 'All Patient Accounts Inserted');
    }

    @isTest
    static void itShouldCreatePublicGroupsForTreatmentSites()
    {
		//GIVEN - System has pre-configured record type set up for Treatment Site(s)
		List<Account> treatmentSiteAccountsList = TestDataFactory.getBusinessAccountsList(TREATMENTSITERECORDTYPEDEVELOPERNAME, 10);
        Test.startTest();
        insert treatmentSiteAccountsList;
        Test.stopTest();
		//WHEN - Internal User with appropriate access creates Treatment Site(s)
        Map<Id, Account> mapOfTreatmentSites = new Accounts(treatmentSiteAccountsList).getById();
        Map<String, Account> mapAccountsByGroupName = AccountsService.getTreatmentSitesByGroupNameForAccountIds(mapOfTreatmentSites.keySet());
		//THEN - A Public Group should be created for that Treatment Site(s)
        Map<Id, Group> groupMap = ((GroupsSelector)Application.Selector.newInstance(Group.SObjectType)).selectByName(mapAccountsByGroupName.keySet()).getById();
        System.assertEquals(11, groupMap.size(), 'Success');
    }

    @IsTest
    static void itShouldDeactivateRelatedContactsAndUsers()
    {
        //GIVEN - AccountSite has been created with the status__c = active
        List<Account> accountList = new AccountsSelector().selectByDeveloperName(
            Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TREATMENTSITERECORDTYPEDEVELOPERNAME).getRecordTypeId()
        );

        Set<String> sitePersonasSet = new Set<String>{ Label.CARTCoordinator };
        List<Contact> contactList =  new ContactsSelector().selectContactsByAccountsIdAndStatus(new Set<Id>{accountList[0].Id}, sitePersonasSet, ACTIVE);

        List<User> userList = new UsersSelector().selectByContacts(new Set<Id>{contactList[0].Id});

        //WHEN - AccountSite status__c = Inactive
        Test.startTest();
        accountList[0].status__c = Label.Inactive;
        update accountList;
        Test.stopTest();

        //THEN - It should deactivate the user and its related contact as well
        System.assert(new UsersLoginSelector().selectByUserIds(new Set<Id>{ userList[0].Id } )[0].IsFrozen);
        System.assertEquals(1 , new ContactsSelector().selectContactsByAccountsIdAndStatus(new Set<Id>{accountList[0].Id}, sitePersonasSet, INACTIVE).size());
    }
}
