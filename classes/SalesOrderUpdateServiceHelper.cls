public with sharing class SalesOrderUpdateServiceHelper implements ICalloutServiceHelper
{

	static final String EMPTYSTRING ='';

	Public Map<Id, String> getCalloutInputRequestBody(Set<Id> orderIds)
	{
		Map<Id, String> orderIdNInputBody = new Map<Id, String>();
		Map<Id, Account> spIdNSDInfo = new Map<Id, Account>();

		List<Order__c> orders = ((OrdersSelector) Application.Selector
				                .newInstance(Order__c.SObjectType))
				                .selectOrdersByOrderId(orderIds);

		Set<Id> treatmentSiteIds = sflib_ArrayUtils.pluckIdField(orders, Order__c.TreatmentSite__c);

		if (treatmentSiteIds.isEmpty()) return orderIdNInputBody;


		Map<Id, Account> treatmentSitesInfo = ((AccountsSelector) Application.Selector.newInstance
				(Account.SObjectType)).selectById(treatmentSiteIds).getById();

		Map<Id, AssociatedLocation> accountIdNLocationInfo = ((AssociatedLocationsService) Application.service
                                                             .newInstance(AssociatedLocationsService.class))
				                                             .getAccountsAddressInfo(treatmentSiteIds);

		SiteProductsService spService = (SiteProductsService) Application.Service.newInstance(SiteProductsService.class);

		Map<Id, SiteProduct__c> siteIdNsiteProductInfo = spService.getSiteIdNsiteProductInfo(treatmentSiteIds);

		SalesOrderUpdateServiceInput input = new SalesOrderUpdateServiceInput();
		for (Order__c order : orders)
		{
			if (order.TreatmentSite__c == null) continue;
			input = new SalesOrderUpdateServiceInput();
			setOrderInfo(input, order);
			input.CARTShipToAccount = treatmentSitesInfo.get(order.TreatmentSite__c).AccountIdentifier__c;
			input.shipToCode = nullCheckStringAndPassBlankIfEmpty(treatmentSitesInfo.get(order.TreatmentSite__c).CustomerCode__c);
			input.soldToCode = getSoldToCode(siteIdNsiteProductInfo?.get(order.TreatmentSite__c));
			input.shipToAddress = getShipToAddress(accountIdNLocationInfo?.get(order.TreatmentSite__c));
			input.atlasVendorCode = nullCheckStringAndPassBlankIfEmpty(treatmentSitesInfo?.get(order.TreatmentSite__c)?.ERPSiteID__c);
			setProductInfo(input, siteIdNsiteProductInfo.get(order.TreatmentSite__c), order.CryoSiteType__c);
			orderIdNInputBody.put(order.Id, JSON.serialize((SalesOrderUpdateServiceInput) input));
		}

		return orderIdNInputBody;
	}

	String getSoldToCode(SiteProduct__c siteProduct)
	{
		return nullCheckStringAndPassBlankIfEmpty(siteProduct?.SpecialtyDistributor__r?.ERPSiteID__c);
	}

	SalesOrderUpdateServiceInput.shipToAddress getShipToAddress(Schema.AssociatedLocation treatmentSiteLocation)
	{
		if (treatmentSiteLocation == null || treatmentSiteLocation.Location == null) return null;

		SalesOrderUpdateServiceInput.shipToAddress shipToAddress = new SalesOrderUpdateServiceInput.shipToAddress();
		shipToAddress.shipToName = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.ParentRecord.Name);
		shipToAddress.city = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.City__c);
		shipToAddress.zipCodeNo = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.PostalCode__c);
		shipToAddress.addressLine2 = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.AddressLine2__c) ;
		shipToAddress.stateRegion = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.State__c);
		shipToAddress.addressLine1 = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.AddressLine1__c);
		shipToAddress.addressLine3 = '';
		shipToAddress.addressLine4 = '';
		shipToAddress.country = nullCheckStringAndPassBlankIfEmpty(treatmentSiteLocation.Location.Country__c);

		return shipToAddress;
	}

	String nullCheckStringAndPassBlankIfEmpty(String sourceValue)
	{
		return String.isNotBlank(sourceValue) ? sourceValue : EMPTYSTRING;
	}

	void setProductInfo(SalesOrderUpdateServiceInput input, SiteProduct__c siteProduct, String cryoType)
	{
		if (siteProduct == null || siteProduct.Product__r == null) return ;

		SalesOrderUpdateServiceInput.apheresis apheresis = new SalesOrderUpdateServiceInput.apheresis();

		input.salesOrderType = siteProduct.Product__r.SalesOrderType__c;
		apheresis.UOM = siteProduct.Product__r.UOMApheresis__c;
		apheresis.quantity = siteProduct.Product__r.QuantityAphersis__c;
		apheresis.material = StaticConstants.cryoTypeRaritan.equalsIgnoreCase(cryoType) ?
				siteProduct.Product__r.ApheresisMaterialCodeFresh__c :
				siteProduct.Product__r.ApheresisMaterialCodeFrozen__c;
		input.apheresis = apheresis;

		input.finishedGoods = new SalesOrderUpdateServiceInput.finishedGoods(
				siteProduct.Product__r.MaterialNoFG__c,
				siteProduct.Product__r.QuantityFG__c,
				siteProduct.Product__r.UOMFG__c);

	}

	void setOrderInfo(SalesOrderUpdateServiceInput input, Order__c order)
	{
		input.SDPONo = nullCheckStringAndPassBlankIfEmpty(order.SDPO__c);
		input.QTCPONo = nullCheckStringAndPassBlankIfEmpty(order.SitePO__c);
		input.projectedDeliveryDueDate = string.valueOf(order.ProjectedDeliveryDate__c);
		input.CARTOrderId = order.CartOrderId__c;
	}
}
