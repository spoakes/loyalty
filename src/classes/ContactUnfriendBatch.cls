public class ContactUnfriendBatch implements Database.Batchable<SObject> {
    private final Set<String> friendLoyaltyIds;
    private final String standard = ContactLoyaltyStatus.STANDARD;
    
    public ContactUnfriendBatch(Set<String> friendLoyaltyIds) {
        this.friendLoyaltyIds = friendLoyaltyIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query =
            '  SELECT Id'
            + '  FROM Contact'
            + ' WHERE LoyaltyStatus__c != :standard'
            + '   AND LoyaltyId__c NOT IN :friendLoyaltyIds';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bc, List<Contact> scope) {
        for (Contact contact : scope) {
            contact.LoyaltyStatus__c = standard;
        }
        
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        // do nothing
    }
}