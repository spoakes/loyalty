public class ContactFriendSchedulable implements System.Schedulable {
	// TODO unit test
    public void execute(System.SchedulableContext sc) {
        List<ContactCustomer> customers = new ContactFriendCallout().getCustomers();
        Set<String> customerIds = getCustomerLoyaltyIds(customers);
        Integer scopeSize = 2500;
        
        Database.executeBatch(new ContactFriendBatch(customers), scopeSize);
        Database.executeBatch(new ContactUnfriendBatch(customerIds), scopeSize);
    }
    
    private Set<String> getCustomerLoyaltyIds(List<ContactCustomer> customers) {
        Set<String> customerIds = new Set<String>();
        for (ContactCustomer customer : customers) {
            customerIds.add(customer.id);
        }
        
        return customerIds;
    }
}