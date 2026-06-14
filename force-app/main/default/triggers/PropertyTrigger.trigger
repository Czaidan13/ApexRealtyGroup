trigger PropertyTrigger on Property__c(after update) {
    PropertyTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
}
