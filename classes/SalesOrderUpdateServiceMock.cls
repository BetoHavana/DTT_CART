@isTest
public class SalesOrderUpdateServiceMock implements HttpCalloutMock{
    boolean passSuccessResponse = false;

	public SalesOrderUpdateServiceMock(Boolean passSuccessResponse)
	{
		this.passSuccessResponse = passSuccessResponse;
	}

    public HttpResponse respond(HttpRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(passSuccessResponse ? CalloutConstants.TWO_HUNDRED_AND_ONE:400);
        response.setBody(passSuccessResponse ? '{"status":"Success","code":"JNJ101","message":"Sales Order Data is successfully posted to Atlas SAP","CARTOrderId":"US-123456-0a0000001-01"}'
                        :'{"status":"Failure","message":"Bad Request","statusCode":"400"}');
        response.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
        System.assert(CalloutConstants.POST.equalsIgnoreCase(request.getMethod()),'Didnot get Expected Request');
        return response;
    }
}