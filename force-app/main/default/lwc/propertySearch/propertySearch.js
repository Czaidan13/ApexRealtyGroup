import { LightningElement, wire } from "lwc";
import { getPicklistValues, getObjectInfo } from "lightning/uiObjectInfoApi";
import PROPERTY_OBJECT from "@salesforce/schema/Property__c";
import STATUS_FIELD from "@salesforce/schema/Property__c.Status__c";
import searchProperties from "@salesforce/apex/PropertySearchController.searchProperties";

export default class PropertySearch extends LightningElement {
    // Search filter properties — store what the user selects in each field
    status = "";
    minPrice = null;
    maxPrice = null;
    bedrooms = null;

    // Results property — stores the list of Properties returned from Apex
    properties = [];

    // Error property — stores any error that comes back from Apex
    error = null;

    // Stores the record type id from the object info — required for getPicklistValues
    recordTypeId;

    // Stores the dynamically fetched status picklist options
    statusOptions = [];

    // Defines the columns displayed in the results table
    columns = [
        { label: "Property Name", fieldName: "Name" },
        { label: "Status", fieldName: "Status__c" },
        { label: "Price", fieldName: "Price__c", type: "currency" },
        { label: "Bedrooms", fieldName: "Bedrooms__c", type: "number" },
        { label: "Address", fieldName: "Address__c" }
    ];

    // Step 1 — Get the object info for Property__c
    // This gives us the default record type Id which is required for getPicklistValues
    @wire(getObjectInfo, { objectApiName: PROPERTY_OBJECT })
    wiredObjectInfo({ data, error }) {
        if (data) {
            // Store the default record type Id from the object metadata
            this.recordTypeId = data.defaultRecordTypeId;
        } else if (error) {
            this.error = error;
        }
    }

    // Step 2 — Get the picklist values for Status__c dynamically from Salesforce metadata
    // This automatically updates if picklist values are added or removed in Setup
    // recordTypeId is required — wire only fires when it has a value
    @wire(getPicklistValues, { recordTypeId: "$recordTypeId", fieldApiName: STATUS_FIELD })
    wiredStatusValues({ data, error }) {
        if (data) {
            // Add an All option at the top to allow clearing the filter
            this.statusOptions = [
                { label: "All", value: "" },
                // Map each picklist value from Salesforce into the format lightning-combobox expects
                ...data.values.map((item) => ({
                    label: item.label,
                    value: item.value
                }))
            ];
        } else if (error) {
            this.error = error;
        }
    }

    // Returns true when a search has been run but no results came back
    get noResults() {
        return this.properties.length === 0 && !this.error;
    }

    // Called every time the user changes the Status dropdown
    handleStatusChange(event) {
        this.status = event.detail.value;
    }

    // Called every time the user types in the Min Price field
    handleMinPriceChange(event) {
        this.minPrice = event.detail.value;
    }

    // Called every time the user types in the Max Price field
    handleMaxPriceChange(event) {
        this.maxPrice = event.detail.value;
    }

    // Called every time the user types in the Bedrooms field
    handleBedroomsChange(event) {
        this.bedrooms = event.detail.value;
    }

    // Called when the user clicks the Search button
    // Calls the Apex method with the current filter values
    handleSearch() {
        searchProperties({
            status: this.status,
            minPrice: this.minPrice,
            maxPrice: this.maxPrice,
            bedrooms: this.bedrooms
        })
            .then((result) => {
                // Apex call succeeded — store the results and clear any previous error
                this.properties = result;
                this.error = null;
            })
            .catch((error) => {
                // Apex call failed — store the error and clear any previous results
                this.error = error;
                this.properties = [];
            });
    }
}
