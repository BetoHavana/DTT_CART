@isTest
public class AnaplanNotificationServiceMock implements HttpCalloutMock
{
	boolean passSuccessResponse = false;

	public AnaplanNotificationServiceMock(Boolean passSuccessResponse)
	{
		this.passSuccessResponse = passSuccessResponse;
	}

	public HttpResponse respond(HttpRequest request)
	{
		HttpResponse response = new HttpResponse();
		response.setStatusCode(passSuccessResponse ? 201 : 400);
		response.setBody(passSuccessResponse ? '{"status":"Success","code":"JNJ101","message":"Milestone Update Request Received","CARTOrderId":"US-123456-0a0000001-01"}'
				: '{"status":"Failure","message":"Bad Request","statusCode":"400"}');
		response.setHeader('Content-Type', 'application/json');
		return response;
	}
}
