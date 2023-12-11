@isTest
public class TilewallTests_Dynacat {

    @testsetup static void setupTestData() {
        
    	// Create some Tilewall config records
    	
        Tilewall_Config__c tc = new Tilewall_Config__c(	Name='Test Config', 
                                                        Summary__c='Test Tilewall Config', 
                                                        Object_API_Name__c='Dynacat_Product__c',
                                                        title__c='Test Tilewall',
                										iconName__c='standard:account', 
                										displayCount__c=true, 
                										allowSearch__c=true, 
                										searchLabel__c='Search Test', 
                										noResultsText__c='No results', 
                										orderBy__c='Name ASC',
                										orderByFieldname__c='Name',
                										orderByDirection__c='ASC',
                										useAdvancedOrdering__c=false,
                										limitResults__c=12, 
                										columnsLarge__c=4, 
                										columnsMedium__c=3, 
                										columnsSmall__c=1, 
                										backgroundColor__c='#FFFFFF', 
                										color__c='#FFFFFF', 
                										colorFieldName__c='Background_Color__c', 
                										imageURL__c='https://www.test.com', 
                										imageFieldName__c='Background_Image_URL__c', 
                										opacity__c=1.0, 
                										size__c='cover', 
                										heightOption__c='max-row', 
                										fixedHeight__c='',
                										titleName__c='Name',
                										titleSize__c='body_regular',
                										titleTextCase__c='uppercase',
                										titleAlign__c='center',
                										fieldStyle__c='horizontal',
                										padding__c=false,
                										showMedia__c='icon',
                										media__c='standard:product',
                										mediaFieldname__c='Tile_Image_URL__c',
                										mediaFormat__c='circle',
                										mediaSize__c='medium'
                                                      );
        insert(tc);
        
        Tilewall_Config__c tc2 = tc.clone();
        tc2.Name = 'Test Config2';
        tc2.showMedia__c = 'image';
        tc2.orderByFieldname__c = '';
        tc2.fieldStyle__c = 'stacked';
        tc2.padding__c = true;
        insert(tc2);
        
        Tilewall_Field__c tf1 = new Tilewall_Field__c( Name='Test Field',
                                                       Config_Id__c = tc.Id,
                                                       type__c = 'field',
                                                       apiName__c = 'Status__c', 
                                                       label__c = 'Status',
                                                       order__c = 10, 
                                                       size__c = 'body_regular', 
                                                       textCase__c = 'lowercase',
                                                       align__c = 'right', 
                                                       color__c = '#333333', 
                                                       colorFieldname__c = 'Field_Text_Color__c',
                                                       bgColor__c = '#FFFFFF', 
                                                       bgColorFieldname__c = 'Field_Background_Color__c', 
                                                       labelColor__c = '#CCCCCC', 
                                                       labelColorFieldname__c = 'Label_Text_Color__c', 
                                                       labelBgColor__c = '#FFFFFF', 
                                                       labelBgColorFieldname__c = 'Label_Background_Color__c');
        insert(tf1);
        
        Tilewall_Field__c tf2 = tf1.clone();
        tf2.Name = 'Test Badge1';
        tf2.type__c = 'badge';
        tf2.apiName__c = 'Vendor__r.Name';
        tf2.order__c = 20;
        tf2.textCase__c = 'default';
        tf2.badgeIcon__c = 'utility:watchlist';
        tf2.badgeIconFieldname__c = 'Badge_Icon_Name__c';
        insert(tf2);
        
        Tilewall_Field__c tf3 = new Tilewall_Field__c();
        tf3.Config_Id__c = tc.Id;
        tf3.Name = 'Test Action1';
        tf3.type__c = 'action';
        tf3.order__c = 10;
        tf3.flow__c = 'Test_Flow';
        tf3.showActionFieldname__c = 'Recommended__c';
        tf3.actionVar1__c = 'Var1';
        tf3.actionVar2__c = 'Var2';
        tf3.actionVar3__c = 'Var3';
        insert(tf3);
        
    }
    
    @isTest static void TilewallController_GetTilewallConfig() {
        
        Test.startTest();        
        String config1 = TilewallController_Dynacat.getTileWallConfig('Test Config');
        TilewallController_Dynacat.TileWallConfig resp1 = (TilewallController_Dynacat.TileWallConfig)JSON.deserialize(config1, TilewallController_Dynacat.TileWallConfig.class);
        String config2 = TilewallController_Dynacat.getTileWallConfig('Test Config2');
        TilewallController_Dynacat.TileWallConfig resp2 = (TilewallController_Dynacat.TileWallConfig)JSON.deserialize(config2, TilewallController_Dynacat.TileWallConfig.class);
        Test.stopTest();

        System.assertEquals('stacked', resp2.fieldStyle);
        
        System.debug('Tilewall Config1: '+config1); 
        System.debug('Tilewall Config2: '+config2);   

    }
    
    @isTest static void Tilewall_PicklistConfigs() {
        Test.startTest();
        
        Tilewall_Picklist_Configs configs = new Tilewall_Picklist_Configs();
        VisualEditor.DynamicPicklistRows configRows = configs.getValues();
        VisualEditor.DataRow configDefault = configs.getDefaultValue();
        
        Test.stopTest();
    }
}