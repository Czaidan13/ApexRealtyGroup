public with sharing class OfferComparisonController {
    // Returns all Offers for a given Property ordered by most recently created
    // cacheable=true — read only method, safe to cache
    @AuraEnabled(cacheable=true)
    public static List<Offer__c> getOffers(Id propertyId) {
        return [
            SELECT Id, Name, Offer_Amount__c, Status__c, Contact__c, CreatedDate, Expiration_Date__c, Financing_Type__c
            FROM Offer__c
            WHERE Property__c = :propertyId
            ORDER BY CreatedDate DESC
        ];
    }

    // Accepts a specific Offer by updating its Status to Accepted
    // The OfferTrigger fires automatically after the update and handles:
    // - Updating the Property status to Under Contract
    // - Stamping the Sale Price on the Property
    // - Withdrawing all other open Offers on the Property
    @AuraEnabled
    public static void acceptOffer(Id offerId) {
        Offer__c offer = [SELECT Id, Property__c, Offer_Amount__c FROM Offer__c WHERE Id = :offerId LIMIT 1];
        offer.Status__c = 'Accepted';
        update offer;
    }
}
