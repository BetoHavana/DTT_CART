public with sharing class AccountContactRelationsService
{
	private static final String TREATMENTSITE = 'Treatment Site';

	public void createPatientSiteRelation(Id accountId,Id contactId, String treatmentSite)
	{
		fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
		createPatientSiteRelation(unitOfWork, accountId, contactId, treatmentSite);
		unitOfWork.commitWork();
	}

	public void createPatientSiteRelation(fflib_ISObjectUnitOfWork unitOfWork,Id accountId,Id contactId, String treatmentSite)
	{
		AccountContactRelation accountContactRelation = new AccountContactRelation ();
		accountContactRelation.AccountId = accountId;
		accountContactRelation.ContactId = contactId;
		accountContactRelation.Roles = treatmentSite;
		unitOfWork.registerNew(accountContactRelation);
	}

	public void grantAccessToRelatedPublicGroups(AccountContactRelations accountContactRelations)
	{
		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToRelatedPublicGroups(uow, accountContactRelations.getRecords());
		uow.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<AccountContactRelation> accountAccountRelationList)
	{
		if (accountAccountRelationList == null || accountAccountRelationList.isEmpty())
		{
			return ;
		}
		Set<Id> accountContactRelationsIds = sflib_ArrayUtils.pluckIdField(accountAccountRelationList, AccountContactRelation.Id);

		List<AccountContactRelation> filteredAccountContactRelationsRecords = ((AccountContactRelationsSelector) Application.Selector.newInstance(AccountContactRelation.SObjectType))
																					.selectByAccountContactRelationIds(accountContactRelationsIds);

		Map<Id, Id> sObjectIdByObjectIdToCloneMap = new Map<Id, Id>();

		for (AccountContactRelation acr : filteredAccountContactRelationsRecords)
		{
			sObjectIdByObjectIdToCloneMap.put(acr.Contact.AccountId, acr.AccountId);
		}

		if (!sObjectIdByObjectIdToCloneMap.isEmpty())
		{
			new RecordsSharingService().cloneSharingSettings(uow, sObjectIdByObjectIdToCloneMap, AccountShare.SObjectType);
		}
	}

	public Map<Id, String> getPatientMRNInfo(Set<Id> patientIds)
	{
		AccountContactRelationsSelector acrSelector = (AccountContactRelationsSelector) Application.Selector
				.newInstance(AccountContactRelation.SObjectType);
		Map<Id, String> patientAndMRNInfo = new Map<Id, String>();
		for (AccountContactRelation acr : acrSelector.selectByContactAccountId(patientIds))
		{
			if (String.isNotBlank(acr.Roles) && acr.Roles.split(';').contains(TREATMENTSITE))
			{
				patientAndMRNInfo.put(acr.Contact.AccountId, acr.MedicalRecordNumber__c);
			}
		}
		return patientAndMRNInfo;
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
