import { LightningElement, api, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import { refreshApex } from '@salesforce/apex';
import ORDERS_OBJECT from '@salesforce/schema/Order__c';
import REASONFORCANCEL_FIELD from '@salesforce/schema/Order__c.ReasonForOrderWithdrawal__c';


import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource';

import fetchPatientServiceEligibilty from '@salesforce/apex/PatientJourneyController.fetchPatientServiceEligibilty';
import fetchPatientServiceEnrollee from '@salesforce/apex/PatientJourneyController.fetchPatientServiceEnrollees';
import getDetailsByPatientId from '@salesforce/apex/PatientJourneyController.getDetailsByPatientId';
import getNextThreeBussinessDays from '@salesforce/apex/PatientJourneyController.getNextThreeBussinessDays';
import isBussinessDayDueForReschedule from '@salesforce/apex/PatientJourneyController.isBussinessDayDueForReschedule';
import updateCarePlan from '@salesforce/apex/PatientJourneyController.updateCarePlan';
import updateOrder from '@salesforce/apex/PatientJourneyController.updateOrder';
import updateDeliveryDateOnOrder from '@salesforce/apex/PatientJourneyController.updateDeliveryDateOnOrder';
import updateInfusedDateOnOrder from '@salesforce/apex/PatientJourneyController.updateInfusedDateOnOrder';

import ACTIVE_LABEL from '@salesforce/label/c.Active';
import ALERTS_LABEL from '@salesforce/label/c.Alerts';
import APHERESIS_PICKUP_LABEL from '@salesforce/label/c.ApheresisPickUp';
import APHERESIS_PICKUP_CANCELLATION_REQUESTED_LABEL from '@salesforce/label/c.ApheresisPickupCancellationRequested';
import APHERESIS_PICKUP_DATE_LABEL from '@salesforce/label/c.ApheresisPickUpDate';
import APHERESIS_PICKUP_DETAILS_LABEL from '@salesforce/label/c.ApheresisPickUpDetails';
import APHERESIS_PICKUP_SITE_LABEL from '@salesforce/label/c.ApheresisPickUpSite';
import AVAILABILITY_CALENDAR_RESCHEDULE_HELP_TEXT from '@salesforce/label/c.AvailabilityCalendarRescheduleHelpText';
import AVAILABLE_DATES_RECORD_INFUSION from '@salesforce/label/c.AvailableDatesRecordInfusion';
import CANCEL_ORDER_LABEL from '@salesforce/label/c.CancelOrder';
import CAREGIVERINFORMATION_LABEL from '@salesforce/label/c.CaregiverInformation';
import CART_COORDINATOR_LABEL from '@salesforce/label/c.CARTCoordinator';
import CONFIRMED_DRUG_PRODUCT_DELIVERY_DATE from '@salesforce/label/c.ConfirmedDrugProductDeliveryDate';
import CONFIRMED_PROJECTED_DELIVERY_DATEHELPTEXT from '@salesforce/label/c.ConfirmedProjectedDeliveryDateHelpText';
import CRYO_TYPE_LABEL from '@salesforce/label/c.CryoType';
import DATES_AVAILABLE_FOR_DRUGPRODUCTDELIVERY from '@salesforce/label/c.DatesAvailableForDrugProductDelivery';
import DATES_AVAILABLE_FOR_INFUSION from '@salesforce/label/c.DatesAvailForInfusion';
import DELIVERY_LABEL from '@salesforce/label/c.Delivery';
import DOCUMENTS_LABEL from '@salesforce/label/c.Documents';
import DOB_LABEL from '@salesforce/label/c.Date_of_Birth';
import DRUG_PRODUCT_DELIVERY_DATE from '@salesforce/label/c.DrugProductDeliveryDate';
import EMAIL_ADDRESS_LABEL from '@salesforce/label/c.EmailAddress';
import ENQUIRE_LABEL from '@salesforce/label/c.Enquire';
import ENROLLMENT_LABEL from '@salesforce/label/c.Enrollment';
import FINDOUT_MORE_LABEL from '@salesforce/label/c.FindOutMore';
import FIRSTNAME_LABEL from '@salesforce/label/c.Name';
import INFUSION_DATE from '@salesforce/label/c.InfusionDate';
import INFUSION_LABEL from '@salesforce/label/c.Infusion';
import INFUSION_DATE_HELPTEXT from '@salesforce/label/c.InfusionDateHelpText';
import MANUFACTURING_LABEL from '@salesforce/label/c.Manufacturing';
import MRN_LABEL from '@salesforce/label/c.MRN';
import OK_LABEL from '@salesforce/label/c.OK';
import ORDER_CANCELLATION_DISCLAIMER_LABEL from '@salesforce/label/c.OrderCancellationDisclaimer';
import ORDER_CANCELLATION_SUBMIT_REQUEST_LABEL from '@salesforce/label/c.OrderCancellationSubmitRequest';
import ORDER_CANCELLATION_VIA_PHONE_TEXT from '@salesforce/label/c.OrderCancellationViaPhoneText';
import ORDER_DETAILS_LABEL from '@salesforce/label/c.OrderDetails';
import PATIENT_ID from '@salesforce/label/c.PatientId';
import PATIENT_INFORMATION_LABEL from '@salesforce/label/c.PatientInformation';
import PATIENT_LABEL from '@salesforce/label/c.Patient';
import PATIENT_SERVICE_AGENT_LABEL from '@salesforce/label/c.PatientServiceAgent';
import PATIENT_SERVICE_CHECK_LABEL from '@salesforce/label/c.PatientServiceProgramsCheck';
import PATIENT_SERVICE_DISCLAIMER_LABEL from '@salesforce/label/c.PatientServiceDisclaimerText';
import PATIENT_SERVICE_LABEL from '@salesforce/label/c.PatientServicePrograms';
import PATIENT_SERVICE_PROGRAM_DISCLAIMER_LABEL from '@salesforce/label/c.PatientServiceProgramDisclaimerText';
import PATIENT_SERVICE_PROGRAMS_DISCLAIMER_LABEL from '@salesforce/label/c.PatientServiceProgramsDisclaimerText';
import PATIENT_SERVICE_PROGRAMS_INELIGIBLE_LABEL from '@salesforce/label/c.PatientServiceProgramIneligible';
import PATIENT_SERVICE_PROGRAMS_POPUP_DISCLAIMER_LABEL from '@salesforce/label/c.PatientServiceProgramsDisclaimer';
import PATIENT_SERVICE_PROGRAM_LABEL from '@salesforce/label/c.PatientServicePrograms';
import PATIENT_SERVICE_PROGRAM_TRAVEL_LABEL from '@salesforce/label/c.PatientServiceProgramTravelAndLogistics';
import PO_NUMBER_LABEL from '@salesforce/label/c.PONumber';
import PREFERRED_METHOD_OF_COMMUNICATION_LABEL from '@salesforce/label/c.PreferredMethodofCommunication';
import PRIMARY_CONTACT_NUMBER_LABEL from '@salesforce/label/c.PrimaryContactNumber';
import PRIMARY_PHONE_NUMBER_TYPE_LABEL from '@salesforce/label/c.PrimaryPhoneNumberType';
import PROJECTED_DRUG_PRODUCT_DELIVERYDATE from '@salesforce/label/c.ProjectedDrugProductDeliveryDate';
import PROJECTED_DELIVERY_DATE from '@salesforce/label/c.DrugProductDeliveryWindow';
import PROJECTED_DELIVERY_DATE_HELPTEXT from '@salesforce/label/c.ProjectedDeliveryDateHelpText';
import PROVIDE_REASON_FOR_ORDERCANCELLATION_LABEL from '@salesforce/label/c.ProvideReasonForOrderCancellation';
import REASON_FOR_ORDERCANCELLATION_LABEL from '@salesforce/label/c.ReasonForOrderCancellation';
import RESCHEDULE_APHERESIS_PICKUP from '@salesforce/label/c.RescheduleApheresisPickUp';
import RELATIONSHIP_TO_PATIENT_LABEL from '@salesforce/label/c.RelationshiptoPatient';
import SAVE_BUTTON from '@salesforce/label/c.SaveButton';
import SCHEDULE_APHERESIS_PICKUP_LABEL from '@salesforce/label/c.ScheduleApheresis';
import SCHEDULED_DRUG_PRODUCT_DELIVERY from '@salesforce/label/c.ScheduleDrugProductDelivery';
import SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT from '@salesforce/label/c.ScheduledDrugProductDeliveryErrorText';
import SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT_WEEKEND from '@salesforce/label/c.ScheduledDrugProductDeliveryErrorTextWeekend';
import SCHEDULED_DRUG_PRODUCT_DELIVERY_OUTRANGE_ERRORTEXT from
  '@salesforce/label/c.ScheduledDrugProductDeliveryOutRangeErrorText';
import SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT from '@salesforce/label/c.ScheduledDrugProductDeliveryHelpText';
import SELECTED_DATE from '@salesforce/label/c.SelectedDate';
import SELECT_INFUSION_DATE from '@salesforce/label/c.SelectInfusionDate';
import SELECTED_INFUSION_DATE from '@salesforce/label/c.SelectedInfusionDate';
import SELECTED_DRUG_PRODUCT_DELIVERY_DATE from '@salesforce/label/c.SelectedDrugProductDeliveryDate';
import SHIPPING_LABEL from '@salesforce/label/c.Shipping';
import SUBMIT_LABEL from '@salesforce/label/c.Submit';
import SUBMIT_REQUEST_LABEL from '@salesforce/label/c.SubmitRequest';
import SUCCESS_LABEL from '@salesforce/label/c.Success';
import TODAY_DATE_LABEL from '@salesforce/label/c.TodayDate';
import TREATING_PHYSICIAN_LABEL from '@salesforce/label/c.TreatingPhysician';
import TREATMENT_CENTER_COORDINATOR_LABEL from '@salesforce/label/c.TreatmentCenterCoordinator';
import TREATMENT_JOURNEY_LABEL from '@salesforce/label/c.TreatmentJourney';
import TREATMENT_TEAM_LABEL from '@salesforce/label/c.TreatmentTeam';
import UNFORTUNATELY_LABEL from '@salesforce/label/c.Unfortunately';

const AVAILABLE_DATE_COLOR = '#DAFBE1';

export default class PatientJourney extends NavigationMixin(LightningElement) {
  @api recordId;

  @track apheresisCryoType = '';

  @track apheresisPickupDate = '';

  @track apheresisPickupSite = '';

  @track apheresisPickupStatus = '';

  @track apheresisSitePO = '';

  @track checkBoxData;

  @track confirmedFPDelieveryDate = '';

  @track coordinatoruserName ='';

  @track cryoType;

  @track delieveryDateError = false;

  @track delieveryRange = [];

  @track delieveryDateInrangeError = false;

  @track delieveryDateInrangeWeekendError = false;

  @track deliveryStatus = '';

  @track enablePatientService = false;

  @track enrollStatus = '';

  @track events = [];

  @track infusionDate;

  @track infusionDateError = false;

  @track infusionEvents = [];

  @track infusionStatus = '';

  @track infusionRange = [];

  @track isApheresisCompleted = false;

  @track isApheresisPickUpScheduled = false;

  @track isAvailableForReschedule = false;

  @track isDeliveryCompleted = false;

  @track isEnrollcompleted =false;

  @track isInfusionCompleted = false;

  @track isManufacturingCompleted = false;

  @track isPatientServiceProgram = false;

  @track isShippingCompleted = false;

  @track isSubmitted = false;

  @track manufacturingStatus = '';

  @track orderStatus;

  @track openCalendar = false;

  @track openInfusionCalendar = false;

  @track patientDetails = [];

  @track patientDetailsWrapper ='';

  @track patientEnrolleeStatus;

  @track patientJourneyDOB = '';

  @track patientJourneyEmail = '';

  @track patientJourneyMRN = '';

  @track patientJourneyPatientId = '';

  @track patientPreferredMethodOfCommunication = '';

  @track patientPrimaryContactType = '';

  @track patientJourneyPhone = '';

  @track patientJourneyStatus = '';

  @track patientName;

  @track PatientServiceProgram;

  @track PatientServiceProgramStatus;

  @track projectedDeliveryDate='';

  @track readonlyChild = true;

  @track selectedDeliveryDate = '';

  @track selectedInfusionDate = '';

  @track selectedPhysicianTitle = '';

  @track shippingStatus = '';

  @track showCareGiverSection = false;

  @track showFindOutMoreButton = false;

  @track showSubmitButton = false;

  @track showOrderCancellationModal = false;

  @track showOrderCancellationViaPhoneModal = false;

  @track toggleFilter = false;

  cancelReasonOptions;

  carePlanStatus;

  cryoedCellsDeliveredStatus = 'Cryo-ed Cells Delivered';

  cryoTypeCentral = 'Central';

  cryoTypeLocal = 'Local';

  drugProductDeliveredStatus = 'Drug Product Delivered';

  drugProductShippedStatus = 'Drug Product Shipped';

  enrolledInServiceStatus = 'Enrolled in Service';

  freshCellsDeliveredStatus = 'Fresh Cells Delivered';

  ineligibleStatus = 'Ineligible';

  infusedStatus = 'Infused';

  manufacturing = 'Manufacturing';

  maxDigits = 36;

  orderCancelRequestDate;

  orderCancelledStatus = 'Order Cancelled';

  patientEnrollmentFormReceivedStatus = 'Patient Enrollment Form Received';

  randomIdEndInd = 9;

  randomIdStartInd = 2;

  selectedOrderCancellationReason;

  shippingDrugProductStatus = 'Shipping Drug Product';

  showOrderCancellationReasonMandatory = false;

  status = 'Verified';

  showWeekend = true;

  connectedCallback() {
    if (this.recordId) {
      this.handleFetchPatientServices();
      this.handleFetchPatientServicesProgramsStatus();
    }
  }

  labels = {
    ACTIVE_LABEL,
    ALERTS_LABEL,
    APHERESIS_PICKUP_LABEL,
    APHERESIS_PICKUP_CANCELLATION_REQUESTED_LABEL,
    APHERESIS_PICKUP_DATE_LABEL,
    APHERESIS_PICKUP_DETAILS_LABEL,
    APHERESIS_PICKUP_SITE_LABEL,
    AVAILABILITY_CALENDAR_RESCHEDULE_HELP_TEXT,
    AVAILABLE_DATES_RECORD_INFUSION,
    CANCEL_ORDER_LABEL,
    CAREGIVERINFORMATION_LABEL,
    CART_COORDINATOR_LABEL,
    CONFIRMED_DRUG_PRODUCT_DELIVERY_DATE,
    CONFIRMED_PROJECTED_DELIVERY_DATEHELPTEXT,
    CRYO_TYPE_LABEL,
    DATES_AVAILABLE_FOR_DRUGPRODUCTDELIVERY,
    DATES_AVAILABLE_FOR_INFUSION,
    DELIVERY_LABEL,
    DOCUMENTS_LABEL,
    DOB_LABEL,
    DRUG_PRODUCT_DELIVERY_DATE,
    EMAIL_ADDRESS_LABEL,
    ENQUIRE_LABEL,
    ENROLLMENT_LABEL,
    FINDOUT_MORE_LABEL,
    FIRSTNAME_LABEL,
    INFUSION_DATE,
    INFUSION_LABEL,
    INFUSION_DATE_HELPTEXT,
    MANUFACTURING_LABEL,
    MRN_LABEL,
    OK_LABEL,
    ORDER_CANCELLATION_DISCLAIMER_LABEL,
    ORDER_CANCELLATION_SUBMIT_REQUEST_LABEL,
    ORDER_CANCELLATION_VIA_PHONE_TEXT,
    ORDER_DETAILS_LABEL,
    PATIENT_ID,
    PATIENT_INFORMATION_LABEL,
    PATIENT_LABEL,
    PATIENT_SERVICE_AGENT_LABEL,
    PATIENT_SERVICE_CHECK_LABEL,
    PATIENT_SERVICE_DISCLAIMER_LABEL,
    PATIENT_SERVICE_LABEL,
    PATIENT_SERVICE_PROGRAM_DISCLAIMER_LABEL,
    PATIENT_SERVICE_PROGRAMS_DISCLAIMER_LABEL,
    PATIENT_SERVICE_PROGRAMS_INELIGIBLE_LABEL,
    PATIENT_SERVICE_PROGRAMS_POPUP_DISCLAIMER_LABEL,
    PATIENT_SERVICE_PROGRAM_LABEL,
    PATIENT_SERVICE_PROGRAM_TRAVEL_LABEL,
    PO_NUMBER_LABEL,
    PREFERRED_METHOD_OF_COMMUNICATION_LABEL,
    PRIMARY_CONTACT_NUMBER_LABEL,
    PRIMARY_PHONE_NUMBER_TYPE_LABEL,
    PROJECTED_DRUG_PRODUCT_DELIVERYDATE,
    PROJECTED_DELIVERY_DATE,
    PROJECTED_DELIVERY_DATE_HELPTEXT,
    PROVIDE_REASON_FOR_ORDERCANCELLATION_LABEL,
    REASON_FOR_ORDERCANCELLATION_LABEL,
    RESCHEDULE_APHERESIS_PICKUP,
    RELATIONSHIP_TO_PATIENT_LABEL,
    SAVE_BUTTON,
    SCHEDULE_APHERESIS_PICKUP_LABEL,
    SCHEDULED_DRUG_PRODUCT_DELIVERY,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT_WEEKEND,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_OUTRANGE_ERRORTEXT,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT,
    SELECTED_DATE,
    SELECTED_DRUG_PRODUCT_DELIVERY_DATE,
    SELECT_INFUSION_DATE,
    SELECTED_INFUSION_DATE,
    SHIPPING_LABEL,
    SUBMIT_LABEL,
    SUBMIT_REQUEST_LABEL,
    SUCCESS_LABEL,
    TODAY_DATE_LABEL,
    TREATING_PHYSICIAN_LABEL,
    TREATMENT_CENTER_COORDINATOR_LABEL,
    TREATMENT_JOURNEY_LABEL,
    TREATMENT_TEAM_LABEL,
    UNFORTUNATELY_LABEL,
  }

  ApheresisIcon = `${CellSightAssets}/images/apheresis.svg`;

  DeliveryIcon = `${CellSightAssets}/images/delivery.svg`;

  EnrollmentIcon = `${CellSightAssets}/images/enrollment.svg`;

  InfusionIcon = `${CellSightAssets}/images/infusion.svg`;

  ManufacturingIcon = `${CellSightAssets}/images/manufacturing.svg`;

  ShippingIcon = `${CellSightAssets}/images/shipping.svg`;

  svgSuccessIcon ='/_slds/icons/utility-sprite/svg/symbols.svg#success';

  zeroTimeZone = 'Africa/Abidjan';

  @wire(isBussinessDayDueForReschedule, { patientId: '$recordId' })
  wiredDays({ data, error }) {
    if (error) {
      this.error = error;
    }
    if (data) {
      this.isAvailableForReschedule = data;
    }
  }

  apherisisCancelRequestedLabel = this.labels.APHERESIS_PICKUP_CANCELLATION_REQUESTED_LABEL;

  @wire(getObjectInfo, { objectApiName: ORDERS_OBJECT })
  orderObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$orderObjectInfo.data.defaultRecordTypeId',
    fieldApiName: REASONFORCANCEL_FIELD
  })
  wiredData(result) {
    if (result && result.data && result.data.values) {
      this.cancelReasonOptions = result.data.values;
    }
  }

  @wire(getDetailsByPatientId, { patientId: '$recordId' })
  wiredDocuments(value) {
    this.wiredPatientInfo = value;
    const { data, error } = value;
    if (error) {
      this.error = error;
    }
    if (data) {
      this.patientDetails = data;
      this.patientDetailsWrapper = JSON.parse(data);
      this.patientName = this.patientDetailsWrapper.memberFirstName ? `${this.patientDetailsWrapper.memberLastName}, ${this.patientDetailsWrapper.memberFirstName}` : '';
      this.apheresisCryoType = this.patientDetailsWrapper.apheresisCryoType;
      this.apheresisPickupDate = this.patientDetailsWrapper.apheresisPickupDate;
      this.apheresisPickupSite = this.patientDetailsWrapper.apheresisPickupSite;
      this.apheresisPickupStatus = this.patientDetailsWrapper.apheresisPickupStatus;
      this.apheresisSitePO = this.patientDetailsWrapper.apheresisSitePO;
      this.coordinatoruserName = this.patientDetailsWrapper.cartCoordinator;
      this.cryoType = this.patientDetailsWrapper.cryoType;
      this.enrollStatus = this.patientDetailsWrapper.patientStatus;
      this.patientJourneyEmail = this.patientDetailsWrapper.patientEmail;
      this.patientJourneyPhone = this.patientDetailsWrapper.memberPhone;
      this.patientJourneyDOB = this.patientDetailsWrapper.memberDateOfBirth;
      this.patientJourneyMRN = this.patientDetailsWrapper.memberMRN;
      this.patientJourneyPatientId = this.patientDetailsWrapper.patientId;
      this.patientPreferredMethodOfCommunication = this.patientDetailsWrapper.patientPreferredMethodOfCommunication;
      this.patientPrimaryContactType = this.patientDetailsWrapper.patientPrimaryContactType;
      this.patientJourneyStatus = this.patientDetailsWrapper.patientJourneyStatus;
      this.manufacturingStatus = this.patientDetailsWrapper.manufacturingStatus;
      this.shippingStatus = this.patientDetailsWrapper.shippingStatus;
      this.deliveryStatus = this.patientDetailsWrapper.deliveryStatus;
      if (this.deliveryStatus === 'Cryo-ed Cells Delivered') {
        this.deliveryStatus = '';
      }
      this.projectedDeliveryDate = this.patientDetailsWrapper.projectedDeliveryDate;
      this.orderStatus = this.patientDetailsWrapper.orderStatus;
      this.orderCancelRequestDate = this.patientDetailsWrapper.orderCancellationRequestDate;
      this.carePlanStatus = this.patientDetailsWrapper.carePlanStatus;
      if (this.patientDetailsWrapper.careGiverName && this.patientDetailsWrapper.careGiverName !== ''){
        this.showCareGiverSection = true;
      }
      this.selectedPhysicianTitle = this.patientDetailsWrapper.treatingPhysician;
      if (this.enrollStatus === this.status) {
        this.isEnrollcompleted = true;
      } else {
        this.isEnrollcompleted = false;
      }
      this.isApheresisPickUpScheduled = this.apheresisPickupDate && this.apheresisPickupDate !== '';
      this.isApheresisCompleted = this.patientDetailsWrapper.isApheresisCompleted;
      this.isShippingCompleted = this.patientDetailsWrapper.isShippingCompleted;
      this.isManufacturingCompleted = this.patientDetailsWrapper.isManufacturingCompleted;
      this.isDeliveryCompleted = this.patientDetailsWrapper.isDeliveryCompleted;
      this.estimatedDrugProductDeliveryDate = this.patientDetailsWrapper.estimatedDrugProductDeliveryDate;
      this.confirmedFPDelieveryDate = this.patientDetailsWrapper.confirmedFPDeliveryDate;
      this.isInfusionCompleted = this.patientDetailsWrapper.isInfusionCompleted;
      this.infusionStatus = this.patientDetailsWrapper.infusionStatus;
      this.infusionDate = this.patientDetailsWrapper.infusionDate;
      if (this.shippingStatus === this.shippingDrugProductStatus
        || this.shippingStatus === this.drugProductDeliveredStatus
      ) {
        this.shippingStatus = this.cryoedCellsDeliveredStatus;
      }
      this.updateDelieveryRange();
      this.updateInfusedRange();
    }
  }

  get apheresisPickUpCancellationRequestOn() {
    return this.apherisisCancelRequestedLabel && Array.isArray(this.apherisisCancelRequestedLabel.split('~')) && this.apherisisCancelRequestedLabel.split('~')[0];
  }

  get customerCareRepresentativeWillReachOut() {
    return this.apherisisCancelRequestedLabel && Array.isArray(this.apherisisCancelRequestedLabel.split('~')) && this.apherisisCancelRequestedLabel.split('~')[1];
  }

  get getContainerClass() {
    let css = 'slds-progress__item ';
    if (this.orderStatus && this.orderStatus === this.orderCancelledStatus) {
      css = 'slds-progress__item ';
    } else {
      css += 'slds-is-completed';
    }
    return css;
  }

  get infusionDateHelpText() {
    if (this.infusionRange) {
      if ( Array.isArray(this.infusionRange) && this.infusionRange.length > 0) {
        let msg = this.labels.INFUSION_DATE_HELPTEXT;
        msg = msg.replace('{0}', this.formatUIDate(this.infusionRange[0]));
        msg = msg.replace('{1}', this.formatUIDate(this.infusionRange[1]));
        return msg;
      }
      return '';
    }
    return '';
  }

  get isCancelRequestedOrder() {
    const orderStatusVal = this.orderStatus;
    return !!(orderStatusVal && (orderStatusVal === 'Order Cancellation Requested' || orderStatusVal === this.orderCancelledStatus));
  }

  get isDeliveryDateSelected() {
    if ((this.selectedDeliveryDate && this.isSubmitted) || this.confirmedFPDelieveryDate) {
      return true;
    }
    return false;
  }

  get selectedFPDeliveryDate(){
    if(this.selectedDeliveryDate) {
      return this.selectedDeliveryDate
    }
    return this.confirmedFPDelieveryDate;
  }

  get isOrderCancelled() {
    return !!(this.orderStatus && this.orderStatus === this.orderCancelledStatus);
  }

  get orderCancellationRequestDisclaimer() {
    let msg = this.labels.ORDER_CANCELLATION_DISCLAIMER_LABEL;
    if (this.patientName) {
      const name = `${this.patientName}'s`;
      msg = msg.replace('{0}', name);
    } else {
      msg = msg.replace('{0}', '');
    }
    return msg;
  }

  get scheduledDrugProductDateHelpText() {
    if (this.delieveryRange) {
      if ( Array.isArray(this.delieveryRange) && this.delieveryRange.length > 0) {
        let msg = this.labels.SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT;
        msg = msg.replace('{0}', this.formatUIDate(new Date(this.delieveryRange[0])));
        msg = msg.replace('{1}', this.formatUIDate(new Date(this.delieveryRange[1])));
        msg = msg.replace('{1}', this.formatUIDate(new Date(this.delieveryRange[1])));
        return msg;
      }
      return '';
    }
    return '';
  }

  get isDeliveryRangeError() {
    if (this.delieveryDateInrangeError || this.delieveryDateInrangeWeekendError) {
      return true;
    }
    return false;
  }

  get scheduledDrugProductDateOutRangeErrorText(){
    if (this.delieveryDateInrangeWeekendError) {
     return this.labels.SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT_WEEKEND;
    } else if (this.delieveryDateInrangeError) {
      if (this.delieveryRange) {
        if (Array.isArray(this.delieveryRange) && this.delieveryRange.length > 0) {
          let msg = this.labels.SCHEDULED_DRUG_PRODUCT_DELIVERY_OUTRANGE_ERRORTEXT;
          msg = msg.replace('{0}', this.formatUIDate(new Date(this.delieveryRange[0])));
          msg = msg.replace('{1}', this.formatUIDate(new Date(this.delieveryRange[1])));
          return msg;
        }
        return '';
      }
      return '';
    } else {
      return '';
    }
  }

  closeOrderViaPhoneModal() {
    this.showOrderCancellationViaPhoneModal = false;
  }

  formatDate(dateObj) {
    if (dateObj instanceof Date) {
      let enddate = dateObj;
      let dd = enddate.getDate();
      if (dd <= 9) {
        dd = `0${dd}`;
      }
      let mm = enddate.getMonth() + 1;
      if (mm < 10) {
        mm = `0${mm}`;
      }
      const yyyy = enddate.getFullYear();
      enddate = `${yyyy}-${mm}-${dd}`;
      return enddate;
    }
    return '';
  }

  formatUIDate(dateObj) {
    if (dateObj instanceof Date) {
      let enddate = dateObj;
      let dd = enddate.getDate();
      if (dd <= 9) {
        dd = `0${dd}`;
      }
      const mm = enddate.toLocaleString('default', { month: 'short' });
      const yyyy = enddate.getFullYear();
      enddate = `${mm} ${dd}, ${yyyy}`;
      return enddate;
    }
    return '';
  }

  genRandom() {
    return Math.random().toString(this.maxDigits).substr(this.randomIdStartInd, this.randomIdEndInd);
  }

  handleCalendarClose() {
    this.openCalendar = false;
  }

  handleInfusionCalendarClose() {
    this.openInfusionCalendar = false;
  }

  handleInfusionDateSave() {
    if (!this.selectedInfusionDate) {
      this.infusionDateError = true;
    } else {
      this.infusionDateError = false;
      updateInfusedDateOnOrder({ patientId: this.recordId, infusedDate: this.selectedInfusionDate})
      .then(data => {
        this.openInfusionCalendar = false;
        refreshApex(this.wiredPatientInfo);
      })
      .catch(error => {
        this.error = error;
        this.openInfusionCalendar = false;
      });
    }
  }

  handleCellClick(event) {
    const selectedDate = event.detail.selecteddate;
    const day = selectedDate.getDay();
    const disableDay = [0, 1, 6];
    if (selectedDate && this.delieveryRange) {
      const startDate = new Date(this.delieveryRange[0]);
      const endDate = new Date(this.delieveryRange[1]);
      startDate.setHours(0,0,0,0);
      endDate.setHours(0,0,0,0);
      if (disableDay.indexOf(day) !== -1) {
        this.delieveryDateInrangeWeekendError = true;
        this.delieveryDateInrangeError = false;
      } else if (selectedDate >= startDate
          && selectedDate <= endDate
          && disableDay.indexOf(day) === -1
      ) {
        this.delieveryDateInrangeWeekendError = false;
        this.delieveryDateInrangeError = false;
      } else {
        this.delieveryDateInrangeWeekendError = false;
        this.delieveryDateInrangeError = true;
      }
    }
  }

  handleInfusionSelectDate(event) {
    if (event.detail) {
      this.selectedInfusionDate = event.detail.selecteddate;
    }
  }

  handleSelectDate(event) {
    if (event.detail) {
      this.selectedDeliveryDate = event.detail.selecteddate;
    }
  }

  handleValidateDate() {
    if (!this.selectedDeliveryDate) {
      this.delieveryDateError = true;
    } else {
      this.delieveryDateError = false;
      updateDeliveryDateOnOrder({ patientId: this.recordId, dpDeliveryDate: this.selectedDeliveryDate })
        .then(() => {
          this.openCalendar = false;
          this.isSubmitted = true;
        }).catch(err => {
          this.error = err;
          this.openCalendar = false;
        });
    }
  }

  handleOpenCalendar(event) {
    event.preventDefault();
    const inputElement = this.template.querySelector('.label-inp');
    if (inputElement) {
      inputElement.click();
    }
    this.openCalendar = true;
  }

  handleOpenInfusionCalendar(event){
    event.preventDefault();
    this.openInfusionCalendar = true;
  }

  handlePatientServiceProgram() {
    this.isPatientServiceProgram = true;
  }

  handleFetchPatientServices(){
    fetchPatientServiceEligibilty({patientId: this.recordId})
        .then((result) => {
          this.checkBoxData = result;
          if(result.length>0){
            setTimeout(()=>{
              this.showFindOutMoreButton = result[0].BeginPatientSupportEligibilityCheck__c;
            },200);
          }
        })
        .catch((error) => {
          this.error = error;
          this.isPatientServiceProgram = false;
        });
  }

  handleFetchPatientServicesProgramsStatus(){
    fetchPatientServiceEnrollee({patientId: this.recordId})
        .then((result) => {
          this.PatientServiceProgramStatus = result;
          this.patientEnrolleeStatus = result[0].PatientServicesStatus__c;
        })
        .catch((error) => {
          this.error = error;
          this.isPatientServiceProgram = false;
        });
  }

  handleClose(){
    this.isPatientServiceProgram = false;
  }

  handlePatientServiceCheck(event) {
    this.enablePatientService = event.target.checked;
    if (event.target.checked) {
      this.showSubmitButton = true;
    } else {
      this.showSubmitButton = false;
    }
  }

  handleSubmitRequest(){
    updateCarePlan({patientId: this.recordId,strPatientServiceProgram:this.enablePatientService})
        .then(() => {
          this.isPatientServiceProgram = false;
          this.handleFetchPatientServices();
        })
        .catch((error) => {
          this.error = error;
        });
  }

  handleCancelOrder() {
    const carePlanStatusVal = this.patientDetailsWrapper.carePlanStatus;
    if (carePlanStatusVal === 'Infused'
        || carePlanStatusVal === 'Drug Product Delivered'
        || carePlanStatusVal === 'Drug Product Shipped') {
      this.showOrderCancellationModal = false;
      this.showOrderCancellationViaPhoneModal = true;
    } else {
      this.showOrderCancellationModal = true;
    }
  }

  handleOrderCancellationReasonChange(event){
    this.selectedOrderCancellationReason = event.target.value;
  }

  handleCancelOrderClose(){
    this.showOrderCancellationModal = false;
  }

  processCancelOrder(){
    updateOrder({patientId: this.recordId,reasonForCancellation:this.selectedOrderCancellationReason})
        .then(() => {
          refreshApex(this.wiredPatientInfo);
        })
  }

  handleSubmitCancelOrder(){
      const allValid = [...this.template.querySelectorAll('lightning-combobox')]
          .reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
          }, true);
    if(allValid === true) {
      this.processCancelOrder();
      this.handleCancelOrderClose();
    } else {
      this.showOrderCancellationReasonMandatory = true;
    }
  }

  navigateToCalendarAvailabilityPage() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'AvailabilityCalendar__c',
      },
      state: {
        patientId: this.recordId,
      },
    });
  }

  navigateToCalendarAvailabilityReschedulePage() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'AvailabilityCalendar__c',
      },
      state: {
        patientId: this.recordId,
        isReschedule: true,
        sitepo: this.patientDetailsWrapper.apheresisSitePO !== null ? this.patientDetailsWrapper.apheresisSitePO : 'null',
      },
    });
  }

  handleToggleFilter() {
    this.toggleFilter = !this.toggleFilter;
  }

  get getStatusText(){
    if(this.patientEnrolleeStatus === this.patientEnrollmentFormReceivedStatus && this.showFindOutMoreButton){
      return `${this.labels.PATIENT_LABEL} ${this.patientName} ${this.labels.PATIENT_SERVICE_AGENT_LABEL}`;
    } else if(this.patientEnrolleeStatus === this.ineligibleStatus && this.showFindOutMoreButton){
      return `${this.labels.UNFORTUNATELY_LABEL} ${this.labels.PATIENT_LABEL} ${this.patientName} ${this.labels.PATIENT_SERVICE_PROGRAMS_INELIGIBLE_LABEL}`;
    } else if(this.patientEnrolleeStatus === this.enrolledInServiceStatus && this.showFindOutMoreButton){
      return `${this.labels.PATIENT_LABEL} ${this.patientName} ${this.labels.PATIENT_SERVICE_PROGRAM_TRAVEL_LABEL}`;
    } else if(this.showFindOutMoreButton){
      return `${this.labels.PATIENT_SERVICE_PROGRAMS_DISCLAIMER_LABEL} ${this.patientName} ${this.labels.PATIENT_SERVICE_DISCLAIMER_LABEL}`;
    } else {
      return `${this.labels.PATIENT_LABEL} ${this.patientName} ${this.labels.PATIENT_SERVICE_PROGRAM_DISCLAIMER_LABEL}`;
    }
  }

  updateDelieveryRange() {
    if (this.estimatedDrugProductDeliveryDate) {
      let startdate = this.estimatedDrugProductDeliveryDate;
      let enddate = new Date(startdate);
      enddate = this.changeTimezone(enddate, this.zeroTimeZone);
      enddate.setDate(enddate.getDate() + 20);
      let estimatedDateformat = new Date(this.estimatedDrugProductDeliveryDate);
      estimatedDateformat = this.changeTimezone(estimatedDateformat, this.zeroTimeZone);

      let dd = enddate.getDate();
      if (dd < 10) {
        dd = `0${dd}`;
      }
      let mm = enddate.getMonth() + 1;
      if(mm < 10) {
        mm = `0${mm}`;
      }
      const yyyy = enddate.getFullYear();
      enddate = `${yyyy}-${mm}-${dd}`;
      enddate = this.changeTimezone(new Date(enddate), this.zeroTimeZone);
      if (estimatedDateformat < new Date()) {
        getNextThreeBussinessDays({ startDate: this.formatDate(new Date() )}).then(date => {
          let originalStartdate = startdate;
          startdate = new Date(date);
          startdate = this.changeTimezone(startdate, this.zeroTimeZone);
          for (let i = 0; i < 21; i++) {
            let tmpdate = new Date(originalStartdate);
            tmpdate = this.changeTimezone(tmpdate, this.zeroTimeZone);
            tmpdate.setDate(tmpdate.getDate() + i);
            if (tmpdate.getDay() !== 0
                && tmpdate.getDay() !== 1
                && tmpdate.getDay() !== 6
                && tmpdate >= startdate
            ) {
              this.events.push({
                id: this.genRandom(),
                title: 'deliveryPickupDate',
                start: this.formatDate(tmpdate),
                end: this.formatDate(tmpdate),
                textColor: '#454545',
                rendering: 'background',
                color: AVAILABLE_DATE_COLOR,
                type: 'delivery',
                selecteddate: this.formatDate(tmpdate),
                allDay: true,
              });
            }
          }
          this.delieveryRange.push(startdate);
          this.delieveryRange.push(enddate);
        }).catch(err => {
          this.error = err;
        });
      } else {
        for (let i = 0; i < 21; i++) {
          let tmpdate = new Date(startdate);
          tmpdate = this.changeTimezone(tmpdate, this.zeroTimeZone);
          tmpdate.setDate(tmpdate.getDate() + i);
          if (tmpdate.getDay() !== 0 && tmpdate.getDay() !== 1 && tmpdate.getDay() !== 6) {
            this.events.push({
              id: this.genRandom(),
              title: 'deliveryPickupDate',
              start: this.formatDate(tmpdate),
              end: this.formatDate(tmpdate),
              textColor: '#454545',
              rendering: 'background',
              color: AVAILABLE_DATE_COLOR,
              type: 'delivery',
              selecteddate: this.formatDate(tmpdate),
              allDay: true,
            });
          }
        }
        startdate = this.changeTimezone(new Date(startdate), this.zeroTimeZone);
        this.delieveryRange.push(startdate);
        this.delieveryRange.push(enddate);
      }
    }
  }

  changeTimezone(date, timezone) {

    const invdate = new Date(date.toLocaleString('en-US', {
      timeZone: timezone,
    }));

    const diff = date.getTime() - invdate.getTime();
    return invdate;
  }

  updateInfusedRange() {
    if (this.confirmedFPDelieveryDate) {
      let startdate = this.confirmedFPDelieveryDate;
      startdate = new Date(startdate);
      startdate = this.changeTimezone(startdate, this.zeroTimeZone);
      const enddate = new Date();
      this.infusionRange.push(startdate);
      this.infusionRange.push(enddate);

      if (startdate < enddate) {
        const tmpDate = new Date(JSON.parse(JSON.stringify(startdate)));
        while (tmpDate <= enddate) {
          this.infusionEvents.push({
            id: this.genRandom(),
            title: 'deliveryPickupDate',
            start: this.formatDate(tmpDate),
            end: this.formatDate(tmpDate),
            textColor: '#454545',
            rendering: 'background',
            color: AVAILABLE_DATE_COLOR,
            type: 'delivery',
            selecteddate: this.formatDate(tmpDate),
            allDay: true,
          });
          tmpDate.setDate(tmpDate.getDate() + 1);
          if (tmpDate >= enddate) {
            break;
          }
        }
      }
    }
  }
}
