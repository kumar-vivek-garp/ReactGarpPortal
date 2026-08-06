/*  Queue job for provisioning FRM Part 1/2 eBooks. Job process 1 Opportunity and chain next one, will retry once if failed.
 *  Used in opportunityTriggerUtils.provisionFRMeBook()
 *  Usage: System.enqueueJob(new EBookSyncQueue(exam, part, productID, iProdList, lstOpp, 0, false));
 *  05/21/2019 Xiang - [US-22339] Created.
 *  4/21/2020 AG - Added Support for SCR with no Part
 *  4/24/2020 AG - Added Access Duration to be passed to set new Access Expire Date
 */
public without sharing class EBookSyncQueue implements System.Queueable, Database.AllowsCallouts {
    
    public static Boolean useQueue {
        get {
            if(null == useQueue) {
                Default_Settings__c setting = Default_Settings__c.getAll().get('EnalbeEBookQueue');
                useQueue = null != setting;
            }
            return useQueue;
        }
        private set;
    }
    
    public String exam {get; private set;}
    public String part {get; private set;}
    public String productID {get; private set;}
    public Integer accessDuration {get; private set;}    
    public List<Integer> iProdList {get; private set;}
    public List<Opportunity> lstOpp {get; private set;}
    
    public Integer index {get; private set;}
    public Boolean isRetry {get; private set;}

    // Init all required parameters for mobiusAPI invoke
    public EBookSyncQueue(String exam, String part, String productID, Integer accessDuration, List<Integer> iProdList, List<Opportunity> lstOpp, Integer index, Boolean isRetry) {
        this.exam = exam;
        this.part = part;
        this.productID = productID;
        this.accessDuration = accessDuration;
        this.iProdList = iProdList;
        this.lstOpp = lstOpp;
        
        this.index = index;
        this.isRetry = isRetry;
    }
    
    // Process one Opportunity each time base on index
    public void execute(QueueableContext qc) {
        if(index < lstOpp.size()) {
            Opportunity opp = lstOpp.get(index);
            
            // Process Current Opportunity
            mobiusAPI.mProvisionAnEBookSync(exam, part, productID, accessDuration, iProdList, opp.Id, opp.Shipping_E_mail__c, opp.Shipping_First_Name__c, opp.Shipping_Last_Name__c, opp.GARP_Member_ID__c, false);
            
            // keyType only support FRM Exam Part I/II and ERP Exam Part I/II
            // AG 4/21/2020 - Added Part = NULL for SCR
            String keyType;
            if(part != NULL) {
                keyType = exam + ' Exam Part ' + part;
            } else {
                keyType = exam;
            }
            List<eBook_Key__c> keys = [SELECT Id FROM eBook_Key__c WHERE Opportunity__c = :opp.Id AND Type__c = :keyType];
            
            if(keys.size() > 0 || (keys.size() == 0 && isRetry == true)) {
                // Chain next Opportunity
                if(index < lstOpp.size() - 1) {
                    System.enqueueJob(new EBookSyncQueue(exam, part, productID, accessDuration, iProdList, lstOpp, index+1, false));
                }
            }else if(!Test.isRunningTest()) {
                // Retry Once
                System.enqueueJob(new EBookSyncQueue(exam, part, productID, accessDuration, iProdList, lstOpp, index, true));
            }
        }
        
        // Logging this Queue execution
        if(0 == index && isRetry != true) {
            try {
                String body = 'Exam: ' + exam + '; Part: ' + part + '; Product ID: ' + productID + '; Product List: ' + String.join(iProdList, ',') + '; Opp List: ';
                for(Opportunity opp : lstOpp) {
                    body += '{Id: ' + opp.Id + ', Member Id: ' + opp.GARP_Member_ID__c + '},';
                }
                body = body.substring(0, body.length() - 1);
                if(body.length() > 100000) body = body.substring(0, 100000);
                
                API_Transaction__c apiLog = new API_Transaction__c(Name='EBookSyncQueue Log', Description__c='Logging EBookSyncQueue Executions', Body__c=body);
                
                insert apiLog;
            }catch(Exception e) {}
        }
    }
    
}