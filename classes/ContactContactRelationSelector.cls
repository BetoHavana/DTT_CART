public with sharing class ContactContactRelationSelector extends fflib_SObjectSelector
{
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public static final String PATIENT_RECORDTYPE_DEVELOPERNAME = 'Patient';
	public static final String CAREGIVER_RECORDTYPE_DEVELOPERNAME = 'Caregiver';

	public static final String Physician = 'Physician';

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
                HealthCloudGA__ContactContactRelation__c.Id,
                HealthCloudGA__ContactContactRelation__c.Account__c,
				HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Contact__c,
				HealthCloudGA__ContactContactRelation__c.HealthCloudGA__Active__c,
				HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c,
				HealthCloudGA__ContactContactRelation__c.HealthCloudGA__InverseRelationship__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__ContactContactRelation__c.SObjectType;
	}

	public Database.QueryLocator queryLocatorAllAssociatedContacts()
	{
		return Database.getQueryLocator(
				newQueryFactory().toSOQL()
		);
	}

	public List<HealthCloudGA__ContactContactRelation__c> selectAssociatedContactsByContactId(Set<Id> contactIds)
	{
		return (List<HealthCloudGA__ContactContactRelation__c>) Database.query(
				newQueryFactory()
						.selectField('HealthCloudGA__Role__r.Name')
						.setCondition('HealthCloudGA__RelatedContact__c IN :contactIds')
						.toSOQL()
		);
	}

	public List<HealthCloudGA__ContactContactRelation__c> elevatedSelectByContactId(Set<Id> contactIds)
	{
		fflib_QueryFactory queryFactory = newQueryFactory();
		return new elevatedContext(queryFactory).elevatedSelectByContactId(contactIds);
	}

    public List<HealthCloudGA__ContactContactRelation__c> selectAssociatedContactsByContactIdAndRoles(Set<Id> patientConIds, Set<String> roles)
    {
        return (List<HealthCloudGA__ContactContactRelation__c>) Database.query(newQueryFactory()
                .selectField('HealthCloudGA__Contact__r.FirstName')
                .selectField('HealthCloudGA__Contact__r.MiddleName')
                .selectField('HealthCloudGA__Contact__r.LastName')
		        .selectField('HealthCloudGA__Contact__r.AccountId')
                .setCondition('HealthCloudGA__RelatedContact__c IN :patientConIds AND HealthCloudGA__Role__r.Name IN :roles')
                .toSOQL());
    }

	public Database.QueryLocator getElevatedQLOfContContRelsCreatEditedInLastNDays(Integer lastNDays)
	{
		return new ElevatedContext(newQueryFactory()).getElevatedQLOfContContRelsCreatEditedInLastNDays(lastNDays);
	}


	private without sharing class elevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private elevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

		private List<HealthCloudGA__ContactContactRelation__c> elevatedSelectByContactId(Set<Id> contactIds)
		{
			queryFactory.selectField('HealthCloudGA__Contact__r.Name');
			queryFactory.selectField('HealthCloudGA__Role__r.Name');
			queryFactory.setCondition(HealthCloudGA__ContactContactRelation__c.HealthCloudGA__RelatedContact__c.getDescribe().getName() + ' IN :contactIds');
			return (List<HealthCloudGA__ContactContactRelation__c>) Database.query(queryFactory.toSOQL());
		}

		public Database.QueryLocator getElevatedQLOfContContRelsCreatEditedInLastNDays(Integer lastNDays)
		{
			return Database.getQueryLocator(
					queryFactory.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
							new List<String>
							{
									HealthCloudGA__AccountAccountRelation__c.LastModifiedDate.getDescribe().getName(),
									String.valueOf(lastNDays)
							}))
							.toSOQL());
		}
	}

	public List<HealthCloudGA__ContactContactRelation__c> selectAssociatedContactsByPatientAndSitePersona(Set<Id> patientIds, Set<String> sitePersonas)
    {
        return (List<HealthCloudGA__ContactContactRelation__c>) Database.query(newQueryFactory()
                .selectField('HealthCloudGA__Contact__r.Name')
                .selectField('HealthCloudGA__Contact__r.AccountId')
                .setCondition('Account__c IN :patientIds AND HealthCloudGA__Contact__r.SitePersona__c IN :sitePersonas')
                .toSOQL());
    }
}