public with sharing class PropertyResponse {

    @AuraEnabled
    public List<Property__c> properties;

    @AuraEnabled
    public Integer totalRecords;

    public PropertyResponse() {
        properties = new List<Property__c>();
        totalRecords = 0;
    }

}