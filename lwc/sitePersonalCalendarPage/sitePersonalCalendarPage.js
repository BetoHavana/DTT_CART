import { LightningElement, track } from 'lwc';

import fetchPatientDetailsForSiteCalendar from
  '@salesforce/apex/PatientsListViewController.fetchPatientDetailsForSiteCalendar';

import PATIENTS from '@salesforce/label/c.Patients';
import SEARCH from '@salesforce/label/c.AvailabilityCalendarSearch';

export default class SitePersonalCalendarPage extends LightningElement {
  labels = {
    PATIENTS,
    SEARCH,
  }

  patientCard = 'patientCard';

  @track initialData;

  @track patientsList;

  connectedCallback() {
    fetchPatientDetailsForSiteCalendar({ option: this.patientCard })
      .then((data) => {
        if (data) {
          this.initialData = JSON.parse(data);
          this.patientsList = JSON.parse(data);
        }
      })
      .catch(err => this.error = err);
  }

  handleKeyUp(event) {
    if (event.detail.value && event.detail.value !== '') {
      this.searchData(this.patientsList, event.detail.value);
    } else {
      this.patientsList = this.initialData;
    }
  }

  formSearchList(tempList, newSearchText) {
    const newTempList = [];
    let regexp;
    for (const eachRec in tempList) {
      if (Object.prototype.hasOwnProperty.call(tempList, eachRec)) {
        regexp = new RegExp(newSearchText, 'i');
        if (regexp.test(tempList[eachRec].memberFirstName)
            || regexp.test(tempList[eachRec].memberLastName)
            || (tempList[eachRec].memberMRN !== null && regexp.test(tempList[eachRec].memberMRN))) {
          newTempList.push(tempList[eachRec]);
        }
      }
    }
    return newTempList;
  }

  searchData(data, newSearchTerm) {
    const newSearchList = data;
    const filteredData = this.formSearchList(newSearchList, newSearchTerm);
    this.patientsList = filteredData;
  }
}
