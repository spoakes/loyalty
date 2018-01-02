@isTest(SeeAllData=false)
private class ContactFriendControllerTest {
    @isTest
    static void getContacts_ReturnsFriendlyContacts() {
    	List<Contact> contacts = new List<Contact>();
    	contacts.add(new Contact(FirstName = 'A', LastName = 'Test', Salutation = 'Mr', Gender__c = 'Male', LoyaltyStatus__c = ContactLoyaltyStatus.STANDARD));
    	contacts.add(new Contact(FirstName = 'B', LastName = 'Test', Salutation = 'Mrs', Gender__c = 'Female', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	contacts.add(new Contact(FirstName = 'C', LastName = 'Test', Salutation = 'Ms', Gender__c = 'Female', LoyaltyStatus__c = ContactLoyaltyStatus.UNFRIENDLY));
    	contacts.add(new Contact(FirstName = 'D', LastName = 'Test', Salutation = 'Mr', Gender__c = 'Male', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	
    	insert contacts;
    	
    	ContactFriendController controller = new ContactFriendController();
    	List<Contact> results = controller.getContacts();
    	
    	System.assertEquals(2, results.size(), 'Failed to return the correct number of contacts.');
    	verifyContact(results[0], contacts[1].Id, 'B Test', 'Mrs', 'Female');
    	verifyContact(results[1], contacts[3].Id, 'D Test', 'Mr', 'Male');
    }
    
    private static void verifyContact(Contact contact, Id expectedId, String expectedName, String expectedSalutation, String expectedGender) {
    	System.assertEquals(expectedId, contact.Id, 'Failed to return contact with the correct ID.');
    	System.assertEquals(expectedName, contact.Name, 'Failed to return contact with the correct name.');
    	System.assertEquals(expectedSalutation, contact.Salutation, 'Failed to return contact with the correct salutation.');
    	System.assertEquals(expectedGender, contact.Gender__c, 'Failed to return contact with the correct gender.');
    }
    
    @isTest
    static void markUnfriendly_UpdatesContact() {
    	Contact contact = new Contact(FirstName = 'A', LastName = 'Test', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY);
    	insert contact;
    	
    	ContactFriendController controller = new ContactFriendController();
    	List<Contact> results = controller.getContacts();
    	
    	System.assertEquals(1, results.size(), 'Failed to return the correct number of contacts.');
    	System.assertEquals(contact.Id, results[0].Id, 'Failed to return the correct contact.');
    	
    	controller.selectedContactId = contact.Id;
    	controller.markUnfriendly();
    	
    	contact = [SELECT LoyaltyStatus__c FROM Contact WHERE Id = :contact.Id];
    	System.assertEquals(ContactLoyaltyStatus.UNFRIENDLY, contact.LoyaltyStatus__c, 'Failed to update the contact loyalty status.');
    }
    
    @isTest
    static void markUnfriendly_RemovesContactFromView() {
    	Contact contact = new Contact(FirstName = 'A', LastName = 'Test', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY);
    	insert contact;
    	
    	ContactFriendController controller = new ContactFriendController();
    	List<Contact> results = controller.getContacts();
    	
    	System.assertEquals(1, results.size(), 'Failed to return the correct number of contacts.');
    	System.assertEquals(contact.Id, results[0].Id, 'Failed to return the correct contact.');
    	
    	controller.selectedContactId = contact.Id;
    	controller.markUnfriendly();
    	
    	results = controller.getContacts();
    	
    	System.assertEquals(0, results.size(), 'Should have removed the contact.');
    }
}