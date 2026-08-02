@IsTest
private class LeaseExpiryEmailServiceTest {

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

        Lease_Agreement__c lease = new Lease_Agreement__c(
           
            Property__c = property.Id,
            Tenant__c = tenant.Id,
            Monthly_Rent__c = 25000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(1),
            Terms__c = '12 Months'
        );
        insert lease;

    }

    @IsTest
    static void testSendExpiryReminders() {

        Test.startTest();

        LeaseExpiryEmailService.sendExpiryReminders();

        Test.stopTest();

        System.assertEquals(
            1,
            Limits.getEmailInvocations(),
            'One email should have been sent.'
        );

    }

}