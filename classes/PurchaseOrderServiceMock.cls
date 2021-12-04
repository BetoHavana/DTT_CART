@isTest
public class PurchaseOrderServiceMock implements HttpCalloutMock
{
	Boolean passSuccessResponse = false;

	public PurchaseOrderServiceMock(Boolean passSuccessResponse)
	{
		this.passSuccessResponse = passSuccessResponse;
	}

	public HttpResponse respond(HttpRequest request)
	{
		HttpResponse response = new HttpResponse();
		response.setStatusCode(passSuccessResponse ? 200 : 400);
		response.setBody(passSuccessResponse ? '{"status":"Success","code":"JNJ101","message":"QTC Purchase Order Request Received","CARTOrderId":"US-123456-0a0000001-01"}'
				: '{"status":"Failure","message":"Bad Request","statusCode":"400"}');
		response.setHeader('Content-Type', 'application/json');
		return response;
	}
}
