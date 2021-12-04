import { LightningElement, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { PATIENT_JOURNEY } from 'c/pageReferences';

import fetchPatientDetails from '@salesforce/apex/PatientsListViewController.fetchPatientDetails';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import USER_ID from '@salesforce/user/Id';

import ACCOUNT from '@salesforce/label/c.Account';
import ALERTS_LABEL from '@salesforce/label/c.Alerts';
import DOB_LABEL from '@salesforce/label/c.Date_of_Birth';
import MRN_LABEL from '@salesforce/label/c.MRN';
import PATIENT_LABEL from '@salesforce/label/c.Patient';
import PATIENT_NOT_FOUND_LABEL from '@salesforce/label/c.PatientNotFound';
import PATIENT_TREATING_MILESTONE_LABEL from '@salesforce/label/c.PatientTreatingMilestone';
import SEARCH_PATIENT_LABEL from '@salesforce/label/c.SearchPatient';
import TREATING_PHYSICIAN_LABEL from '@salesforce/label/c.TreatingPhysician';
import TREATMENT_CENTER_LABEL from '@salesforce/label/c.TreatmentCenter';


const columns = [
  {
    fieldName: 'memberURL',
    label: PATIENT_LABEL,
    type: 'url',
    typeAttributes: {
      label: { fieldName: 'memberName' },
      tooltip: { fieldName: 'memberName' },
      target: '_self',
    },
    sortable: true,
  },
  {
    fieldName: 'mrn',
    label: MRN_LABEL,
    type: 'text',
  },
  {
    fieldName: 'dob',
    label: DOB_LABEL,
    type: 'date',
    typeAttributes: {
      day: '2-digit',
      month: 'short',
      year: 'numeric',
    },
  },
  {
    fieldName: 'patientTreatingMilestone',
    label: PATIENT_TREATING_MILESTONE_LABEL,
    type: 'text',
  },
  {
    fieldName: 'treatingPhysician',
    label: TREATING_PHYSICIAN_LABEL,
    type: 'text',
    sortable: true,
  },
  {
    fieldName: 'alertsURL',
    label: ALERTS_LABEL,
    type: 'url',
    typeAttributes: {
      label: { fieldName: 'alerts' },
      tooltip: { fieldName: 'alerts' },
      target: '_self',
    },
  },
];

const filterByActiveStatus = 'Active';

const USERFIELDS = [
  'User.AccountId',
];

const ACCOUNTFIELDS = [
  'Account.Name',
];

export default class PatientsListView extends NavigationMixin(LightningElement) {
  data;

  treatmentCenterName;

  columns = columns;

  defaultSortDirection = 'asc';

  sortedDirection = 'asc';

  sortedBy;

  sortWithinPaginatedData = false;

  error;

  url;

  recordLimitPerPage = 10;

  buttonsToDisplay = 3;

  displayPagination = true;

  invalidSearchCriteriaMessage;

  treatmentSiteAccountId;

  labels = {
    ACCOUNT,
    SEARCH_PATIENT_LABEL,
    TREATMENT_CENTER_LABEL,
  }

  genericDataTable = 'c-generic-data-table';

  connectedCallback() {
    this[NavigationMixin.GenerateUrl](PATIENT_JOURNEY)
        .then(url => this.url = url);

    fetchPatientDetails()
        .then((data) => {
          this.processPatientData(data);
        })
        .catch((error) => {
          this.error = error;
        });
  }

  processPatientData(data) {
    if (data) {
      const resultData = [];
      const parsedData = JSON.parse(data);
      if (parsedData) {
        for (const itr in parsedData) {
          const temp = {
            isPatientTreatingMilestoneActive: parsedData[itr].isPatientTreatingMilestoneActive,
            memberName: parsedData[itr].memberName,
            memberFirstName: parsedData[itr].memberFirstName,
            memberLastName: parsedData[itr].memberLastName,
            memberURL: `/${this.labels.ACCOUNT}/${parsedData[itr].memberId}`,
            mrn: parsedData[itr].memberMRN,
            dob: parsedData[itr].memberDateOfBirth,
            treatingPhysician: parsedData[itr].treatingPhysician,
            coordinator: parsedData[itr].cartCoordinator,
            patientTreatingMilestone: parsedData[itr].patientTreatingMilestone,
            alerts: parsedData[itr].alerts,
            alertsURL: parsedData[itr].alerts ? `/${this.labels.ACCOUNT}/${parsedData[itr].memberId}` : '',
          };
          resultData.push(temp);
        }
        this.data = resultData;
        this.initialData = resultData;
      }
    }
  }

  handleSearchPatient(event) {
    this.searchData(this.initialData, event.detail);
  }

  searchData(data, newSearchTerm) {
    let newSearchList = data;
    const searchObj = newSearchTerm;

    if (searchObj.coordinator !== '') {
      newSearchList = newSearchList.filter(rec => rec.coordinator === searchObj.coordinator);
    }

    if (searchObj.physician !== '') {
      newSearchList = newSearchList.filter(rec => rec.treatingPhysician === searchObj.physician);
    }

    if (searchObj.searchInp !== '') {
      newSearchList = this.formSearchList(newSearchList, searchObj.searchInp);
    }

    if (searchObj.status !== '') {
      if (searchObj.status === filterByActiveStatus) {
        newSearchList = newSearchList.filter(rec => rec.isPatientTreatingMilestoneActive);
      } else {
        newSearchList = newSearchList.filter(rec => rec.isPatientTreatingMilestoneActive === false);
      }
    }

    if (newSearchList.length === 0) {
      this.data = [];
      this.invalidSearchCriteriaMessage = PATIENT_NOT_FOUND_LABEL;
    } else {
      this.data = newSearchList;
    }
    this.template.querySelector(this.genericDataTable).setDataOnSearch(this.data);
  }

  formSearchList(tempList, newSearchText) {
    const newTempList = [];
    let regexp;
    for (const eachRec in tempList) {
      if (Object.prototype.hasOwnProperty.call(tempList, eachRec)) {
        regexp = new RegExp(newSearchText, 'i');
        if (regexp.test(tempList[eachRec].memberFirstName)
            || regexp.test(tempList[eachRec].memberLastName)
            || (tempList[eachRec].mrn !== null && regexp.test(tempList[eachRec].mrn))) {
          newTempList.push(tempList[eachRec]);
        }
      }
    }
    return newTempList;
  }

  @wire(getRecord, {
    recordId: '$treatmentSiteAccountId',
    fields: ACCOUNTFIELDS,
  }) wiredRecord({
                   error,
                   data,
                 }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.treatmentCenterName = data.fields.Name.value;
    }
  }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: USERFIELDS,
  }) wireuser({
                error,
                data,
              }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.treatmentSiteAccountId = data.fields.AccountId.value;
    }
  }



}
