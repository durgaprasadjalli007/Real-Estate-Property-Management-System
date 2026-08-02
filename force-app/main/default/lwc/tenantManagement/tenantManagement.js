import { LightningElement, wire, track } from 'lwc';

import { NavigationMixin } from 'lightning/navigation';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { deleteRecord } from 'lightning/uiRecordApi';

import { refreshApex } from '@salesforce/apex';

import getTenants
    from '@salesforce/apex/TenantController.getTenants';

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
        label: 'Tenant Name',
        fieldName: 'recordLink',
        type: 'url',

        typeAttributes: {

            label: {

                fieldName: 'Name'

            },

            target: '_self'

        },

        sortable: true

    },

    {
        label: 'Phone Number',
        fieldName: 'Phone_Number__c',
        type: 'phone',
        sortable: true
    },

    {
        label: 'Email',
        fieldName: 'Email__c',
        type: 'email',
        sortable: true
    },

    {

        type: 'action',

        typeAttributes: {

            rowActions: ROW_ACTIONS

        }

    }

];

export default class TenantManagement extends NavigationMixin(LightningElement) {

    columns = COLUMNS;

    @track tenants = [];

    allTenants = [];

    wiredResult;

    isLoading = true;

    searchKey = '';

    pageNumber = 1;

    pageSize = 10;

    totalRecords = 0;

    totalPages = 0;

    startRecord = 0;

    endRecord = 0;

    sortedBy = 'Name';

    sortDirection = 'asc';

    @wire(getTenants)

    wiredTenants(result) {

        this.wiredResult = result;

        if (result.data) {

            this.allTenants = result.data.map(record => {

                return {

                    ...record,

                    recordLink: '/' + record.Id

                };

            });

            this.filterData();

        }

        else if (result.error) {

            console.error(result.error);

            this.showToast(

                'Error',

                'Unable to load tenants.',

                'error'

            );

        }

        this.isLoading = false;

    }

    handleSearch(event) {

        this.searchKey = event.target.value;

        this.filterData();

    }

    filterData() {

        let filtered = [...this.allTenants];

        if (this.searchKey) {

            const keyword = this.searchKey.toLowerCase();

            filtered = filtered.filter(tenant =>

                (tenant.Name &&
                    tenant.Name.toLowerCase().includes(keyword))

                ||

                (tenant.Phone_Number__c &&
                    tenant.Phone_Number__c.includes(keyword))

                ||

                (tenant.Email__c &&
                    tenant.Email__c.toLowerCase().includes(keyword))

            );

        }

        this.totalRecords = filtered.length;

        this.totalPages =

            Math.ceil(

                this.totalRecords / this.pageSize

            ) || 1;

        this.pageNumber = 1;

        this.updatePage(filtered);

        }    updatePage(records) {

        const startIndex =

            (this.pageNumber - 1) * this.pageSize;

        const endIndex =

            startIndex + this.pageSize;

        this.tenants =

            records.slice(startIndex, endIndex);

        this.startRecord =

            this.totalRecords === 0

                ? 0

                : startIndex + 1;

        this.endRecord =

            Math.min(endIndex, this.totalRecords);

    }

    filteredTenants() {

        let filtered = [...this.allTenants];

        if (this.searchKey) {

            const keyword =

                this.searchKey.toLowerCase();

            filtered = filtered.filter(tenant =>

                (tenant.Name &&
                    tenant.Name.toLowerCase().includes(keyword))

                ||

                (tenant.Phone_Number__c &&
                    tenant.Phone_Number__c.includes(keyword))

                ||

                (tenant.Email__c &&
                    tenant.Email__c.toLowerCase().includes(keyword))

            );

        }

        return filtered;

    }

    previousPage() {

        if (this.pageNumber > 1) {

            this.pageNumber--;

            this.updatePage(

                this.filteredTenants()

            );

        }

    }

    nextPage() {

        if (this.pageNumber < this.totalPages) {

            this.pageNumber++;

            this.updatePage(

                this.filteredTenants()

            );

        }

    }

    get disablePrevious() {

        return this.pageNumber === 1;

    }

    get disableNext() {

        return this.pageNumber === this.totalPages;

    }

    handleSort(event) {

        this.sortedBy =
            event.detail.fieldName;

        this.sortDirection =
            event.detail.sortDirection;

        const clonedData =
            [...this.filteredTenants()];

        clonedData.sort((first, second) => {

            let value1 =
                first[this.sortedBy] || '';

            let value2 =
                second[this.sortedBy] || '';

            if (typeof value1 === 'string') {

                value1 =
                    value1.toLowerCase();

            }

            if (typeof value2 === 'string') {

                value2 =
                    value2.toLowerCase();

            }

            if (value1 > value2) {

                return this.sortDirection === 'asc'
                    ? 1
                    : -1;

            }

            if (value1 < value2) {

                return this.sortDirection === 'asc'
                    ? -1
                    : 1;

            }

            return 0;

        });

        this.pageNumber = 1;

        this.updatePage(clonedData);

    }

    refreshTenants() {

        this.isLoading = true;

        refreshApex(this.wiredResult)

            .finally(() => {

                this.isLoading = false;

            });

    }

    clearFilters() {

        this.searchKey = '';

        this.filterData();

    }
        handleNewTenant() {

        this[NavigationMixin.Navigate]({

            type: 'standard__objectPage',

            attributes: {

                objectApiName: 'Tenant__c',

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

                this.deleteTenant(row.Id);

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

                objectApiName: 'Tenant__c',

                actionName: 'view'

            }

        });

    }

    editRecord(recordId) {

        this[NavigationMixin.Navigate]({

            type: 'standard__recordPage',

            attributes: {

                recordId: recordId,

                objectApiName: 'Tenant__c',

                actionName: 'edit'

            }

        });

    }

    async deleteTenant(recordId) {

        try {

            await deleteRecord(recordId);

            this.showToast(

                'Success',

                'Tenant deleted successfully.',

                'success'

            );

            await refreshApex(this.wiredResult);

        }

        catch (error) {

            console.error(error);

            this.showToast(

                'Error',

                error.body?.message ||

                'Unable to delete Tenant.',

                'error'

            );

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