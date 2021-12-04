import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, updateRecord } from 'lightning/uiRecordApi';
import CANCEL_LABEL from '@salesforce/label/c.CancelButton';
import EMAIL_LABEL from '@salesforce/label/c.EmailAddress';
import EXTENSION_LABEL from '@salesforce/label/c.Extension';
import FOOTER_LABEL from '@salesforce/label/c.FooterLabel';
import MY_ACCOUNT_LABEL from '@salesforce/label/c.MyAccount';
import NAME_LABEL from '@salesforce/label/c.Name';
import PHONE_LABEL from '@salesforce/label/c.PhoneNumber';
import SAVE_LABEL from '@salesforce/label/c.SaveButton';
import USERNAME_LABEL from '@salesforce/label/c.Username';
import EXTENSION_FIELD from '@salesforce/schema/Contact.Extension__c';
import PHONE_FIELD from '@salesforce/schema/Contact.Phone';
import CONTACT_ID from '@salesforce/schema/Contact.Id';
import USER_ID from '@salesforce/user/Id';

const USERFIELDS = [
  'User.ContactId',
  'User.Email',
  'User.Name',
  'User.Username',
];

const CONTACTFIELDS = [
  'Contact.Extension__c',
  'Contact.Phone',
];

export default class MyAccount extends LightningElement {
  @api contactId;

  @api recordId;

  @track Email;

  @track Extension;

  @track initialPhone = '';

  @track initialExtension = '';

  @track isVisible = false;

  @track Name;

  @track Phone;

  @track readOnly = true;

  @track showEdit = true;

  @track Username;

  PHONE_NUMBER_LABEL = 'Phone Number';

  EXTENSION_NAME_LABEL = 'Extension';

  PHONE_NAME_LABEL = 'Phone';

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
      this.contactId = data.fields.ContactId.value;
      this.Email = data.fields.Email.value;
      this.Name = data.fields.Name.value;
      this.Username = data.fields.Username.value;
    } else {
      this.Email = '';
      this.Name = '';
      this.Username = '';
    }
  }

  @wire(getRecord, {
    recordId: '$contactId',
    fields: CONTACTFIELDS,
  }) wiredRecord({
                   error,
                   data,
                 }) {
    if (error) {
      this.error = error;
    } else if (data) {
      this.Extension = data.fields.Extension__c.value;
      this.initialPhone = data.fields.Phone.value;
      this.initialExtension = data.fields.Extension__c.value;
      this.Phone = data.fields.Phone.value;
    } else {
      this.Extension = '';
      this.initialPhone = '';
      this.initialExtension = '';
      this.Phone = '';
    }
  }

  labels = {
    CANCEL_LABEL,
    EMAIL_LABEL,
    EXTENSION_LABEL,
    FOOTER_LABEL,
    MY_ACCOUNT_LABEL,
    NAME_LABEL,
    PHONE_LABEL,
    SAVE_LABEL,
    USERNAME_LABEL,
  };

  handleValueChange(event) {
    this.inputLabel = event.target.label;
    this.inputValue = event.target.value;
    if (this.inputLabel === this.PHONE_NUMBER_LABEL && this.inputValue !== undefined) {
      this.Phone = event.target.value;
    }
    if (this.inputLabel === this.EXTENSION_NAME_LABEL && this.inputValue !== undefined) {
      this.Extension = event.target.value;
    }
  }

  handleEdit() {
    this.readOnly = false;
    this.isVisible = true;
    this.showEdit = false;
  }

  handleCancel() {
    this.readOnly = true;
    this.isVisible = false;
    this.showEdit = true;
    const phoneElement = this.template.querySelector('lightning-input.phone');
    const extensionElement = this.template.querySelector('lightning-input.extension');
    if (phoneElement) {
      phoneElement.value = this.initialPhone;
      phoneElement.setCustomValidity('');
      phoneElement.reportValidity();
    }
    if (extensionElement) {
      extensionElement.value = this.initialExtension;
      extensionElement.setCustomValidity('');
      extensionElement.reportValidity();
    }
    this.Phone = this.initialPhone;
    this.Extension = this.initialExtension;
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

  mobileHandler(event) {
    event.preventDefault();
    var mobileField = event.target;
    var mobileEntered = event.target.value;
    if (!this.specChar) {
      if (mobileEntered.length === 3) {
        if(!this.backKeyPressed) {
          this.Phone = mobileEntered + '-';
          mobileField.value = this.Phone;
        }
      } else if (mobileEntered.length === 7) {
        if(!this.backKeyPressed) {
          this.Phone = mobileEntered + '-';
          mobileField.value = this.Phone;
        }
      } else {
        this.Phone = mobileEntered;
        mobileField.value = this.Phone;
      }
    } else {
      event.target.value = mobileEntered.substr(0, mobileEntered.length - 1);
    }
  }

  updateContact() {
    const allValid = [...this.template.querySelectorAll('lightning-input')]
        .reduce((validSoFar, inputCmp) => {
          inputCmp.reportValidity();
          return validSoFar && inputCmp.checkValidity();
        }, true);
    if (allValid) {
      const fields = {};
      fields[CONTACT_ID.fieldApiName] = this.contactId;
      fields[PHONE_FIELD.fieldApiName] = this.Phone;
      fields[EXTENSION_FIELD.fieldApiName] = this.Extension;

      const recordInput = { fields };

      updateRecord(recordInput)
          .then(() => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Success',
                  message: 'Profile has been updated successfully.',
                  variant: 'success',
                }),
            );
            this.readOnly = true;
            this.isVisible = false;
            this.showEdit = true;
          })
          .catch(error => {
            this.dispatchEvent(
                new ShowToastEvent({
                  title: 'Updating error',
                  message: error.body.message,
                  variant: 'error',
                }),
            );
          });
    }
  }
}
