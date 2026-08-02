import { LightningElement, api, wire, track } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import getLeaseDetails from '@salesforce/apex/LeaseAgreementController.getLeaseDetails';
import sendLeaseAgreementEmail from '@salesforce/apex/LeaseAgreementController.sendLeaseAgreementEmail';
import JSPDF_URL from '@salesforce/resourceUrl/jspdf';

export default class LeaseAgreementPdf extends LightningElement {

    @api recordId;

    @track lease;
    @track isLoading = true;
    @track isSending = false;
    @track successMessage = '';
    @track errorMessage = '';

    jspdfLoaded = false;

    @wire(getLeaseDetails, { leaseId: '$recordId' })
    wiredLease({ data, error }) {
        this.isLoading = false;
        if (data) {
            this.lease = data;
        } else if (error) {
            this.errorMessage = 'Failed to load lease details.';
        }
    }

    get propertyName() {
        return this.lease && this.lease.Property__r ? this.lease.Property__r.Name : '';
    }

    get tenantName() {
        return this.lease && this.lease.Tenant__r ? this.lease.Tenant__r.Name : '';
    }

    connectedCallback() {
        loadScript(this, JSPDF_URL)
            .then(() => {
                this.jspdfLoaded = true;
            })
            .catch(() => {
                this.errorMessage = 'PDF library failed to load.';
            });
    }

    handleDownloadPdf() {
        if (!this.jspdfLoaded) {
            this.errorMessage = 'PDF library is not ready yet. Please try again.';
            return;
        }

        // eslint-disable-next-line no-undef
        const doc = new jspdf.jsPDF();
        const la  = this.lease;

        doc.setFontSize(18);
        doc.text('Lease Agreement', 20, 20);

        doc.setFontSize(12);
        doc.text('Agreement : ' + la.Name,                       20, 40);
        doc.text('Property  : ' + this.propertyName,             20, 52);
        doc.text('Tenant    : ' + this.tenantName,               20, 64);
        doc.text('Start Date: ' + la.Start_Date__c,              20, 76);
        doc.text('End Date  : ' + la.End_Date__c,                20, 88);
        doc.text('Monthly Rent: ' + la.Monthly_Rent__c,          20, 100);

        if (la.Terms__c) {
            doc.setFontSize(11);
            doc.text('Terms & Conditions:', 20, 116);
            const lines = doc.splitTextToSize(la.Terms__c, 170);
            doc.text(lines, 20, 126);
        }

        doc.save(la.Name + '.pdf');
        this.successMessage = 'PDF downloaded successfully.';
        this.errorMessage   = '';
    }

    handleSendEmail() {
        this.isSending      = true;
        this.successMessage = '';
        this.errorMessage   = '';

        sendLeaseAgreementEmail({ leaseId: this.recordId })
            .then(() => {
                this.successMessage = 'Lease agreement sent to tenant successfully.';
            })
            .catch(error => {
                this.errorMessage = error.body ? error.body.message : 'Failed to send email.';
            })
            .finally(() => {
                this.isSending = false;
            });
    }
}
