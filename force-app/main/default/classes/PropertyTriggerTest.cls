@isTest
public class PropertyTriggerTest {
    @isTest
    static void testCommissionCreation() {
        // 1. Arrange - Creat a test records
        Agent__c agent = new Agent__c();
        agent.Name = 'Test Agent';
        agent.Commission_Rate__c = 3.0;
        insert agent;

        Property__c prop = new Property__c();
        prop.Name = '987 Real Street';
        prop.Status__c = 'Active';
        prop.Agent__c = agent.Id;
        prop.Sale_Price__c = 500000;
        insert prop;

        // 2. Act - update Property status which fires the trigger
        Test.startTest();
        prop.Status__c = 'Sold';
        update prop;
        Test.stopTest();

        // 3. Assert - Check the Commission record
        Commission__c commResult = [
            SELECT Property__c, Agent__c, Commission_Amount__c, Name
            FROM Commission__c
            WHERE Property__c = :prop.Id
            LIMIT 1
        ];
        System.assertEquals(prop.Id, commResult.Property__c);
        System.assertEquals(agent.Id, commResult.Agent__c);
        System.assertEquals(prop.Sale_Price__c * agent.Commission_Rate__c / 100, commResult.Commission_Amount__c);
    }
}
