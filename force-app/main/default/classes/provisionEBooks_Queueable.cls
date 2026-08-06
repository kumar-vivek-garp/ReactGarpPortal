public class provisionEBooks_Queueable implements System.Queueable, Database.AllowsCallouts{
    public String eBookType;
    public Set<Id> oppIdSet = new Set<Id>();
    public boolean includeYardStick;
    public integer userCourseId;
    public String MobiusProductYear;
    public provisionEBooks_Queueable(String eBookType,Set<Id> oppIds,boolean includeYardStick,integer userCourseId){
        this.eBookType = eBookType;
        this.oppIdSet = oppIds;
        this.includeYardStick = includeYardStick;
        this.userCourseId = userCourseId;
    }
    
    public void execute(System.QueueableContext context) {
        Set<Id> accountIds = new Set<Id>();
        List<Opportunity> oppslist = [Select Id,name,Shipping_First_Name__c,Shipping_Last_Name__c,GARP_Member_ID__c,Shipping_E_mail__c,
                                      		 Billing_Email__c, Billing_First_Name__c, Billing_Last_Name__c,
                                      		 AccountId,Display_Invoice_Number__c,
                                        	(SELECT Id,ProductCode, Product_ID__c FROM OpportunityLineItems)
                                      from Opportunity where Id IN: oppIdSet];
        MAP<String, String> prodCodeToIdMap = new MAP<String, String>();
        for(Opportunity opp :oppslist) {
            accountIds.add(opp.AccountId);
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                prodCodeToIdMap.put(ol.ProductCode,ol.Product_ID__c);
            }                        
        }
        
        if(eBookType == 'FRM1' || eBookType == 'FRM2' || eBookType == 'SCR'){
            String exam;
            String part;
            List<API_Transaction__c> apiTrans = new List<API_Transaction__c>();
            List<eBook_Key__c> allBookKeys = new List<eBook_Key__c>();
            if(eBookType == 'FRM1'){
                exam = 'FRM';
                part = 'I';
            }else if(eBookType == 'FRM2'){
                exam = 'FRM';
                part = 'II';
            }else if(eBookType == 'SCR'){
                exam = 'SCR';
                part = null;
            }
            Map<String,Mobius_Products__c> mProds = Mobius_Products__c.getall();
            Mobius_Products__c MobiusProductYearObj = mProds.get(exam + ' Current Year');
            // If Find Current Year proceed
            // If not defined do not - this is when the eBook is not available
            if(MobiusProductYearObj != null) {
                MobiusProductYear = MobiusProductYearObj.Year__c;
                
                system.debug('MobiusProductYear:' + MobiusProductYear);
                
                List<Integer> iProdList = new List<Integer>();
                String productID;
                Integer accessDuration;
                for(Mobius_Products__c mp :mProds.values()) {
                    if(mp.Year__c == MobiusProductYear && mp.Exam__c == exam && mp.Part__c == part && mp.Name.IndexOf('Current') == -1) {
                        iProdList.add(Integer.valueOf(mp.Product_Id__c));
                        productID = prodCodeToIdMap.get(mp.Salesforce_Product_Code__c);
                        if(mp.Access_Duration_in_Months__c != NULL) {
                            accessDuration = Integer.ValueOf(mp.Access_Duration_in_Months__c);
                        }
                    }                        
                }            
                
                if(iProdList.size() > 0) {
                    for(Opportunity opp :oppslist) {
                        List<List<SObject>> sobjList = mobiusAPI.mProvisionAnEBookSync(exam, part, productID, accessDuration, iProdList, opp.Id,opp.Shipping_E_mail__c,opp.Shipping_First_Name__c,opp.Shipping_Last_Name__c,opp.GARP_Member_ID__c,true);
                        allBookKeys.addAll((List<eBook_Key__c>)sobjList.get(0));
                        apiTrans.addAll((List<API_Transaction__c>)sobjList.get(1));
                    }
                }
            }
            
            if(!allBookKeys.isEmpty()){
                insert allBookKeys;
            }
            if(!apiTrans.isEmpty()){
                insert apiTrans;
            }
        }else if(eBookType == 'ERP2' || eBookType == 'FFR' || eBookType == 'FRR'){
            String productId;
            if(eBookType == 'ERP2') {
                productId = prodCodeToIdMap.get('ENC2X');
            } else if (eBookType == 'FFR'){
                productId = prodCodeToIdMap.get('FBR1X');
            } else if (eBookType == 'FRR'){
                productId = prodCodeToIdMap.get('CBR1X');
            }
            
            List<eBook_Key__c> lstKeysUsed = [select Id, Key__c, Opportunity__c from eBook_Key__c where Type__c = :eBookType and Opportunity__c != null and Opportunity__c in :oppIdSet];
            MAP<Id,eBook_Key__c> mapEBookKeysUsed = new MAP<Id,eBook_Key__c>();
            for(eBook_Key__c ebk :lstKeysUsed) {
                mapEBookKeysUsed.put(ebk.Opportunity__c,ebk);
            }
            
            List<eBook_Key__c> lstUpdateKeys = new List<eBook_Key__c>();
            List<eBook_Key__c> lstKey = [select Id, Key__c, Opportunity__c,Access_Duration_in_Months__c from eBook_Key__c where Type__c = :eBookType and Status__c = 'Available'];
            Integer getCount = 0;
            
            List<User> usersToUpdate = new List<User>();
            Map<Id,User> accIdToUserMap = new Map<Id,User>();
            List<User> currentUserList = [SELECT Id,Rapid_Courses__c,Contact.AccountId FROM User WHERE Contact.AccountId IN: accountIds];
            
            for(user u : currentUserList){
                accIdToUserMap.put(u.Contact.AccountId,u);
            }
            
            
            for(Opportunity opp : oppslist) {
                if(lstKey != null && lstKey.size() > 0 && getCount < lstKey.size() && mapEBookKeysUsed.get(opp.Id) == null) {
                    lstKey[getCount].Opportunity__c = opp.Id;
                    lstKey[getCount].Member_EMail__c = opp.Shipping_E_mail__c;
                    lstKey[getCount].Product_ID__c = productId;
                    lstKey[getCount].Opportunity_1Assigned_Date__c = System.Today();
                    if(lstKey[getCount].Access_Duration_in_Months__c != null) {
                        lstKey[getCount].Access_Expiration_Date__c = System.today().addMonths(integer.valueOf(lstKey[getCount].Access_Duration_in_Months__c));    
                    }
                    lstUpdateKeys.add(lstKey[getCount]);
                    getCount++;
                    system.debug('Found eBook:' + getCount);
                }
                if(includeYardStick){
                    if(accIdToUserMap.containsKey(opp.AccountId)){
                        User updatedUser = WKTRapidCourseJSONBuilder.updateUser(accIdToUserMap.get(opp.AccountId),userCourseId,opp.Display_Invoice_Number__c);
                        if(updatedUser != null){
                            usersToUpdate.add(updatedUser);
                        }
                    }
                }
            }
            update lstUpdateKeys;
            
            if(!usersToUpdate.isEmpty())
                update usersToUpdate;
        }
    }
    
    


}