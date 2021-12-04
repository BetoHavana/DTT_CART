public with sharing class RecordShareConfigSelector extends fflib_SObjectSelector
{
    static final String IS_ACTIVE = RecordShareConfig__mdt.IsActive__c.getDescribe().getName();

    public static List<RecordShareConfig__mdt> recordShareConfigs
    {
        get
        {
            if (recordShareConfigs == null)
            {
                recordShareConfigs = ((RecordShareConfigSelector) Application.Selector.newInstance(getObjectType()))
                                              .selectAllActiverecordShareConfigs();
            }
            return recordShareConfigs;
        }
        private set;
    }

    public sObjectType getSobjectType()
    {
        return RecordShareConfig__mdt.sObjectType;
    }

    public static sobjectType getObjectType()
    {
        return RecordShareConfig__mdt.sObjectType;
    }

    public List<sObjectField> getSObjectFieldList()
    {
        return new List<sObjectField>
        {
                RecordShareConfig__mdt.GroupName__c,
                RecordShareConfig__mdt.ProductName__c,
                RecordShareConfig__mdt.AccessLevel__c
        };
    }

    public List<RecordShareConfig__mdt> selectAllActiverecordShareConfigs()
    {
        return selectActive(true);
    }

    private List<RecordShareConfig__mdt> selectActive(Boolean isActive)
    {
        fflib_QueryFactory queryFactory = newQueryFactory();
        queryFactory.setCondition(IS_ACTIVE + ' = :IsActive');
        return (List<RecordShareConfig__mdt>) Database.query(queryFactory.toSOQL());
    }

    public Map<String, List<RecordShareConfig__mdt>> selectRecShareConfigsGrpByPName()
    {
        Map<String, List<RecordShareConfig__mdt>> shareConfigPerPName = new Map<String, List<RecordShareConfig__mdt>>();
        for (RecordShareConfig__mdt config : recordShareConfigs)
        {
            if (!shareConfigPerPName.containsKey(config.ProductName__c))
            {
                shareConfigPerPName.put(config.ProductName__c, new List<RecordShareConfig__mdt> {config});

            }
            shareConfigPerPName.get(config.ProductName__c).add(config);
        }
        return shareConfigPerPName;
    }
}