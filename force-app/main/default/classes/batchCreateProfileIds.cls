global class batchCreateProfileIds implements Database.Batchable<sObject>,Database.AllowsCallouts
{
    //run with a batch size of one please remeber that.
    
    global PayPal_Recurring_Settings__c payPalSettings = PayPal_Recurring_Settings__c.getOrgDefaults();
    global Database.QueryLocator start(Database.BatchableContext bc){
         
          String status = 'Activated ( Auto-Renew )'; 
          id id='80040000002jAt1';
          id memRecTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
          Integer iYear = system.today().year();
          date d = system.today()+15;
          string membershiptype ='Affiliate';
        if(Test.isRunningTest())
          return Database.getQueryLocator('select Id, Opportunity__c, Membership_Type__c ,Opportunity__r.stagename,Opportunity__r.AccountId,Opportunity__r.Token__c from contract where status =: status  and EndDate = LAST_N_DAYS : 15 and (Account.Profile_ID_Created_Date__c = null OR  CALENDAR_YEAR(Account.Profile_ID_Created_Date__c) =: iYear)');
        return Database.getQueryLocator('select Id, Opportunity__c,Opportunity__r.stagename,Opportunity__r.AccountId,Opportunity__r.Token__c from contract where status =: status and Membership_Type__c!=:membershiptype and EndDate <=:d and (Account.Profile_ID_Created_Date__c = null OR  CALENDAR_YEAR(Account.Profile_ID_Created_Date__c) !=: iYear or Account.Paypal_Batch_Error__c =true)  and recordtypeid=:memRecTypeId and CALENDAR_YEAR(Account.Paypal_Failure_Date__c) !=: iYear');
     

    }
    
    
    global void execute(Database.BatchableContext bc, List<contract> programs){
       
        Set<Id> oppIds = new Set<id>();
        for(contract ct : programs){
            oppIds.add(ct.Opportunity__c);
        }
        
        Map<Id,Opportunity> oppMap = new Map<Id,Opportunity>([Select Id,(Select Id,ChargentOrders__Tokenization__c from Chargent_Orders__r) from Opportunity where id in : oppIds]);
        
        Set<String> setTokens = new Set<String>();
        Map<String,Id> mapAccountsonToken = new Map<String,Id>();
        for(contract ct : programs)
        {
            if(ct.Opportunity__c != null){
                Opportunity opp = oppMap.get(ct.Opportunity__c);                
                if (opp.Chargent_Orders__r != null && !opp.Chargent_Orders__r.isEmpty()) {
                    setTokens.add(opp.Chargent_Orders__r[0].ChargentOrders__Tokenization__c);
                    mapAccountsonToken.put(opp.Chargent_Orders__r[0].ChargentOrders__Tokenization__c,ct.Opportunity__r.AccountId);
                } 
            }
        }
        Map<String,String> mapTokenProfile = new Map<String,String>();
        List<Account> lstAccounts = new List<Account>();
        for(String str : setTokens)
        {
            HttpResponse resp = createProfileID(str);
            String accId = mapAccountsonToken.get(str);
            Map<String,String> mapValues = new Map<String,String>();
            for(String strResp : resp.getBody().split('&'))
            {
                string[] arr = strResp.split('=');
                     mapValues.put(arr[0],arr[1]);
            }
            String result = mapValues.get('RESULT');
            String profileId =  mapValues.get('PROFILEID');
            String batchError = mapValues.get('BatchError');
            if(resp.getStatus() != 'OK' || result != '0'){
                if(accId != null)
                {
                    Account accUpdate = new Account();
                    accUpdate.Id = accId;
                    accUpdate.Paypal_Failure__c = true;
                    accUpdate.Paypal_Failure_Date__c = system.today();
                    accUpdate.Paypal_Batch_Error__c = (batchError == '1' ? true : false);
                    accUpdate.Response__c = resp.getBody();
                    lstAccounts.add(accUpdate);
                }

            }
            else
            {
                
                if(accId != null)
                {
                    Account accUpdate = new Account();
                    accUpdate.Id = accId;
                    accUpdate.Profile_ID__c = profileID;
                    accUpdate.Response__c = resp.getBody();
                    accUpdate.Paypal_Failure__c = false;
                    accUpdate.Profile_ID_Created_Date__c= system.today();
                    accUpdate.Paypal_Failure_Date__c = null;
                    accUpdate.Paypal_Batch_Error__c = false;
                    lstAccounts.add(accUpdate);
                }
            }
        }
        
         
            
        if(!lstAccounts.isEmpty())
            update lstAccounts;
            
    }
    global void finish(Database.BatchableContext bc){
     try
        {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new String[] {payPalSettings.Email_Address__c});
            mail.setReplyTo(payPalSettings.Email_Address__c);
            mail.setSenderDisplayName('Paypal Processing');
            mail.setSubject('Paypal profileid Process Completed');
            mail.setPlainTextBody('Paypal profileid Process has completed');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        catch(exception ex)
        {

        }
           
    }
    
    HttpResponse createProfileID(String token)
    {
        system.debug('token == '+token);
        //Succesful Response : RESULT=0&RPREF=R1058EFCE39F&PROFILEID=RT0000000017&RESPMSG=Approved
        //Falied Resposne : RESULT=1&RESPMSG=User authentication failed
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint('https://payflowpro.paypal.com');
        
         

        String body = 'TRXTYPE=R&TENDER=C&PARTNER=VeriSign&VENDOR=GARPNY&USER=GARPNY&PWD=garp147view&ACTION=A&PROFILENAME=RegularSubscription&ORIGID='+token+'&START=01012070&PAYPERIOD=YEAR&COMMENT1=Recurring payment&AMT=150';
        system.debug('body == '+body);
        httpRequest.setBody(body);
        httpRequest.setMethod('GET');
        httpRequest.SetTimeOut(120000);
        Http htt = new hTTP();
        HttpResponse httpRe;
        try
        {
            if(!Test.isRunningTest())
            
                 httpRe = htt.send(httpRequest);
            else
            {
                httpRe = new HttpResponse();
                httpRe.setStatus('OK');
                httpRe.setBody('PROFILEID=123456789');
            }
            
        }
        catch(Exception ex)
        {
            httpRe.setBody('RESULT=1&BatchError=1&ERRMSG='+ex.getMessage());
            
        }
        system.debug(httpRe.getBody());
        return httpRe;
        /*
        if(httpRe.getStatus() != 'OK') return null;
        Map<String,String> mapValues = new Map<String,String>();
        for(String str : httpRe.getBody().split('&'))
        {
            string[] arr = str.split('=');
                 mapValues.put(arr[0],arr[1]);
        }
        
        return mapValues.get('PROFILEID');*/
        
    }

}