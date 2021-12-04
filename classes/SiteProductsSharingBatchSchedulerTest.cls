@isTest
public class SiteProductsSharingBatchSchedulerTest {
    private static final String BATCHNAME = 'Sharing SiteProduct Accounts Records Batch';
    private static final String HYPEN = ' - ';
    private static final String CRONEXPR_FORDAILYSTARTOFDAY = '0 0 0 ? * * *';
    private static final String INDUSTRIESBUSINESS = 'IndustriesBusiness';
    private static final String SPECIALTYDISTRIBUTOR = 'SpecialtyDistributor';
    private static final String TESTLOCATION = 'Test Location';
    private static final String HEALTHSYSTEM = 'HealthSystem';
    private static final String PATIENTRECORDTYPEDEVELOPERNAME = 'Patient';

    @testSetup
    private static void setUpTestData()
    {
        List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
        List<String> listOfSitesNames = new List<String>();
        listOfSitesNames.add(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
        listOfSitesNames.add(StaticConstants.APHERESISSITE);
        listOfSitesNames.add(StaticConstants.CRYOSITE);
        listOfSitesNames.add(SPECIALTYDISTRIBUTOR);
        listOfSitesNames.add(HEALTHSYSTEM);

        for (String siteName : listOfSitesNames)
        {
            accToBeInserted.addAll(TestdataFactory.getBusinessAccountsList(siteName, 3));
        }
        insert accToBeInserted;

        List<Account> accountsToBeUpdated = new List<Account>();
        List<Contact> contactList = new List<Contact>();
        Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
        Id trtSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            						.get(StaticConstants.TreatmentSiteRecordTypeDeveloperName)
            						.getRecordTypeId();
        Id aphSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            						.get(StaticConstants.APHERESISSITE)
            						.getRecordTypeId();
        Id cryoSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            						.get(StaticConstants.CRYOSITE)
            						.getRecordTypeId();
        Id specialtyDistributorId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
                                	.get(SPECIALTYDISTRIBUTOR)
            						.getRecordTypeId();
        Id healthSystemRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            						.get(HEALTHSYSTEM)
            						.getRecordTypeId();
        List<Id> treatmentSiteIds = new List<Id>();
        List<Id> apheresisSiteIds = new List<Id>();
        List<Id> cryoSiteIds = new List<Id>();
        List<Id> SDIds = new List<Id>();
        List<Id> healthSystemIds = new List<Id>();
        for (Account site : accToBeInserted)
        {
            if (patientRecordTypeId.equals(site.RecordTypeId))
            {
                site.Status__c = StaticConstants.PatientStatusVerified;
                accountsToBeUpdated.add(site);
            }
            else
            {
                contactList.add(TestDataFactory.getBusinessAccRelatedContacts(site.Name, site.Id));
                site.Type = StaticConstants.cryoSiteLocal;
                accountsToBeUpdated.add(site);
                if(healthSystemRecordTypeId.equals(site.RecordTypeId))
                {
                    healthSystemIds.add(site.Id);
                }
                else if (trtSiteRecordTypeId.equals(site.RecordTypeId))
                {
                    treatmentSiteIds.add(site.Id);
                }
                else if (aphSiteRecordTypeId.equals(site.RecordTypeId))
                {
                    apheresisSiteIds.add(site.Id);
                }
                else if (cryoSiteRecordTypeId.equals(site.RecordTypeId))
                {
                    cryoSiteIds.add(site.Id);
                }

                else
                {
                    SDIds.add(site.Id);
                }
            }
        }
        update accountsToBeUpdated;

        List<Product2> productList = TestDataFactory.getProductsList('JNJ-4528', 3);
        insert productList;

        List<SiteProduct__c> siteProductsList = TestDataFactory.getSiteProducts(treatmentSiteIds, SDIds, productList);
        insert siteProductsList;

        siteProductsList.get(0).REMSID__c = '232';
        Update siteProductsList;

        insert contactList;

        List<Schema.Location> locationsList = TestDataFactory.getLocationRecords(TESTLOCATION, 3);
        insert locationsList;

        List<Schema.AssociatedLocation> assLocList = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(cryoSiteIds, locationsList, 3);
        insert assLocList;

        List<Schema.AssociatedLocation> assLocListforTreatmentSites = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(treatmentSiteIds,locationsList,3);
        insert assLocListforTreatmentSites;

        system.assertNotEquals(NULL, assLocList[0].Id);

        List<Contact> businessContactsList = ((ContactsSelector) Application.Selector
                                              .newInstance(Contact.SObjectType))
            .selectAllByRecTypeDeveloperName(new Set<String> {INDUSTRIESBUSINESS});
        system.assertNotEquals(NULL, businessContactsList[0].Id);

        List<HealthCloudGA__ReciprocalRole__c> reciprocalRolesList = new List<HealthCloudGA__ReciprocalRole__c>();

        HealthCloudGA__ReciprocalRole__c carTCoordinatorRole = TestDataFactory.getContactRole(StaticConstants.CARTCOORDINATOR, StaticConstants.contactRole);
        reciprocalRolesList.add(carTCoordinatorRole);

        HealthCloudGA__ReciprocalRole__c aphSiteRole = TestDataFactory.getContactRole(Label.RoleAphresisSite, StaticConstants.accountRole);
        reciprocalRolesList.add(aphSiteRole);

        HealthCloudGA__ReciprocalRole__c cryoSiteRole = TestDataFactory.getContactRole(StaticConstants.CRYOSITELABEL, StaticConstants.accountRole);
        reciprocalRolesList.add(cryoSiteRole);
        insert reciprocalRolesList;

        List<Account> accountsList = new AccountsSelector().selectAllContactsForAccount(patientRecordTypeId);
        List<Contact> conList = new List<Contact>();
        for (Account acc : accountsList)
        {
            conList.add(acc.Contacts);
        }

        List<Id> conIdList = new List<Id>();
        conIdList.addAll(sflib_ArrayUtils.pluckIdField(conList, Contact.Id));

        List<Id> contactIdList = new List<Id>();
        contactIdList.addAll(sflib_ArrayUtils.pluckIdField(businessContactsList, Contact.Id));

        List<HealthCloudGA__ContactContactRelation__c> associatedContactsList = new List<HealthCloudGA__ContactContactRelation__c>();
        associatedContactsList = TestDataFactory.getAssociatedContactRelationsToInsert(contactIdList, conIdList, carTCoordinatorRole.Name, StaticConstants.contactRole, 2);
        insert associatedContactsList;

        List<HealthCloudGA__AccountAccountRelation__c> accRelationList =
            new List<HealthCloudGA__AccountAccountRelation__c>();
        accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(treatmentSiteIds, apheresisSiteIds, aphSiteRole.Id, 2));
        accRelationList.addAll(TestDataFactory.getAccountRelationsToInsertBasedOnSites(apheresisSiteIds, cryoSiteIds, cryoSiteRole.Id, 2));
        insert accRelationList;
        system.assertNotEquals(NULL, accRelationList[0].Id);
    }

    @isTest
    static void itShouldExecuteSiteProductsSharingBatchScheduler()
    {
        //GIVEN When I'm on patient record
        Test.startTest();

        //WHEN i create a relationship Product via Site-Product related list
        SiteProductsSharingBatchScheduler batchJob = new SiteProductsSharingBatchScheduler();
        Database.executeBatch(batchJob);
        SiteProductsSharingBatchScheduler.scheduleBatch();

        Map<Id, Account> treatmentSiteByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                                                           .selectAll()
                                                           .getByRecordTypeDeveloperName(new Set<String> {StaticConstants.TreatmentSiteRecordTypeDeveloperName}))
            												.getById();
        List<AccountShare> accShareList = new AccountSharesSelector().selectSObjectSharesBySObjectIds(treatmentSiteByIds.keySet());

        //THEN treatmentSite will be shared from AccountShare Object
        system.assert(!accShareList.isEmpty());
        Test.stopTest();
    }

}
