trigger ContactTrigger on Contact(before insert) {
    ContactTriggerHandler.handleBeforeInsert(Trigger.new);
}
