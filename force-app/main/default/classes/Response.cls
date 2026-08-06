public class Response {

    public class ResponseException extends Exception{

        public Integer status       { get; set; }
        public List<Object> errors  { get; set; }

        public ResponseException(String message, Integer status, List<Object> errors){
            this(message);
            this.status = status;
            this.errors = errors;
        }

    }

    public abstract class Envelope{
        
        public String message       	{ get; set; }
        public Integer status       	{ get; set; }
        public List<Object> errors  	{ get; set; }
        public User	user				{ get; set; }
        public Boolean isAuthenticated 	{ get; set; }
        
        public Envelope(){
            
            User user = [
                SELECT Id, FullPhotoUrl, ContactId, AccountId, Contact.Membership_Type__c, Contact.Block_Communities_Access__c, 
                Contact.GT_Account__c, Contact.Event_Participant__c, Contact.Event_Contributor__c, Contact.GBI_Participant__c, Contact.GARP_Member_ID__c,
                Contact.FullName__c
                FROM User 
                WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            if(user.ContactId != null && user.AccountId != null){   
                this.isAuthenticated = true;
                this.user = user;
            }else{
                this.isAuthenticated = false;
                this.user = null;
            }
            
        }
        
    }
    
    public class Detail extends Envelope{    
        public Object data { get; set; }
        public Detail(){}
        public Detail(String message, Integer status, List<Object> errors){
            this.message = message;
            this.status = status;
            this.errors = errors;
        }
    }
    
    public class Collection extends Envelope{
        public List<Object> data { get; set; }   
        public Collection(){}
        public Collection(String message, Integer status, List<Object> errors){
            this.message = message;
            this.status = status;
            this.errors = errors;
        }
    }    
    
}