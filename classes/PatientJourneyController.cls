public with sharing class PatientJourneyController
{
	public static final String PHYSICIAN = 'Physician';
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	static final String NUMBEROFDAYSFORRESCHEDULE = 'Number of Days For Reschedule';
	public static final String INFUSIONCOMPLETE = 'Infusion Complete';

	private static ContactContactRelationsService ContactContactRelationsService
	{
		get
		{
			if (null == ContactContactRelationsService)
			{
				ContactContactRelationsService =
						(ContactContactRelationsService) Application.Service.newInstance(ContactContactRelationsService.class);
			}
			return ContactContactRelationsService;
		}
		set;
	}

	private static OrdersService OrdersService
	{
		get
		{
			if (null == OrdersService)
			{
				OrdersService =
						(OrdersService) Application.Service.newInstance(OrdersService.class);
			}
			return OrdersService;
		}
		set;
	}

	private static PatientTreatmentMilestonesService PatientTreatmentMilestonesService
	{
		get
		{
			if (null == PatientTreatmentMilestonesService)
			{
				PatientTreatmentMilestonesService = (PatientTreatmentMilestonesService) Application.Service.newInstance(PatientTreatmentMilestonesService.class);
			}
			return PatientTreatmentMilestonesService;
		}
		set;
	}

	private static AccountContactRelationsService AccountContactRelationsService
	{
		get
		{
			if (null == AccountContactRelationsService)
			{
				AccountContactRelationsService = (AccountContactRelationsService) Application.Service.newInstance(AccountContactRelationsService.class);
			}
			return AccountContactRelationsService;
		}
		set;
	}

	@AuraEnabled(cacheable=true)
	public static List<ContentVersion> getDocumentsByPatientId(Id patientId){
		try
		{
			List<ContentVersion> documentsList = new List<ContentVersion>();
			List<PatientServicesEnrollee__c> patientServicesEnrolleeList =
					((PatientServicesEnrolleesSelector) Application.Selector.newInstance(PatientServicesEnrollee__c.SObjectType))
							.elevatedSelectByAccountId(new Set<Id> {patientId});

			if (!patientServicesEnrolleeList.isEmpty())
			{
				Id patientServicesEnrolleeId = patientServicesEnrolleeList[0].Id;

				List<ContentDocumentLink> contentDocuments =
						((ContentDocumentLinksSelector) Application.Selector.newInstance(ContentDocumentLink.SObjectType))
								.elevatedSelectByLinkedEntity(patientServicesEnrolleeId);

				Set<Id> contentDocumentIds =
						sflib_ArrayUtils.pluckIdField(contentDocuments, ContentDocumentLink.ContentDocumentId);

				if(!contentDocumentIds.isEmpty()){
					documentsList =
							((ContentVersionsSelector) Application.Selector.newInstance(ContentVersion.SObjectType))
									.elevatedGetContentVersionByDocumentIds(contentDocumentIds);
				}
			}
			return documentsList;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static List<Case> fetchPatientServiceEligibilty(Id patientId)
	{
		try
		{
			Map<Id, Case> carePlanByPatientId = CasesService.fetchCarePlanByPatientId(new Set<Id> {patientId});
			return carePlanByPatientId.values();
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled(cacheable=true)
	public static List<PatientServicesEnrollee__c> fetchPatientServiceEnrollees(Id patientId)
	{
		try
		{
			Map<Id, Case> carePlanByPatientId = CasesService.fetchCarePlanByPatientId(new Set<Id> {patientId});

			Set<Id> carePlanIds = sflib_ArrayUtils.pluckIdField(carePlanByPatientId.values(), Case.Id);

			Map<Id, PatientServicesEnrollee__c> patientServicesByPatientId = PatientServicesEnrolleesService.fetchPatientServicesStatus(carePlanIds);
			return patientServicesByPatientId.values();
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static void updateCarePlan(Id patientId,String strPatientServiceProgram)
	{
		try
		{
			Boolean isPatientServiceOpted = Boolean.valueOf(strPatientServiceProgram);

			Map<Id, Boolean> isPatientServiceOptedByAccount = new Map<Id, Boolean>();
			isPatientServiceOptedByAccount.put(patientId,isPatientServiceOpted);

			CasesService.updateCarePlan(isPatientServiceOptedByAccount);

		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static void updateOrder(Id patientId,String reasonForCancellation)
	{
		try
		{
			Map<Id,Order__c> orderByPatientId = OrdersService.getOrderByPatientId(new Set<Id>{patientId});
			Orders cancelledOrders = new Orders(orderByPatientId.values());
			cancelledOrders.setReasonForCancellation(reasonForCancellation);
			cancelledOrders.setOrderStatus('Order Cancellation Requested');
			cancelledOrders.setDateOfCancellationRequestTCP(System.Today());
			List<Order__c> cancelledOrdersList = cancelledOrders.getRecords();
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerDirty(cancelledOrdersList);
			uow.commitWork();
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static void updateDeliveryDateOnOrder(Id patientId, String dpDeliveryDate)
	{
		try
		{
			Map<Id,Order__c> orderByPatientId = OrdersService.getOrderByPatientId(new Set<Id>{patientId});
			Orders patientOrders = new Orders(orderByPatientId.values());
			patientOrders.setConfirmedFPDeliveryDate(date.valueOf(dpDeliveryDate));
			List<Order__c> patientOrdersList = patientOrders.getRecords();
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerDirty(patientOrdersList);
			uow.commitWork();
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	@AuraEnabled
	public static void updateInfusedDateOnOrder(Id patientId, String infusedDate)
	{
		try
		{
			Map<Id,Order__c> orderByPatientId = OrdersService.getOrderByPatientId(new Set<Id>{patientId});
			Orders patientOrders = new Orders(orderByPatientId.values());
			patientOrders.setInfusionDate(date.valueOf(infusedDate));
			patientOrders.setOrderStatus(INFUSIONCOMPLETE);
			List<Order__c> patientOrdersList = patientOrders.getRecords();
			fflib_ISObjectUnitOfWork uow = Application.UnitOfWork.newInstance();
			uow.registerDirty(patientOrdersList);
			uow.commitWork();
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static Map<Id, PatientLandingPageStatusValue__mdt> getPatientStatus(Map<Id, Account> patientsById, Map<Id, Case> carePlanByPatientId,List<PatientLandingPageStatusValue__mdt> lstPatientStatus)
	{
		Map<Id, PatientLandingPageStatusValue__mdt> enrollmentByAccountID = new Map<Id, PatientLandingPageStatusValue__mdt>();
		for (Account objacc : patientsById.values())
		{
			for (PatientLandingPageStatusValue__mdt milestoneStatusValue : lstPatientStatus)
			{
				if (milestoneStatusValue.PatientStatus__c == objacc.Status__c
						&& carePlanByPatientId.containsKey(objacc.Id)
						&& milestoneStatusValue.CarePlanStatus__c == carePlanByPatientId.get(objacc.Id).Status)
				{
					enrollmentByAccountID.put(objacc.Id, milestoneStatusValue);
				}
			}
		}
		return enrollmentByAccountID;
	}

	@AuraEnabled(cacheable=true)
	public static String getDetailsByPatientId(Id patientId)
	{
		try
		{
			String strJsonPatient = '';
			PatientsWrapper objPatientWrapper = new PatientsWrapper();
			List<Account> patients = new List<Account>();
			patients.add(new Account(id = patientId));
			Map<Id, Account> patientsById =
					((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
							.selectById(new Set<Id> {patientId}).getById();
			Map<Id, Id> PersonContactIdByPatientId =
					((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
							.selectById(new Set<Id> {patientId}).getPersonContactIdById();
			Set<Id> patientContactIds = new Set<Id>();
			patientContactIds.addAll(PersonContactIdByPatientId.values());
			Map<Id, String> treatingPhysicianNameByContactId =
					ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, PHYSICIAN);
			Map<Id, String> cartCoordinatorByContactId =
					ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, CARTCOORDINATOR);

			Map<Id, Order__c> orderByPatientId =
					OrdersService.elevatedGetOrderByPatientId(new Set<Id> {patientId});
			Map<Id, Case> carePlanByPatientId =
					new CasesService().elevatedGetCarePlanByPatientId(new Set<Id> {patientId});

			List<PatientLandingPageStatusValue__mdt> lstPatientStatus = PatientTreatmentMilestonesService.getPatientStatusValues();

			Map<Id, PatientLandingPageStatusValue__mdt> patientStatusByPatientId = getPatientStatus(patientsById, carePlanByPatientId, lstPatientStatus);
			Map<Id,String> mrnByPatientId = AccountContactRelationsService.getPatientMRNInfo(patientsById.keySet());

			if (PersonContactIdByPatientId.containskey(patientId) && treatingPhysicianNameByContactId.containsKey(PersonContactIdByPatientId.get(patientId)))
			{
				objPatientWrapper.treatingPhysician =
						treatingPhysicianNameByContactId.get(PersonContactIdByPatientId.get(patientId));
			}
			if (PersonContactIdByPatientId.containskey(patientId) && cartCoordinatorByContactId.containsKey(PersonContactIdByPatientId.get(patientId)))
			{
				objPatientWrapper.cartCoordinator =
						cartCoordinatorByContactId.get(PersonContactIdByPatientId.get(patientId));
			}
			getApheresisDetails(objPatientWrapper,orderByPatientId,patientId);
			getShippingStatus(objPatientWrapper,orderByPatientId,patientId);
			getManufacturingDetails(objPatientWrapper, orderByPatientId, patientId);
			getDeliveryStatus(objPatientWrapper, orderByPatientId, patientId);
			if (patientsById.containskey(patientId))
			{
				if(patientStatusByPatientId.containsKey(patientId))
				{
					objPatientWrapper.patientJourneyStatus = patientStatusByPatientId.get(patientId).PatientJourneyStatus__c;
				}
				objPatientWrapper.patientStatus = patientsById.get(patientId).Status__c;
				objPatientWrapper.memberFirstName = patientsById.get(patientId).FirstName;
				objPatientWrapper.memberLastName = patientsById.get(patientId).LastName;
				objPatientWrapper.setMemberName(patientsById.get(patientId).FirstName, patientsById.get(patientId).MiddleName, patientsById.get(patientId).LastName);
				objPatientWrapper.memberMRN = mrnByPatientId.containsKey(patientId) ? mrnByPatientId.get(patientId) : '';
				objPatientWrapper.memberDateOfBirth = patientsById.get(patientId).PersonBirthdate;
				objPatientWrapper.patientId = patientsById.get(patientId).PatientID__c;
				objPatientWrapper.memberPhone = patientsById.get(patientId).Phone;
				objPatientWrapper.patientEmail = patientsById.get(patientId).PersonEmail;
				objPatientWrapper.patientPreferredMethodOfCommunication = patientsById.get(patientId).PreferredMethodOfCommunication__c;
				objPatientWrapper.patientPrimaryContactType = patientsById.get(patientId).PrimaryContactNumberType__c;
			}
			strJsonPatient = JSON.serialize(objPatientWrapper);
			return strJsonPatient;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static PatientsWrapper getApheresisStatus(PatientsWrapper objPatientWrapper, Order__c order)
	{
		String carePlanStatus = order.CarePlanID__r.Status;
		String orderStatus = order.OrderStatus__c;
		String slotStatus = order.SlotStatus__c;
		String poStatus = order.POStatus__c;
		List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
				Application.Selector.newinstance(TreatmentJourneySteps__mdt.SObjectType))
				.selectApheresisStepsByStatuses(carePlanStatus, orderStatus, slotStatus, poStatus);
		if (!treatmentJourneySteps.isEmpty())
		{
			objPatientWrapper.apheresisPickupStatus = treatmentJourneySteps[0].ApheresisPickUpSectionStatus__c;
			objPatientWrapper.isApheresisCompleted = treatmentJourneySteps[0].ApheresisCompleted__c;
		}
		return objPatientWrapper;
	}

	public static PatientsWrapper getShippingStatus(PatientsWrapper objPatientWrapper,Map<Id, Order__c> orderByPatientId,Id patientId)
	{
		if (!orderByPatientId.isEmpty() && orderByPatientId.containskey(patientId))
		{
			String carePlanStatus = orderByPatientId.get(patientId).CarePlanID__r.Status;
			String orderStatus = orderByPatientId.get(patientId).OrderStatus__c;
			String slotStatus = orderByPatientId.get(patientId).SlotStatus__c;
			String poStatus = orderByPatientId.get(patientId).POStatus__c;
			String shippingStatus = orderByPatientId.get(patientId).ShippingStatus__c;
			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newinstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectShippingStepsByStatuses(carePlanStatus, orderStatus, slotStatus, poStatus, shippingStatus);

			if (!treatmentJourneySteps.isEmpty())
			{
				objPatientWrapper.projectedDeliveryDate = orderByPatientId.get(patientId).ProjectedDeliveryDate__c;
				objPatientWrapper.apheresisPickupStatus = treatmentJourneySteps[0].ApheresisPickUpSectionStatus__c;
				objPatientWrapper.isApheresisCompleted = treatmentJourneySteps[0].ApheresisCompleted__c;
				objPatientWrapper.shippingStatus = treatmentJourneySteps[0].ShippingStatus__c;
				objPatientWrapper.isShippingCompleted = treatmentJourneySteps[0].ShippingCompleted__c;
			}
		}
		return objPatientWrapper;
	}

	public static PatientsWrapper getApheresisDetails(PatientsWrapper objPatientWrapper,Map<Id, Order__c> orderByPatientId,Id patientId){
		if (!orderByPatientId.isEmpty() && orderByPatientId.containskey(patientId))
		{
			getApheresisStatus(objPatientWrapper, orderByPatientId.get(patientId));
			if (orderByPatientId.get(patientId).ApheresisPickUpDate__c != null)
			{
				objPatientWrapper.projectedDeliveryDate = orderByPatientId.get(patientId).ProjectedDeliveryDate__c;
				objPatientWrapper.apheresisPickupSite = orderByPatientId.get(patientId).ApheresisSite__r.Name;
				objPatientWrapper.apheresisCryoType = orderByPatientId.get(patientId).CryoType__c;
				objPatientWrapper.apheresisPickupDate = orderByPatientId.get(patientId).ApheresisPickUpDate__c;
				objPatientWrapper.apheresisSitePO = orderByPatientId.get(patientId).SitePO__c;
			}
			objPatientWrapper.orderStatus = orderByPatientId.get(patientId).OrderStatus__c;
			objPatientWrapper.orderCancellationRequestDate = orderByPatientId.get(patientId).DateOfCancellationRequestTCP__c;
			objPatientWrapper.carePlanStatus = orderByPatientId.get(patientId).CarePlanID__r.Status;
			objPatientWrapper.cryoType = orderByPatientId.get(patientId).CryoType__c;
		}
		return objPatientWrapper;
	}

	public static PatientsWrapper getManufacturingDetails(PatientsWrapper objPatientWrapper, Map<Id, Order__c> orderByPatientId, Id patientId)
	{
		if (!orderByPatientId.isEmpty() && orderByPatientId.containskey(patientId))
		{
			String carePlanStatus = orderByPatientId.get(patientId).CarePlanID__r.Status;
			String orderStatus = orderByPatientId.get(patientId).OrderStatus__c;
			String slotStatus = orderByPatientId.get(patientId).SlotStatus__c;
			String poStatus = orderByPatientId.get(patientId).POStatus__c;
			String manufacturingStatus = orderByPatientId.get(patientId).ManufacturingStatus__c;

			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newinstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectManufacturingStepsByStatuses(carePlanStatus, orderStatus, slotStatus, poStatus,manufacturingStatus );
			if (!treatmentJourneySteps.isEmpty())
			{
				objPatientWrapper.apheresisPickupStatus = treatmentJourneySteps[0].ApheresisPickUpSectionStatus__c;
				objPatientWrapper.isApheresisCompleted = treatmentJourneySteps[0].ApheresisCompleted__c;
				objPatientWrapper.shippingStatus = treatmentJourneySteps[0].ShippingStatus__c;
				objPatientWrapper.isShippingCompleted = treatmentJourneySteps[0].ShippingCompleted__c;
				objPatientWrapper.manufacturingStatus = treatmentJourneySteps[0].ManufacturingStatus__c;
				objPatientWrapper.isManufacturingCompleted = treatmentJourneySteps[0].ManufacturingCompleted__c;

			}
		}
		return objPatientWrapper;
	}

	public static PatientsWrapper getDeliveryStatus(PatientsWrapper objPatientWrapper,Map<Id, Order__c> orderByPatientId,Id patientId)
	{
		if (!orderByPatientId.isEmpty() && orderByPatientId.containskey(patientId))
		{
			String carePlanStatus = orderByPatientId.get(patientId).CarePlanID__r.Status;
			String orderStatus = orderByPatientId.get(patientId).OrderStatus__c;
			String slotStatus = orderByPatientId.get(patientId).SlotStatus__c;
			String poStatus = orderByPatientId.get(patientId).POStatus__c;
			String shippingStatus = orderByPatientId.get(patientId).ShippingStatus__c;
			String manufacturingStatus = orderByPatientId.get(patientId).ManufacturingStatus__c;
			String deliveryStatus = orderByPatientId.get(patientId).ShippingStatus__c;

			List<TreatmentJourneySteps__mdt> treatmentJourneySteps = ((TreatmentJourneyStepsSelector)
					Application.Selector.newinstance(TreatmentJourneySteps__mdt.SObjectType))
					.selectDeliveryStepsByStatuses(carePlanStatus, orderStatus, slotStatus, poStatus, shippingStatus, manufacturingStatus, deliveryStatus);

			if (!treatmentJourneySteps.isEmpty())
			{
				objPatientWrapper.apheresisPickupStatus = treatmentJourneySteps[0].ApheresisPickUpSectionStatus__c;
				objPatientWrapper.isApheresisCompleted = treatmentJourneySteps[0].ApheresisCompleted__c;
				objPatientWrapper.shippingStatus = treatmentJourneySteps[0].ShippingStatus__c;
				objPatientWrapper.isShippingCompleted = treatmentJourneySteps[0].ShippingCompleted__c;
				objPatientWrapper.manufacturingStatus = treatmentJourneySteps[0].ManufacturingStatus__c;
				objPatientWrapper.isManufacturingCompleted = treatmentJourneySteps[0].ManufacturingCompleted__c;
				objPatientWrapper.isDeliveryCompleted = treatmentJourneySteps[0].DeliveryCompleted__c;
				objPatientWrapper.deliveryStatus = treatmentJourneySteps[0].DeliveryStatus__c;
				objPatientWrapper.estimatedDrugProductDeliveryDate = orderByPatientId.get(patientId).EstimatedDrugProductDeliveryDate__c;
				objPatientWrapper.confirmedFPDeliveryDate = orderByPatientId.get(patientId).ConfirmedFPDeliveryDate__c;
				objPatientWrapper.isInfusionCompleted = treatmentJourneySteps[0].InfusionCompleted__c;
				objPatientWrapper.infusionStatus = treatmentJourneySteps[0].InfusionStatus__c;
				objPatientWrapper.infusionDate = orderByPatientId.get(patientId).InfusionDate__c;
			}
		}
		return objPatientWrapper;
	}

	@AuraEnabled(cacheable=true)
	public static Boolean isBussinessDayDueForReschedule(Id patientId)
	{
		List<Account> patients = new List<Account>();
		patients.add(new Account(id = patientId));
		Map<Id, Account> patientsById =
				((AccountsSelector) Application.Selector.newInstance(Account.SObjectType))
						.selectById(new Set<Id> {patientId}).getById();
		Map<Id, Order__c> orderByPatientId =
				OrdersService.elevatedGetOrderByPatientId(new Set<Id> {patientId});

		List<BusinessHours> businessHours = ((BusinessHoursSelector) Application.Selector.newInstance(BusinessHours.SObjectType))
				.selectBusinessHoursByName(Label.BusinessHoursNameForOrderSubmissionRescheduling);
		BusinessHoursCalculatorImp bhCalculatorImp = new BusinessHoursCalculatorImp(businessHours[0].Id);
		Integer noOfDays = Integer.valueOf(bhCalculatorImp.getDifferenceBetweenTimeSpans(Date.today(), orderByPatientId.get(patientId).ApheresisPickUpDate__c) / BusinessHoursCalculator.oneDayToMilliSeconds);

		sflib_Settings__c noOfDaysAllowed = sflib_Settings__c.getValues(NUMBEROFDAYSFORRESCHEDULE);

		if(noOfDays > Integer.ValueOf(NoOfDaysAllowed.Value__c)){
			return true;
		}
		return false;
	}

	@AuraEnabled
	public static Date getNextThreeBussinessDays(String startDate)
	{
		Date stDate = date.valueOf(startDate);
		Date estimatedDate = OrdersService.getEstimatedDate(stDate);
		return estimatedDate;
	}

}
