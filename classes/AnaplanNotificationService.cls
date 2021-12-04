public with sharing class AnaplanNotificationService
{
	private static final String COMMERCIAL = 'Commercial';
	private static final String FAILURESTATUS = 'Failure';
	private static final String LOCAL = 'Local';
	private static final String NA = 'NA';
	private static final String PUT = 'PUT';
	private static final String RARITAN = 'Raritan';
	private static final String SHIPMENT = 'Shipment';
	private static final String THIRDPARTY = '3rd party';
	private static final String US = 'US';

	public void sendApheresisShipmentNoticeToAnaplan(Set<Id> orderIds)
	{
		HttpRequest req = new HttpRequest();
		req.setMethod(PUT);
		req.setEndpoint('callout:ShipmentAndMilestoneManufacturing');
		req.setHeader('Content-Type', 'application/json;');
		req.setHeader('client_id', '{!$Credential.UserName}');
		req.setHeader('client_secret', '{!$Credential.Password}');
		req.setTimeout(Integer.valueOf(Label.RequestTimeout));
		List<Order__c> listOrders = (List<Order__c>) Application.Selector.selectById(orderIds);
		if (listOrders.isEmpty()) return ;

		HttpResponse resp = new HttpResponse();
		Http httpProtocol = new Http();

		for (Order__c order : listOrders)
		{
			AphShipNoticeRequestWrapper requestWrapper = new AphShipNoticeRequestWrapper(order);
			String jsonStr = JSON.serialize(requestWrapper);
			req.setBody(jsonStr);
			if (req == null) return ;
			try
			{
				resp = httpProtocol.send(req);
				AphShipNoticeResponseWrapper output = (AphShipNoticeResponseWrapper) JSON.deserialize(resp.getBody(), AphShipNoticeResponseWrapper.class);
				order.ASNToAnaplanStatus__c = FAILURESTATUS;
				if (checkCalloutStatus(resp.getStatusCode(), output))
				{
					order.ASNToAnaplanStatus__c = CalloutConstants.SUCCESS;
				}
				else
				{
					Application.logEntry.error(string.format('{0} : {1}', new List<String> {output.code, output.message}));
				}
				System.debug('INT 13 Request ' + req.getBody());
				System.debug('INT 13 Response' + resp.getBody());
			}
			catch (Exception e)
			{
				Application.logEntry.error(e);
			}
			System.debug('INT 13 Request: ' + req.getBody());
			System.debug('INT 13 Response:' + resp.getBody());
		}

		if (!listOrders.isEmpty())
		{
			fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Order__c.SObjectType});
			uow.registerDirty(listOrders);
			uow.commitWork();
		}
	}
	boolean checkCalloutStatus(Integer statusCode, AphShipNoticeResponseWrapper output)
	{
		return CalloutConstants.TWOHUNDRED == statusCode && output != null && CalloutConstants.SUCCESS.equalsIgnoreCase(output.status);
	}

	public class AphShipNoticeRequestWrapper
	{
		String CARTOrderId;
		String status;
		String eventDate;
		String eventType;
		String therapyType;
		String country;
		String region;

		String getEventDate(Order__c order)
		{
			String pickupDate = '' ;
			if (((RARITAN.equalsIgnoreCase(order.CryoSiteType__c)) || (THIRDPARTY.equalsIgnoreCase(order.CryoSiteType__c))) &&
					order.FreshCellPickupDateAndTime__c != null)
			{
				pickupDate = String.valueOf(order.FreshCellPickupDateAndTime__c.date());
			}
			else if (LOCAL.equalsIgnoreCase(order.CryoSiteType__c) && order.CryoCellPickupDateAndTime__c != null)
			{
				pickupDate = String.valueOf(order.CryoCellPickupDateAndTime__c.date());
			}
			return pickupDate;
		}

		public AphShipNoticeRequestWrapper(Order__c Orders)
		{
			this.CARTOrderId = String.valueOf(Orders.CartOrderId__c);
			this.status = String.valueOf(Orders.OrderStatus__c);
			this.eventDate = getEventDate(Orders);
			this.eventType = SHIPMENT;
			this.therapyType = COMMERCIAL;
			this.country = US;
			this.region = NA;
		}
	}

	public class AphShipNoticeResponseWrapper
	{
		public String code { get; set; }
		public String message { get; set; }
		public String status { get; set; }
		public String CARTOrderID { get; set; }

		public AphShipNoticeResponseWrapper()
		{
			// Empty Constructor
		}

		public AphShipNoticeResponseWrapper(JSONParser parser)
		{
			while (parser.nextToken() != System.JSONToken.END_OBJECT)
			{
				if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME)
				{
					String text = parser.getText();
					if (parser.nextToken() != System.JSONToken.VALUE_NULL)
					{
						switch on text
						{
							when 'code'
							{
								code = parser.getText();
							}
							when 'message'
							{
								message = parser.getText();
							}
							when 'CARTOrderId'
							{
								CARTOrderID = parser.getText();
							}
							when 'status'
							{
								status = parser.getText();
							}
						}
					}
				}
			}
		}

		public AphShipNoticeResponseWrapper parse(String json)
		{
			System.JSONParser parser = System.JSON.createParser(json);
			return new AphShipNoticeResponseWrapper(parser);
		}
	}
}
