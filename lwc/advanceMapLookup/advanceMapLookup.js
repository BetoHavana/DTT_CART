import { LightningElement, track, api, wire } from 'lwc';
import placeSearch from '@salesforce/apex/AddressSearchController.placeSearch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getPicklistDataForAddressType from '@salesforce/apex/AdvanceMapLookupController.getPicklistDataForAddressType';
import getEntireAddressInfoBasedOnPlaceId from
  '@salesforce/apex/AddressSearchController.getEntireAddressInfoBasedOnPlaceId';
import createLocationRecord from '@salesforce/apex/AddressSearchController.createLocationRecord';
import ADDRESSCREATEDSUCCESSFULLY from '@salesforce/label/c.AddressCreatedSuccessfully';
import ADDRESSLINE1 from '@salesforce/label/c.AddressLine1';
import ADDRESSLINE2 from '@salesforce/label/c.AddressLine2';
import ADDRESSLOOKUPERROR from '@salesforce/label/c.AddressLookupError';
import ADDRESSSELECTIONBEFORESUBMITTING from '@salesforce/label/c.AddressSelectionBeforeSubmitting';
import ADDRESSSELECTIONWARNING from '@salesforce/label/c.AddressSelectionWarning';
import ADDRESSTYPE from '@salesforce/label/c.AddressType';
import CANCELBUTTON from '@salesforce/label/c.CancelButton';
import CITY from '@salesforce/label/c.City';
import COUNTRY from '@salesforce/label/c.Country';
import SAVEBUTTON from '@salesforce/label/c.SaveButton';
import SEARCHLOCATION from '@salesforce/label/c.SearchLocation';
import SOMETHINGWENTWRONG from '@salesforce/label/c.SomethingWentWrongPleaseTryAgain';
import STATE from '@salesforce/label/c.State';
import ZIPCODE from '@salesforce/label/c.ZipCode';

export default class AdvancedMapLookup extends LightningElement {
  @track errors = [];

  @api notifyViaAlerts = false;

  @api recordId;

  @api showCancelButton = false;

  label = {
    ADDRESSCREATEDSUCCESSFULLY,
    ADDRESSLINE1,
    ADDRESSLINE2,
    ADDRESSLOOKUPERROR,
    ADDRESSSELECTIONBEFORESUBMITTING,
    ADDRESSSELECTIONWARNING,
    ADDRESSTYPE,
    CANCELBUTTON,
    CITY,
    COUNTRY,
    SAVEBUTTON,
    SEARCHLOCATION,
    SOMETHINGWENTWRONG,
    STATE,
    ZIPCODE,
  };

  addressLine1;

  addressLine2;

  city;

  state;

  country;

  zipcode;

  addressType;

  @track addressTypePickValues = [];

  showSpinner = false;

  @wire(getPicklistDataForAddressType)
  handleDataFromApex({ data }) {
    this.addressTypePickValues = data;
    this.addressType = 'Pickup';
  }

  handleChange(event) {
    if (event && event.target && event.target.name) {
      if (event.target.name === 'addressType') {
        this.addressType = event.target.value;
      } else if (event.target.name === 'addressLine2') {
        this.addressLine2 = event.target.value;
      } else {
      }
    }
  }

  handleSearch(event) {
    const searchKey = event.detail.searchTerm;
    placeSearch({ searchPhrase: searchKey })
      .then((results) => {
        this.template.querySelector('c-lookup')
          .setSearchResults(results);
      })
      .catch((error) => {
        this.notifyUser(
          'Lookup Error',
          ADDRESSLOOKUPERROR,
          'error',
        );

        this.errors = [error];
      });
  }

  notifyUser(title, message, variant) {
    if (this.notifyViaAlerts) {
      // eslint-disable-next-line no-alert
      alert(`${title}\n${message}`);
    } else {
      const toastEvent = new ShowToastEvent({
        title,
        message,
        variant,
      });
      this.dispatchEvent(toastEvent);
    }
  }

  handleSelectionChange(event) {
    const eventData = event.detail;
    if (eventData && Array.isArray(eventData) && eventData.length > 0 && eventData[0].place_id) {
      this.getEntireAddressInfo(eventData[0].place_id);
    } else {
      this.nullifyData();
    }
  }

  nullifyData() {
    this.addressLine1 = null;
    this.city = null;
    this.state = null;
    this.country = null;
    this.zipcode = null;
    this.errors = [];
  }

  checkForErrors() {
    const selection = this.template.querySelector('c-lookup')
      .getSelection();
    if (selection.length === 0) {
      this.errors = [
        { message: ADDRESSSELECTIONBEFORESUBMITTING },
        { message: ADDRESSSELECTIONWARNING },
      ];
    } else {
      this.errors = [];
    }
  }

  handleSubmit() {
    this.showSpinner = true;
    this.createLocation();
  }

  getEntireAddressInfo(placeIdKey) {
    if (placeIdKey) {
      getEntireAddressInfoBasedOnPlaceId({ placeId: placeIdKey })
        .then((response) => {
          if (response) {
            const addressInfo = response;
            this.addressLine1 = addressInfo.addressLine1;
            this.city = addressInfo.city;
            this.state = addressInfo.state;
            this.country = addressInfo.country;
            this.zipcode = addressInfo.zipCode;
            this.errors = [];
          }
        })
        .catch((error) => {
          this.notifyUser(
            'Lookup Error',
            ADDRESSLOOKUPERROR,
            'error',
          );
          this.errors = [error];
        });
    }
  }

  createLocation() {
    const address = {
      addressLine1: this.addressLine1,
      addressLine2: this.addressLine2,
      city: this.city,
      state: this.state,
      country: this.country,
      zipCode: this.zipcode,
      locationType: this.addressType,
    };

    createLocationRecord({
      addressInfo: JSON.stringify(address),
      accountId: this.recordId,
    })
      .then(() => {
        const toastEvent = new ShowToastEvent({
          title: 'Success!',
          message: ADDRESSCREATEDSUCCESSFULLY,
          variant: 'success',
        });
        this.dispatchEvent(toastEvent);
        this.showSpinner = false;
        this.nullifyData();
        this.addressLine2 = '';
        this.template.querySelector('c-lookup').selection = [];
        this.closeSubtabIfApplicable();
      })
      .catch((error) => {
        this.showSpinner = false;
        const toastEvent = new ShowToastEvent({
          title: 'Error!',
          message: SOMETHINGWENTWRONG,
          variant: 'error',
        });
        this.dispatchEvent(toastEvent);
      });
  }

  closeSubtabIfApplicable() {
    if (this.showCancelButton) {
      const closeSubtabEvent = new CustomEvent('cancelbuttonclick');
      this.dispatchEvent(closeSubtabEvent);
    }
  }
}
