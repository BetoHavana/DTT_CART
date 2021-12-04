@isTest
global class SlotAvailabilityHttpCalloutMock implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest request) {
        HttpResponse response = new HttpResponse();
		if (request.getBody() == 'Patient')
        {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"status":"Success","code":"JNJ101","message":"successfully","statusCode":"US-123456-0a0000001-01"}');
        }
        else
        {
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"errorCode":"JNJ001","errorMessage":"Error while connecting to DB","numberOfRecords":0,"cryoSiteId":"CRY1234"}');
        }

        response.setStatusCode(200);
        return response;
    }
}