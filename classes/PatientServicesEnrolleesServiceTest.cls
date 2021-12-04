@isTest(seeAlldata=false)
public with sharing class PatientServicesEnrolleesServiceTest 
{
    public static final String BILLING_STREET = 'Street 2';
    public static final String BILLING_CITY = 'City 2';
    public static final String BILLING_POSTAL_CODE = '76112';
    public static final String BILLING_COUNTRY = 'Mexico';
    public static final String CARE_PROGRAM = 'Test Care Program';
    public static final String LOCATION = 'Raritan Manufacturing Pickup';
    public static final String NEW_PATIENT_SERVICES_REQUEST = 'New Patient Services Request';
    public static final String REQUEST_TO_ENROLL_CONFIRMED = 'Request to Enroll Confirmed';
    public static final String PATIENT_ENROLLMENT_FORM_RECEIVED = 'Patient Enrollment Form Received';
    public static final String MISSING_INFORMATION_IN_FORM = 'Missing Information in Form';
    public static final String PROCESSING_ELIGIBILITY = 'Processing Eligibility';
    public static final String ELIGIBLE = 'Eligible';
    public static final String NOT_ELIGIBLE = 'Not-eligible';
    public static final String INELIGIBLE = 'Ineligible';
    public static final String SERVICES = 'Meals Services';
    public static final String NO = 'No';
    public static final String NUMBERS = '12';

    @testSetup static void testDataSetup()
    {
        List<Account> accToBeInserted = new List<Account>();
        Account trtSite = TestDataFactory.getBusinessAccountToInsert(StaticConstants.TreatmentSiteRecordTypeDeveloperName);
        accToBeInserted.add(trtSite);
        
        Account patient = TestDataFactory.getPatientAccountsToInsert(1);
        patient.BillingStreet = BILLING_STREET;
        patient.BillingCity = BILLING_CITY;
        patient.BillingPostalCode = BILLING_POSTAL_CODE;
        patient.BillingCountry = BILLING_COUNTRY;
        accToBeInserted.add(patient);
        insert accToBeInserted;
        
        List<Schema.Location> locationList = TestDataFactory.getLocationRecords(LOCATION,1);
        insert locationList;
        
        List<Id> siteIds = new List<Id>();
        siteIds.add(trtSite.Id);
        List<Schema.AssociatedLocation> associatedLocationRecords = TestDataFactory.getAssociatedLocationRecordsBasedOnSiteName(siteIds,locationList,1);
        insert associatedLocationRecords;
        
        Contact trtSiteContact = TestDataFactory.getSitePersonnelContact(StaticConstants.TREATMENTSITELABEL, trtSite.Id);
        Insert trtSiteContact;

        List<CareProgram> careProgramsList = TestDataFactory.getCareProgramsList(CARE_PROGRAM, 1);
		insert careProgramsList;
        
        CareProgramEnrollee patientEnrolled = TestDataFactory.getCareProgramEnrollee(careProgramsList[0].Id, patient.Id);
        insert patientEnrolled;
        
        Case carePlan = TestDataFactory.getCasestoInsert(trtSiteContact.Id,patient.Id);
        insert carePlan;
        
        PatientServicesEnrollee__c pseList = TestDataFactory.getPatientServicesEnrollee(carePlan.Id,patient.Id);
        insert pseList;
        
        HealthCloudGA__ReciprocalRole__c carTRole = TestDataFactory.getContactRole(StaticConstants.CARTCOORDINATOR, StaticConstants.contactRole);
        insert carTRole;
        
        HealthCloudGA__ContactContactRelation__c contactRel = new HealthCloudGA__ContactContactRelation__c();
        contactRel.Account__c = patient.Id;
        contactRel.HealthCloudGA__Contact__c = trtSiteContact.Id;
        contactRel.HealthCloudGA__Contact__r = trtSiteContact;
        contactRel.HealthCloudGA__Contact__r.SitePersona__c = StaticConstants.CARTCOORDINATOR;
		contactRel.HealthCloudGA__RelatedContact__r = trtSiteContact;
		contactRel.HealthCloudGA__Role__c = carTRole.Id;
        insert contactRel;
    }

    @isTest static void itShouldUpdatePSEAsEligible()
    {  
        //GIVEN - A Patient Services Enrollee record
        List<PatientServicesEnrollee__c> pseRecords = ((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SobjectType)).selectAll();
        PatientServicesEnrollee__c currentPSE = new PatientServicesEnrollee__c();
        for (PatientServicesEnrollee__c objPSE: pseRecords)
        {
            if (objPSE.PatientServicesStatus__c.equalsIgnoreCase(NEW_PATIENT_SERVICES_REQUEST))
            {
                currentPSE = objPSE;
                break;
            }
        }

        Test.startTest();
        //WHEN - Update Patient information in Patient Enrollee Services
        currentPSE.PatientServicesStatus__c = REQUEST_TO_ENROLL_CONFIRMED;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = PATIENT_ENROLLMENT_FORM_RECEIVED;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = MISSING_INFORMATION_IN_FORM;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = PROCESSING_ELIGIBILITY;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = ELIGIBLE;
        currentPSE.DistanceMileage__c = NUMBERS;
        currentPSE.DistanceTime__c = NUMBERS;
        currentPSE.NonEmergencyMedicalTravel__c = NO;
        currentPSE.LodgingSupport__c = NO;
        currentPSE.DateEligibilityCheckPerformed__c = System.today()+1;
        currentPSE.MileageEligibility__c = ELIGIBLE;
        currentPSE.TimeEligibility__c = ELIGIBLE;
        currentPSE.InsuranceEligibility__c = ELIGIBLE;
        currentPSE.LodgingEligibility__c = ELIGIBLE;
        currentPSE.IncomeEligibility__c = ELIGIBLE;
        currentPSE.PatientServices__c = SERVICES;
        update currentPSE;
        
        //THEN - It should update the Patient Services Enrollee as Eligible
        System.assertEquals(currentPSE.PatientServicesStatus__c,ELIGIBLE);
        Test.stopTest(); 
    }
    
    @isTest static void itShouldUpdatePSEAsIneligible()
    {  
       //GIVEN - A Patient Services Enrollee record
        List<PatientServicesEnrollee__c> pseRecords = ((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SobjectType)).selectAll();
        PatientServicesEnrollee__c currentPSE = new PatientServicesEnrollee__c();
        for (PatientServicesEnrollee__c objPSE: pseRecords)
        {
            if (objPSE.PatientServicesStatus__c.equalsIgnoreCase(NEW_PATIENT_SERVICES_REQUEST))
            {
                currentPSE = objPSE;
                break;
            }
        }

        Test.startTest();
        //WHEN - Update Patient information in Patient Enrollee Services
        currentPSE.PatientServicesStatus__c = REQUEST_TO_ENROLL_CONFIRMED;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = PATIENT_ENROLLMENT_FORM_RECEIVED;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = MISSING_INFORMATION_IN_FORM;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = PROCESSING_ELIGIBILITY;
        update currentPSE;
        currentPSE.PatientServicesStatus__c = INELIGIBLE;
        currentPSE.DistanceMileage__c = NUMBERS;
        currentPSE.DistanceTime__c = NUMBERS;
        currentPSE.NonEmergencyMedicalTravel__c = NO;
        currentPSE.LodgingSupport__c = NO;
        currentPSE.DateEligibilityCheckPerformed__c = System.today()+1;
        currentPSE.MileageEligibility__c = NOT_ELIGIBLE;
        currentPSE.TimeEligibility__c = NOT_ELIGIBLE;
        currentPSE.InsuranceEligibility__c = NOT_ELIGIBLE;
        currentPSE.LodgingEligibility__c = NOT_ELIGIBLE;
        currentPSE.IncomeEligibility__c = NOT_ELIGIBLE;
        currentPSE.PatientServices__c = SERVICES;
        update currentPSE;
        
        //THEN - It should update the Patient Services Enrollee as Ineligible
        System.assertEquals(currentPSE.PatientServicesStatus__c,INELIGIBLE);
        Test.stopTest(); 
    }
}