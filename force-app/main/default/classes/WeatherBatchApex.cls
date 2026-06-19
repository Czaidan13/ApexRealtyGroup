public class WeatherBatchApex implements Database.Batchable<SObject>, Database.AllowsCallouts {
    // start() defines which records to process
    // Database.getQueryLocator returns an iterable of records Salesforce will chunk into batches
    // Only querying Active properties — no need to refresh weather on Sold or Withdrawn listings
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(
            [
                SELECT Id, Address__c
                FROM Property__c
                WHERE Status__c = 'Active'
            ]
        );
    }

    // execute() is called once per batch chunk — default chunk size is 200 records
    // Database.AllowsCallouts on the class declaration enables HTTP callouts inside this method
    // scope contains the current chunk of Property records being processed
    public void execute(Database.BatchableContext context, List<SObject> scope) {
        // Cast the generic SObject list to a typed List<Property__c>
        List<Property__c> properties = (List<Property__c>) scope;

        for (Property__c prop : properties) {
            // Only fetch weather if the property has an address
            // Properties without an address would cause the callout to fail
            if (prop.Address__c != null) {
                // Call the weather service to fetch forecast conditions for this property
                // fetchWeather returns null if the callout fails or returns a non-200 status
                WeatherCalloutService.WeatherData weather = WeatherCalloutService.fetchWeather(prop.Address__c);

                // Only update fields if the callout was successful
                if (weather != null) {
                    prop.Weather_Condition__c = weather.condition;
                    prop.Weather_Icon_URL__c = weather.iconUrl;
                    prop.Low_Temp_F__c = weather.lowTempF;
                    prop.High_Temp_F__c = weather.highTempF;
                    prop.Humidity__c = weather.humidity;
                    prop.Wind_Speed_mph__c = weather.windMph;
                    prop.UV_Index__c = weather.uvIndex;
                    // Stamp the current date and time so users know when data was last refreshed
                    prop.Weather_Last_Updated__c = DateTime.now();
                }
            }
        }

        // Bulk update all properties in this batch chunk in a single DML statement
        // Runs after all callouts in this chunk are complete
        update properties;
    }

    // finish() is required by the Database.Batchable interface
    // Runs once after all batch chunks have been processed
    // No action needed here — weather updates are complete at this point
    public void finish(Database.BatchableContext context) {
    }
}
