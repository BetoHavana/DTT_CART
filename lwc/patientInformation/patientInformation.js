import { LightningElement, track, api, wire } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';

import { email } from 'c/appConstants';

import CONTACT_INFORMATION_LABEL from '@salesforce/label/c.ContactInformation';
import DATE_OF_BIRTH_LABEL from '@salesforce/label/c.DateofBirth';
import EMAIL_ADDRESS_LABEL from '@salesforce/label/c.EmailAddress';
import EMAIL_VALIDATION_LABEL from '@salesforce/label/c.EmailFieldsValidation';
import FIRSTNAME_LABEL from '@salesforce/label/c.FirstName';
import LASTNAME_LABEL from '@salesforce/label/c.LastName';
import MANDATORY_FIELDS_LABEL from '@salesforce/label/c.MandatoryFieldsValidation';
import MEDICAL_RECORD_NUMBER_LABEL from '@salesforce/label/c.MedicalRecordNumber';
import MEDICAL_RECORD_NUMBER_TOOL_TIP_LABEL from '@salesforce/label/c.MedicalRecordNumberToolTip';
import PATIENT_INFORMATION_LABEL from '@salesforce/label/c.PatientInformation';
import PLEASE_COMPLETE_LABEL from '@salesforce/label/c.PleaseComplete';
import PREFERRED_METHOD_OF_COMMUNICATION_LABEL from '@salesforce/label/c.PreferredMethodofCommunication';
import PRIMARY_CONTACT_NUMBER_LABEL from '@salesforce/label/c.PrimaryContactNumber';
import PRIMARY_PHONE_NUMBER_TYPE_LABEL from '@salesforce/label/c.PrimaryPhoneNumberType';
import SALUTATION_LABEL from '@salesforce/label/c.Salutation';

import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import PREFERRED_METHOD_FIELD from '@salesforce/schema/Account.PreferredMethodOfCommunication__c';
import PRIMARY_CONTACT_NUMBER_FIELD from '@salesforce/schema/Account.PrimaryContactNumberType__c';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import GENDER_FIELD from '@salesforce/schema/Contact.HealthCloudGA__Gender__c';
import SALUTATION_FIELD from '@salesforce/schema/Contact.Salutation';

export default class PatientInformation extends LightningElement {
  relationshipToPatientValues;

  @track isPatientEmailRequired = false;

  @track showValidation = false;

  @track showPatientMandatory = false;

  @api patient={};

  @api readonlyChild;

  @api readonlyRequired = false;

  connectedCallback() {
    this.fetchInitialValues();
  }

  labels = {
    CONTACT_INFORMATION_LABEL,
    DATE_OF_BIRTH_LABEL,
    EMAIL_ADDRESS_LABEL,
    EMAIL_VALIDATION_LABEL,
    FIRSTNAME_LABEL,
    LASTNAME_LABEL,
    MANDATORY_FIELDS_LABEL,
    MEDICAL_RECORD_NUMBER_LABEL,
    MEDICAL_RECORD_NUMBER_TOOL_TIP_LABEL,
    PATIENT_INFORMATION_LABEL,
    PLEASE_COMPLETE_LABEL,
    PREFERRED_METHOD_OF_COMMUNICATION_LABEL,
    PRIMARY_CONTACT_NUMBER_LABEL,
    PRIMARY_PHONE_NUMBER_TYPE_LABEL,
    SALUTATION_LABEL
  };

  @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
  objectInfo;

  @wire(getPicklistValues, { recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: SALUTATION_FIELD })
  salutationPicklistValues;

  @wire(getObjectInfo, {objectApiName: ACCOUNT_OBJECT})
  objectAccountInfo;

  @wire(getPicklistValues, {recordTypeId: '$objectAccountInfo.data.defaultRecordTypeId', fieldApiName: PRIMARY_CONTACT_NUMBER_FIELD})
  primaryPhoneTypePicklistValues;

  @wire(getPicklistValues, {recordTypeId: '$objectAccountInfo.data.defaultRecordTypeId', fieldApiName: PREFERRED_METHOD_FIELD})
  preferredMethodPicklistValues;

  @track backKeyPressed=false;

  @track patientFirstName;

  @track patientLastName;

  @track patientMI;

  @track patientSalutation;

  @track patientMRN;

  @track patientDOB;

  @track patientPhone;

  @track patientPrimaryPhoneNumberType;

  @track patientPreferredMethodOfCommunication;

  @track patientEmail;

  @api
  setRequiredValidation() {
    const allInputData = [...this.template.querySelectorAll('lightning-input,lightning-combobox')];
    let patientData = [];
    allInputData.forEach((el) => {
      if (el.name.startsWith('patient')) {
        patientData.push(el);
      }
    });

    const patientValid = patientData.reduce((validSoFar, inputCmp) => {
      inputCmp.reportValidity();
      return validSoFar && inputCmp.checkValidity();
    }, true);

    if (patientValid === false) {
      this.showPatientMandatory = true;
    } else {
      this.showPatientMandatory = false;
    }

    let allValid;
    if (patientValid === true) {
      allValid = true;
    } else {
      allValid = false;
    }
    return allValid;
  }

  @api
  sendData() {
    const patientData = {};
    const allInputData = this.template
        .querySelectorAll('lightning-input,lightning-combobox');
    allInputData.forEach((el) => {
      if (el.name.startsWith('patient')) {
        patientData[el.label] = el.value;
      }
    });
    this.dispatchEvent(new CustomEvent('patientinfo', {detail:
          { patientData: patientData}}));
  }

  fetchInitialValues() {
    this.patientFirstName = this.patient[this.labels.FIRSTNAME_LABEL];
    this.patientLastName = this.patient[this.labels.LASTNAME_LABEL];
    this.patientSalutation = this.patient[this.labels.SALUTATION_LABEL];
    this.patientMRN = this.patient[this.labels.MEDICAL_RECORD_NUMBER_LABEL];
    this.patientDOB = this.patient[this.labels.DATE_OF_BIRTH_LABEL];
    this.patientPhone = this.patient[this.labels.PRIMARY_CONTACT_NUMBER_LABEL];
    this.patientPrimaryPhoneNumberType = this.patient[this.labels.PRIMARY_PHONE_NUMBER_TYPE_LABEL];
    this.patientPreferredMethodOfCommunication = this.patient[this.labels.PREFERRED_METHOD_OF_COMMUNICATION_LABEL];
    this.patientEmail = this.patient[this.labels.EMAIL_ADDRESS_LABEL];
  }

  handleMobileKeyPress(event) {
    var charCode = event.keyCode;
    this.backKeyPressed = false;

    if(charCode === 8) {
      this.backKeyPressed = true;
    } else {
      this.backKeyPressed = false;
    }
    if (charCode !== 229 && charCode !== 8 && charCode !== 45 && (charCode < 48 || (charCode > 57 && charCode < 96) || charCode > 105)) {
      this.specChar = true;
    } else {
      this.specChar = false;
    }
  }

  handlePatientPreferredMethodOfCommunication(event) {
    if (event.detail.value === email) {
      this.isPatientEmailRequired = true;
    } else {
      this.isPatientEmailRequired = false;
    }
  }

  mobileHandler(event) {
    event.preventDefault();
    var mobileField = event.target;
    var mobileEntered = event.target.value;
    if (!this.specChar) {
      if (mobileEntered.length === 3) {
        if(!this.backKeyPressed) {
          this.patientPhone = mobileEntered + '-';
          mobileField.value = this.patientPhone;
        }
      } else if (mobileEntered.length === 7) {
        if(!this.backKeyPressed) {
          this.patientPhone = mobileEntered + '-';
          mobileField.value = this.patientPhone;
        }
      } else {
        this.patientPhone = mobileEntered;
        mobileField.value = this.patientPhone;
      }
    } else {
      event.target.value = mobileEntered.substr(0, mobileEntered.length - 1);
    }
  }
}
