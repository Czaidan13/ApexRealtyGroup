public with sharing class ContactTriggerHandler {
    public static void handleBeforeInsert(List<Contact> newContacts) {
        DateTime dt = DateTime.newInstance(Date.today(), Time.newInstance(0, 0, 0, 0));
        String formattedDate = dt.format('MMMM d, yyyy');
        String source;

        for (Contact con : newContacts) {
            if (con.LeadSource == 'Web') {
                source = 'Web Inquiry';
            } else if (con.LeadSource == 'Phone Inquiry') {
                source = 'Phone Inquiry';
            } else if (con.LeadSource == 'Partner Referral') {
                source = 'Partner Referral';
            } else if (con.LeadSource == 'Purchased List') {
                source = 'Purchased List';
            } else {
                source = 'Other Inquiry';
            }

            con.Description = source + ' Created on ' + formattedDate;
        }
    }
}
