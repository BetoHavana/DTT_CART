import { LightningElement } from 'lwc';

import TCP_FOOTER_AND_LABEL from '@salesforce/label/c.TCPFooterText';
import TCP_FOOTER_CONTACTUS_LABEL from '@salesforce/label/c.TCPFooterContactUs';
import TCP_FOOTER_CONTACTUS_LINK from '@salesforce/label/c.TCPFooterContactUsLink';
import TCP_FOOTER_CUSTOMER_LABEL from '@salesforce/label/c.TCPFooterCustomerSupportDisclaimer';
import TCP_FOOTER_DISCLAIMER_LABEL from '@salesforce/label/c.TCPFooterDisclaimer';
import TCP_FOOTER_DISCLAIMERTEXT_LABEL from '@salesforce/label/c.TCPFooterDisclaimerText';
import TCP_FOOTER_LEGALNOTICE_LABEL from '@salesforce/label/c.TCPFooterLegalNotice';
import TCP_FOOTER_LEGALNOTICE_LINK from '@salesforce/label/c.TCPFooterLegalNoticeLink';
import TCP_FOOTER_PATIENTSERVICE_LABEL from '@salesforce/label/c.TCPFooterPatientServicesDisclaimer';
import TCP_FOOTER_PRIVACYPOLICY_LABEL from '@salesforce/label/c.TCPFooterPrivacyPolicy';
import TCP_FOOTER_PRIVACYPOLICY_LINK from '@salesforce/label/c.TCPFooterPrivacyPolicyLink';
import TCP_FOOTER_TRADEMARK_DISCLAIMER_LABEL from '@salesforce/label/c.TCPFooterTrademarkDisclaimer';
import TCP_FOOTER_TRADEMARK_LABEL from '@salesforce/label/c.TCPFooterTrademark';

export default class TcpGlobalFooter extends LightningElement {
  labels = {
    TCP_FOOTER_AND_LABEL,
    TCP_FOOTER_CONTACTUS_LABEL,
    TCP_FOOTER_CONTACTUS_LINK,
    TCP_FOOTER_CUSTOMER_LABEL,
    TCP_FOOTER_DISCLAIMER_LABEL,
    TCP_FOOTER_DISCLAIMERTEXT_LABEL,
    TCP_FOOTER_LEGALNOTICE_LABEL,
    TCP_FOOTER_LEGALNOTICE_LINK,
    TCP_FOOTER_PATIENTSERVICE_LABEL,
    TCP_FOOTER_PRIVACYPOLICY_LABEL,
    TCP_FOOTER_PRIVACYPOLICY_LINK,
    TCP_FOOTER_TRADEMARK_DISCLAIMER_LABEL,
    TCP_FOOTER_TRADEMARK_LABEL
  };
}