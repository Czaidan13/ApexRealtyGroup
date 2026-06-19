@isTest
public class WeatherBatchApexTest {
    // Mock that simulates a successful 200 forecast response from WeatherAPI
    // Returns hardcoded values so assertions are deterministic
    public class WeatherAPIMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(
                '{"forecast":{"forecastday":[{"day":{"maxtemp_f":82.0,"mintemp_f":65.0,"avghumidity":60,"maxwind_mph":10.0,"uv":5.0,"condition":{"text":"Sunny","icon":"//cdn.weatherapi.com/weather/64x64/day/113.png"}}}]}}'
            );
            return res;
        }
    }

    // Mock that simulates a failed API response (e.g. invalid key, server error)
    // Used to verify the batch handles null gracefully and leaves fields blank
    public class WeatherAPIFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":{"code":1002,"message":"API key is invalid"}}');
            return res;
        }
    }

    // Tests the happy path: running the batch populates all weather fields on Active Properties
    @isTest
    static void testBatchUpdatesWeatherFields() {
        // Status__c must be 'Active' — the batch query only processes Active properties
        Property__c prop = new Property__c(
            Name = 'Test Property',
            Status__c = 'Active',
            Address__c = '1600 Amphitheatre Pkwy, Mountain View, CA'
        );
        insert prop;

        // Point all HTTP callouts to the success mock — must be set before executeBatch
        Test.setMock(HttpCalloutMock.class, new WeatherAPIMock());

        // Execute the batch inside startTest/stopTest so the async job runs synchronously
        Test.startTest();
        Database.executeBatch(new WeatherBatchApex());
        // stopTest forces the batch to complete before assertions run
        Test.stopTest();

        // Re-query the record to pick up the field values written by the batch
        // Asserting against the original variable would always show null (DML updates the DB, not the local object)
        Property__c updated = [
            SELECT
                Weather_Condition__c,
                Weather_Icon_URL__c,
                Low_Temp_F__c,
                High_Temp_F__c,
                Humidity__c,
                Wind_Speed_mph__c,
                UV_Index__c,
                Weather_Last_Updated__c
            FROM Property__c
            WHERE Id = :prop.Id
        ];

        // Verify every weather field was written with the values from the mock response
        System.assertEquals('Sunny', updated.Weather_Condition__c, 'Condition should match mock');
        System.assertEquals(65.0, updated.Low_Temp_F__c, 'Low temperature should match mock');
        System.assertEquals(82.0, updated.High_Temp_F__c, 'High temperature should match mock');
        System.assertEquals(60, updated.Humidity__c, 'Humidity should match mock');
        System.assertEquals(10.0, updated.Wind_Speed_mph__c, 'Wind speed should match mock');
        System.assertEquals(5.0, updated.UV_Index__c, 'UV index should match mock');
        System.assertNotEquals(null, updated.Weather_Icon_URL__c, 'Icon URL should be populated');
        // Just verify the timestamp was stamped — exact value will differ from System.now()
        System.assertNotEquals(null, updated.Weather_Last_Updated__c, 'Last updated timestamp should be set');
    }

    // Tests the failure path: when the API returns a non-200 status the batch should
    // leave all weather fields null rather than throwing an error
    @isTest
    static void testBatchDoesNotUpdateFieldsOnFailure() {
        // Status__c must be 'Active' so the batch picks up this record
        Property__c prop = new Property__c(
            Name = 'Test Property Fail',
            Status__c = 'Active',
            Address__c = '742 Evergreen Terrace, Springfield'
        );
        insert prop;

        // Point all callouts to the failure mock to simulate an API error
        Test.setMock(HttpCalloutMock.class, new WeatherAPIFailMock());

        Test.startTest();
        Database.executeBatch(new WeatherBatchApex());
        // stopTest forces the batch to run; the null check in execute() should prevent updates
        Test.stopTest();

        // Re-query and confirm the weather fields were never written
        Property__c unchanged = [
            SELECT Weather_Condition__c, Low_Temp_F__c, Weather_Last_Updated__c
            FROM Property__c
            WHERE Id = :prop.Id
        ];

        System.assertEquals(null, unchanged.Weather_Condition__c, 'Condition should be null after failed callout');
        System.assertEquals(null, unchanged.Low_Temp_F__c, 'Low temperature should be null after failed callout');
        System.assertEquals(
            null,
            unchanged.Weather_Last_Updated__c,
            'Last updated should be null after failed callout'
        );
    }
}
