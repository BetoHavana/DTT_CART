import { LightningElement, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import MRN from '@salesforce/label/c.MRN';
import PATIENT_ID from '@salesforce/label/c.PatientId';
import PATIENT_TREATING_MILESTONE_LABEL from '@salesforce/label/c.PatientTreatingMilestone';
import SCHEDULE_APHERESIS from '@salesforce/label/c.ScheduleApheresis';
import SCHEDULE_DRUG_PRODUCT_DELIVERY from '@salesforce/label/c.ScheduleDrugProductDelivery';

export default class PatientListCard extends NavigationMixin(LightningElement) {
  labels = {
    MRN,
    PATIENT_ID,
    PATIENT_TREATING_MILESTONE_LABEL,
    SCHEDULE_APHERESIS,
    SCHEDULE_DRUG_PRODUCT_DELIVERY,
  };

  @api patient;

  manufacturingStatusComplete = 'QR Complete';

  get isStatusManufacturing() {
    if (this.patient && this.patient.manufacturingStatus) {
      if (this.patient.manufacturingStatus === this.manufacturingStatusComplete) {
        return true;
      }
      return false;
    }
    return false;
  }

  get patientName() {
    if (this.patient && this.patient.memberFirstName) {
      return `${this.patient.memberLastName}, ${this.patient.memberFirstName} `;
    }
    return '';
  }

  handleSearchPatient(event) {
    this.searchData(this.patient, event.detail);
  }

  scheduleAphresis() {
    if (this.patient.memberId) {
      this[NavigationMixin.Navigate]({
        type: 'comm__namedPage',
        attributes: {
          name: 'AvailabilityCalendar__c',
        },
        state: {
          patientId: this.patient.memberId,
        },
      });
    }
  }

  scheduleDrug() {
    if (this.patient.memberId) {
      this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
          recordId: this.patient.memberId,
          objectApiName: 'Account',
          actionName: 'view',
        },
      });
    }
  }
}
