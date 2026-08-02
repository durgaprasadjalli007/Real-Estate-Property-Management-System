public with sharing class PropertyService {

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

        pageNumber = (pageNumber == null || pageNumber < 1)
            ? 1
            : pageNumber;

        pageSize = (pageSize == null || pageSize <= 0)
            ? 25
            : pageSize;

        Integer offsetValue =
            (pageNumber - 1) * pageSize;

        Boolean isNearbySearch =

            latitude != null &&
            longitude != null &&
            distance != null;

        List<String> filters =
            new List<String>();

        if (maxPrice != null) {

            filters.add(
                'Rent__c <= ' + maxPrice
            );

        }

        if (String.isNotBlank(status)) {

            filters.add(

                'Status__c = \'' +

                String.escapeSingleQuotes(status) +

                '\''

            );

        }

        if (String.isNotBlank(furnishingStatus)) {

            filters.add(

                'Furnishing_Status__c = \'' +

                String.escapeSingleQuotes(furnishingStatus) +

                '\''

            );

        }

        if (isNearbySearch) {

            filters.add(

                'DISTANCE(' +

                'Location__c,' +

                'GEOLOCATION(' +

                latitude + ',' +

                longitude +

                '),' +

                '\'km\'' +

                ') <= ' +

                distance

            );

        }

        String whereClause = '';

        if (!filters.isEmpty()) {

            whereClause =
                ' WHERE ' +

                String.join(filters, ' AND ');

        }

        Integer totalRecords = Database.countQuery(

            'SELECT COUNT() FROM Property__c' +

            whereClause +

            ' WITH USER_MODE'

        );

        String distanceField = '';

        String orderBy =
            ' ORDER BY CreatedDate DESC';

        if (isNearbySearch) {

            distanceField =

                ', DISTANCE(' +

                'Location__c,' +

                'GEOLOCATION(' +

                latitude + ',' +

                longitude +

                '),' +

                '\'km\'' +

                ') Distance';

            orderBy =

                ' ORDER BY DISTANCE(' +

                'Location__c,' +

                'GEOLOCATION(' +

                latitude + ',' +

                longitude +

                '),' +

                '\'km\'' +

                ')';

        }

        String query =

            'SELECT ' +

            'Id,' +

            'Name,' +

            'Address__c,' +

            'City__c,' +

            'State__c,' +

            'Country__c,' +

            'Postal_Code__c,' +

            'Type__c,' +

            'Status__c,' +

            'Rent__c,' +

            'Furnishing_Status__c,' +

            'Description__c,' +

            'Location__c,' +

            'Location__Latitude__s,' +

            'Location__Longitude__s' +

            distanceField +

            ' FROM Property__c' +

            whereClause +

            ' WITH USER_MODE' +

            orderBy +

            ' LIMIT ' + pageSize +

            ' OFFSET ' + offsetValue;

        List<Property__c> properties =

            Database.query(query);

        SObjectAccessDecision decision =

            Security.stripInaccessible(

                AccessType.READABLE,

                properties

            );

        PropertyResponse response =
            new PropertyResponse();

        response.properties =

            (List<Property__c>)
                decision.getRecords();

        response.totalRecords =
            totalRecords;

        return response;

    }

}