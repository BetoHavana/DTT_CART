public with sharing class ViewAvailabilitySlotsController
{
	static final String RESCHEDULE = 'Reschedule';
	static final Integer SEVEN = 7;
	static final Integer ZERO = 0;

	@AuraEnabled
	public static String getAvailableSlots(String cryoType, String apheresisSiteERP,
			Id treatmentSiteId, Id patientId, String requestType,
			String orderApheresisPickUpDate)
	{
		try
		{
			Map<String, Object> requestMap = getCurrentDateRequest(cryoType, apheresisSiteERP,
					 treatmentSiteId,
					patientId, requestType,
					orderApheresisPickUpDate);
			String jsonBody = JSON.serialize(requestMap);
			Application.logEntry.info('INT 01 Request' + jsonBody);
			return new FilterApheresisSlots().filterApheresisSlots(new ApheresisSlotService().getSlotAvailability(jsonBody));
		}
		catch (Exception excp)
		{
			Application.logEntry.error(excp);
			AuraHandledException auraHandledException = new AuraHandledException(excp.getMessage());
			auraHandledException.setMessage(excp.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static Map<String, Object> getCurrentDateRequest(String cryoType, String apheresisSiteERP,
			 Id treatmentSiteId,
			Id patientId, String requestType,
			String aphPickUpDate)
	{
		String defaultTheraphyType = 'Commercial';
		String defaultProduct = 'JNJ-4528';
		String defaultCountry = 'US';
		String defaultRegion = 'North America';

		Integer dateRange = 60;
		Map<String, Object> masterMap = new Map<String, Object>();
		masterMap.put('startDate', Date.today());
		masterMap.put('rangeInDays', dateRange);
		masterMap.put('cryoType', cryoType);
		masterMap.put('apheresisSiteId', apheresisSiteERP);
		if (patientId != null)
		{
			masterMap.put('therapyType', defaultTheraphyType);
			masterMap.put('product', defaultProduct);
		}
		else
		{
			masterMap.put('therapyType', defaultTheraphyType);
			masterMap.put('product', defaultProduct);
		}
		if (treatmentSiteId != null)
		{
			masterMap.put('country', defaultCountry);
			masterMap.put('region', defaultRegion);
		}
		else
		{
			masterMap.put('country', defaultCountry);
			masterMap.put('region', defaultRegion);
		}
		masterMap.put('requestType', requestType);
		addRescheduleRequest(requestType, aphPickUpDate, masterMap);
		return masterMap;
	}

	static void addRescheduleRequest(String requestType, String aphresisPickUpDate, Map<String, Object> requestInfo)
	{
		if (RESCHEDULE.equalsIgnoreCase(requestType) && string.isNotBlank(aphresisPickUpDate))
		{
			Integer bufferRangeInDays = checkIFApheresisPickUpDateIsAWeekAhead(Date.valueOf(aphresisPickUpDate)) ? ZERO : SEVEN;
			requestInfo.put('requestType', requestType);
			requestInfo.put('apheresisDate', aphresisPickUpDate);
			requestInfo.put('bufferRangeInDays', bufferRangeInDays);
		}
	}

	static Boolean checkIFApheresisPickUpDateIsAWeekAhead(Date aphresisPickUpDate)
	{
		return aphresisPickUpDate > Date.today().addDays(SEVEN);
	}
}
