import { LightningElement, api, wire } from "lwc";
import getAgentStats from "@salesforce/apex/AgentDashboardController.getAgentStats";

export default class AgentDashboard extends LightningElement {
    // @api makes this property settable from outside the component
    // recordId is automatically populated by the Lightning record page
    @api recordId;

    // Stores the stats returned from Apex
    stats;

    // Stores any error that occurs
    error;

    // Controls the loading spinner visibility
    isLoading = true;

    // Automatically calls getAgentStats when the component loads
    // '$recordId' is reactive — wire re-fires if recordId changes
    // cacheable=true on the Apex method is required for @wire
    @wire(getAgentStats, { agentId: "$recordId" })
    wiredStats({ data, error }) {
        if (data) {
            // Data returned successfully — store it and hide the spinner
            this.stats = data;
            this.error = undefined;
            this.isLoading = false;
        } else if (error) {
            // Something went wrong — store the error and hide the spinner
            this.error = error;
            this.stats = undefined;
            this.isLoading = false;
        }
    }

    // Getter that formats the commission amount as currency
    // Returns a formatted string like $12,500.00
    get formattedCommission() {
        if (!this.stats) return "$0.00";
        return new Intl.NumberFormat("en-US", {
            style: "currency",
            currency: "USD"
        }).format(this.stats.commissionYTD);
    }
}
