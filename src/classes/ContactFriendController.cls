public class ContactFriendController {
    private Map<Id, Contact> contactsById;

    public ContactFriendController() {
        this.contactsById = queryFriends();
    }
    
    private Map<Id, Contact> queryFriends() {
        try {
            final String friendly = ContactLoyaltyStatus.FRIENDLY;
            final Integer recordLimit = 1000;
            verifyContactAccess();
            
            return new Map<Id, Contact>([
                SELECT Id, Name, Salutation, Gender__c
                FROM Contact
                WHERE LoyaltyStatus__c = :friendly
                ORDER BY Name
                LIMIT :recordLimit
            ]);
        } catch (Exception e) {
            ApexPages.addMessages(e);
            return new Map<Id, Contact>();
        }    
    }
    
    private void verifyContactAccess() {
        if (!Contact.SObjectType.getDescribe().isAccessible()) {
            throw new SecurityException(Label.ContactNotAccessible);
        }

        Set<SObjectField> fields = new Set<SObjectField>{
        	Contact.Name,
        	Contact.Salutation,
        	Contact.Gender__c
        };
        for (SObjectField field : fields) {
        	verifyContactFieldAccess(field);
        }
    }
    
    private void verifyContactFieldAccess(SObjectField field) {
    	DescribeFieldResult describe = field.getDescribe();
    	if (!describe.isAccessible()) {
    		String msg = String.format(Label.ContactFieldNotAccessible, new List<String>{
    			describe.getLabel()
    		});
    		throw new SecurityException(msg);
    	}
    }
    
    public List<Contact> getContacts() {
        return contactsById.values();
    }
    
    public Id selectedContactId {get; set;}
    public void markUnfriendly() {
       try {
           final String unfriendly = ContactLoyaltyStatus.UNFRIENDLY;
           verifyContactUpdate();
           
           Contact selectedContact = contactsById.get(selectedContactId);
           selectedContact.LoyaltyStatus__c = unfriendly; 
           
           update selectedContact;
           contactsById.remove(selectedContactId);
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
    }

    private void verifyContactUpdate() {
        if (!Contact.SObjectType.getDescribe().isUpdateable()) {
            throw new SecurityException(Label.ContactNotUpdateable);
        }
        if (!Contact.LoyaltyStatus__c.getDescribe().isUpdateable()) {
            throw new SecurityException(Label.ContactLoyaltyStatusNotUpdateable);
        }
    }
}