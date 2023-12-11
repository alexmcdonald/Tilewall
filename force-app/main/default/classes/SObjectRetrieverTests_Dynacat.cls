@isTest
public class SObjectRetrieverTests_Dynacat {

    @isTest static void GetAllObjects() {
        Test.startTest();
        List<SObjectRetriever_Dynacat.Result> results = SObjectRetriever_Dynacat.execute();
        System.assertNotEquals(0, results[0].sobjects.size());
        Test.stopTest();
    }
}