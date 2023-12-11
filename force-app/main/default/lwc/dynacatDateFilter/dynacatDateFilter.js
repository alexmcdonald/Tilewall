/*
 * dynacatDateFilter LWC renders any date range display-style filters.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERS_CLEARED_CHANNEL from '@salesforce/messageChannel/dynacatFiltersCleared__c';

export default class DynacatDateFilter extends LightningElement {

    @api xid;
    @api label;
    @track startValue;
    @track finishValue;
    @api level;
    @api type;
    @api showclear;
    arialevel;

    handleChange(event) {

        this.value = event.detail.value;

        const dateChange = this.dispatchEvent(new CustomEvent('datechange', {
            detail: {
                root: this.xid, value: this.value, name: event.currentTarget.dataset.name, type: this.type
            }
        }));
    }

    handleClear() {

        let inputs = this.template.querySelectorAll('[data-input="' + this.xid + '"]');
        inputs.forEach(input => {
            input.value = '';
        });

        const dateClearStart = this.dispatchEvent(new CustomEvent('datechange', {
            detail: {
                root: this.xid, value: null, name: 'start', type: this.type
            }
        }));
        const dateClearFinish = this.dispatchEvent(new CustomEvent('datechange', {
            detail: {
                root: this.xid, value: null, name: 'finish', type: this.type
            }
        }));

    }

    connectedCallback() {
        this.arialevel = this.level + 1;
        this.subscribeToMessageChannel();
    }

    // Subscribes this component to the filters cleared channel
    subscription;
    @wire(MessageContext) messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            FILTERS_CLEARED_CHANNEL,
            (message) => {
                if (message.clearAll) this.handleClear();
            }
        );
    }

}