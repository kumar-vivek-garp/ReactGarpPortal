public class BenchPrepSSO {

    public Boolean loadComplete {get;set;}
    public Boolean showRedirect {get;set;} 
    public String redirectPage {get;set;}
    
    public void BenchPrepSSO() {
        loadComplete = False;
        showRedirect = False;
        redirectPage = NULL;
    }
    
    public void redirect() {
    
        // For Member Benefits, pass Benefit Key
        // For Study Materials, pass program and part
        String memberBenefitKey = ApexPages.currentPage().getParameters().get('id');
        String programType = ApexPages.currentPage().getParameters().get('prog');
        String programPart = ApexPages.currentPage().getParameters().get('part');
        
        if(programType == 'RiskAI') {
            programType = 'RAI';
        }
        
        if(programType != 'FRM' && (programPart == NULL || String.IsEmpty(programPart))) {
            programPart = 'Full';
        }
        
        GARP_Common.debugLog('BenchPrepSSO','redirect','memberBenefitKey',memberBenefitKey);
        GARP_Common.debugLog('BenchPrepSSO','redirect','programType',programType);
        GARP_Common.debugLog('BenchPrepSSO','redirect','programPart',programPart);
        
        if((memberBenefitKey != NULL && !String.IsEmpty(memberBenefitKey)) || (programType != NULL && !String.IsEmpty(programType) )) {
            
            List<User> users = [SELECT Id, ContactId, Email FROM User WHERE Id = :UserInfo.getUserId()];
            GARP_Common.debugLog('BenchPrepSSO','redirect','users',users);
            
            if(!users.isEmpty()) {           
                List<Contact> contacts = [SELECT Id, Name, KPI_Membership_Payment_Status__c ,Email, AccountID FROM Contact WHERE Id = :users[0].ContactId];
                GARP_Common.debugLog('BenchPrepSSO','redirect','contacts',contacts);
                
                if(!contacts.IsEmpty()) {
                    
                    Contact contact = contacts[0];
                    
                    List<eBook_Key__c> lstKeys = [select id, Product_ID__c, Last_Access_DateTime__c, First_Access_DateTime__c  
                                      from eBook_Key__c 
                                      where Type__c = 'BenchPrep' AND Contact__c = :contact.id AND (Access_Expiration_Date__c >= TODAY)
                                      AND Status__c = 'Taken'];
                    GARP_Common.debugLog('BenchPrepSSO','redirect','lstKeys',lstKeys);
                    
                    MAP<String, eBook_Key__c> mapEBookKeysByProductID = new MAP<String, eBook_Key__c>();
                    for(eBook_Key__c ek :lstKeys) {
                        mapEBookKeysByProductID.put(ek.Product_ID__c, ek);
                    }
                    GARP_Common.debugLog('BenchPrepSSO','redirect','mapEBookKeysByProductID',mapEBookKeysByProductID);
                    
                    String courseSlug;
                    //MAP<string,string> mapSlugs = GARP_BC_Membership.getMemberBenefitsSlugs();
                    
                    Map<String,BenchPrep_Config__mdt> mapBPConfig = BenchPrepClass.getBenchPrepConfig();
                    
                    eBook_Key__c fndEBookKey;
                    
                    // Member Benefits Key
                    if(memberBenefitKey != NULL && !String.IsEmpty(memberBenefitKey)) {
                        BenchPrep_Config__mdt bpConfig = mapBPConfig.get(memberBenefitKey);
                        GARP_Common.debugLog('BenchPrepSSO','redirect','bpConfig',bpConfig);
                        
                        if(bpConfig != NULL) {
                            fndEBookKey = mapEBookKeysByProductID.get(bpConfig.Course_Slug__c);
                            courseSlug = bpConfig.Course_Slug__c;
                        }
                    } else {
                        
                        if(programType == 'FRM' && (programPart == NULL || String.IsEmpty(programPart))) {
                            BenchPrep_Config__mdt bpConfig = mapBPConfig.get('FRM:1');
                            GARP_Common.debugLog('BenchPrepSSO','redirect','bpConfig FRM 1',bpConfig);
                            
                            if(bpConfig != NULL) {
                                fndEBookKey = mapEBookKeysByProductID.get(bpConfig.Product_ID__c);
                                GARP_Common.debugLog('BenchPrepSSO','redirect','fndEBookKey FRM 1',fndEBookKey);
                                
                                if(fndEBookKey == NULL) {
                                    bpConfig = mapBPConfig.get('FRM:2');
                                    fndEBookKey = mapEBookKeysByProductID.get(bpConfig.Product_ID__c);
                                }
                            }
                        } else {
                            BenchPrep_Config__mdt bpConfig = mapBPConfig.get(programType + ':' + programPart);
                            GARP_Common.debugLog('BenchPrepSSO','redirect','bpConfig',bpConfig);
                            
                            fndEBookKey = mapEBookKeysByProductID.get(bpConfig.Product_ID__c);
                        }
                    }
                    GARP_Common.debugLog('BenchPrepSSO','redirect','fndEBookKey',fndEBookKey);
                    
                    if(fndEBookKey != NULL) {
                        if(fndEBookKey.First_Access_DateTime__c == NULL) {
                            fndEBookKey.First_Access_DateTime__c = DateTime.now();
                        }
                        fndEBookKey.Last_Access_DateTime__c = DateTime.now();
                        update fndEBookKey;
                    } else if(memberBenefitKey != NULL && memberBenefitKey == 'SCR_Holders') {
                        // Create eBook Key to track
                        eBook_Key__c eBK25 = new eBook_Key__c(
                            Name = memberBenefitKey,
                            Product_ID__c = courseSlug,
                            Contact__c = contact.Id,
                            Is_API__c = True,
                            Type__c = 'BenchPrep',
                            Last_Access_DateTime__c = DateTime.now(),
                            First_Access_DateTime__c = DateTime.now()
                        );
                        System.Debug('eBK25:' + eBK25);
                        insert eBK25;
                        fndEBookKey = eBK25;
                    } else {
                        loadComplete = True;
                    }
                    
                    GARP_Common.debugLog('BenchPrepSSO','redirect','fndEBookKey final',fndEBookKey);
                    
                    if(fndEBookKey != NULL) {
                        loadComplete = True;
                        showRedirect = True;
                        redirectPage = Label.BenchBrepSSOLink;
                        //Pagereference page = new pagereference(Label.BenchBrepSSOLink);
                        return;
                    }
                }
            }
        } else {
            loadComplete = True;
        }
        return;
    }
    
}