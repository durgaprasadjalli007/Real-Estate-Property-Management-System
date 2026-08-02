import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getProperties from '@salesforce/apex/PropertyController.getProperties';

import PROPERTY_OBJECT from '@salesforce/schema/Property__c';
import STATUS_FIELD from '@salesforce/schema/Property__c.Status__c';
import FURNISHING_FIELD from '@salesforce/schema/Property__c.Furnishing_Status__c';

import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class PropertyList extends NavigationMixin(LightningElement) {

    @track properties = [];
    @track isLoading = false;
    @track properties = [];
    @track isLoading = false;
    @track showCreatePropertyModal = false;

    pageNumber = 1;
    pageSize = 25;

    totalRecords = 0;
    totalPages = 0;

    maxPrice;
    status = '';
    furnishingStatus = '';

    disablePrevious = true;
    disableNext = true;

    statusOptions = [];
    furnishingOptions = [];

    distance;

latitude;

longitude;

  

    columns = [
    {
        label: 'Property Name',
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
        label: 'City',
        fieldName: 'City__c',
        type: 'text'
    },
    {
        label: 'Type',
        fieldName: 'Type__c',
        type: 'text'
    },
    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'text'
    },
{
        label: 'Furnishing Status',
        fieldName: 'Furnishing_Status__c',
        type: 'text'
    },

    
    {
        label: 'Rent',
        fieldName: 'Rent__c',
        type: 'currency',
        typeAttributes: {
            currencyCode: 'INR'
        }
    },
    
];
    connectedCallback() {
        this.loadProperties();
    }

    @wire(getObjectInfo, {
        objectApiName: PROPERTY_OBJECT
    })
    propertyInfo;

    @wire(getPicklistValues, {
        recordTypeId: '$propertyInfo.data.defaultRecordTypeId',
        fieldApiName: STATUS_FIELD
    })
    wiredStatus({ data, error }) {

        if (data) {

            this.statusOptions = [
                {
                    label: 'All',
                    value: ''
                },
                ...data.values
            ];

        } else if (error) {

            console.error(error);

        }

    }

    @wire(getPicklistValues, {
        recordTypeId: '$propertyInfo.data.defaultRecordTypeId',
        fieldApiName: FURNISHING_FIELD
    })
    wiredFurnishing({ data, error }) {

        if (data) {

            this.furnishingOptions = [
                {
                    label: 'All',
                    value: ''
                },
                ...data.values
            ];

        } else if (error) {

            console.error(error);

        }

    }
        async loadProperties() {

        this.isLoading = true;

        try {

            const result = await getProperties({

                pageNumber: this.pageNumber,
                pageSize: this.pageSize,
                maxPrice: this.maxPrice,
                status: this.status,
                furnishingStatus: this.furnishingStatus

            });

            this.properties = result.properties || [];

            this.properties = this.properties.map(property => {

                return {

                    ...property,
                    recordUrl: '/' + property.Id

                };

            });

            this.totalRecords = result.totalRecords;
            this.totalPages = Math.ceil(this.totalRecords / this.pageSize);

            this.disablePrevious = this.pageNumber === 1;
            this.disableNext = this.pageNumber >= this.totalPages;

        }
      catch (error) {

    console.log(JSON.stringify(error));
    console.log(error);

    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error',
            message: error.body ? error.body.message : error.message,
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

    nextPage() {

        if (this.pageNumber < this.totalPages) {

            this.pageNumber++;
            this.loadProperties();

        }

    }

    previousPage() {

        if (this.pageNumber > 1) {

            this.pageNumber--;
            this.loadProperties();

        }

    }
        handleSearch() {

        this.pageNumber = 1;
        this.loadProperties();

    }

    refreshProperties() {

        this.pageNumber = 1;
        this.maxPrice = null;
        this.status = '';
        this.furnishingStatus = '';

        this.loadProperties();

        this.showToast(
            'Success',
            'Property list refreshed.',
            'success'
        );

    }

    

    handleNewProperty() {

    this.showCreatePropertyModal = true;

    }

    closeModal() {

    this.showCreatePropertyModal = false;

}

handlePropertyCreated() {

    this.showCreatePropertyModal = false;

    this.pageNumber = 1;

    this.loadProperties();

    this.showToast(
        'Success',
        'Property created successfully.',
        'success'
    );

}

    handlePriceChange(event) {

        this.maxPrice = event.target.value;

    }

    handleStatusChange(event) {

        this.status = event.detail.value;

    }

    handleFurnishingChange(event) {

        this.furnishingStatus = event.detail.value;

    }

    handleClearFilters() {

    this.maxPrice = null;

    this.status = '';

    this.furnishingStatus = '';

    this.pageNumber = 1;

    this.handleSearch();

}

handleDistanceChange(event) {

    this.distance = event.target.value;

}

getCurrentLocation() {

    if (!navigator.geolocation) {

        this.showToast(
            'Error',
            'Geolocation is not supported.',
            'error'
        );

        return;

    }

    navigator.geolocation.getCurrentPosition(

        (position) => {

            this.latitude = position.coords.latitude;

            this.longitude = position.coords.longitude;

            this.showToast(
                'Success',
                'Current location captured.',
                'success'
            );

        },

        () => {

            this.showToast(
                'Error',
                'Unable to access current location.',
                'error'
            );

        }

    );

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