public without sharing class ApheresisSlotService
{
	private static final String FAILURE = 'Failure';
	private static final String SUCCESS = 'Success';
	private static final String JNJ101 = 'JNJ101';

	public String getSlotAvailability(String jsonStr)
	{
		HttpRequest req = new HttpRequest();
		HttpResponse resp = new HttpResponse();
		req.setMethod('POST');
		req.setEndpoint('callout:AphSlotAvailability');
		req.setHeader('Content-Type', 'application/json;');
		req.setHeader('client_id', '{!$Credential.UserName}');
		req.setHeader('client_secret', '{!$Credential.Password}');
		req.setBody(jsonStr);
		req.setTimeout(120000);
		Http httpProtocol = new Http();
		resp = httpProtocol.send(req);

		if (resp.getStatusCode() == 200 || resp.getStatusCode() == 400)
		{
			ViewAvailabilitySlotsResponseWrapper respWrapper = ViewAvailabilitySlotsResponseWrapper.parse(resp.getBody());

			if(respWrapper.status == SUCCESS && respWrapper.code == JNJ101){
				System.debug('Successful Response = ' + resp.getBody());

			}else if(respWrapper.status == FAILURE){
				String logEntrycodeNMessage = respWrapper.status + ' : ' + respWrapper.statusCode + ':'+ respWrapper.message;
				Application.logEntry.error(logEntrycodeNMessage);

			}
		}
		Application.logEntry.info('INT 01 Response' + resp.getBody());
		return resp.getBody();
	}

}
