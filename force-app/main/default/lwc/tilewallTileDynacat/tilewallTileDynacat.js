/*
 * tilewallTileDynacat LWC renders one tile in the Tile Wall catalog.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import tilewallActionModal from 'c/tilewallActionModal';

export default class TilewallTileDynacat extends NavigationMixin(LightningElement) {

    @api tile;
    get tileClasses() {
        let _tileClasses = 'tile-style slds-tile slds-tile_board slds-box slds-m-around_medium';
        if (this.tile.showMedia) _tileClasses += ' slds-media';
        return _tileClasses;
    };
    get bodyClasses() {
        let _bodyClasses = '';
        if (this.tile.showMedia) _bodyClasses += 'slds-media__body';
        return _bodyClasses;
    };
    get iconContainerClasses() {
        if (this.tile.showMedia && this.tile.mediaFormat == 'circle') return 'slds-icon_container_circle slds-p-around_none';
        else return 'slds-p-around_none';
    }
    get showImage() {
        if (this.tile.showMedia == 'image') return true;
        else return false;
    }
    get showIcon() {
        if (this.tile.showMedia == 'icon') return true;
        else return false;
    }

    handleRecordClick(event) {
        // Stop the event's default behavior.
        // Stop the event from bubbling up in the DOM.
        event.preventDefault();
        event.stopPropagation();


        let recordId = event.currentTarget.attributes.getNamedItem('data-id').value;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: recordId,
                objectApiName: this.objectApiName,
                actionName: 'view'
            }
        });
    }

    handleActionSelect(event) {

        const actionNum = parseInt(event.detail.value);
        const recordId = event.currentTarget.dataset.id;
        let action = this.tile.actions.find(a => a.num == actionNum);

        let actionVars = [{
            name: 'recordId',
            type: 'String',
            value: recordId
        }];
        for (let i = 1; i <= 3; i++) {
            if (action['actionVar'+i]) {
                actionVars.push({
                    name: 'actionVar'+i,
                    type: 'String',
                    value: action['actionVar'+i]
                });
            }
        }
        console.log('ActionVars:'+JSON.stringify(actionVars));
        tilewallActionModal.open({
            label: action.label,
            flowName: action.flow,
            actionVars: actionVars
        });

    }

    connectedCallback() {
//        console.log(JSON.stringify(this.tile));
    }


    _hostStylesRendered = false;
    _fieldsRendered = false;
    _badgesRendered = false;
    renderedCallback() {
        if (!this._fieldsRendered && this.tile.fields.length > 0) {
            let lastField = this.template.querySelector(`[data-field="${(this.tile.fields.length-1)}"]`);
            if (typeof lastField != "undefined") {
                try {
                    this.tile.fields.forEach((field, index) => {
                        let fieldEl = this.template.querySelector(`[data-field="${index}"]`);
                        if (fieldEl) {
                            if (field.hasColor) fieldEl.style.color = field.color;
                            if (field.hasBgColor) fieldEl.style.backgroundColor = field.bgColor;
                        }
                        let labelEl = this.template.querySelector(`[data-lab="${index}"]`);
                        if (labelEl) {
                            if (field.hasLabelColor) labelEl.style.color = field.labelColor;
                            if (field.hasLabelBgColor) labelEl.style.backgroundColor = field.labelBgColor;
                        }
                    });
                    this._fieldsRendered = true;
                } catch (error) {
                    console.log('Error during tile rendering: ' + error.message);
                }
            }
        }
        if (!this._badgesRendered && this.tile.badges.length > 0) {
            let lastBadge = this.template.querySelector(`[data-badge="${(this.tile.badges.length-1)}"]`);
            if (typeof lastBadge != "undefined") {
                try {
                    this.tile.badges.forEach((badge, index) => {
                        let badgeEl = this.template.querySelector(`[data-badge="${index}"]`);
                        if (badgeEl) {
                            badgeEl.style.color = badge.color;
                            badgeEl.style.backgroundColor = badge.bgColor;
                        }
                    });
                    this._badgesRendered = true;
                } catch (error) {
                    console.log('Error during tile rendering: ' + error.message);
                }
            }
        }
        if (!this._hostStylesRendered) {
            // Verify whether :host{} variables are inherited from the parent
            let computedStyles = window.getComputedStyle(this.template.host, null);
            let background = computedStyles.getPropertyValue('--background');
            if (!background || background.length == 0) {
                try {
                    this.template.host.style.setProperty('--background', this.tile.tileBackground);
                    this.template.host.style.setProperty('--tileHeight', this.tile.tileHeight);
                    this._setHeight = true;
                    this._hostStylesRendered = true;
                } catch (error) {
                    console.log('Error during tile rendering: ' + error.message);
                }
            }
        }
    }
}