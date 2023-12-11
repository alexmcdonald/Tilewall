/*
 * colorPicker LWC (Tile Wall version) is a simple color picker component for use within a flow screen.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

export default class ColorPicker_Tilewall extends LightningElement {

    @api label;
    @api value;
    @api tooltip;

    handleChange(event) {
        console.log(event.detail.value);
        this.dispatchEvent(new FlowAttributeChangeEvent('value', event.detail.value));
    }

}