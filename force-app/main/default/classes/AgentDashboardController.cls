public with sharing class AgentDashboardController {
    // Wrapper class to hold all dashboard stats in one object
    // @AuraEnabled on each property makes them accessible from the LWC
    public class AgentStats {
        @AuraEnabled
        public Integer activeListings;
        @AuraEnabled
        public Integer totalOffers;
        @AuraEnabled
        public Decimal commissionYTD;
    }

    // cacheable=true — this method only reads data, never modifies it
    // Required for @wire calls in LWC and improves performance through caching
    @AuraEnabled(cacheable=true)
    public static AgentStats getAgentStats(Id agentId) {
        // Create a new AgentStats instance to hold all the calculated values
        AgentStats stats = new AgentStats();

        // COUNT() returns an Integer directly — no AggregateResult needed
        // Counts all active Property records assigned to this Agent
        Integer activeListings = [
            SELECT COUNT()
            FROM Property__c
            WHERE Agent__c = :agentId AND Status__c = 'Active'
        ];

        // Counts all Offers on Properties assigned to this Agent
        // Uses a subquery to find all Properties belonging to this Agent first
        // then counts Offers related to those Properties
        Integer totalOffers = [
            SELECT COUNT()
            FROM Offer__c
            WHERE
                Property__c IN (
                    SELECT Id
                    FROM Property__c
                    WHERE Agent__c = :agentId
                )
        ];

        // SUM requires AggregateResult — there is no shortcut like COUNT()
        // Returns one row containing the sum of all Commission Amounts for this Agent
        AggregateResult[] results = [
            SELECT SUM(Commission_Amount__c) total
            FROM Commission__c
            WHERE Agent__c = :agentId
        ];

        // Null check required — if the Agent has no Commission records
        // results[0].get('total') returns null instead of 0
        // Ternary operator: if not null cast to Decimal, otherwise default to 0
        Decimal commissionYTD = results[0].get('total') != null ? (Decimal) results[0].get('total') : 0;

        // Assign all calculated values to the stats wrapper object
        stats.activeListings = activeListings;
        stats.totalOffers = totalOffers;
        stats.commissionYTD = commissionYTD;

        // Return the fully populated wrapper object to the LWC
        return stats;
    }
}
