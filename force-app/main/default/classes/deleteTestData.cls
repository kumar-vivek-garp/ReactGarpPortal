public class deleteTestData {
    
    
    public class objectWrapper{
        @auraEnabled  public contact con ;
        @auraEnabled  public Account acc ;
        @auraEnabled  public list<contract> cr ;
        @auraEnabled  public list<Exam_Attempt__c> ea ;
        @auraEnabled  public list<Experience__c> ex ;
        @auraEnabled  public list<CPE_Claim__c> claims ;
        @auraEnabled  public list<Chapter_Member__c> cm ;
        @auraEnabled  public list<Chapter_Meeting_Registration__c> cmr ;
        @auraEnabled  public list<eBook_Key__c> ek ;
        @auraEnabled  public list<Event_Registration__c> er ;
        @auraEnabled  public list<SME_Registration__c> sme ;
        @auraEnabled  public list<case> ca ;
        @auraEnabled  public list<opportunity> opp ;
        @auraEnabled  public list<Webcast_Registration__c> wr;
        @auraEnabled public list<user> us;
        @auraEnabled public string Message;
        
        public objectWrapper(){
            // initialize above vairables as they are array.     
            con = new  contact() ;
            acc  = new Account();
            cr  = new list<contract> ();
            ea = new list<Exam_Attempt__c>();
            ex = new list<Experience__c>();
            claims = new list<CPE_Claim__c>();
            cm = new list<Chapter_Member__c>();
            cmr = new list<Chapter_Meeting_Registration__c>();
            ek = new list<eBook_Key__c>();
            er = new  list<Event_Registration__c>();
            sme = new list<SME_Registration__c>();
            ca = new list<case>();
            opp = new list<opportunity>();
            wr = new list<Webcast_Registration__c>();
            us = new list<user>();    
        }
    }
    
    
    @auraEnabled
    public static objectWrapper deleteTestData(string name){
        //system.debug('Garpid ======>'+name);
        objectWrapper data = new objectWrapper ();
        contact c =[select id ,email,accountid from contact where GARP_Member_ID__c =:name];
        
        list<String> emailDomains = new list<String>();
        string e = c.email;
        emailDomains.add(e.split('@').get(1));
        Boolean result=emailDomains.contains('garpqa.com');
        //system.debug('result:'+result);
        //system.debug('emailDomains:'+emailDomains);
        
        /* if(result==false){
            data.Message = 'you cannot delete this contact as this is not test account.';
            return data;}*/
        
        string accid = c.accountid;
        string conid  = c.id;
        
        Savepoint sp = Database.setSavepoint();
        
        deletecontract(accid);
        String examRegMessage = deleteexamattempt(name);
       //system.debug('examRegMessage========>'+examRegMessage);
        if (examRegMessage == '' ) {
            deletchaptermember(conid);
        deletchaptermeetingregistration(conid);
        deleteWebcastRegistration(conid);
        deletproctorregistration( name);
        deletebook( name);
        deleteeventregistration( conid);
        deletesme( name);
        deletecase( name);
        string oppMessage = deleteopportunity(accid);
        string Message;
        
        if(oppMessage == NULL){
            Message=InactivateAccount(accid);
            //system.debug('Message=======>'+Message);
        }
        else {
           Message = oppMessage;
            //system.debug('Message=======>'+Message);
        }
        if(Message =='updated account'){
            //system.debug('%%%%%:'+Message);
            deleteaccount(accid);
            data.Message = 'sucess';
        } else {
            data.Message = Message;
            //system.debug('Message=======>'+Message);
            Database.rollback( sp );
            //system.debug('Rollback done');
        }
        //system.debug('Final Message=======>'+Message);
        } else {
            Database.rollback( sp );
            data.Message = 'Try Again Active exam Registration is not Cancelled';
        }
        
        return data;
        
    }
    @auraEnabled
    public Static void deletecontract(string accid){
        //System.debug('Delete Contract');
        //System.debug('%%%%:'+accid);
        objectWrapper data = new objectWrapper ();
        
        data.cr =[select id,status, Membership_Type__c ,StartDate ,EndDate, GARP_ID__c  from contract where Accountid =:accid];       
        //system.debug('data.cr=====>'+data.cr);
        if(data.cr.size()>0){
            delete data.cr;
        }
    }
    
    // Changed 
    public static List<Exam_Attempt__c> getexamattempt(string name){ 
        objectWrapper data = new objectWrapper ();
         data.ea =[select id,Cancelled__c , Opportunity_StageName__c  ,Result__c  ,Defered__c , Garp_Id__c,Active_Integration_Data__c,Active_Integration_Data__r.Name,
                  (select id from Integration_Data__r)
                  from Exam_Attempt__c where GARP_ID__c =:name]; 
        if(test.isRunningTest()){
            data.ea = [select id,Cancelled__c , Opportunity_StageName__c  ,Result__c  ,Defered__c , Garp_Id__c,Active_Integration_Data__c,Active_Integration_Data__r.Name,
                  (select id from Integration_Data__r)
                  from Exam_Attempt__c LIMIT 1]; 
        }
        return data.ea;
    }
    
    @auraEnabled
    public static String deleteexamattempt(string name){
        //System.debug('Delete ExamAttempt');
        //System.debug('%%%%:'+name);
        objectWrapper data = new objectWrapper ();
        List<Id> integrationDataIds = new List<Id>();
        List<Exam_Attempt__c> updateCancel = new List<Exam_Attempt__c>();
        List<API_Transaction__c> apiTrans = new List<API_Transaction__c>();
        data.ea = getexamattempt(name);
        for(Exam_Attempt__c e : data.ea) {
            if(e.Active_Integration_Data__c != NULL){
                e.Cancelled__c = true;
                updateCancel.add(e);
           } 
            if(e.Integration_Data__r.size()>0){
                for(Integration_Data__c i : e.Integration_Data__r){
                    integrationDataIds.add(i.id);
                }  
            }
        }
        update updateCancel;
        data.ea = getexamattempt(name);
        //system.debug('Rev:data.ea=======>'+data.ea);
        //system.debug('Rev:data.ea.size=======>'+data.ea.size());
        for(Exam_Attempt__c e : data.ea) {
            //system.debug('e.Cancelled__c======>'+e.Cancelled__c);
            if(e.Active_Integration_Data__c != NULL){
            if (!e.Active_Integration_Data__r.Name.contains('Cancel') && e.Cancelled__c == true){
                data.Message = 'Call back';
            } 
        } else {
                 data.Message = '';
            }
        }
        if(integrationDataIds.size()>0 && data.Message == ''){
            apiTrans = [select id from API_Transaction__c where Integration_Data__c  IN: integrationDataIds ];
            delete apiTrans;
            
            List<Integration_Data__c> intData = [Select id from Integration_Data__c where id IN: integrationDataIds ];
            delete intData;
        }
        //  integrationDataIds = data.ea. 
        if(data.ea.size()>0 && data.Message == NULL){
            delete data.ea;
        }
        return data.Message;
    }    
    
    @auraEnabled
    public static void deletchaptermember(string conid){
        //System.debug('Delete ChapMeeting');
        //System.debug('%%%%:'+conid);
        objectWrapper data = new objectWrapper ();
        
        data.cm =[select id,Chapter__r.name,Chapter_Status__c  from Chapter_Member__c  where Contact__c=:conid];
        
        if(data.cm.size()>0){
            delete data.cm;
        }
    }
    
    @auraEnabled
    public static void deletchaptermeetingregistration(string conid){
        //System.debug('Delete ChapMeetingReg');
        //System.debug('%%%%:'+conid);
        objectWrapper data = new objectWrapper ();
        
        data.cmr =[select id,Chapter_Name__c,Chapter_Meeting_Location__c   from Chapter_Meeting_Registration__c  where Contact__c=:conid];
        if(data.cmr.size()>0){
            delete data.cmr;
        }
    }
   
    @auraEnabled
    public static void deleteWebcastRegistration(string conid){
        //System.debug('Delete WebCast REg');
        //System.debug('%%%%:'+conid);
        objectWrapper data = new objectWrapper ();
        
        data.wr =[select id ,Contact__c  from Webcast_Registration__c  where Contact__c =:conid];
        if(data.wr.size()>0){
            delete  data.wr;
        }
    }
   
    @auraEnabled
    public static void deletproctorregistration(string name){
        //System.debug('Delete Proctor reg');
        //System.debug('%%%%:'+name);
        objectWrapper data = new objectWrapper ();
        
    }
   
    @auraEnabled
    public static void deletebook(string name){
        //System.debug('Delete ebook');
        //System.debug('%%%%:'+name);
        objectWrapper data = new objectWrapper ();
        list<eBook_Key__c> ekec = new list<eBook_Key__c> ();
        list<eBook_Key__c> ek = [select id, Opportunity_Status__c, Member_EMail__c   from eBook_Key__c where Opp_GARP_ID__c =:name ];
        if(ek.size()>0){
        for(eBook_Key__c eb:ek){
           eb.Member_EMail__c ='';
          ekec.add(eb);
        }
            update ekec;
        }
    } 
    
    @auraEnabled
    public static void deleteeventregistration(string conid){
        //System.debug('Delete event reg');
        //System.debug('%%%%:'+conid);
        
        objectWrapper data = new objectWrapper ();
        
        data.er = [select id,Dietary_Restriction__c ,Dietary_Restriction_Description__c  from Event_Registration__c  where Contact__c=:conid ];
        if(data.er.size()>0){
            delete  data.er;
        }
    } 
    
    @auraEnabled
    public static void deletesme(string name){
        //System.debug('Delete sme');
        //System.debug('%%%%:'+name);
        objectWrapper data = new objectWrapper ();
        data.sme =[select id,Credit_Risk__c ,Culture_Governance__c  from SME_Registration__c  where GARP_Member_ID__c=:name ];
        if(data.sme.size()>0){
            delete  data.sme;
        }
    } 
   
    @auraEnabled
    public static void deletecase(string name){
        //System.debug('Delete Case');
        //System.debug('%%%%:'+name);
        
        objectWrapper data = new objectWrapper ();
        
        data.ca =[select id from case where GARP_ID__c =:name ];
        if(data.ca.size()>0){
            delete  data.ca;
        }
    }
    
    // Changed
    @auraEnabled
    public static String deleteopportunity(string accid){
        //System.debug('Delete Opp');
        //System.debug('%%%%:'+accid);
        objectWrapper data = new objectWrapper ();
        String oppErrorMessage ;
        data.opp =[select id, Display_Invoice_Number__c,(select id from Transactions__r where ChargentOrders__Type__c = 'Charge' and ChargentOrders__Gateway_ID__c != NULL),(select id from eBook_Keys__r where Cancelled__c = FALSE) from opportunity where accountid =:accid];
        if(data.opp.size()>0) {
            for(Opportunity opp : data.opp) {
                if(opp.eBook_Keys__r.size()>0) {
                    oppErrorMessage = 'Can\'t delete Opportunity as it contains active Ebooks';
                } else if(opp.Transactions__r.size()>0 && oppErrorMessage == NULL ) { 
                    oppErrorMessage = 'Can\'t delete Opportunity as it contains Credit Card Details';
                }
            }
            if(oppErrorMessage == NULL){
               delete  data.opp; 
            }
        }
        return oppErrorMessage ;
    }
   
    @auraEnabled
    public static string InactivateAccount(string accid){
        //System.debug('Inactivate Account');
        //System.debug('%%%%:'+accid);
        objectWrapper data = new objectWrapper ();
        
        data.acc =[select id,name,type, IsCustomerPortal,industry,RecordType.Name,RecordTypeId, GARP_ID__c,Is_Test_Override__c from Account where id  =:accid ];
        //system.debug('data.acc.name=======>'+data.acc.name);
        //system.debug('data.acc.name.contains(\'Test\')========>' +data.acc.name.contains('test'));
        if(data.acc.Is_Test_Override__c == 'Is Test'){
            if(data.acc.name.toLowercase().contains('test')){
                data.acc.IsCustomerPortal = false;
                update data.acc;
                data.Message ='updated account';
            } else {
                data.Message ='Not Test Data';
            }
        } else {
            data.Message ='IsTestOverride is \'Not IsTest\'';
        }
        //system.debug('data.Message======>'+data.Message);
        return data.Message;
    }
    
    @auraEnabled
    public static void deleteaccount(string accid){
        //System.debug('Delete Account');
        //System.debug('%%%%:'+accid);
        objectWrapper data = new objectWrapper ();
        
        list<account> acc =[select id,name,type, IsCustomerPortal,industry,RecordType.Name,RecordTypeId, GARP_ID__c  from Account where id  =:accid ];
        //System.debug('acc:'+acc);
        
        delete acc;
    }
}