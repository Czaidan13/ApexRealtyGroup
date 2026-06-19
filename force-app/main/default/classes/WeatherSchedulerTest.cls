@isTest
public class WeatherSchedulerTest {

    // Mock that simulates a successful 200 forecast response from WeatherAPI
    // Required because the scheduler triggers a batch that makes HTTP callouts
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

    // Tests that scheduling WeatherScheduler enqueues and runs WeatherBatchApex,
    // which in turn populates weather fields on Active Property records
    @isTest
    static void testSchedulerRunsBatchAndUpdatesFields() {
        // Status__c must be 'Active' — the batch only queries Active properties
        Property__c prop = new Property__c(
            Name = 'Scheduled Test Property',
            Status__c = 'Active',
            Address__c = '1600 Amphitheatre Pkwy, Mountain View, CA'
        );
        insert prop;

        // Point all HTTP callouts to the success mock before the scheduler fires
        Test.setMock(HttpCalloutMock.class, new WeatherAPIMock());

        Test.startTest();
        // Schedule the job using a cron expression — Salesforce requires this to register the scheduler
        // Test.stopTest() will force the scheduled job and the batch it triggers to run synchronously
        String jobId = System.schedule(
            'Test Weather Update',
            '0 0 0 1 1 ? 2099',
            new WeatherScheduler()
        );
        // stopTest forces both the scheduled job and the batch it enqueues to complete
        Test.stopTest();

        // Re-query the record to pick up field values written by the batch
        Property__c updated = [
            SELECT Weather_Condition__c, Weather_Icon_URL__c, Low_Temp_F__c,
                   High_Temp_F__c, Humidity__c, Wind_Speed_mph__c,
                   UV_Index__c, Weather_Last_Updated__c
            FROM Property__c
            WHERE Id = :prop.Id
        ];

        // Verify every weather field was populated by the batch that the scheduler triggered
        System.assertEquals('Sunny', updated.Weather_Condition__c, 'Condition should match mock');
        System.assertEquals(65.0, updated.Low_Temp_F__c, 'Low temperature should match mock');
        System.assertEquals(82.0, updated.High_Temp_F__c, 'High temperature should match mock');
        System.assertEquals(60, updated.Humidity__c, 'Humidity should match mock');
        System.assertEquals(10.0, updated.Wind_Speed_mph__c, 'Wind speed should match mock');
        System.assertEquals(5.0, updated.UV_Index__c, 'UV index should match mock');
        System.assertNotEquals(null, updated.Weather_Icon_URL__c, 'Icon URL should be populated');
        System.assertNotEquals(null, updated.Weather_Last_Updated__c, 'Last updated timestamp should be set');

        // Confirm the scheduled job was actually registered in the system
        System.assertNotEquals(null, jobId, 'Scheduler should return a valid job Id');
    }
}
