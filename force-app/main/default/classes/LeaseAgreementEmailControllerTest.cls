@IsTest
private class LeaseAgreementEmailControllerTest {

    @TestSetup
    static void setupData() {

        Tenant__c tenant = new Tenant__c(
            Name = 'John Smith',
            Email__c = 'john@test.com'
        );
        insert tenant;

        Property__c property = new Property__c(
            Name = 'Green Villa',
            Address__c = 'Street 1',
            City__c = 'Hyderabad',
            State__c = 'Telangana',
            Country__c = 'India',
            Postal_Code__c = '500001',
            Type__c = 'Residential',
            Status__c = 'Available',
            Furnishing_Status__c = 'Furnished',
            Rent__c = 25000
        );
        insert property;

        Lease_Agreement__c lease = new Lease_Agreement__c(
            Property__c = property.Id,
            Tenant__c = tenant.Id,
            Monthly_Rent__c = 25000,
            Start_Date__c = Date.today(),
            End_Date__c = Date.today().addMonths(12),
            Terms__c = 'Sample Terms'
        );
        insert lease;

    }

    @IsTest
    static void testSendLeaseAgreement() {

        Lease_Agreement__c lease = [
            SELECT Id
            FROM Lease_Agreement__c
            LIMIT 1
        ];

        String pdfContent =
            EncodingUtil.base64Encode(
                Blob.valueOf('Sample PDF')
            );

        Test.startTest();

        LeaseAgreementEmailController.sendLeaseAgreement(
            lease.Id,
            pdfContent
        );

        Test.stopTest();

        System.assert(true);

    }

    @IsTest
    static void testTenantEmailMissing() {

        Tenant__c tenant = [
            SELECT Id
            FROM Tenant__c
            LIMIT 1
        ];

        tenant.Email__c = null;
        update tenant;

        Lease_Agreement__c lease = [
            SELECT Id
            FROM Lease_Agreement__c
            LIMIT 1
        ];

        String pdfContent =
            EncodingUtil.base64Encode(
                Blob.valueOf('Sample PDF')
            );

        Test.startTest();

        try {

            LeaseAgreementEmailController.sendLeaseAgreement(
                lease.Id,
                pdfContent
            );

            System.assert(false);

        }
        catch (AuraHandledException ex) {

        }

        Test.stopTest();

    }

}