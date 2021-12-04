public with sharing class PatientServicesEnrolleesController  
{
	public Id pseId { get; set { pseId = value; getPseData();} }
	public Id patientId { get; set;}
	public List<HealthCloudGA__ContactContactRelation__c> contactContactRelationsList { get; set;}
	public List<AssociatedLocation> treatmentSiteList { get; set;}
	public String cartCoordinatorName { get; set;}
	public String treatmentSiteName { get; set;}
	public String treatmentSiteAddress { get; set;}
    
    public Id getPseData()
    {
        PatientServicesEnrolleesService service = (PatientServicesEnrolleesService) Application.Service
													.newInstance(PatientServicesEnrolleesService.class);
		patientId = service.getPatientIdForEmailTemplate(pseId);
		contactContactRelationsList = service.getRelatedContactForEmailTemplate(patientId);
		treatmentSiteList = service.getTreatmentSiteForEmailTemplate(contactContactRelationsList);

		if(String.isNotBlank(contactContactRelationsList[0].HealthCloudGA__Contact__r.Name))
		{
			this.cartCoordinatorName = contactContactRelationsList[0].HealthCloudGA__Contact__r.Name;
		}

		if(String.isNotBlank(treatmentSiteList[0].ParentRecord.Name) && String.isNotBlank(treatmentSiteList[0].Address__c))
		{
			this.treatmentSiteName = treatmentSiteList[0].ParentRecord.Name;
			this.treatmentSiteAddress = treatmentSiteList[0].Address__c;
		}
		
		return patientId;
	}
}