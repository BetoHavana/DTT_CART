public inherited sharing class SlotAndOrderUpdateInfo
{
	public Id orderId { get; set; }
	public Id patientId { get; set; }
	public String apheresisSiteERPId { get; set; }
	public String apheresisSiteId { get; set; }
	public String aphPickUpDate { get; set; }
	public String projectedDeliveryDate { get; set; }
	public String cryoType { get; set; }
	public String cryoSiteERPSiteId { get; set; }
	public Order__c order { get; set; }
	public String requestType { get; set; }
	public String reasonForReschedule { get; set; }
	public String reason { get; set; }
	public String sitePO { get; set; }
	public String sourceOfRequest { get; set; }
	public String therapyType { get; set; }
}
