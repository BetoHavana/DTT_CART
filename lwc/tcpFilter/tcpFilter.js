import { LightningElement, track, api, wire } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';
import USERID from '@salesforce/user/Id';

import { PATIENT_DETAILS_CHEVRON } from 'c/pageReferences';
import { roles } from 'c/appConstants';

import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource';

import USER_ACCOUNT_FIELD from '@salesforce/schema/User.Contact.AccountId';

import fetchPhysicianCoordinatorByAccId from
  '@salesforce/apex/PatientEnrollmentIndicatorController.fetchPhysicianCoordinator';

import ACTIVE_LABEL from '@salesforce/label/c.Active';
import CLEAR_ALL_FILTER_LABEL from '@salesforce/label/c.ClearAllFilters';
import CLOSE_LABEL from '@salesforce/label/c.Close';
import ENROLL_NEW_PATIENT_LABEL from '@salesforce/label/c.EnrollNewPatient';
import FILTER_BY_LABEL from '@salesforce/label/c.FilterBy';
import FILTER_LABEL from '@salesforce/label/c.Filter';
import FILTER_BY_ACTIVE_STATUS_HOVER_TEXT_LABEL from '@salesforce/label/c.FindByActiveStatusOnHoverText';
import FILTER_BY_INACTIVE_STATUS_HOVER_TEXT_LABEL from '@salesforce/label/c.FindByInactiveStatusOnHoverText';
import INACTIVE_LABEL from '@salesforce/label/c.Inactive';
import PHYSICIAN_LABEL from '@salesforce/label/c.RolePhysician';
import SELECT_COORDINATOR_LABEL from '@salesforce/label/c.SelectCoordinator';
import SELECT_PHYSICIAN_LABEL from '@salesforce/label/c.SelectPhysician';
import SHOW_ALL_LABEL from '@salesforce/label/c.ShowAll';
import STATUS_LABEL from '@salesforce/label/c.Status';
import TREATMENT_CENTER_COORDINATOR_LABEL from '@salesforce/label/c.TreatmentCenterCoordinator';
import TREATING_PHYSICIAN_LABEL from '@salesforce/label/c.TreatingPhysician';

export default class TcpFilter extends NavigationMixin(LightningElement) {
  @api searchPlaceholder;

  @track clickedButtonLabel = '';

  @track error;

  @track searchTerm = '';

  @track selectedCartCoordinator = '';

  @track selectedLabels = [];

  @track selectedPhysician = '';

  @track selectedStatus = '';

  @track toggleFilter = false;

  @track user;

  labels = {
    ACTIVE_LABEL,
    CLEAR_ALL_FILTER_LABEL,
    CLOSE_LABEL,
    ENROLL_NEW_PATIENT_LABEL,
    FILTER_LABEL,
    FILTER_BY_LABEL,
    FILTER_BY_ACTIVE_STATUS_HOVER_TEXT_LABEL,
    FILTER_BY_INACTIVE_STATUS_HOVER_TEXT_LABEL ,
    INACTIVE_LABEL,
    PHYSICIAN_LABEL,
    SELECT_COORDINATOR_LABEL,
    SELECT_PHYSICIAN_LABEL,
    SHOW_ALL_LABEL,
    STATUS_LABEL,
    TREATMENT_CENTER_COORDINATOR_LABEL,
    TREATING_PHYSICIAN_LABEL,
  }

  baseIconPathURL = `${CellSightAssets}/images/`;

  closeIcon = `${this.baseIconPathURL}24x24_close.svg#closedefault`;

  filterBrandClass = 'filter-btn cust-width filter-brand slds-m-right_small';

  filterClass = 'filter-btn cust-width slds-m-right_small';

  filterIcon = `${this.baseIconPathURL}24x24_filter.svg#filterdefault`;

  @wire(getRecord, {
    recordId: USERID,
    fields: [USER_ACCOUNT_FIELD],
  })
  wiredUser({ data, error }) {
    if (data) {
      this.user = data;
      if (data) {
        const userId = getFieldValue(data, USER_ACCOUNT_FIELD);
        fetchPhysicianCoordinatorByAccId({ accountId: userId })
          .then(contacts => {
            this.filterContactByRole(contacts);
          })
          .catch(errors => this.error = errors);
      }
    } else if (error) {
      this.error = error;
    } else {
      this.error = '';
    }
  }

  get statusActiveButtonStyle() {
    return this.selectedStatus === this.labels.ACTIVE_LABEL
      ? this.filterBrandClass
      : this.filterClass;
  }

  get statusAllButtonStyle() {
    return this.selectedStatus === this.labels.SHOW_ALL_LABEL
      ? this.filterBrandClass
      : this.filterClass;
  }

  get statusInActiveButtonStyle() {
    return this.selectedStatus === this.labels.INACTIVE_LABEL
      ? this.filterBrandClass
      : this.filterClass;
  }

  get physicianAllButtonStyle() {
    return this.selectedPhysician === this.labels.SHOW_ALL_LABEL
      ? this.filterBrandClass
      : this.filterClass;
  }

  get coordinatorAllButtonStyle() {
    return this.selectedCartCoordinator === this.labels.SHOW_ALL_LABEL
      ? this.filterBrandClass
      : this.filterClass;
  }

  filterContactByRole(contacts) {
    if (contacts) {
      const phyOptions = [];
      const coordinatorOptions = [];
      contacts.forEach(item => {
        if (item.subtitle === roles.physician) {
          phyOptions.push({
            label: item.title,
            value: item.title,
          });
        }
        if (item.subtitle === roles.cartCoordinator) {
          coordinatorOptions.push({
            label: item.title,
            value: item.title,
          });
        }
      });
      this.optionsCoordinators = coordinatorOptions;
      this.optionsPhysicians = phyOptions;
    }
  }

  fireEvent() {
    const searchObj = {
      searchInp: '',
      physician: '',
      coordinator: '',
      status: ''
    };
    searchObj.searchInp = this.searchTerm;
    searchObj.physician = this.selectedPhysician === this.labels.SHOW_ALL_LABEL ? '' : this.selectedPhysician;
    searchObj.coordinator = this.selectedCartCoordinator === this.labels.SHOW_ALL_LABEL
        ? '' : this.selectedCartCoordinator;
    searchObj.status = this.selectedStatus === this.labels.SHOW_ALL_LABEL ? '' : this.selectedStatus;
    this.dispatchEvent(new CustomEvent('search', { detail: searchObj }));
  }

  handleChevron() {
    this[NavigationMixin.Navigate](PATIENT_DETAILS_CHEVRON);
  }

  handleClear() {
    this.selectedStatus = '';
    this.selectedPhysician = '';
    this.selectedCartCoordinator = '';
    this.searchTerm = '';
    this.fireEvent();
  }

  handleCoordinatorChange(event) {
    const selectedEvent = event.target.value;
    if (selectedEvent) {
      this.selectedCartCoordinator = selectedEvent;
      this.fireEvent();
    }
  }

  handleToggleFilter() {
    this.toggleFilter = !this.toggleFilter;
  }

  handleAllCoordinatorActive() {
    this.selectedCartCoordinator = this.labels.SHOW_ALL_LABEL;
    this.fireEvent();
  }

  handlePhysicianActive() {
    this.selectedPhysician = this.labels.SHOW_ALL_LABEL;
    this.fireEvent();
  }

  handlePhysicianChange(event) {
    const selectedEvent = event.detail.value;
    if (selectedEvent) {
      this.selectedPhysician = selectedEvent;
      this.fireEvent();
    }
  }

  handleSearch(event) {
    this.searchTerm = event.target.value;
    this.fireEvent();
  }

  handleStatusActive(event) {
    const selectedEvent = event.target.label;
    if (selectedEvent) {
      this.selectedStatus = selectedEvent;
      this.fireEvent();
    }
  }
}
