@isTest
private class DynacatTests {

    @testSetup static void setupTestData() {

        // Create some nested attributes
        
        Dynacat_Attribute__c a100 = new Dynacat_Attribute__c( Name='Attribute 1', Order__c=1, Selectable__c=true, Active__c=true );
        insert(a100);
        
          Dynacat_Attribute__c a110 = new Dynacat_Attribute__c( Name='Attribute 1.1', Order__c=1, Selectable__c=true, Active__c=true, Parent_Attribute__c = a100.Id );
          insert(a110);  
        
            Dynacat_Attribute__c a111 = new Dynacat_Attribute__c( Name='Attribute 1.1.1', Order__c=1, Selectable__c=true, Active__c=true, Parent_Attribute__c = a110.Id);
            insert(a111); 
        
          Dynacat_Attribute__c a120 = new Dynacat_Attribute__c( Name='Attribute 1.2', Order__c=2, Selectable__c=true, Active__c=true, Parent_Attribute__c = a100.Id);
          insert(a120);
        
        Dynacat_Attribute__c a200 = new Dynacat_Attribute__c( Name='Attribute 2', Order__c=2, Selectable__c=false, Active__c=true );
        insert(a200);        
        
          Dynacat_Attribute__c a210 = new Dynacat_Attribute__c( Name='Attribute 2.1', Order__c=1, Selectable__c=true, Active__c=true, Parent_Attribute__c = a200.Id );
          insert(a210); 
        
          Dynacat_Attribute__c a220 = new Dynacat_Attribute__c( Name='Attribute 2.2', Order__c=2, Selectable__c=true, Active__c=true, Parent_Attribute__c = a200.Id );
          insert(a220);
        
        Dynacat_Attribute__c a300 = new Dynacat_Attribute__c( Name='Attribute 3', Order__c=3, Selectable__c=false, Active__c=true );
        insert(a300);        
        
          Dynacat_Attribute__c a310 = new Dynacat_Attribute__c( Name='Attribute 3.1', Order__c=1, Selectable__c=true, Active__c=true, Parent_Attribute__c = a300.Id );
          insert(a310); 
        
          Dynacat_Attribute__c a320 = new Dynacat_Attribute__c( Name='Attribute 3.2', Order__c=2, Selectable__c=true, Active__c=true, Parent_Attribute__c = a300.Id );
          insert(a320);
        
            Dynacat_Attribute__c a321 = new Dynacat_Attribute__c( Name='Attribute 3.2.1', Order__c=1, Selectable__c=true, Active__c=true, Parent_Attribute__c = a320.Id);
            insert(a321);

            Dynacat_Attribute__c a322 = new Dynacat_Attribute__c( Name='Attribute 3.2.2', Order__c=2, Selectable__c=true, Active__c=true, Parent_Attribute__c = a320.Id);
            insert(a322);


        // Create a test product
        
        Dynacat_Product__c p1 = new Dynacat_Product__c(Name='Product 1', 
                                                       Status__c='Active', 
                                                       Price__c=99.50, 
                                                       Launch_Date__c=Date.today(), 
                                                       Industries__c='Retail;Health & Life Sciences;');
        insert(p1);
        
        Dynacat_Product__c p2 = new Dynacat_Product__c(Name='Product 2 Improved', 
                                                       Status__c='Active', 
                                                       Price__c=140, 
                                                       Launch_Date__c=Date.today()-100, 
                                                       Industries__c='Retail;Communications;Public Sector;');
        insert(p2);
        
        
        // Link a few attributes to each product
        
        Map<Id,Dynacat_Attribute__c> attributeMap = new Map<Id,Dynacat_Attribute__c>([SELECT Id,External_Id__c FROM Dynacat_Attribute__c]);
        
        List<String> p1RecordAttributes = new List<String>();
        for(Id i1 : new List<Id>{ a110.Id, a111.Id, a210.Id, a322.Id }) {
            p1RecordAttributes.add(attributeMap.get(i1).External_Id__c);
        }
        DynacatAttSelectorController.saveRecordAttributes(JSON.serialize(p1RecordAttributes), p1.Id, 'Dynacat_Product__c', 'Dynacat_Product__c');

        List<String> p2RecordAttributes = new List<String>();
        for(Id i2 : new List<Id>{ a120.Id, a111.Id, a220.Id, a322.Id }) {
            p2RecordAttributes.add(attributeMap.get(i2).External_Id__c);
        }
        DynacatAttSelectorController.saveRecordAttributes(JSON.serialize(p2RecordAttributes), p2.Id, 'Dynacat_Product__c', 'Dynacat_Product__c');
        
        
        // Create the Dynacat Deployment & Filter Custom Settings
        
        Dynacat_Deployment__c deployment = new Dynacat_Deployment__c(Name='Test Deployment', Object_API_Name__c='Dynacat_Product__c', Summary__c='Test Deployment');
        insert(deployment);

        List<Dynacat_Filter__c> filters = new List<Dynacat_Filter__c>();
        
        filters.add(new Dynacat_Filter__c(Name='Section 1', 
                                          Type__c='Section', 
                                          Filter__c='Section 1', 
                                          Order__c=10, 
                                          Deployment_Id__c=deployment.Id
                                         ));

        filters.add(new Dynacat_Filter__c(Name='Attribute Filter 100', 
                                          Type__c='Attribute', 
                                          Filter__c=attributeMap.get(a100.Id).External_Id__c, 
                                          Order__c=20,
                                          Display_Type__c='Checkbox',
                                          Deployment_Id__c=deployment.Id
                                         ));
        
        filters.add(new Dynacat_Filter__c(Name='Attribute Filter 200', 
                                          Type__c='Attribute', 
                                          Filter__c=attributeMap.get(a200.Id).External_Id__c, 
                                          Order__c=30,
                                          Display_Type__c='Checkbox',
                                          Deployment_Id__c=deployment.Id
                                         ));
        
        filters.add(new Dynacat_Filter__c(Name='Attribute Filter 320', 
                                          Type__c='Attribute', 
                                          Filter__c=attributeMap.get(a320.Id).External_Id__c, 
                                          Order__c=30,
                                          Display_Type__c='Picklist',
                                          Deployment_Id__c=deployment.Id
                                         ));

        filters.add(new Dynacat_Filter__c(Name='Field Filter Multipicklist', 
                                          Type__c='Field', 
                                          Filter__c='Industries__c', 
                                          Order__c=40,
                                          Display_Type__c='Checkbox',
                                          Deployment_Id__c=deployment.Id,
                                          Valid_Picklist_Values__c='Retail,Health & Life Sciences, Communications, Agriculture'
                                         ));

        filters.add(new Dynacat_Filter__c(Name='Field Filter Checkbox', 
                                          Type__c='Field', 
                                          Filter__c='Recommended__c', 
                                          Order__c=50,
                                          Display_Type__c='Radio Button',
                                          Deployment_Id__c=deployment.Id,
                                          Checked_Label__c='Recommended',
                                          Unchecked_Label__c='Not Recommended'
                                         ));
        
        filters.add(new Dynacat_Filter__c(Name='Field Filter Date', 
                                          Type__c='Field', 
                                          Filter__c='Launch_Date__c', 
                                          Order__c=60,
                                          Display_Type__c='Date',
                                          Deployment_Id__c=deployment.Id
                                         ));
        
        filters.add(new Dynacat_Filter__c(Name='Field Filter Range', 
                                          Type__c='Field', 
                                          Filter__c='Price__c', 
                                          Order__c=70,
                                          Display_Type__c='Range',
                                          Deployment_Id__c=deployment.Id,
                                          Min__c=50,
                                          Max__c=150
                                         ));
        
        insert(filters);    
        
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
    
    @isTest static void AttSelector_GetActiveAttributes() {
        Dynacat_Product__c p1 = [SELECT Id FROM Dynacat_Product__c WHERE Name='Product 1'];
        
        Test.startTest();
        String attributes = DynacatAttSelectorController.getActiveAttributes(p1.Id, 'Dynacat_Product__c', 'Dynacat_Product__c');
        DynacatAttSelectorController.Response resp = (DynacatAttSelectorController.Response)JSON.deserialize(attributes, DynacatAttSelectorController.Response.class);
        System.assertEquals(4, resp.savedAttributes.size());
        Test.stopTest();
        
        System.debug('AttSelector_GetActiveAttributes - Attributes: '+attributes);
    }
    
    @isTest static void AttSelector_SaveRecordAttributes() {
        Dynacat_Attribute__c a1 = [SELECT External_Id__c FROM Dynacat_Attribute__c WHERE Name = 'Attribute 1.1.1'];
        Dynacat_Attribute__c a2 = [SELECT External_Id__c FROM Dynacat_Attribute__c WHERE Name = 'Attribute 3.2.1'];
        Dynacat_Attribute__c a3 = [SELECT External_Id__c FROM Dynacat_Attribute__c WHERE Name = 'Attribute 2.1'];
        List<String> atts = new List<String>{a1.External_Id__c, a2.External_Id__c, a3.External_Id__c};
        Dynacat_Product__c p1 = [SELECT Id FROM Dynacat_Product__c WHERE Name='Product 1'];
        
        Test.startTest();
        Boolean result = DynacatAttSelectorController.saveRecordAttributes(JSON.serialize(atts), p1.Id, 'Dynacat_Product__c', 'Dynacat_Product__c');
        String attributes = DynacatAttSelectorController.getActiveAttributes(p1.Id, 'Dynacat_Product__c', 'Dynacat_Product__c');
        DynacatAttSelectorController.Response resp = (DynacatAttSelectorController.Response)JSON.deserialize(attributes, DynacatAttSelectorController.Response.class);
        System.assertEquals(true, result);
        System.assertEquals(3, resp.savedAttributes.size());
        Test.stopTest();
        
        System.debug('AttSelector_SaveRecordAttributes - Attributes: '+attributes);
    }
    
    @isTest static void CatalogFilters_GetActiveAttributes() {
        
        Test.startTest();
        String attributes = DynacatCatalogFiltersController.getActiveAttributes('Test Deployment');
        DynacatCatalogFiltersController.Response resp = (DynacatCatalogFiltersController.Response)JSON.deserialize(attributes, DynacatCatalogFiltersController.Response.class);
        System.assertEquals(8, resp.attributeList.size());
        Test.stopTest();
        
        System.debug('CatalogFilters_GetActiveAttributes - Attributes: '+attributes);   
    }
    
    @isTest static void CatalogController_GetActiveRecords() {

        Test.startTest();
        String records = DynacatCatalogController.getActiveRecords(null, 'Dynacat_Product__c', 'IsActive__c', 'Test Deployment', 'Name ASC');
        DynacatCatalogController.CatalogResponse resp = (DynacatCatalogController.CatalogResponse)JSON.deserialize(records, DynacatCatalogController.CatalogResponse.class);
        System.assertEquals(2, resp.records.size());
        Test.stopTest();
    }
    
    @isTest static void ServerCatalogController_GetDefaultAndFilteredRecords() {
        
        Test.startTest();
        String defaultRecords = DynacatServerCatalogController.getDefaultRecords(null, 'Dynacat_Product__c', 'IsActive__c', 'Test Deployment', 10, 'Name ASC');
        DynacatServerCatalogController.CatalogResponse resp = (DynacatServerCatalogController.CatalogResponse)JSON.deserialize(defaultRecords, DynacatServerCatalogController.CatalogResponse.class);
        System.assertEquals(2, resp.count);
        
        Map<String, DynacatServerCatalogController.Filter> filters = new Map<String, DynacatServerCatalogController.Filter>();
        
        DynacatServerCatalogController.Filter f1 = new DynacatServerCatalogController.Filter();
        f1.name = 'Industries__c';
        f1.type = 'MULTIPICKLIST';
        f1.filterType = 'checkbox';
        f1.values = new List<String>{ 'Health & Life Sciences' };        
        filters.put('Industries__c', f1);
                
        List<Dynacat_Attribute__c> attributes = [SELECT Level__c, External_Id__c FROM Dynacat_Attribute__c WHERE Name LIKE 'Attribute 1%'];
        String rootExternalId = '';
        List<String> attributeValues = new List<String>();
        for(Dynacat_Attribute__c attrib : attributes) {
            if(attrib.Level__c == 0) { 
                rootExternalId = attrib.External_Id__c;
            } else {
                attributeValues.add(attrib.External_Id__c);
            }
        }     
        DynacatServerCatalogController.Filter f2 = new DynacatServerCatalogController.Filter();
        f2.name = rootExternalId;
        f2.type = 'attribute';
        f2.filterType = 'checkbox';
        f2.values = attributeValues;
        f2.lookupFieldName = 'Dynacat_Product__c';
        filters.put(rootExternalId, f2);        
        
        DynacatServerCatalogController.Filter f3 = new DynacatServerCatalogController.Filter();
        f3.name = 'Price__c';
        f3.type = 'CURRENCY';
        f3.filterType = 'range';
        f3.range = new DynacatServerCatalogController.RangeFilter();
        f3.range.start = 90;
        f3.range.finish = 120;
        filters.put('Price__c', f3);

        DynacatServerCatalogController.Filter f4 = new DynacatServerCatalogController.Filter();
        f4.name = 'Launch_Date__c';
        f4.type = 'DATE';
        f4.filterType = 'date-range';
        f4.dateRange = new DynacatServerCatalogController.DateFilter();
        DateTime start = DateTime.now().addDays(-5);
        DateTime finish = DateTime.now().addDays(5);
        f4.dateRange.start = start.format('yyyy-MM-dd');
        f4.dateRange.finish = finish.format('yyyy-MM-dd');
        System.debug('**START: '+f4.dateRange.start);
        filters.put('Launch_Date__c', f4);

        DynacatServerCatalogController.Filter f5 = new DynacatServerCatalogController.Filter();
        f5.name = 'Recommended__c';
        f5.type = 'BOOLEAN';
        f5.filterType = 'single-select';
        f5.values = new List<String>{'false'};
        filters.put('Recommended__c', f5);

        String filteredRecords = DynacatServerCatalogController.getFilteredRecords(JSON.serialize(resp.soql), JSON.serialize(filters), JSON.serialize(resp.config));
        DynacatServerCatalogController.CatalogResponse resp2 = (DynacatServerCatalogController.CatalogResponse)JSON.deserialize(filteredRecords, DynacatServerCatalogController.CatalogResponse.class);
        System.assertEquals(1, resp2.count);
        System.debug('*** FILTERED RESPONSE: '+filteredRecords);
        System.debug('*** FILTERED RESPONSE COUNT: '+resp2.count);
        
        Test.stopTest();
    }
    
    @isTest static void ServerCatalogController_GetNextRecords() {
        
        Test.startTest();
        String defaultRecords = DynacatServerCatalogController.getDefaultRecords(null, 'Dynacat_Product__c', 'IsActive__c', 'Test Deployment', 1, 'Name ASC');
        DynacatServerCatalogController.CatalogResponse resp = (DynacatServerCatalogController.CatalogResponse)JSON.deserialize(defaultRecords, DynacatServerCatalogController.CatalogResponse.class);
        System.assertEquals(2, resp.count);
        System.assertEquals(1, resp.records.size());
        
        String nextRecords = DynacatServerCatalogController.getNextRecords(JSON.serialize(resp.soql), 1, JSON.serialize(resp.config));
        DynacatServerCatalogController.CatalogResponse resp2 = (DynacatServerCatalogController.CatalogResponse)JSON.deserialize(nextRecords, DynacatServerCatalogController.CatalogResponse.class);
        System.assertEquals(1, resp2.records.size());
        
        Test.stopTest();
        
    }

    @isTest static void TileWallController_GetDefaultAndFilteredRecords() {

        Test.startTest();
        String defaultRecords = DynacatTileWallController.getDefaultRecords(new List<String>{'Name', 'Short_Description__c'}, null, null, 'Test Config', 'Test Deployment', 'Name ASC', 10);
        DynacatTileWallController.CatalogResponse resp = (DynacatTileWallController.CatalogResponse)JSON.deserialize(defaultRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(2, resp.count);
        
        Map<String, DynacatTileWallController.Filter> filters = new Map<String, DynacatTileWallController.Filter>();
        
        DynacatTileWallController.Filter f1 = new DynacatTileWallController.Filter();
        f1.name = 'Industries__c';
        f1.type = 'MULTIPICKLIST';
        f1.filterType = 'checkbox';
        f1.values = new List<String>{ 'Health & Life Sciences' };        
        filters.put('Industries__c', f1);
                
        List<Dynacat_Attribute__c> attributes = [SELECT Level__c, External_Id__c FROM Dynacat_Attribute__c WHERE Name LIKE 'Attribute 1%'];
        String rootExternalId = '';
        List<String> attributeValues = new List<String>();
        for(Dynacat_Attribute__c attrib : attributes) {
            if(attrib.Level__c == 0) { 
                rootExternalId = attrib.External_Id__c;
            } else {
                attributeValues.add(attrib.External_Id__c);
            }
        }     
        DynacatTileWallController.Filter f2 = new DynacatTileWallController.Filter();
        f2.name = rootExternalId;
        f2.type = 'attribute';
        f2.filterType = 'checkbox';
        f2.values = attributeValues;
        f2.lookupFieldName = 'Dynacat_Product__c';
        filters.put(rootExternalId, f2);        
        
        DynacatTileWallController.Filter f3 = new DynacatTileWallController.Filter();
        f3.name = 'Price__c';
        f3.type = 'CURRENCY';
        f3.filterType = 'range';
        f3.range = new DynacatTileWallController.RangeFilter();
        f3.range.start = 90;
        f3.range.finish = 120;
        filters.put('Price__c', f3);

        DynacatTileWallController.Filter f4 = new DynacatTileWallController.Filter();
        f4.name = 'Launch_Date__c';
        f4.type = 'DATE';
        f4.filterType = 'date-range';
        f4.dateRange = new DynacatTileWallController.DateFilter();
        DateTime start = DateTime.now().addDays(-5);
        DateTime finish = DateTime.now().addDays(5);
        f4.dateRange.start = start.format('yyyy-MM-dd');
        f4.dateRange.finish = finish.format('yyyy-MM-dd');
        System.debug('**START: '+f4.dateRange.start);
        filters.put('Launch_Date__c', f4);

        DynacatTileWallController.Filter f5 = new DynacatTileWallController.Filter();
        f5.name = 'Recommended__c';
        f5.type = 'BOOLEAN';
        f5.filterType = 'single-select';
        f5.values = new List<String>{'false'};
        filters.put('Recommended__c', f5);

        String filteredRecords = DynacatTileWallController.getFilteredRecords(JSON.serialize(resp.soql), JSON.serialize(filters), null);
        DynacatTileWallController.CatalogResponse resp2 = (DynacatTileWallController.CatalogResponse)JSON.deserialize(filteredRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(1, resp2.count);
        System.debug('*** FILTERED RESPONSE: '+filteredRecords);
        System.debug('*** FILTERED RESPONSE COUNT: '+resp2.count);
        
        Test.stopTest();
    }
    
    @isTest static void TileWallController_GetNextRecords() {
        
        Test.startTest();
        String defaultRecords = DynacatTileWallController.getDefaultRecords(new List<String>{'Name', 'Short_Description__c'}, null, null, 'Test Config', 'Test Deployment', 'Name ASC', 1);
        DynacatTileWallController.CatalogResponse resp = (DynacatTileWallController.CatalogResponse)JSON.deserialize(defaultRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(2, resp.count);
        System.assertEquals(1, resp.records.size());
        
        List<Dynacat_Product__c> prods = [SELECT Id FROM Dynacat_Product__c WHERE Name LIKE '%Product%'];
        List<Id> fixedSearchResults = new List<Id>();
        for(Dynacat_Product__c prod : prods) fixedSearchResults.add(prod.Id);
        Test.setFixedSearchResults(fixedSearchResults);
        
        String nextRecordsSearch = DynacatTileWallController.getNextRecords(JSON.serialize(resp.soql), 1, '%prod%');
        DynacatTileWallController.CatalogResponse resp2 = (DynacatTileWallController.CatalogResponse)JSON.deserialize(nextRecordsSearch, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(1, resp2.records.size());

        String nextRecords = DynacatTileWallController.getNextRecords(JSON.serialize(resp.soql), 1, null);
        resp2 = (DynacatTileWallController.CatalogResponse)JSON.deserialize(nextRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(1, resp2.records.size());
        
        Test.stopTest();
        
    }
    
    @isTest static void TileWallController_SearchRecords() {
        
        Test.startTest();
        String defaultRecords = DynacatTileWallController.getDefaultRecords(new List<String>{'Name', 'Short_Description__c'}, null, null, 'Test Config', 'Test Deployment', 'Name ASC', 10);
        DynacatTileWallController.CatalogResponse resp = (DynacatTileWallController.CatalogResponse)JSON.deserialize(defaultRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(2, resp.count);
        System.assertEquals(2, resp.records.size());
        
        Dynacat_Product__c p2 = [SELECT Id FROM Dynacat_Product__c WHERE Name LIKE '%Improved'];
        List<Id> fixedSearchResults = new List<Id>{p2.Id};
        Test.setFixedSearchResults(fixedSearchResults);

        String searchRecords = DynacatTileWallController.searchRecords('improv',JSON.serialize(resp.soql));
        DynacatTileWallController.CatalogResponse resp2 = (DynacatTileWallController.CatalogResponse)JSON.deserialize(searchRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(1, resp2.records.size());
        
        Map<String, DynacatTileWallController.Filter> filters = new Map<String, DynacatTileWallController.Filter>();

        DynacatTileWallController.Filter f1 = new DynacatTileWallController.Filter();
        f1.name = 'Industries__c';
        f1.type = 'MULTIPICKLIST';
        f1.filterType = 'checkbox';
        f1.values = new List<String>{ 'Communications' };        
        filters.put('Industries__c', f1);
        
        String filteredRecords = DynacatTileWallController.getFilteredRecords(JSON.serialize(resp.soql), JSON.serialize(filters), 'improv');
        resp2 = (DynacatTileWallController.CatalogResponse)JSON.deserialize(filteredRecords, DynacatTileWallController.CatalogResponse.class);
        System.assertEquals(1, resp2.count);
        System.debug('*** FILTERED RESPONSE: '+filteredRecords);
        System.debug('*** FILTERED RESPONSE COUNT: '+resp2.count);


        Test.stopTest();
        
    }
    
    @isTest static void Dynacat_PicklistDeployments() {
        Test.startTest();
        
        Dynacat_Picklist_Deployments deployments = new Dynacat_Picklist_Deployments();
        VisualEditor.DynamicPicklistRows deploymentRows = deployments.getValues();
        VisualEditor.DataRow deploymentDefault = deployments.getDefaultValue();
        
        Test.stopTest();
    }

}