/*
 * dynacatDualListBoxFilter LWC renders a two-column select box that can be used with PICKLIST and MULTIPICKLIST
 * fields, or one level of Attributes.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api, track, wire } from 'lwc';
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTERS_CLEARED_CHANNEL from '@salesforce/messageChannel/dynacatFiltersCleared__c';

export default class DynacatDualListBoxFilter extends LightningElement {

    @api xid;
    @api label;
    @track values;
    @api children;
    @api level;
    @api type;
    @api showclear;
    arialevel;

    options = [];

    handleSelect(event) {

        this.values = event.detail.value;

        const multiSelectClick = this.dispatchEvent(new CustomEvent('multiselect', {
            detail: {
                root: this.xid, xids: this.values, type: this.type
            }
        }));
    }

    handleClear() {
        this.handleSelect( { detail : { value : null } } );
    }

    connectedCallback() {
        this.arialevel = this.level + 1;
        this.children.forEach(child => {
            this.options.push(
                {
                    label : child.label,
                    value : child.id
                }
            )
        });
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