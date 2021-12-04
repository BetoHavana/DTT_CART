public with sharing class AccountContactRelationsSelector extends fflib_SObjectSelector
{
	public static final String PATIENT_RECORDTYPE_DEVELOPERNAME = 'Patient';
	public static final String TREATMENTSITE_RECORDTYPE_DEVELOPERNAME = 'TreatmentSite';

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				AccountContactRelation.AccountId,
				AccountContactRelation.ContactId,
				AccountContactRelation.Id,
                AccountContactRelation.MedicalRecordNumber__c,
                AccountContactRelation.Roles
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return AccountContactRelation.SObjectType;
	}

	public List<AccountContactRelation> selectByAccountIdAndPersonas(Id accountId, Set<String> contactPersonas)
	{
		return (List<AccountContactRelation>)
				Database.query(
						newQueryFactory()
								.selectField('Contact.Name')
								.selectField('Contact.SitePersona__c')
								.setCondition('AccountId = :accountId AND Contact.SitePersona__c IN :contactPersonas')
								.toSOQL()
				);
	}

	public List<AccountContactRelation> selectByAccountContactRelationIds(Set<Id> accountContactRelationsIds)
	{
		Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PATIENT_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		Id treatmentSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TREATMENTSITE_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		String id = AccountContactRelation.Id.getDescribe().getName();
		String active = AccountContactRelation.IsActive.getDescribe().getName();

		return (List<AccountContactRelation>)
				Database.query(
						newQueryFactory()
								.selectField('ContactId.AccountId')
								.setCondition(id + ' IN :accountContactRelationsIds AND ' + active + ' = true AND Account.RecordType.Id = :treatmentSiteRecordTypeId AND Contact.Account.RecordType.Id = :patientRecordTypeId')
								.toSOQL()
				);
	}
    public List<AccountContactRelation>selectByContactAccountId(Set<Id> accountIds)
    {
        return (List<AccountContactRelation>)
				Database.query(
						newQueryFactory()
								.selectField('MedicalRecordNumber__c')
								.selectField('Contact.AccountId')
								.setCondition('Contact.AccountId IN :accountIds')
								.toSOQL()
				);
    }

	public List<AccountContactRelation> selectByContactIdRelatedToTreatmentSites(Set<Id> contactIds)
	{
		Id patientRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(PATIENT_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		Id treatmentSiteRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(TREATMENTSITE_RECORDTYPE_DEVELOPERNAME).getRecordTypeId();
		String id = AccountContactRelation.Id.getDescribe().getName();
		String active = AccountContactRelation.IsActive.getDescribe().getName();

		return (List<AccountContactRelation>)
				Database.query(
						newQueryFactory()
								.selectField('ContactId.AccountId')
								.setCondition('ContactId IN :contactIds AND ' + active + ' = true AND Account.RecordType.Id = :treatmentSiteRecordTypeId AND Contact.Account.RecordType.Id = :patientRecordTypeId')
								.toSOQL()
				);
	}

	public Database.QueryLocator getElevatedQLOfAccntContRelsCreatEditedInLastNDays(Integer lastNDays)
	{
		return new ElevatedContext(newQueryFactory()).getQLOfAccntContRelsCreatEditedInLastNDays(lastNDays);
	}

	private without sharing class ElevatedContext
	{
		private fflib_QueryFactory queryFactory;

		private ElevatedContext(fflib_QueryFactory queryFactory)
		{
			this.queryFactory = queryFactory;
		}

		public Database.QueryLocator getQLOfAccntContRelsCreatEditedInLastNDays(Integer lastNDays)
		{
			return Database.getQueryLocator(
					queryFactory.setCondition(String.format('{0} = LAST_N_DAYS:{1} ',
							new List<String>
							{
									AccountContactRelation.LastModifiedDate.getDescribe().getName(),
									String.valueOf(lastNDays)
							}))
							.toSOQL());
		}
	}

}