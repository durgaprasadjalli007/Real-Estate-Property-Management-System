public with sharing class LeaseExpiryEmailService {

    public static void sendExpiryReminders() {

        Date reminderDate = Date.today().addMonths(1);

        List<Lease_Agreement__c> leases = [

            SELECT
                Name,
                End_Date__c,
                Tenant__r.Name,
                Tenant__r.Email__c,
                Property__r.Name

            FROM Lease_Agreement__c

            WHERE End_Date__c = :reminderDate

        ];

        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

        for (Lease_Agreement__c lease : leases) {

            if (String.isBlank(lease.Tenant__r.Email__c)) {
                continue;
            }

            Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();

            mail.setToAddresses(
                new List<String>{
                    lease.Tenant__r.Email__c
                }
            );

            mail.setSubject(
                'Lease Expiry Reminder - ' + lease.Name
            );

            mail.setPlainTextBody(

                'Dear ' + lease.Tenant__r.Name + ',\n\n' +

                'Your lease for "' +

                lease.Property__r.Name +

                '" will expire on ' +

                String.valueOf(lease.End_Date__c) +

                '.\n\nPlease contact us if you wish to renew your lease.\n\nThank you.'

            );

            emails.add(mail);

        }

        if (!emails.isEmpty()) {

            Messaging.sendEmail(emails);

        }

    }

}