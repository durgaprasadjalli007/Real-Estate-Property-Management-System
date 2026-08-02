import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript } from 'lightning/platformResourceLoader';

import jsPDF from '@salesforce/resourceUrl/jsPDF';

import getLeaseAgreement from '@salesforce/apex/LeaseAgreementController.getLeaseAgreement';
import getMonthlyRent from '@salesforce/apex/LeaseAgreementController.getMonthlyRent';
import sendLeaseAgreement from '@salesforce/apex/LeaseAgreementEmailController.sendLeaseAgreement';

export default class LeaseAgreement extends LightningElement {

    monthlyRent;
    leaseId;
    selectedPropertyId;
    pdfInitialized = false;

    renderedCallback() {

        if (this.pdfInitialized) {
            return;
        }

        this.pdfInitialized = true;

        loadScript(this, jsPDF)
            .then(() => {
                console.log('jsPDF Loaded Successfully');
            })
            .catch(error => {
                console.error(error);
            });

    }

    async handlePropertyChange(event) {

        this.selectedPropertyId = event.detail.recordId;

        if (!this.selectedPropertyId) {

            this.monthlyRent = null;
            return;

        }

        try {

            this.monthlyRent = await getMonthlyRent({

                propertyId: this.selectedPropertyId

            });

        }
        catch (error) {

            console.error(error);

            this.showToast(
                'Error',
                'Unable to fetch monthly rent.',
                'error'
            );

        }

    }

    handleSubmit(event) {

        event.preventDefault();

        const fields = event.detail.fields;

        fields.Property__c = this.selectedPropertyId;
        fields.Monthly_Rent__c = this.monthlyRent;

        this.template
            .querySelector('lightning-record-edit-form')
            .submit(fields);

    }

    handleSuccess(event) {

        this.leaseId = event.detail.id;

        this.showToast(
            'Success',
            'Lease Agreement created successfully.',
            'success'
        );

    }

    showToast(title, message, variant) {

        this.dispatchEvent(

            new ShowToastEvent({

                title,
                message,
                variant

            })

        );

    }
        async generatePDF() {

        if (!this.leaseId) {

            this.showToast(
                'Error',
                'Please save the Lease Agreement first.',
                'error'
            );

            return;

        }

        try {

            const lease = await getLeaseAgreement({
                leaseId: this.leaseId
            });

            const doc = this.buildPDF(lease);

            doc.save(`LeaseAgreement-${lease.Name}.pdf`);

        }
        catch (error) {

            console.error(error);

            this.showToast(
                'Error',
                error.body?.message || 'Unable to generate PDF.',
                'error'
            );

        }

    }

    async sendPDF() {

        if (!this.leaseId) {

            this.showToast(
                'Error',
                'Please save the Lease Agreement first.',
                'error'
            );

            return;

        }

        try {

            const lease = await getLeaseAgreement({
                leaseId: this.leaseId
            });

            const doc = this.buildPDF(lease);

            const pdfBase64 =
                doc.output('datauristring').split(',')[1];

            await sendLeaseAgreement({

                leaseId: this.leaseId,
                pdfContent: pdfBase64

            });

            this.showToast(
                'Success',
                'Lease Agreement emailed successfully.',
                'success'
            );

        }
        catch (error) {

            console.error(error);

            this.showToast(
                'Error',
                error.body?.message || 'Unable to send email.',
                'error'
            );

        }

    }

    buildPDF(lease) {

        const { jsPDF } = window.jspdf;

        const doc = new jsPDF();

        const rent = lease.Monthly_Rent__c
            ? Number(lease.Monthly_Rent__c).toLocaleString('en-IN')
            : '0';

        doc.setFontSize(20);
        doc.text('LEASE AGREEMENT', 60, 20);

        doc.setDrawColor(0);
        doc.line(20, 25, 190, 25);

        doc.setFontSize(12);

        doc.text(`Agreement No : ${lease.Name}`, 20, 40);

        doc.text(
            `Property : ${lease.Property__r ? lease.Property__r.Name : ''}`,
            20,
            50
        );

        doc.text(
            `Tenant : ${lease.Tenant__r ? lease.Tenant__r.Name : ''}`,
            20,
            60
        );

        doc.text(
            `Monthly Rent : Rs. ${rent}`,
            20,
            70
        );

        doc.text(
            `Start Date : ${lease.Start_Date__c}`,
            20,
            80
        );

        doc.text(
            `End Date : ${lease.End_Date__c}`,
            20,
            90
        );

        doc.line(20, 100, 190, 100);

        doc.setFontSize(14);
        doc.text('Terms & Conditions', 20, 110);

        doc.setFontSize(11);

        const terms =
            lease.Terms__c || 'No Terms Specified';

        const wrappedText =
            doc.splitTextToSize(terms, 170);

        doc.text(
            wrappedText,
            20,
            120
        );

        doc.line(20, 220, 190, 220);

        doc.text(
            'Landlord Signature: __________________',
            20,
            240
        );

        doc.text(
            'Tenant Signature: __________________',
            110,
            240
        );

        return doc;

    }

}