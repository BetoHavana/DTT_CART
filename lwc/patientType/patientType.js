import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import PATIENT_GROUP_LABEL from '@salesforce/label/c.PatientGroupText';
import CLINICAL_DESCRIPTION_LABEL from '@salesforce/label/c.ClinicalProductsText';
import COMMERCIAL_LABEL from '@salesforce/label/c.CommercialText';
import CLINICAL_LABEL from '@salesforce/label/c.ClinicalText';
import { PATIENTS_PAGE_REFERENCE } from 'c/pageReferences';

export default class PatientType extends  NavigationMixin(LightningElement) {
    labels = {
      PATIENT_GROUP_LABEL,
      CLINICAL_DESCRIPTION_LABEL,
      COMMERCIAL_LABEL,
      CLINICAL_LABEL
  };

  handleSelection(){
    this[NavigationMixin.Navigate](PATIENTS_PAGE_REFERENCE);
  }
}
