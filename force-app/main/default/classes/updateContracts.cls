global class updateContracts implements Database.Batchable<SObject> , Database.stateful
{
    global string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
    global string icbrrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
    global string frmRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
    global string fbrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FBR Program');
    global string erpRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
    global string cpeRecordType = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
    global string wileyRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Wiley Bookstore');
    global string RiskRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Risk.Net'); 
    
    
    public List<Database.SaveResult> errors = new List<Database.SaveResult>();
    public List<Database.SaveResult> successes = new List<Database.SaveResult>();
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        Set<String> setStatus = new Set<String>{'Activated','Activated ( Auto-Renew )'};
        Date dtEndDate = system.today();    
        string id ='8001W000004Cb8RQAS';
        
        if(!test.isRunningTest())
            return Database.getQueryLocator('select id,CompanySignedId,Last_Exam_registration_Date__c,AccountId,StartDate,enddate,All_Requirements_Completed__c,Last_Day_Contract_can_be_Active__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status,ActivatedDate from Contract where Status  in: setStatus and EndDate <: dtEndDate  and ActivatedDate !=null');
        else
            return Database.getQueryLocator('select id,Last_Exam_registration_Date__c,AccountId,Last_Day_Contract_can_be_Active__c,StartDate,enddate,All_Requirements_Completed__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status from Contract limit 10');
        
    }
    
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
        
        Map<Id,Contract> mapContract = new Map<Id,Contract>();
		List<String> expiredtypeList = new List<String>();
        expiredtypeList.add(RecordTypeHelper.GetRecordTypeId('Contract','FRR MC1 Program'));
        expiredtypeList.add(RecordTypeHelper.GetRecordTypeId('Contract','FRR MC2 Program'));
        expiredtypeList.add(RecordTypeHelper.GetRecordTypeId('Contract','FRR MC3 Program'));
        expiredtypeList.add(RecordTypeHelper.GetRecordTypeId('Contract','FRR MC4 Program'));
        expiredtypeList.add(RecordTypeHelper.GetRecordTypeId('Contract','FRR25 Program'));
        for(Contract con : scope)
        {
            system.debug('====updateContracts con:'+con);
            
            if(con.recordTypeId == memRecordType)
            {
                
                if(con.Membership_Type__c == 'Affiliate')
                    con.ContractTerm += 24;
                else if((con.Membership_Type__c == 'Student' || con.Membership_Type__c == 'Individual') && (con.Status == 'Activated' || con.Status=='Activated ( Auto-Renew )'))
                {
                    if(con.Status=='Activated ( Auto-Renew )')
                    {
                        Date endDate = con.Enddate;
                        Date todayDate = system.today();
                        Integer numberDaysDue = endDate.daysBetween(todayDate);
                        if(numberDaysDue >= 1)
                            con.Status = 'Expired';
                    }
                    else
                        con.Status = 'Expired';
                }
                                
                //Add it to MAP to avoid duplciate list error
                mapContract.put(con.Id,con);
                system.debug('%%%%%%1:'+mapContract);
            }
            
            if((con.recordTypeId == frmRecordType ||  con.recordTypeId == erpRecordType) && (con.Status=='Activated ( Auto-Renew )')){
                    
                con.ContractTerm += 12;
                //Add it to MAP to avoid duplciate list error
                mapContract.put(con.Id,con);
                system.debug('%%%%%%2:'+mapContract);
            }
            
            if((con.recordTypeId == frmRecordType ||  con.recordTypeId == erpRecordType) &&(con.Last_Day_Contract_can_be_Active__c < system.today())&&(con.Status=='Activated')) {
                con.Status = 'Expired';

                //Add it to MAP to avoid duplciate list error
                mapContract.put(con.Id,con);
                system.debug('%%%%%%3:'+mapContract);
            }
            if((con.recordTypeId == frmRecordType ||  con.recordTypeId == erpRecordType) &&(con.Last_Exam_registration_Date__c < system.today()&& con.Last_Day_Contract_can_be_Active__c ==null)&&(con.Status=='Activated')) {
                
                list<exam_attempt__C> ea =[select id,Candidate_Commitment__c,result__C from exam_attempt__C where result__C =''and Candidate_Commitment__c =:con.id and cancelled__c=false and Opportunity_StageName__c ='closed' FOR UPDATE];
                system.debug('***********:'+ea);
                if(ea.isEmpty()){
                    con.Status = 'Expired';
                    
                    //Add it to MAP to avoid duplciate list error
                    mapContract.put(con.Id,con);
                    system.debug('%%%%%%4:'+mapContract);
                }
            }
            if((con.recordTypeId == wileyRecordType ||  con.recordTypeId == icbrrRecordType || con.recordTypeId == fbrRecordType || con.recordTypeId == RiskRecordType || expiredtypeList.contains(con.recordTypeId))){
                
                system.debug('======== Update =====');
                con.Status = 'Expired';

                //Add it to MAP to avoid duplciate list error
                mapContract.put(con.Id,con);
                system.debug('%%%%%%4:'+mapContract);
                
            }
        }
        
        system.debug('====updateContracts mapContract:'+mapContract);
        
        if(mapContract.size()>0) {
            Database.SaveResult[] results = Database.update(mapContract.values(), false);

            for(Database.SaveResult sr: results){
                if(!sr.isSuccess()){
                    errors.add(sr);
                }else if(sr.isSuccess()){
                    successes.add(sr);
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        try {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String receipientList = system.label.Exception_Recipient_List;
            List<String> toAddresses = new list<string>();
            toAddresses.addall(receipientList.split(','));
            mail.setToAddresses(toAddresses);
            mail.setSubject('Update Contracts Batch Job Completed: ' + BC.getJobId());
            if(!errors.isEmpty() && !test.isRunningTest()){
                mail.setPlainTextBody('Contracts' + '\n\nErrors: \n\n' + JSON.serializePretty(this.errors));
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            }
            
            if(!successes.isEmpty()){
                Messaging.SingleEmailMessage mail2 = new Messaging.SingleEmailMessage();
                mail2.setToAddresses(toAddresses);
                mail2.setSubject('Update Contracts Batch Job Completed: ' + BC.getJobId());
                mail2.setPlainTextBody('Contracts' + '\n\nSuccesses: \n\n' + JSON.serializePretty(this.successes));
                if(!test.isRunningTest())
				Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail2 });
            }
         } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
}