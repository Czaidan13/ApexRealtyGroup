@isTest
public class AgentDashboardControllerTest {
    @isTest
    static void testGetAgentStats() {
        // 1. Arrange - Create test data in the correct order based on dependencies

        // Create a test Agent with a commission rate
        Agent__c agent = new Agent__c(Name = 'Test Agent', Commission_Rate__c = 2.5);
        insert agent;

        // Create an Active Property linked to the Agent
        // Sale_Price__c set to simulate a property that has been valued
        Property__c prop = new Property__c(
            Name = 'Test Property',
            Status__c = 'Active',
            Agent__c = agent.Id,
            Sale_Price__c = 100000
        );
        insert prop;

        // Create an Offer linked to the Property
        // This tests that totalOffers count returns correctly
        Offer__c offer1 = new Offer__c(
            Name = 'Test Offer',
            Property__c = prop.Id,
            Offer_Amount__c = 120000,
            Status__c = 'Pending'
        );
        insert offer1;

        // Create a Commission linked to the Agent and Property
        // Commission_Amount__c set to test the SUM aggregate in the controller
        Commission__c comm = new Commission__c(Property__c = prop.Id, Agent__c = agent.Id, Commission_Amount__c = 2500);
        insert comm;

        // 2. Act - Call the controller method directly
        // AgentDashboardController.AgentStats references the inner wrapper class
        Test.startTest();
        AgentDashboardController.AgentStats stats = AgentDashboardController.getAgentStats(agent.Id);
        Test.stopTest();

        // 3. Assert - Verify all three stats returned correctly
        // One Active Property linked to this Agent
        System.assertEquals(1, stats.activeListings);
        // One Offer on a Property linked to this Agent
        System.assertEquals(1, stats.totalOffers);
        // Commission Amount should match what was inserted
        System.assertEquals(2500, stats.commissionYTD);
    }
}
