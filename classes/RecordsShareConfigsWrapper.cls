public class RecordsShareConfigsWrapper {
    public String accessLevel {get;set;}
    public String groupName {get;set;}
    public Id recordId {get;set;}
    
    public RecordsShareConfigsWrapper(String accessLevel, String groupName, Id recordId)
    {
        this.accessLevel = accessLevel;
        this.groupName = groupName;
        this.recordId = recordId;
    }
}
