import { LightningElement, track, wire, api } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { getQueryParameters } from 'c/sharedUtils';

import { PATIENT_DETAILS_CHEVRON, PATIENTS_PAGE_REFERENCE } from 'c/pageReferences';

import ENROLL_PATIENT from '@salesforce/label/c.EnrollNewPatient';
import MRN from '@salesforce/label/c.MRN';
import PATIENTNAME from '@salesforce/label/c.PatientName';
import PATIENT_DETAILS from '@salesforce/label/c.PatientDetails';
import PRIMARY_CONTACT_NUMBER from '@salesforce/label/c.PrimaryContactNumber';
import SCHEDULE_EXISTING_PATIENT_LABEL from '@salesforce/label/c.ScheduleExistingPatient';
import TREATING_PHYSICIAN from '@salesforce/label/c.TreatingPhysician';
import TREATMENT_CENTER_COORDINATOR_LABEL from '@salesforce/label/c.TreatmentCenterCoordinator';
import VALIDATION_MESSAGE from '@salesforce/label/c.AvailabilityCalendarPageValidationText';

import GETPATIENT from '@salesforce/apex/PatientJourneyController.getDetailsByPatientId';

export default class PatientCard extends NavigationMixin(LightningElement) {

  @track patientData;

  @track patientId;

  @track showValidationMessage = false;

  @api selectedStep;

  labels = {
    ENROLL_PATIENT,
    MRN,
    PATIENTNAME,
    PATIENT_DETAILS,
    PRIMARY_CONTACT_NUMBER,
    SCHEDULE_EXISTING_PATIENT_LABEL,
    TREATING_PHYSICIAN,
    TREATMENT_CENTER_COORDINATOR_LABEL,
    VALIDATION_MESSAGE,
  };

  @wire(GETPATIENT, { patientId: '$patientId' })
  wiredPatientData({ error, data }) {
    if (error) {
      this.error = error;
    }
    if (data) {
      this.patientData = JSON.parse(data);
      this.showValidationMessage = false;
    }
  }

  get patientName(){
    if(this.patientData && this.patientData.memberFirstName){
      return `${this.patientData.memberLastName}, ${this.patientData.memberFirstName}`
    }
    return '';
  }

  get showIfStepOne() {
    return this.selectedStep === 'Step1';
  }

  connectedCallback () {
    const urldata = getQueryParameters();
    if (urldata) {
      this.patientId = urldata.patientId ? urldata.patientId : '';
    }
    this.patientData = {
      memberFirstName: '',
      memberLastName: '',
      memberMRN: '',
      memberPhone: '',
      cartCoordinator: '',
      treatingPhysician: ''
    };
  }

  @api
  getPatientData() {
    if (this.patientData.memberFirstName !== ''
        && this.patientData.memberLastName !== ''
        && this.patientData.memberMRN !== ''
        && this.patientData.memberPhone !== ''
        && this.patientData.cartCoordinator !== ''
        && this.patientData.treatingPhysician !== '') {
      this.showValidationMessage = false;
      return this.patientData;
    } else {
      this.showValidationMessage = true;
      return null;
    }
  }

  navigateToLandingPage() {
    this[NavigationMixin.Navigate](PATIENTS_PAGE_REFERENCE);
  }


  navigateToPatientEnrollment() {
    this[NavigationMixin.Navigate](PATIENT_DETAILS_CHEVRON);
  }

}
