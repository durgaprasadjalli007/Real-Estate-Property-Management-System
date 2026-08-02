global class LeaseExpiryEmailScheduler implements Schedulable {

    global void execute(SchedulableContext sc) {

        LeaseExpiryEmailService.sendExpiryReminders();

    }

}