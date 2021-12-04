public with sharing class OrdersSelector extends fflib_SObjectSelector
{
	public final static String carePlanStatusNew = 'New';
	public final static String carePlanStatusManufactured = 'Manufacturing';

	public final static String orderManufacturingStatusQRComplete = 'QR Complete';

	String patientId = Order__c.Patient__c.getDescribe().getName();

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				Order__c.ApheresisSite__c,
				Order__c.ApheresisSitePickupAddress__c,
				Order__c.ApheresisPickUpDate__c,
				Order__c.ApheresisPO__c,
                Order__c.ApheresisPOStatus__c,
				Order__c.ASNToAnaplanStatus__c,
				Order__c.AtlasOrderId__c,
				Order__c.AttestedForCompletion__c,
				Order__c.CarePlanId__c,
				Order__c.CartOrderId__c,
				Order__c.ConfirmedFPDeliveryDate__c,
				Order__c.Coordinator__c,
				Order__c.CryoSite__c,
				Order__c.CryoCellPickupDateAndTime__c,
				Order__c.CryoSiteType__c,
				Order__c.CryoType__c,
				Order__c.CryoSiteDropOffAddress__c,
				Order__c.CryoSitePickupAddress__c,
				Order__c.DateOfCancellationRequest__c,
				Order__c.DPOkToShipToSAPStatus__c,
				Order__c.EstimatedDrugProductDeliveryDate__c,
				Order__c.FinalDPDateinVineti__c,
				Order__c.FinalDPDropOffDateAndTime__c,
				Order__c.FinalDPPickupDateAndTime__c,
				Order__c.FreshCellDropOffDateAndTime__c,
				Order__c.FreshCellPickupDateAndTime__c,
				Order__c.Id,
				Order__c.InfusionDate__c,
				Order__c.ManufacturingSite__c,
				Order__c.ManufacturingSiteDropOffAddress__c,
				Order__c.ManufacturingSitePickupAddress__c,
				Order__c.ManufacturingStatus__c,
				Order__c.ManufacturingMilestoneDateTime__c,
				Order__c.Name,
				Order__c.OrderPlacementInfo__c,
				Order__c.OrderStatus__c,
				Order__c.OrderRescheduledinVineti__c,
				Order__c.Patient__c,
				Order__c.PatientID__c,
				Order__c.PatientStatus__c,
				Order__c.ProjectedDeliveryDate__c,
				Order__c.Physician__c,
				Order__c.POStatus__c,
				Order__c.ProjectedDeliveryDate__c,
				Order__c.QTCPOtoSDStatus__c,
				Order__c.ReasonForOrderWithdrawal__c,
				Order__c.ReasonforReschedule__c,
				Order__c.SDPO__c,
				Order__c.SitePO__c,
				Order__c.ShippingStatus__c,
				Order__c.SlotStatus__c,
				Order__c.SpecifyTheOtherReasonForReschedule__c,
				Order__c.TreatmentSite__c,
				Order__c.TreatmentSiteDropOffAddress__c,
				Order__c.VinetiCOI__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Order__c.SObjectType;
	}

	public Orders selectByAccountId(Set<Id> accountIds)
	{
		return (Orders) Application.Domain.newInstance(
				Database.query(
						newQueryFactory()
								.selectField('ApheresisSite__r.Name')
								.selectField('CarePlanID__r.Status')
								.selectField('ManufacturingStatus__c')
								.setCondition('Patient__c IN :accountIds')
								.toSOQL()
				)
		);
	}

	public Database.QueryLocator selectByApheresisDueDate()
	{
		String patientStatus = StaticConstants.PatientStatusVerified;
		return Database.getQueryLocator(
				newQueryFactory()
						.setCondition('ApheresisPickUpDate__c = TODAY AND PatientStatus__c =:patientStatus' )
						.toSOQL()
		);
	}

	public List<Order__c> selectOrdersByOrderId(Set<Id> orderIds)
	{
		return (List<Order__c>) Database.query(
				newQueryFactory()
						.selectField('CryoSite__c')
						.selectField('CryoSite__r.Type')
						.selectField('CryoSite__r.ERPSiteID__c')
						.selectField('ApheresisSite__r.ERPSiteID__c')
						.selectField('TreatmentSite__r.ERPSiteID__c')
						.selectField('ApheresisSite__r.AccountIdentifier__c')
						.selectField('TreatmentSite__r.AccountIdentifier__c')
						.selectField('ApheresisSite__r.Type')
						.setCondition('Id IN : orderIds')
						.toSOQL());
	}

	public List<Order__c> selectAll()
	{
		return((List<Order__c>) Database.query(
				newQueryFactory()
						.selectField('CryoSite__r.ERPSiteID__c')
						.selectField('ApheresisSite__r.ERPSiteID__c')
						.selectField('TreatmentSite__r.ERPSiteID__c')
						.selectField('ApheresisSite__r.Type')
						.setOrdering('Name', fflib_QueryFactory.SortOrder.ASCENDING)
						.toSOQL()));
	}

	public List<Order__c> selectOrdersByCarePlanId(Set<Id> carePlanIds)
	{
		return (List<Order__c>) Database.query(
				newQueryFactory()
						.selectField('CryoSite__c')
						.selectField('CryoSite__r.Type')
						.selectField('TreatmentSite__c')
						.setCondition('CarePlanId__c IN : carePlanIds')
						.toSOQL());
	}

	public List<Order__c> selectOrdersByPatientId(Set<Id> patientIds)
	{
		return (List<Order__c>) Database.query(
				newQueryFactory()
						.selectField('Patient__r.PatientID__c')
						.selectField('TreatmentSite__r.ERPSiteID__c')
						.selectField('Name')
						.setCondition(patientId + ' IN :patientIds')
						.toSOQL());
	}

	public List<Order__c> elevatedSelectByAccountIdAndCarePlanStatus(Set<Id> accountIds, Set<String> careplanStatuses)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByAccountIdAndCarePlanStatus(accountIds, careplanStatuses);
	}

	public List<Order__c> elevatedSelectByAccountId(Set<Id> accountIds)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectByAccountId(accountIds);
	}

	public List<Order__c> elevatedSelectedByAccountCarePlanOrderStatus(Set<Id> accountIds)
	{
		ElevateContext elevatedContext = new ElevateContext(this);
		return elevatedContext.elevatedSelectedByAccountCarePlanOrderStatus(accountIds);
	}

	private without sharing class ElevateContext extends fflib_SObjectSelector
	{
		OrdersSelector selector;

		public ElevateContext(OrdersSelector selector)
		{
			super(true, false, false, true);
			this.selector = selector;
		}

		public List<Schema.SObjectField> getSObjectFieldList()
		{
			return selector.getSObjectFieldList();
		}

		public Schema.SObjectType getSObjectType()
		{
			return selector.getSObjectType();
		}

		public List<Order__c> elevatedSelectByAccountIdAndCarePlanStatus(Set<Id> accountIds, Set<String> careplanStatuses)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('ApheresisSite__r.Name');
			queryFactory.selectField('CarePlanID__r.Status');
			queryFactory.setCondition('Patient__c IN :accountIds AND CarePlanID__r.Status IN:careplanStatuses');
			return (List<Order__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<Order__c> elevatedSelectByAccountId(Set<Id> accountIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('ApheresisSite__r.Name');
			queryFactory.selectField('CarePlanID__r.Status');
			queryFactory.selectField('DateOfCancellationRequestTCP__c');
			queryFactory.selectField('ManufacturingStatus__c');
			queryFactory.setCondition('Patient__c IN :accountIds');
			return (List<Order__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}

		public List<Order__c> elevatedSelectedByAccountCarePlanOrderStatus(Set<Id> accountIds)
		{
			fflib_QueryFactory queryFactory = newQueryFactory();
			queryFactory.selectField('ApheresisSite__r.Name');
			queryFactory.selectField('OrderStatus__c');
			queryFactory.selectField('CarePlanID__r.Status');
			queryFactory.setCondition('Patient__c IN :accountIds AND (CarePlanID__r.Status =:carePlanStatusNew OR (CarePlanID__r.Status =:carePlanStatusManufactured AND ManufacturingStatus__c = :orderManufacturingStatusQRComplete))');
			queryFactory.setOrdering('CreatedDate', fflib_QueryFactory.SortOrder.DESCENDING);
			return (List<Order__c>) Database.query(String.escapeSingleQuotes(queryFactory.toSOQL()));
		}
	}

    public Database.QueryLocator getQLOfOrdersCreatedEditedInLastNDays(Integer lastNDays)
	{
		return Database.getQueryLocator(
				newQueryFactory(false, false, false)
            			.selectField(Order__c.Patient__c.getDescribe().getName())
						.setCondition(String.format('{0} = LAST_N_DAYS:{1}',
						new List<String>{
								Order__c.LastModifiedDate.getDescribe().getName(),
								String.valueOf(lastNDays)}))
						.toSOQL());
	}


}
