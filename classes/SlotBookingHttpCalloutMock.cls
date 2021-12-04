@isTest
public class SlotBookingHttpCalloutMock implements HttpCalloutMock
{
	private Integer code;
	String status;
	private String bodyAsString;
	private Map<String, String> responseHeaders;
	public SlotBookingHttpCalloutMock(Integer code, String status, String reqBody, Map<String, String> headers)
	{
		this.code = code;
		this.status = status;
		this.bodyAsString = reqBody;
		this.responseHeaders = headers;
	}

	public HTTPResponse respond(HTTPRequest request)
	{
		HttpResponse response = new HttpResponse();
		if (responseHeaders != null)
		{
			for (String key : responseHeaders.keySet())
			{
				response.setHeader(key, responseHeaders.get(key));
			}
		}
		response.setBody(bodyAsString);
		response.setStatusCode(code);
		return response;
	}
}