public with sharing class AvailabilityCalendarController
{
	public static final String APHERESISSITE = 'Apheresis Site';

	@AuraEnabled(cacheable=true)
	public static List<HealthCloudGA__AccountAccountRelation__c> fetchApheresisSites(Id accountId)
	{
		try
		{
			return ((AccountAccountRelationSelector) Application.Selector.newInstance(HealthCloudGA__AccountAccountRelation__c.SObjectType))
					.elevatedSelectByAccountIdsAndRoles(new Set<Id> {accountId},new Set<String> {APHERESISSITE});
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled(cacheable=true)
	public static String getSlotSchedulingStepDetails()
	{
		try
		{
			List<PatientEnrollmentSteps__mdt> formFields =
					((PatientEnrollmentStepsSelector) Application.Selector.newInstance(PatientEnrollmentSteps__mdt.SObjectType))
							.selectSlotSchedulingSteps();
			return JSON.serialize(formFields);
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}


			}
