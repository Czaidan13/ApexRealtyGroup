@isTest
public class WeatherCalloutServiceTest {
    // Mock class that simulates a successful WeatherAPI forecast response
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

    // Mock class that simulates a failed WeatherAPI response
    public class WeatherAPIFailMock implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(401);
            res.setBody('{"error":{"code":1002,"message":"API key is invalid"}}');
            return res;
        }
    }

    // Tests that a successful callout correctly parses and returns weather data
    @isTest
    static void testFetchWeatherSuccess() {
        Test.setMock(HttpCalloutMock.class, new WeatherAPIMock());
        WeatherCalloutService.WeatherData result = WeatherCalloutService.fetchWeather('Columbus, OH');

        System.assertEquals('Sunny', result.condition);
        System.assertEquals(65.0, result.lowTempF);
        System.assertEquals(82.0, result.highTempF);
        System.assertEquals(60, result.humidity);
        System.assertEquals(10.0, result.windMph);
        System.assertEquals(5.0, result.uvIndex);
        System.assertNotEquals(null, result.iconUrl);
    }

    // Tests that a failed callout returns null instead of throwing an error
    @isTest
    static void testFetchWeatherFailure() {
        Test.setMock(HttpCalloutMock.class, new WeatherAPIFailMock());
        WeatherCalloutService.WeatherData result = WeatherCalloutService.fetchWeather('Columbus, OH');
        System.assertEquals(null, result);
    }
}
