public with sharing class MaintenanceRequestTriggerHandler {

    public static void handleBeforeInsert(
        List<Maintenance_Request__c> newRequests
    ) {

        List<Vendor__c> vendors = [
            SELECT Id
            FROM Vendor__c
            ORDER BY Name
        ];

        if (vendors.isEmpty()) {
            return;
        }

        Map<Id, Integer> workloadByVendor = new Map<Id, Integer>();

        for (Vendor__c vendor : vendors) {
            workloadByVendor.put(vendor.Id, 0);
        }

        for (AggregateResult ar : [

            SELECT
                Vendor__c,
                COUNT(Id) total

            FROM Maintenance_Request__c

            WHERE Vendor__c != null
            AND Status__c NOT IN ('Completed', 'Cancelled')

            GROUP BY Vendor__c

        ]) {

            Id vendorId = (Id)ar.get('Vendor__c');

            Integer count = (Integer)ar.get('total');

            if (workloadByVendor.containsKey(vendorId)) {

                workloadByVendor.put(
                    vendorId,
                    count
                );

            }

        }

        for (Maintenance_Request__c request : newRequests) {

            if (request.Vendor__c != null) {
                continue;
            }

            Id vendorId =
                getLeastLoadedVendor(workloadByVendor);

            if (vendorId != null) {

                request.Vendor__c = vendorId;

                workloadByVendor.put(
                    vendorId,
                    workloadByVendor.get(vendorId) + 1
                );

            }

        }

    }

    private static Id getLeastLoadedVendor(
        Map<Id, Integer> workloadByVendor
    ) {

        Id selectedVendor;

        Integer minimumLoad = Integer.MAX_VALUE;

        for (Id vendorId : workloadByVendor.keySet()) {

            Integer load = workloadByVendor.get(vendorId);

            if (load < minimumLoad) {

                minimumLoad = load;

                selectedVendor = vendorId;

            }

        }

        return selectedVendor;

    }

}