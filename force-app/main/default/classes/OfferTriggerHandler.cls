public with sharing class OfferTriggerHandler {
    public static void handleAfterUpdate(List<Offer__c> newOffers, Map<Id, Offer__c> oldMap) {
        // List to store the Property Ids related to Offers that were just accepted
        List<Id> acceptedPropertyIds = new List<Id>();

        // Map to store the accepted Offer Amount for each Property Id
        // Key: Property Id, Value: Accepted Offer Amount
        Map<Id, Decimal> propertyToAcceptedAmount = new Map<Id, Decimal>();

        // Loop through all Offers that were updated in this transaction
        for (Offer__c offer : newOffers) {
            // Get the old version of this Offer before the update
            Offer__c oldOffer = oldMap.get(offer.Id);

            // Check if the Status just changed to Accepted — not already Accepted before
            if (offer.Status__c == 'Accepted' && oldOffer.Status__c != 'Accepted') {
                // Store the accepted Offer Amount mapped to its Property Id
                // This lets us reference the amount later without needing another query
                propertyToAcceptedAmount.put(offer.Property__c, offer.Offer_Amount__c);

                // Add the related Property Id to our list for querying later
                acceptedPropertyIds.add(offer.Property__c);
            }
        }

        // Only proceed if at least one Offer was accepted — avoids unnecessary queries
        if (!acceptedPropertyIds.isEmpty()) {
            // Query all Properties related to the accepted Offers
            List<Property__c> propertiesToUpdate = [
                SELECT Id, Status__c, Sale_Price__c
                FROM Property__c
                WHERE Id IN :acceptedPropertyIds
            ];

            // Update each Property — set status to Under Contract and stamp the accepted Offer Amount as the Sale Price
            for (Property__c prop : propertiesToUpdate) {
                prop.Status__c = 'Under Contract';

                // Look up the accepted Offer Amount from the Map using the Property Id as the key
                prop.Sale_Price__c = propertyToAcceptedAmount.get(prop.Id);
            }

            // Query all remaining open Offers on those Properties excluding the accepted one
            // These Offers are no longer valid since another Offer was accepted
            List<Offer__c> offersToUpdate = [
                SELECT Id, Status__c
                FROM Offer__c
                WHERE Property__c IN :acceptedPropertyIds AND Status__c != 'Accepted'
            ];

            // Set all other open Offers to Withdrawn since the property is now under contract
            for (Offer__c ofr : offersToUpdate) {
                ofr.Status__c = 'Withdrawn';
            }

            // Perform a single bulk update on all Properties — one DML statement
            update propertiesToUpdate;

            // Perform a single bulk update on all remaining Offers — one DML statement
            update offersToUpdate;
        }
    }
}
