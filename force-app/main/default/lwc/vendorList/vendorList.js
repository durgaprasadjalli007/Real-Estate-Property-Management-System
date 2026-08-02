import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getVendors from '@salesforce/apex/VendorController.getVendors';
import VENDOR_OBJECT from '@salesforce/schema/Vendor__c';


export default class VendorList extends LightningElement {

    @track vendors = [];
    @track isLoading = false;
    @track showCreateVendorModal = false;

    pageNumber = 1;
    pageSize = 10;

    totalRecords = 0;
    totalPages = 0;

    searchKey = '';

    disablePrevious = true;
    disableNext = true;

    columns = [
        {
            label: 'Vendor Name',
            fieldName: 'recordUrl',
            type: 'url',
            typeAttributes: {
                label: {
                    fieldName: 'Name'
                },
                target: '_self'
            }
        },
        {
            label: 'Phone Number',
            fieldName: 'Phone__c',
            type: 'phone'
        },
        {
            label: 'Email',
            fieldName: 'Email__c',
            type: 'email'
        }
    ];

    connectedCallback() {

        this.loadVendors();

    }

    async loadVendors() {

        this.isLoading = true;

        try {

            const result = await getVendors({

                pageNumber: this.pageNumber,
                pageSize: this.pageSize,
                searchKey: this.searchKey

            });

            this.vendors = result.vendors || [];

            this.vendors = this.vendors.map(vendor => {

                return {

                    ...vendor,
                    recordUrl: '/' + vendor.Id

                };

            });

            this.totalRecords = result.totalRecords;

            this.totalPages = Math.ceil(
                this.totalRecords / this.pageSize
            );

            this.disablePrevious =
                this.pageNumber === 1;

            this.disableNext =
                this.pageNumber >= this.totalPages;

        }
        catch (error) {

            this.dispatchEvent(

                new ShowToastEvent({

                    title: 'Error',

                    message:
                        error.body
                            ? error.body.message
                            : error.message,

                    variant: 'error'

                })

            );

        }
        finally {

            this.isLoading = false;

        }

    }

    get startRecord() {

        if (this.totalRecords === 0) {

            return 0;

        }

        return ((this.pageNumber - 1) * this.pageSize) + 1;

    }

    get endRecord() {

        let end = this.pageNumber * this.pageSize;

        return end > this.totalRecords
            ? this.totalRecords
            : end;

    }

    handleSearch(event) {

        this.searchKey = event.target.value;

        this.pageNumber = 1;

        this.loadVendors();

    }

    clearSearch() {

        this.searchKey = '';

        this.pageNumber = 1;

        this.loadVendors();

    }

    refreshVendors() {

        this.pageNumber = 1;

        this.loadVendors();

        this.showToast(

            'Success',

            'Vendor list refreshed.',

            'success'

        );

    }

        handleNewVendor() {

        this.showCreateVendorModal = true;

    }

    closeModal() {

        this.showCreateVendorModal = false;

    }

    handleVendorCreated() {

        this.showCreateVendorModal = false;

        this.pageNumber = 1;

        this.loadVendors();

        this.showToast(
            'Success',
            'Vendor created successfully.',
            'success'
        );

    }

    nextPage() {

        if (this.pageNumber < this.totalPages) {

            this.pageNumber++;

            this.loadVendors();

        }

    }

    previousPage() {

        if (this.pageNumber > 1) {

            this.pageNumber--;

            this.loadVendors();

        }

    }

    showToast(title, message, variant) {

        this.dispatchEvent(

            new ShowToastEvent({

                title: title,

                message: message,

                variant: variant

            })

        );

    }

}