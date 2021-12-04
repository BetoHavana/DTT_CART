({

    closeModalPopup: function (component, event, helper) {
        $A.get('e.force:closeQuickAction').fire();
    },

    handleCloseNRefresh: function (component, event, helper) {
        helper.closeQuickAction();
        $A.get('e.force:refreshView').fire();
    },

    handleCancel: function () {
        $A.get('e.force:closeQuickAction')
            .fire();
    }
});