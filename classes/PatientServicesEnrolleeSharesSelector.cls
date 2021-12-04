public with sharing class PatientServicesEnrolleeSharesSelector extends sflib_SObjectSelector implements ISObjectShareSelector{

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				PatientServicesEnrollee__Share.Id,
                PatientServicesEnrollee__Share.ParentId,
				PatientServicesEnrollee__Share.AccessLevel,
				PatientServicesEnrollee__Share.UserOrGroupId,
                PatientServicesEnrollee__Share.RowCause
		};
	}

	public SObjectType getSObjectType()
	{
		return PatientServicesEnrollee__Share.SObjectType;
	}
    
	public List<PatientServicesEnrollee__Share> selectSObjectSharesBySObjectIds(Set<Id> SObjectIds)
	{
		return (List<PatientServicesEnrollee__Share>) selectByFieldInIdSet(PatientServicesEnrollee__Share.ParentId, SObjectIds);
	}
    
    public Map<Id,List<SObject>> selectShareRecordsBySObjectIds(Set<Id> SObjectIds)
    {
      return new sflib_SObjects(selectSObjectSharesBySObjectIds(SObjectIds)).asSObjectsByIdField(PatientServicesEnrollee__Share.ParentId);   
    }

}