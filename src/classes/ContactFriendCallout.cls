public class ContactFriendCallout {
	// TODO unit test
    public List<ContactCustomer> getCustomers() {
        HttpRequest request = getRequest();
        HttpResponse response = new Http().send(request);
        
        ResponseBody body = parseResponse(response);
        return body.customers;
    }
    
    private HttpRequest getRequest() {
        final String service = 'https://sheltered-depths-66346.herokuapp.com/';
        final String endpoint = 'customers';
        
        HttpRequest request = new HttpRequest();
        request.setMethod('GET');
        request.setEndpoint(service + endpoint);
        
        return request;
    }
    
    private ResponseBody parseResponse(HttpResponse response) {
        final Integer ok = 200;
        if (response.getStatusCode() != ok) {
        	String msg = String.format(Label.ContactFriendCalloutFailure, new List<String> {
        		response.getBody()
        	});
            throw new HttpException(msg);
        }
        
        String body = response.getBody();
        return (ResponseBody)JSON.deserialize(body, ResponseBody.class);
    }
    
    private class ResponseBody {
        public List<ContactCustomer> customers {get; private set;}
    }
}