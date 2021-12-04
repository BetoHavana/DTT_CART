public with sharing class Tasks extends sflib_SObjectDomain
{
	private static final String PERFORMQUALITYCHECKOFPE_TASKSUBJECT = 'Perform quality check of patient enrollment';
    private static final String PATIENTENROLLMENT_GOALNAME = 'Patient Enrollment';
	private static final Integer ONEDAY = 1 ;


	public Tasks(List<Task> Records)
	{
		super(Records, Task.SObjectType);
	}

	public Type getType()
	{
		return Tasks.class;
	}

    private TasksService Service
	{
		get
		{
			if (null == Service)
			{
				Service = (TasksService) Application.Service.newInstance(TasksService.class);
			}
			return Service;
		}
		set;
	}

    public override void onBeforeInsert()
	{
		Service.AssignOwnerId(((List<Task>) Records));
        setDueDateForPerformQualityCheckTasks();
    }

	public Tasks setDueDateForPerformQualityCheckTasks()
	{
		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType)).
														selectBusinessHoursByName(Label.BusinessHoursNameForPatientServiceEnrolleeTasks);
		BusinessHoursCalculatorImp businessHoursImp = new BusinessHoursCalculatorImp(businessHours[0].Id);
		Date dateAfterOneBusinessDay = businessHoursImp.getDueDateBasedOnBusinessHours(System.now(), ONEDAY);
		return selectTasksByTaskSubjectAndGoalName().setTaskDueDate(dateAfterOneBusinessDay);
	}
    
    public Tasks selectTasksByTaskSubjectAndGoalName()
    {		
        List<SObject> filteredRecords = new sflib_SObjects(Records).
											 filter(new sflib_Criteria()
											.addAndCriteria(new sflib_Criteria()	
											.equalTo(Task.Subject, PERFORMQUALITYCHECKOFPE_TASKSUBJECT)
                                    		.equalTo(Task.GoalName__c, PATIENTENROLLMENT_GOALNAME))).getSobjects();
        
        return new Tasks(filteredRecords);
    }
    
    public Tasks setTaskDueDate(Date dueDate)
    {
        setField(Task.ActivityDate,dueDate );
        return this;
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new Tasks(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
    }

}