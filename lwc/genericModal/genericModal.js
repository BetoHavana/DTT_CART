import { LightningElement, api } from 'lwc';
import { modalSize } from 'c/appConstants';

export default class GenericModal extends LightningElement {
  @api
  open = false;

  @api
  size = 'medium';

  get modalStyle() {
    let modalClass = 'slds-model popup-style';
    if (this.open) {
      if (this.size && this.size === modalSize.MEDIUM_SIZE) {
        modalClass = 'slds-modal slds-fade-in-open slds-modal_medium popup-style';
      } else if (this.size && this.size === modalSize.LARGE_SIZE) {
        modalClass = 'slds-modal slds-fade-in-open slds-modal_large popup-style';
      } else if (this.size && this.size === modalSize.SMALL_SIZE) {
        modalClass = 'slds-modal slds-fade-in-open slds-modal_small popup-style';
      } else {
        modalClass = 'slds-modal slds-fade-in-open popup-style';
      }
    }
    return modalClass;
  }
}
