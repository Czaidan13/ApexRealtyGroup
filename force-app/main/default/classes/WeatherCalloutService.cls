public with sharing class WeatherCalloutService {
    // Wrapper class to hold all weather data returned from the API
    // Used by both the Queueable and Batch jobs to pass data back to the caller
    public class WeatherData {
        public String condition;
        public String iconUrl;
        public Decimal lowTempF;
        public Decimal highTempF;
        public Decimal humidity;
        public Decimal windMph;
        public Decimal uvIndex;
    }

    // Makes an HTTP callout to WeatherAPI and returns a WeatherData wrapper object
    // Uses Named Credential 'WeatherAPI' for the base URL and authentication
    // Returns null if the callout fails or returns a non-200 status code
    public static WeatherData fetchWeather(String location) {
        // Build the HTTP request using the Named Credential for the endpoint
        // The location parameter is appended as a query parameter
        HttpRequest req = new HttpRequest();
        req.setEndpoint('callout:WeatherAPI/v1/forecast.json?days=1&q=' + EncodingUtil.urlEncode(location, 'UTF-8'));
        req.setMethod('GET');

        // Send the request and capture the response
        Http http = new Http();
        HttpResponse res = http.send(req);

        // Only parse the response if the callout was successful
        if (res.getStatusCode() == 200) {
            // Parse the raw JSON string into nested Maps so we can extract individual values
            // JSON.deserializeUntyped returns a generic Object that we cast to a Map
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());

            // Drill into forecast → forecastday[0] → day to reach the daily summary values
            Map<String, Object> forecast = (Map<String, Object>) responseMap.get('forecast');
            List<Object> forecastDays = (List<Object>) forecast.get('forecastday');
            Map<String, Object> day = (Map<String, Object>) ((Map<String, Object>) forecastDays[0]).get('day');

            // Drill into the nested 'condition' object inside 'day' for text and icon
            Map<String, Object> condition = (Map<String, Object>) day.get('condition');

            // Populate the WeatherData wrapper with values from the parsed response
            // Field names match the exact JSON keys returned by WeatherAPI
            WeatherData data = new WeatherData();
            data.condition = (String) condition.get('text');
            data.iconUrl = (String) condition.get('icon');
            data.lowTempF = (Decimal) day.get('mintemp_f');
            data.highTempF = (Decimal) day.get('maxtemp_f');
            data.humidity = (Decimal) day.get('avghumidity');
            data.windMph = (Decimal) day.get('maxwind_mph');
            data.uvIndex = (Decimal) day.get('uv');

            return data;
        }

        // Return null if the callout failed — callers must check for null before using the result
        return null;
    }
}
