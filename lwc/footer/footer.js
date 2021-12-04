import { LightningElement } from 'lwc';

import CLICK_HERE_TEXT from '@salesforce/label/c.ClickHere';
import FOOTER_EMAIL_LABEL from '@salesforce/label/c.TCPFooterEmail';
import FOOTER_LABEL from '@salesforce/label/c.FooterLabel';
import RESET_PASSWORD_TEXT from '@salesforce/label/c.ResetPasswordText';
import RESET_TEXT from '@salesforce/label/c.ResetText';

export default class Footer extends LightningElement {
  labels = {
    CLICK_HERE_TEXT,
    FOOTER_EMAIL_LABEL,
    FOOTER_LABEL,
    RESET_PASSWORD_TEXT,
    RESET_TEXT,
  };
}

