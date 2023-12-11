/*
 * objectFieldPicker LWC is a Flow screen component that enables you to select an SObject and Field, 
 * including navigation of lookup / master-detail fields.  It outputs the field path (eg. Account.Owner.Name) 
 * and the object the final field is on (in that example the User object). If the field is a picklist field 
 * then the valid values are also output.
 *
 * Dynacat version used in the Dynacat Configurator Flow.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';

import getObjects from '@salesforce/apex/ObjectFieldPickerController_Dynacat.getObjects';
import getFields from '@salesforce/apex/ObjectFieldPickerController_Dynacat.getFields';

export default class ObjectFieldPickerDynacat extends LightningElement {

    // Input Only Properties
    @api hideObjectPicker = false;
    @api disableObjectPicker = false;
    @api ignoreRelationships = false;
    @api fieldTypes;
    @api title;
    @api tooltip;
    @api border = false;

    // Input/Output Properties
    @api rootSObject;
    @api field;
    @api finalSObject;

    // Output Only Properties
    @api fieldType;
    @api picklistValues;

    // Internal Properties
    get rootSObjectRendered() {
        return this.rootSObject;
    };
    rootSObjectOptions;
    objectFields = [];

    _dataReady = false;
    get dataReady() {
        return this._dataReady;
    }

    get cardClass() {
        if(this.border) return "slds-card slds-card_boundary slds-m-bottom_x-small";
        else return "slds-card slds-m-bottom_x-small field-picker-no-border";
    }

    getObjectDetails() {
        console.log('** Getting Object Details');
        getObjects()
        .then(result => {
            if (result) {
                const parsedData = JSON.parse(result);
                this.rootSObjectOptions = parsedData;
                if (this.rootSObject) {
                    this.getFields(this.rootSObject, 0, this.field);
                }
                this._dataReady = true;
            }
        }).catch(error => {
            console.log('** Error when getting SObjects: "' + error.message + '" **');
        })
    }

    getFields(objectName, depth, field) {
        console.log('** Getting fields for ' + objectName + ', depth: ' + depth + ', field: ' + field);
        getFields({
            objectName: objectName,
            fieldTypes: this.fieldTypes
        }).then((result) => {
            if (result) {
                let objectFields = JSON.parse(result);
                objectFields.depth = depth;
                objectFields.labelText = `Select ${objectFields.objectLabel} Field`;
                if (field) {
                    // An existing field was passed into component as an input, set it and expand it if necessary
                    this.processInputField(field, objectFields);
                } else {
                    this.objectFields = this.objectFields.concat(objectFields);
                }
            }
        }).catch((error) => {
            console.log('** Error when getting Fields: has error: ' + error.message);
        })
    }

    processInputField(field, objectFields) {
        console.log('** Processing field input: ' + field);
        if (field.indexOf('.') > 0) {
            // Field is a relationship to another object, need to traverse the tree
            const fieldArray = field.split('.');
            const relationshipName = fieldArray[0];
            const fieldDetail = objectFields.referenceFieldMap[relationshipName];
            const depth = objectFields.depth;

            objectFields.fieldPath = relationshipName;
            objectFields.value = fieldDetail.name;
            this.objectFields = this.objectFields.concat(objectFields);

            const fieldPath = field.slice(fieldArray[0].length + 1);
            this.getFields(fieldDetail.referenceTo, depth + 1, fieldPath);
        } else {
            objectFields.value = field;
            this.objectFields = this.objectFields.concat(objectFields);

            // If the field is a reference field, then retrieve the fields for the referenced object
            if (objectFields.fieldMap[field].type == 'REFERENCE' && !this.ignoreRelationships) {
                objectFields.fieldPath = objectFields.fieldMap[field].relationshipName;
                this.getFields(objectFields.fieldMap[field].referenceTo, objectFields.depth + 1, null);
            }
        }
    }

    handleRootObjectChange(event) {
        console.log('** Root SObject changed.');
        const objectName = event.detail.value;
        this.dispatchEvent(new FlowAttributeChangeEvent('rootSObject', objectName));
        this.dispatchEvent(new FlowAttributeChangeEvent('field', null));
        this.objectFields = [];
        this.getFields(objectName, 0, null);
    }

    handleFieldChange(event) {
        console.log('** Field selected or changed.');

        const depth = parseInt(event.currentTarget.dataset.index);
        const fieldName = event.detail.value;

        // Which set of fields was changed? If it's an earlier set then the later ones need to be sliced. 
        const offset = (this.objectFields.length - 1) - depth;
        if (offset > 0) this.objectFields = this.objectFields.slice(0, -offset);

        let fieldMap = this.objectFields[depth].fieldMap;
        fieldMap.value = fieldName;

        let field = '';
        for (let i = 0; i < this.objectFields.length - 1; i++) {
            field += this.objectFields[i].fieldPath + '.';
        }
        field += fieldName;

        this.dispatchEvent(new FlowAttributeChangeEvent('field', field));
        this.dispatchEvent(new FlowAttributeChangeEvent('fieldType', fieldMap[fieldName].type));
        this.dispatchEvent(new FlowAttributeChangeEvent('finalSObject', this.objectFields[depth].objectName));

        let picklistValues = fieldMap[fieldName].picklistValues;
        if (!picklistValues || picklistValues.length <= 255) picklistValues = '';
        this.dispatchEvent(new FlowAttributeChangeEvent('picklistValues', picklistValues));

        if (fieldMap[fieldName].type == 'REFERENCE' && !this.ignoreRelationships) {
            this.objectFields[depth].fieldPath = fieldMap[fieldName].relationshipName;
            this.getFields(fieldMap[fieldName].referenceTo, depth + 1, null);
        }
    }

    handleClear() {

        this.objectFields = [];
        
        this.dispatchEvent(new FlowAttributeChangeEvent('field', null));
        this.dispatchEvent(new FlowAttributeChangeEvent('fieldType', null));
        this.dispatchEvent(new FlowAttributeChangeEvent('finalSObject', null));
        if(! this.hideObjectPicker && ! this.disableObjectPicker) {
            this.dispatchEvent(new FlowAttributeChangeEvent('rootSObject', null));
        }
        this.getObjectDetails();

    }

    connectedCallback() {
        this.getObjectDetails();
    }

}