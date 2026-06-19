import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

// Import each weather field as a schema reference
// Schema imports are validated at deploy time — typos fail early instead of silently at runtime
import WEATHER_CONDITION from "@salesforce/schema/Property__c.Weather_Condition__c";
import WEATHER_ICON_URL from "@salesforce/schema/Property__c.Weather_Icon_URL__c";
import LOW_TEMP_F from "@salesforce/schema/Property__c.Low_Temp_F__c";
import HIGH_TEMP_F from "@salesforce/schema/Property__c.High_Temp_F__c";
import HUMIDITY from "@salesforce/schema/Property__c.Humidity__c";
import WIND_SPEED from "@salesforce/schema/Property__c.Wind_Speed_mph__c";
import UV_INDEX from "@salesforce/schema/Property__c.UV_Index__c";
import WEATHER_LAST_UPDATED from "@salesforce/schema/Property__c.Weather_Last_Updated__c";

// Collect all fields into one array to pass to the getRecord wire adapter
const FIELDS = [
    WEATHER_CONDITION,
    WEATHER_ICON_URL,
    LOW_TEMP_F,
    HIGH_TEMP_F,
    HUMIDITY,
    WIND_SPEED,
    UV_INDEX,
    WEATHER_LAST_UPDATED
];

export default class PropertyWeather extends LightningElement {
    // @api makes recordId settable from the Lightning record page
    // Salesforce automatically passes the current record Id into this property
    @api recordId;

    // Automatically fetches the Property record with all weather fields
    // getRecord is a built in Salesforce wire adapter from lightning/uiRecordApi
    // '$recordId' is reactive — re-fires if the record Id changes
    @wire(getRecord, { recordId: "$recordId", fields: FIELDS })
    property;

    // getFieldValue safely extracts a field value from the wired record
    // Returns null instead of throwing if the record hasn't loaded yet

    get condition() {
        return getFieldValue(this.property.data, WEATHER_CONDITION);
    }

    get iconUrl() {
        // WeatherAPI returns protocol-relative URLs starting with //cdn.weatherapi.com/...
        // Prefix with https: so the browser can load the image correctly
        const icon = getFieldValue(this.property.data, WEATHER_ICON_URL);
        return icon ? "https:" + icon : null;
    }

    get lowTempF() {
        return getFieldValue(this.property.data, LOW_TEMP_F);
    }

    get highTempF() {
        return getFieldValue(this.property.data, HIGH_TEMP_F);
    }

    get humidity() {
        return getFieldValue(this.property.data, HUMIDITY);
    }

    get windSpeed() {
        return getFieldValue(this.property.data, WIND_SPEED);
    }

    get uvIndex() {
        return getFieldValue(this.property.data, UV_INDEX);
    }

    get lastUpdated() {
        return getFieldValue(this.property.data, WEATHER_LAST_UPDATED);
    }

    // Calculates the percentage width of the gradient fill inside the temperature range bar
    // Formula: ((highTempF - lowTempF) / 100) * 100, capped between 10 and 100
    // The floor of 10 ensures the bar always has a visible fill even on small ranges
    get tempBarWidth() {
        const low = this.lowTempF || 0;
        const high = this.highTempF || 0;
        const width = ((high - low) / 100) * 100;
        return Math.min(100, Math.max(10, width));
    }

    // Builds the full inline style string for the gradient fill div inside the temperature bar
    // Constructed here because LWC templates cannot evaluate expressions inside style attributes
    get tempBarStyle() {
        return `width: ${this.tempBarWidth}%; height: 100%; background: linear-gradient(to right, #4a90d9, #f5a623); border-radius: 4px;`;
    }

    // Formats the raw ISO timestamp into a readable format like 6/19/2026 - 3:55 PM
    // toLocaleDateString and toLocaleTimeString use the browser's locale for formatting
    get formattedLastUpdated() {
        const raw = getFieldValue(this.property.data, WEATHER_LAST_UPDATED);
        if (!raw) return null;
        const date = new Date(raw);
        return (
            date.toLocaleDateString("en-US") +
            " - " +
            date.toLocaleTimeString("en-US", {
                hour: "numeric",
                minute: "2-digit",
                hour12: true
            })
        );
    }

    // Returns true only when the record has loaded and weather data exists
    // Used in HTML to conditionally render the widget vs a placeholder message
    get hasWeatherData() {
        return this.property.data && this.condition;
    }
}
