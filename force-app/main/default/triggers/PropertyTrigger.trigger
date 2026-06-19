trigger PropertyTrigger on Property__c(after insert, after update) {
    if (Trigger.isInsert) {
        PropertyTriggerHandler.handleAfterInsert(Trigger.new);
    }
    if (Trigger.isUpdate) {
        PropertyTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}
