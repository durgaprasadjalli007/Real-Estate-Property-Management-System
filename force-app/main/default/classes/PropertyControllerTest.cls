@IsTest
private class PropertyControllerTest {

    @TestSetup
    static void setupData() {

        List<Property__c> properties = new List<Property__c>();

        for (Integer i = 1; i <= 5; i++) {

            properties.add(

                new Property__c(

                    Name = 'Property ' + i,
                    Address__c = 'Street ' + i,
                    City__c = 'Hyderabad',
                    State__c = 'Telangana',
                    Country__c = 'India',
                    Postal_Code__c = '50000' + i,
                    Type__c = 'Residential',
                    Status__c = 'Available',
                    Furnishing_Status__c = 'Furnished',
                    Rent__c = 20000 + (i * 1000),
                    Description__c = 'Test Property ' + i

                )

            );

        }

        insert properties;

    }

    @IsTest
    static void testGetProperties() {

        Test.startTest();

        PropertyResponse response =
            PropertyController.getProperties(

                1,
                25,
                null,
                null,
                null,
                null,
                null,
                null

            );

        Test.stopTest();

        System.assertNotEquals(
            null,
            response
        );

        System.assert(
            response.properties.size() > 0
        );

    }

    @IsTest
    static void testCreatePropertyWithImages() {

        Property__c property = new Property__c(

            Name = 'Green Valley Residency',
            Address__c = '123 Main Street',
            City__c = 'Hyderabad',
            State__c = 'Telangana',
            Country__c = 'India',
            Postal_Code__c = '500001',
            Type__c = 'Residential',
            Status__c = 'Available',
            Furnishing_Status__c = 'Furnished',
            Rent__c = 25000,
            Description__c = 'Beautiful Property'

        );

        PropertyController.FileWrapper file =
            new PropertyController.FileWrapper();

        file.fileName = 'house.jpg';

        file.base64Data =
            EncodingUtil.base64Encode(

                Blob.valueOf('Test Image')

            );

        String filesJson =

            JSON.serialize(

                new List<PropertyController.FileWrapper>{

                    file

                }

            );

        Test.startTest();

        Id propertyId =

            PropertyController.createPropertyWithImages(

                property,

                filesJson

            );

        Test.stopTest();

        System.assertNotEquals(

            null,

            propertyId

        );

        List<ContentDocumentLink> links = [

            SELECT Id

            FROM ContentDocumentLink

            WHERE LinkedEntityId = :propertyId

        ];

        System.assertEquals(

            1,

            links.size()

        );

    }

    @IsTest
    static void testCreatePropertyWithoutProperty() {

        Test.startTest();

        try {

            PropertyController.createPropertyWithImages(

                null,

                '[]'

            );

            System.assert(false);

        }

        catch (AuraHandledException ex) {

            System.assert(

                ex.getMessage().contains(

                    'Property details are required.'

                )

            );

        }

        Test.stopTest();

    }

    @IsTest
    static void testCreatePropertyWithoutImages() {

        Property__c property = new Property__c(

            Name = 'Test Property',
            Address__c = 'Street',
            City__c = 'Hyderabad',
            State__c = 'Telangana',
            Country__c = 'India',
            Postal_Code__c = '500001',
            Type__c = 'Residential',
            Status__c = 'Available',
            Furnishing_Status__c = 'Furnished',
            Rent__c = 25000,
            Description__c = 'Test'

        );

        Test.startTest();

        try {

            PropertyController.createPropertyWithImages(

                property,

                ''

            );

            System.assert(false);

        }

        catch (AuraHandledException ex) {

            System.assert(

                ex.getMessage().contains(

                    'Please upload at least one property image.'

                )

            );

        }

        Test.stopTest();

    }

}