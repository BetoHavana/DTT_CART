public with sharing class AccountAccountRelations extends fflib_SObjectDomain
{
	private AccountAccountRelationsService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (AccountAccountRelationsService) Application.Service.newInstance(AccountAccountRelationsService.class);
            }
            return Service;
        }
        set;
    }

	public AccountAccountRelations(List<HealthCloudGA__AccountAccountRelation__c> records)
	{
		super(records, HealthCloudGA__AccountAccountRelation__c.SObjectType);
	}

	public Map<String, Id> getRelatedSites()
	{
		Map<String, Id> relatedSiteMap = new Map<String, Id>();
		Id cryoSiteRecTypeId = Schema.SObjectType.Account
								.getRecordTypeInfosByDeveloperName()
								.get(StaticConstants.CRYOSITE)
								.getRecordTypeId();
		for (HealthCloudGA__AccountAccountRelation__c rel : (List<HealthCloudGA__AccountAccountRelation__c>) records)
		{
			if ((cryoSiteRecTypeId.equals(rel.HealthCloudGA__RelatedAccount__r.RecordTypeId)) && !(relatedSiteMap.containsKey(rel.HealthCloudGA__Account__c)))
			{
				relatedSiteMap.put(rel.HealthCloudGA__Account__c, rel.HealthCloudGA__RelatedAccount__c);
			}
		}
		return relatedSiteMap;
	}

	public override void onAfterInsert()
	{
		Service.grantAccessToRelatedPublicGroups(this);
	}

	public override void onAfterUpdate(Map<Id, SObject> existingRecords)
	{
		Service.grantAccessToRelatedPublicGroups(this);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new AccountAccountRelations(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}
}