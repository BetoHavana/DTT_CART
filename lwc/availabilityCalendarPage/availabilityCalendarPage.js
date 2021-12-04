import { LightningElement, track, wire } from 'lwc';
import { getQueryParameters } from 'c/sharedUtils';
import confirmSlotBooking from '@salesforce/apex/OrderPlacementController.elevatedSendSlotBookingRequest';

import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";

import ORDERS_OBJECT from '@salesforce/schema/Order__c';
import REASONFORRESCHEDULE_FIELD from '@salesforce/schema/Order__c.ReasonforReschedule__c';

import APHERESIS_PICKUP_DATE_LABEL from '@salesforce/label/c.ApheresisPickUpDate';
import APHERESIS_PICKUP_DATE_REQUIRED from '@salesforce/label/c.ApheresisPickUpDateRequired';
import APHERESIS_PICKUP_DATEAND_POREQUIRED from '@salesforce/label/c.ApheresisPickUpPORequired';
import APHERESIS_PICKUP_DETAILS_LABEL from '@salesforce/label/c.ApheresisPickUpDetails';
import APHERESIS_PICKUP_SITE from '@salesforce/label/c.ApheresisPickUpSite';
import APHERESIS_SITE_LABEL from '@salesforce/label/c.ApheresisSite';
import AVAILABILITY_CALENDAR_CONSENT_TEXT from '@salesforce/label/c.AvailabilityCalendarConsentText';
import AVAILABILITY_CALENDAR_RESCHEDULE_CONSENT_TEXT from '@salesforce/label/c.AvailabilityCalendarReScheduleConsentText';
import AVAILABILITY_CALENDER_SUCCESS_LABEL from '@salesforce/label/c.AvailabilityCalendarSuccessLabel';
import AVAILABILITY_SEARCH_CRITIERIA_LABEL from '@salesforce/label/c.AvailabilitySearchCriteria';
import BACK_LABEL from '@salesforce/label/c.Back';
import CONTINUE_LABEL from '@salesforce/label/c.Continue';
import CRYO_TYPE_LABEL from '@salesforce/label/c.CryoType';
import DATES_AVAIL_FOR_APHRESIS_PICKUP from '@salesforce/label/c.DatesAvailForAphresisPickup';
import DRUG_PRODUCT_DELIVERY_DATE_UNAVAILABLE_LABEL from '@salesforce/label/c.DPDeliveryDateUnavailable';
import DRUG_PRODUCT_DELIVERY_DATE_UNAVAILABLE_MESSAGE_LABEL from '@salesforce/label/c.DPDeliveryUnavailableMessage';
import DRUG_PRODUCT_DELIVERY_WINDOW_LABEL from '@salesforce/label/c.DrugProductDeliveryWindow';
import ENROLL_PATIENT from '@salesforce/label/c.EnrollNewPatient';
import HOME from '@salesforce/label/c.Home';
import NEW_APHERESIS_PICKUP_DATE from '@salesforce/label/c.NewApheresisPickDate';
import NEW_PROJECTED_DELIVERY_DATE from '@salesforce/label/c.NewProjectedDeliveryDate';
import NEW_PROJECTED_DELIVERY_DATE_HELP_TEXT from '@salesforce/label/c.NewProjectedDeliveryDateHelpText';
import Ok_LABEL from '@salesforce/label/c.OK';
import ORDER_DETAILS_LABEL from '@salesforce/label/c.OrderDetails';
import PATIENT_ENROLLMENT_SUCCESS_LABEL from '@salesforce/label/c.PatientEnrollmentSuccess';
import PO_NUMBER_LABEL from '@salesforce/label/c.PONumber';
import PO_NUMBER_HELP_TEXT from '@salesforce/label/c.PONumberHelpText';
import PO_NUMBER_REQUIRED from '@salesforce/label/c.PONumberRequired';
import PROJECTED_DELIVERY_DATE_LABEL from '@salesforce/label/c.ProjectedDeliveryDate';
import REASONFORRESCHEDULE_ERROR from '@salesforce/label/c.ReasonForRescheduling';
import REASONFORRESCHEDULE_LABEL from '@salesforce/label/c.ReasonForReschedule';
import REASONFORRESCHEDULEREQ_LABEL from '@salesforce/label/c.PleaseSpecifyReasonOfOrderReschedule';
import RESCHEDULED_ORDER_DETAILS from '@salesforce/label/c.RescheduledOrderDetails';
import REVIEW_SUBMIT_LABEL from '@salesforce/label/c.ReviewSubmit';
import SCHEDULE_EXISTING_PATIENT_LABEL from '@salesforce/label/c.ScheduleExistingPatient';
import SLOT_UNAVAILABLE_MSG from '@salesforce/label/c.SlotUnavailableMsg';
import SPECIFYREASONFORRESCHEDULE_LABEL from '@salesforce/label/c.SpecifyReasonForReschedule';
import SUBMIT_ORDER_LABEL from '@salesforce/label/c.OrderSubmitPageHeading';
import SUCCESS_LABEL from '@salesforce/label/c.Success';
import TODAY_DATE_LABEL from '@salesforce/label/c.TodayDate';
import UNAVAILABLE_SLOTS_VALIDATION_MSG from '@salesforce/label/c.UnavailableSlotsValidationMsg';

import { NavigationMixin } from "lightning/navigation";
import { PATIENT_DETAILS_CHEVRON, PATIENTS_PAGE_REFERENCE } from "c/pageReferences";

const SELECTED_COLOR = '#f57e20';

export default class AvailabilityCalendarPage extends NavigationMixin(LightningElement) {
  availableCalendarPickupState = 'Step1';

  availableCalendarReviewState = 'Step2';

  availableCalendarStep1 = 1;

  availableCalendarStep2 = 2;

  availableCalendarStep3 = 3;

  error;

  patientId;

  @track deliveryWindowStartDate;

  @track events;

  @track isConsentChecked = false;

  @track isSlotUnavailableModalOpen = false;

  @track isOrderReschedule = false;

  @track orderError = '';

  @track orderResponse = '';

  @track pickupHasError = false;

  @track patientData;

  @track readonlyChild = true;

  @track reason = '';

  @track reasonForReschedule='';

  @track rescheduleReasonOptions;

  @track selectedApheresisSite = '';

  @track selectedCryoType = '';

  @track selectedPickupDate;

  @track selectedPONumber;

  @track selectedStep = 'Step1';

  @track showSpinner = false;

  labels = {
    APHERESIS_PICKUP_DATE_LABEL,
    APHERESIS_PICKUP_DATE_REQUIRED,
    APHERESIS_PICKUP_DATEAND_POREQUIRED,
    APHERESIS_PICKUP_DETAILS_LABEL,
    APHERESIS_PICKUP_SITE,
    APHERESIS_SITE_LABEL,
    AVAILABILITY_CALENDAR_CONSENT_TEXT,
    AVAILABILITY_CALENDAR_RESCHEDULE_CONSENT_TEXT,
    AVAILABILITY_CALENDER_SUCCESS_LABEL,
    AVAILABILITY_SEARCH_CRITIERIA_LABEL,
    BACK_LABEL,
    CONTINUE_LABEL,
    CRYO_TYPE_LABEL,
    DATES_AVAIL_FOR_APHRESIS_PICKUP,
    DRUG_PRODUCT_DELIVERY_DATE_UNAVAILABLE_LABEL,
    DRUG_PRODUCT_DELIVERY_DATE_UNAVAILABLE_MESSAGE_LABEL,
    DRUG_PRODUCT_DELIVERY_WINDOW_LABEL,
    ENROLL_PATIENT,
    HOME,
    NEW_APHERESIS_PICKUP_DATE,
    NEW_PROJECTED_DELIVERY_DATE,
    NEW_PROJECTED_DELIVERY_DATE_HELP_TEXT,
    Ok_LABEL,
    ORDER_DETAILS_LABEL,
    PATIENT_ENROLLMENT_SUCCESS_LABEL,
    PO_NUMBER_HELP_TEXT,
    PO_NUMBER_LABEL,
    PO_NUMBER_REQUIRED,
    PROJECTED_DELIVERY_DATE_LABEL,
    REASONFORRESCHEDULE_ERROR,
    REASONFORRESCHEDULE_LABEL,
    REASONFORRESCHEDULEREQ_LABEL,
    RESCHEDULED_ORDER_DETAILS,
    REVIEW_SUBMIT_LABEL,
    SCHEDULE_EXISTING_PATIENT_LABEL,
    SLOT_UNAVAILABLE_MSG,
    SPECIFYREASONFORRESCHEDULE_LABEL,
    SUBMIT_ORDER_LABEL,
    SUCCESS_LABEL,
    TODAY_DATE_LABEL,
    UNAVAILABLE_SLOTS_VALIDATION_MSG,
  };

  @wire(getObjectInfo, { objectApiName: ORDERS_OBJECT })
  orderObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$orderObjectInfo.data.defaultRecordTypeId',
    fieldApiName: REASONFORRESCHEDULE_FIELD,
  })
  wiredData(result) {
    if (result && result.data && result.data.values) {
      this.rescheduleReasonOptions = result.data.values;
    }
  }

  get consentChecked() {
    return this.isConsentChecked? false : true;
  }

  get consentLabel() {
    return this.isOrderReschedule
      ? this.labels.AVAILABILITY_CALENDAR_RESCHEDULE_CONSENT_TEXT
      : this.labels.AVAILABILITY_CALENDAR_CONSENT_TEXT;
  }

  get currentStep() {
    return this.selectedStep ? parseInt(this.selectedStep.substring(this.selectedStep.length - 1), 10) : 1;
  }

  get reasonRequired() {
    return this.reasonForReschedule === 'Other';
  }

  get successMessage() {
    let msg = this.labels.AVAILABILITY_CALENDER_SUCCESS_LABEL;
    if (this.patientData) {
      const name = `${this.patientData.memberLastName}, ${this.patientData.memberFirstName}'s`;
      msg = msg.replace('{0}', name);
    } else {
      msg = msg.replace('{0}', '');
    }
    return msg;
  }

  get showIfStepOne() {
    return this.currentStep === this.availableCalendarStep1;
  }

  get showIfStepTwo() {
    return this.currentStep === this.availableCalendarStep2;
  }

  get showIfStepThree() {
    return this.currentStep === this.availableCalendarStep3;
  }

  connectedCallback () {
    const urldata = getQueryParameters();
    if (urldata) {
      this.patientId = urldata.patientId ? urldata.patientId : '';
      if (urldata.isReschedule) {
        this.isOrderReschedule = true;
      }
      if (urldata.sitepo && urldata.sitepo !== 'null') {
        this.selectedPONumber = urldata.sitepo;
      }
    }
  }

  changeReasonHandler(event) {
    const reasonOption = event.detail.value;
    switch (event.target.name) {
      case 'reasonForReschedule':
        this.reasonForReschedule = reasonOption;
        break;
      case 'reason':
        this.reason = reasonOption;
        break;
      default:
        break;
    }
  }

  closeErrorModal(){
    this.isSlotUnavailableModalOpen = false;
    this.handlePrev();
    this.selectedPickupDate = '';
    this.deliveryWindowStartDate = '';
  }

  formatDate(date) {
    if (date) {
      const tempdate = new Date(date);
      let dd = tempdate.getDate();
      let mm = tempdate.getMonth() + 1;
      const yyyy = tempdate.getFullYear();
      if (dd < 10) {
        dd = `0${dd}`;
      }
      if (mm < 10) {
        mm = `0${mm}`;
      }
      return `${yyyy}-${mm}-${dd}`;
    }
    return '';
  }

  genRandom() {
    return Math.random().toString(36).substr(2, 9);
  }

  handleAphSelect(event){
    this.selectedApheresisSite = event.detail.aphType;
    this.selectedCryoType = event.detail.cryoType;
  }

  handleClearData() {
    this.selectedPickupDate = '';
    this.deliveryWindowStartDate = '';
  }

  handleNext() {
    this.pickupHasError = false;
    this.orderError = '';
    if (this.selectedStep === this.availableCalendarPickupState) {
      const patientElement = this.template.querySelector('c-patient-card');
      if (patientElement) {
        this.patientData = patientElement.getPatientData();
      }
      if (this.selectedPONumber && this.selectedPickupDate && this.patientData && !this.isOrderReschedule) {
        this.pickupHasError = false;
        const element = this.template.querySelector('c-availability-calendar');
        if (element) {
          const data = element.getData();
          if (data) {
            this.selectedApheresisSite = data.apheresisSite;
            this.selectedCryoType = data.cryoType;
            this.selectedApheresisSiteERP = data.apheresisSiteERP;
            this.selectedApheresisSiteId = data.apheresisSiteId;
          }
        }
        if (this.patientData) {
          this.progressNextSteps();
        }
      } else if (this.selectedPONumber && this.selectedPickupDate && this.patientData && this.isOrderReschedule) {
        if (this.reasonForReschedule === '' || !this.reasonForReschedule
            || (this.reasonForReschedule === 'Other' && (this.reason === '' || !this.reason))) {
          this.pickupHasError = true;
          this.orderError = this.labels.REASONFORRESCHEDULE_ERROR;
        } else {
          const element = this.template.querySelector('c-availability-calendar');
          if (element) {
            const data = element.getData();
            if (data) {
              this.selectedApheresisSite = data.apheresisSite;
              this.selectedCryoType = data.cryoType;
              this.selectedApheresisSiteERP = data.apheresisSiteERP;
              this.selectedApheresisSiteId = data.apheresisSiteId;
            }
          }
          this.progressNextSteps();
        }
      } else if (!this.selectedPickupDate && !this.selectedPONumber) {
        this.pickupHasError = true;
        this.orderError = this.labels.APHERESIS_PICKUP_DATEAND_POREQUIRED;
      } else if (this.selectedPickupDate && !this.selectedPONumber) {
        this.pickupHasError = true;
        this.orderError = this.labels.PO_NUMBER_REQUIRED;
      } else if (!this.selectedPickupDate && this.selectedPONumber) {
        this.pickupHasError = true;
        this.orderError = this.labels.APHERESIS_PICKUP_DATE_REQUIRED;
      } else {
        this.pickupHasError = false;
        this.orderError = '';
      }
    } else if (this.selectedStep === this.availableCalendarReviewState) {
      if (this.isConsentChecked) {
        this.sendBookingRequest();
      }
    } else {
      this.progressNextSteps();
    }
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  handlePoChange(event) {
    this.selectedPONumber = event.detail.value;
  }

  handlePrev() {
    let val = this.currentStep;
    if (val !== this.availableCalendarStep1) {
      val -= 1;
      this.selectedStep = `Step${val}`;
    }
  }

  handleSelectDate(event) {
    try {
      if (event.detail) {
        this.deliveryWindowStartDate = event.detail.selecteddate;
        this.selectedPickupDate = this.formatDate(event.detail.date);
        const ets = JSON.parse(JSON.stringify(event.detail.events));
        const data = event.detail;
        if (data) {
          const { id } = data;
          const evt = ets.filter(e => e.id === id);
          if (evt && evt.length) {
            const stDate = evt[0].selecteddate;
            let evtFound = -1;
            for (let i = 0; i < ets.length; i++) {
              if (ets[i].type === 'DateSelected') {
                evtFound = i;
                break;
              }
            }

            if (evtFound !== -1) {
              ets.splice(evtFound, 1);
            }

            ets.push({
              id: this.genRandom(),
              start: stDate,
              end: stDate,
              title: '',
              textColor: '#fff',
              className: 'event aph-event',
              type: 'DateSelected',
              color: SELECTED_COLOR,
            });
            this.events = ets;
          }
        }
      }
    } catch (e) {
      this.error = e;
    }
  }

  navigateToLandingPage() {
    this[NavigationMixin.Navigate](PATIENTS_PAGE_REFERENCE);
  }

  navigateToPatientEnrollment() {
    this[NavigationMixin.Navigate](PATIENT_DETAILS_CHEVRON);
  }

  progressNextSteps() {
    const milestone = this.template.querySelector('c-availability-calendar-milestone');
    if (milestone) {
      const step = milestone.progressNextStep();
      this.selectedStep = step;
    }
  }

  sendBookingRequest() {
    this.showSpinner = true;
    const slotAndOrderUpdateInfo = {
      orderId: this.orderId,
      patientId: this.patientId,
      apheresisSiteERPId: this.selectedApheresisSiteERP,
      apheresisSiteId: this.selectedApheresisSiteId,
      aphPickUpDate: this.selectedPickupDate,
      projectedDeliveryDate: this.deliveryWindowStartDate,
      cryoType: this.selectedCryoType,
      requestType: this.isOrderReschedule === true ? 'Reschedule' : 'New',
      sourceOfRequest: 'TCP',
      therapyType: 'Commercial',
      sitePO: this.selectedPONumber,
      reason: this.reason,
      reasonForReschedule: this.reasonForReschedule,
    };
    confirmSlotBooking({ confirmSlotAndOrderUpdateInfo: slotAndOrderUpdateInfo })
      .then(result => {
        this.showSpinner = false;
        this.orderResponse = result;
        if (result === this.labels.SLOT_UNAVAILABLE_MSG
              || result === this.labels.UNAVAILABLE_SLOTS_VALIDATION_MSG ) {
          this.isSlotUnavailableModalOpen = true;
        } else {
          this.progressNextSteps();
        }
      })
      .catch(error => {
        this.showSpinner = false;
        this.error = error;
       });
  }

  updateConsentBox(event) {
    this.isConsentChecked = event.detail.checked;
  }

}
