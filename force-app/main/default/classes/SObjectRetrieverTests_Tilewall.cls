@isTest
public class SObjectRetrieverTests_Tilewall {

    @isTest static void GetAllObjects() {
        Test.startTest();
        List<SObjectRetriever_Tilewall.Result> results = SObjectRetriever_Tilewall.execute();
        System.assertNotEquals(0, results[0].sobjects.size());
        Test.stopTest();
    }
}