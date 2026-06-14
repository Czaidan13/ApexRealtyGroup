import { LightningElement, api, wire } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import getOffers from "@salesforce/apex/OfferComparisonController.getOffers";
import acceptOffer from "@salesforce/apex/OfferComparisonController.acceptOffer";

export default class OfferComparison extends LightningElement {
    // @api makes recordId settable from the Lightning record page
    // Salesforce automatically passes the current record Id into this property
    @api recordId;

    // Stores the offers returned from Apex
    offers;

    // Stores any error that occurs
    error;

    // Controls the loading spinner
    isLoading = true;

    // Stores the currently selected offer row
    selectedOffer;

    // Stores the raw wire result so we can refresh it after accepting an offer
    wiredOffersResult;

    // Column definitions for the data table
    columns = [
        { label: "Offer Name", fieldName: "Name" },
        { label: "Amount", fieldName: "Offer_Amount__c", type: "currency" },
        { label: "Status", fieldName: "Status__c" },
        { label: "Expiration Date", fieldName: "Expiration_Date__c", type: "date" },
        { label: "Financing Type", fieldName: "Financing_Type__c" }
    ];

    // Automatically fetches offers when the component loads
    // '$recordId' is reactive — re-fires if recordId changes
    @wire(getOffers, { propertyId: "$recordId" })
    wiredOffers(result) {
        // Store the raw result so we can call refreshApex later
        this.wiredOffersResult = result;
        if (result.data) {
            this.offers = result.data;
            this.error = undefined;
            this.isLoading = false;
        } else if (result.error) {
            this.error = result.error;
            this.offers = undefined;
            this.isLoading = false;
        }
    }

    // Returns true when offers have loaded and at least one exists
    get hasOffers() {
        return this.offers && this.offers.length > 0;
    }

    // Returns true when offers have loaded but none exist
    get noOffers() {
        return this.offers && this.offers.length === 0;
    }

    // Shows the Accept button only when a Pending offer is selected
    // Hides it if the selected offer is already Accepted or Withdrawn
    get showAcceptButton() {
        return this.selectedOffer && this.selectedOffer.Status__c === "Pending";
    }

    // Fires when the user selects a row in the datatable
    // Stores the selected offer or clears it if deselected
    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            this.selectedOffer = selectedRows[0];
        } else {
            this.selectedOffer = null;
        }
    }

    // Fires when the Accept button is clicked
    // Calls the Apex method to accept the selected offer
    handleAccept() {
        acceptOffer({ offerId: this.selectedOffer.Id })
            .then(() => {
                // Show a success toast notification
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Success",
                        message: "Offer accepted successfully",
                        variant: "success"
                    })
                );
                // Clear the selected offer
                this.selectedOffer = null;
                // Refresh the wire data so the table updates automatically
                return refreshApex(this.wiredOffersResult);
            })
            .catch((error) => {
                // Show an error toast notification
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error",
                        message: "Failed to accept offer",
                        variant: "error"
                    })
                );
                this.error = error;
            });
    }
}
