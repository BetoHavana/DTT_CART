public class GoogleAPIMockHttpResponse implements HttpCalloutMock
{
	public string apiCallType;
	public GoogleAPIMockHttpResponse(String apiCallType)
	{
		this.apiCallType = apiCallType;
	}
	public HTTPResponse respond(HTTPRequest req)
	{
		String responseBody = null;
		if ('autocompleteAPI'.equalsIgnoreCase(apiCallType))
		{
			responseBody = '{"predictions" : [ { "description" : "1122 Lois Lane, Independence, KS, USA",' +
					'"id" : "a65ae48e7e344c4decb5b4fe6892d3b4be66cf0b", "matched_substrings" : [ { "length" :' +
					'4, "offset" : 0 } ], "place_id" : "ChIJ55Of1dEquIcRAOuraYBeznU", "reference" :' +
					' "ChIJ55Of1dEquIcRAOuraYBeznU", "structured_formatting" :' +
					' { "main_text" : "1122 Lois Lane", "main_text_matched_substrings" : [ { "length" : 4,' +
					'"offset" : 0 } ], "secondary_text" : "Independence, KS, USA" },' +
					'"terms" : [ { "offset" : 0, "value" : "1122" }, { "offset" : 5, "value" : "Lois Lane" },' +
					'{ "offset" : 16, "value" : "Independence" }, { "offset" : 30, "value" : "KS" },' +
					'{ "offset" : 34, "value" : "USA" } ], "types" : [ "street_address", "geocode" ] } ], "status" : "OK" }';
		}
		else
		{
			responseBody = '{ "html_attributions" : [], "result" : { "address_components" : [' +
					'{ "long_name" : "1122", "short_name": "1122", "types" : [ "street_number" ] },' +
					'{ "long_name" : "Lois Lane", "short_name" : "Lois Ln", "types" : [ "route" ] },' +
					'{ "long_name" : "Independence", "short_name" : "Independence", "types" : [ "locality", "political" ] }, ' +
					'{ "long_name" : "neighborhood", "short_name" : "neighborhood", "types" : [ "neighborhood"] }, ' +
					'{ "long_name" : "Independence", "short_name" : "Independence", "types" : [ "administrative_area_level_3", "political" ] },' +
					'{ "long_name" : "Montgomery County", "short_name" : "Montgomery County", "types" : [ "administrative_area_level_2", "political" ] },' +
					'{ "long_name" : "Kansas", "short_name" : "KS", "types" : [ "administrative_area_level_1", "political" ] }, ' +
					'{ "long_name" : "United States", "short_name" : "USA", "types" : [ "country", "political" ] },' +
					'{ "long_name" : "67301", "short_name" : "67301", "types" : [ "postal_code" ] } ],' +
					' "name" : "1122 Lois Ln", "place_id" : "ChIJ55Of1dEquIcRAOuraYBeznU" }, "status" : "OK" }';
		}
		System.assertEquals('GET', req.getMethod());
		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(responseBody);
		res.setStatusCode(200);
		return res;
	}
}