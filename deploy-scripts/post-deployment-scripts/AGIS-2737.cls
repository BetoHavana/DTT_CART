/* Setup logging level for Deployment User so that we can track batch runs STARTS*/

if ([SELECT id from sflib_LogLevelFilter__c WHERE SetupOwnerId = :Userinfo.getUserId()]?.Id == null)
{
	insert new sflib_LogLevelFilter__c(setupOwnerId = Userinfo.getUserid(), LogLevel__c = 'info');
}

/* Setup logging level for Deployment User so that we can track batch runs ENDS */



System.debug('Started setting up configs for Manual Sharing Batches');
String last_N_NoOfDays = '10';


/* SiteProductsSharingBatchScheduler STARTS */
System.debug('Setting Up Config for SiteProductsSharingBatchScheduler');
if (String.isBlank(sflib_Settings.get('SharingSPAccountsRecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingSPAccountsRecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingSPAccountsRecordsBatchLastNDays')), 'SiteProductsSharingBatchScheduler Last N Days is Not Set');
/* SiteProductsSharingBatchScheduler ENDS */


/* AccountAccountRelationSharingBatchShlr STARTS */
System.debug('Setting Up Config for AccountAccountRelationSharingBatchShlr');
if (String.isBlank(sflib_Settings.get('SharingAcntAcntRelationsBatchLastNDays')))
{
	sflib_Settings.set('SharingAcntAcntRelationsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingAcntAcntRelationsBatchLastNDays')), 'AccountAccountRelationSharingBatchShlr Last N Days is Not Set');
/* AccountAccountRelationSharingBatchShlr ENDS */


/* AccountContactRelationSharingBatchShlr STARTS */
System.debug('Setting Up Config for AccountContactRelationSharingBatchShlr');
if (String.isBlank(sflib_Settings.get('SharingAcntContctRelnsBatchLastNDays')))
{
	sflib_Settings.set('SharingAcntContctRelnsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingAcntContctRelnsBatchLastNDays')), 'AccountContactRelationSharingBatchShlr Last N Days is Not Set');
/* AccountContactRelationSharingBatchShlr ENDS */


/* ContactContactRelationSharingBatchShlr STARTS */
System.debug('Setting Up Config for AccountContactRelationSharingBatchShlr');
if (String.isBlank(sflib_Settings.get('SharingContContRelationsBatchLastNDays')))
{
	sflib_Settings.set('SharingContContRelationsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingContContRelationsBatchLastNDays')), 'ContactContactRelationSharingBatchShlr Last N Days is Not Set');
/* ContactContactRelationSharingBatchShlr ENDS */


/* CPEProductSharingBatchScheduler STARTS */
System.debug('Setting Up Config for CPEProductSharingBatchScheduler');
if (String.isBlank(sflib_Settings.get('SharingCPEProductRecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingCPEProductRecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingCPEProductRecordsBatchLastNDays')), 'CPEProductSharingBatchScheduler Last N Days is Not Set');
/* CPEProductSharingBatchScheduler ENDS */


/* CasesSharingBatchScheduler STARTS */
System.debug('Setting Up Config for CPEProductSharingBatchScheduler');
if (String.isBlank(sflib_Settings.get('SharingCaseRecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingCaseRecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingCaseRecordsBatchLastNDays')), 'CasesSharingBatchScheduler Last N Days is Not Set');
/* CasesSharingBatchScheduler ENDS */



/* CarePlanGoalsSharingBatchScheduler STARTS */
System.debug('Setting Up Config for CarePlanGoalsSharingBatchScheduler');
if (String.isBlank(sflib_Settings.get('SharingGoalRecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingGoalRecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingGoalRecordsBatchLastNDays')), 'CarePlanGoalsSharingBatchScheduler Last N Days is Not Set');
/* CarePlanGoalsSharingBatchScheduler ENDS */



/* PatientServicesEnrolleeSharingBatchSchlr STARTS */
System.debug('Setting Up Config for PatientServicesEnrolleeSharingBatchSchlr');
if (String.isBlank(sflib_Settings.get('SharingPSERecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingPSERecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingPSERecordsBatchLastNDays')), 'PatientServicesEnrolleeSharingBatchSchlr Last N Days is Not Set');
/* PatientServicesEnrolleeSharingBatchSchlr ENDS */


/* OrdersSharingBatchScheduler STARTS */
System.debug('Setting Up Config for OrdersSharingBatchScheduler');
if (String.isBlank(sflib_Settings.get('SharingOrderRecordsBatchLastNDays')))
{
	sflib_Settings.set('SharingOrderRecordsBatchLastNDays', last_N_NoOfDays);
}
System.assert(String.isNotBlank(sflib_Settings.get('SharingOrderRecordsBatchLastNDays')), 'OrdersSharingBatchScheduler Last N Days is Not Set');
/* OrdersSharingBatchScheduler ENDS */


// BELOW LINE SCHEDULES SiteProductsSharingBatchScheduler BATCH TO RUN DAILY AT 0:00 AM AND SiteProductsSharingBatchScheduler CHAINS OTHER BATCHES IN FINISH METHOD

List<CronTrigger> cronList =
[
		SELECT Id,CronJobDetail.Name, NextFireTime, CronExpression
		FROM CronTrigger
		WHERE CronJobDetail.Name LIKE :SiteProductsSharingBatchScheduler.BATCHNAME.trim() +
				'%'
];

if (cronList.isEmpty())
{

	SiteProductsSharingBatchScheduler.scheduleBatch();
}






