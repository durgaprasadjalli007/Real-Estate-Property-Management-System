import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';

import getMaintenanceRequests
    from '@salesforce/apex/MaintenanceRequestController.getMaintenanceRequests';

const ROW_ACTIONS = [

    {
        label: 'View',
        name: 'view'
    },

    {
        label: 'Edit',
        name: 'edit'
    },

    {
        label: 'Delete',
        name: 'delete'
    }

];

const COLUMNS = [

    {
        label: 'Request Number',
        fieldName: 'Name',
        type: 'text',
        sortable: true
    },

    {
        label: 'Property',
        fieldName: 'propertyName',
        type: 'text',
        sortable: true
    },

    {
        label: 'Vendor',
        fieldName: 'vendorName',
        type: 'text',
        sortable: true
    },

    {
        label: 'Status',
        fieldName: 'Status__c',
        type: 'text',
        sortable: true
    },

    {
        label: 'Description',
        fieldName: 'Description__c',
        type: 'text',
        wrapText: true
    },

    {
        type: 'action',

        typeAttributes: {

            rowActions: ROW_ACTIONS

        }

    }

];

export default class MaintenanceRequestManagement extends NavigationMixin(LightningElement) {

    columns = COLUMNS;
    sortedBy = 'Name';

    sortDirection = 'asc';

    @track requests = [];

    allRequests = [];

    wiredResult;

    isLoading = true;

    searchKey = '';

    status = '';

    pageNumber = 1;

    pageSize = 10;

    totalRecords = 0;

    totalPages = 0;

    startRecord = 0;

    endRecord = 0;

    statusOptions = [

        {
            label: 'All',
            value: ''
        },

        {
            label: 'Open',
            value: 'Open'
        },

        {
            label: 'In Progress',
            value: 'In Progress'
        },

        {
            label: 'Completed',
            value: 'Completed'
        },

        {
            label: 'Cancelled',
            value: 'Cancelled'
        }

    ];

    @wire(getMaintenanceRequests)
wiredMaintenanceRequests(result) {

    this.wiredResult = result;

    if (result.data) {

        this.allRequests = result.data.map(record => {

            return {

                ...record,

                propertyName: record.Property__r
                    ? record.Property__r.Name
                    : '',

                vendorName: record.Vendor__r
                    ? record.Vendor__r.Name
                    : ''

            };

        });

        this.filterData();

    }
    else if (result.error) {

        console.error(result.error);

        this.showToast(
            'Error',
            'Unable to load maintenance requests.',
            'error'
        );

    }

    this.isLoading = false;

}

handleSearch(event) {

    this.searchKey = event.target.value;

    this.filterData();

}

handleStatusChange(event) {

    this.status = event.detail.value;

    this.filterData();

}

filterData() {

    let filteredRequests = [...this.allRequests];

    if (this.status) {

        filteredRequests = filteredRequests.filter(

            request => request.Status__c === this.status

        );

    }

    if (this.searchKey) {

        const keyword = this.searchKey.toLowerCase();

        filteredRequests = filteredRequests.filter(request =>

            (request.Description__c &&
                request.Description__c.toLowerCase().includes(keyword))

            ||

            (request.propertyName &&
                request.propertyName.toLowerCase().includes(keyword))

            ||

            (request.vendorName &&
                request.vendorName.toLowerCase().includes(keyword))

            ||

            (request.Name &&
                request.Name.toLowerCase().includes(keyword))

        );

    }

    this.totalRecords = filteredRequests.length;

    this.totalPages = Math.ceil(
        this.totalRecords / this.pageSize
    );

    if (this.totalPages === 0) {

        this.totalPages = 1;

    }

    this.pageNumber = 1;

    this.updatePage(filteredRequests);

}

updatePage(records) {

    const startIndex =
        (this.pageNumber - 1) * this.pageSize;

    const endIndex =
        startIndex + this.pageSize;

    this.requests =
        records.slice(startIndex, endIndex);

    this.startRecord =
        this.totalRecords === 0
            ? 0
            : startIndex + 1;

    this.endRecord =
        Math.min(endIndex, this.totalRecords);

}

filteredRequests() {

    let filtered = [...this.allRequests];

    if (this.status) {

        filtered = filtered.filter(

            request => request.Status__c === this.status

        );

    }

    if (this.searchKey) {

        const keyword = this.searchKey.toLowerCase();

        filtered = filtered.filter(request =>

            (request.Description__c &&
                request.Description__c.toLowerCase().includes(keyword))

            ||

            (request.propertyName &&
                request.propertyName.toLowerCase().includes(keyword))

            ||

            (request.vendorName &&
                request.vendorName.toLowerCase().includes(keyword))

            ||

            (request.Name &&
                request.Name.toLowerCase().includes(keyword))

        );

    }

    return filtered;

}

previousPage() {

    if (this.pageNumber > 1) {

        this.pageNumber--;

        this.updatePage(this.filteredRequests());

    }

}

nextPage() {

    if (this.pageNumber < this.totalPages) {

        this.pageNumber++;

        this.updatePage(this.filteredRequests());

    }

}

get disablePrevious() {

    return this.pageNumber === 1;

}

get disableNext() {

    return this.pageNumber === this.totalPages;

}

refreshRequests() {

    this.isLoading = true;

    refreshApex(this.wiredResult)
        .finally(() => {

            this.isLoading = false;

        });

}

clearFilters() {

    this.searchKey = '';

    this.status = '';

    this.filterData();

}
handleNewRequest() {

    this[NavigationMixin.Navigate]({

        type: 'standard__objectPage',

        attributes: {

            objectApiName: 'Maintenance_Request__c',

            actionName: 'new'

        }

    });

}

handleRowAction(event) {

    const actionName = event.detail.action.name;

    const row = event.detail.row;

    switch (actionName) {

        case 'view':

            this.viewRecord(row.Id);

            break;

        case 'edit':

            this.editRecord(row.Id);

            break;

        case 'delete':

            this.deleteMaintenanceRequest(row.Id);

            break;

        default:

            break;

    }

}

viewRecord(recordId) {

    this[NavigationMixin.Navigate]({

        type: 'standard__recordPage',

        attributes: {

            recordId: recordId,

            objectApiName: 'Maintenance_Request__c',

            actionName: 'view'

        }

    });

}

editRecord(recordId) {

    this[NavigationMixin.Navigate]({

        type: 'standard__recordPage',

        attributes: {

            recordId: recordId,

            objectApiName: 'Maintenance_Request__c',

            actionName: 'edit'

        }

    });

}

async deleteMaintenanceRequest(recordId) {

    try {

        await deleteRecord(recordId);

        this.showToast(

            'Success',

            'Maintenance Request deleted successfully.',

            'success'

        );

        await refreshApex(this.wiredResult);

    }

    catch(error) {

        console.error(error);

        this.showToast(

            'Error',

            error.body?.message || 'Unable to delete Maintenance Request.',

            'error'

        );

    }

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
}