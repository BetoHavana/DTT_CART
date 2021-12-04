import { LightningElement, track, wire, api } from 'lwc';

import fetchStepDetails from '@salesforce/apex/AvailabilityCalendarController.getSlotSchedulingStepDetails';

export default class AvailabilityCalendarMilestone extends LightningElement {
  slotSchedulingFirstStepConst = 1;

  progressSteps;

  @api selectedStep = 'Step1';

  @track showSectionOne = true;

  @track showSectionThree = false;

  @track showSectionTwo = false;

  get currentStep() {
    return this.selectedStep ? parseInt(this.selectedStep.substring(this.selectedStep.length - 1), 10) : 1;
  }

  @wire(fetchStepDetails)
  progressStepsResult({ data }) {
    const resultData = [];
    if (data) {
      const parsedData = JSON.parse(data);
      if (parsedData) {
        for (const itr in parsedData) {
          const temp = {
            title: parsedData[itr].MasterLabel,
            value: `Step${parsedData[itr].Order__c}`,
            id: parsedData[itr].Id,
          };
          resultData.push(temp);
        }
        this.progressSteps = resultData;
      }
    }
  }

  handlePrev() {
    let val = this.currentStep;
    if (val !== this.slotSchedulingFirstStepConst) {
      val -= 1;
      this.selectedStep = `Step${val}`;
      this.handleVisibilityBtns(this.selectedStep);
    }
  }

  handleNext() {
    this.progressNextStep();
  }

  handleVisibilityBtns(stepnum) {
    this.showSectionTwo = false;
    this.showSectionThree = false;
    if (stepnum === 'Step1') {
      this.showSectionOne = true;
    } else if (stepnum === 'Step2') {
      this.showSectionOne = false;
      this.showSectionTwo = true;
    } else {
      this.showSectionTwo = false;
      this.showSectionThree = true;
    }
  }

  @api
  progressNextStep() {
    let val = this.currentStep;
    if (val < this.progressSteps.length) {
      val += 1;
      this.selectedStep = `Step${val}`;
      this.handleVisibilityBtns(this.selectedStep);
    }
    return this.selectedStep;
  }
}
