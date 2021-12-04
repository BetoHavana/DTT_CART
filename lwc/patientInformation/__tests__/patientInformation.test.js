/**
 * Created by rabussa on 7/2/2020.
 */

import { createElement } from 'lwc';
import { registerLdsTestWireAdapter, registerApexTestWireAdapter } from '@salesforce/sfdx-lwc-jest';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import getRelationshipToPatientValues
  from '@salesforce/apex/PatientEnrollmentIndicatorController.getRelationshipToPatientValues';
import patientInformation from '../patientInformation';
// eslint-disable-next-line no-unused-vars


// Mock realistic data
const mockGetContactObjectInfo = require('./../../../../test/jest-mocks/SObjects/getContactObjectInfo.json');
const mockGetPicklistValues = require('./../../../../test/jest-mocks/Picklists/getSalutationPicklistValues.json');
const mockGetStatePicklistValues = require('./../../../../test/jest-mocks/Picklists/getStatePicklistValues.json');
const mockGetRelationShipToPatient = require('./data/getRelationshipToPatientValuesResult.json');

// Register as an LDS wire adapter. Some tests verify the provisioned values trigger desired behavior.
const getObjectInfoAdapter = registerLdsTestWireAdapter(getObjectInfo);
const getPicklistValuesAdapter = registerLdsTestWireAdapter(getPicklistValues);
const getApexRelationshipToPatientValues = registerApexTestWireAdapter(getRelationshipToPatientValues);

// Mocking imperative Apex method call
jest.mock(
  '@salesforce/apex/PatientEnrollmentIndicatorController.getRelationshipToPatientValues',
  () => ({
    default: jest.fn(),
  }),
  { virtual: true },
);

// Mocking custom label value
jest.mock('@salesforce/label/c.PatientInformation', () => ({ default: 'PatientInformation' }), { virtual: true });

describe('c-patient-information component load', () => {
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
    const element = createElement('c-patient-information', {
      is: patientInformation,
    });

    document.body.appendChild(element);
    // Emit data from @wire
    getObjectInfoAdapter.emit(mockGetContactObjectInfo);
    getPicklistValuesAdapter.emit(mockGetPicklistValues);
    getPicklistValuesAdapter.emit(mockGetStatePicklistValues);
    getApexRelationshipToPatientValues.emit(JSON.stringify(mockGetRelationShipToPatient));
    return element;
  };

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  const flushPromises = () => new Promise(resolve => setImmediate(resolve));

  it('Check the component title', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      const patientTitle = element.shadowRoot.querySelector('.primary-title.slds-p-vertical_large');
      expect(patientTitle.textContent).toEqual('PatientInformation');
    });
  });

  it('Check if patient form loaded', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      const inputElement = element.shadowRoot.querySelector('lightning-input');
      expect(inputElement.name).toBe('patientFirstName');
    });
  });

  it('Check salutation picklist values', () => {
    const element = initializeElement();
    element.sendData();
    return flushPromises().then(() => {
      const comboElement = element.shadowRoot.querySelector('lightning-combobox');
      expect(comboElement.length).toBe(mockGetPicklistValues.length);
    });
  });

  it('Check state picklist values', () => {
    const element = initializeElement();
    element.sendData();
    return flushPromises().then(() => {
      const comboElement = element.shadowRoot.querySelector('lightning-combobox.state-picklist');
      if (comboElement) {
        expect(comboElement.length).toBe(mockGetStatePicklistValues.length);
      }
    });
  });

  it('Check for send data method block', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      expect(element.sendData()).toBeUndefined();
    });
  });

  it('Check validation method', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      expect(element.setRequiredValidation()).toBeFalsy();
    });
  });

  it('Test addCaregiverSection method', () => {
    const element = initializeElement();
    return flushPromises().then(() => {
      element.isClicked = false;
      const careGiverSection = element.shadowRoot.querySelector('.slds-p-bottom_large lightning-button');
      careGiverSection.click();
    }).then(() => {
      const careGiverElement = element.shadowRoot.querySelector('lightning-input.caregiverName');
      expect(careGiverElement).toBeDefined();
    });
  });

  it('Test Remove Care Giver method', () => {
    const element = initializeElement();
    element.readonlyChild = false;
    return flushPromises().then(() => {
      const careGiverSection = element.shadowRoot.querySelector('.slds-p-bottom_large lightning-button');
      careGiverSection.click();
    }).then(() => {
      const removeCareButton = element.shadowRoot.querySelector('lightning-button.primary-button.slds-float_right');
      removeCareButton.click();
    }).then(() => {
      const careGiverElement = element.shadowRoot.querySelector('lightning-input.caregiverName');
      expect(careGiverElement).toBeNull();
    });
  });
});
