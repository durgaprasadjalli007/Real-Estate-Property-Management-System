/**
 * Controller class for managing Property operations.
 * Provides methods to retrieve properties and create
 * properties with image attachments.
 * Test Class: PropertyControllerTest
 */

public with sharing class PropertyController {

     /**
     * Retrieves a paginated list of properties based on
     * the specified search and filter criteria.
     *
     * @return PropertyResponse containing matching properties.
     */
    @AuraEnabled
    public static PropertyResponse getProperties(
        Integer pageNumber,
        Integer pageSize,
        Decimal maxPrice,
        String status,
        String furnishingStatus,
        Decimal latitude,
        Decimal longitude,
        Decimal distance
    ) {

        return PropertyService.getProperties(
            pageNumber,
            pageSize,
            maxPrice,
            status,
            furnishingStatus,
            latitude,
            longitude,
            distance
        );
    }

    /**
     * Creates a Property record and uploads the associated
     * image files as Salesforce Files.
     *
     * @param propertyRecord Property record to be created.
     * @param filesJson JSON containing uploaded image details.
     * @return Id of the newly created Property.
     */
    @AuraEnabled
    public static Id createPropertyWithImages(
        Property__c propertyRecord,
        String filesJson
    ) {

        if (propertyRecord == null) {
            throw new AuraHandledException(
                'Property details are required.'
            );
        }

        if (String.isBlank(filesJson)) {
            throw new AuraHandledException(
                'Please upload at least one property image.'
            );
        }

        List<FileWrapper> uploadedFiles =
            (List<FileWrapper>)JSON.deserialize(
                filesJson,
                List<FileWrapper>.class
            );

        if (uploadedFiles == null || uploadedFiles.isEmpty()) {
            throw new AuraHandledException(
                'Please upload at least one property image.'
            );
        }

        try {

            List<Property__c> propertyRecords =
                new List<Property__c>{ propertyRecord };

            SObjectAccessDecision accessDecision =
                Security.stripInaccessible(
                    AccessType.CREATABLE,
                    propertyRecords
                );

            Property__c propertyToInsert =
                (Property__c)accessDecision.getRecords()[0];

            insert propertyToInsert;

            List<ContentVersion> contentVersions =
                new List<ContentVersion>();

            for (FileWrapper uploadedFile : uploadedFiles) {

                ContentVersion contentVersion =
                    new ContentVersion();

                contentVersion.Title = uploadedFile.fileName;
                contentVersion.PathOnClient = uploadedFile.fileName;
                contentVersion.VersionData =
                    EncodingUtil.base64Decode(
                        uploadedFile.base64Data
                    );

                contentVersion.FirstPublishLocationId =
                    propertyToInsert.Id;

                contentVersions.add(contentVersion);
            }

            insert contentVersions;

            return propertyToInsert.Id;

        }
        catch (Exception ex) {

            throw new AuraHandledException(
                'Unable to create Property. ' +
                ex.getMessage()
            );

        }

    }

     /**
     * Wrapper class used to store uploaded
     * file information from the client.
     */
    public class FileWrapper {

        @AuraEnabled
        public String fileName;

        @AuraEnabled
        public String base64Data;

    }

}