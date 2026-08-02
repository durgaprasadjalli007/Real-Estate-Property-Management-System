/**
 * Handler class responsible for automatically assigning
 * maintenance requests to the vendor with the least workload.
 */
public with sharing class MaintenanceRequestHandler {

    /**
     * Assigns each maintenance request to the vendor with
     * the fewest active maintenance requests.
     *
     * @param maintenanceRequests List of maintenance requests to assign.
     */
    public static void assignVendor(List<Maintenance_Request__c> maintenanceRequests) {

        List<Vendor__c> vendors = [
            SELECT Id, Name
            FROM Vendor__c
            WITH USER_MODE
        ];

        if (vendors.isEmpty()) {
            return;
        }

        // Stores active workload for each vendor
        Map<Id, Integer> vendorWorkloadMap = new Map<Id, Integer>();

        for (Vendor__c vendor : vendors) {
            vendorWorkloadMap.put(vendor.Id, 0);
        }

        // Get active maintenance request count for each vendor
        for (AggregateResult result : [

            SELECT
                Vendor__c vendorId,
                COUNT(Id) requestCount

            FROM Maintenance_Request__c

            WHERE Vendor__c != null
            AND Status__c IN ('Open', 'In Progress')

            GROUP BY Vendor__c

        ]) {

            vendorWorkloadMap.put(
                (Id) result.get('vendorId'),
                (Integer) result.get('requestCount')
            );

        }

        // Assign each request to the vendor with the least workload
        for (Maintenance_Request__c maintenanceRequest : maintenanceRequests) {

            Id leastBusyVendorId;
            Integer lowestWorkload;

            for (Id vendorId : vendorWorkloadMap.keySet()) {

                Integer currentWorkload = vendorWorkloadMap.get(vendorId);

                if (lowestWorkload == null || currentWorkload < lowestWorkload) {

                    lowestWorkload = currentWorkload;
                    leastBusyVendorId = vendorId;

                }

            }

            maintenanceRequest.Vendor__c = leastBusyVendorId;

            // Increase workload because this request is now assigned
            vendorWorkloadMap.put(
                leastBusyVendorId,
                vendorWorkloadMap.get(leastBusyVendorId) + 1
            );

        }

    }

}