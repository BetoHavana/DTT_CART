public with sharing class AccountsService {

    public static final String HEALTHSYSTEMRECDEVNAME = 'HealthSystem';
    public static final String TREATMENTSITE = 'Treatment Site';
    public static final String TREATMENTSITERECORDTYPEDEVELOPERNAME = 'TreatmentSite';
    static final Set<String> CAREGIVERRECIPROCALROLES = new Set<String>
    {
            'Daughter or Son','Professional Caregiver',
            'Other Family Member','Spouse/Partner',
            'Sibling','Parent','Legal Guardian'
    };
    private static AccountsSelector accountsSelector
    {
        get
        {
            if (null == accountsSelector )
            {
                accountsSelector = (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
            }
            return accountsSelector;
        }
        set;
    }



    public Map<Id, Account> getPatients()
    {
        return ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                .selectPatients()
                .getById();
    }

    public void updatePatientBirthDateReference(List<Account> accountsList) {
        for(Account acc : accountsList) {
            acc.PatientBirthDateReference__c = String.valueOf(acc.PersonBirthdate);
        }
    }

    public static Map<String, Account> getTreatmentSitesByGroupNameForAccountIds(Set<Id> accountIds)
    {
        Map<String, Account> mapTreatmentSiteByGroupName = new Map<String, Account>();
        Map<String, Account> mapTreatmentSitesByAccountIdentifier = (Map<String, Account>)new Accounts(((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
                .selectById(accountIds)
                .getByRecordTypeDeveloperName(new Set<String> {TREATMENTSITERECORDTYPEDEVELOPERNAME}))
                .getByAccountIdentifier();
        for (String accountIdentifier : mapTreatmentSitesByAccountIdentifier.keySet())
        {
            String groupName = TREATMENTSITE + ' - ' + accountIdentifier;
            mapTreatmentSiteByGroupName.put(groupName, mapTreatmentSitesByAccountIdentifier.get(accountIdentifier));
        }
        return mapTreatmentSiteByGroupName;
    }

    public void createPublicGroupsForAccounts(List<Account> accounts)
    {
        fflib_ISObjectUnitOfWork elevatedGroupUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        Groups.createPublicGroupsForAccounts(accounts, elevatedGroupUnitOfWork);
        elevatedGroupUnitOfWork.commitWork();
    }

    public Map<Id, Contact> getCareGiverInformationPerPatient(Set<Id> patientContactIds)
    {
        Map<Id, Contact> patientNRelatedCaregiverInfo = new Map<Id, Contact>();
        List<HealthCloudGA__ContactContactRelation__c> contactContatRelationshipRecs =
                ((ContactContactRelationSelector) Application.Selector.newInstance
                        (HealthCloudGA__ContactContactRelation__c.SObjectType)).
                        selectAssociatedContactsByContactIdAndRoles(patientContactIds,CAREGIVERRECIPROCALROLES);
        for (HealthCloudGA__ContactContactRelation__c contactContactRelation : contactContatRelationshipRecs)
        {
            patientNRelatedCaregiverInfo.put(contactContactRelation.Account__c, contactContactRelation.HealthCloudGA__Contact__r);
        }
        return patientNRelatedCaregiverInfo;
    }

    public Map<Id,Id> getTreatmentSiteHealthSystemInfo(Set<Id> treatmentSiteIds)
    {
        Map<Id,Id> treatmentSiteIdAndRelatedHSIds = new Map<Id,Id>();
        if(treatmentSiteIds == null || treatmentSiteIds.isEmpty())
        {
            return  treatmentSiteIdAndRelatedHSIds;
        }

        Id healthSystemRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(HEALTHSYSTEMRECDEVNAME).getRecordTypeId();
        for(Account treatmentSite :accountsSelector.elevatedSelectById(treatmentSiteIds) )
        {
            if(healthSystemRecTypeId == treatmentSite.Parent?.RecordTypeId)
            {
                treatmentSiteIdAndRelatedHSIds.put(treatmentSite.Id, treatmentSite.ParentId);
            }
        }

        return treatmentSiteIdAndRelatedHSIds;
    }

    private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
    {
        public void dmlInsert(List<SObject> objList)
        {
            insert objList;
        }
        public void dmlUpdate(List<SObject> objList)
        {
            update objList;
        }
        public void dmlDelete(List<SObject> objList)
        {
            delete objList;
        }
        public void eventPublish(List<SObject> objList)
        {
            //not implemented
        }

        public void emptyRecycleBin(List<SObject> objList)
        {
            if (objList.isEmpty())
            {
                return;
            }
            Database.emptyRecycleBin(objList);
        }

    }

}