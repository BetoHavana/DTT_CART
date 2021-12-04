public with sharing class TasksService
{
	static final String GENERAL ='General';
	static final String INTERNAL_OPERATIONS_COORDINATOR = 'CellTherapyOrderSpecialist';

	public List<Task> elevatedCreateCarePlanTasks(List<HealthCloudGA__CarePlanTemplateGoal__c> carePlanTemplateGoals, List<HealthCloudGA__CarePlanGoal__c> lstCarePlanGoals)
	{
		List<Task> carePlanGoalTasks = new List<Task>();
		if (carePlanTemplateGoals.isEmpty() || lstCarePlanGoals.isEmpty()) return carePlanGoalTasks;

		Set<Id> carePlanTemplateGoalIds = sflib_ArrayUtils.pluckIdField(carePlanTemplateGoals, HealthCloudGA__CarePlanTemplateGoal__c.Id);
		List<HealthCloudGA__CarePlanTemplateTask__c> lstCarePlanTemplateTasks = ((CarePlanTemplateTasksSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanTemplateTask__c.SObjectType)).selectByCarePlanTemplateGoalIds(carePlanTemplateGoalIds);

		Id carePlanTaskRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CarePlanTask').getRecordTypeId();
		if (lstCarePlanTemplateTasks.isEmpty()) return carePlanGoalTasks;

		Set<Id> carePlanIds = sflib_ArrayUtils.pluckIdField(lstCarePlanGoals,HealthCloudGA__CarePlanGoal__c.HealthCloudGA__CarePlan__c);
		Map<Id,Case> carePlanMap = new Map<Id, Case>((List<Case>)((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
				.elevatedSelectByCarePlanId(carePlanIds));

		for (HealthCloudGA__CarePlanTemplateTask__c objCarePlanTemplateTask : lstCarePlanTemplateTasks)
		{
			for (HealthCloudGA__CarePlanGoal__c objGoal : lstCarePlanGoals)
			{
				if (objCarePlanTemplateTask.HealthCloudGA__CarePlanTemplateGoal__r.Name == objGoal.Name)
				{
					Task objTask = new Task();
					objTask.HealthCloudGA__CarePlanGoal__c = objGoal.Id;
					objTask.HealthCloudGA__CarePlanTemplate__c = objGoal.HealthCloudGA__CarePlanTemplate__c;
					objTask.RecordTypeId = carePlanTaskRecordTypeId;
					objTask.HealthCloudGA__SortOrder__c = objCarePlanTemplateTask.HealthCloudGA__SortOrder__c;
					objTask.Priority = objCarePlanTemplateTask.HealthCloudGA__Priority__c;
					objTask.WhatId = objGoal.HealthCloudGA__CarePlan__c;
					if(carePlanMap.containsKey(objGoal.HealthCloudGA__CarePlan__c)
							&& carePlanMap.get(objGoal.HealthCloudGA__CarePlan__c).TreatmentSite__c != null
									&& carePlanMap.get(objGoal.HealthCloudGA__CarePlan__c).TreatmentSite__r.CellTherapyOrderSpecialist__c != null)
					{
						objTask.OwnerId = carePlanMap.get(objGoal.HealthCloudGA__CarePlan__c).TreatmentSite__r.CellTherapyOrderSpecialist__c;
					}
					objTask.HealthCloudGA__TaskType__c = objCarePlanTemplateTask.HealthCloudGA__Type__c;
					objTask.Status = objCarePlanTemplateTask.HealthCloudGA__Status__c;
					objTask.Subject = objCarePlanTemplateTask.HealthCloudGA__Subject__c;
					objTask.ActivityDate = System.today() + Integer.valueOf(objCarePlanTemplateTask.HealthCloudGA__Offset__c);
					objTask.Description = objCarePlanTemplateTask.HealthCloudGA__Description__c;
					carePlanGoalTasks.add(objTask);
				}
			}
		}
		try
		{
			fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
			new ElevatedContextDML().elevatedCreateCarePlanTasks(carePlanGoalTasks, elevatedUnitOfWork);
			elevatedUnitOfWork.commitWork();
		}
		catch (Exception e)
		{
			Application.logEntry.error(e);
		}
		return carePlanGoalTasks;
	}

    public List<Task> getTasksForPatientServiceEnrollee(List<PatientServicesEnrollee__c> pseRecords,
            Map<String, List<PatientServiceEnrolleeTaskConfig__mdt>> pseStatusAndTaskConfigInfo,
            Id businessHoursId)
    {
        List<Task> tasks = new List<Task>();
        BusinessHoursCalculatorImp bhCalculatorImp = new BusinessHoursCalculatorImp(businessHoursId);
        DateTime nextBusinessHourDT = bhCalculatorImp.getNextBusinessHourDateTime(Date.today().addDays(1));
	    Id taskGeneralRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(GENERAL).getRecordTypeId();
        for (PatientServicesEnrollee__c pse : pseRecords)
        {
            if (!pseStatusAndTaskConfigInfo.containsKey(pse.PatientServicesStatus__c)) continue;
            for (PatientServiceEnrolleeTaskConfig__mdt pseConfig :
                    pseStatusAndTaskConfigInfo.get(pse.PatientServicesStatus__c))
            {
                tasks.add(getNewTask(pse, pseConfig, businessHoursId, nextBusinessHourDT, bhCalculatorImp, taskGeneralRecordTypeId));
            }
        }
        return tasks;
    }

    Task getNewTask(PatientServicesEnrollee__c pse, PatientServiceEnrolleeTaskConfig__mdt pseTaskConfig,
                    Id businessHoursId, DateTime nextBusinessHourDT, BusinessHoursCalculatorImp bhCalculatorImp,
                    Id recordTypeId)
    {
        return new Task(Subject = pseTaskConfig.TaskSubject__c, Status = pseTaskConfig.TaskStatus__c,
                whatId = pse.Id, OwnerId = pse.OwnerId,
                Priority = pseTaskConfig.TaskPriority__c,
                ActivityDate = bhCalculatorImp.getDueDateBasedOnBusinessHours(nextBusinessHourDT,
		        Integer.valueOf(pseTaskConfig.DaysToReachDueDate__c)),
                RecordTypeId=recordTypeId,
                HealthCloudGA__TaskType__c = pseTaskConfig.TaskType__c);
    }

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			insert objList;
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

		public void elevatedCreateCarePlanTasks(List<Task> tasks, fflib_ISObjectUnitOfWork unitOfWork)
		{
			unitOfWork.registerNew(tasks);
		}
	}

	public void closeTasks(List<Order__c> orderList, Map<Id,Order__c> existingOrders)
	{
		Map<Id,List<String>> tasksToCloseByCarePlanId = getTasksToCloseByCarePlanId(orderList, existingOrders);
		Set<Id> carePlanIds = sflib_ArrayUtils.pluckIdField(orderList, Order__c.CarePlanID__c);

		List<Task> openTasksList = ((TasksSelector) Application.Selector.newInstance(Task.SObjectType))
		.selectTasksByCarePlanIds(carePlanIds);

		List<Task> tasksToUpdate = new List<Task>();
		List<String> taskSubjectList;

		for(Task tsk : openTasksList)
		{
			Id carePlanId = tsk.whatId;

			if(tasksToCloseByCarePlanId.containsKey(carePlanId))
			{
				taskSubjectList = tasksToCloseByCarePlanId.get(carePlanId);

				if(taskSubjectList.contains(tsk.Subject))
				{
					tsk.Status = Label.StatusCompleted;
					tasksToUpdate.add(tsk);
				}
			}
		}

		if(!tasksToUpdate.isEmpty())
		{
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerDirty(tasksToUpdate);
			uow.commitWork();
		}


	}

	private Map<Id,List<String>> getTasksToCloseByCarePlanId(List<Order__c> orderList, Map<Id,Order__c> existingRecords)
	{

		Map<Id,List<String>> tasksToCloseByCarePlanId = new Map<Id,List<String>>();
		List<String> subjects;
		Order__c oldOrder;
		Id carePlanId;

		for(Order__c ord : orderList)
		{
			oldOrder = existingRecords.get(ord.Id);
			carePlanId = ord.CarePlanID__c;

			if(!tasksToCloseByCarePlanId.containsKey(carePlanId))
			{
				tasksToCloseByCarePlanId.put(carePlanId, new List<String>());
			}

			if(ord.VinetiCOI__c	!= oldOrder.VinetiCOI__c)
			{
				subjects = tasksToCloseByCarePlanId.get(carePlanId);
				subjects.add(Label.OrderPlacement);

				tasksToCloseByCarePlanId.put(carePlanId, subjects);
			}

			if(ord.FinalDPDateinVineti__c != oldOrder.FinalDPDateinVineti__c)
			{
				subjects = tasksToCloseByCarePlanId.get(carePlanId);
				subjects.add(Label.ConfirmDeliveryDate);
				tasksToCloseByCarePlanId.put(carePlanId, subjects);
			}

			if(ord.OrderRescheduledinVineti__c != oldOrder.OrderRescheduledinVineti__c)
			{
				subjects = tasksToCloseByCarePlanId.get(carePlanId);
				subjects.add(Label.OrderReschedule);

				tasksToCloseByCarePlanId.put(carePlanId, subjects);
			}
		}
		return tasksToCloseByCarePlanId;
	}
	public List<Task> getAdhocTasksforVeinToVein(List<Order__c> orderRecords,
                                       Map<String, List<OrderTaskConfig__mdt>> orderTaskConfigInfo,
                                       Id businessHoursId, String taskSubject)
    {
        List<Group> queuesName = ((GroupsSelector) Application.Selector.newInstance(Group.SObjectType)).selectAll();
        String queueId = '';
        for(Group objGroup: queuesName){
            if(objGroup.Name == Label.V2VManagerQueue){
                queueId = objGroup.Id;
            }
        }
        List<Task> tasks = new List<Task>();
        BusinessHoursCalculatorImp bhCalculatorImp = new BusinessHoursCalculatorImp(businessHoursId);
        DateTime nextBusinessHourDT = bhCalculatorImp.getNextBusinessHourDateTime(Date.today().addDays(1));
	    Id taskGeneralRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByName().get(GENERAL).getRecordTypeId();
        for (Order__c objOrder : orderRecords)
        {
            tasks.add(getNewAdhocTasksforVeinToVein(objOrder, orderTaskConfigInfo.get(taskSubject),
                                         nextBusinessHourDT,
                                         bhCalculatorImp, taskGeneralRecordTypeId,queueId));
        }
        return tasks;
    }
    Task getNewAdhocTasksforVeinToVein(Order__c objOrder,
                            List<OrderTaskConfig__mdt> orderTaskConfig,
                    		DateTime nextBusinessHourDT,
                            BusinessHoursCalculatorImp bhCalculatorImp,
                    		Id recordTypeId, String queueId)
    {
        return new Task(
            Subject = orderTaskConfig[0].TaskSubject__c,
            Status = orderTaskConfig[0].TaskStatus__c,
            WhatId = objOrder.CarePlanID__c,
            OwnerId = queueId,
            Priority = orderTaskConfig[0].TaskPriority__c,
            ActivityDate = bhCalculatorImp.getDueDateBasedOnBusinessHours(nextBusinessHourDT,Integer.valueOf(orderTaskConfig[0].DaysToReachDueDate__c)),
            RecordTypeId = recordTypeId,
            HealthCloudGA__TaskType__c = orderTaskConfig[0].TaskType__c
        );
    }

	public void assignOwnerId(List<Task> taskList)
	{
		List<HealthCloudGA__CarePlanTemplateTask__c> cptemplateTask = ((CarePlanTemplateTasksSelector) Application.Selector.newInstance(HealthCloudGA__CarePlanTemplateTask__c.SObjectType))
																		.selectRelatedToTemplateGoalByRole(INTERNAL_OPERATIONS_COORDINATOR);

		Set<String> tasksNameSet = sflib_ArrayUtils.pluckStringField(cptemplateTask, HealthCloudGA__CarePlanTemplateTask__c.HealthCloudGA__Subject__c);
		List<Task> tasksToUpdate = getTasksByName(tasksNameSet, taskList);
		Map<Id,List<Task>> tasksByCarePlan = (Map<Id,List<Task>>) new sflib_SObjects(tasksToUpdate).asSObjectsByIdField(Task.WhatId);
		Map<Id,Id> usersByCarePlanIdMap = getUsersByCarePlanIdMap(tasksByCarePlan.keySet());

		assignOwnerId(tasksByCarePlan, usersByCarePlanIdMap);
	}

	public void assignOwnerId(Map<Id,List<Task>> tasksByCarePlan, Map<Id,Id> usersByCarePlanId)
	{
		Id userId;

		for(Id carePlanId : tasksByCarePlan.keySet())
		{
			userId = usersByCarePlanId.get(carePlanId);

			if(userId != null)
			{
				for(Task task : tasksByCarePlan.get(carePlanId))
				{
					task.OwnerId = userId;
				}
			}

		}

	}

	public Map<Id,Id> getUsersByCarePlanIdMap(Set<Id> carePlanIds)
	{
		List<Case> carePlanList = ((CasesSelector) Application.Selector.newInstance(Case.SObjectType))
									.selectByCarePlanId(carePlanIds);

		Map<Id,Id> usersByCarePlanIdMap = new Map<Id,Id>();

		for(Case carePlan : carePlanList)
		{
			usersByCarePlanIdMap.put(carePlan.Id, carePlan.TreatmentSite__r.CellTherapyOrderSpecialist__c);
		}

		return usersByCarePlanIdMap;
	}

	public List<Task> getTasksByName(Set<String> tasksNameSet, List<Task> taskList)
	{
		List<Task> tasksToUpdate = new List<Task>();

		for(Task task : taskList)
		{
			if(tasksNameSet.contains(task.Subject))
			{
				tasksToUpdate.add(task);
			}
		}

		return tasksToUpdate;
	}

}
