global class updateScrContracts implements Database.Batchable<SObject>
{
   
    global string ScrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
    global Id RiskAIProgramID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program'); //Chinnapa
    global Id RAIJProgramID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
    
    Set<String> setStatus = new Set<String>{'Activated'};
    Date dtEndDate = system.today();    
    string id ='800400000020HIHAA2';
    
    if(!test.isRunningTest())
        return Database.getQueryLocator('select id,Last_Exam_registration_Date__c,SCR_Computed_Expiration_Date__c,AccountId,StartDate,enddate,All_Requirements_Completed__c,Last_Day_Contract_can_be_Active__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status,ActivatedDate from Contract where Status  in: setStatus and SCR_Computed_Expiration_Date__c <: dtEndDate  and ActivatedDate !=null  and (recordtypeid=:ScrRecordType OR recordtypeid=:RiskAIProgramID OR recordtypeid=:RAIJProgramID)');
    else
        return Database.getQueryLocator('select id,Last_Exam_registration_Date__c,AccountId,Last_Day_Contract_can_be_Active__c,StartDate,enddate,All_Requirements_Completed__c,recordTypeId,recordType.Name,Membership_Type__c,ContractTerm,Status from Contract limit 1');
        
     }
    
    
    global void execute(Database.BatchableContext BC, List<Contract> scope){
    
       List<Contract> lstContract = new List<Contract>();
        Map<Id,Contract> mapContract = new Map<Id,Contract>();
        for(Contract con : scope)
        {
   
        list<exam_attempt__C> ea =[select id,Candidate_Commitment__c,result__C from exam_attempt__C where result__C =''and Candidate_Commitment__c =:con.id and cancelled__c=false and Opportunity_StageName__c ='closed'];
        //system.debug('***********:'+ea);
            if(ea.isEmpty()){    
        		con.Status = 'Expired';
                lstContract.add(con);
                //Add it to MAP to avoid duplciate list error
                mapContract.put(con.Id,con);
               // system.debug('^^^^^:'+lstContract);
            }
                   
      
        }
        update mapContract.values();
        }
     
    global void finish(Database.BatchableContext BC){
         
       
    }

}