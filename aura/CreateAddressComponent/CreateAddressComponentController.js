({
  doInit: function (component, event, helper) {
    helper.getAccountId(component);
  },
  closeSubTab: function (component) {
    const workspaceAPI = component.find('workspace');
    if (workspaceAPI) {
      workspaceAPI.getEnclosingTabId().then(function (subtabId) {
        workspaceAPI.closeTab({ tabId: subtabId });
      })
        .catch(function () {
          this.notifyUser(
            'SubTab Error',
            'An error occured while closing the subtab.',
            'error'
          );
        });
    }
  }
})
