import { LightningElement, wire, track, api } from 'lwc';
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import ORDERS_OBJECT from '@salesforce/schema/Order__c';
import REASONFORRESCHEDULE_FIELD from '@salesforce/schema/Order__c.ReasonforReschedule__c';

import CANCEL_LABEL from '@salesforce/label/c.CancelButton';
import REASONFORRESCHEDULE_LABEL from '@salesforce/label/c.ReasonForReschedule';
import REASONFORRESCHEDULEREQ_LABEL from '@salesforce/label/c.PleaseSpecifyReasonOfOrderReschedule';
import NEXT_LABEL from '@salesforce/label/c.Next';
import SPECIFYREASONFORRESCHEDULE_LABEL from '@salesforce/label/c.SpecifyReasonForReschedule';


export default class ReasonForRescheduleComp extends LightningElement {

  @track rescheduleReasonOptions;
  @api reasonForReschedule = '';
  @api reason = '';

  labels = {
    NEXT_LABEL,
    REASONFORRESCHEDULE_LABEL,
    REASONFORRESCHEDULEREQ_LABEL,
    SPECIFYREASONFORRESCHEDULE_LABEL,
    CANCEL_LABEL
  };

  get reasonRequired() {
    return this.reasonForReschedule === 'Other';
  }

  get disableNextButton() {
    return this.reasonForReschedule && (this.reason || this.reasonForReschedule !== 'Other') ? false : true;
  }

  @wire(getObjectInfo, { objectApiName: ORDERS_OBJECT })
  orderObjectInfo;

  @wire(getPicklistValues, {
    recordTypeId: '$orderObjectInfo.data.defaultRecordTypeId',
    fieldApiName: REASONFORRESCHEDULE_FIELD
  })
  wiredData(result) {
    if (result && result.data && result.data.values) {
      this.rescheduleReasonOptions = result.data.values;
    }
  }

  changeHandler(event) {
    const eventTarget = event.target;
    switch (eventTarget.name) {
      case 'reasonForReschedule':
        this.reasonForReschedule = eventTarget.value;
        break;
      case 'reason':
        this.reason = eventTarget.value;
        break;
      default:
    }
  }

  closePopup() {
    this.dispatchEvent(new CustomEvent('closepopup'));
  }

  handleNextButtonClick() {
    this.dispatchEvent(new CustomEvent('showspinner'));
    this.dispatchEvent(new CustomEvent('nextbuttonclicked'));
  }
}
