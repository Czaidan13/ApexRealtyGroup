// Schedulable entry point that kicks off WeatherBatchApex on a cron schedule.
// Schedule via: System.schedule('Weather Update', '0 0 * * * ?', new WeatherScheduler());
public class WeatherScheduler implements Schedulable {
    // Called by the Salesforce scheduler at the configured cron interval.
    public void execute(SchedulableContext context) {
        Database.executeBatch(new WeatherBatchApex());
    }
}
