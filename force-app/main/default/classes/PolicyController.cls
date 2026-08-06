public class PolicyController {
	
    public class Policies{
            
        public String recordTypeName                { get; set; }
        public String sObjectTypeName               { get; set; }
        public Boolean hasPaymentPolicy 			{ get; set; }
        public Boolean hasCancellationPolicy  		{ get; set; }
        public Boolean hasEventsPhotographyRelease 	{ get; set; }
        
        public Policies(String sObjectTypeName, String recordTypeName, String paymentPolicy, String cancellationPolicy, String eventsPhotographyRelease){
            this.recordTypeName = recordTypeName;
            this.sObjectTypeName = sObjectTypeName;
            this.hasPaymentPolicy = String.isNotBlank(paymentPolicy);
            this.hasCancellationPolicy = String.isNotBlank(cancellationPolicy);
            this.hasEventsPhotographyRelease = String.isNotBlank(eventsPhotographyRelease);
        }
        
    }
    
    @RemoteAction
    public static Response.Detail get(Id recordId){
        
        Schema.SObjectType sObjectType = recordId.getSobjectType();
        
        String sObjectTypeName = sObjectType.getDescribe().getName();
        
        try{
            
            Response.Detail res = new Response.Detail();
            
            switch on sObjectTypeName {
                when 'Event__c' {
                    Event__c event = [SELECT RecordType.Name, Cancellation_Policy__c, Events_Photography_Release__c, Payment_Policy__c FROM Event__c WHERE Id = :recordId];
                    res.data = new Policies(sObjectTypeName, event.RecordType.Name, event.Payment_Policy__c, event.Cancellation_Policy__c, event.Events_Photography_Release__c);
                    res.status = 200;
                    res.message = 'Event policies retrieved successfully.';
                }
                when 'Chapter_Meeting__c' {
                    Chapter_Meeting__c event = [SELECT Cancellation_Policy__c, Payment_Policy__c FROM Chapter_Meeting__c WHERE Id = :recordId];
                    res.data = new Policies(sObjectTypeName, null, event.Payment_Policy__c, event.Cancellation_Policy__c, null);
                    res.status = 200;
                    res.message = 'Event policies retrieved successfully.';                    
                }
                when else {
                    throw new Response.ResponseException(
                        'There are no policies defined for this sObjectType.', 
                        400, 
                        new List<String>{'There are no policies defined for this sObjectType.', 'Please add the desired sObjectType to the remote action call.'}
                    );
                }
            }
            
            return res;
            
        }catch(Response.ResponseException e){
            return new Response.Detail(e.getMessage(), e.status, e.errors);
        }catch(Exception e){
            return new Response.Detail(null, 400, new List<Object>{e.getMessage(), e.getLineNumber(), e.getStackTraceString()});
        } 
               
    }
    
    public PolicyController(sfdcAppRemoter ctrl){}
    
}