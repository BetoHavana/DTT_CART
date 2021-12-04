public with sharing class PatientsWrapper
{
	public String alerts { get; set; }
	public String apheresisCryoType { get; set; }
	public Date apheresisPickupDate { get; set; }
	public String apheresisPickupSite { get; set; }
	public String apheresisPickupStatus { get; set; }
	public String apheresisSitePO { get; set; }
	public String carePlanStatus { get; set; }
	public String cartCoordinator { get; set; }
	public Date confirmedFPDeliveryDate { get; set; }
	public String cryoType { get; set; }
	public String deliveryStatus { get; set; }
	public Date estimatedDrugProductDeliveryDate { get; set; }
	public String infusionStatus { get; set; }
	public Date infusionDate { get; set; }
	public Boolean isApheresisCompleted { get; set; }
	public Boolean isDeliveryCompleted { get; set; }
	public Boolean isInfusionCompleted { get; set; }
	public Boolean isManufacturingCompleted { get; set; }
	public Boolean isPatientTreatingMilestoneActive { get; set; }
	public Boolean isShippingCompleted { get; set; }
	public String manufacturingStatus { get; set; }
	public Date memberDateOfBirth { get; set; }
	public String memberFirstName { get; set; }
	public Id memberId { get; set; }
	public String memberLastName { get; set; }
	public String memberMRN { get; set; }
	public String memberName { get; set; }
	public String memberPhone { get; set; }
	public String patientEmail { get; set; }
	public String patientId { get; set; }
	public String patientJourneyStatus { get; set; }
	public String patientPreferredMethodOfCommunication { get; set; }
	public String patientPrimaryContactType { get; set; }
	public String patientStatus { get; set; }
	public String patientTreatingMilestone { get; set; }
	public Date projectedDeliveryDate { get; set; }
 	public String shippingStatus { get; set; }
	public String treatingPhysician { get; set; }
	public String orderStatus{ get; set; }
	public Date orderCancellationRequestDate{ get; set; }
	public void setMemberName(String lastName, String middleName, String firstName)
	{
		if (String.isblank(middleName))
		{
			memberName = lastName + ', ' + firstName;
		}
		else
		{
			memberName = lastName + ', ' + firstName + ' ' + middleName;
		}
	}

}
