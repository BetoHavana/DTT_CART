import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

import { LightningElement, track, api, wire } from 'lwc';

import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource';
import USERID from '@salesforce/user/Id';

import { globalHeader } from 'c/appConstants';
import { AVAILABILITY_CALENDAR_PAGE_REFERENCE,
  LOGOUT_PAGE_REFERENCE,
  MY_CALENDAR_PAGE_REFERENCE,
  PATIENTS_PAGE_REFERENCE,
  RESOURCES_PAGE_REFERENCE,
  SERVICES_PAGE_REFERENCE,
  USER_PROFILE_PAGE_REFERENCE } from 'c/pageReferences';

import AVAILABILITY_CALENDAR_LABEL from '@salesforce/label/c.AvailabilityCalendar';
import CALENDAR_LABEL from '@salesforce/label/c.Calendar';
import GREETINGS_LABEL from '@salesforce/label/c.Greetings';
import LOGIN_TOP_HEADER from '@salesforce/label/c.LoginTopHeader';
import LOGOUT_LABEL from '@salesforce/label/c.Logout';
import MY_ACCOUNT_LABEL from '@salesforce/label/c.MyAccount';
import PATIENTS_LABEL from '@salesforce/label/c.Patients';
import PLANNING_CALENDAR_LABEL from '@salesforce/label/c.PlanningCalendar';
import RESOURCES_LABEL from '@salesforce/label/c.Resources';
import SERVICES_LABEL from '@salesforce/label/c.Services';
import USER_FIRSTNAME_FIELD from '@salesforce/schema/User.FirstName';

export default class CommunityHeader extends NavigationMixin(LightningElement) {
  @api message;

  @api modalHeading;

  @api showModal = false;

  BlueLogo = `${CellSightAssets}/images/Janssen_Legend.png`;

  labels = {
    AVAILABILITY_CALENDAR_LABEL,
    CALENDAR_LABEL,
    GREETINGS_LABEL,
    LOGIN_TOP_HEADER,
    LOGOUT_LABEL,
    MY_ACCOUNT_LABEL,
    PATIENTS_LABEL,
    PLANNING_CALENDAR_LABEL,
    RESOURCES_LABEL,
    SERVICES_LABEL,
  };

  baseIconPath = `${CellSightAssets}/images/`;

  calendarAvailableIcon = `${this.baseIconPath}availabilitycalendar.svg#availabilitycalendardefault`;

  calendarAvailableActiveIcon = `${this.baseIconPath}availabilitycalendaractive.svg#availabilitycalendaractive`;

  myCalendarIcon = `${this.baseIconPath}mycalendar.svg#mycalendardefault`;

  myCalendarActiveIcon = `${this.baseIconPath}mycalendar-active.svg#mycalendaractive`;

  navItemActive = 'slds-global-actions__item slds-p-right_medium nav-active';

  navItemDefault = 'slds-global-actions__item slds-p-right_medium';

  patientIcon = `${this.baseIconPath}patients.svg#patientdefault`;

  patientActiveIcon = `${this.baseIconPath}patients-active.svg#patientactive`;

  resourceIcon = `${this.baseIconPath}resources.svg#resourcesdefault`;

  resourceActiveIcon = `${this.baseIconPath}resources-active.svg#resourcesactive`;

  serviceActiveIcon = `${this.baseIconPath}services-active.svg#serviceactive`;

  serviceIcon = `${this.baseIconPath}services.svg#servicesdefault`;

  @track
  items = [
    {
      label: MY_ACCOUNT_LABEL,
      value: MY_ACCOUNT_LABEL,
    },
    {
      label: LOGOUT_LABEL,
      value: LOGOUT_LABEL,
    },
  ];

  @wire(CurrentPageReference)
  currentPageReference;

  @wire(getRecord, { recordId: USERID, fields: [USER_FIRSTNAME_FIELD] })
  user;

  get availableCalendarClass() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.availabilityCalendarPage
          ? this.navItemActive
          : this.navItemDefault;
      }
      return this.navItemDefault;
    }
    return this.navItemDefault;
  }

  get availableCalendarIcon() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.availabilityCalendarPage
          ? this.calendarAvailableActiveIcon
          : this.calendarAvailableIcon;
      }
      return this.calendarAvailableIcon;
    }
    return this.calendarAvailableIcon;
  }

  get calendarClass() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.myCalendarPage
          ? this.navItemActive
          : this.navItemDefault;
      }
      return this.navItemDefault;
    }
    return this.navItemDefault;
  }

  get calendarIcon() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.myCalendarPage
          ? this.myCalendarActiveIcon
          : this.myCalendarIcon;
      }
      return this.myCalendarIcon;
    }
    return this.myCalendarIcon;
  }

  get greeting() {
    return `${GREETINGS_LABEL}, ${getFieldValue(this.user.data, USER_FIRSTNAME_FIELD)}`;
  }

  get patientClass() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.patientsPage
          ? this.navItemActive
          : this.navItemDefault;
      }
      return this.navItemDefault;
    }
    return this.navItemDefault;
  }

  get patientIcons() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.patientsPage
          ? this.patientActiveIcon
          : this.patientIcon;
      }
      return this.patientIcon;
    }
    return this.patientIcon;
  }

  get resourcesClass() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.resourcesPage
          ? this.navItemActive
          : this.navItemDefault;
      }
      return this.navItemDefault;
    }
    return this.navItemDefault;
  }

  get resourcesIcon() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.resourcesPage
          ? this.resourceActiveIcon
          : this.resourceIcon;
      }
      return this.resourceIcon;
    }
    return this.resourceIcon;
  }

  get servicesClass() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.servicesPage
          ? this.navItemActive
          : this.navItemDefault;
      }
      return this.navItemDefault;
    }
    return this.navItemDefault;
  }

  get servicesIcon() {
    if (this.currentPageReference) {
      if (this.currentPageReference.hasOwnProperty('attributes')) {
        return this.currentPageReference.attributes.name === globalHeader.servicesPage
          ? this.serviceActiveIcon
          : this.serviceIcon;
      }
      return this.serviceIcon;
    }
    return this.serviceIcon;
  }

   handleMenuSelect(event) {
    const selectedItemValue = event.detail.value;
    if (selectedItemValue === LOGOUT_LABEL) {
      this[NavigationMixin.Navigate](LOGOUT_PAGE_REFERENCE);
    }
    if (selectedItemValue === MY_ACCOUNT_LABEL) {
      this[NavigationMixin.Navigate](USER_PROFILE_PAGE_REFERENCE);
    }
  }

  navigateToCalendar() {
    this[NavigationMixin.Navigate](MY_CALENDAR_PAGE_REFERENCE);
  }

  navigateToCalendarAvailabilityPage() {
    this[NavigationMixin.Navigate](AVAILABILITY_CALENDAR_PAGE_REFERENCE);
  }

  navigateToLandingPage() {
    this[NavigationMixin.Navigate](PATIENTS_PAGE_REFERENCE);
  }

  navigateToResourcesPage() {
    this[NavigationMixin.Navigate](RESOURCES_PAGE_REFERENCE);
  }

  navigateToServicesPage() {
    this[NavigationMixin.Navigate](SERVICES_PAGE_REFERENCE);
  }
}
