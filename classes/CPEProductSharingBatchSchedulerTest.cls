@isTest
public class CPEProductSharingBatchSchedulerTest
{
    Private Static Final String ACTIVE = 'Active';
    Private Static Final String CAREPROGRAMPRODUCT = 'Test Care Program Product';
    Private Static Final String INDUSTRIESBUSINESS = 'IndustriesBusiness';
    Private Static Final String JNJPRODUCT ='JNJ-4528';
    Private Static Final String SPECIALTYDISTRIBUTOR = 'SpecialtyDistributor';
    Private Static Final String TESTCAREPROGRAM = 'Test Care Program';
    Private Static Final String TESTLOCATION = 'Test Location';

    @testSetup
    private static void setUpTestData()
    {
        CareProgram careProgramRecord = TestDataFactory.getCareProgramsList(TESTCAREPROGRAM, 1)[0];
        insert careProgramRecord;

        CareProgramProduct CareProgramProductRecord = new CareProgramProduct();
        CareProgramProductRecord.Name = CAREPROGRAMPRODUCT;
        CareProgramProductRecord.CareProgramId = CareProgramRecord.Id;
        CareProgramProductRecord.Status = ACTIVE;
        insert CareProgramProductRecord;

        List<String> listOfSitesNames = new List<String>();
        List<Account> accToBeInserted = TestDataFactory.getPatientAccountsList();
        listOfSitesNames.add(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
        listOfSitesNames.add(StaticConstants.APHERESISSITE);
        listOfSitesNames.add(StaticConstants.CRYOSITE);
        listOfSitesNames.add(SPECIALTYDISTRIBUTOR);

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
        List<Id> treatmentSiteIds = new List<Id>();
        List<Id> apheresisSiteIds = new List<Id>();
        List<Id> cryoSiteIds = new List<Id>();
        List<Id> SDIds = new List<Id>();
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
                if (trtSiteRecordTypeId.equals(site.RecordTypeId))
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

        List<Product2> productList = TestDataFactory.getProductsList(JNJPRODUCT, 3);
        insert productList;

        List<SiteProduct__c> siteProductsList = TestDataFactory.getSiteProducts(treatmentSiteIds, SDIds, productList);
        insert siteProductsList;

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
        List<CareProgramEnrollee> CareProgramEnrollee = TestDataFactory.getCareProgramEnrolleeRecords(new Map<Id, Id>{accountsList[0].Id => careProgramRecord.Id});
        insert CareProgramEnrollee;

        List<CareProgramEnrolleeProduct> CareProgramEnrolleeProductList = TestDataFactory.getCareProgramEnrolleeProductRecords(new map<Id, Id> {CareProgramEnrollee[0].Id => CareProgramProductRecord.Id});
        insert CareProgramEnrolleeProductList;

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
    }
    @isTest
    private static void testScheduling()
    {
        //GIVEN IM AN ADMINISTRATOR AND I WANT TO SCHEDULE THE JOB

        Test.startTest();

        //WHEN I SCHEDULE THE JOB
        CPEProductSharingBatchScheduler.scheduleBatch();

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB IS Scheduled
        List<CronTrigger> asyncJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :CPEProductSharingBatchScheduler.BATCHNAME.trim()+'%'];
        System.assert(!asyncJobs.isEmpty(),'CPEProductSharingBatchScheduler Batch is Not Scheduled');
    }

    @isTest
    private static void checkIfApexBatchIsProperlyScheduled()
    {
        //GIVEN IM AN ADMINISTRATOR AND I WANT TO SCHEDULE THE JOB

        Test.startTest();

        //WHEN I START THE SCHEDULED JOB
        CPEProductSharingBatchScheduler sch = new CPEProductSharingBatchScheduler();
        SchedulableContext cntxt = null;
        sch.execute(cntxt);

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB EXECUTING THE BATCH (BUSINESS LOGIC)
        List<AsyncApexJob> asyncJobs = [SELECT ApexClass.Name, JobType FROM AsyncApexJob WHERE ApexClass.Name = 'CPEProductSharingBatchScheduler'];
        System.assert(!asyncJobs.isEmpty(),'Batch Execution is Not Started');
        System.assertEquals(asyncJobs[0].JobType, 'BatchApex');
    }
}
