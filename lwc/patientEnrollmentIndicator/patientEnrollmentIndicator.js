import { LightningElement, track, wire, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import { AVAILABILITY_CALENDAR_PAGE_REFERENCE, PATIENTS_PAGE_REFERENCE } from 'c/pageReferences';

import createEnrollment from '@salesforce/apex/PatientEnrollmentIndicatorController.createEnrollment';
import fetchDuplicatePatients from '@salesforce/apex/PatientEnrollmentIndicatorController.fetchDuplicatePatients';
import fetchStepDetails from '@salesforce/apex/PatientEnrollmentIndicatorController.getStepDetails';

import BACK_LABEL from '@salesforce/label/c.Back';
import CLOSE_LABEL from '@salesforce/label/c.Close';
import CONTINUE_LABEL from '@salesforce/label/c.Continue';
import EXISTING_PATIENT_CONTACT_FOOTER from '@salesforce/label/c.ExistingPatientContactFooter';
import EXISTING_PATIENT_DUPLICATE_TEXT from '@salesforce/label/c.ExistingPatientDuplicateText';
import EXISTING_PATIENT_FOUND from '@salesforce/label/c.ExistingPatientFound';
import FIRSTNAME_LABEL from '@salesforce/label/c.FirstName';
import HOME_LABEL from '@salesforce/label/c.Home';
import LASTNAME_LABEL from '@salesforce/label/c.LastName';
import NEW_ENROLLMENT_LABEL from '@salesforce/label/c.NewEnrollment';
import PATIENT_DETAILS_SUBMITTED_LABEL from '@salesforce/label/c.PatientDetailsSubmitted';
import PATIENT_ENROLLMENT_HELP_LABEL from '@salesforce/label/c.PatientEnrollmentHelp';
import PATIENT_ENROLLMENT_SUCCESS_LABEL from '@salesforce/label/c.PatientEnrollmentSuccess';
import PATIENT_INFORMATION_LABEL from '@salesforce/label/c.PatientInformation';
import PATIENTS_LABEL from '@salesforce/label/c.Patients';
import PATIENT_SERVICE_CHECK_LABEL from '@salesforce/label/c.PatientServiceProgramsCheck';
import PATIENT_SERVICE_DISCLAIMER_LABEL from '@salesforce/label/c.PatientServiceProgramsDisclaimer';
import PATIENT_SERVICE_LABEL from '@salesforce/label/c.PatientServicePrograms';
import REVIEW_SUBMIT_ERROR_LABEL from '@salesforce/label/c.ReviewAndAttest';
import REVIEW_SUBMIT_LABEL from '@salesforce/label/c.ReviewSubmit';
import REVIEW_SUBMIT_CHECK_LABEL from '@salesforce/label/c.ReviewSubmitCheck';
import SCHEDULE_APHERESIS_LABEL from '@salesforce/label/c.ScheduleApheresis';
import SUBMIT_LABEL from '@salesforce/label/c.Submit';
import TREATMENT_LABEL from '@salesforce/label/c.TreatmentDetails';

export default class PatientEnrollmentIndicator extends NavigationMixin(LightningElement) {
  patientEnrollFirstStepConst = 1;

  patientEnrollSecondStepConst = 2;

  patientEnrollReviewPageConst = 3;

  progresSteps;

  @api readonly = false;

  @track requiredonly = true;

  @track treatmentReadOnly = true;

  @track consentCheck;

  @track duplicatePatient;

  @track enrolledPatientId = '';

  @track enteredPatient = {};

  @track enablePatientService = false;

  @track isAttested = false;

  @track isPatientDuplicate = false;

  @track patientData;

  @track selectedPhysician = [];

  @track selectedPhysicianTitle = '';

  @track selectedStep = 'Step1';

  @track showApherisisBtn = false;

  @track showReviewMandatory = false;

  @track showSectionOne = true;

  @track showSectionThree = false;

  @track showSectionTwo = false;

  @track showSpinner = false;

  @track showSubmitBtn = false;

  get currentStep() {
    return this.selectedStep ? parseInt(this.selectedStep.substring(this.selectedStep.length - 1), 10) : 1;
  }

  get duplicatePatientBirthDate() {
    return this.duplicatePatient ? this.duplicatePatient.PersonBirthdate : '';
  }

  get duplicatePatientName() {
    if (this.duplicatePatient) {
      return this.duplicatePatient.MiddleName
        ? `${this.duplicatePatient.FirstName}, ${this.duplicatePatient.MiddleName}, ${this.duplicatePatient.LastName}`
        : `${this.duplicatePatient.FirstName}, ${this.duplicatePatient.LastName}`;
    }
    return '';
  }

  get showBackBtn() {
    if (this.showSectionOne === false && this.showApherisisBtn === false) {
      return true;
    }
    return false;
  }

  get showContinueBtn() {
    if (this.showSubmitBtn !== true && this.showApherisisBtn !== true) {
      return true;
    }
    return false;
  }

  @wire(fetchStepDetails)
  progresStepsResult({ data }) {
    const resultData = [];
    if (data) {
      const parsedData = JSON.parse(data);
      if (parsedData) {
        for (const itr in parsedData) {
          const temp = {
            title: parsedData[itr].MasterLabel,
            value: `Step${parsedData[itr].Order__c}`,
            id: parsedData[itr].Id,
          };
          resultData.push(temp);
        }
        this.progresSteps = resultData;
      }
    }
  }

  labels = {
    BACK_LABEL,
    CLOSE_LABEL,
    CONTINUE_LABEL,
    EXISTING_PATIENT_CONTACT_FOOTER,
    EXISTING_PATIENT_DUPLICATE_TEXT,
    EXISTING_PATIENT_FOUND,
    FIRSTNAME_LABEL,
    HOME_LABEL,
    LASTNAME_LABEL,
    NEW_ENROLLMENT_LABEL,
    PATIENT_DETAILS_SUBMITTED_LABEL,
    PATIENT_ENROLLMENT_HELP_LABEL,
    PATIENT_ENROLLMENT_SUCCESS_LABEL,
    PATIENT_INFORMATION_LABEL,
    PATIENTS_LABEL,
    PATIENT_SERVICE_LABEL,
    PATIENT_SERVICE_CHECK_LABEL,
    PATIENT_SERVICE_DISCLAIMER_LABEL,
    REVIEW_SUBMIT_CHECK_LABEL,
    REVIEW_SUBMIT_ERROR_LABEL,
    REVIEW_SUBMIT_LABEL,
    SCHEDULE_APHERESIS_LABEL,
    SUBMIT_LABEL,
    TREATMENT_LABEL,
  };

  createPatientEnrollment(labelVal) {
    const val = this.currentStep;
    if (val === this.patientEnrollReviewPageConst) {
      this.readonly = true;
      this.requiredonly = false;
      this.treatmentReadOnly = false;
    }
    this.progressNextStep();
    if (labelVal === this.labels.SUBMIT_LABEL) {
      const strPatient = JSON.stringify(this.enteredPatient);
      const strPhysician = JSON.stringify(this.selectedPhysician);
      const strPatientServiceProgram = JSON.stringify(this.enablePatientService);
      this.showSpinner = true;
      createEnrollment({
        strPatientJSON: strPatient,
        strPhysicianJSON: strPhysician,
        strPatientServiceProgramJSON: strPatientServiceProgram,
      })
        .then((results) => {
          this.showSpinner = false;
          if(results) {
            this.enrolledPatientId = results.Id;
          }
        })
        .catch(() => {
          this.showSpinner = false;
        });
    }
  }

  editDetails(event) {
    const clickedVar = event.target.name;
    if (clickedVar === 'editPatientInfo') {
      this.selectedStep = 'Step1';
    } else if (clickedVar === 'editTreatmentInfo') {
      this.selectedStep = 'Step2';
    } else {
      this.selectedStep = 'Step3';
    }
    this.readonly = false;
    this.requiredonly = true;
    this.treatmentReadOnly = true;

    this.handleVisibilityBtns(this.selectedStep);
  }

  get successMessage() {
    let msg = this.labels.PATIENT_ENROLLMENT_SUCCESS_LABEL;
    if (this.enteredPatient) {
      const name = `<b><i>${this.enteredPatient[this.labels.LASTNAME_LABEL]}, ${this.enteredPatient[this.labels.FIRSTNAME_LABEL]}</i></b>`;
      msg = msg.replace('{0}', name);
    } else {
      msg = msg.replace('{0}', '');
    }
    return msg;
  }

  handleAgreementCheck(event) {
    this.isAttested = event.target.checked;
  }

  handleDuplicatePatientClose() {
    this.isPatientDuplicate = false;
  }

  handleDuplicateValidation() {
    return new Promise((resolve, reject) => {
      const strPatient = JSON.stringify(this.enteredPatient);
      let nonduplicate;
      this.showSpinner = true;
      fetchDuplicatePatients({
        patientJson: strPatient,
      })
          .then(results => {
            this.showSpinner = false;
            if (results.length > 0) {
              const start = 0;
              this.duplicatePatient = results[start];
              nonduplicate = false;
              this.isPatientDuplicate = true;
            } else {
              nonduplicate = true;
              this.isPatientDuplicate = false;
            }
            resolve(nonduplicate);
          })
          .catch(err => {
            this.showSpinner = false;
            this.isPatientDuplicate = false;
            reject(err);
          });
    });
  }

  handleNext(event) {
    if (this.selectedStep === 'Step1') {
      const allFieldsValid = this.template.querySelector('c-patient-information').setRequiredValidation();
      this.template.querySelector('c-patient-information').sendData();
      if (allFieldsValid) {
        this.handleDuplicateValidation()
          .then(nonDuplicate => {
            if (allFieldsValid !== '' && allFieldsValid && nonDuplicate) {
              this.progressNextStep();
            }
          });
      }
    } else if (this.selectedStep === 'Step2') {
      const allValid = this.template.querySelector('c-treatment-detail').setRequiredValidation();
      const consentCheckBoxValid = this.template.querySelector('c-treatment-detail').setRequiredCheckboxValidation();
      const physicianData = this.template.querySelector('c-treatment-detail').sendData();
      this.handlePhysicianChange(physicianData);
      if (allValid && consentCheckBoxValid){
        this.progressNextStep();
      }
    } else if (this.selectedStep === 'Step3') {
      this.progressNextStep();
      this.readonly = true;
      this.requiredonly = false;
      this.treatmentReadOnly = false;
    } else if (this.selectedStep === 'Step4') {
      if (this.isAttested) {
        this.showReviewMandatory = false;
        this.createPatientEnrollment(event.target.label);
      } else {
        this.showReviewMandatory = true;
      }
    } else {
      event.stopPropagation();
    }
  }

  handlePatientServiceCheck(event) {
    this.enablePatientService = event.target.checked;
  }

  handlePatientInfo(event) {
    if (event.detail) {
      this.enteredPatient = event.detail.patientData;
    }
  }

  handlePhysicianChange(physicianData) {
    if (physicianData) {
      this.selectedPhysician = physicianData.physicianSelection;
      this.selectedPhysicianTitle = physicianData.physicianTitle;
      this.consentCheck = physicianData.consentDocValue;
    } else {
      this.selectedPhysician = [];
      this.selectedPhysicianTitle = '';
      this.consentCheck = '';
    }
  }

  handlePrev() {
    let val = this.currentStep;
    if(val === this.patientEnrollSecondStepConst){
      const physicianData = this.template.querySelector('c-treatment-detail').sendData();
      this.handlePhysicianChange(physicianData);
    }
    if (val !== this.patientEnrollFirstStepConst) {
      val -= 1;
      this.selectedStep = `Step${val}`;
      this.handleVisibilityBtns(this.selectedStep);
    }
    if (val === this.patientEnrollFirstStepConst) {
      this.readonly = false;
    }
  }

  handleVisibilityBtns(stepnum) {
    this.showSubmitBtn = false;
    this.showSectionTwo = false;
    this.showSectionThree = false;
    if (stepnum === 'Step1') {
      this.showSectionOne = true;
    } else if (stepnum === 'Step2') {
      this.showSectionOne = false;
      this.showSectionTwo = true;
    } else if (stepnum === 'Step3') {
      this.showSectionTwo = false;
      this.showSectionThree = true;
    } else if (stepnum === 'Step4') {
      this.showSubmitBtn = true;
      this.showSectionTwo = false;
      this.showSectionThree = false;
    } else {
      this.showApherisisBtn = true;
    }
  }

  navigateToCalendarAvailabilityPage() {
    this[NavigationMixin.Navigate]({
      type: 'comm__namedPage',
      attributes: {
        name: 'AvailabilityCalendar__c',
      }, state: {
        patientId: this.enrolledPatientId,
      },
    });
  }

  navigateToLandingPage() {
    this[NavigationMixin.Navigate](PATIENTS_PAGE_REFERENCE);
  }

 progressNextStep() {
    let val = this.currentStep;
    if (val < this.progresSteps.length) {
      val += 1;
      this.selectedStep = `Step${val}`;
      this.handleVisibilityBtns(this.selectedStep);
    }
  }
}
