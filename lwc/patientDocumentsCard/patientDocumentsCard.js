import { LightningElement, api, wire, track } from 'lwc';
import getDocumentsByPatientId from '@salesforce/apex/PatientJourneyController.getDocumentsByPatientId';

import DOCUMENT_DOWNLOAD_PATH from '@salesforce/label/c.communityFileDownloadPath';
import DOCUMENTS_LABEL from '@salesforce/label/c.Documents';
import DOCUMENTS_LIST_EMPTY_LABEL from '@salesforce/label/c.DocumentListEmpty';

export default class PatientDocumentsCard extends LightningElement {

  @api patientName='';

  @api recordId;

  @track documents = [];

  @track documentsMessage;

  @track isDocumentListEmpty = false;

  cartCoordinator = 'CAR-T Coordinator';

  error;

  labels ={
    DOCUMENTS_LABEL,
    DOCUMENT_DOWNLOAD_PATH
  };

  @wire(getDocumentsByPatientId, { patientId: '$recordId' })
  wiredDocuments({ data, error }) {
    if (error) {
      this.error = error;
    }
    if (data && data.length) {
      this.documents = [];
      if (Array.isArray(data)) {
        data.forEach(doc => {
          if (doc.PathOnClient.indexOf(this.cartCoordinator) > -1) {
            this.documents.push(doc);
          }
        });
      }
      this.isDocumentListEmpty = false;
      this.documentsMessage = '';
    } else {
      this.documentsMessage = DOCUMENTS_LIST_EMPTY_LABEL;
      this.isDocumentListEmpty = true;
    }
  }

  downloadFile(event) {
    const contentDocId = event.target.getAttribute('data-id');
    if (contentDocId) {
      const link = `${this.labels.DOCUMENT_DOWNLOAD_PATH}${contentDocId}`;
      window.open(link, '_blank');
    }
  }
}
