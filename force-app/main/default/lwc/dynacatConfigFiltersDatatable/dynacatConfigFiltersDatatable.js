/*
 * dynacatConfigFiltersDatatable LWC is used by the Dynacat Configurator Flow, to display the table of configured filters
 * for a deployment and enable Edit / Delete / Create actions to be initiated.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent, FlowNavigationNextEvent } from "lightning/flowSupport";

export default class DynacatConfigFiltersDatatable extends LightningElement {

    // Inputs
    @api get dynacatFilters() {
        return this._dynacatFilters;
    }
    set dynacatFilters(value) {
        this._dynacatFilters = value;
        console.log(this._dynacatFilters);
        this.splitFilters();
    }
    get showFields() {
        return this._fields.length > 0;
    }
    get fields() {
        console.log('Returning fields');
        return this._fields;
    }
    get showAttributes() {
        return this._attributes.length > 0;
    }
    get attributes() {
        console.log('Returning attributes');
        return this._attributes;
    }
    get showSections() {
        return this._sections.length > 0;
    }
    get sections() {
        console.log('Returning sections');
        return this._sections;
    }
    @api label;

    // Outputs
    @api selectedRecord;
    @api selectedId;
    @api action;

    _dynacatFilters;
    _fields;
    _attributes;
    _sections;

    get displayTable() {
        return (this._dynacatFilters) ? true : false;
    }

    splitFilters() {

        console.log('Splitting filters');

        let f = [];
        let a = [];
        let s = [];

        console.log(this._dynacatFilters.length);
        console.log(JSON.stringify(this._dynacatFilters));
        this._dynacatFilters.forEach(filter => {
            if (filter.Type__c == 'Field') f.push(filter);
            else if (filter.Type__c == 'Attribute') a.push(filter);
            else if (filter.Type__c == 'Section') s.push(filter);
        });

        this._fields = (f.length > 0) ? f : [];
        this._attributes = (a.length > 0) ? a : [];
        this._sections = (s.length > 0) ? s : [];

        console.log('Fields: '+JSON.stringify(this._fields));
        console.log('Attribute: '+JSON.stringify(this._attributes));
        console.log('Sections: '+JSON.stringify(this._sections));

    }

    handleRowAction(event) {

        const actionName = event.detail.value;
        const type = event.currentTarget.dataset.type;
        const index = parseInt(event.currentTarget.dataset.row);

        console.log(`${actionName}: ${type} ${index}`);

        let row;
        if (type == 'field') row = this.fields[index];
        else if (type == 'attribute') row = this.attributes[index];
        else if (type == 'section') row = this.sections[index];

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