public with sharing class PropertyController {

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

        List<FileWrapper> files =

            (List<FileWrapper>) JSON.deserialize(

                filesJson,

                List<FileWrapper>.class

            );

        if (files == null || files.isEmpty()) {

            throw new AuraHandledException(

                'Please upload at least one property image.'

            );

        }

        try {

            insert propertyRecord;

            List<ContentVersion> versions =
                new List<ContentVersion>();

            for (FileWrapper file : files) {

                ContentVersion version =
                    new ContentVersion();

                version.Title = file.fileName;

                version.PathOnClient =
                    file.fileName;

                version.VersionData =
                    EncodingUtil.base64Decode(
                        file.base64Data
                    );

                version.FirstPublishLocationId =
                    propertyRecord.Id;

                versions.add(version);

            }

            insert versions;

        }
        catch (Exception ex) {

            throw new AuraHandledException(

                'Unable to create Property. '

                + ex.getMessage()

            );

        }

        return propertyRecord.Id;

    }

    public class FileWrapper {

        @AuraEnabled
        public String fileName;

        @AuraEnabled
        public String base64Data;

    }

}