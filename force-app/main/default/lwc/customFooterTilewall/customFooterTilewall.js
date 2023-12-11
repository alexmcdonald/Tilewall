/*
 * customFooter (Tile Wall version) LWC is used to replace the standard footer within
 * a flow. Rather than navigating back, both buttons navigate next but pass the action
 * being performed as an output to the flow. A decision element can then be used to validate
 * and route the flow accordingly. This gets around problems when navigating back sometimes
 * where values aren't cleared out from variables properly.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from 'lightning/flowSupport';

export default class CustomFooterTilewall extends LightningElement {

    _action;
    @api get action() {
        return this._action;
    }
    set action(value) {
        this._action = value;
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

    handleAction(event) {
        console.log('** Custom Footer Action Clicked');
        const action = event.currentTarget.dataset.action;
        console.log('Action: '+action);
        this.dispatchEvent(new FlowAttributeChangeEvent('action', action));
    }

}