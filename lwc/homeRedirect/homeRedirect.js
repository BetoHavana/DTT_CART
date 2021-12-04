import { LightningElement } from 'lwc';
import PATIENT_LINK from '@salesforce/label/c.PatientLink';

export default class HomeRedirect extends LightningElement {
  constructor() {
    super();
    window.location.href = PATIENT_LINK;
  }
}
