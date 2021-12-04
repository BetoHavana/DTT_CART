public class LookupSearchResult {
    private String id;
    private String sObjectType;
    private String icon;
    private String title;
    private String subtitle;
    private String place_id;
    
    public LookupSearchResult(
        String id,
        String sObjectType,
        String icon,
        String title,
        String subtitle,
        String place_id
    ) {
        this.id = id;
        this.sObjectType = sObjectType;
        this.icon = icon;
        this.title = title;
        this.subtitle = subtitle;
        this.place_id=place_id;
    }
    
    @AuraEnabled
    public String getId() {
        return id;
    }
    
    @AuraEnabled
    public String getSObjectType() {
        return sObjectType;
    }
    @AuraEnabled
    public String getplace_id() {
        return place_id;
    }
    
    @AuraEnabled
    public String getIcon() {
        return icon;
    }
    
    @AuraEnabled
    public String getTitle() {
        return title;
    }
    
    @AuraEnabled
    public String getSubtitle() {
        return subtitle;
    }
}