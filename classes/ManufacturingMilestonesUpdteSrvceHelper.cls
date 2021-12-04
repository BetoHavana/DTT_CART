public inherited sharing class ManufacturingMilestonesUpdteSrvceHelper implements ICalloutServiceHelper {
    
    public Map<Id, String> getCalloutInputRequestBody(Set<Id> orderMilestoneIds)
    {
        Map<Id, String> orderIdNInputBody = new Map<Id, String>();
        
        Map<Id,OrderMilestones__c> orderMilestonesInfo = new Map<Id,OrderMilestones__c>(
            											((OrderMilestonesSelector) Application.Selector
                                                         .newInstance(OrderMilestones__c.SObjectType))
                                                         .selectById(orderMilestoneIds));
        
        OrderMilestones__c orderMilestone = new OrderMilestones__c();
        ManufacturingMilestonesUpdateSrvceInput input = new ManufacturingMilestonesUpdateSrvceInput();
        
        for(Id orderMilestoneId : orderMilestoneIds)
        {
            input  = new ManufacturingMilestonesUpdateSrvceInput();
            orderMilestone = orderMilestonesInfo.get(orderMilestoneId);
            input.CARTOrderId = orderMilestone.Order__r.CartOrderId__c;
            input.status = orderMilestone.Name;
            input.eventDate = orderMilestone.MilestoneDatetime__c == null ? null : string.valueOf(
                              orderMilestone.MilestoneDatetime__c.Date());
            orderIdNInputBody.put(orderMilestone.Order__c,JSON.serialize(input));
        } 
        
        return orderIdNInputBody;
    }
}