/*
 * Controller class for the dynacatTileWall LWC, which is a mash-up between the dynacatServerCatalog and an old aura-
 * based demo component I built a few years ago. As with the Server version, all the filtering and pagination of target 
 * records is done in APEX.  It should be much more scalable than the original dynacatCatalog LWC, particularly if
 * support enable indexing for the fields being filtered.
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

public class DynacatTileWallController {
    
    @AuraEnabled(cacheable=true)
    public static String getDefaultRecords(List<String> fieldNames, String soqlWhere, String recordId, String config, String deployment, String orderBy, Integer limitResults) {

        //    public static String getDefaultRecords(List<String> fieldNames, String soqlWhere, String recordId, String deployment, String orderBy, Integer limitResults) {

        System.debug('Getting Default Records');
        
        TileWall_Config__c twc = [SELECT Object_API_Name__c FROM TileWall_Config__c WHERE Name = :config];
        
        String objectApiName = null;
        

        Set<String> fields = new Set<String>();
        fields.addAll(fieldNames);

        List<String> whereClauseList = new List<String>(); 

        
        if(String.isBlank(deployment)) {
            
			objectApiName = twc.Object_API_Name__c;
                        
            
            
        } else {
            
            Dynacat_Deployment__c dd = [SELECT Id, Name, Object_API_Name__c FROM Dynacat_Deployment__c WHERE Name=:deployment];
            objectApiName = dd.Object_API_Name__c;
            
            List<Dynacat_Filter__c> filterConfigs = [SELECT Id,
                                                 		Filter__c,
                                                  		Object_API_Name__c,
                                                  		Order__c,
                                                 		Type__c,
                                                 		Display_Type__c
                                                   FROM Dynacat_Filter__c
                                                  WHERE Deployment_Id__c = :dd.Id
                                               ORDER BY Order__c ASC];
            
            Boolean useFields = false;

        	for(Dynacat_Filter__c c : filterConfigs) {
            	if(c.Type__c=='Field') {
                	useFields = true;
                	// Add the field name to the Set of fields to be retrieved in the query
                	fields.add(c.Filter__c);
            	}
        	}
            
        }
        
        String nameField = [SELECT QualifiedApiName FROM FieldDefinition WHERE EntityDefinition.QualifiedApiName = :objectApiName AND IsNameField = TRUE].QualifiedApiName;
        fields.addAll(new Set<String>{'Id',nameField});

            
        if(! String.isBlank(soqlWhere)) {
        	if(! String.isBlank(recordId)) soqlWhere = soqlWhere.replaceAll('(?i)\\{\\{recordid\\}\\}', recordId);
			whereClauseList.add('( ' + soqlWhere + ' )');
        }

        String selectFields = String.join(new List<String>(fields),', ');
        String selectClause = 'SELECT ' + selectFields;
        String fromClause = ' FROM ' + objectApiName;
        String whereClause = (whereClauseList.size() > 0) ? ' WHERE ' + String.join(whereClauseList, ' AND ') : '';
        String orderByClause = (! String.isBlank(orderBy)) ? ' ORDER BY ' + orderBy : '';
        String limitClause = (limitResults != null && limitResults > 0) ? ' LIMIT ' + limitResults : ''; 
        
        Integer count = Database.countQuery('SELECT COUNT() ' + fromClause + whereClause);
        String soqlRecordsQuery = selectClause + fromClause + whereClause + orderByClause + limitClause; 
        System.debug('Soql Query: '+soqlRecordsQuery);
        List<SObject> records = Database.query(soqlRecordsQuery);

        List<Record> recs = new List<Record>();
        
        for(SObject rec : records) {
            Record r = new Record();
            r.id = (String)rec.get('Id');
            r.name = (String)rec.get(nameField);
            r.record = rec;
            recs.add(r);
        }
        
        SOQLElement soql = new SOQLElement();
        soql.selectFields = selectFields;
        soql.nameField = nameField;
        soql.selectClause = selectClause;
        soql.fromObject = objectApiName;
        soql.fromClause = fromClause;
        soql.whereClause = whereClause;
        soql.filteredWhereClause = whereClause;
        soql.orderByClause = orderByClause;
        soql.limitClause = limitClause;
        
        CatalogResponse resp = new CatalogResponse();
        resp.records = recs;
        resp.objectApiName = objectApiName;
        resp.count = count;
        resp.soql = soql;
                
        String jsonResponse = JSON.serialize(resp, true);
        return jsonResponse;

    }
    
    
    @AuraEnabled(cacheable=true)
    public static String getFilteredRecords(String soqlStr, String filtersStr, String queryTerm) {

        SOQLElement soql = (SOQLElement)JSON.deserialize(soqlStr,SOQLElement.class);
        System.debug(soql);
        
        Map<String, Filter> filtersMap = (Map<String, Filter>) JSON.deserialize(filtersStr, Map<String, Filter>.class);

        List<Filter> attributes = new List<Filter>();
        List<Filter> picklists = new List<Filter>();
        List<Filter> booleans = new List<Filter>();
        List<Filter> ranges = new List<Filter>();
        List<Filter> dates = new List<Filter>();
        
        for(String filterKey : filtersMap.keyset()) {
            Filter filter = filtersMap.get(filterKey);
            if(filter.type == 'attribute') {
                attributes.add(filter);
            } else if(new String[]{'PICKLIST','MULTIPICKLIST'}.contains(filter.type)) {
				picklists.add(filter);                
            } else if(filter.type == 'BOOLEAN') {
                booleans.add(filter);
            } else if(new String[]{'DOUBLE','INTEGER','CURRENCY','PERCENT'}.contains(filter.type)) {
                ranges.add(filter);
            } else if(new String[]{'DATE','DATETIME'}.contains(filter.type)) {
                dates.add(filter);
            }           
        }
        
        List<String> filteredWhereClauseList = new List<String>();
        
        // Picklists & Multipicklists
        if(picklists.size() > 0) {
            for(Filter f : picklists) {
                if(f.values != null && f.values.size() > 0) {
                    String w = f.name;
                    w += (f.type == 'PICKLIST') ? ' IN (' : ' INCLUDES (';
                    for(Integer i=0; i<f.values.size(); i++) {
    					if(i>0) w += ',';
                    	w += '\''+f.values[i]+'\'';
					}
					w +=')';
                    filteredWhereClauseList.add(w);
                }
            }            
        }
        
        // Boolean
        if(booleans.size() > 0) {
            for(Filter f : booleans) {
                if(f.values != null && f.values.size() > 0) {
                    String w = f.name + ' IN (' + String.join(f.values, ',') + ')';
                    filteredWhereClauseList.add(w);
                }
            }
        }
        
        // Ranges
        if(ranges.size() > 0) {
            for(Filter f : ranges) {
                if(f.range != null) {
                    if(f.range.start != null) {
                        filteredWhereClauseList.add(f.name + ' >= ' + f.range.start);
                    }
                    if(f.range.finish != null) {
                        filteredWhereClauseList.add(f.name + ' <= ' + f.range.finish);
                    }
                }
            }
        }
        
        // Date Range && DateTime
        if(dates.size() > 0) {
            for(Filter f : dates) {
                if(f.dateRange != null) {
                    if(f.dateRange.start != null) {
                        f.dateRange.start += (f.type=='DATETIME') ? 'T00:00:00Z' : '';
                        filteredWhereClauseList.add(f.name + ' >= ' + f.dateRange.start);
                    }
                    if(f.dateRange.finish != null) {
                        f.dateRange.finish += (f.type=='DATETIME') ? 'T00:00:00Z' : '';
                        filteredWhereClauseList.add(f.name + ' <= ' + f.dateRange.finish);
                    }
                }
            }
        }
        
        // Build Attribute Joined Queries and add them to the Where Clause List
        List<String> attWhereClauseList = new List<String>();
        if(attributes.size() > 0) {
            for(Filter f : attributes) {
                System.debug('Attribute Filter: '+f.name + ', Values: '+f.values);
                if(f.values != null && f.values.size() > 0) {
                    String w = 'Id IN (SELECT ' + f.lookupFieldName + ' FROM Dynacat_Record_Attribute__c WHERE Attribute_UID__c IN (';
                    for(Integer i=0; i<f.values.size(); i++) {
    					if(i>0) w += ',';
                    	w += '\''+f.values[i]+'\'';
					}
					w +='))';
                    filteredWhereClauseList.add(w);
                }
            }
        }
        
        String filteredWhereClause = (soql.whereClause != null && soql.whereClause != '') ? soql.whereClause : '';
        if(filteredWhereClauseList.size() > 0) {
            filteredWhereClause += (filteredWhereClause != '') ? ' AND ' : ' WHERE ';
            filteredWhereClause += String.join(filteredWhereClauseList, ' AND ');
        }
        
		Integer count;
        List<SObject> records;
        if(queryTerm != null && queryTerm.length() > 1) {

        	String countQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(Id ' + filteredWhereClause + ')';
        	List<List<SObject>> countList = search.query(countQuery);
        	count = (countList.size() > 0) ? countList[0].size() : -1;

        	String searchQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(' + soql.selectFields + filteredWhereClause + soql.orderByClause + soql.limitClause + ')'; 
        	System.debug('SOSL Search Query: ' + searchquery);
        
        	List<List<SObject>> recordsList=search.query(searchQuery);

			records = null;       
        	if(recordsList.size() > 0) {
            	records = recordsList[0];
        	}
                        
        } else {

            System.debug('Query Term: '+queryTerm);

            count = Database.countQuery('SELECT COUNT() ' + soql.fromClause + filteredWhereClause);
        	String soqlRecordsQuery = soql.selectClause + soql.fromClause + filteredWhereClause + soql.orderByClause + soql.limitClause;
        	System.debug('Filtered Soql Query: '+soqlRecordsQuery);
        	records = Database.query(soqlRecordsQuery);
            
        }
        
        List<Record> recs = new List<Record>();
        
        for(SObject rec : records) {
            Record r = new Record();
            r.id = (String)rec.get('Id');
            r.name = (String)rec.get(soql.nameField);
            r.record = rec;
            recs.add(r);
        }
                
        CatalogResponse resp = new CatalogResponse();
        resp.records = recs;
        resp.count = count;
        soql.filteredWhereClause = filteredWhereClause;
        resp.soql = soql;
        
        System.debug(count);
        System.debug(recs);

        String jsonResponse = JSON.serialize(resp, true);
        return jsonResponse;
        

    }
    
    @AuraEnabled(cacheable=true)
    public static String searchRecords(String queryTerm, String soqlStr) {
        System.debug('Search!');
        SOQLElement soql = (SOQLElement)JSON.deserialize(soqlStr,SOQLElement.class);
        System.debug(soql);

        String countQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(Id ' + soql.filteredWhereClause + ')';
        List<List<SObject>> countList = search.query(countQuery);

        Integer count = (countList.size() > 0) ? countList[0].size() : -1;

        String searchQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(' + soql.selectFields + soql.filteredWhereClause + soql.orderByClause + soql.limitClause + ')'; 
        System.debug('SOSL Search Query: ' + searchquery);
        
        List<List<SObject>> recordsList=search.query(searchQuery);

		List<SObject> records = null;       

        if(recordsList.size() > 0) {
            records = recordsList[0];
        }

        List<Record> recs = new List<Record>();
        
        for(SObject rec : records) {
            Record r = new Record();
            r.id = (String)rec.get('Id');
            r.name = (String)rec.get(soql.nameField);
            r.record = rec;
            recs.add(r);
        }
        
        CatalogResponse resp = new CatalogResponse();
        resp.records = recs;
        resp.count = count;
        
        String jsonResponse = JSON.serialize(resp, true);
        return jsonResponse;
    }
    
    @AuraEnabled(cacheable=true)
    public static String getNextRecords(String soqlStr, Integer offset, String queryTerm) {
        System.debug('Next!');
        SOQLElement soql = (SOQLElement)JSON.deserialize(soqlStr,SOQLElement.class);
        System.debug(soql);

        Integer count;
        List<SObject> records;

        if(queryTerm != null && queryTerm.length() > 1) {

        	String countQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(Id ' + soql.filteredWhereClause + ')';
        	List<List<SObject>> countList = search.query(countQuery);
        	count = (countList.size() > 0) ? countList[0].size() : -1;

        	String searchQuery = 'FIND \'' + queryTerm + '*\' IN ALL FIELDS RETURNING ' + soql.fromObject + '(' + soql.selectFields + soql.filteredWhereClause + soql.orderByClause + soql.limitClause + ' OFFSET ' + offset + ')'; 
        	System.debug('SOSL Search Query: ' + searchquery);
        
        	List<List<SObject>> recordsList=search.query(searchQuery);

			records = null;       
        	if(recordsList.size() > 0) {
            	records = recordsList[0];
        	}

        } else {
            
        	count = Database.countQuery('SELECT COUNT() ' + soql.fromClause + soql.filteredWhereClause);
        	String soqlRecordsQuery = soql.selectClause + soql.fromClause + soql.filteredWhereClause + soql.orderByClause + soql.limitClause + ' OFFSET ' + offset;
        	System.debug('Next Soql Query: '+soqlRecordsQuery);
        	records = Database.query(soqlRecordsQuery);
            
        }
        
        List<Record> recs = new List<Record>();
        
        for(SObject rec : records) {
            Record r = new Record();
            r.id = (String)rec.get('Id');
            r.name = (String)rec.get(soql.nameField);
            r.record = rec;
            recs.add(r);
        }
        
        CatalogResponse resp = new CatalogResponse();
        resp.records = recs;
        resp.count = count;
        
        String jsonResponse = JSON.serialize(resp, true);
        return jsonResponse;
    }
        
    
    
    public class CatalogResponse {
        public List<Record> records;
        public String objectApiName;
        public Integer count;
        public SOQLElement soql;
    }
    
    
    public class Record {
		public String id;
        private String name;
        private SObject record;
    }
    
    
    public class SOQLElement {
        public String selectClause;
        public String selectFields;
        public String nameField;
        public String fromClause;
        public String fromObject;
        public String whereClause;
        public String filteredWhereClause;
        public String orderByClause;
        public String limitClause;
    }
    
    
    public class Filter {
        public String name;
        public String filterType;
        public String type;
        public List<String> values;
        public String lookupFieldName;
        public RangeFilter range;
        public DateFilter dateRange;
        
    }
    
    public class RangeFilter {
        public Decimal start;
        public Decimal finish;
    }
    
    public class DateFilter {
        public String start;
        public String finish;
    }
        
}