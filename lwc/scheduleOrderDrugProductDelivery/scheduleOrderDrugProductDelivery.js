import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import CONFIRMEDFPDELIVERYDATEFIELD from '@salesforce/schema/Order__c.ConfirmedFPDeliveryDate__c';
import IDFIELD from '@salesforce/schema/Order__c.Id';

import getOrderDetails from '@salesforce/apex/OrderPlacementController.getOrderDetails';

import DATES_AVAILABLE_FOR_DRUGPRODUCTDELIVERY from '@salesforce/label/c.DatesAvailableForDrugProductDelivery';
import SUBMIT_LABEL from '@salesforce/label/c.Submit';
import SCHEDULE_ERROR_LABEL from '@salesforce/label/c.ScheduleDrugProductDeliveryError';
import SCHEDULED_DRUG_PRODUCT_DELIVERY from '@salesforce/label/c.ScheduleDrugProductDelivery';

import SCHEDULE_SHIPPED_ERROR_LABEL from '@salesforce/label/c.ScheduleShippedDrugProductDeliveryError';

import SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT from '@salesforce/label/c.ScheduledDrugProductDeliveryErrorText';
import SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT from '@salesforce/label/c.ScheduledDrugProductDeliveryHelpText';
import SELECTED_DRUG_PRODUCT_DELIVERY_DATE from '@salesforce/label/c.SelectedDrugProductDeliveryDate';
import TODAY_DATE_LABEL from '@salesforce/label/c.TodayDate';

const [ERROR, SUCCESS, AVAILABLE_DATE_COLOR, QR_COMPLETE, DELIVERY_PICKUP_DATE, BACKGROUND, DELIVERY, SHIPPING_STATUS]
    = ['Error', 'Success', '#DAFBE1', 'QR Complete', 'deliveryPickupDate', 'background', 'delivery','Shipping Drug Product'];

const TEN = 10;
const TWENTY_ONE = 21;
const TWENTY = 20;
const SIX = 6;
const NINE = 9;

export default class ScheduleOrderDrugProductDelivery extends LightningElement {
  @api orderId;

  @track selectedDeliveryDate = '';

  deliveryDateError = false;

  deliveryRange = [];

  events = [];

  showCalendar = false;

  showSpinner = false;

  showWeekend = true;

  zeroTimeZone = 'Africa/Abidjan';

  labels = {
    DATES_AVAILABLE_FOR_DRUGPRODUCTDELIVERY,
    SCHEDULE_ERROR_LABEL,
    SCHEDULED_DRUG_PRODUCT_DELIVERY,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_ERRORTEXT,
    SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT,
    SCHEDULE_SHIPPED_ERROR_LABEL,
    SELECTED_DRUG_PRODUCT_DELIVERY_DATE,
    SUBMIT_LABEL,
    TODAY_DATE_LABEL,
  };

  connectedCallback() {
    this.fetchOrderDetails();
  }

  get scheduledDrugProductDateHelpText() {
    if (this.deliveryRange) {
      if ( Array.isArray(this.deliveryRange) && this.deliveryRange.length > 0) {
        let msg = this.labels.SCHEDULED_DRUG_PRODUCT_DELIVERY_HELPTEXT;
        msg = msg.replace('{0}', this.deliveryRange[0]);
        msg = msg.replace('{1}', this.deliveryRange[1]);
        msg = msg.replace('{1}', this.deliveryRange[1]);
        return msg;
      }
      return '';
    }
    return '';
  }

  changeTimezone(date, timezone) {

    const invdate = new Date(date.toLocaleString('en-US', {
      timeZone: timezone,
    }));

    const diff = date.getTime() - invdate.getTime();
    return invdate;
  }

  fetchOrderDetails() {
    getOrderDetails({ listOfOrderIds: this.orderId })
        .then(result => {
          this.order = result;
          this.treatmentSiteId = result[0].TreatmentSite__c ? result[0].TreatmentSite__c : null;
          this.apheresisSiteERPSiteId = result[0].ApheresisSite__r && result[0].ApheresisSite__r.ERPSiteID__c
              ? result[0].ApheresisSite__r.ERPSiteID__c : '';
          this.patientId = result.Patient__c;
          this.orderStatus = result[0].OrderStatus__c;
          this.attestedforCompletion = result[0].AttestedForCompletion__c;
          this.estimatedDrugProductDeliveryDate = result[0].EstimatedDrugProductDeliveryDate__c;
          this.manufacturingStatus = result[0].ManufacturingStatus__c;
          this.shippingStatus = result[0].ShippingStatus__c;
          this.validateOrderStatusNValidateFurther();
        })
        .catch(() => {
          this.closePopupAndShowToastMessage(ERROR.toLowerCase(), ERROR, ERROR);
        });
  }

  validateOrderStatusNValidateFurther() {
    if (QR_COMPLETE !== this.manufacturingStatus) {
      this.showCalendar = false;
      this.closePopupAndShowToastMessage(ERROR.toLowerCase(), this.labels.SCHEDULE_ERROR_LABEL, ERROR);
    }else if (SHIPPING_STATUS == this.shippingStatus){
        this.showCalendar = false;
        this.closePopupAndShowToastMessage(ERROR.toLowerCase(), this.labels.SCHEDULE_SHIPPED_ERROR_LABEL, ERROR);
    }else {
      this.showCalendar = true;
      this.updateDeliveryRange();
    }
  }

  closePopupAndShowToastMessage(variant, message, title) {
    this.stopSpinner();
    this.communicateParentToCloseAction();
    this.showToastMessage(variant, message, title);
  }

  stopSpinner() {
    this.showSpinner = false;
  }

  communicateParentToCloseAction() {
    this.dispatchEvent(new CustomEvent('closepopup'));
  }

  showToastMessage(variant, message, title) {
    const toastEvent = new ShowToastEvent({
      message,
      title,
      variant
    });
    this.dispatchEvent(toastEvent);
  }

  updateDeliveryRange() {
    if (this.estimatedDrugProductDeliveryDate) {
      let startdate = this.estimatedDrugProductDeliveryDate;
      let enddate = new Date(startdate);
      enddate = this.changeTimezone(enddate, this.zeroTimeZone);
      enddate.setDate(enddate.getDate() + TWENTY);

      let dd = enddate.getDate();
      if (dd < TEN) {
        dd = `0${dd}`;
      }
      let mm = enddate.getMonth() + 1;
      if (mm < TEN) {
        mm = `0${mm}`;
      }
      const yyyy = enddate.getFullYear();
      enddate = `${yyyy}-${mm}-${dd}`;

      for (let i = 0; i < TWENTY_ONE; i++) {
        let tmpdate = new Date(startdate);
        tmpdate = this.changeTimezone(tmpdate, this.zeroTimeZone);
        tmpdate.setDate(tmpdate.getDate() + i);
        if (tmpdate.getDay() !== 0 && tmpdate.getDay() !== 1 && tmpdate.getDay() !== SIX) {
          this.events.push({
            id: this.genRandom(),
            title: DELIVERY_PICKUP_DATE,
            start: this.formatDate(tmpdate),
            end: this.formatDate(tmpdate),
            textColor: '#454545',
            rendering: BACKGROUND,
            color: AVAILABLE_DATE_COLOR,
            type: DELIVERY,
            selecteddate: this.formatDate(tmpdate),
            allDay: true,
          });
        }
      }
      this.deliveryRange.push(startdate);
      this.deliveryRange.push(enddate);
    }
  }

  genRandom() {
    return Math.random()
        .toString(this.maxDigits)
        .substr(this.randomIdStartInd, this.randomIdEndInd);
  }

  formatDate(dateObj) {
    if (dateObj instanceof Date) {
      let enddate = dateObj;
      let dd = enddate.getDate();
      if (dd <= NINE) {
        dd = `0${dd}`;
      }
      let mm = enddate.getMonth() + 1;
      if (mm < TEN) {
        mm = `0${mm}`;
      }
      const yyyy = enddate.getFullYear();
      enddate = `${yyyy}-${mm}-${dd}`;
      return enddate;
    }
    return '';
  }

  handleSelectDate(event) {
    if (event.detail) {
      this.selectedDeliveryDate = event.detail.selecteddate;
    }
  }

  submitOrderInfo() {
    if (this.selectedDeliveryDate) {
      this.startSpinner();
      this.updateOrder();
    } else {
      this.deliveryDateError = true;
    }
  }

  startSpinner() {
    this.showSpinner = true;
  }

  updateOrder() {
    if (this.selectedDeliveryDate) {
      const fields = {};
      fields[CONFIRMEDFPDELIVERYDATEFIELD.fieldApiName] = this.selectedDeliveryDate;
      fields[IDFIELD.fieldApiName] = this.orderId;
      const recordInput = { fields };

      updateRecord(recordInput)
          .then(() => {
            this.closePopupAndShowToastMessage(SUCCESS.toLowerCase(), SUCCESS, SUCCESS);
          })
          .catch(() => {
            this.closePopupAndShowToastMessage(ERROR.toLowerCase(), ERROR, ERROR);
          });
    }
  }
}
