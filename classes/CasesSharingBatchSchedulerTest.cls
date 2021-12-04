@isTest
public class CasesSharingBatchSchedulerTest
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
        CasesSharingBatchScheduler.scheduleBatch();

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB IS Scheduled
        List<CronTrigger> asyncJobs = [SELECT Id FROM CronTrigger WHERE CronJobDetail.Name LIKE :CasesSharingBatchScheduler.BATCHNAME.trim()+'%'];
        System.assert(!asyncJobs.isEmpty(),'CasesSharingBatchScheduler Batch is Not Scheduled');
    }

    @isTest
    private static void checkIfApexBatchIsProperlyScheduled()
    {
        //GIVEN IM AN ADMINISTRATOR AND I WANT TO SCHEDULE THE JOB

        Test.startTest();

        //WHEN I SCHEDULE THE JOB
        CasesSharingBatchScheduler sch = new CasesSharingBatchScheduler();
        SchedulableContext cntxt = null;
        sch.execute(cntxt);

        Test.stopTest();

        //THEN I SHOULD SEE THE JOB EXECUTING THE BATCH (BUSINESS LOGIC)
        List<AsyncApexJob> asyncJobs = [SELECT ApexClass.Name, JobType FROM AsyncApexJob WHERE ApexClass.Name = 'CasesSharingBatchScheduler'];
        System.assert(!asyncJobs.isEmpty(),'Batch Execution is Not Started');
        System.assertEquals(asyncJobs[0].JobType, 'BatchApex');
    }
}
