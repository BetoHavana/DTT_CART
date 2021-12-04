public class ManufacturingMilestonesUpdateSrvceInput {
    
    public String CARTOrderId{get;set;}	
    public String status{get;set;}
    public String eventDate{get;set;}	
    public String eventType 
    {
        get{
            return 'Manufacturing';
        }
        private set;
    }	
    public String therapyType{
        get{
            return 'Commercial';
        }
        private set;
    }	
    public String country {
        get{
            return 'US';
        }
        private set;
    }	
    public String region {
        get{
            return CalloutConstants.NAEREGION;
        }
        private set;
    }	
    
}