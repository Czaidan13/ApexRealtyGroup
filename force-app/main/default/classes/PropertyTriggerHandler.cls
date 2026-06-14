public with sharing class PropertyTriggerHandler {
    public static void handleAfterUpdate(List<Property__c> newProps, Map<Id, Property__c> oldMap) {
        // Step 1 - Collect unique Agent Ids from all Properties being updated
        // Using a Set ensures no duplicate Ids even if multiple Properties share the same Agent
        Set<Id> agentIds = new Set<Id>();
        for (Property__c prop : newProps) {
            // Only add the Agent Id if one is assigned to this Property
            if (prop.Agent__c != null) {
                agentIds.add(prop.Agent__c);
            }
        }

        // Step 2 - Query all Agents at once and store in a Map keyed by Agent Id
        // This avoids running a SOQL query inside the loop — one query handles all Agents
        Map<Id, Agent__c> agentMap = new Map<Id, Agent__c>(
            [SELECT Id, Name, Commission_Rate__c FROM Agent__c WHERE Id IN :agentIds]
        );

        // Step 3 - List to collect all Commission records to insert in one bulk DML statement
        List<Commission__c> commissionToBeInserted = new List<Commission__c>();

        // Step 4 - Loop through all updated Properties
        for (Property__c prop : newProps) {
            // Get the old version of this Property before the update
            Property__c oldProperty = oldMap.get(prop.Id);

            // Check if the Status just changed to Sold — not already Sold before the update
            if (prop.Status__c == 'Sold' && oldProperty.Status__c != 'Sold') {
                // Look up the Agent assigned to this Property using the Map
                // This is instant — no additional SOQL query needed
                Agent__c agent = agentMap.get(prop.Agent__c);

                // Only create a Commission if an Agent is assigned to this Property
                // Prevents a null pointer error if the Agent field is blank
                if (agent != null) {
                    // Create a new Commission record
                    // Commission Amount = Sale Price x Commission Rate / 100
                    Commission__c newCommission = new Commission__c(
                        Property__c = prop.Id,
                        Agent__c = agent.Id,
                        Commission_Amount__c = prop.Sale_Price__c * agent.Commission_Rate__c / 100
                    );

                    // Add to the list — do not insert yet
                    commissionToBeInserted.add(newCommission);
                }
            }
        }

        // Step 5 - Insert all Commission records in a single bulk DML statement
        // Only runs if there are Commission records to insert
        if (!commissionToBeInserted.isEmpty()) {
            insert commissionToBeInserted;
        }
    }
}
