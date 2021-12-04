public with sharing class CasesService
{
    private static final String APHERESISIDSSET = 'apheresisIdsSet';
    private static final String APHCRYOMAP = 'aphCryoMap';
    private static final String CAREGAP = 'CareGap';
    private static final String CAREPLAN = 'CarePlan';
    private static final String CASEOBJECT = 'Case';
    private static final String CRYOMAP = 'cryoMap';
    private static final String CASESTATUSEW = 'New';
    private static final String CASEPRIORITYHIGH ='High';
    private static final String COORDINATORSET = 'coordinatorsSet';
    private static final String MANUFACTURINGSITEMAP = 'manufacturingSiteMap';
    private static final String ORDERCANCELLATIONRECTYPEDEVNAME = 'OrderCancellationCase';
    private static final String ORDERCANCELLATIONQUEUENAME = 'OrderCancellationsQueue';
        public static final String INTERNAL_OPERATIONS_COORDINATOR = 'Cell Therapy Order Specialist (CTOS)';
    private static final String PATIENTROLE = 'Patient';
    private static final String TCP = 'TCP';
    private static final String TRTAPHMAP = 'trtAphMap';
    static final String SPACE = ' ';

    private static CasesSelector casesSelector
    {
        get
        {
            if (null == casesSelector)
            {
                casesSelector = (CasesSelector) Application.Selector.newInstance(Case.SObjectType);
            }
            return casesSelector;
        }
        set;
    }

    public void updateSitesReference(List<Case> casesList)
    {
        Set<Id> setOfContactIds = ((Cases) Application.Domain.newInstance(casesList,Case.sObjectType)).getContactIds();
        Map<String, Object> accTypeToAccIdsMap = new Map<String, Object>();

        if (!setOfContactIds.isEmpty())
        {
            accTypeToAccIdsMap = getListOfCoordinators(setOfContactIds, accTypeToAccIdsMap);
        }

        if ((accTypeToAccIdsMap.containsKey(COORDINATORSET)) && (!((Set<Id>) accTypeToAccIdsMap.get(COORDINATORSET)).isEmpty()))
        {
            accTypeToAccIdsMap = getTreatmentSiteContacts((Set<Id>) accTypeToAccIdsMap.get(COORDINATORSET), accTypeToAccIdsMap);
        }
        updateCaseWithRelatedSites(casesList, accTypeToAccIdsMap);
    }

    private Map<String, Object> getListOfCoordinators(Set<Id> contactIds, Map<String, Object> mapOfPatCoordinator)
    {
        List<HealthCloudGA__ContactContactRelation__c> listOfContactContactRelations = new List<HealthCloudGA__ContactContactRelation__c>();
        Set<Id> setOfCoordinatorContactIds = new Set<Id>();
        Map<String, String> mapOfPatientIdWithCoordinatorId = new Map<String, String>();
        listOfContactContactRelations = queryconContactRelRecords(contactIds);
        for (HealthCloudGA__ContactContactRelation__c astContact : listOfContactContactRelations)
        {
            if (astContact.HealthCloudGA__Role__r.Name == Label.RoleCoordinator && astContact.HealthCloudGA__Contact__c <> null)
            {
                setOfCoordinatorContactIds.add(astContact.HealthCloudGA__Contact__c);
                mapOfPatientIdWithCoordinatorId.put(astContact.HealthCloudGA__RelatedContact__c, astContact.HealthCloudGA__Contact__c);
            }
        }
        mapOfPatCoordinator.put(COORDINATORSET, (Object) setOfCoordinatorContactIds);
        mapOfPatCoordinator.put('patientMap', (Object) mapOfPatientIdWithCoordinatorId);
        return mapOfPatCoordinator;
    }

    private Map<String, Object> getTreatmentSiteContacts(Set<Id> setOfCoordinatorContactIds, Map<String, Object> accAccountRelTrtSiteMap)
    {
        Map<Id, Id> mapOfCoordinatorIdWithTrementSiteID = new Map<Id, Id>();
        List<Contact> listOfCoodinators = new List<Contact>();
        Set<Id> setOfTreatmentSiteIds = new Set<Id>();
        Id treatmentSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(Label.TreatmentSiteRecordType).getRecordTypeId();
        listOfCoodinators = queryContactRecords(setOfCoordinatorContactIds);
        for (Contact coodintor : listOfCoodinators)
        {
            if (coodintor.Account.RecordTypeId == treatmentSiteRecordTypeId)
            {
                setOfTreatmentSiteIds.add(coodintor.AccountId);
                mapOfCoordinatorIdWithTrementSiteID.put(coodintor.Id, coodintor.AccountId);
            }
        }
        accAccountRelTrtSiteMap.put('treatmentSiteSet', (Object) setOfTreatmentSiteIds);
        accAccountRelTrtSiteMap.put('treatmentMap', (Object) mapOfCoordinatorIdWithTrementSiteID);

        return accAccountRelTrtSiteMap;
    }

    private Map<String, Object> getApheresisSiteContacts(Set<Id> treatmentSiteSet, Map<String, Object> apheresisSiteMap)
    {
        Set<Id> setOfAphSiteIds = new Set<Id>();
        Map<Id, Id> mapOfTreatmentSiteWithAphSite = new Map<Id, Id>();
        List<HealthCloudGA__AccountAccountRelation__c> listOfAphSitesRelation = new List<HealthCloudGA__AccountAccountRelation__c>();
        listOfAphSitesRelation = queryAccAccountRelRecords(treatmentSiteSet);
        for (HealthCloudGA__AccountAccountRelation__c AphSite : listOfAphSitesRelation)
        {
            if (AphSite.HealthCloudGA__Role__r.Name == Label.RoleAphresisSite && AphSite.HealthCloudGA__Account__c <> null)
            {
                setOfAphSiteIds.add(AphSite.HealthCloudGA__RelatedAccount__c);
                mapOfTreatmentSiteWithAphSite.put(AphSite.HealthCloudGA__Account__c, AphSite.HealthCloudGA__RelatedAccount__c);
            }
        }
        apheresisSiteMap.put(APHERESISIDSSET, (Object) setOfAphSiteIds);
        apheresisSiteMap.put(TRTAPHMAP, (Object) mapOfTreatmentSiteWithAphSite);

        return apheresisSiteMap;
    }

    private Map<String, Object> getCryoSiteContacts(Set<Id> setOfAphSiteIds, Map<String, Object> cryoSiteMap)
    {
        Map<Id, Id> mapOfAphSiteWithCryoSite = new Map<Id, Id>();
        List<HealthCloudGA__AccountAccountRelation__c> listCryoSitesRelation = new List<HealthCloudGA__AccountAccountRelation__c>();
        listCryoSitesRelation = queryAccAccountRelRecords(setOfAphSiteIds);
        for (HealthCloudGA__AccountAccountRelation__c CryoSiteRel : listCryoSitesRelation)
        {
            if (CryoSiteRel.HealthCloudGA__Role__r.Name == Label.RoleCryoSite && CryoSiteRel.HealthCloudGA__Account__c <> null)
            {
                mapOfAphSiteWithCryoSite.put(CryoSiteRel.HealthCloudGA__Account__c, CryoSiteRel.HealthCloudGA__RelatedAccount__c);
            }
        }
        cryoSiteMap.put(APHCRYOMAP, (Object) mapOfAphSiteWithCryoSite);

        return cryoSiteMap;
    }

    private void updateCaseWithRelatedSites(List<Case> casesList, Map<String, Object> masterMap)
    {
        Id aphSiteId;
        Id coordinatorContactId;
        Id treatmentSiteId;
        Map<String, String> mapOfPatientIdWithCoordinatorId = (Map<String, String>) masterMap.get('patientMap');
        Map<Id, Id> mapOfCoordinatorIdWithTrementSiteID = (Map<Id, Id>) masterMap.get('treatmentMap');
        for (Case carePlan : casesList)
        {
            if (mapOfPatientIdWithCoordinatorId.containsKey(carePlan.ContactId))
            {
                coordinatorContactId = mapOfPatientIdWithCoordinatorId.get(carePlan.ContactId);
                if (mapOfCoordinatorIdWithTrementSiteID.containsKey(coordinatorContactId))
                {
                    treatmentSiteId = mapOfCoordinatorIdWithTrementSiteID.get(coordinatorContactId);
                    carePlan.TreatmentSite__c = treatmentSiteId;
                }
            }
        }
    }

    public void fetchNotificationAlertDetails(List<Case> caseChangedRecords, List<Case> caseExistingRecords, Set<Schema.SObjectField> sObjectFieldSet)
    {
        List<String> fieldschema = new List<String>();
        for (Schema.SObjectField sfield : sObjectFieldSet)
        {
            fieldschema.add('' + sfield);
        }
        NotificationEngineSelector notificationEngineSelector = (NotificationEngineSelector) Application.Selector.newInstance(NotificationEngine__mdt.SObjectType);
        List<NotificationEngine__mdt> notificationEngineList = new List<NotificationEngine__mdt>();
        if (fieldschema[0].contains('Status'))
        {
            notificationEngineList = notificationEngineSelector.selectNotificationAlert(CASEOBJECT, fieldschema, caseExistingRecords[0].Status, caseChangedRecords[0].Status);
        }
        if (notificationEngineList.isEmpty()) return ;

        OrdersSelector ordersSelectorInstance = (OrdersSelector) Application.Selector.newInstance(Order__c.SObjectType);
        List<Order__c> orderRecords = ordersSelectorInstance.selectOrdersByCarePlanId(new Set<Id> {caseChangedRecords[0].Id});
        if (orderRecords.isEmpty()) return ;

        UsersSelector usersSelectorInstance = (UsersSelector) Application.Selector.newInstance(User.SObjectType);
        List<User> cartCoordinatorList = usersSelectorInstance.selectByContactId(new Set<Id> {orderRecords[0].Coordinator__c});
        if (cartCoordinatorList.isEmpty()) return ;

        AccountsSelector accountsSelectorInstance = (AccountsSelector) Application.Selector.newInstance(Account.SObjectType);
        List<Account> patientsList = (List<Account>) accountsSelectorInstance.selectById(new Set<Id> {caseChangedRecords[0].AccountId}).getRecords();

        createNotificationAlert(patientsList, notificationEngineList, cartCoordinatorList, orderRecords);
    }

    public void createNotificationAlert(List<Account> patientsList, List<NotificationEngine__mdt> notificationEngineList, List<User> cartCoordinatorList, List<Order__c> orderRecords)
    {
        NotificationsService notificationsServiceInstance = (NotificationsService) Application.Service.newInstance(NotificationsService.class);
        notificationsServiceInstance.createNotificationRecords(patientsList, notificationEngineList, cartCoordinatorList, orderRecords);
    }

    public void addCareTeamMember(List<Case> carePlanList)
    {
        Set<Id> setOfPatientContactIds = ((Cases) Application.Domain.newInstance(carePlanList,Case.sObjectType)).getContactIds();

        Map<Id, List<HealthCloudGA__ContactContactRelation__c>> MapOfPatientIdWithListOfContactId = getConContactRel(setOfPatientContactIds);
        Map<String, Id> MapOfCaseTeamRoleWithId = getCaseTeamRoles();
        List<CaseTeamMember> ListOfCaseTeamMemberToCreate = getCaseTeamMemberList(carePlanList, MapOfPatientIdWithListOfContactId, MapOfCaseTeamRoleWithId);

        Set<Id> careplanIds = sflib_ArrayUtils.pluckIdField(carePlanList, Case.Id);
        List<CaseTeamMember> internalOperationsCoordinatorList = getTeamMembersFromTreatmentSite(careplanIds, MapOfCaseTeamRoleWithId);
        ListOfCaseTeamMemberToCreate.addAll(internalOperationsCoordinatorList);

        if (!ListOfCaseTeamMemberToCreate.isEmpty())
        {
                fflib_ISObjectUnitOfWork caseTeamMemberUnitOfWork = Application.UnitOfWork.newInstance();
                caseTeamMemberUnitOfWork.registerNew(ListOfCaseTeamMemberToCreate);
                caseTeamMemberUnitOfWork.commitWork();
        }
    }

    private List<CaseTeamMember> getTeamMembersFromTreatmentSite(Set<Id> carePlanIds, Map<String, Id> MapOfCaseTeamRoleWithId)
    {
        List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
                                    .selectByCarePlanId(carePlanIds);

        List<CaseTeamMember> careTeamMemberList = new List<CaseTeamMember>();
        CaseTeamMember careTeamMember;

        List<Case> carePlansWithTreatmentSiteList = (List<Case>) new sflib_SObjects(carePlanList)
                                                    .filter(
                                                        new sflib_Criteria()
                                                        .notEqualTo(Case.TreatmentSite__c, null)
                                                    ).getSObjects();

        for(Case carePlan : carePlansWithTreatmentSiteList)
        {
            if(carePlan.TreatmentSite__r.CellTherapyOrderSpecialist__c != null)
            {
                careTeamMember = new CaseTeamMember();
                careTeamMember.MemberId = carePlan.TreatmentSite__r.CellTherapyOrderSpecialist__c;
                careTeamMember.ParentId = carePlan.Id;
                careTeamMember.TeamRoleId = MapOfCaseTeamRoleWithId.get(INTERNAL_OPERATIONS_COORDINATOR);
                careTeamMemberList.add(careTeamMember);
            }
        }
        return careTeamMemberList;
    }

    private List<Case> elevatedGetCaseDetailsByIds(Set<Id> carePlanIds)
    {
        List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
                .elevatedSelectByCarePlanId(carePlanIds);
        return carePlanList;
    }

    private Map<Id, List<HealthCloudGA__ContactContactRelation__c>> getConContactRel(Set<Id> SetOfPatientContactIds)
    {
        List<HealthCloudGA__ContactContactRelation__c> TempListOfAssociatedContactIds = new List<HealthCloudGA__ContactContactRelation__c>();
        List<HealthCloudGA__ContactContactRelation__c> ListOfAssociatedContacts = new List<HealthCloudGA__ContactContactRelation__c>();
        ListOfAssociatedContacts = queryconContactRelRecords(SetOfPatientContactIds);
        Map<Id, List<HealthCloudGA__ContactContactRelation__c>> conMap = new Map<Id, List<HealthCloudGA__ContactContactRelation__c>>();
        for (HealthCloudGA__ContactContactRelation__c astContact : ListOfAssociatedContacts)
        {
            TempListOfAssociatedContactIds = new List<HealthCloudGA__ContactContactRelation__c>();
            if (astContact.HealthCloudGA__Contact__c <> null)
            {
                if (conMap.containsKey(astContact.HealthCloudGA__RelatedContact__c))
                {
                    TempListOfAssociatedContactIds = conMap.get(astContact.HealthCloudGA__RelatedContact__c);
                }
                TempListOfAssociatedContactIds.add(astContact);
                conMap.put(astContact.HealthCloudGA__RelatedContact__c, TempListOfAssociatedContactIds);
            }
        }
        return conMap;
    }

    private Map<String, Id> getCaseTeamRoles()
    {
        Map<String, Id> caseTeamMap = new Map<String, Id>();
        List<CaseTeamRole> ListOfCaseTeamRoles = new List<CaseTeamRole>();
        ListOfCaseTeamRoles = ((CaseTeamRoleSelector) Application.Selector.newInstance(CaseTeamRole.SObjectType)).selectAll();
        for (CaseTeamRole CareTeamRole : ListOfCaseTeamRoles)
        {
            caseTeamMap.put(CareTeamRole.Name, CareTeamRole.Id);
        }
        return caseTeamMap;
    }

    private List<CaseTeamMember> getCaseTeamMemberList(List<Case> caseList, Map<Id, List<HealthCloudGA__ContactContactRelation__c>> MapOfPatientIdWithListOfContactId, Map<String, Id> MapOfCaseTeamRoleWithId)
    {
        List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
        List<HealthCloudGA__ContactContactRelation__c> ListOfRelContactsToSetAsCareTeam = new List<HealthCloudGA__ContactContactRelation__c>();
        for (Case carePlanCase : caseList)
        {
            ListOfRelContactsToSetAsCareTeam = new List<HealthCloudGA__ContactContactRelation__c>();
            if (MapOfPatientIdWithListOfContactId.containsKey(carePlanCase.ContactId))
            {
                ListOfRelContactsToSetAsCareTeam = MapOfPatientIdWithListOfContactId.get(carePlanCase.ContactId);
            }
            for (HealthCloudGA__ContactContactRelation__c relContact : ListOfRelContactsToSetAsCareTeam)
            {
                if (MapOfCaseTeamRoleWithId.containsKey(relContact.HealthCloudGA__Role__r.Name))
                {
                    CaseTeamMember CareTeamMember = new CaseTeamMember();
                    CareTeamMember.MemberId = relContact.HealthCloudGA__Contact__c;
                    CareTeamMember.ParentId = carePlanCase.Id;
                    CareTeamMember.TeamRoleId = MapOfCaseTeamRoleWithId.get(relContact.HealthCloudGA__Role__r.Name);
                    caseTeamList.add(CareTeamMember);
                }
            }
        }
        return caseTeamList;
    }

    public Map<Id, Case> elevatedGetCarePlanByPatientId(Set<Id> accountIds)
    {
        return new Cases(((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
                .elevatedSelectByAccountId(accountIds))
                .getCasesByAccountId();
    }

    private List<HealthCloudGA__AccountAccountRelation__c> queryAccAccountRelRecords(Set<Id> accountIds)
    {
        return ((AccountAccountRelationSelector) Application.Selector.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType)).selectPrimarySitesByAccountIds(accountIds);
    }

    private List<HealthCloudGA__AccountAccountRelation__c> elevatedQueryAccAccountRelRecords(Set<Id> accountIds)
    {
        return ((AccountAccountRelationSelector) Application.Selector.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType)).elevatedSelectPrimarySitesByAccountIds(accountIds);
    }

    private List<HealthCloudGA__ContactContactRelation__c> queryconContactRelRecords(Set<Id> contactIds)
    {
        return ((ContactContactRelationSelector) Application.Selector.newInstance(HealthCloudGA__ContactContactRelation__c.SObjectType)).selectAssociatedContactsByContactId(contactIds);
    }

    private List<Contact> queryContactRecords(Set<Id> setOfCoordinatorContactIds)
    {
        return ((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType)).selectByIdWithAccountsRecordType(setOfCoordinatorContactIds);
    }

    public Map<Id,Case> getCarePlanByPatientId(Set<Id> accountIds)
    {
        return ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId(accountIds).getCasesByAccountId();
    }

    public static Map<Id, Case> fetchCarePlanByPatientId(Set<Id> accountIds)
    {
        return ((CasesSelector) Application.Selector.newInstance(Case.SObjectType)).selectByPatientAccountId(accountIds).getCasesByAccountId();
    }

    public void insertOrderForCareplanCase(List<Case> caseList)
    {
        Set<Id> accountIdsSet = ((Cases) Application.Domain.newInstance(caseList,Case.sObjectType)).getTreatmentSiteIds();
        Set<Id> apheresisSiteIdsSet = new Set<Id>();
        Set<Id> caseIdSet = (new Map<Id,Case>(caseList)).keySet();
        Set<Id> treatmentSiteIdsSet = ((Cases) Application.Domain.newInstance(caseList,Case.sObjectType)).getTreatmentSiteIds();
        Map<String, Object> accTypeToAccIdsMap = new Map<String, Object>();
        Map<Id, Id> mapOfAphSiteWithCryoSite = new Map<Id, Id>();

        if (!treatmentSiteIdsSet.isEmpty())
        {
            accTypeToAccIdsMap = getApheresisSiteContacts(treatmentSiteIdsSet, accTypeToAccIdsMap);
            if (accTypeToAccIdsMap.containsKey(APHERESISIDSSET))
            {
                accountIdsSet.addAll((Set<Id>) accTypeToAccIdsMap.get(APHERESISIDSSET));
                apheresisSiteIdsSet.addAll((Set<Id>) accTypeToAccIdsMap.get(APHERESISIDSSET));
            }
        }
        if ((accTypeToAccIdsMap.containsKey(APHERESISIDSSET)) && (!((Set<Id>) accTypeToAccIdsMap.get(APHERESISIDSSET)).isEmpty()))
        {
            accTypeToAccIdsMap = getCryoSiteContacts((Set<Id>) accTypeToAccIdsMap.get(APHERESISIDSSET), accTypeToAccIdsMap);
            if(accTypeToAccIdsMap.containsKey(APHCRYOMAP))
            {
                 mapOfAphSiteWithCryoSite = (Map<Id, Id>) accTypeToAccIdsMap.get(APHCRYOMAP);
                 accountIdsSet.addAll(mapOfAphSiteWithCryoSite.values());
            }
        }
        accTypeToAccIdsMap = getManufacturingSiteDetails(treatmentSiteIdsSet, accTypeToAccIdsMap);
        if ((accTypeToAccIdsMap.containsKey(MANUFACTURINGSITEMAP)) &&
                ((Map<String, String>) accTypeToAccIdsMap.get(MANUFACTURINGSITEMAP) != NULL))
        {
            List<String> manList = ((Map<String, String>) accTypeToAccIdsMap.get(MANUFACTURINGSITEMAP)).values();
            accountIdsSet.addAll((List<Id>) manList);
        }
        accTypeToAccIdsMap = getCaseTeamMembersMap(caseIdSet, accTypeToAccIdsMap);
        accTypeToAccIdsMap = getAddressDetailsForSites(accountIdsSet, accTypeToAccIdsMap);
        accTypeToAccIdsMap = getCryoTypeForSites(apheresisSiteIdsSet, accTypeToAccIdsMap);
        insertOrderForCareplanCase(caseList, accTypeToAccIdsMap);
    }

    private Map<String, Object> getCaseTeamMembersMap(Set<Id> caseSet, Map<String, Object> masterMap)
    {
        List<CaseTeamMember> caseTeamMemberList = new List<CaseTeamMember>();
        Map<String, String> caseTeamMemberMap = new Map<String, String>();
        if (!caseSet.isEmpty())
        {
            caseTeamMemberList = ((CaseTeamMembersSelector) Application.Selector.newInstance(CaseTeamMember.SObjectType)).getCaseTeamMembersList(caseSet);
            caseTeamMemberMap = ((CaseTeamMembers) Application.Domain.newInstance(caseTeamMemberList,CaseTeamMember.sObjectType)).getCaseTeamMemberInfo(caseTeamMemberList);
        }
        masterMap.put('caseTeamMap', (Object) caseTeamMemberMap);
        return masterMap;
    }

    private Map<String, Object> getAddressDetailsForSites(Set<Id> accountIds, Map<String, Object> masterMap)
    {
        List<Schema.AssociatedLocation> associatedLocationList = new List<Schema.AssociatedLocation>();
        Map<String, String> addressMap = new Map<String, String>();
        String siteStr = '';
        if (!accountIds.isEmpty())
        {
            associatedLocationList = ((AssociatedLocationsSelector) Application.Selector.newInstance(Schema.AssociatedLocation.SObjectType)).getAddressesForSites(accountIds);
            for (Schema.AssociatedLocation asl : associatedLocationList)
            {
                siteStr = asl.ParentRecordId + ',' + asl.Type;
                if (!addressMap.containsKey(siteStr))
                {
                    addressMap.put(siteStr, asl.Address__c);
                }
            }
        }
        masterMap.put('associatedLocationMap', (Object) addressMap);
        return masterMap;
    }

    private Map<String, Object> getCryoTypeForSites(Set<Id> apheresisSiteIds, Map<String, Object> masterMap)
    {
        List<Account> accountList = new List<Account>();
        Map<String, String> cryoTypeMap = new Map<String, String>();
        if (!apheresisSiteIds.isEmpty())
        {
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.APHERESISSITE).getRecordTypeId();
            accountList = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).getCryoTypeForSites(apheresisSiteIds, recTypeId);
            for (Account acc : accountList)
            {
                cryoTypeMap.put(acc.Id, acc.Type);
            }
        }
        masterMap.put(CRYOMAP, (Object) cryoTypeMap);
        return masterMap;
    }

    private Map<String, Object> getManufacturingSiteDetails(Set<Id> treatmentIds, Map<String, Object> masterMap)
    {
        List<HealthCloudGA__AccountAccountRelation__c> accAccountRelList = new List<HealthCloudGA__AccountAccountRelation__c>();
        Map<String, String> manuSiteMap = new Map<String, String>();
        if (!treatmentIds.isEmpty())
        {
            Id manSiteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.manufacturingSiteRecTypeDeveloperName).getRecordTypeId();
            accAccountRelList = queryAccAccountRelRecords(treatmentIds);
            for (HealthCloudGA__AccountAccountRelation__c rel : accAccountRelList)
            {
                if ((manSiteRecTypeId.equals(rel.HealthCloudGA__RelatedAccount__r.RecordTypeId)) && !(manuSiteMap.containsKey(rel.HealthCloudGA__Account__c)))
                {
                    manuSiteMap.put(rel.HealthCloudGA__Account__c, rel.HealthCloudGA__RelatedAccount__c);
                }
            }
        }
        masterMap.put(MANUFACTURINGSITEMAP, (Object) manuSiteMap);
        return masterMap;
    }

    private void insertOrderForCareplanCase(List<Case> caseList, Map<String, Object> objMap)
    {
        List<Order__c> orderList = new List<Order__c>();
        Map<Id, Id> mapOfTreatmentSiteWithAphSite = (Map<Id, Id>) objMap.get(TRTAPHMAP);
        Map<Id, Id> mapOfAphSiteWithCryoSite = (Map<Id, Id>) objMap.get(APHCRYOMAP);
        String manStr = '';
        String aphSiteId, cryoSiteId, cryoType;
        for (Case cs : caseList)
        {
            manStr = ((Map<String, String>) objMap.get(MANUFACTURINGSITEMAP)).get(cs.TreatmentSite__c);
            if (!String.isBlank(cs.TreatmentSite__c) && mapOfTreatmentSiteWithAphSite.containsKey(cs.TreatmentSite__c))
            {
                aphSiteId = mapOfTreatmentSiteWithAphSite.get(cs.TreatmentSite__c);
                cryoType = ((Map<String, String>) objMap.get(CRYOMAP)).get(aphSiteId);
                if (mapOfAphSiteWithCryoSite.containsKey(aphSiteId) && cryoType == StaticConstants.cryoSiteLocal)
                {
                    cryoSiteId = mapOfAphSiteWithCryoSite.get(aphSiteId);
                }
            }
            orderList.add(new Order__c(
                ApheresisSite__c = aphSiteId,
                ApheresisSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(aphSiteId + ',' + Label.PickupCryoType),
                CarePlanID__c = cs.Id,
                CryoType__c = cryoType,
                CryoSite__c = cryoSiteId,
                CryoSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cryoSiteId + ',' + Label.PickupCryoType),
                CryoSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cryoSiteId + ',' + Label.DropOffCryoType),
                Coordinator__c = ((Map<String, String>) objMap.get('caseTeamMap')).get(cs.Id + Label.RoleCoordinator),
                Patient__c = cs.AccountId,
                Physician__c = ((Map<String, String>) objMap.get('caseTeamMap')).get(cs.Id + Label.RolePhysician),
                TreatmentSite__c = cs.TreatmentSite__c,
                TreatmentSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cs.TreatmentSite__c + ',' + Label.DropOffCryoType),
                ManufacturingSite__c = manStr,
                ManufacturingSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(manStr + ',' + Label.PickupCryoType),
                ManufacturingSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(manStr + ',' + Label.DropOffCryoType)));
        }
        if (!orderList.isEmpty())
        {
            insertOrderForCareplanCase(orderList);
        }
    }

    public static void insertOrderForCareplanCase(List<Order__c> orderList)
    {
        fflib_ISObjectUnitOfWork orderUnitOfWork = Application.UnitOfWork.newInstance();
        orderUnitOfWork.registerNew(orderList);
        orderUnitOfWork.commitWork();
    }

    public static void updateCarePlan(Map<Id, Boolean> isPatientServiceOptedByAccount)
    {
        Map<Id, Case> casesByAccountId =
                ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
                        .selectByPatientAccountId(isPatientServiceOptedByAccount.keySet()).getCasesByAccountId();
        if (casesByAccountId.isEmpty()) return;
        for (Case objCase : casesByAccountId.values())
        {
            if (isPatientServiceOptedByAccount.containsKey(objCase.AccountId))
            {
                objCase.BeginPatientSupportEligibilityCheck__c = isPatientServiceOptedByAccount.get(objCase.AccountId);
            }
        }
        try
        {
            fflib_ISObjectUnitOfWork casesUnitOfWork = Application.UnitOfWork.newInstance();
            casesUnitOfWork.registerDirty(casesByAccountId.values());
            casesUnitOfWork.commitWork();
        }
        catch (Exception e)
        {
            Application.logEntry.error(e);
        }
    }

    public void setSubjectFromProductAndAccount(List<Case> caseList)
    {
        Set<Id> accountIds = sflib_ArrayUtils.pluckIdField(caseList,Case.AccountId);
        if (!accountIds.isEmpty())
        {
            Map<Id,Account> accountMap = new Map<Id,Account>(((AccountsSelector) Application.Selector.newInstance
                    (Account.SObjectType))
                    .selectByAccountIds(accountIds));

            Map<Id,CareProgramEnrollee> enrolleeMap = new Map<Id,CareProgramEnrollee>(((CareProgramEnrolleesSelector) Application.Selector.newInstance
                    (CareProgramEnrollee.SObjectType))
                    .elevatedSelectByAccountId(accountIds));

            List<CareProgramEnrolleeProduct> careProgramEnrolleeProductList = ((CareProgramEnrolleeProductsSelector) Application.Selector.newInstance
                    (CareProgramEnrolleeProduct.SObjectType))
                    .elevatedSelectByCPEnrolleeId(enrolleeMap.keySet());

            Set<Id> careProgramProductIds = sflib_ArrayUtils.pluckIdField(careProgramEnrolleeProductList,CareProgramEnrolleeProduct.CareProgramProductId);
            Map<Id,CareProgramProduct> careProgramProductsByIds = new Map<Id,CareProgramProduct>(((CareProgramProductsSelector) Application.Selector.newInstance
                    (CareProgramProduct.SObjectType))
                    .elevatedSelectById(careProgramProductIds));

            Map<Id, String> productNameMap = new Map<Id, String>();
            for (CareProgramEnrolleeProduct record : careProgramEnrolleeProductList)
            {
                if (isEnrolleeAndCareProgramProductIsNotEmpty(enrolleeMap, record, careProgramProductsByIds))
                {
                    Id careProgramProductId = record.CareProgramProductId;
                    Id careProgramEnrolleeId = record.CareProgramEnrolleeId;
                    productNameMap.put(
                            enrolleeMap.get(careProgramEnrolleeId).AccountId,
                            careProgramProductsByIds.get(careProgramProductId).Product.Name
                    );
                }
            }

            for (Case casObj : caseList)
            {
                if(productNameMap.containsKey(casObj.AccountId) && accountMap.containsKey(casObj.AccountId))
                {
                    casObj.Subject = productNameMap.get(casObj.AccountId) + SPACE + label.CareplanSubject + SPACE + accountMap.get(casObj.AccountId).Name;
                }
            }
        }
    }

    private Boolean isEnrolleeAndCareProgramProductIsNotEmpty(Map<Id, CareProgramEnrollee> enrolleeMap, CareProgramEnrolleeProduct cpepObj, Map<Id, CareProgramProduct> careProgramProductsByIds)
    {
        Boolean isNotEmpty = false;
        if (cpepObj.CareProgramEnrolleeId != null && cpepObj.CareProgramProductId != null
                && enrolleeMap.containsKey(cpepObj.CareProgramEnrolleeId)
                && careProgramProductsByIds.containsKey(cpepObj.CareProgramProductId)
                && careProgramProductsByIds.get(cpepObj.CareProgramProductId).ProductId != null)
        {
            isNotEmpty = true;
        }
        return isNotEmpty;
    }

    public List<Case> createCareGapCases(Map<Account, HealthCloudGA__CarePlanTemplate__c> carePlanTemplateByPatient, Map<Account, User> cartCoordinatorByPatient, Map<Account, Boolean> isPatientServiceOptedByAccount){
        List<Case> carePlans = new List<Case>();
        Id careGapRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CAREGAP).getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList.addAll(carePlanTemplateByPatient.keySet());
        Set<Id> accountIdsSet = sflib_ArrayUtils.pluckIdField(accountList, Account.Id);
        Map<Id, Id> contactIdByPatientId = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).selectById(accountIdsSet).getPersonContactIdById();
        for (Account patient : carePlanTemplateByPatient.keySet())
        {
            Case objCarePlan = new Case();
            objCarePlan.Origin = TCP;
            objCarePlan.AccountId = patient.Id;
            if (contactIdByPatientId.containsKey(patient.Id))
            {
                objCarePlan.ContactId = contactIdByPatientId.get(patient.Id);
            }
            if (isPatientServiceOptedByAccount.containsKey(patient))
            {
                objCarePlan.BeginPatientSupportEligibilityCheck__c = isPatientServiceOptedByAccount.get(patient);
            }
            if (cartCoordinatorByPatient.containsKey(patient))
            {
                objCarePlan.OwnerId = cartCoordinatorByPatient.get(patient).CreatedById;
            }
            objCarePlan.RecordTypeId = careGapRecordTypeId;
            carePlans.add(objCarePlan);
        }
        setSubjectFromProductAndAccount(carePlans);
        return carePlans;
    }

    public void createPatientServiceEnrolleesForCarePlans(Cases cases)
    {
        List<Case> carePlans = cases.getRecords();
        if (carePlans.isEmpty()) return;
        elevatedCreatePatientServiceEnrolleesForCarePlans(carePlans);
    }

    public void elevatedCreatePatientServiceEnrolleesForCarePlans(List<Case> carePlans)
    {
        PatientServicesEnrolleesService pseService = (PatientServicesEnrolleesService)
                Application.Service.newInstance(PatientServicesEnrolleesService.Class);
        List<PatientServicesEnrollee__c> patientServiceEnrollesToCreate = pseService.getPatientServiceEnrolleeRecordsForCarePlans(carePlans);
        if (patientServiceEnrollesToCreate.isEmpty()) return ;
        try
        {
            fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
            new ElevatedContextDML().elevatedCreatePSES(patientServiceEnrollesToCreate, elevatedUnitOfWork);
            elevatedUnitOfWork.commitWork();
        }
        catch (Exception exceptnWhileCreatingPSES)
        {
            Application.logEntry.error(exceptnWhileCreatingPSES);
        }

    }

    public void elevatedAddCareTeamMember(List<Case> carePlanList)
    {
        Set<Id> setOfPatientContactIds = ((Cases) Application.Domain.newInstance(carePlanList, Case.sObjectType)).getContactIds();
        Map<Id, List<HealthCloudGA__ContactContactRelation__c>> MapOfPatientIdWithListOfContactId = getConContactRel(setOfPatientContactIds);
        Map<String, Id> MapOfCaseTeamRoleWithId = getCaseTeamRoles();
        List<HealthCloudGA__ContactContactRelation__c> ListOfRelContactsToSetAsCareTeam = elevatedGetCaseTeamMemberList(carePlanList, MapOfPatientIdWithListOfContactId);
        Set<Id> careplanIds = sflib_ArrayUtils.pluckIdField(carePlanList, Case.Id);
        List<Case> caseDetails = elevatedGetCaseDetailsByIds(careplanIds);

        fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        new ElevatedContextDML().elevatedCreateCareTeamMember(caseDetails, MapOfCaseTeamRoleWithId, ListOfRelContactsToSetAsCareTeam, elevatedUnitOfWork);
        Cases carePlanCases = (Cases) Application.Domain.newInstance(caseDetails);
        addCaseContactToCaseTeam(elevatedUnitOfWork, carePlanCases, MapOfCaseTeamRoleWithId);
        elevatedUnitOfWork.commitWork();
    }

    private void addCaseContactToCaseTeam(fflib_ISObjectUnitOfWork unitOfWork, Cases cases, Map<String, Id> MapOfCaseTeamRoleWithId)
    {
        Cases casesWithContacts = cases.selectWithContactId();
        if (casesWithContacts.isEmpty()) return;
        ((CaseTeamMembersService) Application.Service.newInstance(CaseTeamMembersService.class))
                .elevatedAddCaseTeamMember(unitOfWork,
                casesWithContacts.getContactIdById(),
                MapOfCaseTeamRoleWithId.get(PATIENTROLE)
        );
    }

    public void elevatedInsertOrderForCareplanCase(List<Case> caseList)
    {
        Set<Id> accountIdsSet = ((Cases) Application.Domain.newInstance(caseList, Case.sObjectType)).getTreatmentSiteIds();
        Set<Id> apheresisSiteIdsSet = new Set<Id>();
        Set<Id> caseIdSet = (new Map<Id, Case>(caseList)).keySet();
        Set<Id> treatmentSiteIdsSet = ((Cases) Application.Domain.newInstance(caseList, Case.sObjectType)).getTreatmentSiteIds();
        Map<String, Object> masterMap = new Map<String, Object>();
        Map<Id, Id> mapOfAphSiteWithCryoSite = new Map<Id, Id>();

        if (!treatmentSiteIdsSet.isEmpty())
        {
            masterMap = elevatedGetApheresisSiteContacts(treatmentSiteIdsSet, masterMap);
            accountIdsSet.addAll((Set<Id>) masterMap.get(APHERESISIDSSET));
            apheresisSiteIdsSet.addAll((Set<Id>) masterMap.get(APHERESISIDSSET));
        }
        if (!((Set<Id>) masterMap.get(APHERESISIDSSET)).isEmpty())
        {
            masterMap = elevatedGetCryoSiteContacts((Set<Id>) masterMap.get(APHERESISIDSSET), masterMap);
            mapOfAphSiteWithCryoSite = (Map<Id, Id>) masterMap.get(APHCRYOMAP);

            accountIdsSet.addAll(mapOfAphSiteWithCryoSite.values());
        }
        masterMap = elevatedGetManufacturingSiteDetails(treatmentSiteIdsSet, masterMap);
        if ((Map<String, String>) masterMap.get(MANUFACTURINGSITEMAP) != NULL)
        {
            List<String> manList = ((Map<String, String>) masterMap.get(MANUFACTURINGSITEMAP)).values();
            accountIdsSet.addAll((List<Id>) manList);
        }
        masterMap = getCaseTeamMembersMap(caseIdSet, masterMap);
        masterMap = elevatedGetAddressDetailsForSites(accountIdsSet, masterMap);
        masterMap = elevatedGetCryoTypeForSites(apheresisSiteIdsSet, masterMap);
        elevatedCreateOrderForCase(caseList, masterMap);
    }

    private Map<String, Object> elevatedGetApheresisSiteContacts(Set<Id> treatmentSiteSet, Map<String, Object> apheresisSiteMap)
    {
        Set<Id> setOfAphSiteIds = new Set<Id>();
        Map<Id, Id> mapOfTreatmentSiteWithAphSite = new Map<Id, Id>();
        List<HealthCloudGA__AccountAccountRelation__c> listOfAphSitesRelation = new List<HealthCloudGA__AccountAccountRelation__c>();
        listOfAphSitesRelation = elevatedQueryAccAccountRelRecords(treatmentSiteSet);
        for (HealthCloudGA__AccountAccountRelation__c AphSite : listOfAphSitesRelation)
        {
            if (AphSite.HealthCloudGA__Role__r.Name == Label.RoleAphresisSite && AphSite.HealthCloudGA__Account__c <> null)
            {
                setOfAphSiteIds.add(AphSite.HealthCloudGA__RelatedAccount__c);
                mapOfTreatmentSiteWithAphSite.put(AphSite.HealthCloudGA__Account__c, AphSite.HealthCloudGA__RelatedAccount__c);
            }
        }
        apheresisSiteMap.put(APHERESISIDSSET, (Object) setOfAphSiteIds);
        apheresisSiteMap.put(TRTAPHMAP, (Object) mapOfTreatmentSiteWithAphSite);

        return apheresisSiteMap;
    }

    private Map<String, Object> elevatedGetCryoSiteContacts(Set<Id> setOfAphSiteIds, Map<String, Object> cryoSiteMap)
    {
        Map<Id, Id> mapOfAphSiteWithCryoSite = new Map<Id, Id>();
        List<HealthCloudGA__AccountAccountRelation__c> listCryoSitesRelation = new List<HealthCloudGA__AccountAccountRelation__c>();
        listCryoSitesRelation = elevatedQueryAccAccountRelRecords(setOfAphSiteIds);
        for (HealthCloudGA__AccountAccountRelation__c CryoSiteRel : listCryoSitesRelation)
        {
            if (CryoSiteRel.HealthCloudGA__Role__r.Name == Label.RoleCryoSite && CryoSiteRel.HealthCloudGA__Account__c <> null)
            {
                mapOfAphSiteWithCryoSite.put(CryoSiteRel.HealthCloudGA__Account__c, CryoSiteRel.HealthCloudGA__RelatedAccount__c);
            }
        }
        cryoSiteMap.put(APHCRYOMAP, (Object) mapOfAphSiteWithCryoSite);

        return cryoSiteMap;
    }

    private Map<String, Object> elevatedGetManufacturingSiteDetails(Set<Id> treatmentIds, Map<String, Object> masterMap)
    {
        List<HealthCloudGA__AccountAccountRelation__c> accAccountRelList = new List<HealthCloudGA__AccountAccountRelation__c>();
        Map<String, String> manuSiteMap = new Map<String, String>();
        if (!treatmentIds.isEmpty())
        {
            Id manSiteRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.manufacturingSiteRecTypeDeveloperName).getRecordTypeId();
            accAccountRelList = elevatedQueryAccAccountRelRecords(treatmentIds);
            for (HealthCloudGA__AccountAccountRelation__c rel : accAccountRelList)
            {
                if ((manSiteRecTypeId.equals(rel.HealthCloudGA__RelatedAccount__r.RecordTypeId)) && !(manuSiteMap.containsKey(rel.HealthCloudGA__Account__c)))
                {
                    manuSiteMap.put(rel.HealthCloudGA__Account__c, rel.HealthCloudGA__RelatedAccount__c);
                }
            }
        }
        masterMap.put(MANUFACTURINGSITEMAP, (Object) manuSiteMap);
        return masterMap;
    }

    private Map<String, Object> elevatedGetAddressDetailsForSites(Set<Id> accountIds, Map<String, Object> masterMap)
    {
        List<Schema.AssociatedLocation> associatedLocationList = new List<Schema.AssociatedLocation>();
        Map<String, String> addressMap = new Map<String, String>();
        String siteStr = '';
        if (!accountIds.isEmpty())
        {
            associatedLocationList = ((AssociatedLocationsSelector) Application.Selector.newInstance(Schema.AssociatedLocation.SObjectType)).elevatedGetAddressesForSites(accountIds);
            for (Schema.AssociatedLocation asl : associatedLocationList)
            {
                siteStr = asl.ParentRecordId + ',' + asl.Type;
                if (!addressMap.containsKey(siteStr))
                {
                    addressMap.put(siteStr, asl.Address__c);
                }
            }
        }
        masterMap.put('associatedLocationMap', (Object) addressMap);
        return masterMap;
    }

    private Map<String, Object> elevatedGetCryoTypeForSites(Set<Id> apheresisSiteIds, Map<String, Object> masterMap)
    {
        List<Account> accountList = new List<Account>();
        Map<String, String> cryoTypeMap = new Map<String, String>();
        if (!apheresisSiteIds.isEmpty())
        {
            Id recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.APHERESISSITE).getRecordTypeId();
            accountList = ((AccountsSelector) Application.Selector.newInstance(Account.SObjectType)).elevatedGetCryoTypeForSites(apheresisSiteIds, recTypeId);
            for (Account acc : accountList)
            {
                cryoTypeMap.put(acc.Id, acc.Type);
            }
        }
        masterMap.put(CRYOMAP, (Object) cryoTypeMap);
        return masterMap;
    }

    private void elevatedCreateOrderForCase(List<Case> caseList, Map<String, Object> objMap)
    {
        List<Order__c> orderList = new List<Order__c>();
        Map<Id, Id> mapOfTreatmentSiteWithAphSite = (Map<Id, Id>) objMap.get(TRTAPHMAP);
        Map<Id, Id> mapOfAphSiteWithCryoSite = (Map<Id, Id>) objMap.get(APHCRYOMAP);
        String manStr = '';
        String aphSiteId, cryoSiteId, cryoType;
        for (Case cs : caseList)
        {
            manStr = ((Map<String, String>) objMap.get(MANUFACTURINGSITEMAP)).get(cs.TreatmentSite__c);
            if (!String.isBlank(cs.TreatmentSite__c) && mapOfTreatmentSiteWithAphSite.containsKey(cs.TreatmentSite__c))
            {
                aphSiteId = mapOfTreatmentSiteWithAphSite.get(cs.TreatmentSite__c);
                cryoType = ((Map<String, String>) objMap.get(CRYOMAP)).get(aphSiteId);
                if (mapOfAphSiteWithCryoSite.containsKey(aphSiteId) && cryoType == StaticConstants.cryoSiteLocal)
                {
                    cryoSiteId = mapOfAphSiteWithCryoSite.get(aphSiteId);
                }
            }
            orderList.add(new Order__c(
                    ApheresisSite__c = aphSiteId,
                    ApheresisSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(aphSiteId + ',' + Label.PickupCryoType),
                    CarePlanID__c = cs.Id,
                    CryoType__c = cryoType,
                    CryoSite__c = cryoSiteId,
                    CryoSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cryoSiteId + ',' + Label.PickupCryoType),
                    CryoSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cryoSiteId + ',' + Label.DropOffCryoType),
                    Coordinator__c = ((Map<String, String>) objMap.get('caseTeamMap')).get(cs.Id + Label.RoleCoordinator),
                    Patient__c = cs.AccountId,
                    Physician__c = ((Map<String, String>) objMap.get('caseTeamMap')).get(cs.Id + Label.RolePhysician),
                    TreatmentSite__c = cs.TreatmentSite__c,
                    TreatmentSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(cs.TreatmentSite__c + ',' + Label.DropOffCryoType),
                    ManufacturingSite__c = manStr,
                    ManufacturingSitePickupAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(manStr + ',' + Label.PickupCryoType),
                    ManufacturingSiteDropOffAddress__c = ((Map<String, String>) objMap.get('associatedLocationMap')).get(manStr + ',' + Label.DropOffCryoType)));
        }
        if (!orderList.isEmpty())
        {
            fflib_ISObjectUnitOfWork elevatedOrderUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
            new ElevatedContextDML().elevatedCreateOrderForCase(orderList, elevatedOrderUnitOfWork);
            elevatedOrderUnitOfWork.commitWork();
        }
    }

    private List<HealthCloudGA__ContactContactRelation__c> elevatedGetCaseTeamMemberList(List<Case> caseList, Map<Id, List<HealthCloudGA__ContactContactRelation__c>> MapOfPatientIdWithListOfContactId)
    {
        List<HealthCloudGA__ContactContactRelation__c> ListOfRelContactsToSetAsCareTeam = new List<HealthCloudGA__ContactContactRelation__c>();
        for (Case carePlanCase : caseList)
        {
            ListOfRelContactsToSetAsCareTeam = new List<HealthCloudGA__ContactContactRelation__c>();
            if (MapOfPatientIdWithListOfContactId.containsKey(carePlanCase.ContactId))
            {
                ListOfRelContactsToSetAsCareTeam = MapOfPatientIdWithListOfContactId.get(carePlanCase.ContactId);
            }
        }
        return ListOfRelContactsToSetAsCareTeam;
    }

    public List<Case> elevatedCreateCarePlan(Map<Account, HealthCloudGA__CarePlanTemplate__c> carePlanTemplateByPatient, Map<Account, User> cartCoordinatorByPatient, Map<Account, Boolean> isPatientServiceOptedByAccount)
    {
        fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        List<Case> careGapCases = createCareGapCases(carePlanTemplateByPatient,cartCoordinatorByPatient,isPatientServiceOptedByAccount);
        List<Case> casesList = new ElevatedContextDML().elevatedCreateCarePlan(careGapCases , elevatedUnitOfWork);
        elevatedUnitOfWork.commitWork();
        elevatedUpdateRecordTypeToCarePlan(casesList);
        return casesList;
    }

    private void elevatedUpdateRecordTypeToCarePlan(List<Case> cases)
    {
        fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        new ElevatedContextDML().elevatedUpdateRecordTypeToCarePlan(cases, elevatedUnitOfWork);
        elevatedUnitOfWork.commitWork();
    }

    private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
    {
        public void dmlInsert(List<SObject> objList)
        {
            if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
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

        public List<Case> elevatedCreateCarePlan(List<Case> cases,fflib_ISObjectUnitOfWork unitOfWork)
        {
            unitOfWork.registerNew(cases);
            return cases;
        }

        public void elevatedUpdateRecordTypeToCarePlan(List<Case> cases, fflib_ISObjectUnitOfWork unitOfWork)
        {
            List<Case> carePlans = new List<Case>();
            Id carePlanRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(CAREPLAN).getRecordTypeId();
            for (Case objCase : cases)
            {
                objCase.RecordTypeId = carePlanRecordTypeId;
                carePlans.add(objCase);
            }
            unitOfWork.registerDirty(carePlans);
        }

        public void elevatedCreateCareTeamMember(List<Case> carePlans, Map<String, Id> MapOfCaseTeamRoleWithId, List<HealthCloudGA__ContactContactRelation__c> ListOfRelContactsToSetAsCareTeam, fflib_ISObjectUnitOfWork unitOfWork)
        {
            List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
            for (Case carePlanCase : carePlans)
            {
                if(carePlanCase.TreatmentSite__c != null && carePlanCase.TreatmentSite__r.CellTherapyOrderSpecialist__c != null)
                {
                    CaseTeamMember careTeamMember = new CaseTeamMember();
                    careTeamMember.MemberId = carePlanCase.TreatmentSite__r.CellTherapyOrderSpecialist__c;
                    careTeamMember.ParentId = carePlanCase.Id;
                    careTeamMember.TeamRoleId = MapOfCaseTeamRoleWithId.get(INTERNAL_OPERATIONS_COORDINATOR);
                    caseTeamList.add(careTeamMember);
                }
                for (HealthCloudGA__ContactContactRelation__c relContact : ListOfRelContactsToSetAsCareTeam)
                {
                    if (MapOfCaseTeamRoleWithId.containsKey(relContact.HealthCloudGA__Role__r.Name))
                    {
                        CaseTeamMember CareTeamMember = new CaseTeamMember();
                        CareTeamMember.MemberId = relContact.HealthCloudGA__Contact__c;
                        CareTeamMember.ParentId = carePlanCase.Id;
                        CareTeamMember.TeamRoleId = MapOfCaseTeamRoleWithId.get(relContact.HealthCloudGA__Role__r.Name);
                        caseTeamList.add(CareTeamMember);
                    }
                }
            }

            unitOfWork.registerNew(caseTeamList);
        }

        public void elevatedCreatePSES(List<PatientServicesEnrollee__c> patientServiceEnrollesToCreate,fflib_ISObjectUnitOfWork unitOfWork)
        {
            unitOfWork.registerNew(patientServiceEnrollesToCreate);
        }

        public void elevatedCreateOrderForCase(List<Order__c> orderList, fflib_ISObjectUnitOfWork unitOfWork)
        {
            unitOfWork.registerNew(orderList);
        }


    }

    public void updateSubjectForCareplanCase(Cases casDomain)
    {
        Set<Id> accountIds = casDomain.getAccountIds();

        if (!accountIds.isEmpty())
        {
            List<Account> accountsList = new List<Account>();
            AccountsSelector accSelector = (AccountsSelector) Application.Selector.newInstance
                    (Account.SObjectType);
            accountsList = accSelector.selectByAccountIds(accountIds);
            Map<String, String> accountNameMap = new Map<String, String>();
            accountNameMap = new sflib_SObjects(accountsList).
                    asStringFieldByStringField(Account.Id, Account.Name);

            List<CareProgramEnrollee> careProgramEnrolleeList = new List<CareProgramEnrollee>();
            CareProgramEnrolleesSelector enrolleeSelector = (CareProgramEnrolleesSelector) Application.Selector.newInstance
                    (CareProgramEnrollee.SObjectType);
            careProgramEnrolleeList = enrolleeSelector.selectByAccountId(accountIds);
            Set<Id> careProgramEnrolleeIds = new Set<Id>();
            careProgramEnrolleeIds = sflib_ArrayUtils.pluckIdField(careProgramEnrolleeList, CareProgramEnrollee.Id);

            List<CareProgramEnrolleeProduct> careProgramEnrolleeProductList = new List<CareProgramEnrolleeProduct>();
            CareProgramEnrolleeProductsSelector enrolleeProductSelector = (CareProgramEnrolleeProductsSelector) Application.Selector.newInstance
                    (CareProgramEnrolleeProduct.SObjectType);
            careProgramEnrolleeProductList = enrolleeProductSelector.selectByCPEId(careProgramEnrolleeIds);
            CareProgramEnrolleeProductsService enrolleeProductService = new CareProgramEnrolleeProductsService();
            Map<Id, String> productNameMap = new Map<Id, String>();
            productNameMap = enrolleeProductService.getProductNameMap(careProgramEnrolleeProductList);

            casDomain.updateSubject(accountNameMap, productNameMap);
        }
    }

    public Map<Id, List<SObject>> getPatientIdAndActiveCarePlan(Set<Id> patientIds, Set<Id> recordTypeIds)
    {
        return new sflib_SObjects(casesSelector.selectCasesByPatientIds(patientIds, recordTypeIds))
                                                .asSObjectsByIdField(Case.AccountId);
    }

    public void getCasesForCancellationRequestedOrders(List<Order__c> orders,fflib_ISObjectUnitOfWork uow)
    {
        List<Case> casesToCreate = new List<Case>();
        Id orderCancellationCaseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(ORDERCANCELLATIONRECTYPEDEVNAME)
                .getRecordTypeId();
        Id orderCancellationQueueId = getOrderCancellationQueueId();

        Case caseObj;
        for (Order__c order : Orders)
        {
            caseObj = new Case(OrderID__c = order.Id,TreatmentSite__c = order.TreatmentSite__c,ParentId = order.CarePlanID__c);

            if (order.ReasonForOrderWithdrawal__c != null)
            {
                caseObj.ReasonForCancellation__c = order.ReasonForOrderWithdrawal__c;
            }

            casesToCreate.add(caseObj);
        }

        Cases cases = (Cases) Application.Domain.newInstance(casesToCreate);
        Cases.setRecordType(orderCancellationCaseRecTypeId);
        Cases.setOwner(orderCancellationQueueId);
        Cases.setStatus(CASESTATUSEW);
        Cases.setPriority(CASEPRIORITYHIGH);
        uow.registerNew(cases.getRecords());
    }

    public void updateCaseRelatedOrderCancellationInfo(List<Case> casesWithClosedOrderToBeCancelledStatus)
    {
        try
        {
            fflib_ISObjectUnitOfWork uow = Application.getUnitOfWork();
            setCaseRelatedOrderCancellationInfo(uow, casesWithClosedOrderToBeCancelledStatus);
            uow.commitWork();
        }
        catch (Exception excp)
        {
            Application.logEntry.error(excp);
        }
    }

    public void setCaseRelatedOrderCancellationInfo(fflib_ISObjectUnitOfWork uow, List<Case> casesWithClosedOrderToBeCancelledStatus)
    {
        ((OrdersService) Application.Service.newInstance(OrdersService.class)).getCaseRelatedOrderCancellationInfo(
                                             casesWithClosedOrderToBeCancelledStatus,uow);
    }

    Id getOrderCancellationQueueId()
    {
        List<Group> orderCancellationQueue = ((GroupsSelector) Application.Selector.newInstance(Group.SObjectType))
                                                               .selectQueuesByDeveloperName(new Set<String> {ORDERCANCELLATIONQUEUENAME});
        return !orderCancellationQueue.isEmpty() ? orderCancellationQueue[0].Id : null;
    }

    public void updateReasonForCancellation(List<Case> caseList, Map<Id,String> cancellationReasonByOrderId)
    {
        Cases cases = (Cases) Application.Domain.newInstance(caseList);
        updateReasonForCancellation(cases.setReasonForCancellation(cancellationReasonByOrderId));
    }

    private void updateReasonForCancellation(Cases cases)
    {
        fflib_ISObjectUnitOfWork uof = Application.UnitOfWork.newInstance();
        uof.registerDirty(cases.getRecords());
        uof.commitWork();
    }

    public void grantAccessToPublicGroups(Cases cases)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
        grantAccessToRelatedPublicGroups(uow, cases.getRecords());
        uow.commitWork();
    }

    public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<Case> caseList)
    {
        Map<Id, Id> caseObjectIdByAccountIdToCloneMap = new Map<Id, Id>();

        for(Case objCase : caseList)
        {
            caseObjectIdByAccountIdToCloneMap.put(objCase.Id, objCase.AccountId);
        }

        if(! caseObjectIdByAccountIdToCloneMap.isEmpty())
        {
            new RecordsSharingService().cloneSharingSettings(uow, caseObjectIdByAccountIdToCloneMap, AccountShare.SObjectType);
        }
    }
}
