/**
 * Controller class for sending Lease Agreement PDFs
 * to tenants via email.
 */
public with sharing class LeaseAgreementEmailController {

    /**
     * Sends the Lease Agreement PDF to the tenant's email.
     *
     * @param leaseId Id of the Lease Agreement record.
     * @param pdfContent Base64 encoded PDF content.
     */
    @AuraEnabled
    public static void sendLeaseAgreement(Id leaseId, String pdfContent) {

        Lease_Agreement__c lease = [
            SELECT
                Name,
                Tenant__r.Email__c
            FROM Lease_Agreement__c
            WHERE Id = :leaseId
            LIMIT 1
        ];

        if (lease.Tenant__r == null ||String.isBlank(lease.Tenant__r.Email__c)) {
            throw new AuraHandledException('Tenant email is missing.');
        }

        Messaging.EmailFileAttachment attachment =
            new Messaging.EmailFileAttachment();

        attachment.setFileName('LeaseAgreement.pdf');
        attachment.setBody(
            EncodingUtil.base64Decode(pdfContent)
        );
        attachment.setContentType('application/pdf');

        Messaging.SingleEmailMessage email =
            new Messaging.SingleEmailMessage();

        email.setToAddresses(
            new List<String>{
                lease.Tenant__r.Email__c
            }
        );

        email.setSubject(
            'Lease Agreement - ' + lease.Name
        );

        email.setPlainTextBody(
            'Dear Tenant,\n\nPlease find your lease agreement attached.\n\nThank you.'
        );

        email.setFileAttachments(
            new List<Messaging.EmailFileAttachment>{
                attachment
            }
        );

        Messaging.SendEmailResult[] results =
    Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ email }
    );

if (!results[0].isSuccess()) {

    String errorMessage = '';

    for (Messaging.SendEmailError err : results[0].getErrors()) {
        errorMessage += err.getMessage() + ' ';
    }

    throw new AuraHandledException(errorMessage);

}
    }

}