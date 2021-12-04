@isTest
public class OrdersShipmentServiceMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"status": "Success","code": "JNJ101","message": "Ship Release Data is successfully posted to Atlas SAP","CARTOrderId": "USCO-O-00000001-01"}');
        res.setStatusCode(201);
        return res;
    }   
}