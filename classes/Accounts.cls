public class Accounts extends fflib_SObjectDomain {

    public static final String TREATMENTSITERECORDTYPEDEVELOPERNAME = 'TreatmentSite';

    private AccountsService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (AccountsService) Application.Service.newInstance(AccountsService.class);
            }
            return Service;
        }
        set;
    }

    private ContactsService ContactsService
    {
        get
        {
            if (null == ContactsService)
            {
                ContactsService = (ContactsService) Application.Service.newInstance(ContactsService.class);
            }
            return ContactsService;
        }
        set;
    }

    public Accounts(List<Account> records)
    {
        super(records);
    }

    public Map<Id, Account> getById()
    {
        return new Map<Id, Account>((List<Account>) records);
    }

    public Map<String, Account> getByAccountIdentifier()
    {
        Map<String, Account> mapAccountsByIdentifier = new Map<String, Account>();
        for(Account objAccount : (List<Account>)records){
            mapAccountsByIdentifier.put(objAccount.AccountIdentifier__c, objAccount);
        }
        return mapAccountsByIdentifier;
    }

    public Map<Id, Id> getPersonContactIdById()
    {
        return new sflib_SObjects(records).asIdFieldByIdField(Account.Id, Account.PersonContactId);
    }

    public Set<Id> getPersonContactIds()
    {
        return sflib_ArrayUtils.pluckIdField(records, Account.PersonContactId);
    }

    public List<Account> getByRecordTypeDeveloperName(Set<String> recordTypeDeveloperNames)
    {
        List<Account> filteredAccounts = new List<Account>();
        Map<String, Id> recordTypeByDevName = sflib_RecordTypesSelector.selectByDeveloperNames(Account.SObjectType, recordTypeDeveloperNames);
        for (Account objAccount : (List<Account>) records)
        {
            for (Id recordTypeId : recordTypeByDevName.values())
            {
                if (objAccount.RecordTypeId == recordTypeId)
                {
                    filteredAccounts.add(objAccount);
                    break;
                }
            }
        }
        return filteredAccounts;
    }

    public override void onBeforeInsert()
    {
        getPatientAccountsWithPopulatedBirthDate();
    }

    public override void onBeforeUpdate(Map<Id,sObject> existingRecords)
    {
        getPatientAccountsWithPopulatedBirthDate();
    }

    public override void onAfterInsert()
    {
        createPublicGroupsForTreatmentSites();
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        updateSiteStatusForTreatmentSites((Map<Id, Account>)existingRecords);
    }

    public void getPatientAccountsWithPopulatedBirthDate()
    {
        List<Account> updatedPatientAccountsList = new List<Account>();

        Id PatientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.PatientRecordtype).getRecordTypeId();
        for(Account acc : (List<Account>) records) {
            if(acc.RecordTypeId == PatientRecordTypeId && acc.PersonBirthdate <> null) {
                updatedPatientAccountsList.add(acc);
            }
        }
        if(updatedPatientAccountsList != null) {
            Service.updatePatientBirthDateReference(updatedPatientAccountsList);
        }
    }

    public void createPublicGroupsForTreatmentSites()
    {
        List<Account> treatmentSites = getByRecordTypeDeveloperName(new Set<String> {TREATMENTSITERECORDTYPEDEVELOPERNAME});
        if (treatmentSites.isEmpty()) return;
        Service.createPublicGroupsForAccounts(treatmentSites);
    }

    public void updateSiteStatusForTreatmentSites(Map<Id,Account> existingRecords)
    {
        List<Account> treatmentSites = getByRecordTypeDeveloperName(new Set<String> {TREATMENTSITERECORDTYPEDEVELOPERNAME});
        List<Account> deactivatedAccounts = getDeactivatedTreatmentSites(treatmentSites, (Map<Id,Account>) existingRecords);
        ContactsService.deactivateContactsAndUsers(deactivatedAccounts);
    }

    public List<Account> getDeactivatedTreatmentSites(List<Account> treatmentSites, Map<Id,Account> existingTreatmentSites)
    {
        List<Account> deactivatedTreatmentSites = new List<Account>();
        for(Account acc : treatmentSites){
            Account existingAccount = existingTreatmentSites.get(acc.Id);

            if(acc.status__c == Label.InactiveStatusTreatmentSites && existingAccount.Status__c != acc.Status__c)
            {
                deactivatedTreatmentSites.add(acc);
            }
        }

        return deactivatedTreatmentSites;
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new Accounts(sObjectList);
        }
    }

}
