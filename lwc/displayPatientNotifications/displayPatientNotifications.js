import { LightningElement,api,wire,track } from 'lwc'
import getPatientNotificationList from '@salesforce/apex/DisplayNotificationsController.getPatientNotificationList'
import updateNotificationStatus from '@salesforce/apex/DisplayNotificationsController.updateNotificationStatus'
import { refreshApex } from '@salesforce/apex'
import { CurrentPageReference } from 'lightning/navigation';
import MARKASREAD from '@salesforce/label/c.MarkAsRead'
import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource'
import getTotalNotificationsSize from '@salesforce/apex/DisplayNotificationsController.getTotalNotificationsSize'
import ALERTS_LABEL from '@salesforce/label/c.Alerts';

export default class DisplayPatientNotifications extends LightningElement {
    labels = {
        MARKASREAD,
        ALERTS_LABEL
    }
    isLoading;

    notificationIcon = `${CellSightAssets}/images/alert-headerbar-black.svg#notificationOffPatient`;

    articlesToView = 5;

    @api recordId;

    @track unReadPatientNotifications =0;

    @track PatientUnreadNotificationList = []

    @track originalPatientUnreadNotificationList = []

    @track totalNotificationsSize =0;

    @wire(CurrentPageReference) pageRef;

    @wire(getPatientNotificationList, {
        patientId: '$recordId'
    })
    wiredUnReadPatientNotifications(value) {
        this.wiredUnReadPatientNotificationsInfo=value
        const { data, error } = value
        if (data) {
            this.originalPatientUnreadNotificationList = data;
            this.unReadPatientNotifications = data.length;
            this.processNotifications();
        } else {
            this.error = error
        }
    }

    processNotifications() {
        if(this.originalPatientUnreadNotificationList.length > this.articlesToView){
            this.PatientUnreadNotificationList =[];
            for(let i=0; i < this.articlesToView; i++)
            {
                this.PatientUnreadNotificationList.push(this.originalPatientUnreadNotificationList[i]);
            }
        }
        else{
            this.PatientUnreadNotificationList = this.originalPatientUnreadNotificationList;
        }
    }

    handleClick(event) {
        this.isLoading = true
        updateNotificationStatus({
            notificationId: event.target.value
        })
            .then(result => {
                this.success = result;
                this.isLoading = false;
                this.refreshNotificationList();
            })
            .catch(error => {
                this.error = error
            })
    }

    @wire(getTotalNotificationsSize)
    wiredTotalNotificationsSize (value) {
        this.wiredTotlaNotificationsSizeInfo = value
        const { data, error } = value
        if (data) {
            this.totalNotificationsSize = data
        } else {
            this.error = error;
        }
    }

    refreshNotificationList () {
        refreshApex(this.wiredUnReadPatientNotificationsInfo)
        refreshApex(this.wiredTotlaNotificationsSizeInfo)
    }
}
