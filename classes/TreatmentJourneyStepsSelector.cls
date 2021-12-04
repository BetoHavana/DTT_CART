public with sharing class TreatmentJourneyStepsSelector extends fflib_SObjectSelector
{
	public static final String APHERESISPICKUP = 'Apheresis Pick-Up';
	public static final String MANUFACTURING ='Manufacturing';
	public static final String SHIPPING = 'Shipping';
	public static final String DELIVERY = 'Delivery';

	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField>
		{
				TreatmentJourneySteps__mdt.ApheresisCompleted__c,
				TreatmentJourneySteps__mdt.ApheresisPickUpSectionStatus__c,
				TreatmentJourneySteps__mdt.DeveloperName,
				TreatmentJourneySteps__mdt.DeliveryCompleted__c,
				TreatmentJourneySteps__mdt.DeliveryStatus__c,
				TreatmentJourneySteps__mdt.Id,
				TreatmentJourneySteps__mdt.InfusionCompleted__c,
				TreatmentJourneySteps__mdt.InfusionStatus__c,
				TreatmentJourneySteps__mdt.ManufacturingCompleted__c,
				TreatmentJourneySteps__mdt.ManufacturingStatus__c,
				TreatmentJourneySteps__mdt.MasterLabel,
				TreatmentJourneySteps__mdt.ShippingCompleted__c,
				TreatmentJourneySteps__mdt.ShippingStatus__c
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return TreatmentJourneySteps__mdt.sObjectType;
	}

	public List<TreatmentJourneySteps__mdt> selectApheresisStepsByStatuses(String carePlanStatus, String orderStatus, String slotStatus, String poStatus)
	{
		String section = TreatmentJourneySteps__mdt.SectionName__c.getDescribe().getName();
		String careplan = TreatmentJourneySteps__mdt.CarePlanStatus__c.getDescribe().getName();
		String order = TreatmentJourneySteps__mdt.OrderStatus__c.getDescribe().getName();
		String slot = TreatmentJourneySteps__mdt.SlotStatus__c.getDescribe().getName();
		String po = TreatmentJourneySteps__mdt.POStatus__c.getDescribe().getName();
		return (List<TreatmentJourneySteps__mdt>) Database.query(
				newQueryFactory()
						.setCondition(careplan + ' =:carePlanStatus AND ' + order + ' =:orderStatus AND ' + slot + ' =:slotStatus AND ' + po + ' =:poStatus AND ' + section + ' =:APHERESISPICKUP')
						.toSOQL()
		);
	}

	public List<TreatmentJourneySteps__mdt> selectShippingStepsByStatuses(String carePlanStatus, String orderStatus, String slotStatus, String poStatus,  String shippingStatus)
	{
		String section = TreatmentJourneySteps__mdt.SectionName__c.getDescribe().getName();
		String careplan = TreatmentJourneySteps__mdt.CarePlanStatus__c.getDescribe().getName();
		String order = TreatmentJourneySteps__mdt.OrderStatus__c.getDescribe().getName();
		String slot = TreatmentJourneySteps__mdt.SlotStatus__c.getDescribe().getName();
		String po = TreatmentJourneySteps__mdt.POStatus__c.getDescribe().getName();
		String ship = TreatmentJourneySteps__mdt.ShippingStatus__c.getDescribe().getName();
		return (List<TreatmentJourneySteps__mdt>) Database.query(
				newQueryFactory()
						.setCondition(careplan + ' =:carePlanStatus AND ' + order + ' =:orderStatus AND ' + slot + ' =:slotStatus AND ' + po + ' =:poStatus AND ' + ship + ' =:shippingStatus AND ' + section + ' =:SHIPPING')
						.toSOQL()
		);
	}

	public List<TreatmentJourneySteps__mdt> selectManufacturingStepsByStatuses(String carePlanStatus, String orderStatus, String slotStatus, String poStatus,  String manufacturingStatus)
	{
		String section = TreatmentJourneySteps__mdt.SectionName__c.getDescribe().getName();
		String careplan = TreatmentJourneySteps__mdt.CarePlanStatus__c.getDescribe().getName();
		String order = TreatmentJourneySteps__mdt.OrderStatus__c.getDescribe().getName();
		String slot = TreatmentJourneySteps__mdt.SlotStatus__c.getDescribe().getName();
		String po = TreatmentJourneySteps__mdt.POStatus__c.getDescribe().getName();
		String manufacturingStatusLabel = TreatmentJourneySteps__mdt.ManufacturingStatus__c.getDescribe().getName();
		return (List<TreatmentJourneySteps__mdt>) Database.query(
				newQueryFactory()
						.setCondition(careplan + ' =:carePlanStatus AND ' + order + ' =:orderStatus AND ' + slot + ' =:slotStatus AND ' + po + ' =:poStatus AND ' + manufacturingStatusLabel + ' =:manufacturingStatus AND ' + section + ' =:MANUFACTURING')
						.toSOQL()
		);
	}

	public List<TreatmentJourneySteps__mdt> selectDeliveryStepsByStatuses(String carePlanStatus, String orderStatus, String slotStatus, String poStatus,  String shippingStatus, String manufacturingStatus, String deliveryStatus)
	{
		String section = TreatmentJourneySteps__mdt.SectionName__c.getDescribe().getName();
		String careplan = TreatmentJourneySteps__mdt.CarePlanStatus__c.getDescribe().getName();
		String order = TreatmentJourneySteps__mdt.OrderStatus__c.getDescribe().getName();
		String slot = TreatmentJourneySteps__mdt.SlotStatus__c.getDescribe().getName();
		String po = TreatmentJourneySteps__mdt.POStatus__c.getDescribe().getName();
		String ship = TreatmentJourneySteps__mdt.ShippingStatus__c.getDescribe().getName();
		String manufacturingStatusLabel = TreatmentJourneySteps__mdt.ManufacturingStatus__c.getDescribe().getName();
		String deliveryStatusLabel = TreatmentJourneySteps__mdt.DeliveryStatus__c.getDescribe().getName();

		return (List<TreatmentJourneySteps__mdt>) Database.query(
				newQueryFactory()
						.setCondition(careplan + ' =:carePlanStatus AND ' + order + ' =:orderStatus AND ' + slot + ' =:slotStatus AND ' + po + ' =:poStatus AND ' + ship + ' =:shippingStatus AND ' + manufacturingStatusLabel + ' =:manufacturingStatus AND ' + deliveryStatusLabel + ' =:deliveryStatus AND '  + section + ' =:DELIVERY')
						.toSOQL()
		);

	}
}
