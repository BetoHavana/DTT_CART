public with sharing class CareProgramEnrolleesService
{
	private static CareProgramEnrolleesSelector careProgramEnrolleesSelector
	{
		get
		{
			if (null == careProgramEnrolleesSelector)
			{
				careProgramEnrolleesSelector = (CareProgramEnrolleesSelector) Application.Selector
							                                                  .newInstance(CareProgramEnrollee.SObjectType);
			}
			return careProgramEnrolleesSelector;
		}
		set;
	}

	public List<CareProgramEnrollee> createCareProgramEnrollee(Map<Account, CareProgram> careProgramsByAccounts)
	{
		fflib_ISObjectUnitOfWork unitOfWork = Application.UnitOfWork.newInstance();
		List<CareProgramEnrollee> careprogramEnrollees = createCareProgramEnrollee(unitOfWork, careProgramsByAccounts);
		unitOfWork.commitWork();
		return careprogramEnrollees;
	}

	public List<CareProgramEnrollee> createCareProgramEnrollee(
			fflib_ISObjectUnitOfWork unitOfWork,
			Map<Account, CareProgram> careProgramsByAccounts)
	{
		List<CareProgramEnrollee> careprogramEnrollees = new List<CareProgramEnrollee>();
		for (Account objAccount : careProgramsByAccounts.keySet())
		{
			CareProgramEnrollee objCareEnrollee = new CareProgramEnrollee();
			objCareEnrollee.AccountId = objAccount.Id;
			objCareEnrollee.CareProgramId = careProgramsByAccounts.get(objAccount).Id;
			objCareEnrollee.Name = objAccount.FirstName + ' ' + objAccount.LastName + '-' + careProgramsByAccounts.get(objAccount).Name;
			careprogramEnrollees.add(objCareEnrollee);
		}
		unitOfWork.registerNew(careprogramEnrollees);
		return careprogramEnrollees;
	}

	public Map<Id, CareProgramEnrollee> getPatientAndCareProgramEnrolleeInfo(Set<Id> patientIds)
	{
		Map<Id, CareProgramEnrollee> patientAndCareProgrmEnrolleeInfo = new Map<Id, CareProgramEnrollee>();
		for (CareProgramEnrollee cpe : careProgramEnrolleesSelector.elevatedSelectByAccountId(patientIds))
		{
			patientAndCareProgrmEnrolleeInfo.put(cpe.AccountId, cpe);
		}
		return patientAndCareProgrmEnrolleeInfo;
	}
}
