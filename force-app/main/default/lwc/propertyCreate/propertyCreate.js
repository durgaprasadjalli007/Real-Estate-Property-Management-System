import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class PropertyCreate extends LightningElement {

    propertyId;

    handleSuccess(event) {

        this.propertyId = event.detail.id;

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Property Created Successfully',
                variant: 'success'
            })
        );
    }

    handleError() {

        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: 'Unable to create Property',
                variant: 'error'
            })
        );
    }

}