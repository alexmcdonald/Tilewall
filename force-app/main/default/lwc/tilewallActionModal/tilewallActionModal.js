/*
 * tilewallActionModal LWC is a modal used by Tilewall to execute Flow actions from a tile
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { api } from 'lwc';
import LightningModal from 'lightning/modal';

export default class TilewallActionModal extends LightningModal {

    @api flowName;
    @api recordId;
    @api label;
    @api actionVars;

    get modalLabel() {
        return `Action: ${this.label}`;
    }

    get inputVariables() {
        return this.actionVars;
    }

    handleStatusChange(event) {
        if (event.detail.status == 'FINISHED') this.close('FINISHED');
        console.log(JSON.stringify(event.detail));
    }

}