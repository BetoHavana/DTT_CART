import { LightningElement } from 'lwc';
import LOGIN_PRIMARY_TEXT from '@salesforce/label/c.LoginHeader';
import SITE_NAME_SUPPORT_TEXT from '@salesforce/label/c.SiteNameSupport';

export default class LoginHeader extends LightningElement {
  labels = {
    LOGIN_PRIMARY_TEXT,
    SITE_NAME_SUPPORT_TEXT,
  };
}
