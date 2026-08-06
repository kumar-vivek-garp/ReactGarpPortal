/* Input for this batch is Exam Type, string should match the Exam__c picklist value on Exam__c object for FRM,ERP and SCR
 * Exam Group Id should be saved to Free_Ebooks_Batch_Record_Id custom label, query will filter Registrations with that Group Id
 */
global class CreateFreeOppEBookAndPracExams implements Database.Batchable<sObject>,Database.StateFul,Database.AllowsCallouts{
	private string examType;
    private string examAdminId = System.Label.Free_Ebooks_Batch_Record_Id;
    private string recordId;
    public CreateFreeOppEBookAndPracExams(string examTypeStr){
        examType = examTypeStr;
    }
    public CreateFreeOppEBookAndPracExams(string examTypeStr,string inputRecordId){
        examType = examTypeStr;
        recordId = inputRecordId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        //run this batch for only one record at once.
        //List<Exam_Date__c > lstDate = Exam_Date__c.getAll().values();
        String StrDefered = 'Approved';       
        String oppstatus = 'closed';
        //date datExam = lstDate[0].Date__c;
        //Set<String> sitecode =new Set<String>{'814','838'};
        //Set<String> id =new Set<String>{'a1a1W000008ijQ5'};
        Set<String> strSection = new Set<String>{examType};
            
        string strQuery = 'select id,Section__c,Exam_Site__r.Exam_Site_Code_idetifier__c,Opportunity__c,Deferral_Status__c,Candidate_Commitment__c,Member__c,Candidate_Requirement__c,Exam_Site__c,Defered__c from Exam_Attempt__c where  Defered__c =: StrDefered  and Opportunity_StageName__c =:oppstatus and cancelled__c !=true and EBooks_Created__c != true and Section__c in: strSection and Exam_Administration__c =:examAdminId';
        if(String.isNotBlank(recordId)) {
            strQuery += ' AND Id=: recordId';
        }
        if(test.isRunningTest()){
            strQuery = 'select id,Section__c,Exam_Site__r.Exam_Site_Code_idetifier__c,Opportunity__c,Deferral_Status__c,Candidate_Commitment__c,Member__c,Candidate_Requirement__c,Exam_Site__c,Defered__c from Exam_Attempt__c where  Defered__c =: StrDefered  and Opportunity_StageName__c =:oppstatus and cancelled__c !=true and Section__c in: strSection';
        }
        return Database.getQueryLocator(strQuery); 
        
    }
    
    global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
        Set<String> productCodeSet = new Set<String>();
        List<Exam_Attempt__c> listToUpdate = new List<Exam_Attempt__c>();
        String eBookType;
        if(examType == 'FRM Part 1'){
           // productCodeSet.add('FRM1X');
            productCodeSet.add('FRMBP');
            eBookType = 'Frm part 1';
        }else if(examType == 'FRM Part 2'){
            //productCodeSet.add('FRM2X');
            productCodeSet.add('FRMC2');
            eBookType = 'Frm part 2';
        }else if(examType == 'ERP Exam Part I'){
            //productCodeSet.add('ENC1X');
            productCodeSet.add('ENCC1');
            eBookType = 'ERP Part I';
        }else if(examType == 'ERP Exam Part II'){
            //productCodeSet.add('ENC2X');
            productCodeSet.add('ENCC2');
            eBookType = 'ERP Part II';
        }else if(examType == 'SCR'){
            //productCodeSet.add('SCRX');
            productCodeSet.add('SCRBP');
            eBookType = 'SCR';
        }else if(examType == 'RiskAI'){ 
            productCodeSet.add('RAIBP');
            eBookType = 'RiskAI';
        }
        Set<Id> Conids = new Set<Id>();
        
        for(Exam_Attempt__c ea : scope){
            Conids.add(ea.Member__c);
            ea.EBooks_Created__c = true;
            listToUpdate.add(ea);
        }
        
        Contact objContact = [select id,name,Email,account.BillingStreet,Account.BillingState,Account.BillingCountry,Company_Clean_Name__c,Account.BillingCity, FirstName, HomePhone, LastName, Mailing_Address_Company__c, MailingCity, MailingCountry, MailingState, MailingStreet, MailingPostalCode,accountId from Contact where id =: Conids];
        
        Opportunity Newopp = new opportunity();
        if(objContact != null )
        {
            List<Opportunity> lstNewOpps = new List<Opportunity>();
            Newopp.Name = 'Free Ebook Extension';
            Newopp.accountid = objContact.accountid;
            Newopp.StageName = 'New Lead';
            Newopp.CloseDate=system.today();
            Newopp.Billing_Address__c = objContact.account.BillingStreet;
            Newopp.Billing_City__c    = objContact.account.BillingCity;
            Newopp.Billing_Company__c = objContact.Company_Clean_Name__c;
            Newopp.Billing_Country__c = objContact.account.BillingCountry;
            Newopp.Billing_Email__c   = objContact.Email;
            Newopp.Billing_Last_Name__c    = objContact.LastName;
            Newopp.Billing_First_Name__c   = objContact.FirstName;
            Newopp.Billing_Phone__c   = objContact.HomePhone;
            Newopp.Billing_Zip_Postal__c= objContact.MailingPostalCode;
            Newopp.Billing_State_Text__c   = objContact.account.BillingState;
            Newopp.Shipping_Last_Name__c           = objContact.LastName;
            Newopp.Shipping_First_Name__c          = objContact.FirstName;
            Newopp.Shipping_Street__c              = objContact.account.BillingStreet;
            Newopp.Shipping_City__c                = objContact.account.BillingCity;
            Newopp.Shipping_Country__c             = objContact.account.BillingCountry;
            Newopp.Shipping_E_mail__c              = objContact.Email;
            Newopp.Shipping_Phone_No__c            = objContact.HomePhone;
            Newopp.Shipping_Postal_Code__c         = objContact.MailingPostalCode;
            Newopp.Shipping_State__c               = objContact.account.BillingState;
            Newopp.Give_Ebook_for_Free__c = true;
            Newopp.E_book_Type__c = eBookType != 'RiskAI'?eBookType:null;
            lstNewOpps.add(Newopp);
			
            insert lstNewOpps;
ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: newOpp.Id Limit 1];
            if(lstNewOpps.size() > 0){
               
                List<PriceBookEntry> PricebookEntryList = [select Id,unitprice, productcode, product2.Gl_Code__c,Product2.Product_Id__c from PriceBookEntry where Pricebook2.IsActive = true and Pricebook2.IsActive = true and productcode IN: productCodeSet and product2.Gl_Code__c = '4030' and isActive = true];
                List<OpportunityLineItem> lstOppLines = new List<OpportunityLineItem>();
                for(Opportunity opp : lstNewOpps)
                {
                    for(PriceBookEntry pbe : PricebookEntryList){
                        OpportunityLineItem oppLine = new OpportunityLineItem();
                        oppline.OpportunityId = opp.id;
                        oppline.PricebookEntryId  = pbe.Id;
                        oppline.Quantity =1;
                        oppline.TotalPrice =0;
                        oppline.Product_Id__c = pbe.Product2.Product_Id__c;
                        oppLine.Description = 'Extension Complimentary';
                        lstOppLines.add(oppLine);
                    }
                }
                
                if(!lstOppLines.isEmpty())
                    insert lstOppLines;
                
                ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                trans.Opportunity__c = newopp.Id;
                trans.ChargentOrders__Order__c = order.Id;
                trans.ChargentOrders__Amount__c = 0.00;
                trans.ChargentOrders__Response_Message__c = 'Approved';
                trans.ChargentOrders__Response_Status__c = 'Approved';
                trans.ChargentOrders__Type__c = 'Charge';
                trans.ChargentOrders__Payment_Method__c ='Free';
                trans.ChargentOrders__Gateway_Date__c =system.now();
                insert trans;
            }
     	}
        if(!listToUpdate.isEmpty()){
            update listToUpdate;
        }
    }
   	global void finish(Database.BatchableContext BC){
        
    }
}