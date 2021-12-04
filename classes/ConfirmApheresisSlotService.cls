public inherited sharing class ConfirmApheresisSlotService
{
	static final String CONFIRMSLOTBOOKING = 'ConfirmSlotBooking';
	static final String EMPTYSTRING = '';
	static final String LOCAL = 'Local';
	static final String SLOTUNAVAILABLE = 'Slot Unavailable';
	static final String REQUESTTYPENEW = 'New';
	static final String ORDERSUBMITTED = 'Order Submitted';
	static final String ORDERRESCHEDULED = 'Order Rescheduled';
	static final String RARITAN = 'Raritan';
	static final String SLOTREQUESTED = 'Slot Requested';
	static final String TCP = 'Tcp';
	static final String THIRDPARTY = '3rd party';
	static final String YES = 'Yes';


	public String confirmApheresisSlot(SlotAndOrderUpdateInfo slotInfo)
	{
		String inputRequest = new ConfirmApheresisSlotServiceHelper().getApheresisSlotConfirmServiceRequest(slotInfo);
		HttpRequest request = new HttpRequest();
		request.setMethod(CalloutConstants.POST);
		request.setEndpoint(CalloutConstants.CALLOUTCOLON + CONFIRMSLOTBOOKING);
		request.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
		request.setHeader(CalloutConstants.CLIENT_ID, CalloutConstants.CREDENTIAL_USERNAMEMERGEFIELD);
		request.setHeader(CalloutConstants.CLIENT_SECRET, CalloutConstants.CREDENTIAL_PWDMERGEFIELD);
		request.setTimeout(CalloutConstants.CALLOUTIMEOUT);
		request.setBody(inputRequest);
		Application.logEntry.info('Request is INT-02:' + request.getBody());

		return handleServiceResponse(new Http().send(request), request.getBody(), slotInfo);
	}

	String handleServiceResponse(HttpResponse response, String request, SlotAndOrderUpdateInfo slotInfo)
	{
		Application.logEntry.info('Response is INT-02:' + response.getBody());
		String errorMessage = '';
		SlotBookingResponse slotBookingResponse;
		if (CalloutConstants.TWOHUNDRED == response.getStatusCode())
		{
			slotBookingResponse = (SlotBookingResponse) JSON.deserialize(response.getBody(), SlotBookingResponse.class);
			errorMessage = getErrorMessageIfSlotConfirmFailed(slotBookingResponse);
		}
		else
		{
			logError(request, response.getBody());
			errorMessage = Label.SlotsNotConfirmedValidationMsg;
			return errorMessage;
		}

		if (string.isBlank(errorMessage))
		{
			slotInfo.cryoSiteERPSiteId = slotBookingResponse ?.cryoSiteId;
			parseSlotInfoAndUpdateOrder(slotInfo);
		}
		return errorMessage;
	}

	String getErrorMessageIfSlotConfirmFailed(SlotBookingResponse response)
	{
		String slotConfirmationFailureMsg = '';
		if (CalloutConstants.JNJ007.equalsIgnoreCase(response.code))
		{
			slotConfirmationFailureMsg = Label.UnavailableSlotsValidationMsg;
		}
		else if (CalloutConstants.JNJ101.equalsIgnoreCase(response.code) && CalloutConstants.SUCCESS.equalsIgnoreCase(response.status))
		{
			slotConfirmationFailureMsg = slotUnavailable.equalsIgnoreCase(response.slotStatus) ? Label.SlotUnavailableMsg : '';
		}
		else
		{
			slotConfirmationFailureMsg = Label.SlotsNotConfirmedValidationMsg;
		}
		return slotConfirmationFailureMsg;
	}
	void logError(String request, String response)
	{
		Application.logEntry.error(CONFIRMSLOTBOOKING + CalloutConstants.FAILURE +
				staticconstants.REQUESTPAYLOAD + request + CalloutConstants.RESPONSE + response);
	}

	public class SlotBookingResponse
	{
		public String status { get; set; }
		public String code { get; set; }
		public String message { get; set; }
		public String slotStatus { get; set; }
		public String cryoSiteId { get; set; }
		public String slotConfirmed { get; set; }
		public String slotId { get; set; }
	}

	public void parseSlotInfoAndUpdateOrder(SlotAndOrderUpdateInfo slotInfo)
	{
		Orders orders = (Orders) Application.Domain.newInstance(new List<Order__c> {slotInfo.order});
		orders.setOrderPlacementInfo(REQUESTTYPENEW.equals(slotInfo.requestType) ? ORDERSUBMITTED : ORDERRESCHEDULED) ;
		orders.setResonForReschedule(slotInfo.reasonForReschedule);
		orders.setSpecifyResonForReschedule(slotInfo.reason);
		orders.setSlotStatus(SLOTREQUESTED);
		orders.setApheresisSite(slotInfo.apheresisSiteId);
		orders.setApheresisPickUpDate(Date.valueOf(slotInfo.aphPickUpDate));
		orders.setProjectedProductDeliveryDate(Date.valueOf(slotInfo.projectedDeliveryDate));
		orders.setCryoType(slotInfo.cryoType);
		setCryoSiteAddressInfo(orders, slotInfo.cryoSiteERPSiteId, slotInfo.cryoType);
		Boolean isSoruceTCP = TCP.equalsIgnoreCase(slotInfo.sourceOfRequest);

		if (isSoruceTCP)
		{
			orders.setSitePO(slotInfo.sitePO);
			orders.setAttestedForCompletion(YES);
		}

		OrdersService ordersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
		ordersService.updateOrderPlacementInfo(orders, isSoruceTCP);
	}

	private void wipeOffCryoSiteInfo(Orders orders)
	{
		orders.setCryoSite(null);
		orders.setCryoSitePickupAddress(EMPTYSTRING);
		orders.setCryoSiteDropOffAddress(EMPTYSTRING);
	}

	public void setCryoSiteAddressInfo(Orders orders, String cryoSiteId, String cryoTypeSelctedOnCalender)
	{
		if (String.isBlank(cryoSiteId))
		{
			if (StaticConstants.CryoSiteCentral.equals(cryoTypeSelctedOnCalender))
			{
				wipeOffCryoSiteInfo(orders);
			}
			return;
		}

		String recTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(StaticConstants.CRYOSITE).getRecordTypeId();
		List<Account> accountsList = ((AccountsSelector) Application.Selector.newInstance(Account.SobjectType))
									  .elevatedSelectByERPSiteId(cryoSiteId, recTypeId);

		if (accountsList.isEmpty() && StaticConstants.CryoSiteCentral.equals(cryoTypeSelctedOnCalender))
		{
			wipeOffCryoSiteInfo(orders);
			return ;
		}

		if (!accountsList.isEmpty() &&
				(RARITAN.equalsIgnoreCase(accountsList[0].Type) || (THIRDPARTY.equalsIgnoreCase(accountsList[0].Type))))
		{
			orders.setCryoSite(accountsList[0].Id);
			List<Schema.AssociatedLocation> associatedLocationList = ((AssociatedLocationsSelector) Application.Selector
					                                                   .newInstance(Schema.AssociatedLocation.SObjectType))
					                                                   .elevatedGetAddressesForSites(new Set<Id> {accountsList[0].Id});
			setOrderCryoSiteAddress(orders, associatedLocationList);
		}
	}

	void setOrderCryoSiteAddress(Orders orders, List<Schema.AssociatedLocation> associatedLocationList)
	{
		for (Schema.AssociatedLocation asl : associatedLocationList)
		{
			if (asl.Address__c != null)
			{
				switch on asl.Type
				{
					when 'Pickup'
					{
						orders.setCryoSitePickupAddress(asl.Address__c);
					}
					when 'Drop Off'
					{
						orders.setCryoSiteDropOffAddress(asl.Address__c);
					}
					when 'Pickup and Drop Off'
					{
						orders.setCryoSitePickupAddress(asl.Address__c);
						orders.setCryoSiteDropOffAddress(asl.Address__c);
					}
				}
			}
		}
	}

}
