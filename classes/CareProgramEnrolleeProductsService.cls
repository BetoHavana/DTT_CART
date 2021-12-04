public with sharing class CareProgramEnrolleeProductsService
{
	public Map<Id, String> getProductNameMap(List<CareProgramEnrolleeProduct> cpeList)
	{
		Map<Id, String> productNameMap = new Map<Id, String>();
		CareProgramEnrolleeProducts cpepDomain = new CareProgramEnrolleeProducts(cpeList);
		productNameMap = cpepDomain.getProductNamesByCpeId(productNameMap);
		return productNameMap;
	}

	public List<CareProgramEnrolleeProduct> createCareProgramEnrolleeProduct(List<CareProgramEnrollee> careprogramEnrollees)
	{
		Set<Id> careProgramIds = sflib_ArrayUtils.pluckIdField(careprogramEnrollees, CareProgramEnrollee.CareProgramId);
		List<CareProgramProduct> careProgramProducts = ((CareProgramProductsSelector)
														Application.Selector.newInstance(CareProgramProduct.SObjectType))
														.elevatedSelectByCareProgramId(careProgramIds);

		Map<Id, CareProgramProduct> careProgramProductsByCareProgramId = new CareProgramProducts(careProgramProducts).getByCareProgramIds();

		fflib_ISObjectUnitOfWork elevatedUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		List<CareProgramEnrolleeProduct> careProgramEnrolleeProducts = new ElevatedContextDML().elevatedCreateCareProgramEnrolleeProduct(careprogramEnrollees, careProgramProductsByCareProgramId, elevatedUnitOfWork);
		elevatedUnitOfWork.commitWork();

		return careProgramEnrolleeProducts;
	}

	public void grantAccessToPublicGroups(CareProgramEnrolleeProducts cpep)
	{
		fflib_ISObjectUnitOfWork elevatedGroupUnitOfWork = Application.UnitOfWork.newInstance(new ElevatedContextDML());
		grantAccessToPublicGroups(elevatedGroupUnitOfWork, cpep.getRecords());
		elevatedGroupUnitOfWork.commitWork();
	}

	public void grantAccessToPublicGroups(fflib_ISObjectUnitOfWork uow, List<CareProgramEnrolleeProduct> cpepList)
	{

		Set<Id> cpeIds = sflib_ArrayUtils.pluckIdField(cpepList, CareProgramEnrolleeProduct.CareProgramEnrolleeId);

		Map<Id,CareProgramEnrollee> careprogramEnrolleesById = new Map<Id,CareProgramEnrollee>(
							((CareProgramEnrolleesSelector) Application.Selector
									.newInstance(CareProgramEnrollee.SObjectType))
									.elevatedSelectById(cpeIds));

		Map<Id, Id> cpepIdBycpIdToCloneMap = new Map<Id, Id>();

		CareProgramEnrollee cpe;
		for(CareProgramEnrolleeProduct careProduct : cpepList)
		{

			if(careprogramEnrolleesById.containsKey(careProduct.CareProgramEnrolleeId))
			{
				cpe = careprogramEnrolleesById.get(careProduct.CareProgramEnrolleeId);
				cpepIdBycpIdToCloneMap.put(careProduct.Id,cpe.AccountId);
			}

		}

		if(! cpepIdBycpIdToCloneMap.isEmpty())
		{
			new RecordsSharingService().cloneSharingSettings(uow, cpepIdBycpIdToCloneMap, AccountShare.SObjectType);
		}
	}

	private without sharing class ElevatedContextDML implements fflib_SObjectUnitOfWork.IDML
	{
		public void dmlInsert(List<SObject> objList)
		{
			if (objList != null && !objList.isEmpty())
			{
				Database.insert(objList, false);
			}
		}
		public void dmlUpdate(List<SObject> objList)
		{
			update objList;
		}
		public void dmlDelete(List<SObject> objList)
		{
			delete objList;
		}
		public void eventPublish(List<SObject> objList)
		{
			//not implemented
		}

		public void emptyRecycleBin(List<SObject> objList)
		{
			if (objList.isEmpty())
			{
				return;
			}
			Database.emptyRecycleBin(objList);
		}

		public List<CareProgramEnrolleeProduct> elevatedCreateCareProgramEnrolleeProduct(List<CareProgramEnrollee> careprogramEnrollees, Map<Id, CareProgramProduct> careProgramProductsByCareProgramId, fflib_ISObjectUnitOfWork unitOfWork)
		{
			List<CareProgramEnrolleeProduct> careprogramEnrolleeProducts = new List<CareProgramEnrolleeProduct>();
			for (CareProgramEnrollee objEnrollee : careprogramEnrollees)
			{
				if (careProgramProductsByCareProgramId.containsKey(objEnrollee.CareProgramId))
				{
					CareProgramEnrolleeProduct objCareProgramEnrolleeProduct = new CareProgramEnrolleeProduct();
					objCareProgramEnrolleeProduct.CareProgramEnrolleeId = objEnrollee.Id;
					objCareProgramEnrolleeProduct.CareProgramProductId = careProgramProductsByCareProgramId.get(objEnrollee.CareProgramId).Id;
					objCareProgramEnrolleeProduct.Name = objEnrollee.Name;
					careprogramEnrolleeProducts.add(objCareProgramEnrolleeProduct);
				}
			}

			unitOfWork.registerNew(careprogramEnrolleeProducts);
			return careprogramEnrolleeProducts;
		}

	}
}