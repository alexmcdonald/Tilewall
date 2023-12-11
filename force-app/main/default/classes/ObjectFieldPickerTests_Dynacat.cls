@isTest
private class ObjectFieldPickerTests_Dynacat {

    @isTest static void GetObjects() {
    
        Test.startTest();
        String objectsStr = ObjectFieldPickerController_Dynacat.getObjects();
        List<PicklistValue_Dynacat> objectsList = (List<PicklistValue_Dynacat>)JSON.deserialize(objectsStr, List<PicklistValue_Dynacat>.class);
        System.assertNotEquals(0, objectsList.size());        
        Test.stopTest();
        
    }
    
    @isTest static void GetFields() {
        
        Test.startTest();
        String fieldsStr = ObjectFieldPickerController_Dynacat.getFields('Account', 'PICKLIST,REFERENCE');
        ObjectFieldPickerController_Dynacat.ObjectFieldsResponse resp = (ObjectFieldPickerController_Dynacat.ObjectFieldsResponse)JSON.deserialize(fieldsStr, ObjectFieldPickerController_Dynacat.ObjectFieldsResponse.class);
        System.assertNotEquals(0, resp.fields.size());
        
        ObjectFieldPickerController_Dynacat.FieldDescribe industryField = resp.fieldMap.get('Industry');
        System.assertEquals('PICKLIST', industryField.type);
        
        Test.stopTest();
    }
}