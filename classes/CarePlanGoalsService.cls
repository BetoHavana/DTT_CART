public with sharing class CarePlanGoalsService
{

	public List<HealthCloudGA__CarePlanGoal__c> elevatedCreateCarePlanGoals(Map<Case, HealthCloudGA__CarePlanTemplate__c> carePlanTemplateByCases, List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoalList)
	{
		List<HealthCloudGA__CarePlanGoal__c> carePlanGoals = new List<HealthCloudGA__CarePlanGoal__c>();
		for (Case objCase : carePlanTemplateByCases.keySet())
		{
			for (HealthCloudGA__CarePlanTemplateGoal__c objCarePlanTemplateGoal : carePlanTemplateGoalList)
			{
				if (!carePlanTemplateByCases.containsKey(objCase)) break;
				HealthCloudGA__CarePlanGoal__c objCarePlanGoal = new HealthCloudGA__CarePlanGoal__c();
				objCarePlanGoal.HealthCloudGA__CarePlan__c = objCase.Id;
				objCarePlanGoal.HealthCloudGA__CarePlanTemplate__c = carePlanTemplateByCases.get(objCase).Id;
				objCarePlanGoal.Name = objCarePlanTemplateGoal.Name;
				objCarePlanGoal.HealthCloudGA__SortOrder__c = objCarePlanTemplateGoal.HealthCloudGA__SortOrder__c;
				objCarePlanGoal.HealthCloudGA__Description__c = objCarePlanTemplateGoal.HealthCloudGA__Description__c;
				carePlanGoals.add(objCarePlanGoal);
			}
		}
		try
		{
			fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
			new ElevatedContextDML().elevatedCreateCarePlanGoals(carePlanGoals, elevatedUnitOfWork);
			elevatedUnitOfWork.commitWork();
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
		return carePlanGoals;
	}

	public void grantAccessToPublicGroups(carePlanGoals carePlanGoals)
	{

		fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToRelatedPublicGroups(uow, carePlanGoals.getRecords());
		uow.commitWork();
	}

	public void grantAccessToRelatedPublicGroups(fflib_ISObjectUnitOfWork uow, List<HealthCloudGA__CarePlanGoal__c> carePlanGoalList)
	{
		Map<Id, Id> cpgIdByCarePlanIdToInheritAccess = new Map<Id, Id>();

		for (HealthCloudGA__CarePlanGoal__c goal : carePlanGoalList)
		{
			if (goal.HealthCloudGA__CarePlan__c == null)
			{
				continue;
			}

			cpgIdByCarePlanIdToInheritAccess.put(goal.Id, goal.HealthCloudGA__CarePlan__c);
		}
		new RecordsSharingService().cloneSharingSettings(uow, cpgIdByCarePlanIdToInheritAccess, CaseShare.SObjectType);
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
		public void eventPublish(List<SObject> objList)
		{
			//not implemented
		}

		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}
			Database.emptyRecycleBin(objList);
		}

		public void elevatedCreateCarePlanGoals(List<HealthCloudGA__CarePlanGoal__c> carePlanGoals, fflib_ISObjectUnitOfWork unitOfWork)
		{
			unitOfWork.registerNew(carePlanGoals);
		}
	}

}