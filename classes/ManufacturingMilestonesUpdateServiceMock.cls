@isTest
public class ManufacturingMilestonesUpdateServiceMock implements HttpCalloutMock
{
    
    boolean passSuccessResponse = false;
	public ManufacturingMilestonesUpdateServiceMock(Boolean passSuccessResponse)
	{
        this.passSuccessResponse = passSuccessResponse;
	}
    
    public HttpResponse respond(HttpRequest request)
    {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(passSuccessResponse ? CalloutConstants.TWOHUNDRED:400);
        response.setBody(passSuccessResponse ? '{"status":"Success","code":"JNJ101","message":"Milestone Update Request Received","CARTOrderId":"ORD-0874"}'
                        :'{"status":"Failure","message":"Bad Request","statusCode":"400"}');
        response.setHeader(CalloutConstants.CONTENT_TYPE, CalloutConstants.APPLICATIONSLASHJSON);
        System.assert(CalloutConstants.PUT.equalsIgnoreCase(request.getMethod()),'Didnot get Expected Request');
        return response;
    }

}