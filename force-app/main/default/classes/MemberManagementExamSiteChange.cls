public class MemberManagementExamSiteChange {
    @AuraEnabled
    Public Static String GARPIdValidation(String GARPId){
        String retval ='';
        List<Contact> conList = [Select Id,Account.BillingStreet,Account.BillingCountry,Account.BillingPostalCode,Account.BillingCity From Contact Where GARP_Member_ID__c=:GARPId And RecordType.Name ='Member'];
        if(conList.isEmpty()){
            retval = 'Error';
        }else if(conList[0].Account.BillingStreet == null || conList[0].Account.BillingCountry == null || conList[0].Account.BillingPostalCode == null || conList[0].Account.BillingCity == null){
                     retval = 'Error Address';
                 }else{
                     retval =conList[0].Id;
                 }
        return retval;
    }
    
    
    @AuraEnabled
    Public Static Map<String,List<Exam_Attempt__c>> getexamAttemptDetailsList(String contactId)
    { 
        Map<String,List<Exam_Attempt__c>> examAttemptMapList = new Map<String,List<Exam_Attempt__c>>();
        List<Exam_Attempt__c> examAttemptList = [select id,Name,Exam_Site_Name__c,Site_Code__c,Section__c,Candidate_Commitment__r.AccountId,Exam_Site__r.Name,Exam_Site__r.Site__r.Name,Defered__c,Exam_Site__r.Exam__r.Exam_Group__r.Active__c,Exam_Site__r.Exam_Date__c,Exam_Site__r.Exam__r.Exam__c,Exam_Date__c,Other_Exam_Registrations__r.Exam_Date__c from Exam_Attempt__c where  Member__c =: contactId and Opportunity_StageName__c ='closed' and result__C =:null And Cancelled__c = false order by Section__c,Exam_Date__c DESC limit 2];
        //system.debug(examAttemptMapList);
        if(!examAttemptList.isEmpty()){ 
            if(examAttemptList.size() == 2){ 
                String sec1 = examAttemptList[0].Section__c;
                String sec2 = examAttemptList[1].Section__c;
                if(sec1.substring(0, 3) != sec2.substring(0, 3)){
                    examAttemptMapList = new Map<String,List<Exam_Attempt__c>>();
                    examAttemptList = new List<Exam_Attempt__c>(); 
                    examAttemptMapList.put('Error',examAttemptList);
                    return examAttemptMapList;
                }
            }
            
            for(Exam_Attempt__c ex:examAttemptList){
                if(examAttemptList.size() == 2){ 
                    if(ex.Section__c == 'FRM Part 1' || ex.Section__c == 'ERP Exam Part I')
                        examAttemptMapList.put('Success',new List<Exam_Attempt__c>{ex});
                }else{
                    examAttemptMapList.put('Success',new List<Exam_Attempt__c>{ex}); 
                }
            }
        }
        //system.debug(examAttemptMapList);
        return examAttemptMapList;
        
    }
    @AuraEnabled
    public Static List<Site__c> getSiteList(String examAttemptId,String SearchKey){
        List<Exam_Attempt__c> examgroup = [Select Id,Exam_Date__c From Exam_Attempt__c where id=:examAttemptId];
        List<Site__c> siteList = new List<Site__c>();
        String query = 'Select Id,Name,Site_Code__c,Exam_Date__c from Site__c Where';
        if(!examgroup.IsEmpty()){  
           Date myDate = date.newinstance(2020, 10, 24);
            Date dt = examgroup[0].Exam_Date__c;
           if(myDate == examgroup[0].Exam_Date__c){
              dt = date.newInstance(2020, 05, 16);
            } 
            query += ' Exam_Date__c =:dt ';
            if(SearchKey != null){
                SearchKey = '%'+SearchKey+'%';
                query += ' And Name Like:SearchKey';
            }
            
            query += ' Order By Name Limit 1000'; 
            siteList = database.query(query);
        } 
        
        return siteList;
    }
    
    
    public static Map<Id,Opportunity> OSTAoppMap = new Map<Id,Opportunity>();
    @AuraEnabled
    public Static List<examsitechangestatus> ExamSiteChangeUpdate(String siteId,String examAttemptId,String contactId){
        //system.debug('contactId'+contactId);
        String retval ='';
        boolean refund = false;
        boolean charge = false;
        Set<Id> examAttId = new Set<Id>();      
        Set<Id> examAttOppId = new Set<Id>(); 
        Set<Id> cloneexamAttId = new Set<Id>();
        Set<String> Productcodes = new Set<String>();
        Set<String> GlCode = new Set<String>();
        Set<String> SectionList = new Set<String>();
        Set<Date> ExamdateList = new Set<Date>();
        String examName = 'Exam Site Change Fee';
        Contract contractList =new Contract();
        List<examsitechangestatus> examstatusList= new List<examsitechangestatus>();
        examsitechangestatus examwrap = new examsitechangestatus();
        Map<Id,Exam_Attempt__c> oliobjExamAttemptMap = new Map<Id,Exam_Attempt__c>();
        Map<String,String> examsiteMap = new   Map<String,String>();
        Productcodes.add('CHLF'); 
        GlCode.add('2008');
        try{
            Exam_Attempt__c objEA = new Exam_Attempt__c();
            
            List<Exam_Attempt__c>  examAttemptList = [select Id,Candidate_Commitment__r.AccountId,Member__r.AccountId,Section__c,Opportunity__c,Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,Cloned_From__c,Exam_Date__c from Exam_Attempt__c where  Id =: examAttemptId];
            
            if(!examAttemptList.isEmpty()){
                objEA = examAttemptList[0];  
            }
            if(objEA.Member__r.AccountId != null){
               List<Contract> contList = [Select Id,Opportunity__c,OSTA_Last_Upload_Date__c from Contract where AccountId =:objEA.Member__r.AccountId And RecordType.Name ='OSTA Program'  And Status Like '%Activated%'];
                if(!contList.isEmpty()){
                   contractList =  contList[0];
                }
            }
            List<Site__c> siteList = [Select Id,Name,Is_OSTA_Information_Required__c,Site_Code__c from Site__c where Id =:siteId];
            
            examAttemptList = new List<Exam_Attempt__c>();
            examAttemptList = [select id,Name,Site_Code__c,Section__c,Cloned_From__c,Opportunity__c,Defered__c,Exam_Date__c from Exam_Attempt__c where  Member__c =: contactId and Opportunity_StageName__c ='closed' and result__C =:null And Cancelled__c = false order by Exam_Date__c DESC limit 2];
            if(examAttemptList.size() == 1){
                refund = true; 
                charge = true; 
                examAttId.add(objEA.Id);
                cloneexamAttId.add(objEA.Cloned_From__c);
                examAttOppId.add(objEA.Opportunity__c); 
                SectionList.add(objEA.Section__c);
                ExamdateList.add(objEA.Exam_Date__c);
                oliobjExamAttemptMap.put(objEA.Id,objEA);
            }else if(examAttemptList.size() == 2){
                for(Exam_Attempt__c ex:examAttemptList){
                    SectionList.add(ex.Section__c);
                    ExamdateList.add(ex.Exam_Date__c);
                     if(examAttemptList[0].Exam_Date__c == examAttemptList[1].Exam_Date__c && ex.Defered__c != 'Pending'){ 
                          if(objEA != null && !siteList.isEmpty() && objEA.Section__c != null){  
                              if(objEA.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == true && siteList[0].Is_OSTA_Information_Required__c == false && objEA.Section__c.contains('FRM')){
                                  refund = true;
                                  examAttId.add(ex.Id);
                                  cloneexamAttId.add(ex.Cloned_From__c);
                                  examAttOppId.add(ex.Opportunity__c);
                                  oliobjExamAttemptMap.put(ex.Id,ex);
                              }
                              if(objEA.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == false && siteList[0].Is_OSTA_Information_Required__c == true && objEA.Section__c.contains('FRM')){
                                  charge = true; 
                                  examAttId.add(objEA.Id);
                                  cloneexamAttId.add(objEA.Cloned_From__c);
                                  examAttOppId.add(objEA.Opportunity__c);
                                  oliobjExamAttemptMap.put(ex.Id,ex);
                                  break;
                              }
                          }
                         
                    }else if(examAttemptList[0].Exam_Date__c == examAttemptList[1].Exam_Date__c && ex.Defered__c == 'Pending' && ex.Section__c == 'FRM Part 2'){ 
                        refund = true;
                        charge = true; 
                        examAttId.add(examAttemptList[0].Id);
                        examAttId.add(examAttemptList[1].Id);
                        cloneexamAttId.add(examAttemptList[0].Cloned_From__c);
                        cloneexamAttId.add(examAttemptList[1].Cloned_From__c);
                        examAttOppId.add(examAttemptList[0].Opportunity__c);
                        examAttOppId.add(examAttemptList[1].Opportunity__c);
                        oliobjExamAttemptMap.put(examAttemptList[0].Id,examAttemptList[0]);
                        oliobjExamAttemptMap.put(examAttemptList[1].Id,examAttemptList[1]);
                    }else if(examAttemptList[0].Exam_Date__c != examAttemptList[1].Exam_Date__c){ 
                        refund = true;
                        charge = true;
                        examAttId.add(ex.Id);
                        cloneexamAttId.add(ex.Cloned_From__c);
                        examAttOppId.add(ex.Opportunity__c);
                        oliobjExamAttemptMap.put(ex.Id,ex);
                     }                           
                }
            } 
            
            boolean updatesite = true; 
            if(objEA != null && !siteList.isEmpty() && objEA.Section__c != null){ 
                 examsiteMap = getExamSitedata(siteList[0].Site_Code__c,ExamdateList,SectionList);
                if(objEA.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == true && siteList[0].Is_OSTA_Information_Required__c == false && objEA.Section__c.contains('FRM')){
                    Set<Id> ProductRefundList = new Set<Id>();  
                    updatesite = true; 
                    if(refund == true ){  
                        if(!examAttId.isEmpty()){ 
                            ProductRefundList.Addall(ProductRefunds(examAttId,null,Productcodes,GlCode)); 
                        }
                        if(!cloneexamAttId.isEmpty()){ 
                            ProductRefundList.addAll(ProductRefunds(cloneexamAttId,null,Productcodes,GlCode)); 
                        }
                        if(!examAttOppId.isEmpty() != null){ 
                            ProductRefundList.addAll(ProductRefunds(null,examAttOppId,Productcodes,GlCode)); 
                        }
                    } 
                    if(contractList.Id !=null && contractList.OSTA_Last_Upload_Date__c == null){ 
                        examAttOppId = new Set<Id>();
                        Productcodes = new Set<String>();
                        GlCode = new Set<String>();
                        examAttOppId.add(contractList.Opportunity__c);  
                        Productcodes.add('CHNDF');
                        GlCode.add('2009');
                       Set<Id> prodref = ProductRefunds(null,examAttOppId,Productcodes,GlCode);
                        if(!prodref.isEmpty()){
                            contractList.Status ='Canceled';
                            update contractList;
                        }
                        ProductRefundList.AddAll(prodref);
                        
                     }
                    examstatusList.addAll(getexamrefundList(ProductRefundList)); 
                }else if(charge == true && objEA.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == false && siteList[0].Is_OSTA_Information_Required__c == true && objEA.Section__c.contains('FRM')){
                    Id oppId = createOpportunity(objEA,examName,siteList[0].Site_Code__c);
                    updatesite = false;
                    if(oppId != null){
                        Map<String,Decimal> oliMap = new Map<String,Decimal>(); 
                        oliMap = createOpportunityLineItems('CHLF','2008',oppId,oliobjExamAttemptMap);
                        Map<Id,Opportunity> oppmap = getoppobj(new set<Id>{oppId});
                        if(oliMap.containsKey(oppId)){
                            examwrap = new examsitechangestatus();                          
                            examwrap.examType ='Charge';
                            examwrap.exampcode = 'CHLF';
                            examwrap.examStatus = 'Success';
                            examwrap.amount = oliMap.get(oppId);
                            examwrap.InvoiceNumber = oppmap.get(oppId).Display_Invoice_Number__c; 
                            if(oppmap.get(oppId).Amount >0)
                            examwrap.CustomerSecureCheck = Label.MemberManagementUrlLabel.replace('oppId',oppmap.get(oppId).Id);
                            examstatusList.add(examwrap);
                        }
                        if(contractList.Id == null || contractList.OSTA_Last_Upload_Date__c == null){ 
                            oliobjExamAttemptMap.clear();
                            oliobjExamAttemptMap.put(objEA.Id,objEA);
                            oliMap = new Map<String,Decimal>(); 
                            oliMap = createOpportunityLineItems('CHNDF','2009',oppId,oliobjExamAttemptMap);
                            if(oliMap.containsKey(oppId)){
                                examwrap = new examsitechangestatus();                          
                                examwrap.examType ='Charge';
                                examwrap.exampcode = 'CHNDF';
                                examwrap.examStatus = 'Success';
                                examwrap.amount = oliMap.get(oppId);
                                examwrap.InvoiceNumber = oppmap.get(oppId).Display_Invoice_Number__c; 
                                if(oppmap.get(oppId).Amount >0)
                                    examwrap.CustomerSecureCheck = Label.MemberManagementUrlLabel.replace('oppId',oppmap.get(oppId).Id);
                                examstatusList.add(examwrap);
                            } 
                        }  
                    }
                }  
               
                    List<Exam_Attempt__c> updateexamattemptlist = new List<Exam_Attempt__c>();
                        for(Exam_Attempt__c ex:examAttemptList){
                            Exam_Attempt__c exa = new Exam_Attempt__c();
                            Date myDate = date.newinstance(2020, 10, 24); 
                            date dt = ex.Exam_Date__c;
                            if(myDate == ex.Exam_Date__c){
                                dt = date.newInstance(2020, 05, 16);
                            }
                            String keyval = ex.Section__c+''+dt;
                            
                            if(examsiteMap.containsKey(keyval)){
                                exa.Exam_Site__c = examsiteMap.get(keyval);
                                exa.Id = ex.Id;
                                updateexamattemptlist.add(exa);
                            }  
                        } 
                        if(!updateexamattemptlist.isEmpty() && updatesite == true){
                            Update updateexamattemptlist;
                        }  
                     
            }
            if(!OSTAoppMap.Isempty()){
                update OSTAoppMap.values();
            } 
        }catch(Exception ex){
            system.debug(ex.getMessage()+''+ex.getLinenumber()); 
            retval = ex.getMessage();
            examwrap.examType ='Error'; 
            examwrap.examStatus = ex.getMessage(); 
            examstatusList.add(examwrap);
        } 
        return examstatusList;
    }
    
    public Static Map<String,String> getExamSitedata(String SiteCode,Set<Date> ExamdateList,Set<String> SectionList){
        Date myDate = date.newinstance(2020, 10, 24);
        Set<Date> Examdateset = new Set<Date>();
        for(date exdate:ExamdateList){  
            if(myDate == exdate){
                Date dt = date.newInstance(2020, 05, 16);
                Examdateset.add(dt);
            }else{
                Examdateset.add(exdate);  
            } 
        }
        
        Map<String,String> examsiteMap = new Map<String,String>();
        List<Exam_Sites__c> examSiteLst = [Select Id,Move_Exam_Registration_code__c,Exam_Date__c,Site_code__c from Exam_Sites__c Where Site_code__c=:SiteCode And Move_Exam_Registration_code__c In:SectionList and Exam_Date__c In:Examdateset];
        if(!examSiteLst.isEmpty()){  
            for(Exam_Sites__c exs:examSiteLst){
                if(exs.Move_Exam_Registration_code__c != null){ 
                    String key = exs.Move_Exam_Registration_code__c+''+exs.Exam_Date__c; 
                    examsiteMap.put(key,exs.Id); 
                }
                
            }
        }   
        return examsiteMap;
    }
    public static List<examsitechangestatus> getexamrefundList(Set<Id> ProductRefundId){
        List<examsitechangestatus> examstatusList = new List<examsitechangestatus>();
        for(Product_Refunds__c pr:[Select Id,Opportunity__r.Display_Invoice_Number__c,Refund_amount__c,Product__r.ProductCode From Product_Refunds__c Where Id In:ProductRefundId]){
            examsitechangestatus examwrap = new examsitechangestatus();
            examwrap.examType ='refund';
            examwrap.exampcode = pr.Product__r.ProductCode;
            examwrap.examStatus = 'Success';
            examwrap.amount = pr.Refund_amount__c;
            examwrap.InvoiceNumber = pr.Opportunity__r.Display_Invoice_Number__c; 
            examstatusList.add(examwrap);
        }
        return examstatusList;
    }
    public static Map<Id,Opportunity> getoppobj(Set<Id> oppId){
        Map<Id,Opportunity> opp = new Map<Id,Opportunity>([Select Id,Display_Invoice_Number__c,Name,Amount,Customer_Secure_Checkout_Link__c from Opportunity where Id In:oppId]);  
        return opp;
    }
    public class examsitechangestatus{
        @AuraEnabled
        public String examType{get;set;}
        @AuraEnabled
        public String examStatus{get;set;}
        @AuraEnabled
        public String exampcode{get;set;}
        @AuraEnabled
        public Decimal amount{get;set;}
        @AuraEnabled
        public String InvoiceNumber{get;set;} 
        @AuraEnabled
        public String CustomerSecureCheck{get;set;} 
    }
    
    public static Id createOpportunity(Exam_Attempt__c objExamAttempt, String strOppName,String siteCode){
        Opportunity objOpp = new Opportunity();
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity','Automated'); 
        objOpp.Name = strOppName;
        objOpp.accountId = objExamAttempt.Candidate_Commitment__r.AccountId;
        objOpp.stagename = 'New Lead';
        objOpp.CloseDate = System.today();
        objOpp.RecordTypeId = recordTypeID;
        objOpp.OSTA_Exam_Site_Code__c = siteCode;
        if (strOppName == 'Exam Site Change Fee') {
            objOpp.EA_Id__c = objExamAttempt.id;
            objOpp.Deferred_Exam_Registration__c = objExamAttempt.id;
        }  
        insert objOpp;
        return objOpp.Id;
    }
    
    // create Opportunity Line Items. 
    public static Map<String,Decimal> createOpportunityLineItems(String setProdCodes,String setGlCodes, string oppid,Map<Id,Exam_Attempt__c> objExamAttempt){ 
        list<OpportunityLineItem> oppls = new list<OpportunityLineItem> ();
        Map<String,Decimal> chargeMap = new Map<String,Decimal>();
        Map<String,PriceBookEntry> PriceBookEntryMap = new Map<String,PriceBookEntry>(); 
        for (PriceBookEntry prb: [select unitprice, productcode, product2.Gl_Code__c from PriceBookEntry where Pricebook2.IsActive = true and 
                                  productcode =:setProdCodes and product2.Gl_Code__c =:setGlCodes and isActive = true]) {
                                      PriceBookEntryMap.put(prb.ProductCode,prb); 
                                  }
        
        for(Id ex:objExamAttempt.KeySet()){ 
            if(PriceBookEntryMap.containsKey(setProdCodes)){ 
                OpportunityLineItem oppLineItem = new OpportunityLineItem();
                oppLineItem.OpportunityId = oppid;
                oppLineItem.Exam_Registration__c = ex;
                oppLineItem.Description = 'FRM Exam Site Change Fee';
                oppLineItem.UnitPrice  = PriceBookEntryMap.get(setProdCodes).UnitPrice; 
                oppLineItem.PricebookEntryId = PriceBookEntryMap.get(setProdCodes).Id;
                String keyval = objExamAttempt.get(ex).Section__c+''+objExamAttempt.get(ex).Exam_Date__c; 
                oppLineItem.Quantity = 1;
                Decimal pri = PriceBookEntryMap.get(setProdCodes).UnitPrice;
                if(chargeMap.containsKey(oppid)){
                    decimal d = chargeMap.get(oppid);
                    chargeMap.put(oppid,pri+d);
                }else{
                    chargeMap.put(oppid,pri);
                } 
                oppls.add(oppLineItem); 
                if(setProdCodes =='CHLF'){
                    Opportunity op = new Opportunity();
                    op.Id = oppid;
                    op.OSTA_Check__c = true;
                    OSTAoppMap.put(oppid,op);
                }
            }
        }
        
        insert oppls;  
        return chargeMap;
    }
    //  Product Refunds. 
    public static Set<Id> ProductRefunds(Set<Id> examAttId,Set<Id> examAttOppId,Set<String> Productcodes,Set<String> GlCode){ 
        Set<Id> olioppId = new Set<Id>();
        Set<Id> cratedrefunds = new Set<Id>();
        Map<String,List<OpportunityLineItem>> refundAmountMapOpp = new Map<String,List<OpportunityLineItem>>(); 
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>(); 
        String query='';
        query = 'Select Id,OpportunityId,Unitprice,ProductCode,Product2.Gl_Code__c From OpportunityLineItem Where Opportunity.Stagename =\'Closed\' And ProductCode In:Productcodes and Product2.Gl_Code__c In:GlCode';
        if(examAttId != null){ 
            query += ' And Exam_Registration__c In:examAttId And Exam_Registration__c != null';
        }
        if(examAttOppId !=null){ 
            query += ' And OpportunityId In:examAttOppId And OpportunityId != null';
        }
        oliList = database.query(query);  
        for(OpportunityLineItem oli:oliList){
            olioppId.add(oli.OpportunityId); 
            string key = oli.OpportunityId+','+oli.ProductCode;  
            if(refundAmountMapOpp.containsKey(key)){
                List<OpportunityLineItem> tempoli = refundAmountMapOpp.get(key);
                tempoli.add(oli);
                refundAmountMapOpp.put(key,tempoli);
            }else{
                refundAmountMapOpp.put(key,new List<OpportunityLineItem>{oli});
            }
        } 
        
        if(!olioppId.isEmpty()){ 
            Map<String,Integer> productrefundMap = new Map<String,Integer>();
            for(Product_Refunds__c pr:[Select Id,Opportunity__c,Product__r.productcode From Product_Refunds__c where Opportunity__c In:olioppId And Product__r.productcode In:Productcodes and Product__r.Gl_Code__c In:GlCode]){
                string removekey = pr.Opportunity__c+','+pr.Product__r.productcode;
                if(productrefundMap.containsKey(removekey)){
                    integer temppr = productrefundMap.get(removekey); 
                    productrefundMap.put(removekey,(temppr +1));
                }else{
                    productrefundMap.put(removekey,1);
                }
            }
            
            for(String s:productrefundMap.keySet()){
                if(refundAmountMapOpp.containsKey(s)){
                    integer removeoli  = 0;
                    integer olisize = refundAmountMapOpp.get(s).size();
                    integer refundsize = productrefundMap.get(s);
                    if(olisize == refundsize){
                        refundAmountMapOpp.remove(s); 
                    }else if(olisize > refundsize){
                        removeoli = olisize - refundsize; 
                    }else if(olisize < refundsize){
                        removeoli = refundsize - olisize; 
                    }
                    if(removeoli != 0){
                        for(integer i=0;i<removeoli;i++){
                            refundAmountMapOpp.get(s).remove(i); 
                        } 
                    }
                } 
            }
            //system.debug(olioppId);
            //system.debug(refundAmountMapOpp);
            if(!olioppId.isEmpty() && refundAmountMapOpp.size()>0){
                cratedrefunds = createProductRefunds(olioppId,refundAmountMapOpp,Productcodes,GlCode); 
            }
        }
        return cratedrefunds;
    }
    
    //create Product Refunds. 
    public static Set<Id> createProductRefunds(Set<Id> oppid,Map<String,List<OpportunityLineItem>> unitpriceOlImap,Set<String> Productcodes,Set<String> GlCode){ 
        list<Product_Refunds__c> productrefundlist = new list<Product_Refunds__c> (); 
        Set<Id> productrefundid = new Set<Id>(); 
        Map<String,String> productMap = new Map<String,String>();
        for(Product2 pr:[select Id,productcode from Product2 where IsActive = true and productcode In:Productcodes and Gl_Code__c In:GlCode]){
            productMap.put(pr.productcode,pr.Id);
        }
        
        Map<Id,Id> TransactionMap = new Map<Id,Id>(); 
        for(ChargentOrders__Transaction__c Transactions :[Select Id,Opportunity__c From ChargentOrders__Transaction__c Where ChargentOrders__Type__c = 'Charge' 
                                                       And ChargentOrders__Response__c ='0' And ChargentOrders__Response_Status__c ='Approved' And ChargentOrders__Response_Message__c='Approved' And Opportunity__c In:oppid]){
                                                           TransactionMap.put(Transactions.Opportunity__c,Transactions.Id);                             
                                                       }
        
           //system.debug(unitpriceOlImap);
            for(String s:unitpriceOlImap.keyset()){
                for(OpportunityLineItem oli:unitpriceOlImap.get(s)){
                    list<string> keylist = s.split(',');
                    Product_Refunds__c pr = new Product_Refunds__c();
                    pr.Opportunity__c =keylist[0];
                    if(productMap.containsKey(keylist[1]))
                        pr.Product__c = productMap.get(keylist[1]);
                    pr.Refund_amount__c = oli.Unitprice;
                    if(TransactionMap.containsKey(pr.Opportunity__c))
                        pr.Payment_Order_Transaction__c = TransactionMap.get(pr.Opportunity__c);
                    productrefundlist.add(pr); 
                    if(keylist[1] =='CHLF'){
                        Opportunity op = new Opportunity();
                        op.Id = pr.Opportunity__c;
                        op.OSTA_Check__c = true;
                        OSTAoppMap.put(pr.Opportunity__c,op);
                    }
                } 
            }  
         
        if(!productrefundlist.isEmpty()){
            insert productrefundlist;
        } 
        for(Product_Refunds__c pr:productrefundlist){
            productrefundid.add(pr.Id);
        }
        //system.debug(productrefundid);
        return productrefundid;
    } 
    
}