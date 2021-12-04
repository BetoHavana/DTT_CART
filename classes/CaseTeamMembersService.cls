public with sharing class CaseTeamMembersService
{
	public void elevatedAddCaseTeamMember(fflib_ISObjectUnitOfWork elevatedUnitOfWork, Map<Id, Id> memberIdByCaseId, Id roleId)
	{
		new ElevatedContextDML().elevatedAddCaseTeamMember(elevatedUnitOfWork, memberIdByCaseId, roleId);
		elevatedUnitOfWork.commitWork();
	}

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void eventPublish(List<SObject> objList)
		{
			//not implemented
		}

		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}
			Database.emptyRecycleBin(objList);
		}

		private void elevatedAddCaseTeamMember(fflib_ISObjectUnitOfWork unitOfWork, Map<Id, Id> memberIdByCaseId, Id roleId)
		{
			if (memberIdByCaseId.isEmpty()) return;
			List<CaseTeamMember> caseTeamList = new List<CaseTeamMember>();
			for (Id caseId : memberIdByCaseId.keySet())
			{
				CaseTeamMember careTeamMember = new CaseTeamMember();
				careTeamMember.MemberId = memberIdByCaseId.get(caseId);
				careTeamMember.ParentId = caseId;
				careTeamMember.TeamRoleId = roleId;
				caseTeamList.add(careTeamMember);
			}
			unitOfWork.registerNew(caseTeamList);
		}
	}

}