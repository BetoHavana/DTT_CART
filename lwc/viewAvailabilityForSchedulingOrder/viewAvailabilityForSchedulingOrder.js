import { LightningElement, api, track } from 'lwc';
import validateOrderRequiredFieldsBeforeScheduling from '@salesforce/apex/OrderPlacementController.validateOrderRequiredFieldsBeforeScheduling';
import getOrderDetails from '@salesforce/apex/OrderPlacementController.getOrderDetails';
import confirmSlotBooking from '@salesforce/apex/OrderPlacementController.sendSlotBookingRequest';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import APHERESIS_PICKUP_DATE_LABEL from '@salesforce/label/c.ApheresisPickUpDate';
import APHERESIS_PICKUP_DATE_REQUIRED from '@salesforce/label/c.ApheresisPickUpDateRequired';
import ATTESTEDFORCOMPLETIONCONFIRMATION_LABEL from '@salesforce/label/c.OrderSubmitConfirmationButton';
import ATTESTEDFORCOMPLETIONVALIDATIONMSG_LABEL from '@salesforce/label/c.AttestToCompletionOrderError';
import DATES_AVAIL_FOR_APHRESIS_PICKUP from '@salesforce/label/c.DatesAvailForAphresisPickup';
import DRUG_PRODUCT_DELIVERY_WINDOW_LABEL from '@salesforce/label/c.DrugProductDeliveryWindow';
import EARLIESTPRODUCTDELIVERYDATE_LABEL from '@salesforce/label/c.EarliestProductDeliveryDate';
import LATESTPRODUCTDELIVERYDATE_LABEL from '@salesforce/label/c.LatestProductDeliveryDate';
import ORDER_DETAILS_LABEL from '@salesforce/label/c.OrderDetails';
import ORDERSCHEDULEDSUCCESSFULLY_LABEL from '@salesforce/label/c.OrderScheduledSuccessfully';
import PROJECTED_DELIVERY_DATE_LABEL from '@salesforce/label/c.ProjectedDeliveryDate';
import SOMETHINGWENTWRONGERROR_LABEL from '@salesforce/label/c.SomethingWentWrongPleaseTryAgain';
import SLOTSNOTCONFIRMEDVALIDATIONMSG_LABEL from '@salesforce/label/c.SlotsNotConfirmedValidationMsg';
import ORDER_SUBMISSION_VALIDATION_ERROR_START from '@salesforce/label/c.OrderSubmissionValidationErrorStart';
import ORDER_SUBMISSION_VALIDATION_ERROR_END from '@salesforce/label/c.OrderSubmissionValidationErrorEnd';
import ORDER_SUBMITTED_LABEL from '@salesforce/label/c.OrderStatusSubmitted';
import ORDER_VERIFIED_LABEL from '@salesforce/label/c.OrderVerifiedStatus';
import ORDERSTATUS_SUBMITTED_VERIFIED_LABEL from '@salesforce/label/c.OrderStatusSubmittedOrVerified';
import ORDERMANDATORYFIELDS_LABEL from '@salesforce/label/c.OrderMandatoryFields';

const [SELECTED_COLOR, ERROR, SPACE, THIRTYSIX, TWO, NINE, TEN] = ['#f57e20', 'Error', ' ', 36, 2, 9, 10];

export default class ViewAvailabilityForSchedulingOrder extends LightningElement {
    result = '';

    fieldsInfo = '';

    errorMessage = '';

    showSpinner = true;

    order;

    showCalenderScreen = false;

    treatmentSiteId;

    orderStatus;

    pickupHasError = false;

    orderError = '';

    patientId = '';

    isSubmitButtonDisabled = true;

    selectedCryoType = '';

    selectedApheresisSite = '';

    selectedApheresisSiteId = '';

    apheresisSiteERPSiteId = '';

    apheresisSiteId = '';

    attestedforCompletion = '';

    errorInfo;

    @api orderId;

    @track selectedPickupDate;

    @track deliveryWindowStartDate;

    @track events;


    labels = {
      APHERESIS_PICKUP_DATE_LABEL,
      APHERESIS_PICKUP_DATE_REQUIRED,
      ATTESTEDFORCOMPLETIONCONFIRMATION_LABEL,
      ATTESTEDFORCOMPLETIONVALIDATIONMSG_LABEL,
      DATES_AVAIL_FOR_APHRESIS_PICKUP,
      DRUG_PRODUCT_DELIVERY_WINDOW_LABEL,
      EARLIESTPRODUCTDELIVERYDATE_LABEL,
      LATESTPRODUCTDELIVERYDATE_LABEL,
      ORDERSCHEDULEDSUCCESSFULLY_LABEL,
      SOMETHINGWENTWRONGERROR_LABEL,
      SLOTSNOTCONFIRMEDVALIDATIONMSG_LABEL,
      ORDER_DETAILS_LABEL,
      ORDER_SUBMITTED_LABEL,
      ORDER_VERIFIED_LABEL,
      ORDER_SUBMISSION_VALIDATION_ERROR_START,
      ORDER_SUBMISSION_VALIDATION_ERROR_END,
      ORDERSTATUS_SUBMITTED_VERIFIED_LABEL,
      ORDERMANDATORYFIELDS_LABEL,
      PROJECTED_DELIVERY_DATE_LABEL,
    };

    connectedCallback() {
      this.fetchOrderDetails();
    }

    fetchOrderDetails() {
      getOrderDetails({ listOfOrderIds: this.orderId })
        .then((result) => {
          this.order = result;
          this.treatmentSiteId = result[0].TreatmentSite__c ? result[0].TreatmentSite__c : null;
          this.apheresisSiteERPSiteId = result[0].ApheresisSite__r && result[0].ApheresisSite__r.ERPSiteID__c
            ? result[0].ApheresisSite__r.ERPSiteID__c : '';
          this.patientId = result.Patient__c;
          this.orderStatus = result[0].OrderStatus__c;
          this.attestedforCompletion = result[0].AttestedForCompletion__c;
          this.validateOrderStatusNValidateFurther();
        })
        .catch(() => {
          this.closePopupAndShowToastMessage(ERROR.toLowerCase(), SOMETHINGWENTWRONGERROR_LABEL, ERROR);
        });
    }

    validateOrderStatusNValidateFurther() {
      if (ORDER_SUBMITTED_LABEL === this.orderStatus || ORDER_VERIFIED_LABEL === this.orderStatus) {
        this.closePopupAndShowToastMessage(ERROR.toLowerCase(), ORDERSTATUS_SUBMITTED_VERIFIED_LABEL, ERROR);
      } else {
        this.checkForRequiredFieldsBeforeScheduling();
      }
    }

    checkForRequiredFieldsBeforeScheduling() {
      if (ATTESTEDFORCOMPLETIONCONFIRMATION_LABEL === this.attestedforCompletion) {
        validateOrderRequiredFieldsBeforeScheduling({ listOfOrders: this.order })
          .then((result) => {
            this.processValidationResponse(result);
          })
          .catch(() => {
            this.closePopupAndShowToastMessage(ERROR.toLowerCase(), SOMETHINGWENTWRONGERROR_LABEL, ERROR);
          });
      } else {
        this.closePopupAndShowToastMessage(ERROR.toLowerCase(), ATTESTEDFORCOMPLETIONVALIDATIONMSG_LABEL, ERROR);
      }
    }

    processValidationResponse(data) {
      const validationError = data && data[this.orderId] ? data[this.orderId].join(', ') : '';
      if (validationError) {
        this.closePopupAndShowToastMessage(ERROR.toLowerCase(),
          ORDER_SUBMISSION_VALIDATION_ERROR_START + SPACE + validationError + SPACE + ORDER_SUBMISSION_VALIDATION_ERROR_END,
          ERROR);
      } else {
        this.showCalenderScreen = true;
        this.stopSpinner();
      }
    }

    handleSelectDate(event) {
      try {
        if (event.detail) {
          this.handleDateSelection(event.detail);
          this.setApheresisAndCryoFields(this.template.querySelector('c-availability-calendar-c-c-m'));
        }
      } catch (e) {
        this.error = e;
      }
      this.handleSubmitButtonEnablingDisabling();
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

    handleDateSelection(data) {
      const ets = JSON.parse(JSON.stringify(data.events));
      this.setApheresisDates(data);
      const { id } = data;
      const evt = ets.filter(e => e.id === id);
      if (evt && evt.length) {
        const stDate = evt[0].selecteddate;
        const evtFound = this.getSelectedDateIndex(ets);
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

    getSelectedDateIndex(ets) {
      let index = -1;
      for (let i = 0; i < ets.length; i++) {
        if (ets[i].type === 'DateSelected') {
          index = i;
          break;
        }
      }
      return index;
    }

    setApheresisDates(eventDetail) {
      this.deliveryWindowStartDate = eventDetail.selecteddate;
      this.selectedPickupDate = this.formatDate(eventDetail.date);
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
      this.sendBookingRequest();
    }

    sendBookingRequest() {
      const slotAndOrderUpdateInfo = {
        orderId: this.orderId,
        apheresisSiteERPId: this.apheresisSiteERPSiteId,
        apheresisSiteId: this.selectedApheresisSiteId,
        aphPickUpDate: this.selectedPickupDate,
        projectedDeliveryDate: this.deliveryWindowStartDate,
        cryoType: this.selectedCryoType,
        requestType: 'New',
        sourceOfRequest: 'CCM',
        therapyType: 'Commercial'
      };
    confirmSlotBooking({confirmSlotAndOrderUpdateInfo:slotAndOrderUpdateInfo})
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
        this.closePopupAndShowToastMessage(ERROR.toLowerCase(), result, ERROR);
      } else {
          this.showToastMessage('success', ORDERSCHEDULEDSUCCESSFULLY_LABEL, 'Success');
          this.communicateParentToCloseActionNrefresh();
      }
    }

    startSpinner() {
      this.showSpinner = true;
    }

    handleSubmitButtonEnablingDisabling() {
      this.isSubmitButtonDisabled = !(this.selectedPickupDate && this.deliveryWindowStartDate
            && this.selectedApheresisSite && this.selectedApheresisSiteId
            && this.selectedCryoType);
    }

    stopSpinner() {
      this.showSpinner = false;
    }

    closePopupAndShowToastMessage(variant, message, title) {
      this.stopSpinner();
      this.communicateParentToCloseAction();
      this.showToastMessage(variant, message, title);
    }

    showToastMessage(variant, message, title) {
      const toastEvent = new ShowToastEvent({
        message,
        title,
        variant,
      });
      this.dispatchEvent(toastEvent);
    }

    handleSpinner(event) {
      const eventInfo = event.detail;
      if (eventInfo && eventInfo.showSpinner) {
        this.startSpinner();
      } else {
        this.stopSpinner();
      }
    }

    communicateParentToCloseAction() {
      this.dispatchEvent(new CustomEvent('closepopup'));
    }

    communicateParentToCloseActionNrefresh() {
      this.dispatchEvent(new CustomEvent('closeactionnrefresh'));
    }

    handleClearData() {
      this.selectedPickupDate = '';
      this.deliveryWindowStartDate = '';
    }
}
