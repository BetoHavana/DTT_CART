({
  sendSlotBookingConfirmation: function (component) {
    const saveAction = component.get("c.confirmSlotBooking");
    const listOfOrders = [];
    listOfOrders.push(component.get("v.order"));
    saveAction.setParams({
      listOfOrders: listOfOrders
    });
    saveAction.setCallback(this, function (response) {
      const state = response.getState();
      if (state === "SUCCESS") {
        const resultsToast = $A.get("e.force:showToast");
        resultsToast.setParams({
          "type": "success",
          "message": $A.get("$Label.c.OrderSubmitted")
        });
        $A.get("e.force:closeQuickAction")
            .fire();
        resultsToast.fire();
        $A.get("e.force:refreshView")
            .fire();
      } else {
        const errors = response.getError();
        let errMessage = '';
        const errorMsgResp = errors[0].message.toLowerCase();
        const labelUnavailableSlotsValidationMsg = $A.get("$Label.c.UnavailableSlotsValidationMsg").toLowerCase();
        const labelSlotsNotConfirmedValidationMsg = $A.get("$Label.c.SlotsNotConfirmedValidationMsg").toLowerCase();
        const labelSlotUnavailableMsg = $A.get("$Label.c.SlotUnavailableMsg").toLowerCase();
        if (errorMsgResp === labelUnavailableSlotsValidationMsg || errorMsgResp === labelSlotsNotConfirmedValidationMsg
            || errorMsgResp === labelSlotUnavailableMsg) {
          errMessage = errorMsgResp;
        } else {
          errMessage = $A.get("$Label.c.OrderSubmissionGenericError");
        }
        const errorToast = $A.get("e.force:showToast");
        errorToast.setParams({
          "type": "error",
          "title": $A.get("$Label.c.OrderSumissionErrorTitle"),
          "message": errMessage
        });
        $A.get("e.force:closeQuickAction")
            .fire();
        errorToast.fire();
      }
    });
    $A.enqueueAction(saveAction);
  },

  getOrderStatus: function (component) {
    return component.get("v.order.OrderStatus__c");
  },

  sendOrderForSubmission: function (component) {
    const attestedForCompletion = component.get("v.order.AttestedForCompletion__c");
    if (attestedForCompletion === $A.get("$Label.c.OrderSubmitConfirmationButton") && (this.getOrderStatus(component) === $A.get("$Label.c.NewButtonText"))) {
      this.sendSlotBookingConfirmation(component);
    }
  },

  validateAttestedForSubmission: function (component) {
    const attestedForCompletion = component.get("v.order.AttestedForCompletion__c");
    if (attestedForCompletion === $A.get("$Label.c.NoText") && (this.getOrderStatus(component) === $A.get("$Label.c.NewButtonText"))) {
      const errorToast = $A.get("e.force:showToast");
      errorToast.setParams({
        "type": "error",
        "message": $A.get("$Label.c.AttestToCompletionOrderError")
      });
      $A.get("e.force:closeQuickAction")
          .fire();
      errorToast.fire();
      $A.get("e.force:refreshView")
          .fire();
    }
  },

  validateOrderResubmission: function (component) {
    if ((this.getOrderStatus(component) === $A.get("$Label.c.OrderStatusSubmitted")) || (this.getOrderStatus(component) === $A.get("$Label.c.OrderStatusVerified"))) {
      const toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        "type": "error",
        "message": $A.get("$Label.c.OrderAlreadyPlacedErrorMessage")
      });
      toastEvent.fire();
      const closeModalaction = component.get("c.handleCancel");
      $A.enqueueAction(closeModalaction);
    }
  }

});