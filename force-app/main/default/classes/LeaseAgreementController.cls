/**
 * Controller class for managing Lease Agreement operations.
 * Provides methods to retrieve lease details and Property rent
 * for Lightning Web Components.
   Test Class: LeaseAgreementControllerTest
 */
public with sharing class LeaseAgreementController {

    /**
     * Retrieves the details of a Lease Agreement,
     * including the related Property and Tenant.
     *
     * @param leaseId Lease Agreement record Id.
     * @return Lease Agreement record.
     */
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
    
       /**
     * Retrieves the monthly rent of the selected Property.
     *
     * @param propertyId Property record Id.
     * @return Monthly rent of the Property.
     */
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