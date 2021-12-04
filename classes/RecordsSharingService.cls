public with sharing class RecordsSharingService {
	private static final String ACCESSLEVEL = 'AccessLevel';
	private static final String ID = 'Id';
    private static final String MANUAL = 'Manual';
	private static final String NONE = 'None';
	private static final String OPPORTUNITYACCESSLEVEL = 'OpportunityAccessLevel';
	private static final String PARENTID = 'ParentId';
    private static final String ROWCAUSE = 'RowCause';
	private static final String SHARE = 'Share';
	private static final String USERORGROUPID = 'UserOrGroupId';
	private static final Map<SObjectType, SObjectType> SObjectAndShareObjectInfo = new Map<SObjectType, SObjectType>
	{
			Account.SObjectType => AccountShare.SObjectType,
			Case.SObjectType => CaseShare.SObjectType,
			CareProgramEnrolleeProduct.SObjectType => CareProgramEnrolleeProductShare.SObjectType,
			Order__c.SObjectType => Order__Share.SObjectType,
			PatientServicesEnrollee__c.SObjectType => PatientServicesEnrollee__Share.SObjectType,
			HealthCloudGA__AccountAccountRelation__c.SObjectType => HealthCloudGA__AccountAccountRelation__share.SObjectType,
            HealthCloudGA__CarePlanGoal__c.SObjectType => HealthCloudGA__CarePlanGoal__Share.SObjectType,
			HealthCloudGA__ContactContactRelation__c.SObjectType => HealthCloudGA__ContactContactRelation__Share.SObjectType
	};
	private static Map<String, String> groupDevNamesAndIds
	{
		get
		{
			if (null == groupDevNamesAndIds || groupDevNamesAndIds.isEmpty())
			{
				groupDevNamesAndIds = selectAllGroupsByDeveloperName();
			}
			return groupDevNamesAndIds;
		}
		private set;
	}

	private static final List<SObjectType> standardSObjectSharesList = new List<SObjectType> {AccountShare.SObjectType, CaseShare.SObjectType};


	public void getSObjectShareRecords(fflib_ISObjectUnitOfWork uow, List<RecordsShareConfigsWrapper> recordsShareConfigs, SObjectType sObjectTypeName)
	{
		Id groupId = null;

		SObjectType shareSObjectType = SObjectAndShareObjectInfo.get(sObjectTypeName);
		if (shareSObjectType == null)
		{
			return ;
		}

		Set<Id> SObjectIds = getSObjectIds(recordsShareConfigs);

		if (SObjectIds.isEmpty())
		{
			return ;
		}

		Schema.DescribeSObjectResult SObjectResult = shareSObjectType.getDescribe();
		String accessLevelFieldName = getAccessLevelFieldName(shareSObjectType, SObjectResult);
		String parentIdFieldName = getParentIdFieldName(shareSObjectType, SObjectResult);
		Map<Id, List<SObject>> shareRecordsBySObjectId = Application.getSObjectShareSelectorInstance(shareSObjectType)
				.selectShareRecordsBySObjectIds(SObjectIds);
		Boolean hasExistingShares = shareRecordsBySObjectId != null && !shareRecordsBySObjectId.isEmpty();

		for (RecordsShareConfigsWrapper rscw : recordsShareConfigs)
		{
			groupId = (Id) groupDevNamesAndIds.get(rscw.groupName);
			if (hasExistingShares && checkIfShareRecordExistsForGroup(shareRecordsBySObjectId.get(rscw.recordId), groupId))
			{
				continue;
			}

			SObject SObjectShare = shareSObjectType.newSObject();
			SObjectShare.put(parentIdFieldName, rscw.recordId);
			SObjectShare.put(USERORGROUPID, groupId);
			SObjectShare.put(accessLevelFieldName, rscw.accessLevel);
			addOpportunityAccessLevelIfAccontShare(shareSObjectType, SObjectShare);
			uow.registerNew(SObjectShare);
		}
	}

	private static Map<String, String> selectAllGroupsByDeveloperName()
	{
		List<Group> groups = new sflib_GroupsSelector().selectAllGroups();
		return new sflib_SObjects(groups).asStringFieldByStringField(Group.DeveloperName, Group.Id);
	}

	private String getAccessLevelFieldName(SObjectType shareSObjectType, Schema.DescribeSObjectResult SObjectResult)
	{

		return !standardSObjectSharesList.contains(shareSObjectType) ? ACCESSLEVEL : SObjectResult.getName().removeEndIgnoreCase(SHARE) + ACCESSLEVEL;
	}

	private String getParentIdFieldName(SObjectType shareSObjectType, Schema.DescribeSObjectResult SObjectResult)
	{
		return !standardSObjectSharesList.contains(shareSObjectType) ? PARENTID : SObjectResult.getName().removeEndIgnoreCase(SHARE) + ID;
	}

	private void addOpportunityAccessLevelIfAccontShare(SObjectType shareSObjectType, SObject shareRecord)
	{
		if (AccountShare.SObjectType == shareSObjectType)
		{
			shareRecord.put(OPPORTUNITYACCESSLEVEL, NONE);
		}
	}

	private Boolean checkIfShareRecordExistsForGroup(List<SObject> existingShareRecords, Id groupId)
	{
		if (existingShareRecords == null || existingShareRecords.isEmpty())
		{
			return false;
		}

		Boolean shareRecordFound = false;

		for (SObject shareRecord : existingShareRecords)
		{
			if (groupId == shareRecord.get(USERORGROUPID))
			{
				shareRecordFound = true;
				break;
			}
		}
		return shareRecordFound;
	}

	private Set<Id> getSObjectIds(List<RecordsShareConfigsWrapper> recordShareConfigs)
	{
		Set<Id> SObjectIds = new Set<Id>();
		for (RecordsShareConfigsWrapper recordShareConfig : recordShareConfigs)
		{
			SObjectIds.add(recordShareConfig.recordId);
		}
		return SObjectIds;
	}

	public void cloneSharingSettings(fflib_ISObjectUnitOfWork uow, Map<Id, Id> sObjectIdByObjectIdToCloneMap, SObjectType sObjectToCloneType)
	{
		Map<Id, List<SObject>> shareRecordsBySObjectIdToInherit = Application.getSObjectShareSelectorInstance(sObjectToCloneType)
																		.selectShareRecordsBySObjectIds(new Set<Id>(sobjectIdByObjectIdToCloneMap.values()));

		if (shareRecordsBySObjectIdToInherit == null || shareRecordsBySObjectIdToInherit.isEmpty())
		{
			return ;
		}

		SObjectType SObjectTypeToCreateShares = SObjectAndShareObjectInfo.get(new List<Id>(sObjectIdByObjectIdToCloneMap.keySet())[0].getSObjectType());
		Schema.DescribeSObjectResult SObjectResult = SObjectTypeToCreateShares.getDescribe();

		String parentAccessLevel = getAccessLevelFieldName(sObjectToCloneType, sObjectToCloneType.getDescribe());
		String accessLevelFieldName = getAccessLevelFieldName(SObjectTypeToCreateShares, SObjectResult);
		String parentIdFieldName = getParentIdFieldName(SObjectTypeToCreateShares, SObjectResult);

		Map<Id, List<SObject>> existingShareRecordsBySObjectId = Application.getSObjectShareSelectorInstance(SObjectTypeToCreateShares)
																	.selectShareRecordsBySObjectIds(
																			new Set<Id>(sObjectIdByObjectIdToCloneMap.keyset()));

		Boolean hasExistingShares = existingShareRecordsBySObjectId != null && !existingShareRecordsBySObjectId.isEmpty();
		Id sObjectIdToInheritFrom;
		SObject SObjectShare;

		for(Id sObjectIdToShare : sObjectIdByObjectIdToCloneMap.keySet())
		{
			sObjectIdToInheritFrom = sObjectIdByObjectIdToCloneMap.get(sObjectIdToShare);
			if(sObjectIdToInheritFrom == null || !shareRecordsBySObjectIdToInherit.containsKey(sObjectIdToInheritFrom))
			{
				continue;
			}

			for(SObject sObjectToInherit : shareRecordsBySObjectIdToInherit.get(sObjectIdToInheritFrom))
			{
				if (MANUAL != (String) sObjectToInherit.get(ROWCAUSE) || (hasExistingShares &&
						checkIfShareRecordExistsForGroup(existingShareRecordsBySObjectId.get(sObjectIdToShare), (Id) sObjectToInherit.get(USERORGROUPID))))
				{
					continue;
				}
				SObjectShare = SObjectTypeToCreateShares.newSObject();
				SObjectShare.put(parentIdFieldName, sObjectIdToShare);
				SObjectShare.put(USERORGROUPID, sObjectToInherit.get(USERORGROUPID));
				SObjectShare.put(accessLevelFieldName, sObjectToInherit.get(parentAccessLevel));
				addOpportunityAccessLevelIfAccontShare(SObjectTypeToCreateShares, SObjectShare);
				uow.registerNew(SObjectShare);
			}
		}

	}
}
