import { LightningElement } from 'lwc';
import LOGIN_TOP_HEADER from '@salesforce/label/c.LoginTopHeader';
import CellSightAssets from '@salesforce/resourceUrl/CellSight360Resource';

export default class TopHeader extends LightningElement {
  logo = `${CellSightAssets}/images/logo_white.png`;
  labels = {
    LOGIN_TOP_HEADER
  };
}
