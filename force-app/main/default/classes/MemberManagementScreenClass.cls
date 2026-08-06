public class MemberManagementScreenClass {
    @AuraEnabled
    public static String hasCustomPermission(){ 
        String profileName=[Select Id,Name from Profile where Id=:userinfo.getProfileId()].Name;
        if(profileName == 'System Administrator'){
            return 'Admin';
        }else if(FeatureManagement.checkPermission('Refund_Free_Deferral_Permission')){
             return 'Refund Free';
        }else{
            return 'Not Refund Free';
        } 
    }
    @AuraEnabled
    Public Static String getnavigateToURL(String selectedEvent,String InvoiceNumber){
        String retval ='';
        List<Opportunity> opp = [Select Id,Amount,StageName,ia_crm__Intacct_Transaction__c,Display_Invoice_Number__c,AccountId From Opportunity where Display_Invoice_Number__c =:InvoiceNumber];
        //system.debug('opp========>'+opp); 
        if(!opp.IsEmpty()){
            
            retval = '/apex/';
            if(selectedEvent == 'Ups Edit') 
                retval += 'UpsEdit?scontrolCaching=1&id='+opp[0].Id;
            if(selectedEvent == 'Switch Exam') 
                retval += 'switchCreation?InvoiceNumber='+opp[0].Display_Invoice_Number__c;
            if(selectedEvent == 'Create Switch Exam Fee'){ 
                List<Contact> contactobj = [Select Id From Contact Where AccountID=: opp[0].AccountId];
                if(!contactobj.IsEmpty()){
                    retval += 'SwtichFeesForErptoFrm?scontrolCaching=1&id='+contactobj[0].Id;
                }else{
                    retval = 'Invalid Invoice Number';
                }
            }
            if(selectedEvent == 'Scholarship refund') 
                retval += 'ScholarshipRefunds?OppId='+opp[0].Id;
            if(selectedEvent == 'Update Opportunity Billing Info') 
                retval += 'changeBillinginfo?scontrolCaching=1&id='+opp[0].Id; 
            /*if(selectedEvent == 'Update Opportunity Price') 
                retval += 'opportunityProductEntry?scontrolCaching=1&id='+opp[0].Id;*/
            if(selectedEvent == 'Refund Free Deferral'){
                if(opp[0].ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral' && opp[0].Amount == 0 && opp[0].StageName == 'Closed'){
                    String res = createFreeDeferralOpp(opp[0],false);
                    retval = res.contains('Error') ? res : '/'+res;
                }else{
                    retval = 'Invalid Invoice Number'; 
                }
            }
            if(selectedEvent == 'Internal Refund'){
                if(((opp[0].ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral' && opp[0].Amount > 0) || opp[0].ia_crm__Intacct_Transaction__c == 'Salesforce - Internal Refund')  && opp[0].StageName == 'Closed'){
                    String res = createFreeDeferralOpp(opp[0],true);
                    retval = res.contains('Error') ? res : '/'+res;
                }else{
                    retval = 'Invalid Invoice Number'; 
                }
            }
        }else{
            retval = 'Invalid Invoice Number';
        }
        return retval;
    }
    public static String createFreeDeferralOpp(Opportunity oldOpp,Boolean isPaidDeferral){
        try{ 
        Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([Select Id,Original_Garp_ID__c,Tax_Authority__c,StageName,AccountId,Billing_Email__c,Payment_Method_New__c,
                                                               Billing_First_Name__c,Billing_Last_Name__c,
                                                               Billing_Phone__c,Billing_Company__c,Gateway__c,Gateway__r.Name,
                                                               Billing_Address__c,Billing_City__c,
                                                               Billing_State_text__c,Billing_Zip_Postal__c,
                                                               Billing_Country__c,Shipping_First_Name__c,ia_crm__Intacct_Transaction__c,
                                                               Shipping_Last_Name__c,Shipping_E_mail__c,Shipping_Company_Name__c,
                                                               Shipping_Phone_No__c,Shipping_Street__c,Shipping_City__c,
                                                               Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,
                                                               RecordTypeId,priceBook2Id,CardType__c,Display_Invoice_Number__c,
                                                               (Select Id,Tax_Authority__c,UnitPrice,PricebookEntryId,OpportunityId,Product_Id__c,Product2Id,Quantity,TotalPrice,ProductCode,
                                                                ia_crm__Class__c,ia_crm__Department__c,ia_crm__Intacct_Location__c,Sage_Reporting_Country__c,Site_Code__c,
                                                                Intacct_Template__c,Warehouse__c,Sage_Reporting_State__c,Sage_Shipping_Country__c,Sage_Shipping_State__c,
                                                                Vendor_Id__c,Vendor_Name__c,ServiceDate,ia_crm__Project__c,Reference_Id__c,Product2.GL_Code__c,Product2.Name from OpportunityLineItems)
                                                               from Opportunity where Id =:oldOpp.Id]);
        Opportunity objOpp = new Opportunity();
        for(Opportunity opp : oppsMap.values()){ 
            objOpp.AccountId = opp.AccountId;
            objOpp.Billing_Email__c = opp.Billing_Email__c;
            objOpp.Billing_First_Name__c = opp.Billing_First_Name__c;
            objOpp.Billing_Last_Name__c = opp.Billing_Last_Name__c;
            objOpp.Billing_Phone__c = opp.Billing_Phone__c;
            objOpp.Billing_Company__c = opp.Billing_Company__c;
            objOpp.Billing_Address__c = opp.Billing_Address__c;
            objOpp.Billing_City__c = opp.Billing_City__c;
            objOpp.Billing_State_Text__c = opp.Billing_State_Text__c;
            objOpp.Billing_Zip_Postal__c = opp.Billing_Zip_Postal__c;
            objOpp.Billing_Country__c = opp.Billing_Country__c;
            objOpp.Shipping_First_Name__c = opp.Shipping_First_Name__c;
            objOpp.Shipping_Last_Name__c = opp.Shipping_Last_Name__c;
            objOpp.Shipping_E_mail__c = opp.Shipping_E_mail__c;
            objOpp.Shipping_Company_Name__c = opp.Shipping_Company_Name__c;
            objOpp.Shipping_Phone_No__c = opp.Shipping_Phone_No__c;
            objOpp.Shipping_Street__c = opp.Shipping_Street__c;
            objOpp.Shipping_City__c = opp.Shipping_City__c;
            objOpp.Shipping_State__c = opp.Shipping_State__c;
            objOpp.Shipping_Postal_Code__c = opp.Shipping_Postal_Code__c;
            objOpp.Shipping_Country__c = opp.Shipping_Country__c;
            objOpp.StageName = 'New Lead';
            objOpp.CloseDate = system.today();
            objOpp.Name = 'Refund Invoice';
            objOpp.Refund_Opportunity__c = opp.Id;
            objOpp.RecordTypeId = opp.RecordTypeId;
            objOpp.priceBook2Id = opp.priceBook2Id;
            objOpp.Original_Garp_ID__c = opp.Original_Garp_ID__c; 
            objOpp.ia_crm__Intacct_Transaction__c = isPaidDeferral == true ?'Salesforce - Internal Refund':'Salesforce - Deferral Refund';
            if(isPaidDeferral == true){
                String invoicenumber = '';
                if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Internal Refund'){
                    invoicenumber = opp.Display_Invoice_Number__c.replace('ICN','ICNR');
                }else{
                    invoicenumber = opp.Display_Invoice_Number__c+'ICN';
                }
            	objOpp.Display_Invoice_Number__c = invoicenumber;
            }else{
                objOpp.Display_Invoice_Number__c = opp.Display_Invoice_Number__c+'CN';
            }
            objOpp.Gateway__c = opp.Gateway__c;
            objOpp.Tax_Authority__c = opp.Tax_Authority__c;
            
            insert objOpp;
            List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
            for(OpportunityLineItem oli : opp.OpportunityLineItems){
                OpportunityLineItem examOLi = new OpportunityLineItem();
                examOLi.OpportunityId = objOpp.Id;
                examOLi.Quantity = oli.Quantity;
                if(isPaidDeferral == true && oli.Product2.GL_Code__c == '4020' && oli.Product2.Name.contains('Deferral')){
                    examOLi.UnitPrice = 0;
                }else{
                    examOLi.UnitPrice = -1 * oLi.UnitPrice;
                } 
                examOLi.Product_ID__c = oli.Product_ID__c;
                examOLi.PricebookEntryId = oli.PricebookEntryId;
                examOLi.Product2Id = oli.Product2Id;
                examOLi.For_Sage_Sync_Only__c = true;
                examOLi.Do_Not_Show_on_Invoice__c = true;
                examOLi.ia_crm__Class__c = oli.ia_crm__Class__c;
                examOLi.ia_crm__Department__c = oli.ia_crm__Department__c;
                examOLi.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
                examOLi.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
                examOLi.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
                examOLi.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
                examOLi.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
                examOLi.Vendor_Name__c = oli.Vendor_Name__c;
                examOLi.Vendor_Id__c = oli.Vendor_Id__c;
                examOLi.Warehouse__c = oli.Warehouse__c;
                examOLi.Site_Code__c = oli.Site_Code__c;
                examOLi.Intacct_Template__c = oli.Intacct_Template__c;
                examOLi.Tax_Authority__c = oli.Tax_Authority__c;
                if(oli.ServiceDate > system.today()){
                    examOli.ServiceDate = oli.ServiceDate;
               }else{
                    examOli.ServiceDate = system.today();
                }
                lineItemsToInsert.add(examOli);
            }
            if(!lineItemsToInsert.isEmpty()){
                insert lineItemsToInsert;
            }
        }
        
             
            ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: objOpp.Id Limit 1];
            
            ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
            trans.Opportunity__c = objOpp.Id;
            trans.ChargentOrders__Order__c = order.Id;
            trans.ChargentOrders__Amount__c = 0.00;
            trans.ChargentOrders__Response_Message__c = 'Approved';
            trans.ChargentOrders__Response_Status__c = 'Approved';
            trans.ChargentOrders__Type__c = 'Charge';
            trans.ChargentOrders__Payment_Method__c ='Free';
            trans.ChargentOrders__Gateway_Date__c = system.now();
            insert trans;
        return objOpp.Id;
        }catch(Exception ex){
            system.debug('Error '+ex.getMessage());
            return 'Error '+ex.getMessage();
        }
    }
    
    @AuraEnabled
    Public Static String GARPIdMergeRequest(String GARPId){
        String retval ='';
        
        List<Contact> conList = [Select Id,First_Name_as_it_Appears_on_ID__c,Middle_Name_as_it_Appears_on_ID__c,Last_Name_as_it_Appears_on_ID__c,RA_Phone__c,Email,Account.BillingState,Account.BillingStreet,Account.BillingCountry,Account.BillingPostalCode,Account.BillingCity From Contact Where GARP_Member_ID__c=:GARPId And RecordType.Name ='Member'];
        if(conList.isEmpty()){
            retval = 'Error' ; 
        }else if(conList[0].Account.BillingState == null || conList[0].Account.BillingStreet == null || conList[0].Account.BillingCountry == null || conList[0].Account.BillingPostalCode == null || 
                 conList[0].Account.BillingCity == null || conList[0].Middle_Name_as_it_Appears_on_ID__c == null || conList[0].First_Name_as_it_Appears_on_ID__c == null || conList[0].Last_Name_as_it_Appears_on_ID__c == null || conList[0].RA_Phone__c == null || conList[0].Email == null){
                     retval = 'Error Info';
                 }else{
                     Id SCRRecId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get('SCR_Program').getRecordTypeId();
                     List<Contract> contractList = [Select Id From Contract Where AccountId=:conList[0].AccountId and Status ='Activated' and RecordTypeId =:SCRRecId];
                     if(contractList.isEmpty()){                 
                         retval = 'Error Contract';
                     }else{
                         try{
                             Contract program = new Contract();
                             program.Id = contractList[0].Id; 
                             program.Pearson_Member_First_Name__c = conList[0].First_Name_as_it_Appears_on_ID__c;
                             program.Pearson_Member_Middle_Name__c = conList[0].Middle_Name_as_it_Appears_on_ID__c;
                             program.Pearson_Member_Last_Name__c = conList[0].Last_Name_as_it_Appears_on_ID__c;
                             program.Member_Email__c = conList[0].Email;
                             program.Pearson_Phone_No__c = conList[0].RA_Phone__c;
                             program.BillingState = conList[0].Account.BillingState;
                             program.BillingCity=conList[0].Account.BillingCity;
                             program.BillingPostalCode = conList[0].Account.BillingPostalCode;
                             program.BillingStreet = conList[0].Account.BillingStreet;
                             program.BillingCountry = conList[0].Account.BillingCountry; 
                             Update program; 
                             retval = 'Updated Pearson Merge Request';
                         }Catch(Exception ex){
                             retval = ex.getMessage();
                         }
                         
                     }
                 }
        return retval;
    }
    
    @AuraEnabled
    Public Static String GARPIdValidation(String GARPId){
        String retval ='';
        List<Contact> conList = [Select Id,Account.BillingStreet,Account.BillingCountry,Account.BillingPostalCode,Account.BillingCity From Contact Where GARP_Member_ID__c=:GARPId And RecordType.Name ='Member'];
        if(conList.isEmpty()){
            retval = 'Error' ; 
        }else if(conList[0].Account.BillingStreet == null || conList[0].Account.BillingCountry == null || conList[0].Account.BillingPostalCode == null || conList[0].Account.BillingCity == null){
            retval = 'Error Address';
        }else{
            boolean isvalidate = validatedeferral(conList[0].Id);
            if(isvalidate == true){
                retval = 'Error ERP';
            }else {
                retval =conList[0].Id; 
            }
        }
        return retval;
    }
    
    public Static boolean validatedeferral(String ContactId){
        boolean isvalidate = false;  
        String section = '%ERP%';
        List<Exam_Attempt__c> examAttemptList = new List<Exam_Attempt__c>();  
        examAttemptList = [select id,Section__c,Defered__c from Exam_Attempt__c where Member__c =:ContactId and Opportunity_StageName__c ='closed' And Cancelled__c = false and result__c =null and Section__c like:section order by Exam_Date__c];
        if(examAttemptList.size()>0){
            isvalidate = true;
        }
        return isvalidate;
    }
    
    @AuraEnabled
    Public Static Map<String,String> getExamTypeList(){
        Map<String,String>  exgroupMap = new Map<String,String>();
        for(Exam_Group__c exgp:[Select Id,Name From Exam_Group__c where (Active__c =true Or Exam_Date__c > Today)  Order By Name]){
            exgroupMap.put(exgp.Id,exgp.Name);
        } 
        return exgroupMap;
    }
    
    @AuraEnabled
    public Static List<Site__c> getActiveSiteList(String examGroupId,String SearchKey){
        List<Exam_Group__c> examgroup = [Select Id,Name,Exam_Date__c From Exam_Group__c where id=:examGroupId]; 
        List<Site__c> siteList = new List<Site__c>();
        String query = 'Select Id,Name,Site_Code__c,Exam_Date__c from Site__c Where Exam_Date__c != null'; 
        if(!examgroup.isEmpty()){
            Date myDate = date.newinstance(2020, 10, 24);
            Date dt = examgroup[0].Exam_Date__c;
            if(myDate == examgroup[0].Exam_Date__c){
                dt = date.newInstance(2020, 05, 16);
            } 
            query += ' And Exam_Date__c =:dt '; 
            
        }
        if(SearchKey != null){
            SearchKey = '%'+SearchKey+'%';
            query += ' And Name Like:SearchKey';
        }
        query += ' Order By Name Limit 1000';
        siteList = database.query(query);
        return siteList;
    }
    
    @AuraEnabled
    public Static Map<String,List<String>> ExamRegistration(String ContactId,String examGroupId,String selectedSite){
        Map<String,List<String>> RegistrationMap = new Map<String,List<String>>();
        List<String> examList = new List<String>();
        try{
            dataWrapper m = new dataWrapper(); 
            List<Contact> conList = [Select Id,AccountId From Contact Where Id=:ContactId];
            If(!conList.IsEmpty()){
                List<Contract> contractList = [Select Id from Contract Where AccountID =:conList[0].AccountId And RecordType.Name = 'FRM Program' And (Status like '%Activated%' Or Status like '%Completed%')];
                
                if(!contractList.IsEmpty()){
                    List<Exam_Group__c> examgp= [Select Id,Name,Exam_Date__c From Exam_Group__c where id=:examGroupId];
                    Set<String> frmexam =  getFRMExams(conList[0].id,examgp[0].Exam_Date__c);
                    if(!frmexam.isEmpty()){
                        if(frmexam.size() == 1){
                            String ext = String.join((Iterable<String>)frmexam, ',');  
                            examList.add(ext);
                        }else if(frmexam.size() > 1){
                            examList.add('FRM Part 1'); 
                            examList.add('FRM Part 1 And Part 2');
                        } 
                        RegistrationMap.put('Registred FRM Program',examList);
                    }                  
                }else{ 
                    examList.add('FRM Part 1'); 
                    examList.add('FRM Part 1 And Part 2');
                    RegistrationMap.put('Not Registred FRM Program',examList); 
                } 
            }
        }Catch(Exception ex){ 
            system.debug(ex.getMessage()+' '+ex.getLinenumber()); 
            RegistrationMap.put('Error',new list<String>{ex.getMessage()}); 
        } 
        return RegistrationMap;
    }
    
    public Static String newoppId;
    @AuraEnabled
    public Static List<ExamRegistationstatus> CreateExamRegistrations(String contactId,String examGroupId,String selectedSite,String payType,String selexamPart,Map<String,List<String>> examRegistredMap){
        //system.debug('examRegistredMap=========>'+examRegistredMap);
        List<ExamRegistationstatus> regstatusList = new List<ExamRegistationstatus>();
        ExamRegistationstatus regstatus = new ExamRegistationstatus(); 
        Contact con = new Contact();
        try{ 
            if(contactId != null){ 
                con = [Select Id,AccountId From Contact Where Id=:contactId];
                List<Exam_Attempt__c> examAttempt = [Select Id,Site__c,Member__c,Member__r.AccountID From Exam_Attempt__c where Member__c=:contactId And Section__c = 'FRM Part 1' And Cancelled__c= false And Opportunity_StageName__c='Closed' And Result__c = null];
                dataWrapper m = new dataWrapper();
                m.examsite = selectedSite;
                List<Site__c> siteList = [Select Id,Name,Is_OSTA_Information_Required__c,Exam_Date__c from Site__c Where Id =:selectedSite];
                
                if(!siteList.IsEmpty()){
                    if(siteList[0].Exam_Date__c != null){
                        m.ExamMonth ='May';
                        if(siteList[0].Exam_Date__c.Month() == 11)
                            m.ExamMonth ='Nov';
                    }
                    //Not Registred FRM Program
                    if(examRegistredMap.containsKey('Not Registred FRM Program')){
                        m.enrollment = true;
                        m.Membership = true;
                        if(siteList[0].Is_OSTA_Information_Required__c == true){  
                            m.OSTA = true;
                            m.ChinaLocation = true; 
                        }
                    }else if(examRegistredMap.containsKey('Registred FRM Program')){ 
                        //Registred FRM Program
                        
                        List<String> exampPartLst = examRegistredMap.get('Registred FRM Program');
                        if(siteList[0].Is_OSTA_Information_Required__c == true){
                            // OSTA Exam
                            m.OSTA = true; 
                            List<Contract> activeOSTAcontract = [Select Id from Contract Where AccountID =:con.AccountId And RecordType.Name = 'OSTA Program' And Status like '%Activated%'];
                            if(!activeOSTAcontract.isEmpty())
                                m.OSTA = false;
                            
                            // ChinaLocation   
                            for(String s:exampPartLst){
                                if(s == 'FRM Part 1' || s == 'FRM Part 1 And Part 2'){
                                    m.ChinaLocation = true;
                                }else if(s == 'FRM Part 2'){ 
                                    if(!examAttempt.isEmpty()){
                                        m.examsite = examAttempt[0].Site__c;
                                        m.ChinaLocation = false;
                                    }else{
                                        m.ChinaLocation = true; 
                                    }
                                }
                            }  
                        }else if(!examAttempt.isEmpty()){
                            for(String s:exampPartLst){
                                if(s == 'FRM Part 2'){
                                    m.examsite = examAttempt[0].Site__c;
                                }   
                            }
                        } 
                    }
                }
                
                m.payType = payType;
                if(selexamPart == 'FRM Part 1')
                    m.examPartOne =selexamPart;
                if(selexamPart == 'FRM Part 2')
                    m.examPartTwo = 'FRM Part 2';
                if(selexamPart == 'FRM Part 1 And Part 2'){
                    m.examPartOne ='FRM Part 1';
                    m.examPartTwo = 'FRM Part 2';
                }
                m.conid = con.Id;
                m.accid = con.AccountId;  
                createproductList(m); 
                if(newoppId != null){
                    Opportunity opp = getoppobj(newoppId);
                    regstatus = new ExamRegistationstatus();
                    regstatus.defType ='New Opportunity';
                    regstatus.defStatus = 'Success';
                    regstatus.amount =  opp.Amount;
                    regstatus.InvoiceNumber = opp.Display_Invoice_Number__c;
                    if(opp.Amount >0)
                        regstatus.CustomerSecureCheck =Label.MemberManagementUrlLabel.replace('oppId',opp.Id);
                    regstatusList.add(regstatus);
                }
            } 
        }catch(Exception ex){
            system.debug(ex.getLineNumber());
            regstatus = new ExamRegistationstatus();
            regstatus.defType ='Error';
            regstatus.defStatus = 'Order can\'t be processed Please Contact IT'; 
            regstatusList.add(regstatus);
        }
        return regstatusList;
    }
    
    public class ExamRegistationstatus{
        @AuraEnabled
        public String defType{get;set;}
        @AuraEnabled
        public String defStatus{get;set;}
        @AuraEnabled
        public Decimal amount{get;set;}
        @AuraEnabled
        public String InvoiceNumber{get;set;}
        @AuraEnabled
        public String CustomerSecureCheck{get;set;}  
    }
    public static Opportunity getoppobj(String oppId){
        Opportunity opp = new Opportunity();
        List<Opportunity> opplst = [Select Id,Display_Invoice_Number__c,Name,Amount,Customer_Secure_Checkout_Link__c from Opportunity where Id =:oppId]; 
        if(!opplst.isEmpty()){
            opp = opplst[0];
        }
        return opp;
    }
    public class dataWrapper{ 
        // Declaring variables for the data transormation. 
        public String conid;
        public String accid;    
        public String fname;
        public String lname;
        public String examPartOne;
        public String examPartTwo;
        public boolean enrollment =false;
        public String email;
        public String examsite;
        public boolean Membership = false;      
        public string payType;
        public string ExamMonth;
        public boolean OSTA = false;
        public boolean ChinaLocation = false;
        public set<String > setProdCodes;
        public set<String > setGlCodes;
        public  List < Candidate_Requirement__c > CandReq;
        public  contract contrac;
        
        public dataWrapper(){
            // initialize above vairables as they are array.  
            setProdCodes = new set<String >();
            setGlCodes = new set<String >();
            CandReq = new List < Candidate_Requirement__c >();
            
        }
    }
    
    
    public static Set <String> getFRMExams(string  objUser,Date ExamFRMDate) {
        // this date needs to be dynamic.
        //system.debug('ExamFRMDate=='+ExamFRMDate);
        Date ExamDate = ExamFRMDate;
        Set < String > setExamToRegister = new Set < String > ();
        boolean bhasRecords = false;
        boolean bhasFrm12 = false;
        Integer iDefferedCount = 0;
        Integer iActiveEA = 0;
        Date dtExamDate = null;
        boolean bFrm1 = false;
        boolean bFrm2 = false;
        boolean bPassFrm1 = false;
        boolean bFRMActivatedXX = false;
        
        Id frmRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program');
        List<Exam_Attempt__c> examAtmps = [select id, Candidate_Commitment__r.EndDate,Candidate_Commitment__r.Last_Exam_registration_Date__c, Contract_End_Date__c, Defered__c, Opportunity_StageName__c, Member__c, Exam_Date__c, Exam_Site__c, Exam_Site__r.Exam__r.Exam_Group__r.Active__c, Exam_Site__r.site__c, Section__c, Result__c, Candidate_Commitment__c, Candidate_Commitment__r.Status 
                                           from Exam_Attempt__c 
                                           where
                                           (
                                               Candidate_Commitment__r.Status like '%Activated%' or 
                                               Candidate_Commitment__r.Status = : 'Completed'
                                           ) and 
                                           Member__c = : objUser and 
                                           Opportunity_StageName__c ='closed' and 
                                           Candidate_Commitment__r.recordTypeID = : frmRecordTypeId and 
                                           Cancelled__c != true 
                                           order by Exam_Date__c DESC ];
        //system.debug('examAtmps============>'+examAtmps);
        for (Exam_Attempt__c objFRMEA:examAtmps) {
            if(objFRMEA.Candidate_Commitment__r.Last_Exam_registration_Date__c != null){
                if(objFRMEA.Candidate_Commitment__r.Status == 'Activated' && ((objFRMEA.Candidate_Commitment__r.Last_Exam_registration_Date__c.month() <= ExamDate.month() )&& (objFRMEA.Candidate_Commitment__r.Last_Exam_registration_Date__c.year() <= ExamDate.year()) &&(objFRMEA.Candidate_Commitment__r.Last_Exam_registration_Date__c.month() != ExamDate.month() ))) return new set<String>();
            }
            if (objFRMEA.Candidate_Commitment__r.Status == 'Completed') return new set<String>();
            bhasRecords = true;
            if (dtExamDate == null) dtExamDate = objFRMEA.Exam_Date__c;
            if (objFRMEA.Defered__c == 'Pending')
                iDefferedCount += 1;
            if (objFRMEA.Exam_Site__r.Exam__r.Exam_Group__r.Active__c)
                iActiveEA += 1;
            
            //&& objFRMEA.Defered__c == null
            if (objFRMEA.Section__c.indexOf('FRM Part 2') >= 0 && (objFRMEA.Result__c == 'pass' || objFRMEA.Result__c == null|| objFRMEA.Result__c == '')) {
                
                
                if ((objFRMEA.Result__c == null ||objFRMEA.Result__c =='Pass')&& !objFRMEA.Exam_Site__r.Exam__r.Exam_Group__r.Active__c) {
                    setExamToRegister.clear();}
                //system.debug('&&&&&&:'+bhasFrm12);
                
                bhasFrm12 = true;
                bFrm2 = true;
                break;
                
            } 
            
            else if (objFRMEA.Section__c.indexOf('FRM Full Program') >= 0 && !bFrm1 && !bFrm2) {
                bFRMActivatedXX = true;
                if (objFRMEA.Result__c == 'Pass') {
                    bhasFrm12 = true;
                    break;
                } else if ((objFRMEA.Result__c != null) && objFRMEA.Result__c != 'Pass' || objFRMEA.Result__c == 'No-Show') {
                    setExamToRegister.clear();
                    setExamToRegister.add('FRM Part 1');
                    setExamToRegister.add('FRM Part 2');
                }
            }
            
            
            else if (objFRMEA.Section__c.indexOf('FRM Part 1') >= 0) {
                bFRMActivatedXX = true;
                bFrm1 = true;
                
                if (objFRMEA.Result__c == null && !objFRMEA.Exam_Site__r.Exam__r.Exam_Group__r.Active__c && objFRMEA.Exam_Date__C !=ExamDate ) {
                    break;
                    //setExamToRegister.clear();
                } else if ((objFRMEA.Result__c != null) && objFRMEA.Result__c != 'Pass' || objFRMEA.Result__c == 'No-Show') {
                    setExamToRegister.clear();
                    if(bPassFrm1==false)
                        setExamToRegister.add('FRM Part 1');
                    setExamToRegister.add('FRM Part 2');
                } else if (objFRMEA.Result__c == 'Pass' || objFRMEA.Result__c == null && objFRMEA.Exam_Date__C ==ExamDate) {
                    
                    bPassFrm1=true ;              
                    setExamToRegister.clear();  
                    setExamToRegister.add('FRM Part 2');
                }
            }
            
        }
        
        //system.debug('iDefferedCount == '+iDefferedCount);
        //system.debug('iActiveEA == '+iActiveEA);
        if(iDefferedCount == 1)
            // return null;
            setExamToRegister.clear();
        //system.debug('*********:'+bhasFrm12);
        if (bhasFrm12 && (iDefferedCount != iActiveEA) ) return new set<String>();
        else if (!bhasRecords) {
            setExamToRegister.add('FRM Part 1');
            setExamToRegister.add('FRM Part 2');
        }
        
        //system.debug('setExamToRegister == '+setExamToRegister);
        return setExamToRegister;
    } 
    
    public static void createproductList(dataWrapper m){  
        //system.debug('Start createproductList');
        if(m.enrollment == true){
            m.setProdCodes.add('FRM1');
            m.setGlCodes.add('4010');
        }
        
        if(m.OSTA == true){ 
            m.setProdCodes.add('CHNDF');
            m.setGlCodes.add('2009'); 
        }
        
        if(m.ChinaLocation == true){ 
            m.setProdCodes.add('CHLF');
            m.setGlCodes.add('2008'); 
        }
        
        if(m.payType =='Early' && m.examPartOne =='FRM Part 1'){
            m.setProdCodes.add('FRM1E');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
            m.setProdCodes.add('FRM1X'); 
            m.setGlCodes.add('4030');
        }
        if(m.payType =='Standard' && m.examPartOne == 'FRM Part 1'){
            m.setProdCodes.add('FRM1S');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
            m.setProdCodes.add('FRM1X');
            m.setGlCodes.add('4030');
        }
        if(m.payType =='Late' && m.examPartOne == 'FRM Part 1'){
            m.setProdCodes.add('FRM1L');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
            m.setProdCodes.add('FRM1X');
            m.setGlCodes.add('4030');
        }
        
        if(m.payType =='Early'  && m.examPartTwo == 'FRM Part 2'){
            m.setProdCodes.add('FRM2E');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
        }
        if(m.payType =='Standard'  && m.examPartTwo == 'FRM Part 2'){
            m.setProdCodes.add('FRM2S');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
        }
        if(m.payType =='Late'  && m.examPartTwo == 'FRM Part 2'){
            m.setProdCodes.add('FRM2L');
            if(m.ExamMonth=='May'){
                m.setGlCodes.add('4001');
            }
            if(m.ExamMonth=='Nov'){
                m.setGlCodes.add('4002');
            }
        }  
        createFrmOrder(m);    
        //system.debug('End createproductList');
    }
    
    public static void createFrmOrder(dataWrapper m){
        
        opportunity opp = new opportunity ();
        //system.debug('^^^^^:'+m.accid);
        //system.debug('m:'+m);
        contact con =[select id,phone, Email,Firstname,lastname,account.billingstreet,account.billingcity,account.billingcountry,account.Billing_Address_Company__c ,account.billingstate,account.billingpostalcode,mailingstreet,mailingcity,mailingstate,mailingpostalcode,mailingcountry from contact where id =:m.conid];
        // create new opportunity
        opp.Accountid = m.accid;
        opp.Name = 'Exam Registration';
        opp.StageName = 'New Lead';
        opp.CloseDate = system.today();
        opp.Program__c = 'FRM';
        opp.Eligible_for_Membership_Extension__c = m.Membership; 
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated');
        opp.RecordTypeId = recordTypeID;
        if(m.OSTA == true){
            opp.OSTA_Check__c = true;
        }
        opp.Billing_First_Name__c =  con.Firstname ; 
        opp.Billing_Last_Name__c = con.lastname ;
        opp.Billing_Email__c  =con.Email  ;
        opp.Billing_Phone__c = con.phone ;
        opp.Billing_Company__c = con.account.Billing_Address_Company__c ; 
        opp.Billing_Address__c =  con.account.billingstreet; 
        opp.Billing_City__c   = con.account.billingcity;
        opp.Billing_State_Text__c = con.account.billingstate;   
        opp.Billing_Country__c =con.account.billingcountry ;
        opp.Billing_Zip_Postal__c = con.account.billingpostalcode ;
        opp.Shipping_Street__c  = con.mailingstreet;
        opp.Shipping_City__c  = con.mailingcity;
        opp.Shipping_State__c = con.mailingstate ;
        opp.Shipping_Postal_Code__c = con.mailingpostalcode;
        
        opp.Shipping_Country__c  = con.mailingcountry;
        opp.Shipping_First_Name__c =con.Firstname ;
        opp.Shipping_Last_Name__c =con.lastname ;
        opp.Shipping_E_mail__c    =con.Email  ;
        opp.Shipping_Phone_No__c  =con.phone ;
        
        insert opp;
        //system.debug('insertopp:'+opp);
        newoppId = opp.Id;
        // calling next method to create Line items.
        createOpportunityLineItems( m,opp.id); 
    }
    
    // create Opportunity Line Items. 
    public static void createOpportunityLineItems(dataWrapper m, string oppid){ 
        //system.debug('m.setProdCodes:'+m.setProdCodes);
        //system.debug('m.setGlCodes:'+m.setGlCodes);
        list<OpportunityLineItem> oppls = new list<OpportunityLineItem> ();
        for (PriceBookEntry PricebookEntryId: [select unitprice, productcode, product2.Gl_Code__c from PriceBookEntry where Pricebook2.IsActive = true and productcode in :m.setProdCodes and product2.Gl_Code__c in :m.setGlCodes and isActive = true]) {
            //system.debug('PricebookEntryId:'+PricebookEntryId);
            OpportunityLineItem oppLineItem = new OpportunityLineItem();
            oppLineItem.OpportunityId = oppid;
            if(PricebookEntryId.ProductCode  =='FRM1X')
                oppLineItem.UnitPrice  = 0.00;
            else{
                oppLineItem.UnitPrice  = PricebookEntryId.UnitPrice;}
            oppLineItem.PricebookEntryId = PricebookEntryId.Id;
            oppLineItem.Quantity = 1;
            oppls.add(oppLineItem);
            //system.debug('oppls:'+oppls);
        }
        
        insert oppls;
        //system.debug('oppls:'+oppls);
        // calling next method to create programs.
        createProgram( m,oppid);
    }
    
    // create Programs. 
    public static void createProgram(dataWrapper m, string oppid){         
        
        contract cr = new contract();
        contract cr1 = new contract();
        contract cr2 = new contract();
        List < Contract > lstContract = new List < Contract > ();
        
        if(m.enrollment == true){
            cr.accountId =m.accid;
            cr.Opportunity__c = oppid;
            cr.StartDate = system.today();
            cr.ContractTerm = 48;
            cr.recordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'FRM Program');
            lstContract.add(cr);
        }
        if(m.enrollment == true){
            cr1.accountId =m.accid;
            cr1.Opportunity__c = oppid;
            cr1.StartDate = system.today();
            cr1.ContractTerm = 12;
            cr1.Membership_Type__c = 'Individual';
            cr1.recordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
            lstContract.add(cr1);
            
        }
        
        if (lstContract.size() > 0) {
            insert lstContract;
        } 
        // calling next method to create program Requirements.
        if(m.enrollment == true){
            createProgramRequirement( m,oppid,cr);
        }
        
        if(m.enrollment == false){
            List<Contract> contractList = [Select Id from Contract Where AccountID =:m.accid And RecordType.Name = 'FRM Program' And Status like '%Activated%'];
            if(!contractList.isEmpty()){
                m.contrac =contractList[0];
                List < Candidate_Requirement__c > cr3 =[select id, Exam__c  from Candidate_Requirement__c where Candidate_Commitment__c =:contractList[0].id];
                m.CandReq = cr3;
                createExamAttempts(m,oppid,m.CandReq,m.contrac);
            }
        }
    }
    
    // create Program requirements. 
    public static void createProgramRequirement(dataWrapper m, string oppid,contract cr){  
        
        Candidate_Requirement__c Cre = new Candidate_Requirement__c ();
        
        List < Candidate_Requirement__c > lstCandReq = new List < Candidate_Requirement__c > ();
        Candidate_Requirement__c objCandReq;
        Integer iCount = 3;
        
        
        Id examRecType = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Exam');
        Id jobExpRecType = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'Job Experience');
        
        Candidate_Requirement__c crJob=null;
        Candidate_Requirement__c crE1=null;
        Candidate_Requirement__c crE2=null;
        
        for (Integer i = 0; i < iCount; i++) {
            objCandReq = new Candidate_Requirement__c();
            objCandReq.Candidate_Commitment__c = cr.id;
            objCandReq.Candidate_Email__c = m.email;
            if (i == 0) {
                
                objCandReq.Name = 'Job Requirement';
                objCandReq.Status__c = 'Initial';
                objCandReq.recordTypeID = jobExpRecType;
                objCandReq.Email_GARP_Member__c = m.Email;
                crJob = objCandReq;
                
            } else if (i == 1) {
                
                objCandReq.Name = 'Pass FRM1';
                objCandReq.Exam__c = 'FRM Part I';
                objCandReq.Status__c = 'Initial';
                objCandReq.recordTypeID = examRecType;
                crE1 = objCandReq;
                
            } else {
                
                objCandReq.Name = 'Pass FRM2';
                objCandReq.Exam__c = 'FRM Part II';
                objCandReq.Status__c = 'Initial';
                objCandReq.recordTypeID = examRecType;                    
                crE2 = objCandReq;
            }
            
            lstCandReq.add(objCandReq);
        }
        if (lstCandReq.size() > 0) {
            if(crE2!=null && crE1!=null) 
                crE2.Prerequisite__c = crE1.Id;
            if(crE2!=null && crJob!=null)
                crJob.Prerequisite__c = crE2.Id;
            
        }
        insert lstCandReq;
        // calling next method to create Exam Attempts.
        
        createExamAttempts(m,oppid,lstCandReq,cr);
    }
    
    // create Exam Attempts.
    @auraEnabled
    public static void createExamAttempts(dataWrapper m, string oppid, List < Candidate_Requirement__c > lstCandReq,contract cr){
        Exam_Attempt__c ea = new Exam_Attempt__c ();
        ID examGroup;
        list < Exam_Sites__c > lstExamSites = new List < Exam_Sites__c > ();
        Set < String > setExamNames = new Set < String > ();
        
        //system.debug('m.examPartOne=== ' + m.examPartOne);
        //system.debug('m.examPartTwo=== ' + m.examPartTwo);
        if (m.examPartOne == 'FRM Part 1' )
            setExamNames.add('FRM Part 1');
        if (m.examPartTwo == 'FRM Part 2')
            setExamNames.add('FRM Part 2');
        
        //system.debug('setExamNames=== ' + setExamNames);
        lstExamSites = [Select id, Name, Exam__r.Exam__c, Exam__r.Exam_Group__c from Exam_Sites__c where Site__c= : m.examsite and Exam__r.Exam__c in : setExamNames];
        
        Map < String, Id > mapCandIds = new Map < String, Id > ();
        Map <string, Id > mapExamIds = new Map <string, Id > ();
        
        for (Candidate_Requirement__c obj: lstCandReq) {
            string strName = '';
            if (obj.Exam__c == 'FRM Part I')
                strName = 'FRM Part 1';
            else if (obj.Exam__c == 'FRM Part II')
                strName = 'FRM Part 2';
            
            mapCandIds.put(strName, obj.Id);
            
        }
        
        //system.debug('lstExamSites=== ' + lstExamSites);
        
        List < Exam_Attempt__c > lstExamApptempts = new List < Exam_Attempt__c > ();
        Exam_Attempt__c objSwapEAFRM1=null;
        Exam_Attempt__c objSwapEAFRM2=null;
        
        for (Exam_Sites__c objExamSite: lstExamSites) {
            
            Exam_Attempt__c   objAttempt = new Exam_Attempt__c();
            objAttempt.Exam_Site__c = objExamSite.Id;
            objAttempt.Member__c = m.conid;
            String strExamName = '';
            objAttempt.Candidate_Commitment__c = cr.id;
            objAttempt.Opportunity__c = oppid;
            objAttempt.Opportunity__c = oppid;
            objAttempt.Candidate_Requirement__c = mapCandIds.get(objExamSite.Exam__r.Exam__c);
            
            lstExamApptempts.add(objAttempt);
            if(objExamSite.Exam__r.Exam_Group__c != null)
                examGroup = objExamSite.Exam__r.Exam_Group__c;
        }
        if (lstExamApptempts.size() > 0) {
            insert lstExamApptempts;
        }
        lstExamApptempts = [select Id, Name, Exam_Site__r.Exam__r.Exam__c from Exam_Attempt__c where Member__c = :m.conid and Candidate_Commitment__c = :cr.id and Exam_Site__r.Exam__r.Exam_Group__c = :examGroup];
        
        //system.debug('* * * lstExamApptempts ...'+ lstExamApptempts);
        
        for (Exam_Attempt__c ea1: lstExamApptempts) {
            if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1') {
                objSwapEAFRM1 = ea1;
            }
            if(ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2') {
                objSwapEAFRM2 = ea1;
            }            
            
        }
        
        //system.debug('* * * objSwapEAFRM1 ...'+ objSwapEAFRM1 + ':' + objSwapEAFRM2 );
        
        if(objSwapEAFRM1!=null && objSwapEAFRM2!=null) {
            objSwapEAFRM1.Other_Exam_Registrations__c = objSwapEAFRM2.Id;
            objSwapEAFRM2.Other_Exam_Registrations__c = objSwapEAFRM1.Id;
            update lstExamApptempts;
        }
        
        
    }
    
    
    
    @AuraEnabled
    Public Static String OnclickMembershipSwitch(String InvoiceNumber){
        
        String retval ='Success';
        List<Opportunity> oppList = [Select Id,Display_Invoice_Number__c,AccountId From Opportunity where Display_Invoice_Number__c =:InvoiceNumber LIMIT 1];
        //system.debug(InvoiceNumber+'    <<::   InvoiceNumber   oppList::>>   '+oppList); 
        if(!oppList.IsEmpty()){
            Opportunity opp = oppList[0];
            for(Opportunity existingOPP : [SELECT Id,Display_Invoice_Number__c FROM Opportunity WHERE Refund_Opportunity__c =: Opp.Id ]){
                //system.debug('existingOPP::>>   '+existingOPP);
                return 'Refund Opportunity Exists:- '+existingOPP.Display_Invoice_Number__c;
            }
        }
        return retval;
    }
    
    
}