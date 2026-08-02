@IsTest
private class Property_TenantTriggerHandlerTest {

    @TestSetup
    static void setupData() {

        Property__c property = new Property__c(
            Name = 'Green Valley Residency',
            Address__c = '123 Main Street',
            City__c = 'Hyderabad',
            State__c = 'Telangana',
            Country__c = 'India',
            Postal_Code__c = '500001',
            Type__c = 'Residential',
            Status__c = 'Available',
            Rent__c = 25000,
            Description__c = 'Test Property'
        );
        insert property;

        Tenant__c tenant = new Tenant__c(
            Name = 'John Smith',
            Phone_Number__c = '9876543210',
            Email__c = 'john@test.com'
        );
        insert tenant;

    }

    @IsTest
    static void testTaskCreatedAfterInsert() {

        Property__c property = [
            SELECT Id
            FROM Property__c
            LIMIT 1
        ];

        Tenant__c tenant = [
            SELECT Id
            FROM Tenant__c
            LIMIT 1
        ];

        Test.startTest();

        Property_Tenant__c assignment = new Property_Tenant__c(
            Property__c = property.Id,
            Tenant__c = tenant.Id
        );

        insert assignment;

        Test.stopTest();

        List<Task> tasks = [

            SELECT
                Subject,
                Status,
                Priority,
                WhatId,
                ActivityDate,
                Description

            FROM Task

            WHERE WhatId = :assignment.Id

        ];

        System.assertEquals(
            1,
            tasks.size(),
            'One task should be created.'
        );

        Task taskRecord = tasks[0];

        System.assertEquals(
            'Generate Lease Agreement',
            taskRecord.Subject
        );

        System.assertEquals(
            'Not Started',
            taskRecord.Status
        );

        System.assertEquals(
            'Normal',
            taskRecord.Priority
        );

        System.assertEquals(
            assignment.Id,
            taskRecord.WhatId
        );

        System.assertEquals(
            Date.today().addDays(7),
            taskRecord.ActivityDate
        );

        System.assert(
            taskRecord.Description.contains('lease agreement'),
            'Description should mention lease agreement.'
        );

    }

}