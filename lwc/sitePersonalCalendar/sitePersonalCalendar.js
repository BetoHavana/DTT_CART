import { LightningElement, wire, track } from 'lwc';
import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource';
import USER_ACCOUNT_FIELD from '@salesforce/schema/User.Contact.AccountId';
import fetchPhysicianCoordinatorByAccId from
  '@salesforce/apex/PatientEnrollmentIndicatorController.fetchPhysicianCoordinator';
import fetchPatientDetailsForSiteCalendar from
  '@salesforce/apex/PatientsListViewController.fetchPatientDetailsForSiteCalendar';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

import APHERESIS_PICKUP_LABEL from '@salesforce/label/c.ScheduledApheresisPickUp';
import CALENDAR_LABEL from '@salesforce/label/c.Calendar';
import CART_COORDINATOR_LABEL from '@salesforce/label/c.CARTCoordinator';
import CURRENT_MONTH from '@salesforce/label/c.CurrentMonth';
import DELIVERY_LABEL from '@salesforce/label/c.Delivery';
import DRUG_PRODUCT_DELIVERY_LABEL from '@salesforce/label/c.DrugProductDelivery';
import EVENT_TYPE_LABEL from '@salesforce/label/c.EventType';
import SELECT_COORDINATOR_LABEL from '@salesforce/label/c.SelectCoordinator';
import SELECT_PHYSICIAN_LABEL from '@salesforce/label/c.SelectPhysician';
import SHOW_ALL_LABEL from '@salesforce/label/c.ShowAll';
import TODAY_DATE_LABEL from '@salesforce/label/c.TodayDate';
import TREATING_PHYSICIAN_LABEL from '@salesforce/label/c.TreatingPhysician';
import TREATMENT_CENTER_COORDINATOR_LABEL from '@salesforce/label/c.TreatmentCenterCoordinator';
import TWO_WEEK_VIEW from '@salesforce/label/c.TwoWeekView';


import USERID from '@salesforce/user/Id';

export default class SitePersonalCalendar extends NavigationMixin(LightningElement) {
  @track calendarType = 'month';

  @track events;

  @track optionsCoordinators = [];

  @track optionsPhysicians = [];

  @track originalEvents = [];

  @track selectedCartCoordinator = '';

  @track selectedEventType = '';

  @track selectedPhysician = '';

  ApheresisIcon = `${CellSightAssets}/images/24x24_apheresis.svg`;

  APHERESIS_PICKUP = 'Apheresis Pickup';

  DeliveryIcon = `${CellSightAssets}/images/24x24_delivery.svg`;

  DRUG_SHIPPED = 'Drug Shipped';

  CART_COORDINATOR = 'CAR-T Coordinator';

  error;

  labels = {
    APHERESIS_PICKUP_LABEL,
    CALENDAR_LABEL,
    CART_COORDINATOR_LABEL,
    CURRENT_MONTH,
    DELIVERY_LABEL,
    DRUG_PRODUCT_DELIVERY_LABEL,
    EVENT_TYPE_LABEL,
    SELECT_COORDINATOR_LABEL,
    SELECT_PHYSICIAN_LABEL,
    SHOW_ALL_LABEL,
    TODAY_DATE_LABEL,
    TREATING_PHYSICIAN_LABEL,
    TREATMENT_CENTER_COORDINATOR_LABEL,
    TWO_WEEK_VIEW,
  }

  baseIconPathURL = `${CellSightAssets}/images/`;

  filterApheresisBrand = 'event-buttons slds-m-bottom_small slds-p-around_x-small';

  filterBrandClass = 'filter-btn cust-width filter-brand slds-m-right_small';

  filterClass = 'filter-btn cust-width slds-m-right_small';

  filterEventBrand = 'event-buttons slds-m-top_small slds-p-around_x-small custom-brand';

  filterEvent = 'event-buttons slds-m-top_small slds-p-around_x-small';

  PHYSICIAN = 'Physician';

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
          .then((contacts) => {
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

  get calendarTypeOptions() {
    return [{
      label: this.labels.CURRENT_MONTH,
      value: 'month',
    }, {
      label: this.labels.TWO_WEEK_VIEW,
      value: 'week',
    }];
  }

  connectedCallback() {
    fetchPatientDetailsForSiteCalendar()
      .then((data) => {
        if (data) {
          const patientsData = JSON.parse(data);
          if (patientsData && patientsData.length) {
            patientsData.forEach((patient) => {
              if (patient.confirmedFPDeliveryDate && patient.confirmedFPDeliveryDate !== null) {
                patient.type = this.DRUG_SHIPPED;
              } else if (patient.apheresisPickupDate && patient.apheresisPickupDate !== null) {
                patient.type = this.APHERESIS_PICKUP;
              } else {
                patient.type = '';
              }
            });
            this.originalEvents = patientsData;
            this.processPatientsByType(patientsData);
          }
        }
      })
      .catch((err) => {
        this.error = err;
      });
  }

  processPatientsByType(patients) {
    const evts = [];
    if (patients && patients.length) {
      patients.forEach((patient) => {
        if (patient.type === this.DRUG_SHIPPED) {
          evts.push({
            id: patient.memberId,
            title: `${patient.memberLastName}, ${patient.memberFirstName} `,
            start: patient.confirmedFPDeliveryDate,
            end: patient.confirmedFPDeliveryDate,
            textColor: '#454545',
            type: 'aphDelivery',
            color: '#BDFFB6',
            className: 'custom-event',
            patientName: patient.memberName,
            MRN: patient.memberMRN,
            patientId: patient.patientId,
          });
        }
        if (patient.type === this.APHERESIS_PICKUP) {
          evts.push({
            id: patient.memberId,
            title: `${patient.memberLastName}, ${patient.memberFirstName}`,
            start: patient.apheresisPickupDate,
            end: patient.apheresisPickupDate,
            textColor: '#454545',
            type: 'aphSelect',
            color: '#BDFFB6',
            className: 'custom-event',
            patientName: patient.memberName,
            MRN: patient.memberMRN,
            patientId: patient.patientId,
          });
        }
      });
    }
    this.events = evts;
  }

  filterContactByRole(contacts) {
    if (contacts) {
      const phyOptions = [];
      const coordinatorOptions = [];
      contacts.forEach((item) => {
        if (item.subtitle === this.PHYSICIAN) {
          phyOptions.push({
            label: item.title,
            value: item.title,
          });
        }
        if (item.subtitle === this.CART_COORDINATOR) {
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

  get statusAllButtonStyle() {
    return this.selectedEventType === this.labels.SHOW_ALL_LABEL
        ? this.filterBrandClass
        : this.filterClass;
  }

  get coordinatorAllButtonStyle() {
    return this.selectedCartCoordinator === this.labels.SHOW_ALL_LABEL
        ? this.filterBrandClass
        : this.filterClass;
  }

  get physicianAllButtonStyle() {
    return this.selectedPhysician === this.labels.SHOW_ALL_LABEL
        ? this.filterBrandClass
        : this.filterClass;
  }

  get scheduledApheresisButtonStyle() {
    return this.selectedEventType === this.APHERESIS_PICKUP
        ? this.filterEventBrand
        : this.filterEvent;
  }

  get drugProductButtonStyle() {
    return this.selectedEventType === this.DRUG_SHIPPED
        ? this.filterEventBrand
        : this.filterEvent;
  }

  handleAllCoordinatorActive() {
    this.selectedCartCoordinator = this.labels.SHOW_ALL_LABEL;
    this.searchData();
  }

  handleAllPhysicianActive() {
    this.selectedPhysician = this.labels.SHOW_ALL_LABEL;
    this.searchData();
  }

  handleApheresisSelect() {
    this.selectedEventType = this.APHERESIS_PICKUP;
    this.searchData();
  }

  handleDrugDeliverySelect() {
    this.selectedEventType = this.DRUG_SHIPPED;
    this.searchData();
  }

  handleAllEvents() {
    this.selectedEventType = this.labels.SHOW_ALL_LABEL;
    this.searchData();
  }

  handleCalendarTypeChange(event) {
    const selectedValue = event.detail.value;
    this.calendarType = selectedValue;
    const calElement = this.template.querySelector('c-calendar');
    if (selectedValue === 'month') {
      calElement.setViewAsMonth();
    } else {
      calElement.setViewAsWeek();
    }
  }

  handleCoordinatorChange(event) {
    const selectedCoordinator = event.detail.value;
    if (selectedCoordinator) {
      this.selectedCartCoordinator = selectedCoordinator;
      this.searchData();
    }
  }

  handleEventClick(event){
    if(event.detail.type && (event.detail.type === 'aphSelect' || event.detail.type === 'aphDelivery')) {
      const memberId = event.detail.id;
      if(memberId) {
        this[NavigationMixin.Navigate]({
          type: 'standard__recordPage',
          attributes: {
            recordId: memberId,
            objectApiName: 'Account',
            actionName: 'view',
          },
        });
      }
    }
  }

  handlePhysicianChange(event) {
    const selectedPhysician = event.detail.value;
    if (selectedPhysician) {
      this.selectedPhysician = selectedPhysician;
      this.searchData();
    }
  }

  handleViewChange(event) {
    if (event.detail) {
      if (event.detail.view) {
        const { view } = event.detail;
        if (view === 'dayGrid2Week') {
          this.calendarType = 'week';
        } else {
          this.calendarType = 'month';
        }
      }
    }
  }

  searchData() {
    let newSearchList = this.originalEvents;

    if (this.selectedCartCoordinator !== '' && this.selectedCartCoordinator !== this.labels.SHOW_ALL_LABEL) {
      newSearchList = newSearchList.filter(rec => rec.cartCoordinator === this.selectedCartCoordinator);
    }

    if (this.selectedPhysician !== '' && this.selectedPhysician !== this.labels.SHOW_ALL_LABEL) {
      newSearchList = newSearchList.filter(rec => rec.treatingPhysician === this.selectedPhysician);
    }

    if (this.selectedEventType !== '' && this.selectedEventType !== this.labels.SHOW_ALL_LABEL) {
      newSearchList = newSearchList.filter(rec => rec.type === this.selectedEventType);
    }
    this.processPatientsByType(newSearchList);
  }
}
