@isTest
public class PropertySearchControllerTest {
    // @testSetup runs before all test methods and commits data so Database.query() can find it
    @testSetup
    static void setupTestData() {
        // Create two properties with different statuses and prices
        // Price__c is the field queried by the controller — Sale_Price__c is a different field
        Property__c prop1 = new Property__c(
            Name = 'Test Property',
            Status__c = 'Active',
            Sale_Price__c = 350000,
            Price__c = 350000
        );
        Property__c prop2 = new Property__c(
            Name = 'Another Property',
            Status__c = 'Sold',
            Sale_Price__c = 450000,
            Price__c = 450000
        );
        insert new List<Property__c>{ prop1, prop2 };
    }

    @isTest
    static void testSearchProperties() {
        Test.startTest();

        // Test 1 — Search by Status = Active
        // Should return only prop1 since prop2 is Sold
        List<Property__c> activeResults = PropertySearchController.searchProperties('Active', null, null, null);

        // Test 2 — Search by Min Price = 400000
        // Should return only prop2 since prop1 is below 400000
        List<Property__c> minPriceResults = PropertySearchController.searchProperties(null, 400000, null, null);

        // Test 3 — Search by Max Price = 400000
        // Should return only prop1 since prop2 is above 400000
        List<Property__c> maxPriceResults = PropertySearchController.searchProperties(null, null, 400000, null);

        // Test 4 — Search with no filters
        // Should return both properties
        List<Property__c> allResults = PropertySearchController.searchProperties(null, null, null, null);

        Test.stopTest();

        // Assert Test 1 — Status filter
        System.assertEquals(1, activeResults.size());
        System.assertEquals('Test Property', activeResults[0].Name);

        // Assert Test 2 — Min Price filter
        System.assertEquals(1, minPriceResults.size());
        System.assertEquals('Another Property', minPriceResults[0].Name);

        // Assert Test 3 — Max Price filter
        System.assertEquals(1, maxPriceResults.size());
        System.assertEquals('Test Property', maxPriceResults[0].Name);

        // Assert Test 4 — No filters returns all properties
        System.assertEquals(2, allResults.size());
    }
}
