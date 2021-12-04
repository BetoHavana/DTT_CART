({
  doInit: function (component) {
    const saveAction = component.get("c.getOrderDetails");
    const listOfOrderIds = [];
    const recId = component.get("v.recordId");
    listOfOrderIds.push(recId);
    saveAction.setParams({
      listOfOrderIds: listOfOrderIds
    });
    saveAction.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const result = response.getReturnValue();
        component.set("v.order", result[0]);
      }
    });
    $A.enqueueAction(saveAction);
  },

  validateOrder: function (component, event, helper) {
    const saveAction = component.get("c.validateOrderBeforeSubmission");
    const listOfOrderIds = [];
    const recId = component.get("v.recordId");
    listOfOrderIds.push(recId);
    saveAction.setParams({
      listOfOrderIds: listOfOrderIds
    });
    saveAction.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const result = response.getReturnValue() && Array.isArray(response.getReturnValue()) ?
            response.getReturnValue()
                .join(', ') : '';
        component.set("v.fieldsInfo", result);
        const space = " ";
        const fieldsInfo = component.get("v.fieldsInfo");
        const orderStatus = component.get("v.order.OrderStatus__c");
        if ((fieldsInfo) && orderStatus === $A.get("$Label.c.NewButtonText")) {
          const toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            "type": "error",
            "title": $A.get("$Label.c.OrderSumissionErrorTitle"),
            "message": $A.get("$Label.c.OrderSubmissionValidationErrorStart") + space + fieldsInfo + space + $A.get("$Label.c.OrderSubmissionValidationErrorEnd")
          });
          toastEvent.fire();

          const closeModalaction = component.get("c.handleCancel");
          $A.enqueueAction(closeModalaction);
        } else {
          helper.validateOrderResubmission(component, event, helper);
          helper.validateAttestedForSubmission(component, event, helper);
          helper.sendOrderForSubmission(component, event, helper);
        }
      } else {
        const errorToast = $A.get("e.force:showToast");
        errorToast.setParams({
          "type": "error",
          "title": $A.get("$Label.c.OrderSumissionErrorTitle"),
          "message": $A.get("$Label.c.OrderSubmissionGenericError")
        });
        errorToast.fire();
      }
    });
    $A.enqueueAction(saveAction);
  },

  handleCancel: function () {
    $A.get("e.force:closeQuickAction")
        .fire();
  }
});