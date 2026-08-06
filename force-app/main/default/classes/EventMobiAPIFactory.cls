/*  Apex Class for handling EventMobiAPIFactory Process Builders
 *  01/08/2019 Xiang - Refactored Global Describe, add check in doActions for Event_Session_Track__c and Event_Speaker__c
 *  01/17/2019 Xiang - Added support for Event_Session_Registration__c, added batch support for queued job
 */
global class EventMobiAPIFactory{
    
    global class EventMobiRequest {
        
        @InvocableVariable(label='External ID' description='The record Id of the sObject in context.' required=true)
        global Id externalId;
        
        @InvocableVariable(label='sObject Type' description='The sObject Type of the record in context.' required=true)
        global String sObjectType;
        
        @InvocableVariable(label='Action' description='Defines the action, options are "add", "put", and "del").' required=true)
        global String action;
        
        @InvocableVariable(label='Session Registration Record' description='The Event_Session_Registration__c record. Only needed in Delete calls.' required=false)
        global Event_Session_Registration__c eventSessionRegistration;
        
    }
        
    // Process Builder invoke - Use custom class as input for supporting different SObject Types
    @InvocableMethod(label='EventMobi API Factory' description='Determines the sObjectType and Method at runtime based on provided parameters.')
    global static void execute(List<EventMobiRequest> eventMobiRequests) {
        //Database.executeBatch(new EventMobiApiBatch(eventMobiRequests), 1);
    }
    
}