public with sharing class PatientsListViewController
{

	public static final String PHYSICIAN = 'Physician';
	public static final String CARTCOORDINATOR = 'CAR-T Coordinator';
	public final static String STATUSUNREAD = 'Unread';
	public final static String PATIENTCARD = 'patientCard';

	private PatientsListViewController()
	{

	}

	private static AccountsService AccountsService
	{
		get
		{
			if (null == AccountsService)
			{
				AccountsService = (AccountsService) Application.Service.newInstance(AccountsService.class);
			}
			return AccountsService;
		}
		set;
	}

	private static CasesService CasesService
	{
		get
		{
			if (null == CasesService)
			{
				CasesService = (CasesService) Application.Service.newInstance(CasesService.class);
			}
			return CasesService;
		}
		set;
	}

	private static ContactContactRelationsService ContactContactRelationsService
	{
		get
		{
			if (null == ContactContactRelationsService)
			{
				ContactContactRelationsService = (ContactContactRelationsService) Application.Service.newInstance(ContactContactRelationsService.class);
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
				OrdersService = (OrdersService) Application.Service.newInstance(OrdersService.class);
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

	@AuraEnabled
	public static String fetchPatientDetails()
	{
		try
		{
			String strJsonPatient = '';
			List<PatientsWrapper> lstPatientWrapper = new List<PatientsWrapper>();
			Map<Id, Account> patientsById = AccountsService.getPatients();
			Map<Id, Id> PersonContactIdByPatientId = new Accounts(patientsById.values()).getPersonContactIdById();

			Set<Id> patientContactIds = new Accounts(patientsById.values()).getPersonContactIds();

			Map<Id, String> treatingPhysicianNameByContactId = ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, PHYSICIAN);
			Map<Id, String> cartCoordinatorByContactId = ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, CARTCOORDINATOR);

			Map<Id, Case> carePlanByPatientId = CasesService.elevatedGetCarePlanByPatientId(patientsById.keySet());
			Map<Id, Order__c> orderByPatientId = OrdersService.elevatedGetOrderByPatientId(patientsById.keySet());

			List<PatientLandingPageStatusValue__mdt> lstPatientStatus = PatientTreatmentMilestonesService.getPatientStatusValues();
			Map<Id, PatientLandingPageStatusValue__mdt> milestoneStatusValue = getPatientTreatmentMilestone(patientsById, carePlanByPatientId, orderByPatientId, lstPatientStatus);

			Map<String, List<Notification__c>> notificationsByPatientId = getNotificationsByPatientId(patientsById.keySet());
			Map<Id,String> mrnByPatientId = AccountContactRelationsService.getPatientMRNInfo(patientsById.keySet());
			for (Account objPatient : patientsById.values())
			{
				PatientsWrapper objPatientWrapper = new PatientsWrapper();
				objPatientWrapper.memberId = objPatient.Id;
				objPatientWrapper.setMemberName(objPatient.LastName, objPatient.MiddleName, objPatient.FirstName);
				objPatientWrapper.memberFirstName = objPatient.FirstName;
				objPatientWrapper.memberLastName = objPatient.LastName;
				objPatientWrapper.memberMRN = mrnByPatientId.containsKey(objPatient.Id) ? mrnByPatientId.get(objPatient.Id) : '';
				objPatientWrapper.memberDateOfBirth = objPatient.PersonBirthdate;
				if (notificationsByPatientId.isEmpty())
				{
					objPatientWrapper.alerts = '';
				}
				else
				{
					objPatientWrapper.alerts = notificationsByPatientId.keySet().contains(objPatient.Id) ? notificationsByPatientId.get(objPatient.Id).size() + '' : '';
				}
				assignRelatedData(objPatientWrapper, carePlanByPatientId, objPatient.Id, treatingPhysicianNameByContactId, PersonContactIdByPatientId, cartCoordinatorByContactId, milestoneStatusValue);
				lstPatientWrapper.add(objPatientWrapper);
			}
			strJsonPatient = JSON.serialize(lstPatientWrapper);
			return strJsonPatient;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	private static Map<String, List<Notification__c>> getNotificationsByPatientId(Set<Id> accountsId)
	{
		Set<String> readStatus = new Set<String>();
		readStatus.add(STATUSUNREAD);
		List<Notification__c> notifications =
				(new NotificationsSelector().selectRelatedRecordId(accountsId, readStatus)).Records ;
		Map<String, List<Notification__c>> notificationsByPatientId = new Map<String, List<Notification__c>>();
		if (!notifications.isEmpty())
		{
			for (Notification__c notification : notifications)
			{
				if (notificationsByPatientId.containsKey(notification.RelatedRecordId__c))
				{
					List<Notification__c> notificationsForMap = notificationsByPatientId.get(notification.RelatedRecordId__c);
					notificationsForMap.add(notification);
					notificationsByPatientId.put(notification.RelatedRecordId__c, notificationsForMap);
				}
				else
				{
					notificationsByPatientId.put(notification.RelatedRecordId__c, new List<Notification__c> {notification});
				}
			}
		}
		return notificationsByPatientId;
	}

	public static Map<Id, PatientLandingPageStatusValue__mdt> getPatientTreatmentMilestone(Map<Id, Account> patientsById, Map<Id, Case> carePlanByPatientId, Map<Id, Order__c> orderByPatientId, List<PatientLandingPageStatusValue__mdt> lstPatientStatus)
	{
		Map<Id, PatientLandingPageStatusValue__mdt> enrollmentByAccountID = new Map<Id, PatientLandingPageStatusValue__mdt>();
		for (Account objacc : patientsById.values())
		{
			for (PatientLandingPageStatusValue__mdt milestoneStatusValue : lstPatientStatus)
			{
				if (milestoneStatusValue.PatientStatus__c == objacc.Status__c
						&& carePlanByPatientId.containsKey(objacc.Id)
						&& milestoneStatusValue.CarePlanStatus__c == carePlanByPatientId.get(objacc.Id).Status
						&& orderByPatientId.containsKey(objacc.Id)
						&& milestoneStatusValue.OrderStatus__c == orderByPatientId.get(objacc.Id).OrderStatus__c)
				{
					enrollmentByAccountID.put(objacc.Id, milestoneStatusValue);
				}
			}
		}
		return enrollmentByAccountID;
	}

	public static PatientsWrapper assignRelatedData(PatientsWrapper objPatientWrapper, Map<Id, Case> carePlanByPatientId, Id patientId, Map<Id, String> treatingPhysicianNameByContactId, Map<Id, Id> contactIdByPatientId, Map<Id, String> cartCoordinatorByContactId, Map<Id, PatientLandingPageStatusValue__mdt> milestoneStatusValue)
	{
		if (milestoneStatusValue.containsKey(patientId))
		{
			objPatientWrapper.patientTreatingMilestone = milestoneStatusValue.get(patientId).PatientTreatmentMilestoneStatus__c;
			objPatientWrapper.isPatientTreatingMilestoneActive = milestoneStatusValue.get(patientId).Active__c;
		}
		if (contactIdByPatientId.containsKey(patientId) && treatingPhysicianNameByContactId.containsKey(contactIdByPatientId.get(patientId)))
		{
			objPatientWrapper.treatingPhysician = treatingPhysicianNameByContactId.get(contactIdByPatientId.get(patientId));
		}
		if (contactIdByPatientId.containsKey(patientId) && cartCoordinatorByContactId.containsKey(contactIdByPatientId.get(patientId)))
		{
			objPatientWrapper.cartCoordinator = cartCoordinatorByContactId.get(contactIdByPatientId.get(patientId));
		}
		return objPatientWrapper;
	}

	@AuraEnabled
	public static String fetchPatientDetailsForSiteCalendar(String option){
		try {
			String strJsonPatient = '';
			List<PatientsWrapper> lstPatientWrapper = new List<PatientsWrapper>();

			Map<Id, Account> patientsById = AccountsService.getPatients();
			Map<Id, Id> PersonContactIdByPatientId = new Accounts(patientsById.values()).getPersonContactIdById();

			Set<Id> patientContactIds = new Accounts(patientsById.values()).getPersonContactIds();

			Map<Id, String> treatingPhysicianNameByContactId = ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, PHYSICIAN);
			Map<Id, String> cartCoordinatorByContactId = ContactContactRelationsService.getRelatedContactIdsByRole(patientContactIds, CARTCOORDINATOR);

			Map<Id, Case> carePlanByPatientId = CasesService.getCarePlanByPatientId(patientsById.keySet());

			Map<Id, Order__c> orderByPatientId = getOrderForPatientId(patientsById.keySet(), option);



			List<PatientLandingPageStatusValue__mdt> lstPatientStatus = PatientTreatmentMilestonesService.getPatientStatusValues();

			Map<Id, PatientLandingPageStatusValue__mdt> milestoneStatusValue = getPatientTreatmentMilestone(patientsById, carePlanByPatientId, orderByPatientId, lstPatientStatus);
			Map<Id,String> mrnByPatientId = AccountContactRelationsService.getPatientMRNInfo(patientsById.keySet());


			for (Order__c objOrder : orderByPatientId.values())
			{
				Account objPatient = patientsById.get(objOrder.Patient__c);
				PatientsWrapper objPatientWrapper = new PatientsWrapper();
				objPatientWrapper.memberId = objPatient.Id;
				objPatientWrapper.patientId = objPatient.PatientID__c;
				objPatientWrapper.setMemberName(objPatient.LastName, objPatient.MiddleName, objPatient.FirstName);
				objPatientWrapper.memberFirstName = objPatient.FirstName;
				objPatientWrapper.memberLastName = objPatient.LastName;
				objPatientWrapper.memberMRN = mrnByPatientId.containsKey(objPatient.Id) ? mrnByPatientId.get(objPatient.Id) : '';
				assignRelatedData(objPatientWrapper, carePlanByPatientId, objPatient.Id, treatingPhysicianNameByContactId,
						PersonContactIdByPatientId, cartCoordinatorByContactId, milestoneStatusValue);
				getApheresisDetails(objPatientWrapper,orderByPatientId,objPatient.Id);
				System.debug(objPatientWrapper);
				lstPatientWrapper.add(objPatientWrapper);
			}
			strJsonPatient = JSON.serialize(lstPatientWrapper);
			return strJsonPatient;
		}
		catch (Exception e)
		{
			AuraHandledException auraHandledException = new AuraHandledException(e.getMessage());
			auraHandledException.setMessage(e.getStackTraceString());
			throw auraHandledException;
		}
	}

	public static Map<Id, Order__c> getOrderForPatientId(Set<Id> patientIds, String option)
	{
		Map<Id, Order__c> orderByPatientId = new Map<Id, Order__c>();

		if(String.isNotBlank(option) && option == PATIENTCARD)
		{
			orderByPatientId = OrdersService.getNewAndDrugDeliveredOrdersByPatientId(patientIds);
		}
		else
		{
			orderByPatientId = OrdersService.getScheduledApheresisAndDrugDeliveryOrdersByPatientId(patientIds);
		}

		return orderByPatientId;
	}

	public static PatientsWrapper getApheresisDetails(PatientsWrapper objPatientWrapper,Map<Id, Order__c> orderByPatientId,Id patientId){
		if (!orderByPatientId.isEmpty() && orderByPatientId.containskey(patientId))
		{
			objPatientWrapper.manufacturingStatus = orderByPatientId.get(patientId).ManufacturingStatus__c;
			if (orderByPatientId.get(patientId).ApheresisPickUpDate__c != null)
			{
				objPatientWrapper.apheresisPickupDate = orderByPatientId.get(patientId).ApheresisPickUpDate__c;
				objPatientWrapper.confirmedFPDeliveryDate = orderByPatientId.get(patientId).ConfirmedFPDeliveryDate__c;
			}
		}
		return objPatientWrapper;
	}
}
