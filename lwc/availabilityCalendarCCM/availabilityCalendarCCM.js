import { LightningElement, track, api } from 'lwc';
import fetchApheresisSitesByAccId from
      '@salesforce/apex/AvailabilityCalendarController.fetchApheresisSites';

import fetchAvailability from
      '@salesforce/apex/ViewAvailabilitySlotsController.getAvailableSlots';

import APHERESIS_SITE_LABEL from '@salesforce/label/c.ApheresisSite';
import AVAILABILITY_SEARCH_CRITIERIA_LABEL from '@salesforce/label/c.AvailabilitySearchCriteria';
import CRYO_TYPE_LABEL from '@salesforce/label/c.CryoType';
import SEARCH_LABEL from '@salesforce/label/c.Search';
import SUBMIT_LABEL from '@salesforce/label/c.Submit';
import CANCEL_LABEL from '@salesforce/label/c.CancelButton';
import SLOTSUNAVAILABLETRYAFTERSOMETIME_LABEL from '@salesforce/label/c.ApheresisPickUpUnavailable';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

const [AVAILABLE_DATE_COLOR, THIRTYSIX, TWO, NINE, THREETHOUSAND] = ['#BDFFB6', 36, 2, 9, 3000];

export default class AvailabilityCalendarCCM extends LightningElement {
  labels = {
    APHERESIS_SITE_LABEL,
    AVAILABILITY_SEARCH_CRITIERIA_LABEL,
    CRYO_TYPE_LABEL,
    SEARCH_LABEL,
    SLOTSUNAVAILABLETRYAFTERSOMETIME_LABEL,
    SUBMIT_LABEL,
    CANCEL_LABEL

  };

  maxDigits = THIRTYSIX;

  parameters = {};

  randomIdEndInd = NINE;

  randomIdStartInd = TWO;

  showWeekend = true;

  timeout = THREETHOUSAND;

  @track availabilityData;

  @track CryoOptions = [];

  @track events = [];

  optionsApheresisSite = '';

  @api requestType = '';

  selectedApheresisSite = '';

  selectedApheresisSiteId = '';

  selectedCryoType = '';

  @api treatmentSiteId;

  @api patientId = '';

  @api isSubmitButtonDisabled;

  apheresisSiteERPSiteId;

  @api orderApheresisPickUpDate;

  @api set eventsdata(value) {
    if (value) {
      this.events = value;
    }
  }

  connectedCallback() {
    this.fetchAphresisSites();
  }

  fetchAphresisSites() {
    fetchApheresisSitesByAccId({ accountId: this.treatmentSiteId })
        .then(contacts => {
          if (contacts) {
            this.optionsApheresisSite = contacts.map(site => ({
              label: site.HealthCloudGA__RelatedAccount__r.Name,
              value: site.HealthCloudGA__RelatedAccount__r.Name,
              type: site.HealthCloudGA__RelatedAccount__r.Type,
              apheresisSiteERP: site.HealthCloudGA__RelatedAccount__r.ERPSiteID__c,
              treatmentSiteERP: site.HealthCloudGA__Account__r.ERPSiteID__c,
              treatmentSiteId: site.HealthCloudGA__RelatedAccount__c,
              apheresisSiteId: site.HealthCloudGA__RelatedAccount__r.Id

            }));
          }
          for (let i = 0; i < contacts.length; i++) {
            if (contacts[i].PrimarySite__c === 'Yes') {
              this.selectedApheresisSite = contacts[i].HealthCloudGA__RelatedAccount__r.Name;
              this.selectedApheresisSiteId = contacts[i].HealthCloudGA__RelatedAccount__r.Id;
              this.aphresisSiteERPSiteId = contacts[i].HealthCloudGA__RelatedAccount__r.ERPSiteID__c;
              this.updateCryoOption(contacts[i].HealthCloudGA__RelatedAccount__r.Name);
              this.obtainAvailabilityForApheresisSite(this.selectedApheresisSite, this.selectedCryoType);
              break;
            }
          }
        })
        .catch(errors => {
          this.error = errors;
          this.showToastMessage('error', SLOTSUNAVAILABLETRYAFTERSOMETIME_LABEL, 'Error');
          this.closePopup();
        })
        .finally(() => {
          this.showOrHideSpinner('hide');
        });
  }

  get eventsdata() {
    return this.events;
  }

  genRandom() {
    return Math.random()
        .toString(this.maxDigits)
        .substr(this.randomIdStartInd, this.randomIdEndInd);
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
    this.apheresisSiteERPSiteId = selectedOption && selectedOption.apheresisSiteERP ? selectedOption.apheresisSiteERP : '';
    if (selectedOption) {
      const central = 'Central';
      if (selectedOption.type === central) {
        this.CryoOptions = [{
          label: central,
          value: central
        }];
        this.selectedCryoType = central;
      } else {
        const local = 'Local';
        this.CryoOptions = [{
          label: central,
          value: central
        }, {
          label: local,
          value: local
        }];
        this.selectedCryoType = local;
      }
    }
  }

  @api
  getData() {
    return {
      apheresisSite: this.selectedApheresisSite,
      cryoType: this.selectedCryoType,
      selectedApheresisSiteId: this.selectedApheresisSiteId,
      apheresisSiteERPSiteId: this.apheresisSiteERPSiteId
    };
  }

  obtainAvailabilityForApheresisSite(treatmentSiteValue, cryoTypeValue) {
    this.showOrHideSpinner('show');
    let selectedOption = this.optionsApheresisSite.filter(option => option.value === treatmentSiteValue);
    if (Array.isArray(selectedOption) && selectedOption.length) {
      selectedOption = selectedOption[0];
    }

    if (selectedOption) {
      fetchAvailability({
        cryoType: cryoTypeValue,
        apheresisSiteERP: selectedOption.apheresisSiteERP,
        treatmentSiteId: selectedOption.treatmentSiteId,
        patientId: this.patientId,
        requestType: this.requestType,
        orderApheresisPickUpDate: this.orderApheresisPickUpDate
      })
          .then(result => {
            if (result) {
              this.availabilityData = JSON.parse(result);
              this.events = JSON.parse(result);
              this.processAvailabilityData(JSON.parse(result));
            }
          })
          .catch(error => {
            this.error = error;
            this.showOrHideSpinner('hide');
            this.showToastMessage('error', SLOTSUNAVAILABLETRYAFTERSOMETIME_LABEL, 'Error');
          });
    }
  }

  processAvailabilityData(responseData) {
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
      this.showToastMessage('error', SLOTSUNAVAILABLETRYAFTERSOMETIME_LABEL, 'Error');
    }
    this.showOrHideSpinner('hide');
  }

  handleSearch() {
    this.obtainAvailabilityForApheresisSite(this.selectedApheresisSite, this.selectedCryoType);
    this.dispatchEvent(new CustomEvent('clearorderdata'));
  }

  handleSubmitButtonClick() {
    this.dispatchEvent(new CustomEvent('submitorder'));
  }

  closePopup() {
    this.dispatchEvent(new CustomEvent('closepopup'));
  }

  showOrHideSpinner(showOrHide) {
    const eventInfo = { showSpinner: showOrHide === 'show' ? true : false };
    this.dispatchEvent(new CustomEvent('handlespinner', { detail: eventInfo }));
  }

  showToastMessage(variant, message, title) {
    const toastEvent = new ShowToastEvent({
      message,
      title,
      variant
    });
    this.dispatchEvent(toastEvent);
  }
}
