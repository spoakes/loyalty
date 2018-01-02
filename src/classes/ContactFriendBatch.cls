public class ContactFriendBatch implements Database.Batchable<ContactCustomer> {
    private final String friendly = ContactLoyaltyStatus.FRIENDLY;
    
    private final List<ContactCustomer> friends;
    
    public ContactFriendBatch(List<ContactCustomer> friends) {
        this.friends = friends;
    }
    
    public Iterable<ContactCustomer> start(Database.BatchableContext bc) {
        return friends;
    }
    
    public void execute(Database.BatchableContext bc, List<ContactCustomer> scope) {
        List<Contact> contacts = getContacts(scope);
        Map<String, Contact> contactsByLoyaltyId = getContactsByLoyaltyId(contacts);
        
        for (ContactCustomer friend : scope) {
            Contact contact = contactsByLoyaltyId.get(friend.id);
            if (contact == null) {
                contacts.add(createContact(friend));
            } else {
                contact.LoyaltyStatus__c = friendly;
            }
        }
        
        upsert contacts;
    }
    
    private List<Contact> getContacts(List<ContactCustomer> customers) {
        Set<String> loyaltyIds = getLoyaltyIds(customers);
        return queryContacts(loyaltyIds);
    }
    
    private Set<String> getLoyaltyIds(List<ContactCustomer> customers) {
        Set<String> customerIds = new Set<String>();
        for (ContactCustomer customer : customers) {
            customerIds.add(customer.id);
        }
        
        return customerIds;
    }
    
    private List<Contact> queryContacts(Set<String> loyaltyIds) {
        return [
            SELECT Id, LoyaltyId__c
            FROM Contact
            WHERE LoyaltyId__c IN :loyaltyIds
        ];
    }
    
    private Contact createContact(ContactCustomer customer) {
        return new Contact(
        	FirstName = customer.firstName,
            LastName = customer.lastName,
            LoyaltyId__c = customer.id,
            LoyaltyStatus__c = friendly,
            Gender__c = customer.gender,
            Salutation = customer.title
        );
    }
    
    private Map<String, Contact> getContactsByLoyaltyId(List<Contact> contacts) {
        Map<String, Contact> contactsByLoyaltyId = new Map<String, Contact>();
        for (Contact contact : contacts) {
            contactsByLoyaltyId.put(contact.LoyaltyId__c, contact);
        }
        
        return contactsByLoyaltyId;
    }
    
    public void finish(Database.BatchableContext bc) {
        // do nothing
    }
}