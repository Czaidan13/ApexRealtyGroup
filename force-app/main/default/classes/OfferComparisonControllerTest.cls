@isTest
public class OfferComparisonControllerTest {
    @isTest
    static void testGetOffers() {
        // 1. Arrange - Create a Property and two Offers linked to it
        Property__c prop = new Property__c(Name = 'Test Property', Status__c = 'Active', Sale_Price__c = 400000);
        insert prop;

        // Create two Pending Offers on the same Property
        Offer__c offer1 = new Offer__c(
            Name = 'Offer 1',
            Property__c = prop.Id,
            Offer_Amount__c = 420000,
            Status__c = 'Pending'
        );
        Offer__c offer2 = new Offer__c(
            Name = 'Offer 2',
            Property__c = prop.Id,
            Offer_Amount__c = 430000,
            Status__c = 'Pending'
        );
        insert new List<Offer__c>{ offer1, offer2 };

        // 2. Act - Call getOffers with the Property Id
        Test.startTest();
        List<Offer__c> offers = OfferComparisonController.getOffers(prop.Id);
        Test.stopTest();

        // 3. Assert - Verify both offers were returned
        System.assertEquals(2, offers.size());
    }

    @isTest
    static void testAcceptOffer() {
        // 1. Arrange - Create a Property and two Pending Offers
        Property__c prop = new Property__c(Name = 'Test Property', Status__c = 'Active', Sale_Price__c = 400000);
        insert prop;

        Offer__c offer1 = new Offer__c(
            Name = 'Offer 1',
            Property__c = prop.Id,
            Offer_Amount__c = 420000,
            Status__c = 'Pending'
        );
        Offer__c offer2 = new Offer__c(
            Name = 'Offer 2',
            Property__c = prop.Id,
            Offer_Amount__c = 430000,
            Status__c = 'Pending'
        );
        insert new List<Offer__c>{ offer1, offer2 };

        // 2. Act - Accept offer2
        // This fires the OfferTrigger which handles the cascade updates
        Test.startTest();
        OfferComparisonController.acceptOffer(offer2.Id);
        Test.stopTest();

        // 3. Assert - Re-query all affected records to verify the cascade worked correctly
        // Verify offer1 was withdrawn — OfferTrigger should have set it to Withdrawn
        Offer__c updatedOffer1 = [SELECT Status__c FROM Offer__c WHERE Id = :offer1.Id];
        System.assertEquals('Withdrawn', updatedOffer1.Status__c);

        // Verify offer2 was accepted
        Offer__c updatedOffer2 = [SELECT Status__c FROM Offer__c WHERE Id = :offer2.Id];
        System.assertEquals('Accepted', updatedOffer2.Status__c);

        // Verify the Property status was updated to Under Contract
        // and the Sale Price was stamped with offer2's amount
        Property__c updatedProp = [SELECT Status__c, Sale_Price__c FROM Property__c WHERE Id = :prop.Id];
        System.assertEquals('Under Contract', updatedProp.Status__c);
        System.assertEquals(offer2.Offer_Amount__c, updatedProp.Sale_Price__c);
    }
}
