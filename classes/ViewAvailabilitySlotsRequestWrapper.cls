public with sharing class ViewAvailabilitySlotsRequestWrapper
{

	public String aphSiteID;
	public String country;
	public String cryoType;
	public Integer dateRange;
	public String startDate;
	public String product;
	public String therapyType;
	public String treatmentSiteID;
	public String region;
	public String requestType;

	public ViewAvailabilitySlotsRequestWrapper(Map<String, Object> masterMap)
	{
		this.aphSiteID = (String) masterMap.get('apheresisSiteId');
		this.country = (String) masterMap.get('country');
		this.cryoType = (String) masterMap.get('cryoType');
		this.dateRange = (Integer) masterMap.get('dateRange');
		this.startDate = String.valueOf((Date) masterMap.get('startDate'));
		this.product = (String) masterMap.get('product');
		this.therapyType = (String) masterMap.get('therapyType');
		this.treatmentSiteID = (String) masterMap.get('treatmentSiteId');
		this.region = (String) masterMap.get('region');
		this.requestType = (String) masterMap.get('requestType');

	}
}