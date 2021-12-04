public with sharing class ContactContactRelationsService
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';

	public static final String Physician = 'physician';

	private static AccountSharesService AccountSharesService
	{
		get
		{
			if (null == AccountSharesService)
			{
				AccountSharesService = (AccountSharesService) Application.Service.newInstance(AccountSharesService.class);
			}
			return AccountSharesService;
		}
		set;
	}

	private static GroupsService GroupsService
	{
		get
		{
			if (null == GroupsService)
			{
				GroupsService = (GroupsService) Application.Service.newInstance(GroupsService.class);
			}
			return GroupsService;
		}
		set;
	}

	private static ContactContactRelationSelector ContactContactRelationSelector
	{
		get
		{
			if (null == ContactContactRelationSelector)
			{
				ContactContactRelationSelector = (ContactContactRelationSelector) Application.Selector.newInstance(HealthCloudGA__ContactContactRelation__c.SObjectType);
			}
			return ContactContactRelationSelector;
		}
		set;
	}

	private static ContactsSelector ContactsSelector
	{
		get
		{
			if (null == ContactsSelector)
			{
				ContactsSelector = (ContactsSelector) Application.Selector.newInstance(Contact.SObjectType);
			}
			return ContactsSelector;
		}
		set;
	}

	public Map<Id, String> getRelatedContactIdsByRole(Set<Id> contactIds, String role)
	{
		List<HealthCloudGA__ContactContactRelation__c> contactRelationsByRole = getRelatedContactsByRole(contactIds, role);
		Map<Id, Id> relatedContactIdByContactId = getRelatedContactIdByContactId(contactRelationsByRole);

		Set<Id> relatedContactIds = new Set<Id>();
		relatedContactIds.addAll(relatedContactIdByContactId.values());

		Map<Id, String> contactNameById = getContactNameById(relatedContactIds);

		Map<Id, String> relatedContactNameByContactId = new Map<Id, String>();
		for (Id contactId : relatedContactIdByContactId.keySet())
		{
			relatedContactNameByContactId.put(contactId, contactNameById.get(relatedContactIdByContactId.get(contactId)));
		}
		return relatedContactNameByContactId;
	}

	private List<HealthCloudGA__ContactContactRelation__c> getRelatedContactsByRole(Set<Id> contactIds, String role)
	{
		List<HealthCloudGA__ContactContactRelation__c> relatedContacts = new List<HealthCloudGA__ContactContactRelation__c>();
		if(String.isBlank(role)) return relatedContacts;
		relatedContacts =  new ContactContactRelations((ContactContactRelationSelector)
				.elevatedSelectByContactId(contactIds))
				.getByRoles(new Set<String>
				{
						role
				});
		return relatedContacts;
	}

	private Map<Id, Id> getRelatedContactIdByContactId(List<HealthCloudGA__ContactContactRelation__c> contacts)
	{
		return new ContactContactRelations(contacts)
				.getRelatedContactIdByContactId();
	}

	private Map<Id, String> getContactNameById(Set<Id> contactIds)
	{
		return new Contacts((ContactsSelector)
				.elevatedSelectById(contactIds))
				.getNameById();
	}

	public List<HealthCloudGA__ContactContactRelation__c> getRecordsWithCARTRole(List<HealthCloudGA__ContactContactRelation__c> contactContactRelationsList)
	{
		List<HealthCloudGA__ContactContactRelation__c> filteredCartList = new List<HealthCloudGA__ContactContactRelation__c>();

		Set<Id> roleIds = new ContactContactRelations(contactContactRelationsList).getRoleIds();
		if (roleIds.isEmpty()) return filteredCartList;

		Map<Id, HealthCloudGA__ReciprocalRole__c> reciprocalRolesMap = new Map<Id, HealthCloudGA__ReciprocalRole__c>();

		List<HealthCloudGA__ReciprocalRole__c> reciprocalRoles =
				((ReciprocalRoleSelector) Application.Selector.newInstance
						(HealthCloudGA__ReciprocalRole__c.SObjectType)).selectByIds(roleIds);

		for (HealthCloudGA__ReciprocalRole__c objreciprocalRole : reciprocalRoles)
		{
			if (objreciprocalRole.Name == CARTCOORDINATOR)
			{
				reciprocalRolesMap.put(objreciprocalRole.Id, objreciprocalRole);
			}
		}
		if (reciprocalRolesMap.isEmpty()) return filteredCartList;

		for (HealthCloudGA__ContactContactRelation__c objConConRel : contactContactRelationsList)
		{
			if (reciprocalRolesMap.containsKey(objConConRel.HealthCloudGA__Role__c))
			{
				filteredCartList.add(objConConRel);
			}
		}
		return filteredCartList;
	}

	public void createShareRecordsForCARTRole(List<HealthCloudGA__ContactContactRelation__c> contactContactRelationsList)
	{
		List<HealthCloudGA__ContactContactRelation__c> filteredCartList = getRecordsWithCARTRole(contactContactRelationsList);
		if (filteredCartList.isEmpty()) return;
		createPatientShareForTreatmentSites(filteredCartList);
	}

	public void createPatientShareForTreatmentSites(List<HealthCloudGA__ContactContactRelation__c> filteredCartList)
	{
		Map<Id, Id> patientIdCoordinatorIdMap = new ContactContactRelations(filteredCartList).getContactIdsByRelatedContactIds();

		Set<Id> cartCoordinatorIds = new ContactContactRelations(filteredCartList).getContactIds();

		List<Contact> cartCoordinatorList =
				((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType)).
						selectByIdWithAccountsRecordType(cartCoordinatorIds);
		if (cartCoordinatorList.isEmpty()) return;

		List<Contact> patientContactList =
				((ContactsSelector) Application.Selector.newInstance(Contact.SObjectType)).
						selectByIdWithAccountsRecordType(patientIdCoordinatorIdMap.keyset());
		if (patientContactList.isEmpty()) return;

		Map<Id, Contact> cartCoordinatorMap = new Map<Id, Contact>(cartCoordinatorList);

		Set<Id> treatmentSiteIds = new Contacts(cartCoordinatorList).getAccountIds();

		Map<Id, Id> patientsMap = new Contacts(patientContactList).getAccountIdByContactId();

		Map<Id, Id> patientIdTreatmentSiteIdMap = new Map<Id, Id>();

		for (Id patientId : patientIdCoordinatorIdMap.keySet())
		{
			Id CartCoordinatorId = patientIdCoordinatorIdMap.get(patientId);
			if (cartCoordinatorMap.containsKey(CartCoordinatorId) && patientsMap.containsKey(patientId))
			{
				patientIdTreatmentSiteIdMap.put(patientsMap.get(patientId), cartCoordinatorMap.get(CartCoordinatorId).AccountId);
			}
		}
		Map<Id,Id> groupIdByTreatmentSiteId = GroupsService.fetchGroupIdsByTreatmentSiteIds(treatmentSiteIds);
		createAccountSharesForPublicGroups(patientIdTreatmentSiteIdMap,groupIdByTreatmentSiteId);
	}

	public void createAccountSharesForPublicGroups(Map<Id, Id> patientIdTreatmentSiteIdMap, Map<Id, Id> groupIdByTreatmentSiteId)
	{
		Map<Id, Id> groupIdByPatientId = new Map<Id, Id>();
		for (Id patientId : patientIdTreatmentSiteIdMap.keySet())
		{
			Id treatmentSiteId = patientIdTreatmentSiteIdMap.get(patientId);
			if (groupIdByTreatmentSiteId.containsKey(treatmentSiteId))
			{
				groupIdByPatientId.put(patientId, groupIdByTreatmentSiteId.get(treatmentSiteId));
			}
		}
		if (groupIdByPatientId.isEmpty()) return;
		AccountSharesService.createShareRecordForPublicGroup(groupIdByPatientId);
	}

	public void grantAccessToPublicGroups(ContactContactRelations ccRelations)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToRelatedPublicGroups(uow, ccRelations.getRecords());
		uow.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<HealthCloudGA__ContactContactRelation__c> ccrList)
	{
		Map<Id, Id> accountIdByAccountIdToCloneMap = new Map<Id, Id>();
		Map<Id, Id> contactIdByAccountIdToCloneMap = new Map<Id, Id>();
		Set<Id> contactIds = sflib_ArrayUtils.pluckIdField(ccrList, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Contact__c);
		contactIds.addAll(sflib_ArrayUtils.pluckIdField(ccrList, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c));

		Map<Id, Id> contactByPersonAccountId = ((ContactsService) Application.Service.newInstance(ContactsService.class))
														.getContactByPersonAccountId(contactIds);
		RecordsSharingService rss = new RecordsSharingService();
		Id patientId = null;
		for (HealthCloudGA__ContactContactRelation__c ccr : ccrList)
		{
			patientId = contactByPersonAccountId.get(ccr.HealthCloudGA__Contact__c);
			if (ccr.HealthCloudGA__InverseRelationship__c != null && ccr.HealthCloudGA__Active__c &&
					contactByPersonAccountId.containsKey(ccr.HealthCloudGA__Contact__c) && patientId != null)
			{
				accountIdByAccountIdToCloneMap.put(contactByPersonAccountId.get(ccr.HealthCloudGA__RelatedContact__c), patientId);
				contactIdByAccountIdToCloneMap.put(ccr.Id, patientId);
				contactIdByAccountIdToCloneMap.put(ccr.HealthCloudGA__InverseRelationship__c, patientId);
			}
		}

		if (!accountIdByAccountIdToCloneMap.isEmpty() && !contactIdByAccountIdToCloneMap.isEmpty())
		{
			rss.cloneSharingSettings(uow, accountIdByAccountIdToCloneMap, AccountShare.SObjectType);
			rss.cloneSharingSettings(uow, contactIdByAccountIdToCloneMap, AccountShare.SObjectType);
		}
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
		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}

			Database.emptyRecycleBin(objList);
		}
		public void eventPublish(List<SObject> objList)
		{
		}
	}
}
