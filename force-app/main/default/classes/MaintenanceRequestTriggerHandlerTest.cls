@IsTest
private class MaintenanceRequestTriggerHandlerTest {

    @TestSetup
    static void setupData() {

        Property__c property = new Property__c(
            Name='Green Valley Residency',
            Address__c='Street',
            City__c='Hyderabad',
            State__c='Telangana',
            Country__c='India',
            Postal_Code__c='500001',
            Type__c='Residential',
            Status__c='Available',
            Rent__c=25000,
            Description__c='Test Property'
        );
        insert property;

        Vendor__c vendorA = new Vendor__c(
            Name='Vendor A',
            Phone__c='9999999991',
            Email__c='vendorA@test.com'
        );

        Vendor__c vendorB = new Vendor__c(
            Name='Vendor B',
            Phone__c='9999999992',
            Email__c='vendorB@test.com'
        );

        insert new List<Vendor__c>{
            vendorA,
            vendorB
        };

        insert new Maintenance_Request__c(
            Property__c=property.Id,
            Vendor__c=vendorA.Id,
            Status__c='Open',
            Description__c='Existing Request'
        );

    }

    @IsTest
    static void testAssignLeastLoadedVendor() {

        Property__c property = [
            SELECT Id
            FROM Property__c
            LIMIT 1
        ];

        Vendor__c vendorB = [
            SELECT Id
            FROM Vendor__c
            WHERE Name='Vendor B'
            LIMIT 1
        ];

        Test.startTest();

        Maintenance_Request__c request =
            new Maintenance_Request__c(

                Property__c=property.Id,
                Status__c='Open',
                Description__c='New Request'

            );

        insert request;

        Test.stopTest();

        request = [

            SELECT Vendor__c

            FROM Maintenance_Request__c

            WHERE Id=:request.Id

        ];

        System.assertEquals(
            vendorB.Id,
            request.Vendor__c
        );

    }

    @IsTest
    static void testExistingVendorIsNotOverwritten() {

        Property__c property = [
            SELECT Id
            FROM Property__c
            LIMIT 1
        ];

        Vendor__c vendorA = [
            SELECT Id
            FROM Vendor__c
            WHERE Name='Vendor A'
            LIMIT 1
        ];

        Test.startTest();

        Maintenance_Request__c request =
            new Maintenance_Request__c(

                Property__c=property.Id,
                Vendor__c=vendorA.Id,
                Status__c='Open',
                Description__c='Already Assigned'

            );

        insert request;

        Test.stopTest();

        request = [

            SELECT Vendor__c

            FROM Maintenance_Request__c

            WHERE Id=:request.Id

        ];

        System.assertEquals(
            vendorA.Id,
            request.Vendor__c
        );

    }

}