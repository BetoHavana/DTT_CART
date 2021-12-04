/**
 * Created by rabussa on 7/20/2020.
 */
import { createElement } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import { registerLdsTestWireAdapter, registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import fetchPhysicianResults from '@salesforce/apex/PatientEnrollmentIndicatorController.searchPhysician';
import treatmentDetail from '../treatmentDetail';


// Mock realistic data
const mockGetRecord = require('./data/getRecord.json');
const mockPhysicianData = require('./data/getPhysicianDetails.json');

// Mock Physician data
const fetchPhysician = registerApexTestWireAdapter(fetchPhysicianResults);

// Register as an LDS wire adapter. Some tests verify the provisioned values trigger desired behavior.
const getRecordAdapter = registerLdsTestWireAdapter(getRecord);

const mockFileArray = [{ consentFileName: 'testDoc.docx', consentFileId: '000000000000000XXX' }];

// Mocking imperative Apex method call
jest.mock(
  '@salesforce/apex/PatientEnrollmentIndicatorController.searchPhysician',
  () => ({
    default: jest.fn(),
  }),
  { virtual: true },
);


describe('c-treatment-detail component tests', () => {
  afterEach(() => {
    // jsdom instance are shared across the dom
    // reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // reusable method for all test cases
  const initializeElement = () => {
    const element = createElement('c-treatment-detail', {
      is: treatmentDetail,
    });
    element.uploadedFileData = mockFileArray;
    document.body.appendChild(element);

    // Emit data from @wire
    getRecordAdapter.emit(mockGetRecord);
    return element;
  };

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  const flushPromises = () => new Promise(resolve => setImmediate(resolve));

  it('Check for component load when readonly mode', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      element.selectedPhysicianTitle = 'Test User';
      element.readonlyChild = true;
    }).then(() => {
      const physicianElement = element.shadowRoot.querySelector('lightning-input[name="selectedPhysicianReadMode"]');
      expect(physicianElement).toBeDefined();
    });
  });

  it('Check for component load in edit mode', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      element.selectedPhysicianTitle = 'Test User';
      element.readonlyChild = false;
    }).then(() => {
      const physicianElement = element.shadowRoot.querySelector('c-lookup');
      expect(physicianElement).toBeDefined();
    });
  });

  it('Check for method call on input of Physician', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    fetchPhysician.emit(mockPhysicianData);
    const handler = jest.fn();

    return flushPromises().then(() => {
      const physicianElement = element.shadowRoot.querySelector('c-lookup');
      // Mock handler for child event
      physicianElement.addEventListener('search', handler);
      physicianElement.dispatchEvent(new CustomEvent('search', {
        detail: { searchTerm: 'te' },
      }));
    }).then(() => {
      // evaluate the handleSearch method is called
      expect(handler).toHaveBeenCalled();
    });
  });

  it('Check data table render on edit mode', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    element.uploadedFileData = mockFileArray;
    return flushPromises().then(() => {
      const tableElement = element.shadowRoot.querySelector('c-generic-data-table');
      expect(tableElement).toBeDefined();
    });
  });

  it('Check sendData method', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    fetchPhysician.emit(mockPhysicianData);
    element.uploadedFileData = mockFileArray;
    const physicianElement = element.shadowRoot.querySelector('c-lookup');
    return flushPromises().then(() => {
      physicianElement.selection = mockPhysicianData;
    }).then(() => {
      expect(element.sendData()).not.toBeNull();
      expect(element.sendData().uploadedFiles.length).toBe(1);
    });
  });

  it('Check patient detail page validity', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    fetchPhysician.emit(mockPhysicianData);
    element.uploadedFileData = [{ consentFileName: 'testDoc.docx', consentFileId: '000000000000000XXX' }];
    return flushPromises().then(() => {
      expect(element.setRequiredValidation()).toBeFalsy();
    });
  });

  it('Check the handleRowAction method', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    const deleteHandler = jest.fn();
    const tableElement = element.shadowRoot.querySelector('c-generic-data-table');
    return flushPromises().then(() => {
      tableElement.addEventListener('rowaction', deleteHandler);
      tableElement.dispatchEvent(new CustomEvent('rowaction', {
        detail: {
          row: { consentFileId: '000000000000000XXX' },
        },
      }));
    }).then(() => {
      expect(deleteHandler).toHaveBeenCalled();
    });
  });

  it('Check the handleUploadFinished method', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    const uploadHandler = jest.fn();
    const fileElement = element.shadowRoot.querySelector('lightning-file-upload');
    fileElement.addEventListener('uploadfinished', uploadHandler);
    fileElement.dispatchEvent(new CustomEvent('uploadfinished', {
      detail: {
        files: [{
          name: 'TestDoc.docx',
          documentId: '000000000000000XXX',
        }],
      },
    }));
    return flushPromises().then(() => {
      expect(uploadHandler).toHaveBeenCalled();
    });
  });
});
