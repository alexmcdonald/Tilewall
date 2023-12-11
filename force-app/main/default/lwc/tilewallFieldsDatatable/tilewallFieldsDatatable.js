/*
 * tilewallFieldsDatatable LWC is used by the Tile Wall Configurator Flow, to display the table of configured
 * fields and badges for a configuration and enable Edit / Delete / Create actions to be initiated.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from "lightning/flowSupport";

export default class TilewallFieldsDatatable extends LightningElement {

    // Inputs
    @api get tilewallFields() {
        return this._tilewallFields;
    }
    set tilewallFields(value) {
        this._tilewallFields = value;
        console.log(this._tilewallFields);
        this.splitFields();
    }
    get showFields() {
        return this._fields.length > 0;
    }
    get fields() {
        console.log('Returning fields');
        return this._fields;
    }
    get showBadges() {
        return this._badges.length > 0;
    }
    get badges() {
        console.log('Returning badges');
        return this._badges;
    }
    get showActions() {
        return this._actions.length > 0;
    }
    get actions() {
        console.log('Returning actions');
        return this._actions;
    }
    @api label;

    // Outputs
    @api selectedRecord;
    @api selectedId;
    @api action;

    _tilewallFields;
    _fields;
    _badges;
    _actions;

    get displayTable() {
        return (this._tilewallFields) ? true : false;
    }

    splitFields() {

        let f = [];
        let b = [];
        let a = [];

        this._tilewallFields.forEach(field => {
            if (field.type__c == 'field') f.push(field);
            else if (field.type__c == 'badge') b.push(field);
            else if (field.type__c == 'action') a.push(field);
        });

        this._fields = (f.length > 0) ? f : [];
        this._badges = (b.length > 0) ? b : [];
        this._actions = (a.length > 0) ? a : [];

    }

    handleRowAction(event) {

        const actionName = event.detail.value;
        const type = event.currentTarget.dataset.type;
        const index = parseInt(event.currentTarget.dataset.row);

        console.log(`${actionName}: ${type} ${index}`);

        let row;
        if (type == 'field') row = this.fields[index];
        else if (type == 'badge') row = this.badges[index];
        else if (type == 'action') row = this.actions[index];

        console.log(JSON.stringify(row));

        this.dispatchEvent(new FlowAttributeChangeEvent('selectedRecord', row));
        this.dispatchEvent(new FlowAttributeChangeEvent('selectedId', row.Id));
        this.dispatchEvent(new FlowAttributeChangeEvent('action', actionName));
        this.dispatchEvent(new FlowNavigationNextEvent());

    }

    handleNew(event) {
        this.dispatchEvent(new FlowAttributeChangeEvent('selectedRecord', null));
        this.dispatchEvent(new FlowAttributeChangeEvent('selectedId', null));
        this.dispatchEvent(new FlowAttributeChangeEvent('action', 'create'));
        this.dispatchEvent(new FlowNavigationNextEvent());
    }

}