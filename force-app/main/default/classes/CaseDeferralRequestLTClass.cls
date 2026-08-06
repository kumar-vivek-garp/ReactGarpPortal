public class CaseDeferralRequestLTClass {
    public class ExamRegistrationsWrap{
        @AuraEnabled
        Public String ErrorMessage{get;Set;}
        @AuraEnabled
        Public List<Exam_Attempt__c> ExamAttemptList{get;Set;}
        @AuraEnabled
        Public List<String> FromExamDate{get;Set;}
        @AuraEnabled
        Public List<String> ToExamDate{get;Set;} 
        public ExamRegistrationsWrap(){
            ExamAttemptList = new List<Exam_Attempt__c>();
            FromExamDate = new  List<String>();
            ToExamDate = new  List<String>(); 
        }
    }
    
    
    @AuraEnabled
    public static ExamRegistrationsWrap getExamRegistrations(String contactId){
        ExamRegistrationsWrap exa = new ExamRegistrationsWrap();
        List<Exam_Attempt__c> ExamAttempt = [Select Id,Name,Section__c,Exam_Date__c,Exam_Site__r.Name From Exam_Attempt__c Where Member__c=:contactId and Result__c = null and Opportunity_StageName__c = 'Closed' and Cancelled__c = false and Defered__c != 'Pending'];
        if(ExamAttempt.size() > 2){
            exa.ErrorMessage = 'Error 1';
            return exa;
        }else if(ExamAttempt.size() == 2){
            if(ExamAttempt[0].Section__c.subString(0,3) != ExamAttempt[1].Section__c.subString(0,3)){
                exa.ErrorMessage = 'Error 2'; 
                return exa;
            }else  if(ExamAttempt[0].Exam_Date__c != ExamAttempt[1].Exam_Date__c){
                exa.ErrorMessage = 'Error 3';
                return exa;
            }
        }
        if(!ExamAttempt.isEmpty()){ 
            exa.ExamAttemptList = ExamAttempt;
             
        }        
        return exa; 
    }
    
    @AuraEnabled
    public static ExamRegistrationsWrap getFromToDateList(String SelectedExamAtt){
        ExamRegistrationsWrap exa = new ExamRegistrationsWrap();
        List<Exam_Attempt__c> ExamAttempt = [Select Id,Name,Section__c,Exam_Date__c From Exam_Attempt__c Where Id =:SelectedExamAtt];
        if(ExamAttempt.size()>0){
            Date exdt = ExamAttempt[0].Exam_Date__c;
            DateTime fromdate = DateTime.newInstance(exdt.Year(), exdt.month(), exdt.Day());
            String fromdt = fromdate.format('MMM') +' - ' + fromdate.year();
            exa.FromExamDate.add(fromdt);
            exa.ToExamDate.add('May - 2021');
            if(fromdt == 'Oct - 2020'){
                exa.ToExamDate.add('Nov - 2020');
                exa.ToExamDate.add('Jan - 2021');
            }else  if(fromdt == 'Nov - 2020'){
                exa.ToExamDate.add('Jan - 2021');
            }
        }
        return exa; 
    }
    
    @AuraEnabled
    public static String saveOpportunityDeferral(String contactId,String FromDate,String ToDate,String SelectedExamAtt,boolean isSelectedPart2){
        String message ='';
        try{
            Contact con = new Contact();
            List<Contact> conList = [Select Id,FirstName,AccountId,LastName,Email,Phone,MailingStreet,MailingState,MailingCountry,
                                     MailingPostalCode,MailingCity,Account.BillingStreet,Account.BillingCity,Account.BillingCountry,
                                     Account.BillingState,Account.BillingPostalCode from Contact where Id=:contactId];
            if(!conList.isEmpty()){
                con = conList[0];
            }
            List<PriceBook2> pricebook = [select id,name from pricebook2 Where Name = 'Standard Price Book'];
            Map<String,String> priceBookmap = new Map<String,String>();
            for(PriceBookEntry pre:[SELECT Id, PriceBook2Id,Product2.ProductCode, UnitPrice FROM PriceBookEntry WHERE IsActive = true and PriceBook2Id In:pricebook and (Product2.ProductCode = 'FRM1' OR Product2.ProductCode = 'ENC') and Product2.GL_Code__c = '4020']){
                priceBookmap.put(pre.Product2.ProductCode,pre.Id);
            }
            
            String exSection;
            Map<String,Exam_Attempt__c> selExamAdminMap = new Map<String,Exam_Attempt__c>();
            List<String> ExamSiteCodeidetifier = new List<String>();
            List<Exam_Attempt__c> ExamAttemptList = [select id,Section__c,Exam_Site__r.Exam_Site_Code_idetifier__c,Opportunity__c,Deferral_Status__c,Candidate_Commitment__c,Member__c,Candidate_Requirement__c,Exam_Site__c,Defered__c From Exam_Attempt__c Where Member__c=:contactId and Result__c = null and Opportunity_StageName__c = 'Closed' and Cancelled__c = false and Defered__c != 'Pending'];
            for(Exam_Attempt__c ea:ExamAttemptList){
                if(ea.Id == SelectedExamAtt){
                    exSection = ea.Section__c.subString(0,3); 
                }
                ExamSiteCodeidetifier.add(ea.Exam_Site__r.Exam_Site_Code_idetifier__c);
                selExamAdminMap.put(ea.Id,ea);
            }
            Map<String,String> mapNewSiteCodes = new Map<String,String>();
          
            for(Exam_sites__c  objSite : [select id,name,Move_Exam_Registration_code__c,Exam_Site_Code_idetifier__c,Exam_Date__c from Exam_sites__c where Exam_Site_Code_idetifier__c In:ExamSiteCodeidetifier]){
                Date dt = objSite.Exam_Date__c;
                DateTime exdate = DateTime.newInstance(dt.Year(), dt.month(), dt.Day());
                String exdatefr = exdate.format('MMM') +' - ' + exdate.year();
                if(exdatefr == ToDate){
                    String key = objSite.Move_Exam_Registration_code__c +','+objSite.Exam_Site_Code_idetifier__c;
                    mapNewSiteCodes.put(key,objSite.Id);
                }
            }
          
            if(mapNewSiteCodes.isEmpty() && ToDate  != 'May - 2021'){
                message ='Exam Site not found';
                return message;
            }
            Opportunity opp = new Opportunity();
            opp.Name = 'Late Exam Deferral';
            opp.CloseDate = system.today();
            opp.StageName = 'Closed';
            opp.Billing_First_Name__c = con.FirstName;
            opp.Billing_Last_Name__c = con.LastName;
            opp.Billing_Email__c = con.Email;
            opp.Billing_Phone__c = con.Phone;
            opp.Billing_Company__c = '';
            opp.Billing_Address__c = con.Account.BillingStreet;
            opp.Billing_City__c = con.Account.BillingCity;
            opp.Billing_Country__c = con.Account.BillingCountry;
            opp.Billing_State_Text__c = con.Account.BillingState;
            opp.Billing_Zip_Postal__c = con.Account.BillingPostalCode;
            opp.Shipping_First_Name__c = con.FirstName;
            opp.Free_Deferral__c = true;
            opp.Shipping_Last_Name__c = con.LastName;
            opp.Shipping_Phone_No__c = con.Phone;
            opp.Shipping_E_mail__c = con.Email;
            opp.Shipping_Street__c = con.MailingStreet; 
            opp.Shipping_State__c = con.MailingState; 
            opp.Shipping_Country__c = con.MailingCountry; 
            opp.Shipping_Postal_Code__c = con.MailingPostalCode; 
            opp.Shipping_City__c = con.MailingCity;
            opp.Late_EA_Id__c = SelectedExamAtt;
            opp.AccountId = con.AccountId;
            if(!pricebook.isEmpty())
                opp.pricebook2Id = pricebook[0].Id;
            insert opp;
            
            if(exSection == 'FRM'){
                exSection ='FRM1';
            }else if(exSection == 'ERP'){
                 exSection ='ENC';
            }
            if(priceBookmap.containsKey(exSection)){
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.OpportunityId = opp.Id; 
                oli.PricebookEntryId = priceBookmap.get(exSection);
                if(selExamAdminMap.containsKey(SelectedExamAtt)){
                    if(ExamAttemptList.size() == 2 && (selExamAdminMap.get(SelectedExamAtt).Section__c == 'FRM Part 1' || selExamAdminMap.get(SelectedExamAtt).Section__c == 'ERP Part I')){
                        oli.Description = 'Deferral of ' + selExamAdminMap.get(SelectedExamAtt).Section__c.subString(0,3) + ' Part I and ' +  selExamAdminMap.get(SelectedExamAtt).Section__c.subString(0,3) + ' Part II' + ' from ' + FromDate +' to '+ ToDate;
                    }else{
                        oli.Description = 'Deferral of ' + selExamAdminMap.get(SelectedExamAtt).Section__c + ' from ' + FromDate +' to '+ ToDate;
                    } 
                }
                oli.UnitPrice= 0;
                oli.Quantity = 1;
                insert oli;
            }
            
            ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: opp.Id];

            ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
            trans.Opportunity__c = opp.Id;
            trans.ChargentOrders__Amount__c = 0;
            trans.ChargentOrders__Response_Message__c = 'Approved';
            trans.ChargentOrders__Response_Status__c = 'Approved';
            trans.ChargentOrders__Type__c = 'Charge';
            trans.ChargentOrders__Order__c = order.Id;
            trans.ChargentOrders__Gateway_Date__c = system.now();
            insert trans;
            
            List<Exam_Attempt__c> lstToUpdate = new List<Exam_Attempt__c>();
            List<Exam_Attempt__c> lstToUpdate1 = new List<Exam_Attempt__c>();
           
            for(Exam_Attempt__c obj : ExamAttemptList){
                
                Exam_Attempt__c clonedRec = obj.clone(false,true,false,false);
                if(ToDate != 'May - 2021'){
                    String key = obj.Section__c +','+obj.Exam_Site__r.Exam_Site_Code_idetifier__c;
                    if(mapNewSiteCodes.containsKey(key)){
                        clonedRec.Exam_Site__c = mapNewSiteCodes.get(key);
                        clonedRec.Defered__c = 'Approved';
                        clonedRec.Deferral_Status__c = 'Deferred In';
                        clonedRec.Cloned_From__c = obj.id;
                        clonedRec.Member__c = obj.Member__c;
                        
                        obj.Defered__c = 'Approved';
                        obj.Cancelled__c =true;
                        obj.Cancel_Reason__c ='Deferral';
                        obj.Deferral_Status__c ='Deferred Out';
                    }
                }else if(ToDate == 'May - 2021'){
                    obj.Defered__c = 'Pending';
                }
                if((obj.Section__c ==  'FRM Part 2' || obj.Section__c == 'ERP Part II') && obj.Id == SelectedExamAtt && isSelectedPart2 == true){ 
                    lstToUpdate.add(obj); 
                    if(ToDate != 'May - 2021')
                        lstToUpdate1.add(clonedRec); 
                }else if(isSelectedPart2 == false){ 
                    lstToUpdate.add(obj);
                    if(ToDate != 'May - 2021')
                        lstToUpdate1.add(clonedRec);
                }
            }
            
            if(!lstToUpdate.isEmpty())
                upsert lstToUpdate;
            if(!lstToUpdate1.isEmpty())
                upsert lstToUpdate1;
            message = 'Success';
        }catch(Exception ex){
            message = ex.getMessage();
            system.debug(ex.getLinenumber());
        }
        return message;
    } 
    
}