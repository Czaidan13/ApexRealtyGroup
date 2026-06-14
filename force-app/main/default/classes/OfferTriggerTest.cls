@isTest
public class OfferTriggerTest {
    @isTest
    static void testStatusChange() {
        // 1. Arrange - Creat a test records
        Property__c prop = new Property__c();
        prop.Name = '987 Real Street';
        prop.Status__c = 'Active';
        insert prop;

        Offer__c offer1 = new Offer__c();
        Offer__c offer2 = new Offer__c();
        Offer__c offer3 = new Offer__c();
        offer1.Name = 'Offer 1';
        offer1.Property__c = prop.Id;
        offer1.Offer_Amount__c = 100000;
        offer1.Status__c = 'Pending';
        offer2.Name = 'Offer 2';
        offer2.Property__c = prop.Id;
        offer2.Offer_Amount__c = 200000;
        offer2.Status__c = 'Pending';
        offer3.Name = 'Offer 3';
        offer3.Property__c = prop.Id;
        offer3.Offer_Amount__c = 300000;
        offer3.Status__c = 'Pending';
        List<Offer__c> offers = new List<Offer__c>{ offer1, offer2, offer3 };
        insert offers;

        // 2. Act - update offer status which fires the trigger
        Test.startTest();
        offer3.Status__c = 'Accepted';
        update offer3;
        Test.stopTest();

        // 3. Assert - Check the Status was set correctly
        Property__c propResult = [SELECT Status__c, Sale_Price__c FROM Property__c WHERE Id = :prop.Id];
        System.assertEquals('Under Contract', propResult.Status__c);
        System.assertEquals(offer3.Offer_Amount__c, propResult.Sale_Price__c);
        List<Offer__c> offerResult = [SELECT Status__c FROM Offer__c WHERE Property__c = :prop.Id];
        for (Offer__c o : offerResult) {
            if (o.Id == offer3.Id) {
                System.assertEquals('Accepted', o.Status__c);
            } else {
                System.assertEquals('Withdrawn', o.Status__c);
            }
        }
    }
}
