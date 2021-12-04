public with sharing class ViewAvailabilitySlotsResponseWrapper
{
	public String status { get; set; }
	public String message { get; set; }
	public string statusCode {get;set;}
	public string code {get;set;}

	public ViewAvailabilitySlotsResponseWrapper(JSONParser parser)
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
						when 'status'
						{
							status = parser.getText();
						}
						when 'message'
						{
							message = parser.getText();
						}
						when 'statusCode'
						{
							statusCode = parser.getText();
						}
						when 'code'
						{
							code = parser.getText();
						}
						when else
						{
							consumeObject(parser);
						}
					}
				}
			}
		}
	}

	public static ViewAvailabilitySlotsResponseWrapper parse(String json)
	{
		System.JSONParser parser = System.JSON.createParser(json);
		return new ViewAvailabilitySlotsResponseWrapper(parser);
	}

	public static void consumeObject(System.JSONParser parser)
	{
		Integer depth = 0;
		do
		{
			System.JSONToken curr = parser.getCurrentToken();
			if (curr == System.JSONToken.START_OBJECT ||
					curr == System.JSONToken.START_ARRAY)
			{
				depth++;
			}
			else if (curr == System.JSONToken.END_OBJECT ||
					curr == System.JSONToken.END_ARRAY)
			{
				depth--;
			}
		}
		while (depth > 0 && parser.nextToken() != null);
	}
}