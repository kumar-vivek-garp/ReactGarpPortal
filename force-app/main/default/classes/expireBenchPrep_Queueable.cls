public class expireBenchPrep_Queueable implements System.Queueable, Database.AllowsCallouts{
    
    public Map<Id,List<OpportunityLineItem>> oppIdToProdsMap = new Map<Id,List<OpportunityLineItem>>();
    
    public expireBenchPrep_Queueable(Map<Id,List<OpportunityLineItem>> oppIdToProdCodes){
        this.oppIdToProdsMap = oppIdToProdCodes;
    }
    
    public void execute(System.QueueableContext context) {
        
        Map<String,Set<String>> garpIdToCourse = new Map<String,Set<String>>();
        List<eBook_Key__c> ebooksToUpdate =new List<eBook_Key__c>();
        List<User> usersToUpdate = new List<User>();
        
        List<Opportunity> oppList = [Select Id,Garp_Member_Id__c,
                                     (select id,Cancelled__c,Opportunity__c,Product_ID__c from eBook_Keys__r where Type__c = 'BenchPrep')
                                     from Opportunity where Id IN: oppIdToProdsMap.keyset()];
        
        for(Opportunity opp : oppList){
            Set<String> prodCodes = new Set<String>();
            Set<String> prodIds = new Set<String>();
            for(OpportunityLineItem oli : oppIdToProdsMap.get(opp.Id)){
                if(String.isNotBlank(oli.ProductCode))
                    prodCodes.add(oli.ProductCode);
                if(String.isNotBlank(oli.Product_Id__c))
                	prodIds.add(oli.Product_Id__c);
            }
            
            if(!prodCodes.isEmpty()){
                garpIdToCourse.put(opp.GARP_Member_ID__c,prodCodes);
            }
            
            if(!prodIds.isEmpty()){
                for(eBook_Key__c eb : opp.eBook_Keys__r){
                    if(prodIds.contains(eb.Product_Id__c)){
                        eb.Cancelled__c = true;
                        ebooksToUpdate.add(eb);
                    }
                }
            }
        }
        
        List<User> userList = [select Id, Bench_Prep_SSO_Attribute__c,ContactId,Community_Contact_GARP_ID__c from User where Community_Contact_GARP_ID__c in :garpIdToCourse.keyset()];
        
        for(User u : userList){
            Map<String,BenchPrepClass.benchPrepAttr> courseList = new Map<String,BenchPrepClass.benchPrepAttr>();
            if(String.isNotBlank(u.Bench_Prep_SSO_Attribute__c)){
                courseList = BenchPrepClass.removeAccess(u,garpIdToCourse.get(u.Community_Contact_GARP_ID__c));
                if(!courseList.isEmpty()){
                    u.Bench_Prep_SSO_Attribute__c =  JSON.serialize(courseList.values());
                }else{
                    u.Bench_Prep_SSO_Attribute__c = '';
                }
                usersToUpdate.add(u);
            }
        }
        
        if(!ebooksToUpdate.isEmpty()){
            update ebooksToUpdate;
        }
        
        if(!usersToUpdate.isEmpty() && !Test.isRunningTest()){
            update usersToUpdate;
        }
    }

}