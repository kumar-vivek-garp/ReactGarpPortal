public class provEventAndChptMtngs_Queueable implements System.Queueable, Database.AllowsCallouts{
    public String callOutType;
    public Set<Id> oppsIdSet = new Set<Id>();
    public provEventAndChptMtngs_Queueable(String callOutType,Set<Id> OppIdSet) { 
        this.callOutType =  callOutType;
        this.oppsIdSet = OppIdSet;
    }
    
    public void execute(System.QueueableContext context) {
        if(callOutType == 'Events'){
            LIST<Event_Registration__c > lstEventRegistrations = [select Id,Event__r.ON24_Event_Id__c,Event__r.ON24_API_Key__c,Contact__r.id,Status__c from Event_Registration__c where Opportunity__c  in :oppsIdSet];
            for(Event_Registration__c  itemEventRegistrations :lstEventRegistrations) {
                itemEventRegistrations.Status__c = 'Registered and Paid';
                
                // Call ON24 for Virtual Standard Eventif(itemEventRegistrations.Event__r.ON24_Event_Id__c != null) {
                API_Transaction__c trans = on24API.prepareAPITransactionRecord('event',itemEventRegistrations.Id,itemEventRegistrations.Contact__r.Id,
                                                                              itemEventRegistrations.Event__r.ON24_Event_Id__c, itemEventRegistrations.Event__r.ON24_API_Key__c);
                if(trans != null){
                    trans = on24API.SendRequestSync(null, trans);
                    insert trans;
                } 
            }
            if(!lstEventRegistrations.isEmpty()){
                update lstEventRegistrations;
            }
                
        }else if(calloutType == 'ChapterMeetings'){
            List<Chapter_Meeting_Registration__c> lstChaptMeetRegs = [select Id,contact__r.id, Name,Chapter_Meeting__r.ON24_Event_Id__c,Chapter_Meeting__r.ON24_API_Key__c, Opportunity__c, Status__c from Chapter_Meeting_Registration__c where Opportunity__c in :oppsIdSet];
            for(Chapter_Meeting_Registration__c cmr :lstChaptMeetRegs) {
                cmr.Status__c = 'Confirmed';
                // Call ON24 for Virtual Chapter Meeting (that has an order/purchased membership during registration)
                if(cmr.Chapter_Meeting__r.ON24_Event_Id__c != null) {
                    API_Transaction__c trans = on24API.prepareAPITransactionRecord('chaptermeeting',cmr.Id , cmr.contact__r.id,
                                                                                  cmr.Chapter_Meeting__r.ON24_Event_Id__c, cmr.Chapter_Meeting__r.ON24_API_Key__c);
                    if(trans != null){
                        trans = on24API.SendRequestSync(null, trans);
                        insert trans;
                    } 
                }
            }
            if(!lstChaptMeetRegs.isEmpty()){
                update lstChaptMeetRegs;
            }
        }
    }
}