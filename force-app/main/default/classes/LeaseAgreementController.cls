public with sharing class LeaseAgreementController {

    @AuraEnabled(cacheable=true)
    public static Lease_Agreement__c getLeaseAgreement(Id leaseId) {

        return [
            SELECT
                Name,
                Property__c,
                Property__r.Name,
                Tenant__c,
                Tenant__r.Name,
                Monthly_Rent__c,
                Start_Date__c,
                End_Date__c,
                Terms__c
            FROM Lease_Agreement__c
            WHERE Id = :leaseId
            WITH USER_MODE
            LIMIT 1
        ];

    }
@AuraEnabled(cacheable=true)
public static Decimal getMonthlyRent(Id propertyId) {

    if (propertyId == null) {
        return null;
    }

    Property__c property = [
        SELECT Rent__c
        FROM Property__c
        WHERE Id = :propertyId
        WITH USER_MODE
        LIMIT 1
    ];

    return property.Rent__c;
}
}