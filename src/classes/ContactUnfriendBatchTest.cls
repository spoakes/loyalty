@isTest(SeeAllData=false)
private class ContactUnfriendBatchTest {
    @isTest
    static void batchJob_SetsNonFriendLoyaltyStatus() {
    	Set<String> friendLoyaltyIds = new Set<String>{
    		'a01',
    		'a02',
    		'a03'
    	};
    	
    	List<Contact> contacts = new List<Contact>();
    	contacts.add(new Contact(FirstName = 'A', LastName = 'Test', LoyaltyId__c = 'a01', LoyaltyStatus__c = ContactLoyaltyStatus.STANDARD));
    	contacts.add(new Contact(FirstName = 'B', LastName = 'Test', LoyaltyId__c = 'a02', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	contacts.add(new Contact(FirstName = 'C', LastName = 'Test', LoyaltyId__c = 'a03', LoyaltyStatus__c = ContactLoyaltyStatus.UNFRIENDLY));
    	contacts.add(new Contact(FirstName = 'D', LastName = 'Test', LoyaltyId__c = 'a04', LoyaltyStatus__c = ContactLoyaltyStatus.STANDARD));
    	contacts.add(new Contact(FirstName = 'E', LastName = 'Test', LoyaltyId__c = 'a05', LoyaltyStatus__c = ContactLoyaltyStatus.FRIENDLY));
    	contacts.add(new Contact(FirstName = 'F', LastName = 'Test', LoyaltyId__c = 'a06', LoyaltyStatus__c = ContactLoyaltyStatus.UNFRIENDLY));
    	
    	insert contacts;
    	
    	Test.startTest();
    	Database.executeBatch(new ContactUnfriendBatch(friendLoyaltyIds), 2);
    	Test.stopTest();
    	
    	List<Contact> results = [
    		SELECT LoyaltyStatus__c
    		FROM Contact
    		ORDER BY FirstName ASC
    	];
    	
    	System.assertEquals(6, results.size(), 'Failed to create the correct number of contacts.');
    	
    	verifyLoyaltyStatus(results[0], ContactLoyaltyStatus.STANDARD);
    	verifyLoyaltyStatus(results[1], ContactLoyaltyStatus.FRIENDLY);
    	verifyLoyaltyStatus(results[2], ContactLoyaltyStatus.UNFRIENDLY);
    	verifyLoyaltyStatus(results[3], ContactLoyaltyStatus.STANDARD);
    	verifyLoyaltyStatus(results[4], ContactLoyaltyStatus.STANDARD);
    	verifyLoyaltyStatus(results[5], ContactLoyaltyStatus.STANDARD);
    }
    
    private static void verifyLoyaltyStatus(Contact result, String expectedStatus) {
    	System.assertEquals(expectedStatus, result.LoyaltyStatus__c, 'Failed to set the correct loyalty status.');
    }
}