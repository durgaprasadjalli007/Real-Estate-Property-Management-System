trigger Property_TenantTrigger on Property_Tenant__c (after insert) {
    Property_TenantTriggerHandler.handleAfterInsert(Trigger.new);
}
