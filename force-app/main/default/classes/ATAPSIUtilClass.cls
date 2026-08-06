public class ATAPSIUtilClass {
    public static boolean examRegistrationTriggerRecursion = false;
    
    public static PSI_Eligibility__mdt getPSIEligibility_mdt(){
        PSI_Eligibility__mdt psimtd = new PSI_Eligibility__mdt();
        List<PSI_Eligibility__mdt>  PSIEligibility = [Select id,Account_Code__c,Get_Eligibility_URL__c,Client_Secret__c,Add_Eligibility_URL__c,Update_Eligibility_URL__c,
                                                      Cancel_Eligibility_URL__c,EndPoint__c,Password__c,PSI_Token_URL__c,User_Name__c From PSI_Eligibility__mdt where DeveloperName ='PSI_Eligibility_Setting'];
        if(!PSIEligibility.isEmpty()){
            psimtd = PSIEligibility[0];
        }
        return psimtd;
    }
    
    public static Map<Id,Decimal> getLatestVersionIntegritaion(String examRegId){
        Map<Id,Decimal> checkDupicateDataMap = new Map<Id,Decimal>();              
        for(Integration_Data__c ps:[SELECT Id,Version_Number__c,Is_Active__c,Exam_Registrations__c FROM Integration_Data__c  WHERE Exam_Registrations__c =:examRegId  Order By Version_Number__c Desc Limit 1]){  
            if(!checkDupicateDataMap.containsKey(ps.Exam_Registrations__c)){  
                checkDupicateDataMap.put(ps.Exam_Registrations__c,ps.Version_Number__c);
            }                                    
        }
        return checkDupicateDataMap;
    }
    
     public static Map<String,ATA_Cert_Type_List__c> getATACertTypeList(){
        Map<String,ATA_Cert_Type_List__c> ATACertTypeMap = new Map<String,ATA_Cert_Type_List__c>();
         ATACertTypeMap = ATA_Cert_Type_List__c.getAll();
        return ATACertTypeMap;
    }
    
    public static ATA_Scheduling_Interface__mdt getATASchedulingInterface_mdt(){
        ATA_Scheduling_Interface__mdt atamtd = new ATA_Scheduling_Interface__mdt();
        List<ATA_Scheduling_Interface__mdt>  ATASetup = [Select Id,Batch_No__c,App_Id__c,EndPoint__c,Private_Key__c From ATA_Scheduling_Interface__mdt where DeveloperName ='ATA_Scheduling_Interface_Setting'];
        if(!ATASetup.isEmpty()){
            atamtd = ATASetup[0]; 
        }
        return atamtd;
    }
    public static string getPSIaccesstoken(PSI_Eligibility__mdt psimtd){
        String accessToken;
        Httprequest req = new HttpRequest();    
        req.setMethod('POST');
        req.setHeader('auth',psimtd.Client_Secret__c);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setBody('grant_type=password' +  
                    '&username=' + psimtd.User_Name__c +
                    '&password=' + psimtd.Password__c
                   );    
        req.setEndpoint(psimtd.PSI_Token_URL__c);        
        Http http = new Http();
        HttpResponse res= http.send(req);  
        //system.debug('req:'+req);            
        system.debug('body:'+res.getBody());        
        JSONParser parser = JSON.createParser(res.getBody());
        //system.debug('parser:'+parser);      
        while (parser.nextToken() != null) {
            system.debug('parser:'+parser.nextToken());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                String fieldName = parser.getText();
                parser.nextToken();
                //System.debug('fieldName'+fieldName);
                if (fieldName == 'access_token') {
                    accessToken = parser.getText();
                }
            }
        }  
        
        return accessToken;
    }
    
    public static List<Integration_Data__c> cloneActiveIntegrationData(Set<Id> IntegrationId){ 
        List<Integration_Data__c> IntegrationActierec = new List<Integration_Data__c>(); 
        if(IntegrationId.size()>0){
            List<String> fields = new List<String>();
            fields.addAll(Integration_Data__c.getsObjectType().getDescribe().fields.getMap().keySet());
            String soql = 'SELECT ' + String.join(fields, ',') +
                ' FROM Integration_Data__c WHERE Id IN: IntegrationId';
            IntegrationActierec = Database.query(soql).deepclone(false,false,false); 
        }
        return IntegrationActierec;
    }
    
    public static string stripJsonNulls(string JsonString){
        
        if(JsonString != null)  
        {
            JsonString = JsonString.replaceAll('\"[^\"]*\":null',''); //basic removeal of null values
            JsonString = JsonString.replaceAll(',{2,}', ','); //remove duplicate/multiple commas
            JsonString = JsonString.replace('{,', '{'); //prevent opening brace from having a comma after it
            JsonString = JsonString.replace(',}', '}'); //prevent closing brace from having a comma before it
            JsonString = JsonString.replace('[,', '['); //prevent opening bracket from having a comma after it
            JsonString = JsonString.replace(',]', ']'); //prevent closing bracket from having a comma before it
        } 
        return JsonString;
    }
    
    
    public static string getATAstatus(String resbody){
        string resstatus='';  
        JSONParser parser = JSON.createParser(resbody);  
        while (parser.nextToken() != null) { 
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                String fieldName = parser.getText();
                parser.nextToken(); 
                if (fieldName == 'resp_msg') {
                    resstatus = parser.getText();
                }
            }
        }  
        return resstatus;
    }
    
    Public Static List<Integration_Data__c> updateActiveRecordsPSIATA(Set<Id> intdataId){
         List<Integration_Data__c> UpdateintegrationDataList = new  List<Integration_Data__c>();
        if(intdataId.size()>0){
            Map<Id,boolean> duplicatecheckList = new Map<Id,boolean>(); 
            for(Api_Transaction__c at:[Select Id,Error__c,Integration_Data__c from Api_Transaction__c where Integration_Data__c in:intdataId And Error__c = null]){
                if(!duplicatecheckList.containsKey(at.Integration_Data__c)){
                    Integration_Data__c intdata = new Integration_Data__c(); 
                    intdata.Id = at.Integration_Data__c; 
                    intdata.Is_Active__c = false;
                    UpdateintegrationDataList.add(intdata);
                }
                duplicatecheckList.put(at.Integration_Data__c,true);
            }
            
        }
        return UpdateintegrationDataList;
    }
    Public Static List<Integration_Data__c> updateActiveRecords(Set<Id> intId,Set<Id> examRegId){
        List<Integration_Data__c> UpdateintegrationDataList = new  List<Integration_Data__c>(); 
        for(Integration_Data__c ex: [Select Id,Is_Active__c from Integration_Data__c Where Id NOT In:intId And Exam_Registrations__c In:examRegId And Is_Active__c = true]){
            ex.Is_Active__c = false;
            UpdateintegrationDataList.add(ex);
        }
        
        return UpdateintegrationDataList;
    }
}