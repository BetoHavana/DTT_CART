public with sharing class ReciprocalRoleSelector extends fflib_SObjectSelector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				HealthCloudGA__ReciprocalRole__c.Id,
				HealthCloudGA__ReciprocalRole__c.Name,
				HealthCloudGA__ReciprocalRole__c.HealthCloudGA__CreateInverseRole__c,
				HealthCloudGA__ReciprocalRole__c.HealthCloudGA__InverseRelationship__c,
				HealthCloudGA__ReciprocalRole__c.HealthCloudGA__InverseRole__c,
				HealthCloudGA__ReciprocalRole__c.HealthCloudGA__RelationshipType__c,
				HealthCloudGA__ReciprocalRole__c.HealthCloudGA__SourceSystemId__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return HealthCloudGA__ReciprocalRole__c.SObjectType;
	}

	public List<HealthCloudGA__ReciprocalRole__c> selectAll()
	{
		String patient = StaticConstants.PatientRecordTypeDeveloperName;
		String contactContactRelation = StaticConstants.contactContactRelation;
		return((List<HealthCloudGA__ReciprocalRole__c>) Database.query(
				newQueryFactory()
						.setCondition('HealthCloudGA__InverseRole__c =:patient AND HealthCloudGA__RelationshipType__c =:contactContactRelation')
						.toSOQL()
		)
		);
	}
	public List<HealthCloudGA__ReciprocalRole__c> selectByNameAndInverseRole(String name, String inverseRole, String recordTypeDeveloperName)
	{
		Id recordTypeId = Schema.SObjectType.HealthCloudGA__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		return((List<HealthCloudGA__ReciprocalRole__c>) Database.query(
				newQueryFactory()
						.setCondition('Name =:name AND HealthCloudGA__InverseRole__c =:inverseRole AND RecordTypeId = :recordTypeId')
						.toSOQL()
		));
	}

	public List<HealthCloudGA__ReciprocalRole__c> selectByRoleName(String name, String recordTypeDeveloperName)
	{
		Id recordTypeId = Schema.SObjectType.HealthCloudGA__ReciprocalRole__c.getRecordTypeInfosByDeveloperName().get(recordTypeDeveloperName).getRecordTypeId();
		return((List<HealthCloudGA__ReciprocalRole__c>) Database.query(
				newQueryFactory()
						.setCondition('Name =:name AND RecordTypeId = :recordTypeId')
						.toSOQL()
		));
	}

	public List<HealthCloudGA__ReciprocalRole__c> selectByIds(Set<Id> reciprocalRoleIds)
	{
		return((List<HealthCloudGA__ReciprocalRole__c>) Database.query(
				newQueryFactory()
						.selectField('Name')
						.setCondition('Id IN:reciprocalRoleIds')
						.toSOQL()
		));
	}
}
