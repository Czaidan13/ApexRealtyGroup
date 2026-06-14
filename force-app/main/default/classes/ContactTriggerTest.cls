@isTest
public class ContactTriggerTest {
    
    @isTest
    static void testWebLeadSource() {
        // 1. Arrange - Creat a test contact
        Contact con = new Contact();
        con.LastName = 'ApexTest';
        con.LeadSource = 'Web';

        // 2. Act - insert the contact which fires the trigger
        Test.startTest();
        insert con;
        Test.stopTest();

        // 3. Assert - Check the Description was set correctly
        Contact result = [SELECT Description FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Web Inquiry Created on ' + DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)).format('MMMM d, yyyy'), result.Description);
    }

    @isTest
    static void testPhoneInquiryLeadSource() {
        // 1. Arrange - Creat a test contact
        Contact con = new Contact();
        con.LastName = 'ApexTest';
        con.LeadSource = 'Phone Inquiry';

        // 2. Act - insert the contact which fires the trigger
        Test.startTest();
        insert con;
        Test.stopTest();

        // 3. Assert - Check the Description was set correctly
        Contact result = [SELECT Description FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Phone Inquiry Created on ' + DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)).format('MMMM d, yyyy'), result.Description);
    }

    @isTest
    static void testPartnerReferralLeadSource() {
        // 1. Arrange - Creat a test contact
        Contact con = new Contact();
        con.LastName = 'ApexTest';
        con.LeadSource = 'Partner Referral';

        // 2. Act - insert the contact which fires the trigger
        Test.startTest();
        insert con;
        Test.stopTest();

        // 3. Assert - Check the Description was set correctly
        Contact result = [SELECT Description FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Partner Referral Created on ' + DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)).format('MMMM d, yyyy'), result.Description);
    }

    @isTest
    static void testPurchasedListLeadSource() {
        // 1. Arrange - Creat a test contact
        Contact con = new Contact();
        con.LastName = 'ApexTest';
        con.LeadSource = 'Purchased List';

        // 2. Act - insert the contact which fires the trigger
        Test.startTest();
        insert con;
        Test.stopTest();

        // 3. Assert - Check the Description was set correctly
        Contact result = [SELECT Description FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Purchased List Created on ' + DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)).format('MMMM d, yyyy'), result.Description);
    }

    @isTest
    static void testOtherLeadSource() {
        // 1. Arrange - Creat a test contact
        Contact con = new Contact();
        con.LastName = 'ApexTest';
        con.LeadSource = 'Other';

        // 2. Act - insert the contact which fires the trigger
        Test.startTest();
        insert con;
        Test.stopTest();

        // 3. Assert - Check the Description was set correctly
        Contact result = [SELECT Description FROM Contact WHERE Id = :con.Id];
        System.assertEquals('Other Inquiry Created on ' + DateTime.newInstance(Date.today(), Time.newInstance(0,0,0,0)).format('MMMM d, yyyy'), result.Description);
    }
}