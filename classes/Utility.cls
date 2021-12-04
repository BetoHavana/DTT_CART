public with sharing class Utility
{
	static final String INSERTIONFAILEDWITHFOLLOWINGERRORS = ' Insertion failed with Following Errors : ';
	
	public Map<Id, Set<String>> getChangedFieldsPerRecord(Set<Schema.SObjectField> fieldsList, Map<Id, sObject> oldRecords, List<Sobject> newRecords)
	{
		Map<Id, Set<String>> recordNChangedFieldsMap = new Map<Id, Set<String>>();
		for (SObject newRecord : newRecords)
		{
			Id recordId = (Id) newRecord.get('Id');
			if (oldRecords == null || !oldRecords.containsKey(recordId))
			{
				continue;
			}

			SObject oldRecord = oldRecords.get(recordId);
			for (Schema.SObjectField fieldName : fieldsList)
			{
				if (oldRecord.get(fieldName) != newRecord.get(fieldName))
				{
					if (recordNChangedFieldsMap.containsKey(newRecord.Id))
					{
						recordNChangedFieldsMap.get(newRecord.Id).add(string.valueOf(fieldName));
					}
					else
					{
						recordNChangedFieldsMap.put(newRecord.Id, new Set<String> {string.valueOf(fieldName)});
					}
				}
			}
		}
		return recordNChangedFieldsMap;
	}

    public Boolean getIfExecutionContextInAsync()
    {
        return system.isBatch() || system.isFuture() || system.isQueueable() || system.isScheduled();
    }

	public void insertSObjects(List<SObject> sObjectRecords,Schema.SObjectType sObjectName)
	{
		try
		{
			if(sObjectRecords.isEmpty()) return ;

			Database.SaveResult[] saveResultInfo = Database.insert(sObjectRecords,false);
			handleSaveResult(saveResultInfo,String.valueOf(sObjectName));
		}
		catch(Exception excp)
		{
			Application.logEntry.Error(excp);
		}
	}

	void handleSaveResult(Database.SaveResult[] saveResultInfo,String sOjbectName)
	{
		for(Database.SaveResult saveResult : saveResultInfo)
		{
			if(saveResult.isSuccess()) continue;

			Application.logEntry.error(getErrorMessageFromErrorInfo(saveResult.getErrors(),SOjbectName));
		}
	}

	String getErrorMessageFromErrorInfo(Database.Error[] errors,String sOjbectName)
	{
		String finalErrorMessage = '';
		for(Database.Error error : errors)
		{
			finalErrorMessage += error.getMessage() + StaticConstants.COMMA;
		}
		return SOjbectName+ INSERTIONFAILEDWITHFOLLOWINGERRORS + finalErrorMessage.removeEnd(StaticConstants.COMMA);
	}

}