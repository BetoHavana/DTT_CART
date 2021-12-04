public with sharing class CaseTeamMembers extends fflib_SObjectDomain
{
    public CaseTeamMembers(List<CaseTeamMember> records)
    {
        super(records, CaseTeamMember.SObjectType);
    }
    
    public Map<String, String> getCaseTeamMemberInfo(List<CaseTeamMember> caseTeamMembersList)
    {
        Map<String, String> caseTeamMemberMap = new Map<String, String>();
        for (CaseTeamMember ctm : caseTeamMembersList)
        {
            if (!caseTeamMemberMap.containsKey(ctm.TeamRole.Name))
            {
                caseTeamMemberMap.put(ctm.ParentId + ctm.TeamRole.Name, ctm.MemberId);
            }
        }
        
        return caseTeamMemberMap;
    }
    
    public class Constructor implements fflib_SObjectDomain.IConstructable2
    {
        public fflib_SObjectDomain construct(List<SObject> sObjectList)
        {
            return new CaseTeamMembers(sObjectList);
        }
        
        public fflib_SObjectDomain construct(List<SObject> sObjectList, SObjectType sObjectType)
        {
            return construct(sObjectList);
        }
    }
}