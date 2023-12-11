/*
 * tilewallDynacat LWC is a mash-up between the dynacatServerCatalog and the Tile Wall LWC. 
 * As with the Server version, all the filtering and pagination of target records is done in APEX.  
 * It should be much more scalable than the original dynacatCatalog LWC, particularly if support enable indexing 
 * for the fields being filtered.
 *
 * The Tile Wall adds more configurable display options for the filtered records. In the config for the component 
 * you can set which fields should be displayed, how they should be aligned, background colours, images, etc. You can
 * also use a formula field on the record to specify a background colour, background image, or a badge foreground/background
 * colour.  And, SOSL search is built in, which enables full-text searching of all SOSL enabled fields on the records.
 *
 * DISCLAIMER: This is sample code only released under the CC0.
 * It is not of production quality, and is not warranted for quality or fitness 
 * for purpose by me or my employer.
*/

import { LightningElement, wire, track, api } from 'lwc';
import getTileWallConfig from '@salesforce/apex/TilewallController_Dynacat.getTileWallConfig';
import getDefaultRecords from '@salesforce/apex/DynacatTileWallController.getDefaultRecords';
import getFilteredRecords from '@salesforce/apex/DynacatTileWallController.getFilteredRecords';
import getNextRecords from '@salesforce/apex/DynacatTileWallController.getNextRecords';
import searchRecords from '@salesforce/apex/DynacatTileWallController.searchRecords';

// Import message service features required for subscribing and the message channel
import { subscribe, MessageContext } from 'lightning/messageService';
import FILTER_CHANGED_CHANNEL from '@salesforce/messageChannel/dynacatFilterChanged__c';

export default class TilewallDynacat extends LightningElement {


    // Inputs
    @api deployment;

    // Tile Wall Inputs
    @api tileWallConfigName;
    @api soqlWhere;
    @api recordId;

    tileProperties;
    noResults = false;
    queryTerm;
    @track tiles = [];

    progressText;
    showNext;
    showPrevious;

    count = 0;
    offset = 0;

    @track records;
    soql;

    _timeout;

    @track filters = {};

    dataRetrieved = false;
    notConfigured = false;


    get dataReady() {
        return (this.dataRetrieved) ? true : false;
    }

    get columnClass() {
        const colSizeLarge = this.tileProperties.sizeLarge;
        const colSizeMedium = this.tileProperties.sizeMedium;
        const colSizeSmall = this.tileProperties.sizeSmall;
        return `slds-col slds-size_${colSizeSmall}-of-12 slds-large-size_${colSizeLarge}-of-12 slds-medium-size_${colSizeMedium} slds-small-size_${colSizeSmall} slds-p-vertical_small`;
    };


    // Get the default set of records, runs after the Tile properties have been initialised
    getDefault() {

        getDefaultRecords({
            fieldNames: this.tileProperties.fieldNames,
            soqlWhere: this.soqlWhere,
            recordId: this.recordId,
            config: this.tileWallConfigName,
            deployment: this.deployment,
            orderBy: this.tileProperties.orderBy,
            limitResults: this.tileProperties.limitResults
        }).then((result) => {
            if (typeof result != "undefined" && result != null && result != '') {
                let parsedData = JSON.parse(result);
                this.soql = parsedData.soql;
                this.handleResult(parsedData, false);
                this.dataRetrieved = true;
            }
        }).catch((error) => {
            console.log(error.message);
            this.notConfigured = true;
        });
    }


    // Handles the entered search term by executing the search method. If the term is removed then it re-runs the filters
    handleSearch(event) {
        this.queryTerm = event.currentTarget.value;
        if (this.queryTerm.length >= 2) {
            clearTimeout(this._timeout);
            this._timeout = setTimeout(() => { this.search() }, 300);
        } else if (this.queryTerm.length == 0) {
            this.getFiltered();
        }
    }

    search() {
        this.noResults = false;
        searchRecords({
            queryTerm: this.queryTerm,
            soqlStr: JSON.stringify(this.soql)
        }).then((result) => {
            if (typeof result != "undefined" && result != null && result != '') {
                let parsedData = JSON.parse(result);
                this.handleResult(parsedData, false);
            }
        }).catch((error) => {
            console.log(error.message);
        });
    }

    // Handler for message received from the filters component
    handleFilterChange(message) {
        let node = message.appliedFilters;
        this.filters[node.rootNode] = node.filters;

        // Sets a timeout to slow things down
        clearTimeout(this._timeout);
        this._timeout = setTimeout(() => { this.getFiltered() }, 300);
    }


    // Gets the filtered records, with or without a search term applied
    getFiltered() {
        getFilteredRecords({
            soqlStr: JSON.stringify(this.soql),
            filtersStr: JSON.stringify(this.filters),
            queryTerm: this.queryTerm
        }).then((result) => {
            if (typeof result != "undefined" && result != null && result != '') {
                let parsedData = JSON.parse(result);
                this.soql = parsedData.soql;
                this.handleResult(parsedData, false);
            } else {
                console.log('getFilteredRecords: No result');
            }
        }).catch((error) => {
            console.log(error.message);
        });
    }

    // Subscribes this component to the filters changed channel
    @wire(MessageContext) messageContext;
    subscribeToMessageChannel() {
        this.subscription = subscribe(
            this.messageContext,
            FILTER_CHANGED_CHANNEL,
            (message) => this.handleFilterChange(message)
        );
    }

    // Handlers for the Next & Previous buttons
    handleNext() {
        this.getMoreRecords(true);
    }
    handlePrevious() {
        this.getMoreRecords(false);
    }

    // Gets the next or previous set of records
    getMoreRecords(more) {
        let offset = (more) ? (this.offset + this.tileProperties.limitResults) : (this.offset - this.tileProperties.limitResults);
        console.log('Offset: ' + offset);
        getNextRecords({
            soqlStr: JSON.stringify(this.soql),
            offset: offset,
            queryTerm: this.queryTerm
        }).then((result) => {
            if (typeof result != "undefined" && result != null && result != '') {
                let parsedData = JSON.parse(result);
                this.offset += (more) ? this.tileProperties.limitResults : -this.tileProperties.limitResults;
                this.handleResult(parsedData, true);
            } else {
                console.log('getNextRecords: No result');
            }
        }).catch((error) => {
            console.log(error.message);
        })
    }

    // Helper to process the result from each query and kick off the follow-on methods
    handleResult(parsedData, offset) {
        this.count = parsedData.count;
        if (!offset) this.offset = 0;
        this.records = parsedData.records;
        this.updateProgress();
        if (this.records.length > 0) {
            this.noResults = false;
            this.processRecords();
        } else {
            this.noResults = true;
            this.tiles = [];
        }
    }

    // Updates the record counts and shows the Previous/Next buttons appropriately
    updateProgress() {
        if (this.records.length == 0) {
            this.progressText = 'No records matched the filters.';
        } else {
            this.progressText = 'Showing records ' + (this.offset + 1) + ' to ' + (this.offset + this.records.length) + ' of ' + this.count + ' total.';
        }
        this.showNext = (this.count > (this.offset + this.records.length));
        this.showPrevious = (this.offset > 0);
    }


    // Processes the received records and generates the list of tiles to be displayed
    processRecords() {
        let _records = this.records;
        let tileProperties = this.tileProperties;

        let _tiles = [];
        for (let i = 0; i < _records.length; i++) {
            let tile = {
                id: _records[i].record.Id,
                fields: [],
                badges: [],
                actions: [],
                hasFields: false,
                hasBadges: false,
                hasActions: false
            };
            // Field Values
            if (tileProperties.fields) {
                for (let j = 0; j < (tileProperties.fields).length; j++) {
                    let field = Object.assign({}, tileProperties.fields[j]);
                    field.value = this.processValue(field.name, _records[i].record);
                    if (field.value) {
                        if (field.hasTextCase) {
                            if (field.textCase == "lowercase") field.value = (field.value).toString().toLowerCase();
                            else if (field.textCase == "uppercase") field.value = (field.value).toString().toUpperCase();
                        }
                        if (field.hasColorFieldname) {
                            const color = this.processValue(field.colorFieldname, _records[i].record);
                            if (color) field.color = color;
                        }
                        if (field.hasBgColorFieldname) {
                            const bgColor = this.processValue(field.bgColorFieldname, _records[i].record);
                            if (bgColor) field.bgColor = bgColor;
                        }
                        if (field.hasLabelColorFieldname) {
                            const color = this.processValue(field.labelColorFieldname, _records[i].record);
                            if (color) field.labelColor = color;
                        }
                        if (field.hasLabelBgColorFieldname) {
                            const bgColor = this.processValue(field.labelBgColorFieldname, _records[i].record);
                            if (bgColor) field.labelBgColor = bgColor;
                        }
                        field.hasValue = true;
                        tile.fields.push(field);
                    }
                }
                if (tile.fields.length > 0) tile.hasFields = true;
            }
            // Badge Values
            if (tileProperties.badges) {
                for (var j = 0; j < (tileProperties.badges).length; j++) {
                    let badge = Object.assign({}, tileProperties.badges[j]);
                    badge.value = this.processValue(badge.name, _records[i].record);
                    if (badge.value) {
                        if (badge.hasTextCase) {
                            if (badge.textCase == "lowercase") badge.value = (badge.value).toString().toLowerCase();
                            else if (badge.textCase == "uppercase") badge.value = (badge.value).toString().toUpperCase();
                        }
                        if (badge.hasBadgeIconFieldname) {
                            const badgeIcon = this.processValue(badge.badgeIconFieldname, _records[i].record);
                            if (badgeIcon) badge.badgeIcon = badgeIcon;
                        }
                        if (badge.hasColorFieldname) {
                            const color = this.processValue(badge.colorFieldname, _records[i].record);
                            if (color) badge.color = color;
                        }
                        if (badge.hasBgColorFieldname) {
                            const bgColor = this.processValue(badge.bgColorFieldname, _records[i].record);
                            if (bgColor) badge.bgColor = bgColor;
                        }
                        badge.hasValue = true;
                        tile.badges.push(badge);
                    }
                }
                if (tile.badges.length > 0) tile.hasBadges = true;
            }

            // Action Values
            if (tileProperties.actions) {
                for (var j = 0; j < (tileProperties.actions).length; j++) {
                    let action = Object.assign({}, tileProperties.actions[j]);
                    if (action.flow) {
                        if (action.hasShowActionFieldname) {
                            const showAction = this.processValue(action.showActionFieldname, _records[i].record);
                            if (showAction) action.showAction = true;
                            else action.showAction = false;
                        } else {
                            action.showAction = true;
                        }
                        if (action.showAction) tile.actions.push(action);
                    }
                }
                if (tile.actions.length > 0) tile.hasActions = true;
            }

            // Tile-specific styles
            let imageURL;
            let color;
            let tileBackground = '';
            if (tileProperties.hasImageField) imageURL = this.processValue(tileProperties.imageFieldName, _records[i].record);
            if (!imageURL && tileProperties.hasImageURL) imageURL = tileProperties.imageURL;
            if (tileProperties.hasColorField) color = this.processValue(tileProperties.colorFieldName, _records[i].record);
            if (!color && tileProperties.hasColor) color = tileProperties.color;
            if (tileProperties.hasOpacity) {
                const bgRGB = (color) ? this.hexToRgb(color) : this.hexToRgb("#FFFFFF");
                tileBackground += `linear-gradient(rgb(${bgRGB.r},${bgRGB.g},${bgRGB.b},${tileProperties.opacity}), rgb(${bgRGB.r},${bgRGB.g},${bgRGB.b},${tileProperties.opacity}))`;
                if (imageURL) {
                    tileBackground += `, url('${imageURL}') no-repeat center`;
                    if (tileProperties.hasSize) tileBackground += `/${tileProperties.size} `;
                }
            } else {
                if (color) {
                    tileBackground += `${color} `;
                }
                if (imageURL) {
                    tileBackground += `url('${imageURL}') no-repeat center`;
                    if (tileProperties.hasSize) tileBackground += `/${tileProperties.size} `;
                }
            }
            tile.tileBackground = tileBackground;

            let tileHeight = '';
            if (tileProperties.hasFixedHeight && (tileProperties.hasHeightOption && tileProperties.heightOption == 'fixed') || (!tileProperties.hasHeightOption)) {
                tileHeight = tileProperties.fixedHeight;
            } else if (tileProperties.hasHeightOption && tileProperties.heightOption == "max-row") {
                tileHeight = "calc(100% - 24px)";
            }
            tile.tileHeight = tileHeight;

            tile.titleValue = this.processValue(tileProperties.titleName, _records[i].record);
            if (tile.titleValue) {
                if (tileProperties.hasTitleTextCase) {
                    if (tileProperties.titleTextCase == "lowercase") tile.titleValue = (tile.titleValue).toString().toLowerCase();
                    else if (tileProperties.titleTextCase == "uppercase") tile.titleValue = (tile.titleValue).toString().toUpperCase();
                }
            }

            tile.titleClasses = tileProperties.titleClasses;
            tile.fieldClasses = tileProperties.fieldClasses;
            tile.isHorizontal = tileProperties.isHorizontal;
            tile.isStacked = tileProperties.isStacked;

            if (tileProperties.showMedia) {
                tile.showMedia = tileProperties.showMedia;
                if (tileProperties.hasMediaField) tile.media = this.processValue(tileProperties.mediaFieldname, _records[i].record);
                if (!tile.media && tileProperties.hasMedia) tile.media = tileProperties.media;
                tile.mediaSize = tileProperties.mediaSize;
                tile.mediaFormat = tileProperties.mediaFormat;
                if (tileProperties.showMedia == 'image') tile.imageClasses = tileProperties.imageClasses;
            }

            _tiles.push(tile);
        }
        this.tiles = _tiles;
    }

    // Helper to process possible parent record fields/badges/styles that are displayed on the tile
    processValue(fieldname, record) {
        if (fieldname.indexOf('.') > 0) {
            const fieldArray = fieldname.split('.');
            const objPart = fieldArray[0];
            const valPart = fieldArray[1];
            return (record[objPart] && record[objPart][valPart]) ? record[objPart][valPart] : '';
        } else {
            return (record[fieldname]) ? record[fieldname] : '';
        }
    }


    // Helper to convert a hex-formatted color into an rgb one
    hexToRgb(hex) {
        const shorthandRegex = /^#?([a-f\d])([a-f\d])([a-f\d])$/i;
        hex = hex.replace(shorthandRegex, function (m, r, g, b) {
            return r + r + g + g + b + b;
        });

        const result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            r: parseInt(result[1], 16),
            g: parseInt(result[2], 16),
            b: parseInt(result[3], 16)
        } : null;
    }


    initializeTileWall() {

        // Get Config
        getTileWallConfig({
            configName: this.tileWallConfigName
        }).then((result) => {
            if (typeof result != "undefined" && result != null && result != '') {
                let parsedData = JSON.parse(result);

                this.tileProperties = parsedData;

                // Get the base set of records
                try {
                    if (this.tileProperties.titleName) {
                        this.getDefault(false);
                    }
                } catch (error) {
                    console.log(JSON.stringify(error.message));
                }

            }
        }).catch((error) => {
            console.log(error.message);
            this.notConfigured = true;
        });

    }

    connectedCallback() {

        this.subscribeToMessageChannel();
        this.initializeTileWall();

        if (!this.tileWallConfigName) {
            this.notConfigured = true;
        }

    }

    _hasRendered = false;
    renderedCallback() {
        if (!this._hasRendered && this.tileProperties) {
            try {
                if (this.tileProperties.backgroundColor) {
                    let computedStyles = window.getComputedStyle(this.template.host, null);
                    let backgroundColor = computedStyles.getPropertyValue('--backgroundColor');

                    if (!backgroundColor || backgroundColor.length == 0) {
                        this.template.host.style.setProperty('--backgroundColor', this.tileProperties.backgroundColor);
                        this._hasRendered = true;
                    }
                }
            } catch (error) {
                console.log(error.message);
            }
        }
    }


}