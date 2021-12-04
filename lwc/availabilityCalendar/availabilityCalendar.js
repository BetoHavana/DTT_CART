import { LightningElement, track, wire, api } from 'lwc';
import { getFieldValue, getRecord } from 'lightning/uiRecordApi';
import { getQueryParameters } from 'c/sharedUtils';

import USERID from '@salesforce/user/Id';

import USER_ACCOUNT_FIELD from '@salesforce/schema/User.Contact.AccountId';

import fetchApheresisSitesByAccId from
      '@salesforce/apex/AvailabilityCalendarController.fetchApheresisSites';

import fetchAvailability from
      '@salesforce/apex/ViewAvailabilitySlotsController.getAvailableSlots';

import GETPATIENT from '@salesforce/apex/PatientJourneyController.getDetailsByPatientId';

import APHERESIS_SITE_LABEL from '@salesforce/label/c.ApheresisSite';
import AVAILABILITY_CALENDAR_LABEL from '@salesforce/label/c.AvailabilityCalendar';
import AVAILABILITY_SEARCH_CRITIERIA_LABEL from '@salesforce/label/c.AvailabilitySearchCriteria';
import CRYO_TYPE_LABEL from '@salesforce/label/c.CryoType';
import SEARCH_LABEL from '@salesforce/label/c.Search';

const AVAILABLE_DATE_COLOR = '#DAFBE1';

export default class AvailabilityCalendar extends LightningElement {
  labels = {
    APHERESIS_SITE_LABEL,
    AVAILABILITY_CALENDAR_LABEL,
    AVAILABILITY_SEARCH_CRITIERIA_LABEL,
    CRYO_TYPE_LABEL,
    SEARCH_LABEL,
  };

  maxDigits = 36;

  parameters = {};

  patientId = '';

  randomIdEndInd = 9;

  randomIdStartInd = 2;

  showWeekend = true;

  timeout = 3000;

  @track availabilityData;

  @track CryoOptions = [];

  @track events=[];

  @track optionsApheresisSite = '';

  @track requestType = 'New';

  @track selectedApheresisSite = '';

  @track selectedApheresisSiteERP = '';

  @track selectedApheresisSiteId = '';

  @track selectedCryoType = '';

  @api isOrderReschedule = false;

  @api set eventsdata(value) {
    if (value) {
      this.events = value;
    }
  }

  connectedCallback() {
    this.parameters = getQueryParameters();
    if (this.parameters) {
      this.patientId = this.parameters.patientId;
    }
  }

  @wire(GETPATIENT, { patientId: '$patientId' })
  wiredPatientData({ error, data }) {
    if (error) {
      this.error = error;
    }
    if (data) {
      this.patientData = JSON.parse(data);
    }
  }

  @wire(getRecord, {
    recordId: USERID,
    fields: [USER_ACCOUNT_FIELD],
  })
  wiredUser({ data }) {
    if (data) {
      const userId = getFieldValue(data, USER_ACCOUNT_FIELD);
      fetchApheresisSitesByAccId({ accountId: userId })
        .then(contacts => {
          if (contacts) {
            this.optionsApheresisSite = contacts.map(site => ({
              label: site.HealthCloudGA__RelatedAccount__r.Name,
              value: site.HealthCloudGA__RelatedAccount__r.Name,
              type: site.HealthCloudGA__RelatedAccount__r.Type,
              apheresisSiteERP: site.HealthCloudGA__RelatedAccount__r.ERPSiteID__c,
              treatmentSiteId: site.HealthCloudGA__Account__c,
              apheresisSiteId: site.HealthCloudGA__RelatedAccount__c,
            }));
          }
          for (let i = 0; i < contacts.length; i++) {
            if (contacts[i].PrimarySite__c === 'Yes') {
              this.selectedApheresisSite = contacts[i].HealthCloudGA__RelatedAccount__r.Name;
              this.selectedApheresisSiteERP = contacts[i].HealthCloudGA__RelatedAccount__r.ERPSiteID__c;
              this.selectedApheresisSiteId = contacts[i].HealthCloudGA__RelatedAccount__c;
              this.updateCryoOption(contacts[i].HealthCloudGA__RelatedAccount__r.Name);
              setTimeout(() => {
                this.obtainAvailabilityForApheresisSite(this.selectedApheresisSite, this.selectedCryoType);
              },200);
              break;
            }
          }
        })
        .catch(errors => {
          this.error = errors;
        });
    } else {
      this.error = '';
    }
  }

  get eventsdata() {
    return this.events;
  }

  genRandom() {
    return Math.random().toString(this.maxDigits).substr(this.randomIdStartInd, this.randomIdEndInd);
  }

  handleApheresisSite(event) {
    const selectedEvent = event.detail.value;
    if (selectedEvent) {
      this.selectedApheresisSite = selectedEvent;
      this.updateCryoOption(selectedEvent);
    }
  }

  handleCryoChange(event) {
    const selectedCryo = event.detail.value;
    if (selectedCryo) {
      this.selectedCryoType = selectedCryo;
    }
  }

  updateCryoOption(value) {
    let selectedOption = this.optionsApheresisSite.filter(option => option.value === value);
    if (Array.isArray(selectedOption) && selectedOption.length) {
      selectedOption = selectedOption[0];
    }
    this.selectedApheresisSiteId = selectedOption && selectedOption.apheresisSiteId ? selectedOption.apheresisSiteId : '';
    this.selectedApheresisSiteERP = selectedOption && selectedOption.apheresisSiteERP ? selectedOption.apheresisSiteERP : '';
    if (selectedOption) {
      const central = 'Central';
      if (selectedOption.type === central) {
        this.CryoOptions = [{
          label: central,
          value: central,
        }];
        this.selectedCryoType = central;
      } else {
        const local = 'Local';
        this.CryoOptions = [{
          label: central,
          value: central,
        }, {
          label: local,
          value: local,
        }];
        this.selectedCryoType = local;
      }
      const evt = new CustomEvent('selectedaph',{
        detail: {
          aphType: this.selectedApheresisSite,
          cryoType: this.selectedCryoType
        }

      });
      this.dispatchEvent(evt);
    }
  }

  @api
  getData() {
    return {
      apheresisSite: this.selectedApheresisSite,
      cryoType: this.selectedCryoType,
      apheresisSiteERP: this.selectedApheresisSiteERP,
      apheresisSiteId: this.selectedApheresisSiteId,
    };
  }

  obtainAvailabilityForApheresisSite(treatmentSiteValue,cryoTypeValue) {
    let selectedOption = this.optionsApheresisSite.filter(option => option.value === treatmentSiteValue);
    if (Array.isArray(selectedOption) && selectedOption.length) {
      selectedOption = selectedOption[0];
    }

    let patientIdToSend;
    if(this.parameters){
      patientIdToSend = this.parameters.patientId;
    }else{
      patientIdToSend = '';
    }
    if (selectedOption) {
      fetchAvailability({
        cryoType: cryoTypeValue,
        apheresisSiteERP: selectedOption.apheresisSiteERP,
        treatmentSiteId : selectedOption.treatmentSiteId,
        patientId : patientIdToSend,
        requestType: this.isOrderReschedule === true ? 'Reschedule' : 'New',
        orderApheresisPickUpDate:this.isOrderReschedule === true ? this.patientData.apheresisPickupDate : null,
      })
          .then((result) => {
            if (result) {
              this.availabilityData = JSON.parse(result);
              this.events = JSON.parse(result);
              this.processAvailabilityData(JSON.parse(result));
            }
          })
          .catch((error) => {
            this.error = error;
          });
    }
  }

  processAvailabilityData(responseData){
    if (responseData.status === 'Success' && responseData.numberOfRecords > 0) {
      if (this.events && !this.events.length) {
        this.events = responseData.slots.map(slot => ({
          id: this.genRandom(),
          title: 'apheresisPickUpDate',
          start: slot.apheresisPickUpDate,
          end: slot.apheresisPickUpDate,
          textColor: '#454545',
          rendering: 'background',
          color: AVAILABLE_DATE_COLOR,
          type: 'apheresisSelection',
          selecteddate: slot.projectedDeliveryDate,
        }));
      }
    } else {
      this.events = [];
    }
  }

  handleSearch(){
    this.obtainAvailabilityForApheresisSite(this.selectedApheresisSite,this.selectedCryoType);
    this.dispatchEvent(new CustomEvent('clearorderdata'));
    const evt = new CustomEvent('selectedaph',{
      detail: {
        aphType: this.selectedApheresisSite,
        cryoType: this.selectedCryoType
      }

    });
    this.dispatchEvent(evt);

  }
}
