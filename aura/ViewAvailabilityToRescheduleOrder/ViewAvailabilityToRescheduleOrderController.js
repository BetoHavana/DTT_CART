({
  handleCancelClick: function (component, event, helper) {
    helper.closeQuickAction();
  },
  handleCloseNRefresh: function (component, event, helper) {
    helper.closeQuickAction();
    $A.get("e.force:refreshView").fire();
  }
});


