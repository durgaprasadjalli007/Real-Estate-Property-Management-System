/**
 * Handles trigger logic for Property_Tenant__c.
 * On insert: creates a Task to generate the lease agreement.
 */
public with sharing class Property_TenantTriggerHandler {

    public static void handleAfterInsert(List<Property_Tenant__c> newRecords) {
        List<Task> tasks = new List<Task>();

        for (Property_Tenant__c pt : newRecords) {
            Task t = new Task(
                Subject       = 'Generate Lease Agreement',
                WhatId        = pt.Id,
                Status        = 'Not Started',
                Priority      = 'Normal',
                ActivityDate  = Date.today().addDays(7),
                Description   = 'A property has been assigned to a tenant. Please generate the lease agreement.'
            );
            tasks.add(t);
        }

        if (!tasks.isEmpty()) {
            insert tasks;
        }
    }
}
