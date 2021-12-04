public inherited sharing class FilterApheresisSlots
{
	static final String NUMBEROFBUSINESSDAYEXCLUDED = 'Number Of Business Days Excluded';
	static final String ERRORCODECHECK = 'errorCode';

	public String filterApheresisSlots(String response)
	{
		if (response.containsIgnoreCase(ERRORCODECHECK))
		{
			return response;
		}

		sflib_Settings__c numberOfBusinessDaysNotAllowed = sflib_Settings__c.getValues(NUMBEROFBUSINESSDAYEXCLUDED);
		Date dateNotAllowed = Date.today().addDays(integer.ValueOf(numberOfBusinessDaysNotAllowed.Value__c));
		String filteredResponse = '';

		ApheresisSlots apheresisSlotsFromAnaplan = (ApheresisSlots) JSON.deserialize(response, ApheresisSlots.class);
		ApheresisSlots apheresisSlotsFiltered = new ApheresisSlots();
		List<FilterApheresisSlots.Slot> filteredSlots = new List<FilterApheresisSlots.Slot>();

		apheresisSlotsFiltered.status = apheresisSlotsFromAnaplan.status;
		apheresisSlotsFiltered.code = apheresisSlotsFromAnaplan.code;
		apheresisSlotsFiltered.message = apheresisSlotsFromAnaplan.message;
		apheresisSlotsFiltered.numberOfRecords = apheresisSlotsFromAnaplan.numberOfRecords;

		if (!apheresisSlotsFromAnaplan.slots.isEmpty())
		{
			for (FilterApheresisSlots.Slot apheresisSlot : apheresisSlotsFromAnaplan.slots)
			{
				if (Date.valueOf(apheresisSlot.apheresisPickUpDate) > dateNotAllowed)
				{
					filteredSlots.add(apheresisSlot);
				}
			}
		}

		if (!filteredSlots.isEmpty())
		{
			apheresisSlotsFiltered.Slots = filteredSlots;
		}

		filteredResponse = JSON.serialize(apheresisSlotsFiltered);

		return filteredResponse;
	}

	public inherited sharing class ApheresisSlots
	{
		public String status { get; set; }
		public String code { get; set; }
		public String message { get; set; }
		public Integer numberOfRecords { get; set; }
		public List<FilterApheresisSlots.Slot> slots { get; set; }
	}

	public inherited sharing class Slot
	{
		public String apheresisPickUpDate { get; set; }
		public String firstDayShipmentWindow { get; set; }
		public String lastDayShipmentWindow { get; set; }
		public String projectedDeliveryDate { get; set; }
	}

}
