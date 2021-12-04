public with sharing class ContactContactRelations extends fflib_SObjectDomain
{
	private static ContactContactRelationsService ContactContactRelationsService
	{
		get
		{
			if (null == ContactContactRelationsService)
			{
				ContactContactRelationsService = (ContactContactRelationsService) Application.Service.newInstance(ContactContactRelationsService.class);
			}
			return ContactContactRelationsService;
		}
		set;
	}

	public ContactContactRelations(List<HealthCloudGA__ContactContactRelation__c> records)
	{
		super(records, HealthCloudGA__ContactContactRelation__c.SObjectType);
	}

	public Set<Id> getRelatedContactIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c);
	}

	public Set<Id> getContactIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Contact__c);
	}

	public Set<Id> getRoleIds()
	{
		return sflib_ArrayUtils.pluckIdField(Records, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Role__c);
	}

	public Map<Id, Id> getContactIdsByRelatedContactIds()
	{
		Map<Id, Id> relatedContactIdsByContactsIds = new Map<Id, Id>();
		for (HealthCloudGA__ContactContactRelation__c objContactContactRelation : (List<HealthCloudGA__ContactContactRelation__c>) Records)
		{
			relatedContactIdsByContactsIds.put(objContactContactRelation.HealthCloudGA__RelatedContact__c, objContactContactRelation.HealthCloudGA__Contact__c);
		}
		return relatedContactIdsByContactsIds;
	}

	public List<HealthCloudGA__ContactContactRelation__c> getByRoles(Set<String> roleNames)
	{
		List<HealthCloudGA__ContactContactRelation__c> result = new List<HealthCloudGA__ContactContactRelation__c>();
		for (HealthCloudGA__ContactContactRelation__c objContactContactRelation : (List<HealthCloudGA__ContactContactRelation__c>) Records)
		{
			for (String role : roleNames)
			{
				if (objContactContactRelation.HealthCloudGA__Role__r.Name == role)
				{
					result.add(objContactContactRelation);
				}
			}
		}
		return result;
	}

	public ContactContactRelations getRecordsWithRelatedContactAndContact()
	{
		List<HealthCloudGA__ContactContactRelation__c> filteredRecords = (List<HealthCloudGA__ContactContactRelation__c>) new sflib_SObjects(Records).
				filter(new sflib_Criteria()
						.andCriteria()
						.notEqualTo(HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Contact__c, null)
						.notEqualTo(HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c, null)
						.addOrCriteria(new sflib_Criteria())
				).getSobjects();
		return new ContactContactRelations(filteredRecords);
	}

	public override void onAfterInsert()
	{
		createPatientsShareRecordsForTreatmentSitesGroup();
		grantAccessToPublicGroups();
	}

	public void createPatientsShareRecordsForTreatmentSitesGroup()
	{
		ContactContactRelationsService.createShareRecordsForCARTRole(getRecordsWithRelatedContactAndContact().getRecords());
	}

	public Map<Id, Id> getRelatedContactIdByContactId()
	{
		return new sflib_SObjects(records).asIdFieldByIdField(HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c, HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Contact__c);
	}

	public void grantAccessToPublicGroups()
	{
		ContactContactRelationsService.grantAccessToPublicGroups(this);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new ContactContactRelations(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return new ContactContactRelations(sObjectList);
		}
	}
}