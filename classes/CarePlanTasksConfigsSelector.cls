public with sharing class CarePlanTasksConfigsSelector extends sflib_SObjectSelector
{
    public sObjectType getSobjectType()
    {
        return CarePlanTasksConfigs__mdt.SObjectType;
    }

    public List<SObjectField> getSObjectFieldList()
    {
        return new List<SObjectField>
        {
                CarePlanTasksConfigs__mdt.APINamesOfChangedFieldsToRunLogic__c,
                CarePlanTasksConfigs__mdt.InheritDueDateFromOrderField__c,
                CarePlanTasksConfigs__mdt.IsActive__c,
                CarePlanTasksConfigs__mdt.MasterLabel,
                CarePlanTasksConfigs__mdt.NoOfDaysToAddToInheritedDate__c,
                CarePlanTasksConfigs__mdt.OrderConditionsInfo__c,
                CarePlanTasksConfigs__mdt.TasksConditionsInfo__c
                
        };
    }

    public List<CarePlanTasksConfigs__mdt> selectAllActiveRules()
    {
        return (List<CarePlanTasksConfigs__mdt> ) Database.query(
                 newQueryFactory()
                    .setCondition(String.format('{0} = true',
                     new List<String>{CarePlanTasksConfigs__mdt.IsActive__c.getDescribe().getName()})).toSOQL());

    }

}