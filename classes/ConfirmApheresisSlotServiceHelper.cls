public with sharing class ConfirmApheresisSlotServiceHelper
{

    public String getApheresisSlotConfirmServiceRequest(SlotAndOrderUpdateInfo slotInfo)
    {
        ConfirmSlotBookingServiceInput input = new ConfirmSlotBookingServiceInput();
        input.CARTOrderId = slotInfo?.order?.CartOrderId__c;
        input.cryoType = slotInfo.cryoType;
        input.apheresisPickUpDate = slotInfo.aphPickUpDate;
        input.apheresisSiteId = slotInfo.apheresisSiteERPId;
        input.projectedDeliveryDate = slotInfo.projectedDeliveryDate;
        input.requestType = slotInfo.requestType;
        setProductLocationInfo(input, slotInfo);

        return JSON.serialize(input);
    }

    private Class ConfirmSlotBookingServiceInput
    {
        String apheresisPickUpDate;
        String projectedDeliveryDate;
        String CARTOrderId;
        String therapyType;
        String cryoType;
        String apheresisSiteId;
        String product;
        String region;
        String country;
        String requestType;
    }

    void setProductLocationInfo(ConfirmSlotBookingServiceInput input, SlotAndOrderUpdateInfo slotInfo)
    {
        List<AssociatedLocation> associatedLocationsInfo = ((AssociatedLocationsSelector) Application.Selector
                                                            .newInstance(AssociatedLocation.SObjectType))
                                                            .elevatedGetAddressesForSites(new Set<Id> {slotInfo.order.TreatmentSite__c});
        if (!associatedLocationsInfo.isEmpty())
        {
            input.country = associatedLocationsInfo[0].Location?.Country__c;
            List<CountryToRegionMapping__mdt> careProgramCountryToRegionList = ((CountryToRegionMappingSelector) Application.Selector
                                                                                .newInstance(CountryToRegionMapping__mdt.SObjectType))
                                                                                .selectAll(associatedLocationsInfo[0].Location?.Country__c);
            input.region = !careProgramCountryToRegionList.isEmpty() ? careProgramCountryToRegionList[0].Region__c : null;
        }
        input =getPatientCareProgramProductInfo(new Set<Id>{slotInfo?.order?.Patient__c}, input);
    }

    public ConfirmSlotBookingServiceInput getPatientCareProgramProductInfo(Set<Id> patientIds, ConfirmSlotBookingServiceInput input)
    {
        List<CareProgramEnrollee> careProgramEnrolleeList = ((CareProgramEnrolleesSelector) Application.Selector.newInstance(CareProgramEnrollee.SObjectType))
                                                            .elevatedSelectByAccountId(patientIds);
        List<CareProgramEnrolleeProduct> careProgramEnrolleeProductList = new List<CareProgramEnrolleeProduct>();

        if (!careProgramEnrolleeList.isEmpty())
        {
            careProgramEnrolleeProductList = ((CareProgramEnrolleeProductsSelector) Application.Selector.newInstance(CareProgramEnrolleeProduct.SObjectType))
                                              .elevatedSelectByCPEnrolleeId(new Set<Id> {careProgramEnrolleeList[0].Id});
        }
        if (!careProgramEnrolleeProductList.isEmpty())
        {
            Set<Id> careProgramProductIds = new Set<Id>();
            careProgramProductIds.add(careProgramEnrolleeProductList[0].CareProgramProductId);
            if(careProgramProductIds.isEmpty()) return input;

            List<CareProgramProduct> careProgramProducts = ((CareProgramProductsSelector) Application.Selector.newInstance(CareProgramProduct.SObjectType))
                                                            .elevatedSelectById(careProgramProductIds);

            if(careProgramProducts.isEmpty()) return input;
            input.therapyType = careProgramProducts[0].Product.TherapyType__c;
            input.product = careProgramProducts[0].Product.Name;
        }
        return input;
    }
}
