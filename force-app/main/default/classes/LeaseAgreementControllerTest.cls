@IsTest
private class LeaseAgreementControllerTest {

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
            End_Date__c = Date.today().addYears(1),
            Terms__c = '12 Months'
        );
        insert lease;

    }

    @IsTest
    static void testGetLeaseAgreement() {

        Lease_Agreement__c lease = [

            SELECT Id

            FROM Lease_Agreement__c

            LIMIT 1

        ];

        Test.startTest();

        Lease_Agreement__c result =
            LeaseAgreementController.getLeaseAgreement(lease.Id);

        Test.stopTest();

        System.assertNotEquals(null, result);

        System.assertEquals('Lease-001', result.Name);

        System.assertNotEquals(null, result.Property__c);

        System.assertNotEquals(null, result.Tenant__c);

    }

    @IsTest
    static void testGetMonthlyRent() {

        Property__c property = [

            SELECT Id, Rent__c

            FROM Property__c

            LIMIT 1

        ];

        Test.startTest();

        Decimal rent =
            LeaseAgreementController.getMonthlyRent(property.Id);

        Test.stopTest();

        System.assertEquals(

            property.Rent__c,

            rent

        );

    }

    @IsTest
    static void testGetMonthlyRentWithNull() {

        Test.startTest();

        Decimal rent =
            LeaseAgreementController.getMonthlyRent(null);

        Test.stopTest();

        System.assertEquals(

            null,

            rent

        );

    }

}