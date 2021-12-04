public inherited sharing class PatientServiceEnrolleeTaskConfigSelector extends sflib_SObjectSelector
{
	public static List<PatientServiceEnrolleeTaskConfig__mdt> patientServiceEnrolleeTaskConfigs
	{
		get
		{
			if (patientServiceEnrolleeTaskConfigs == null)
			{
				patientServiceEnrolleeTaskConfigs = ((PatientServiceEnrolleeTaskConfigSelector) Application.Selector.newInstance(getObjectType()))
						.getActivePatientServiceEnrolleeTaskConfigInfo();
			}
			return patientServiceEnrolleeTaskConfigs;
		}
		private set;
	}

	Public SObjectType getSObjectType()
	{
		return PatientServiceEnrolleeTaskConfig__mdt.SobjectType;
	}

	public static sobjectType getObjectType()
	{
		return PatientServiceEnrolleeTaskConfig__mdt.sObjectType;
	}

	Public List<SObjectField> getSObjectFieldList()
	{
		return new List<SObjectField>
		{
				PatientServiceEnrolleeTaskConfig__mdt.IsActive__c,
				PatientServiceEnrolleeTaskConfig__mdt.DaysToReachDueDate__c,
				PatientServiceEnrolleeTaskConfig__mdt.PatientServiceEnrolleeStatus__c,
				PatientServiceEnrolleeTaskConfig__mdt.TaskPriority__c,
				PatientServiceEnrolleeTaskConfig__mdt.TaskStatus__c,
				PatientServiceEnrolleeTaskConfig__mdt.TaskSubject__c,
                PatientServiceEnrolleeTaskConfig__mdt.TaskType__c
		};
	}

	Public List<PatientServiceEnrolleeTaskConfig__mdt> getActivePatientServiceEnrolleeTaskConfigInfo()
	{
		return selectPatientServiceEnrolleeTaskConfigInfo(true);
	}

	Public List<PatientServiceEnrolleeTaskConfig__mdt> selectPatientServiceEnrolleeTaskConfigInfo(Boolean isActive)
	{

		fflib_QueryFactory queryFactory = newQueryFactory();
		queryFactory.setCondition(PatientServiceEnrolleeTaskConfig__mdt.isActive__c.getDescribe().getName() +
				' = :IsActive');
		return (List<PatientServiceEnrolleeTaskConfig__mdt>) Database.query(queryFactory.toSOQL());
	}

	public Map<String, List<PatientServiceEnrolleeTaskConfig__mdt>> selectActivePSEnrolleeTaskConfigInfoPerStatus()
	{
		Map<String, List<PatientServiceEnrolleeTaskConfig__mdt>> pseTaskConfigs = new Map<String, List<PatientServiceEnrolleeTaskConfig__mdt>>();
		for (PatientServiceEnrolleeTaskConfig__mdt pseTaskConfig : patientServiceEnrolleeTaskConfigs)
		{
			if (pseTaskConfigs.containsKey(pseTaskConfig.PatientServiceEnrolleeStatus__c))
			{
				pseTaskConfigs.get(pseTaskConfig.PatientServiceEnrolleeStatus__c).add(pseTaskConfig);
			}
			else
			{
				pseTaskConfigs.put(pseTaskConfig.PatientServiceEnrolleeStatus__c, new List<PatientServiceEnrolleeTaskConfig__mdt> {pseTaskConfig});
			}
		}
		return pseTaskConfigs;
	}

}