public with sharing class PropertySearchController {
    // cacheable=true tells Salesforce this method only reads data and never modifies it
    // This allows the results to be cached for better performance
    // Required for methods called via @wire in LWC
    @AuraEnabled(cacheable=true)
    public static List<Property__c> searchProperties(
        String status,
        Decimal minPrice,
        Decimal maxPrice,
        Integer bedrooms
    ) {
        // Start with a base query that always returns results
        // WHERE Id != null is always true — gives us a safe base to append AND conditions
        String query = 'SELECT Id, Name, Price__c, Bedrooms__c, Status__c, Address__c FROM Property__c WHERE Id != null';

        // Only add Status filter if the user provided a value
        // String.escapeSingleQuotes prevents SOQL injection
        if (status != null && status != '') {
            query += ' AND Status__c = \'' + String.escapeSingleQuotes(status) + '\'';
        }

        // Only add Min Price filter if the user provided a value
        // Using string concatenation for consistent behavior in all contexts
        if (minPrice != null) {
            query += ' AND Price__c >= ' + minPrice;
        }

        // Only add Max Price filter if the user provided a value
        if (maxPrice != null) {
            query += ' AND Price__c <= ' + maxPrice;
        }

        // Only add Bedrooms filter if the user provided a value
        if (bedrooms != null) {
            query += ' AND Bedrooms__c = ' + bedrooms;
        }

        // Execute the dynamically built query and return results
        // Database.query() is used instead of bracket syntax for dynamic SOQL
        // Cast the result to List<Property__c> since Database.query returns a generic List
        return (List<Property__c>) Database.query(query);
    }
}
