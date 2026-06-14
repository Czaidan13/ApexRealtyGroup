trigger OfferTrigger on Offer__c(after update) {
    OfferTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
