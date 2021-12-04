public with sharing class OrdersShipmentService {
    private OrdersShipmentService() {}
    private static final String FAILURE_STATUS = 'Failure';

    @Future(Callout=true)
    public static void postOrderShipmentService(set<Id> orderIds)
    {
        HttpRequest req = new HttpRequest();
        req.setMethod('POST');
        req.setEndpoint('callout:ShipmentDateToSAP');
        req.setHeader('Content-Type', 'application/json;');
        req.setHeader('client_id', '{!$Credential.UserName}');
        req.setHeader('client_secret', '{!$Credential.Password}');
        req.setTimeout(Integer.ValueOf(Label.RequestTimeout));
        List<Order__c> listOrders = (List<Order__c>) Application.Selector.selectById(orderIds);
        for(Order__c order : listOrders){
            ShipmentDateToSAPRequestWrapper RequestWrapper  = new ShipmentDateToSAPRequestWrapper(order);
            String jsonStr = JSON.serialize(requestWrapper);
            req.setBody(jsonStr);
            try
            {
                HttpResponse resp = new HttpResponse();
                Http httpProtocol = new Http();
                resp = httpProtocol.send(req);
                ShipmentDateToSAPResponseWrapper responseWrapper = new ShipmentDateToSAPResponseWrapper();
                ShipmentDateToSAPResponseWrapper respWrapper = responseWrapper.parse(resp.getBody());
                order.DPOkToShipToSAPStatus__c = respWrapper.status;

                if (respWrapper.status == FAILURE_STATUS)
                {
                    String logEntrycodeNMessage = respWrapper.code + ' : ' + respWrapper.message;
                    Application.logEntry.error(logEntrycodeNMessage);
                }
                System.debug('Request## '+req.getBody());
                System.debug('Response## '+resp.getBody());
            } catch (Exception e){
                order.DPOkToShipToSAPStatus__c = FAILURE_STATUS;
                String logEntrycodeNMessage = e.getLineNumber() + ' : ' + e.getMessage();
                Application.logEntry.error(logEntrycodeNMessage);
            }
        }
        if(!listOrders.isempty()){
            fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new Schema.SObjectType[] {Order__c.SObjectType});
            uow.registerDirty(listOrders);
            uow.commitWork();
        }
    }

    public class ShipmentDateToSAPRequestWrapper{
        String CARTOrderId;
        String salesOrderNo;
        String shipDateTimeInUTC;

        public ShipmentDateToSAPRequestWrapper(Order__c Orders)
        {
            this.CARTOrderId = String.valueOf(Orders.CartOrderId__c);
            this.salesOrderNo = String.valueOf(Orders.AtlasOrderId__c);
            if (Orders.ConfirmedFPDeliveryDate__c != null)
            {
                this.shipDateTimeInUTC = formatDateToUTC(Orders.ConfirmedFPDeliveryDate__c);
            }
        }

        public String formatDateToUTC(Date dateToFormat){
            DateTime dateFormatter = DateTime.newInstance(dateToFormat.Year(), dateToFormat.month(), dateToFormat.day());
            return dateFormatter.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        }
    }

    public class ShipmentDateToSAPResponseWrapper
    {
        public String code { get; set; }
        public String message { get; set; }
        public String status { get; set; }
        public String CARTOrderID { get; set; }

        private ShipmentDateToSAPResponseWrapper(){}

        public ShipmentDateToSAPResponseWrapper(JSONParser parser)
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
                                CARTOrderId = parser.getText();
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

        public ShipmentDateToSAPResponseWrapper parse(String json)
        {
            System.JSONParser parser = System.JSON.createParser(json);
            return new ShipmentDateToSAPResponseWrapper(parser);
        }

    }
}
