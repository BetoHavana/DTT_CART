@isTest(seeAllData=false)
public class AccountContactRelationsServiceTest
{
	public static final String SCRIPTTHROWNEXCEPTION = 'Script-thrown exception';
	public static final string strPatientRecordType = 'Patient';
	public static final string strSuccess = 'SUCCESS';
	public static final String TreatmentSiteRecordTypeDeveloperName = 'TreatmentSite';
	public static final String MEDICALRECORDNUMBER = '1012091';


	@testSetup
	static void setup()
	{
		List<Account> patientsToBeInserted = TestDataFactory.getPatientAccountsList();
		insert patientsToBeInserted;
	}

	@IsTest
	public static void itShouldCreatePatientSiteRelation()
	{
		try
		{
			//GIVEN -  A patient is enrolled in the system
			Map<Id, Account> patientByIds = new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
					.selectAll()
					.getByRecordTypeDeveloperName(new Set<String> {strPatientRecordType}))
					.getById();

			Map<Id, Contact> contactsByAccountIds =
					((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType))
							.selectByAccountId(patientByIds.keySet()).getContactsByAccountId();

			List<Account> treatmentSiteAccountsList =
					TestDataFactory.getBusinessAccountsList(TREATMENTSITERECORDTYPEDEVELOPERNAME, 10);
			insert treatmentSiteAccountsList;

			Test.startTest();
			//WHEN - TreatmentSite and patient are associated
			AccountContactRelationsService AccountContactRelationsServiceObj = new AccountContactRelationsService();
			AccountContactRelationsServiceObj.createPatientSiteRelation(treatmentSiteAccountsList[0].Id, contactsByAccountIds.values()[0].Id, TreatmentSiteRecordTypeDeveloperName);
			
			List<AccountContactRelation> accContactToUpdate =
					((AccountContactRelationsSelector) Application.Selector.newInstance(AccountContactRelation.SObjectType))
							.selectByContactIdRelatedToTreatmentSites(new Set<Id> {contactsByAccountIds.values()[0].Id});
            accContactToUpdate[0].MedicalRecordNumber__c = MEDICALRECORDNUMBER;
			update accContactToUpdate;
			Test.stopTest();
			
			//THEN - PatientSite Relation is being established
			List<AccountContactRelation> accContactUpdated =
					((AccountContactRelationsSelector) Application.Selector.newInstance(AccountContactRelation.SObjectType))
							.selectByContactIdRelatedToTreatmentSites(new Set<Id> {contactsByAccountIds.values()[0].Id});
            System.assertEquals(7, patientByIds.size(), strSuccess);
			System.assertEquals(accContactUpdated[0].MedicalRecordNumber__c, MEDICALRECORDNUMBER);
		}
		catch (AuraHandledException ex)
		{
			//THEN - check for Exception being thrown
			System.assertEquals(ex.getMessage(), SCRIPTTHROWNEXCEPTION, strSuccess);
		}
		
	}

}