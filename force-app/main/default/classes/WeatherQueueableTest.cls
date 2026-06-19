@isTest
public class WeatherQueueableTest {

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
    // Used to verify the Queueable handles null gracefully and leaves fields blank
    public class WeatherAPIFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":{"code":1002,"message":"API key is invalid"}}');
            return res;
        }
    }

    // Tests the happy path: enqueuing a WeatherQueueable job populates all weather fields
    // on the Property record after the async job runs synchronously inside Test.stopTest()
    @isTest
    static void testWeatherFieldsPopulatedOnSuccess() {
        // Create a test Property record with an address the Queueable will pass to the API
        Property__c prop = new Property__c(
            Name = 'Test Property',
            Address__c = '1600 Amphitheatre Pkwy, Mountain View, CA'
        );
        insert prop;

        // Point all HTTP callouts to the success mock — must be set before enqueueJob
        Test.setMock(HttpCalloutMock.class, new WeatherAPIMock());

        // Enqueue the job inside startTest/stopTest so the async context is captured
        Test.startTest();
        System.enqueueJob(new WeatherQueueable(prop.Id));
        // stopTest forces the queued job to execute synchronously before assertions run
        Test.stopTest();

        // Re-query the Property to pick up the field values written by the Queueable
        Property__c updated = [
            SELECT Weather_Condition__c, Weather_Icon_URL__c, Low_Temp_F__c,
                   High_Temp_F__c, Humidity__c, Wind_Speed_mph__c,
                   UV_Index__c, Weather_Last_Updated__c
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
        // Weather_Last_Updated__c is stamped inside the Queueable — just verify it was set
        System.assertNotEquals(null, updated.Weather_Last_Updated__c, 'Last updated timestamp should be set');
    }

    // Tests the failure path: when the API returns a non-200 status, WeatherCalloutService
    // returns null and the Queueable should not update any fields on the Property
    @isTest
    static void testWeatherFieldsNotPopulatedOnFailure() {
        // Create a test Property record — fields should remain blank after a failed callout
        Property__c prop = new Property__c(
            Name = 'Test Property Fail',
            Address__c = '742 Evergreen Terrace, Springfield'
        );
        insert prop;

        // Point all callouts to the failure mock to simulate an API error
        Test.setMock(HttpCalloutMock.class, new WeatherAPIFailMock());

        Test.startTest();
        System.enqueueJob(new WeatherQueueable(prop.Id));
        // stopTest forces the queued job to run; the null check in execute() should prevent updates
        Test.stopTest();

        // Re-query and confirm the weather fields were never written
        Property__c unchanged = [
            SELECT Weather_Condition__c, Low_Temp_F__c, Weather_Last_Updated__c
            FROM Property__c
            WHERE Id = :prop.Id
        ];

        System.assertEquals(null, unchanged.Weather_Condition__c, 'Condition should be null after failed callout');
        System.assertEquals(null, unchanged.Low_Temp_F__c, 'Low temperature should be null after failed callout');
        System.assertEquals(null, unchanged.Weather_Last_Updated__c, 'Last updated should be null after failed callout');
    }
}
