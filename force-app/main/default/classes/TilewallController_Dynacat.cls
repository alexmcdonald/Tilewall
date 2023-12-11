/*
 * Controller class for the Tilewall LWC (Dynacat edition), a much-updated LWC version of an old aura-
 * based demo component I built a few years ago. 
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

public class TilewallController_Dynacat {
    
    @AuraEnabled(cacheable=true)
    public static String getTileWallConfig(String configName) {

        System.debug('Getting Configs Records');
               
        List<String> baseFields = new List<String>{ 
                'title__c',
                'iconName__c',
                'iconSize__c',
                'displayCount__c', 
                'allowSearch__c', 
                'searchLabel__c', 
                'noResultsText__c', 
                'orderBy__c',
                'orderByFieldname__c',
                'orderByDirection__c',
                'useAdvancedOrdering__c',
                'limitResults__c', 
                'columnsLarge__c', 
                'columnsMedium__c', 
                'columnsSmall__c', 
                'backgroundColor__c', 
                'color__c', 
                'colorFieldName__c', 
                'imageURL__c', 
                'imageFieldName__c', 
                'opacity__c', 
                'size__c', 
                'heightOption__c', 
                'fixedHeight__c',
                'titleName__c',
                'titleSize__c',
                'titleTextCase__c',
                'titleAlign__c',
                'fieldStyle__c',
                'padding__c',
                'showMedia__c',
                'media__c',
                'mediaFieldname__c',
                'mediaFormat__c',
                'mediaSize__c'
        };
            
        List<String> configFields = new List<String>();
        configFields.addAll(baseFields);
        
        List<Tilewall_Config__c> twc = Database.query('SELECT Id, Name, ' + String.join(configFields,',') + ' FROM Tilewall_Config__c WHERE Name=\''+configName+'\'');
        
        if(twc.size() > 0) {
                        
            Tilewall_Config__c c = twc[0];
                        
            Set<String> fieldNamesSet = new Set<String>();
            List<String> fieldNamesList = new List<String>();
                        
            Map<String,Object> base = new Map<String,Object>();
            for(String fieldName : baseFields) {
                if(twc[0].get(fieldName) != null && twc[0].get(fieldName) != '') {
                    String prop = fieldName.removeEnd('__c');
                    base.put(prop, twc[0].get(fieldName));
                }
            }
            TileWallConfig config = (TileWallConfig)JSON.deserialize(JSON.serialize(base),TileWallConfig.class);
            
            config.titleClasses = 'tile-title-value slds-item_detail';
            if(! String.isBlank(config.titleSize)) {
                config.titleClasses += ' slds-text-'+config.titleSize;
                config.hasTitleSize = true;
            }
            if(! String.isBlank(config.titleTextCase)) {
                config.hasTitleTextCase = true;
            }
            if(! String.isBlank(config.titleAlign)) {
                config.titleClasses += ' slds-text-align_'+config.titleAlign;
                config.hasTitleAlign = true;
            }
            if(! String.isBlank(config.showMedia)) {
                if(config.showMedia == 'image') {
                	config.imageClasses = 'slds-avatar';
                	if(! String.isBlank(config.mediaSize)) config.imageClasses += ' slds-avatar_' + config.mediaSize;
					if(! String.isBlank(config.mediaFormat) && config.mediaFormat == 'circle') config.imageClasses += ' slds-avatar_circle';
                }
            }
            if(! fieldNamesSet.contains(config.titleName.toLowerCase())) {
                fieldNamesSet.add(config.titleName.toLowerCase());
                fieldNamesList.add(config.titleName);
            }
                        
            config.sizeLarge = 12/config.columnsLarge;
            config.sizeMedium = 12/config.columnsMedium;
            config.sizeSmall = 12/config.columnsSmall;
            
            if(! config.useAdvancedOrdering) {
                if(! String.isBlank(config.orderByFieldname)) {
                    config.orderBy = config.orderByFieldname;
                    config.orderBy += (! String.isBlank(config.orderByDirection)) ? ' '+config.orderByDirection : ' ASC';
                } else {
                    config.orderBy = '';
                }
            }
            
            if(! String.isBlank(config.mediaFieldname)) {
                config.hasMediaField = true;
                if(! fieldNamesSet.contains(config.mediaFieldname.toLowerCase())) {
                    fieldNamesSet.add(config.mediaFieldname.toLowerCase());
                    fieldNamesList.add(config.mediaFieldname);
                }
            }
            if(! String.isBlank(config.imageFieldName)) {
                config.hasImageField = true;
                if(! fieldNamesSet.contains(config.imageFieldName.toLowerCase())) {
                    fieldNamesSet.add(config.imageFieldName.toLowerCase());
                    fieldNamesList.add(config.imageFieldName);
                }
            }
            if(! String.isBlank(config.imageURL)) config.hasImageURL = true;
            if(! String.isBlank(config.colorFieldName)) {
                config.hasColorField = true;
                if(! fieldNamesSet.contains(config.colorFieldName.toLowerCase())) {
                    fieldNamesSet.add(config.colorFieldName.toLowerCase());
                    fieldNamesList.add(config.colorFieldName);
                }
            }
            if(! String.isBlank(config.media)) config.hasMedia = true;
            if(! String.isBlank(config.color)) config.hasColor = true;
            if(! String.isBlank(config.opacity)) config.hasOpacity = true;
            if(! String.isBlank(config.size)) config.hasSize = true;
            if(! String.isBlank(config.heightOption)) config.hasHeightOption = true;
            if(! String.isBlank(config.fixedHeight)) config.hasFixedHeight = true;
            
            if(! String.isBlank(config.fieldStyle) && config.fieldStyle == 'horizontal') {
                config.fieldClasses = 'slds-table slds-table_header-hidden slds-no-row-hover tilewall-table';
                config.isHorizontal = true;
                config.isStacked = false;
            } else {
                config.fieldClasses = 'slds-list_stacked';
                config.isStacked = true;
                config.isHorizontal = false;
            }
            
            String valuePadding = '';
            String labelPadding = '';
            if(! config.padding) {
                valuePadding = ' slds-p-left_none slds-p-right_none';
                labelPadding = ' slds-p-left_none';
            } else if(config.isStacked) {
                valuePadding = ' slds-p-left_x-small slds-p-right_x-small';
                labelPadding = ' slds-p-left_x-small slds-p-right_x-small';
            }

            
            
            List<Tilewall_Field__c> twf = [SELECT Id, Name, type__c, apiName__c, label__c, order__c, size__c, textCase__c, align__c, color__c, colorFieldname__c, bgColor__c, bgColorFieldname__c, labelColor__c, labelColorFieldname__c, labelBgColor__c, labelBgColorFieldname__c, badgeIcon__c, badgeIconFieldname__c, flow__c, showActionFieldname__c, actionVar1__c, actionVar2__c, actionVar3__c
                                           FROM Tilewall_Field__c 
                                           WHERE Config_Id__c=:c.Id
                                           ORDER BY order__c ASC];

            
           	if(twf.size() > 0) {
            
                List<TilewallField> fields = new List<TilewallField>();
                List<TilewallBadge> badges = new List<TilewallBadge>();
                List<TilewallAction> actions = new List<TilewallAction>();
                
                for(Tilewall_Field__c field : twf) {

                    if(! String.isBlank(field.apiName__c) && field.type__c == 'Field') {
                            
                        TilewallField f = new TilewallField();
                        f.name = field.apiName__c;
                        if(! fieldNamesSet.contains(f.name.toLowerCase())) {
                            fieldNamesSet.add(f.name.toLowerCase());
                            fieldNamesList.add(f.name);
                        }
                        f.num = fields.size()+1;
                        f.valueClasses = 'tile-field' + f.num + '-value tile-field-value' + valuePadding;
                        if(config.isStacked) f.valueClasses += ' slds-item_detail';
                        if(config.isHorizontal) f.valueClasses += ' slds-cell-wrap vertical-align-top slds-p-vertical_none';
                        if(! String.isBlank(field.label__c)) {
                           	f.label = field.label__c;
                            f.labelClasses = 'tile-field' + f.num + '-label tile-field-label slds-text-color_weak' + labelPadding;
                            if(config.isStacked) f.labelClasses += ' slds-item_label slds-truncate';
                            if(config.isHorizontal) f.labelClasses += ' slds-cell-wrap vertical-align-top slds-p-vertical_none';
                            f.hasLabel = true;
                        }
                        if(! String.isBlank(field.size__c)) {
                            f.size = field.size__c;
                            f.valueClasses += ' slds-text-'+f.size;
                            f.hasSize = true;
                        }
                        if(! String.isBlank(field.textCase__c)) {
                            f.textCase = field.textCase__c;
                            f.hasTextCase = true;
                        }
                        if(! String.isBlank(field.align__c)) {
                            f.align = field.align__c;
                            f.valueClasses += ' slds-text-align_'+f.align;
                            f.hasAlign = true;
                        }
                            
                        if(! String.isBlank(field.color__c)) {
                            f.color = field.color__c;
                            f.hasColor = true;
                        }
                        if(! String.isBlank(field.colorFieldname__c)) {
                            f.colorFieldname = field.colorFieldname__c;
                            f.hasColorFieldname = true;
                            if(! fieldNamesSet.contains(f.colorFieldname.toLowerCase())) {
                                fieldNamesSet.add(f.colorFieldname.toLowerCase());
                                fieldNamesList.add(f.colorFieldname);
                            }
                        }
                        if(! String.isBlank(field.bgColor__c)) {
                            f.bgColor = field.bgColor__c;
                            f.hasBGColor = true;
                        }
                        if(! String.isBlank(field.bgColorFieldname__c)) {
                            f.bgColorFieldname = field.bgColorFieldname__c;
                            f.hasBGColorFieldname = true;
                            if(! fieldNamesSet.contains(f.bgColorFieldname.toLowerCase())) {
                                fieldNamesSet.add(f.bgColorFieldname.toLowerCase());
                                fieldNamesList.add(f.bgColorFieldname);
                            }
                        }

                        if(! String.isBlank(field.labelColor__c)) {
                            f.labelColor = field.labelColor__c;
                            f.hasLabelColor = true;
                        }
                        if(! String.isBlank(field.labelColorFieldname__c)) {
                            f.labelColorFieldname = field.labelColorFieldname__c;
                            f.hasLabelColorFieldname = true;
                            if(! fieldNamesSet.contains(f.labelColorFieldname.toLowerCase())) {
                                fieldNamesSet.add(f.labelColorFieldname.toLowerCase());
                                fieldNamesList.add(f.labelColorFieldname);
                            }
                        }
                        if(! String.isBlank(field.labelBgColor__c)) {
                            f.labelBgColor = field.labelBgColor__c;
                            f.hasLabelBgColor = true;
                        }
                        if(! String.isBlank(field.labelBgColorFieldname__c)) {
                            f.labelBgColorFieldname = field.labelBgColorFieldname__c;
                            f.hasLabelBgColorFieldname = true;
                            if(! fieldNamesSet.contains(f.labelBgColorFieldname.toLowerCase())) {
                                fieldNamesSet.add(f.labelBgColorFieldname.toLowerCase());
                                fieldNamesList.add(f.labelBgColorFieldname);
                            }
                        }
                        fields.add(f);
                        
                    } else if(! String.isBlank(field.apiName__c) && field.type__c == 'Badge') {
                        
                        TilewallBadge b = new TilewallBadge();
                        b.name = field.apiName__c;
                        if(! fieldNamesSet.contains(b.name.toLowerCase())) {
                            fieldNamesSet.add(b.name.toLowerCase());
                            fieldNamesList.add(b.name);
                        }
                        b.num = badges.size()+1;
                        b.badgeClasses = ' tile-badge'+b.num+' tile-badge slds-badge slds-m-bottom_none slds-m-left_none slds-m-right_x-small slds-truncate';
                        if(! String.isBlank(field.label__c)) {
                            b.label = field.label__c;
                            b.labelClasses = 'tile-badge'+b.num+'-label tile-badge-label';
                            b.hasLabel = true;
                        }
                        b.valueClasses = 'tile-badge'+b.num+'-value tile-badge-value';
                        if(! String.isBlank(field.textCase__c)) {
                            b.textCase = field.textCase__c;
                            b.hasTextCase = true;
                        }
                        if(! String.isBlank(field.badgeIcon__c)) {
                            b.badgeIcon = field.badgeIcon__c;
                            b.hasBadgeIcon = true;
                        }
                        if(! String.isBlank(field.badgeIconFieldname__c)) {
                            b.badgeIconFieldname = field.badgeIconFieldname__c;
                            b.hasBadgeIconFieldname = true;
                            if(! fieldNamesSet.contains(b.badgeIconFieldname.toLowerCase())) {
                                fieldNamesSet.add(b.badgeIconFieldname.toLowerCase());
                                fieldNamesList.add(b.badgeIconFieldname);
                            }
                        }
                        if(! String.isBlank(field.color__c)) {
                            b.color = field.color__c;
                            b.hasColor = true;
                        }
                        if(! String.isBlank(field.colorFieldname__c)) {
                            b.colorFieldname = field.colorFieldname__c;
                            b.hasColorFieldname = true;
                            if(! fieldNamesSet.contains(b.colorFieldname.toLowerCase())) {
                                fieldNamesSet.add(b.colorFieldname.toLowerCase());
                                fieldNamesList.add(b.colorFieldname);
                            }
                        }
                        if(! String.isBlank(field.bgColor__c)) {
                            b.bgColor = field.bgColor__c;
                            b.hasBGColor = true;
                        }
                        if(! String.isBlank(field.bgColorFieldname__c)) {
                            b.bgColorFieldname = field.bgColorFieldname__c;
                            b.hasBGColorFieldname = true;
                            if(! fieldNamesSet.contains(b.bgColorFieldname.toLowerCase())) {
                                fieldNamesSet.add(b.bgColorFieldname.toLowerCase());
                                fieldNamesList.add(b.bgColorFieldname);
                            }
                        }
                        badges.add(b);   

                    } else if(field.type__c == 'action') {
                            
                        TilewallAction a = new TilewallAction();
                        a.name = field.flow__c;
                        a.num = actions.size()+1;
                        a.flow = field.flow__c;
                        a.label = (! String.isBlank(field.label__c)) ? field.label__c : field.flow__c;
                        if(! String.isBlank(field.showActionFieldname__c)) {
                            a.showActionFieldname = field.showActionFieldname__c;
                            a.hasShowActionFieldname = true;
                            if(! fieldNamesSet.contains(a.showActionFieldname.toLowerCase())) {
                            	fieldNamesSet.add(a.showActionFieldname.toLowerCase());
                            	fieldNamesList.add(a.showActionFieldname);
                        	}
                        }
                        if(! String.isBlank(field.actionVar1__c)) a.actionVar1 = field.actionVar1__c;
                        if(! String.isBlank(field.actionVar2__c)) a.actionVar2 = field.actionVar2__c;
                        if(! String.isBlank(field.actionVar3__c)) a.actionVar3 = field.actionVar3__c;
                        actions.add(a);

                    }
                    
                }
                
                if(fields.size() > 0) config.fields = fields;
                if(badges.size() > 0) config.badges = badges;
                if(actions.size() > 0) config.actions = actions;
	        }
         
            config.fieldNames = fieldNamesList;
            return JSON.serialize(config, true);
            
        }

		return null;        
    } 

    
    public class TileWallConfig {
        public String title;
        public String iconName;
        public String iconSize;
        public Boolean displayCount;
        public Integer limitResults;
        public String orderBy;
        public String orderByFieldname;
        public String orderByDirection;
        public Boolean useAdvancedOrdering;
        public Boolean allowSearch;
        public String searchLabel;
        public String noResultsText;
        public Integer columnsLarge;
        public Integer columnsMedium;
        public Integer columnsSmall;
        public Integer sizeLarge;
        public Integer sizeMedium;
        public Integer sizeSmall;
        public String backgroundColor;
        public Boolean hasBackgroundColor;
        public String color;
        public Boolean hasColor;
        public String colorFieldName;
        public Boolean hasColorField;
        public String imageURL;
        public Boolean hasImageURL;
        public String imageFieldName;
        public Boolean hasImageField;
        public String opacity;
        public Boolean hasOpacity;
        public String size;
        public Boolean hasSize;
        public String heightOption;
        public Boolean hasHeightOption;
        public String fixedHeight;
		public Boolean hasFixedHeight;  
        public String titleName;
        public String titleSize;
        public Boolean hasTitleSize;
        public String titleTextCase;
        public Boolean hasTitleTextCase;
        public String titleAlign;
        public Boolean hasTitleAlign;
        public String titleClasses;
        public String fieldStyle;
        public Boolean padding;
        public String fieldClasses;
        public Boolean isHorizontal;
        public Boolean isStacked;
        public String showMedia;
        public String media;
        public Boolean hasMedia;
        public String mediaFieldname;
        public Boolean hasMediaField;
        public String mediaFormat;
        public String mediaSize;
        public String imageClasses;
		public List<TileWallField> fields;
        public List<TileWallBadge> badges;
        public List<TileWallAction> actions;
        
        public List<String> fieldNames;
    }
    
    
    public class TileWallField {
        public Integer num;
		public String name;
        public String label;
        public Boolean hasLabel;
        public String labelClasses;
        public String textCase;
        public Boolean hasTextCase;
        public String align;
        public Boolean hasAlign;
        public String size;
        public Boolean hasSize;
        public String color;
        public Boolean hasColor;
        public String colorFieldname;
        public Boolean hasColorFieldname;
        public String bgColor;
        public Boolean hasBgColor;
        public String bgColorFieldname;
        public Boolean hasBgColorFieldname;
        public String labelColor;
        public Boolean hasLabelColor;
        public String labelColorFieldname;
        public Boolean hasLabelColorFieldname;
        public String labelBgColor;
        public Boolean hasLabelBgColor;
        public String labelBgColorFieldname;
        public Boolean hasLabelBgColorFieldname;

        public String valueClasses;
    }
    
    public class TileWallBadge {
        public Integer num;
        public String name;
        public String label;
        public Boolean hasLabel;
        public String badgeClasses;
        public String labelClasses;
        public String textCase;
        public Boolean hasTextCase;
        public String color;
        public Boolean hasColor;
        public String colorFieldname;
        public Boolean hasColorFieldname;
        public String bgColor;
        public Boolean hasBgColor;
        public String bgColorFieldname;
        public Boolean hasBgColorFieldname;
        public String badgeIcon;
        public Boolean hasBadgeIcon;
        public String badgeIconFieldname;
        public Boolean hasBadgeIconFieldname;
        public String valueClasses;
    }   
    
    public class TileWallAction {
        public Integer num;
        public String name;
        public String label;
        public Boolean hasLabel;
        public String flow;
        public String showActionFieldname;
        public Boolean hasShowActionFieldname;
		public String actionVar1;
		public String actionVar2;
		public String actionVar3;        
    }
        
}