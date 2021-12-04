import { LightningElement, track, wire, api } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import USERID from '@salesforce/user/Id';

import fetchPhysicianCoordinatorByAccId from
    '@salesforce/apex/PatientEnrollmentIndicatorController.fetchPhysicianCoordinator';

import { roles } from 'c/appConstants';

import USER_ACCOUNT_FIELD from '@salesforce/schema/User.Contact.AccountId';
import USER_FIRST_NAME_FIELD from '@salesforce/schema/User.FirstName';
import USER_LAST_NAME_FIELD from '@salesforce/schema/User.LastName';

import COMPLETE_FIELD_LABEL from '@salesforce/label/c.MandatoryField';
import CONSENT_CHECKBOX_LABEL from '@salesforce/label/c.ConsentCheckbox';
import CONSENT_ERROR_LABEL from '@salesforce/label/c.ConsentError';
import CONSENT_FORMS_LABEL from '@salesforce/label/c.ConsentForms';
import DOCUMENT_NAME from '@salesforce/label/c.DocumentName';
import MANDATORY_FIELDS_LABEL from '@salesforce/label/c.MandatoryFieldsValidation';
import PLEASE_COMPLETE_LABEL from '@salesforce/label/c.PleaseComplete';
import SELECT_PHYSICIAN_LABEL from '@salesforce/label/c.SelectPhysician';
import TREATING_PHYSICIAN_LABEL from '@salesforce/label/c.TreatingPhysician';
import TREATMENT_LABEL from '@salesforce/label/c.TreatmentDetails';
import TREATMENT_CENTER_COORDINATOR_LABEL from '@salesforce/label/c.TreatmentCenterCoordinator';

const columns = [
  {
    label: DOCUMENT_NAME,
    fieldName: 'consentFileName',
    type: 'text',
    sortable: false,
  },
  {
    label: 'Action',
    type: 'button-icon',
    fixedWidth: 100,
    typeAttributes: {
      iconName: 'utility:close',
      name: { fieldName: 'consentFileId' },
      title: 'Delete',
      variant: 'border-filled',
      alternativeText: 'edit',
      disabled: false,
    },
  },
];

const RECORD_LIMIT = 10;

export default class TreatmentDetail extends LightningElement {

  @api readonlyChild;

  @api readonlyTreatmentDetails = false;

  @api selectedPhysician = [];

  @api selectedPhysicianTitle ='';

  @api showCheckMandatory = false;

  @api set consentcheck(value){
    if(value) {
      this.isConsentStrategy = value;
      this.reviewSubmitConsentCheckBox = value;
    }
  }

  @track data = [];

  @track errors = [];

  @track isConsentStrategy = false;

  @track isEntryMandatory = true;

  @track physicianOptions = [];

  @track reviewSubmitConsentCheckBox;

  @track selectedPhysicianId;

  @track showPhysicianMandatory;

  @track user;

  columns = columns;

  defaultSortDirection = 'asc';

  displayPagination = false;

  error;

  labels = {
    COMPLETE_FIELD_LABEL,
    CONSENT_ERROR_LABEL,
    CONSENT_FORMS_LABEL,
    MANDATORY_FIELDS_LABEL,
    PLEASE_COMPLETE_LABEL,
    SELECT_PHYSICIAN_LABEL,
    TREATING_PHYSICIAN_LABEL,
    TREATMENT_LABEL,
    TREATMENT_CENTER_COORDINATOR_LABEL,
  };

  recordLimitPerPage = RECORD_LIMIT;

  sortedBy;

  sortedDirection = 'asc';

  constructor() {
    super();
    this.setRequiredCheckboxValidation = this.setRequiredCheckboxValidation.bind(this);
  }

  @wire(getRecord, {
    recordId: USERID,
    fields: [USER_FIRST_NAME_FIELD, USER_LAST_NAME_FIELD, USER_ACCOUNT_FIELD],
  })
  wiredUser({ data, errors }) {
    if (errors) {
      this.error = errors;
    } else {
      this.user = data;
      if (data) {
        const userId = getFieldValue(data, USER_ACCOUNT_FIELD);
        fetchPhysicianCoordinatorByAccId({ accountId: userId })
          .then(contacts => {
            const phyOptions = [];
            contacts.forEach(item => {
              if (item.subtitle === roles.physician) {
                phyOptions.push({
                  label: item.title,
                  value: item.id,
                  title: item.title,
                  sObjectType: item.sObjectType,
                  subtitle: item.subtitle,
                  place_id: item.place_id,
                  Id: item.id,
                });
              }
            });
            this.physicianOptions = phyOptions;
          })
          .catch(error => {
            this.error = error;
          });
      }
    }
  }

  get consentcheck(){
    return this.isConsentStrategy;
  }

  get consentLabel(){
    return CONSENT_CHECKBOX_LABEL;
  }

  get coordinatoruserName() {
    if (this.user) {
      const firstName = `${getFieldValue(this.user, USER_FIRST_NAME_FIELD)}`;
      const lastName = `${getFieldValue(this.user, USER_LAST_NAME_FIELD)}`;
      return `${firstName} ${lastName}`;
    }
    return '';
  }

  get selectedPhysicianOption() {
    if (this.selectedPhysician.length) {
      return this.selectedPhysician[0].value;
    }
    return '';
  }

  get uploadAccountId() {
    if (this.user) {
      return `${getFieldValue(this.user, USER_ACCOUNT_FIELD)}`;
    }
    return '';
  }

  handlePhysicianChange(event) {
    const selectedId = event.detail.value;
    this.selectedPhysicianId = selectedId;
    if (selectedId) {
      const optionSelected = this.physicianOptions.find(phy => phy.value === selectedId);
      if (optionSelected) {
        this.selectedPhysician = [optionSelected];
      }
    }
  }

  handleRowAction(event) {
    const row = event.detail.row.consentFileId;
    const rec = this.data;
    const newarr = [];
    for (let i = 0; i < rec.length; i++) {
      if (rec[i].consentFileId !== row) {
        newarr.push(rec[i]);
      }
    }
    this.data = newarr;
  }

  @api
  sendData() {
    const selectedResult = this.selectedPhysician;
    const checkedConsentStrategy = this.isConsentStrategy;
    const checkedReviewSubmitConsentCheckBox = this.reviewSubmitConsentCheckBox;
    const physicianTitle = selectedResult.find(element => element.title !== null);
    let title = '';
    if (physicianTitle) {
      title = physicianTitle.title;
    }
    return {
      physicianSelection: selectedResult,
      physicianTitle: title,
      consentDocValue: checkedConsentStrategy,
      consentCheckedValue: checkedReviewSubmitConsentCheckBox,
    };
  }

  @api
  setRequiredValidation() {
    const allValid = this.template.querySelector('lightning-combobox').reportValidity();
    if (allValid === false) {
      this.showPhysicianMandatory = true;
    } else {
      this.showPhysicianMandatory = false;
    }
    return allValid;
  }

  @api
  setRequiredCheckboxValidation() {
    if (this.isConsentStrategy === false) {
      this.showCheckMandatory = true;
    } else {
      this.showCheckMandatory = false;
    }
    return this.isConsentStrategy;
  }

  handleConsentStrategyCheck(event){
    this.isConsentStrategy = event.detail.checked;
    if( event.detail.checked) {
      this.reviewSubmitConsentCheckBox = event.detail.checked;
      this.showCheckMandatory = false;
    } else {
      this.reviewSubmitConsentCheckBox = false;
    }
  }
}
