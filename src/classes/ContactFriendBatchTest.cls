@isTest(SeeAllData=false)
private class ContactFriendBatchTest {
    @isTest
    static void batchJob_SetsFriendlyLoyaltyStatus_CreatesNewContacts() {
    	List<Contact> contacts = new List<Contact>();
    	contacts.add(new Contact(FirstName = 'A', LastName = 'Test', LoyaltyId__c = 'a01', LoyaltyStatus__c = ContactLoyaltyStatus.STANDARD));
    	contacts.add(new Contact(FirstName = 'B', LastName = 'Test', LoyaltyId__c = 'a02', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	contacts.add(new Contact(FirstName = 'C', LastName = 'Test', LoyaltyId__c = 'a03', LoyaltyStatus__c = ContactLoyaltyStatus.UNFRIENDLY));
    	contacts.add(new Contact(FirstName = 'D', LastName = 'Test', LoyaltyId__c = 'a04', LoyaltyStatus__c = ContactLoyaltyStatus.STANDARD));
    	contacts.add(new Contact(FirstName = 'E', LastName = 'Test', LoyaltyId__c = 'a05', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	contacts.add(new Contact(FirstName = 'F', LastName = 'Test', LoyaltyId__c = 'a06', LoyaltyStatus__c = ContactLoyaltyStatus.UNFRIENDLY));
    	
    	insert contacts;
    	
    	List<ContactCustomer> friends = new List<ContactCustomer>();
    	friends.add(createCustomer('A', 'Test', 'Mr', 'Male', 'a01'));
    	friends.add(createCustomer('B', 'Test', 'Mrs', 'Female', 'a02'));
    	friends.add(createCustomer('C', 'Test', 'Mr', 'Male', 'a03'));
    	friends.add(createCustomer('G', 'Test', 'Mrs', 'Female', 'a07'));
    	
    	Test.startTest();
    	Database.executeBatch(new ContactFriendBatch(friends), 10);
    	Test.stopTest();
    	
    	List<Contact> results = [
    		SELECT FirstName, LastName, Salutation, Gender__c, LoyaltyId__c, LoyaltyStatus__c
    		FROM Contact
    		ORDER BY FirstName ASC
    	];
    	
    	System.assertEquals(7, results.size(), 'Failed to create the correct number of contacts.');
    	
    	verifyLoyaltyStatus(results[0], ContactLoyaltyStatus.FRIENDLY);
    	verifyLoyaltyStatus(results[1], ContactLoyaltyStatus.FRIENDLY);
    	verifyLoyaltyStatus(results[2], ContactLoyaltyStatus.FRIENDLY);
    	verifyLoyaltyStatus(results[3], ContactLoyaltyStatus.STANDARD);
    	verifyLoyaltyStatus(results[4], ContactLoyaltyStatus.FRIENDLY);
    	verifyLoyaltyStatus(results[5], ContactLoyaltyStatus.UNFRIENDLY);
    	verifyLoyaltyStatus(results[6], ContactLoyaltyStatus.FRIENDLY);
    	
    	verifyNewContact(results[6], friends[3]);
    }
    
    private static ContactCustomer createCustomer(String firstName, String lastName, String title, String gender, String id) {
    	ContactCustomer customer = new ContactCustomer();
    	customer.firstName = firstName;
    	customer.lastName = lastName;
    	customer.title = title;
    	customer.gender = gender;
    	customer.id = id;
    	
    	return customer;
    }
    
    private static void verifyLoyaltyStatus(Contact result, String expectedStatus) {
    	System.assertEquals(expectedStatus, result.LoyaltyStatus__c, 'Failed to set the correct loyalty status.');
    }
    
    private static void verifyNewContact(Contact result, ContactCustomer expectation) {
    	System.assertEquals(expectation.firstName, result.FirstName, 'Failed to set the correct first name.');
    	System.assertEquals(expectation.lastName, result.LastName, 'Failed to set the correct last name.');
    	System.assertEquals(expectation.title, result.Salutation, 'Failed to set the correct salutation.');
    	System.assertEquals(expectation.gender, result.Gender__c, 'Failed to set the correct gender.');
    	System.assertEquals(expectation.id, result.LoyaltyId__c, 'Failed to set the correct loyalty ID.');
    }
}