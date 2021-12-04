({
  getAccountId: function (component) {
    const workspaceAPI = component.find('workspace');
    let parentTabId;
    let accountId;
    workspaceAPI.getEnclosingTabId().then(function (subtabId) {
      workspaceAPI.getTabInfo({
        tabId: subtabId,
      }).then(function (response) {
        if (response) {
          parentTabId = response.parentTabId;
          workspaceAPI.getTabInfo({
            tabId: parentTabId,
          }).then(function (tabInfo) {
            accountId = tabInfo.recordId;
            component.set('v.accountId', accountId);
          });
        }
      }).catch(function () {
        this.notifyUser(
          'SubTab Error',
          'An error occured while closing the subtab.',
          'error'
        );
      });
    });
  }
})