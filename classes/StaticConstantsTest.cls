@isTest
public class StaticConstantsTest {
   
    @isTest static void isAccountRole(){
        //WHEN STRING IS INSTANCED
        String accountRole = StaticConstants.accountRole;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('AccountRole',accountRole);
    }

    @isTest static void isApherisisSiteLabel(){
        //WHEN STRING IS INSTANCED
        String apheresisSite = StaticConstants.APHERESISSITE;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('ApheresisSite',apheresisSite);
    }

    @isTest static void isApheresisSiteLabel(){
        //WHEN STRING IS INSTANCED
        String apherisisLabel = StaticConstants.APHERESISSITELABEL;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Apheresis Site',apherisisLabel);
    }

    @isTest static void isApheresisConfirmedStatus(){
        //WHEN STRING IS INSTANCED
        String apherisisPickupStatus = StaticConstants.apheresisPickupConfirmedStatus;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Apheresis Pickup Date Scheduled',apherisisPickupStatus);
    }

    @isTest static void isApheresisPickupRequestedStatus(){
        //WHEN STRING IS INSTANCED
        String apherisisPickupStatus = StaticConstants.apheresisPickupRequestedStatus;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Apheresis Pickup Date Requested',apherisisPickupStatus);
    }

    @isTest static void isApheresisPOReceived(){
        //WHEN STRING IS INSTANCED
        String apheresisPOReceived = StaticConstants.apheresisPOReceived;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Aph PO Received',apheresisPOReceived);
    }

    @isTest static void isBlankValue(){
        //WHEN STRING IS INSTANCED
        String blankString = StaticConstants.BLANKVALUE;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals(' ',blankString);
    }

    @isTest static void isCaregiverRecordType(){
        //WHEN STRING IS INSTANCED
        String caregiverRecordType = StaticConstants.CaregiverRecordTypeDeveloperName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Caregiver',caregiverRecordType);
    }

    @isTest static void isCarePlanRecordType(){
        //WHEN STRING IS INSTANCED
        String carePlanRecordType = StaticConstants.CarePlanRecordTypeDeveloperName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('CarePlan',carePlanRecordType);
    }

    @isTest static void isCarePlanStatusNew(){
        //WHEN STRING IS INSTANCED
        String carePlanStatus = StaticConstants.carePlanStatusAsNew;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('New',carePlanStatus);
    }

    @isTest static void isCarePlanStatusApheresed(){
        //WHEN STRING IS INSTANCED
        String carePlanStatus = StaticConstants.carePlanStatusAsApheresed;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Apheresed',carePlanStatus);
    }

    @isTest static void isCarePlanStatusDPShipped(){
        //WHEN STRING IS INSTANCED
        String carePlanStatus = StaticConstants.carePlanStatusAsDrugProductShipped;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Drug Product Shipped',carePlanStatus);
    }

    @isTest static void isCarePlanStatusInfused(){
        //WHEN STRING IS INSTANCED
        String carePlanStatus = StaticConstants.carePlanStatusAsInfused;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Infused',carePlanStatus);
    }

    @isTest static void isCARTCoordinator(){
        //WHEN STRING IS INSTANCED
        String cartCoordinator = StaticConstants.CARTCOORDINATOR;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('CAR-T Coordinator',cartCoordinator);
    }

    @isTest static void isComma(){
        //WHEN STRING IS INSTANCED
        String commaString = StaticConstants.COMMA;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals(',',commaString);
    }

    @isTest static void isColon(){
        //WHEN STRING IS INSTANCED
        String colonString = StaticConstants.COLON;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals(':',colonString);
    }

    @isTest static void isCompleted(){
        //WHEN STRING IS INSTANCED
        String completedString = StaticConstants.completedStatus;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Completed',completedString);
    }

    @isTest static void isContactContactRelation(){
        //WHEN STRING IS INSTANCED
        String ccRelation = StaticConstants.contactContactRelation;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Contact Contact Relation',ccRelation);
    }

    @isTest static void isContactRole(){
        //WHEN STRING IS INSTANCED
        String contactRoleString = StaticConstants.contactRole;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('ContactRole',contactRoleString);
    }

    @isTest static void isCryoCellDelivered(){
        //WHEN STRING IS INSTANCED
        String cryoCellDelivered = StaticConstants.cryoCellsDelivered;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Cryo-ed Cells Delivered',cryoCellDelivered);
    }

    @isTest static void isCentral(){
        //WHEN STRING IS INSTANCED
        String centralString = StaticConstants.CryoSiteCentral;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Central',centralString);
    }

    @isTest static void isDrugProductDelivered(){
        //WHEN STRING IS INSTANCED
        String dpDelivered = StaticConstants.drugProductDelivered;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Drug Product Delivered',dpDelivered);
    }

    @isTest static void isCryoSite(){
        //WHEN STRING IS INSTANCED
        String cryoSite = StaticConstants.CRYOSITE;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('CryoSite',cryoSite);
    }

    @isTest static void isCryoSiteLabel(){
        //WHEN STRING IS INSTANCED
        String cryoSiteLabel = StaticConstants.CRYOSITELABEL;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Cryo Site',cryoSiteLabel);
    }

    @isTest static void isCryoSiteLocal(){
        //WHEN STRING IS INSTANCED
        String csLocal = StaticConstants.cryoSiteLocal;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Local',csLocal);
    }

    @isTest static void isCryoTypeRaritan(){
        //WHEN STRING IS INSTANCED
        String ctRaritan = StaticConstants.cryoTypeRaritan;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Raritan',ctRaritan);
    }

    @isTest static void isDeliveryFinalToInfusionSite(){
        //WHEN STRING IS INSTANCED
        String deliveryFinal = StaticConstants.deliveryOfFinalProductToInfusionTreatmentSite;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Confirmation on delivery of final product to the Infusion/ Treatment Site',deliveryFinal);
    }

    @isTest static void isFreshCellDelivered(){
        //WHEN STRING IS INSTANCED
        String freshCellDelivered = StaticConstants.freshCellsDelivered;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Fresh Cells Delivered',freshCellDelivered);
    }
    @isTest static void isFinalProductDelivered(){
        //WHEN STRING IS INSTANCED
        String fproductDelivered = StaticConstants.finalProductDelivered;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Drug Product Delivered',fproductDelivered);
    }

    @isTest static void isGoalName(){
        //WHEN STRING IS INSTANCED
        String goal = StaticConstants.goalName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Shipping (Apheresis Site to Cryo Site)',goal);
    }
    
    @isTest static void isSlotConfirmed(){
        //WHEN STRING IS INSTANCED
        String slotConfirmed = StaticConstants.hardSlotReserved;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Slot Confirmed',slotConfirmed);
    }

    @isTest static void isInProgress(){
        //WHEN STRING IS INSTANCED
        String inProgress = StaticConstants.inProgressStatus;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('In Progress',inProgress);
    }
    
    @isTest static void isManufacturing(){
        //WHEN STRING IS INSTANCED
        String manufacturing = StaticConstants.MANUFACTURING;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Manufacturing',manufacturing);
    }

    @isTest static void isManufacturingComplete(){
        //WHEN STRING IS INSTANCED
        String manufacturingComplete = StaticConstants.manufacturingComplete;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Manufacturing Complete',manufacturingComplete);
    }
    
    @isTest static void isManufacturingNotStarted(){
        //WHEN STRING IS INSTANCED
        String notStarted = StaticConstants.manufacturingNotStarted;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Not Started',notStarted);
    }

    @isTest static void isManufacturingSiteDevName(){
        //WHEN STRING IS INSTANCED
        String manufacturingSite = StaticConstants.manufacturingSiteRecTypeDeveloperName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('ManufacturingSite',manufacturingSite);
    }
    
    @isTest static void isManufacturingStarted(){
        //WHEN STRING IS INSTANCED
        String manufacturingStarted = StaticConstants.MANUFACTURING_STARTED;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Manufacturing Started',manufacturingStarted);
    }

    @isTest static void isNameLabel(){
        //WHEN STRING IS INSTANCED
        String nameLabel = StaticConstants.NAMELABEL;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Name',nameLabel);
    }
    
    @isTest static void isInfusionComplete(){
        //WHEN STRING IS INSTANCED
        String infusionComplete = StaticConstants.orderInfusionComplete;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Infusion Complete',infusionComplete);
    }

    @isTest static void isOrderInProgress(){
        //WHEN STRING IS INSTANCED
        String orderInProgress = StaticConstants.orderInProgress;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order In Progress',orderInProgress);
    }
    
    @isTest static void isOrderInProgressStatus(){
        //WHEN STRING IS INSTANCED
        String orderInProgress = StaticConstants.orderInProgressStatus;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order In Progress',orderInProgress);
    }

    @isTest static void isOrderPlacement(){
        //WHEN STRING IS INSTANCED
        String orderPlacement = StaticConstants.orderPlacement;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order Placement',orderPlacement);
    }
    
    @isTest static void isOrderRescheduled(){
        //WHEN STRING IS INSTANCED
        String orderRescheduled = StaticConstants.OrderRescheduled;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order Rescheduled',orderRescheduled);
    }

    @isTest static void isOrderSubmitted(){
        //WHEN STRING IS INSTANCED
        String orderSubmitted = StaticConstants.orderSubmitted;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order Submitted',orderSubmitted);
    }
    
    @isTest static void isOrderVerified(){
        //WHEN STRING IS INSTANCED
        String orderVerified = StaticConstants.orderVerified;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Order Verified',orderVerified);
    }

    @isTest static void isPatientRecordType(){
        //WHEN STRING IS INSTANCED
        String patientRecordType = StaticConstants.PatientRecordTypeDeveloperName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Patient',patientRecordType);
    }
    
    @isTest static void isPOPending(){
        //WHEN STRING IS INSTANCED
        String poPending = StaticConstants.POPending;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('PO Pending',poPending);
    }

    @isTest static void isPOReceived(){
        //WHEN STRING IS INSTANCED
        String poReceived = StaticConstants.POReceived;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('PO Received',poReceived);
    }
    
    @isTest static void isVerified(){
        //WHEN STRING IS INSTANCED
        String verified = StaticConstants.PatientStatusVerified;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Verified',verified);
    }

    @isTest static void isQCQAComplete(){
        //WHEN STRING IS INSTANCED
        String qcQaComplete = StaticConstants.QC_QA_COMPLETE;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('QC/QA Complete',qcQaComplete);
    }

    @isTest static void isQrComplete(){
        //WHEN STRING IS INSTANCED
        String qrComplete = StaticConstants.QRCOMPLETED;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('QR Complete',qrComplete);
    }

    @isTest static void isRecordInfusionDate(){
        //WHEN STRING IS INSTANCED
        String recordInfusionDate = StaticConstants.RECORDINFUSIONDATE;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Record Infusion Date',recordInfusionDate);
    }    

    @isTest static void isRequestPayload(){
        //WHEN STRING IS INSTANCED
        String requestPayload = StaticConstants.REQUESTPAYLOAD;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals(' Request Payload : ',requestPayload);
    }

    @isTest static void isRequestPayloadNew(){
        //WHEN STRING IS INSTANCED
        String requestPayloadNew = StaticConstants.REQUESTTYPENEW;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('New',requestPayloadNew);
    }
    
    @isTest static void isRequestPayloadRescheduled(){
        //WHEN STRING IS INSTANCED
        String requestPayloadR = StaticConstants.REQUESTTYPERESCHEDULED;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Rescheduled',requestPayloadR);
    }

    @isTest static void isShippingFinalProduct(){
        //WHEN STRING IS INSTANCED
        String shippingDP = StaticConstants.shippingFinalProduct;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Shipping Drug Product',shippingDP);
    }

    @isTest static void isShippingFreshCells(){
        //WHEN STRING IS INSTANCED
        String shippingFC = StaticConstants.shippingFreshCells;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Shipping Fresh Cells',shippingFC);
    }

    @isTest static void isShippingCryoCells(){
        //WHEN STRING IS INSTANCED
        String shippingCC = StaticConstants.shippingCryoCells;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Shipping Cryo-ed Cells',shippingCC);
    }

    @isTest static void isSlotBooking(){
        //WHEN STRING IS INSTANCED
        String slotBooking = StaticConstants.SLOTBOOKING;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Slot Booking',slotBooking);
    }

    @isTest static void isSlotSoftConfirmed(){
        //WHEN STRING IS INSTANCED
        String slotConfirmed = StaticConstants.softSlotConfirmed;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Slot Confirmed',slotConfirmed);
    }

    @isTest static void isSlotRequested(){
        //WHEN STRING IS INSTANCED
        String slotRequested = StaticConstants.softSlotRequested;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Slot Requested',slotRequested);
    }

    @isTest static void isSubjectLabel(){
        //WHEN STRING IS INSTANCED
        String subjectLabel = StaticConstants.SUBJECTLABEL;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Subject',subjectLabel);
    }

    @isTest static void isTransactionName(){
        //WHEN STRING IS INSTANCED
        String transactionName = StaticConstants.TRANSACTIONNAME;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Transaction Name : ',transactionName);
    }

    @isTest static void isTreatmentSite(){
        //WHEN STRING IS INSTANCED
        String treatmentSite = StaticConstants.TreatmentSiteRecordTypeDeveloperName;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('TreatmentSite',treatmentSite);
    }

    @isTest static void isTreatmentSiteLabel(){
        //WHEN STRING IS INSTANCED
        String treatementSiteLabel = StaticConstants.TREATMENTSITELABEL;
        //THEN IT SHOULD HAVE AN EXPECTED VALUE
        System.assertEquals('Treatment Site',treatementSiteLabel);
    }
}
