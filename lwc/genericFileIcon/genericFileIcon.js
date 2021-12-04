import { LightningElement, api } from 'lwc';

const DOC = 'doc';
const DOCX = 'docx';
const PDF = 'pdf';
const CSV = 'csv';
const XLS =  'XLS';



export default class GenericFileIcon extends LightningElement {
  @api icon;

  @api size = 'small';

  get getIconName() {
    switch (this.icon) {
      case DOCX:
        return 'doctype:word';
      case DOC:
        return 'doctype:word';
      case PDF:
        return 'doctype:pdf';
      case CSV:
        return 'doctype:csv';
      case XLS:
        return 'doctype:excel';
      default:
        return 'doctype:pdf';
    }
  }
}
