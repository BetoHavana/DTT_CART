@isTest
public class PatientServicesEnrolleeSharingBaScTest
{
    @testSetup
    private static void setUpTestData()
    {
        TestDataFactory.createOrders();
    }

    @isTest
    private static void testScheduling()
    {
        //GIVEN IM AN ADMINISTRATOR AND I WANT TO SCHEDULE THE JOB

        Test.startTest();

        //WHEN I SCHEDULE THE JOB
        PatientServicesEnrolleeSharingBatchSchlr.scheduleBatch();

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB IS Scheduled
        List<CronTrigger> asyncJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :PatientServicesEnrolleeSharingBatchSchlr.BATCHNAME.trim()+'%'];
        System.assert(!asyncJobs.isEmpty(),'PatientServicesEnrolleeSharingBatchSchlr Batch is Not Scheduled');
    }

    @isTest
    private static void checkIfApexBatchIsProperlyScheduled()
    {
        //GIVEN IM AN ADMINISTRATOR AND I WANT TO SCHEDULE THE JOB

        Test.startTest();

        //WHEN I SCHEDULE THE JOB
        PatientServicesEnrolleeSharingBatchSchlr sch = new PatientServicesEnrolleeSharingBatchSchlr();
        SchedulableContext cntxt = null;
        sch.execute(cntxt);

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB EXECUTING THE BATCH (BUSINESS LOGIC)
        List<AsyncApexJob> asyncJobs = [SELECT ApexClass.Name, JobType FROM AsyncApexJob WHERE ApexClass.Name = 'PatientServicesEnrolleeSharingBatchSchlr'];
        System.assert(!asyncJobs.isEmpty(),'Batch Execution is Not Started');
        System.assertEquals(asyncJobs[0].JobType, 'BatchApex');
    }
}
