public with sharing class PatientTreatmentMilestonesService
{
	public List<PatientLandingPageStatusValue__mdt> getPatientStatusValues()
	{
		return ((PatientTreatmentMilestonesSelector)
				Application.Selector.newInstance(PatientLandingPageStatusValue__mdt.SObjectType))
						.selectAll();
	}

}