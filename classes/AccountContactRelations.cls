public with sharing class AccountContactRelations extends fflib_SObjectDomain
{

    public AccountContactRelations(List<SObject> records)
    {
        super(records, AccountContactRelation.SObjectType);
    }

        private AccountContactRelationsService Service
    {
        get
        {
            if (null == Service)
            {
                Service = (AccountContactRelationsService) Application.Service.newInstance(AccountContactRelationsService.class);
            }
            return Service;
        }
        set;
    }

    public Type getType()
    {
        return AccountContactRelations.class;
    }

    public override void onAfterInsert()
    {
        Service.grantAccessToRelatedPublicGroups(this);
    }

    public override void onAfterUpdate(Map<Id, SObject> existingRecords)
    {
        Service.grantAccessToRelatedPublicGroups(this);
    }

    public class Constructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new AccountContactRelations(sObjectList);
        }

        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return construct(sObjectList);
        }
    }

}