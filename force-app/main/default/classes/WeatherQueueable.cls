public class WeatherQueueable implements Queueable, Database.AllowsCallouts {
    // Stores the Property Id passed in when the job is enqueued
    // Used to query the correct Property record in the execute method
    private Id propertyId;

    // Constructor receives the Property Id from the trigger
    // Called via System.enqueueJob(new WeatherQueueable(propertyId)) in PropertyTrigger
    public WeatherQueueable(Id propertyId) {
        this.propertyId = propertyId;
    }

    // Salesforce calls this method when the queued job runs asynchronously
    // Runs in a separate transaction from the trigger — allows HTTP callouts
    // Database.AllowsCallouts on the class declaration enables the callout
    public void execute(QueueableContext context) {
        // Query the Property record to get the address for the weather callout
        Property__c prop = [SELECT Id, Name, Status__c, Address__c FROM Property__c WHERE Id = :propertyId LIMIT 1];

        // Call the weather service to fetch forecast conditions for this property's location
        // fetchWeather returns null if the callout fails or returns a non-200 status
        WeatherCalloutService.WeatherData weather = WeatherCalloutService.fetchWeather(prop.Address__c);

        // Only update the Property if the callout was successful
        // Null check prevents errors if the API call failed
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
            update prop;
        }
    }
}
