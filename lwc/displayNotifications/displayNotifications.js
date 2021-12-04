import { LightningElement, track , wire } from 'lwc'
import { NavigationMixin , CurrentPageReference} from 'lightning/navigation'


import { refreshApex } from '@salesforce/apex'
import getNotificationList from '@salesforce/apex/DisplayNotificationsController.getNotificationList'
import getTotalNotificationsSize from '@salesforce/apex/DisplayNotificationsController.getTotalNotificationsSize'
import updateNotificationStatus from '@salesforce/apex/DisplayNotificationsController.updateNotificationStatus'

import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource'

import ACCOUNT from '@salesforce/label/c.Account'
import ALERTS from '@salesforce/label/c.Alerts'
import CLOSEDIALOG from '@salesforce/label/c.CloseDialog'
import MARKASREAD from '@salesforce/label/c.MarkAsRead'

export default class DisplayNotifications extends NavigationMixin(LightningElement) {

    baseIconPath = `${CellSightAssets}/images/`
    closeIcon = `${this.baseIconPath}24x24_close.svg#closedefault`
    isLoading
    error
    labels = {
        ACCOUNT,
        ALERTS,
        CLOSEDIALOG,
        MARKASREAD
    }
    notificationIconOff = `${this.baseIconPath}alert-headerbar-off.svg#notificationOffHeader`
    notificationIconOn = `${this.baseIconPath}alert-headerbar-on.svg#notificationOnHeader`
    success

    @track notificationList = []
    @track totalNotificationsSize

    get notificationIcon () {
        return this.notificationList.length ? this.notificationIconOn : this.notificationIconOff
    }

    handleNavigationURL (event) {
        if (event.target) {
            const id = event.currentTarget.getAttribute('data-id')
            if (id) {
                this.handleToggleClick()
                this[NavigationMixin.Navigate]({
                    type: 'standard__recordPage',
                    attributes: {
                        recordId: id,
                        objectApiName: 'Account',
                        actionName: 'view'
                    }
                })
            }
        }

    }

    handleClick (event) {
        this.isLoading = true
        updateNotificationStatus({
            notificationId: event.target.value
        })
                .then(result => {
                    this.success = result
                    this.isLoading = false
                    this.refreshNotificationList()
                })
                .catch(error => {
                    this.error = error
                })
    }

    handleToggleClick () {
        const contentBlockClasslist = this.template.querySelector(
                '.slds-popover'
        ).classList
        contentBlockClasslist.toggle('displayToggle')
    }

    refreshNotificationList () {
        refreshApex(this.wiredNotificationsInfo)
        refreshApex(this.wiredTotlaNotificationsSize)
    }



    @wire(getNotificationList)
    wiredNotification (value) {
        this.wiredNotificationsInfo = value
        const { data, error } = value
        if (data) {
            this.notificationList = data
        } else {
            this.error = error
        }
    }

    @wire(getTotalNotificationsSize)
    wiredTotalNotificationsSize (value) {
        this.wiredTotlaNotificationsSize = value
        const { data, error } = value
        if (data) {
            this.totalNotificationsSize = data
        } else {
            this.error = error;
        }
    }

    @wire(CurrentPageReference) pageRef;

}
