public with sharing class CarePlanGoals extends fflib_SObjectDomain
{

	public CarePlanGoals(List<HealthCloudGA__CarePlanGoal__c> records)
	{
		super(records);
	}

	private CarePlanGoalsService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (CarePlanGoalsService) Application.Service.newInstance(CarePlanGoalsService.class);
            }
            return Service;
        }
        set;
    }

	public override void onAfterInsert()
	{
		Service.grantAccessToPublicGroups(this);
	}

	public class Constructor implements fflib_SObjectDomain.IConstructable2
	{
		public fflib_SObjectDomain construct(List<SObject> sObjectList)
		{
			return new CarePlanGoals(sObjectList);
		}

		public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
		{
			return construct(sObjectList);
		}
	}

}