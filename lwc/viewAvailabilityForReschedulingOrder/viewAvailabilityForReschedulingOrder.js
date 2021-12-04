import { LightningElement, api, track } from 'lwc';
import checkForValidationsNPassReqData
  from '@salesforce/apex/OrderPlacementRescheduleController.checkForValidationsNPassReqData';
import sendSlotBookingRequest from '@salesforce/apex/OrderPlacementRescheduleController.sendSlotBookingRequest';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import APHERESIS_PICKUP_DATE_REQUIRED from '@salesforce/label/c.ApheresisPickUpDateRequired';
import DATES_AVAIL_FOR_APHRESIS_PICKUP from '@salesforce/label/c.DatesAvailForAphresisPickup';
import DRUG_PRODUCT_DELIVERY_WINDOW_LABEL from '@salesforce/label/c.DrugProductDeliveryWindow';
import ORDER_DETAILS_LABEL from '@salesforce/label/c.OrderDetails';
import ORDERRESCHEDULEDSUCCESSFULLY_LABEL from '@salesforce/label/c.OrderRescheduledSuccessfully';
import PROJECTED_DELIVERY_DATE_LABEL from '@salesforce/label/c.ProjectedDeliveryDate';
import SOMETHINGWENTWRONGERROR_LABEL from '@salesforce/label/c.SomethingWentWrongPleaseTryAgain';
import SLOTSNOTCONFIRMEDVALIDATIONMSG_LABEL from '@salesforce/label/c.SlotsNotConfirmedValidationMsg';


const [SELECTED_COLOR, ERROR, THIRTYSIX, TWO, NINE, THREETHOUSAND, TEN] = ['#f57e20', 'Error', 36, 2, 9, 3000, 10];

export default class ViewAvailabilityForReschedulingOrder extends LightningElement {

  showReasonForRescheduleSection = false;

  reasonSectionRequired = false;

  reasonForReschedule = '';

  reason = '';
  @api orderId;

  showSpinner = true;

  order;

  showCalenderScreen = false;

  treatmentSiteId;

  @track selectedPickupDate;

  deliveryWindowStartDate;

  @track events;

  pickupHasError = false;

  orderError = '';

  patientId = '';

  isSubmitButtonDisabled = true;

  selectedCryoType = '';

  selectedApheresisSite = '';

  selectedApheresisSiteId = '';

  apheresisSiteERPSiteId = '';

  errorInfo;

  labels = {
    APHERESIS_PICKUP_DATE_REQUIRED,
    DATES_AVAIL_FOR_APHRESIS_PICKUP,
    DRUG_PRODUCT_DELIVERY_WINDOW_LABEL,
    ORDERRESCHEDULEDSUCCESSFULLY_LABEL,
    SOMETHINGWENTWRONGERROR_LABEL,
    SLOTSNOTCONFIRMEDVALIDATIONMSG_LABEL,
    ORDER_DETAILS_LABEL,
    PROJECTED_DELIVERY_DATE_LABEL
  };

  connectedCallback() {
    this.checkForValidationsNProcessOrder();
  }

  checkForValidationsNProcessOrder() {
    checkForValidationsNPassReqData({ orderId: this.orderId })
        .then(result => {
          this.processValidationResponse(result);
        })
        .catch(() => {
          this.stopSpinner();
          this.showToastMessage(ERROR.toLowerCase(), SOMETHINGWENTWRONGERROR_LABEL, ERROR);
          this.communicateParentToCloseAction();
        });
  }

  handleNextButtonClicked() {
    this.setReasonFields();
    this.showReasonForRescheduleSection = false;
    this.showCalenderScreen = this.treatmentSiteId ? true : false;
  }

  setReasonFields() {
    const reasonForRescheduleComp = this.template.querySelector('c-reason-for-reschedule-comp');
    if (reasonForRescheduleComp) {
      this.reason = reasonForRescheduleComp.reason;
      this.reasonForReschedule = reasonForRescheduleComp.reasonForReschedule;
    }
  }


  processValidationResponse(data) {
    if (data && data.satisfiedAllValidations && data.order) {
      this.order = data.order;
      this.treatmentSiteId = data.order.TreatmentSite__c ? data.order.TreatmentSite__c : null;
      this.patientId = data.order.Patient__c;
      this.showReasonForRescheduleSection = true;
      this.orderApheresisPickUpDate = data.order.ApheresisPickUpDate__c;
    } else {
      this.showToastMessage(ERROR.toLowerCase(), data.errorMessageOnValidationsFail, ERROR);
      this.communicateParentToCloseAction();
    }
    this.stopSpinner();
  }

  stopSpinner() {
    this.showSpinner = false;
  }

  showToastMessage(variant, message, title) {
    const toastEvent = new ShowToastEvent({
      message,
      title,
      variant
    });
    this.dispatchEvent(toastEvent);
  }

  communicateParentToCloseAction() {
    this.dispatchEvent(new CustomEvent('cancelclick'));
  }

  communicateParentToCloseActionNrefresh() {
    this.dispatchEvent(new CustomEvent('closeactionnrefresh'));
  }

  setApheresisDates(eventDetail) {
    this.deliveryWindowStartDate = eventDetail.selecteddate;
    this.selectedPickupDate = this.formatDate(eventDetail.date);
  }

  handleSelectDate(event) {
    try {
      if (event.detail) {
        this.handleDateSelection(event.detail);
      }
    } catch (e) {
      this.error = e;
    } finally {
      this.handleNext();
      this.handleSubmitButtonEnablingDisabling();
    }
  }

  handleDateSelection(data) {
    const ets = JSON.parse(JSON.stringify(data.events));
    this.setApheresisDates(data);
    const { id } = data;
    const evt = ets.filter(e => e.id === id);
    if (evt && evt.length) {
      const stDate = evt[0].selecteddate;
      let evtFound = this.getSelectedDateIndex(ets);

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
        color: SELECTED_COLOR
      });
      this.events = ets;
    }
  }

  getSelectedDateIndex(ets) {
    let index = -1;
    for (let i = 0; i < ets.length; i++) {
      if ('DateSelected' === ets[i].type) {
        index = i;
        break;
      }
    }
    return index;
  }

  handleClearData() {
    this.selectedPickupDate = '';
    this.deliveryWindowStartDate = '';
  }

  handleNext() {
    if (this.selectedPickupDate) {
      this.pickupHasError = false;
      this.setApheresisAndCryoFields(this.template.querySelector('c-availability-calendar-c-c-m'));
    }
  }

  setApheresisAndCryoFields(element) {
    const data = element ? element.getData() : '';
    if (data) {
      this.selectedApheresisSite = data.apheresisSite;
      this.selectedApheresisSiteId = data.selectedApheresisSiteId;
      this.selectedCryoType = data.cryoType;
      this.apheresisSiteERPSiteId = data.apheresisSiteERPSiteId;
    } else {
      this.pickupHasError = true;
      this.orderError = this.labels.APHERESIS_PICKUP_DATE_REQUIRED;
    }
  }

  formatDate(date) {
    if (date) {
      const tempdate = new Date(date);
      let dd = tempdate.getDate();
      let mm = tempdate.getMonth() + 1;
      const yyyy = tempdate.getFullYear();
      if (dd < TEN) {
        dd = `0${dd}`;
      }
      if (mm < TEN) {
        mm = `0${mm}`;
      }
      return `${yyyy}-${mm}-${dd}`;
    }

    return '';
  }

  genRandom() {
    return Math.random()
        .toString(THIRTYSIX)
        .substr(TWO, NINE);
  }


  submitOrderInfo() {
    this.startSpinner();
    this.callAnaPlanToSendSlotBooking();
  }

  callAnaPlanToSendSlotBooking() {
    const slotAndOrderUpdateInfo = {
      orderId: this.orderId,
      apheresisSiteERPId: this.apheresisSiteERPSiteId,
      apheresisSiteId: this.selectedApheresisSiteId,
      aphPickUpDate: this.selectedPickupDate,
      projectedDeliveryDate: this.deliveryWindowStartDate,
      cryoType: this.selectedCryoType,
      requestType: 'Reschedule',
      sourceOfRequest: 'CCM',
      therapyType: 'Commercial',
      reason: this.reason,
      reasonForReschedule: this.reasonForReschedule
    };
    sendSlotBookingRequest({confirmSlotAndOrderUpdateInfo:slotAndOrderUpdateInfo})
        .then(result => {
          this.handleSubmitOrderResponse(result);
        })
        .catch(error => {
          this.errorInfo = error;
          this.showToastMessage(ERROR.toLowerCase(), SLOTSNOTCONFIRMEDVALIDATIONMSG_LABEL, ERROR);
        })
        .finally(() => {
          this.stopSpinner();
        });
  }

  handleSubmitOrderResponse(result) {
    if (result) {
      this.showToastMessage(ERROR.toLowerCase(), result, ERROR);
    } else {
      this.showToastMessage('success', ORDERRESCHEDULEDSUCCESSFULLY_LABEL, 'Success');
      this.communicateParentToCloseActionNrefresh();
    }
  }

  startSpinner() {
    this.showSpinner = true;
  }

  handleSubmitButtonEnablingDisabling() {
    this.isSubmitButtonDisabled = this.selectedPickupDate && this.deliveryWindowStartDate &&
    this.selectedApheresisSite && this.selectedApheresisSiteId &&
    this.selectedCryoType ? false : true;
  }

  handleSpinner(event) {
    const eventInfo = event.detail;
    if (eventInfo && eventInfo.showSpinner) {
      this.startSpinner();
    } else {
      this.stopSpinner();
    }
  }
}
