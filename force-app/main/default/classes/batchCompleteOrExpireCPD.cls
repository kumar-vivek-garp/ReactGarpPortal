global class batchCompleteOrExpireCPD implements Database.Batchable<sObject>,Database.StateFul{

    public String recordid;
    global batchCompleteOrExpireCPD(String recId){
        this.recordid = recId;
    }
	global batchCompleteOrExpireCPD(){ 
    }
         global Database.QueryLocator start(Database.BatchableContext BC){
             
           //  run with a batch size of 50.
             string constatus ='Activated ( Auto-Renew )';
             Id CPEContRecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
             Id CPEPRRecordTypeID = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
             Date StartDate = date.newInstance(2024, 01, 01);
             String query = 'select id,Approved_Credits_Total__c,Candidate_Commitment__c,Status__c,Candidate_Commitment__r.status from Candidate_Requirement__c where Candidate_Commitment__r.RecordTypeId=:CPEContRecordTypeID and Candidate_Commitment__r.StartDate =: StartDate and recordtypeID =: CPEPRRecordTypeID and Candidate_Commitment__r.status =:constatus';
             if(recordid != null){
                 query += ' And Id=:recordid';
             }
             return Database.getQueryLocator(query); 
         }
    
    global void execute(Database.BatchableContext BC, List<Candidate_Requirement__c> lstCRs){
        
        List<ID> lstCompletedContracts = new List<ID>();
        List<ID> lstExpiredContracts = new List<ID>();
        Id CPEContRecordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        Id CPEPRRecordTypeID = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        Id AttestPRRecordTypeID = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','Attest');
        List<contract> lstToBeCloned = new List<contract>();
        
        // Check for the Approved Credits
        for(Candidate_Requirement__c cr : lstCRs)
        {
            if(cr.Approved_Credits_Total__c >= 40)
                lstCompletedContracts.add(cr.Candidate_Commitment__c);
            else 
                lstExpiredContracts.add(cr.Candidate_Commitment__c);
        }
        
        // Mark the contracts as Completed / Expired based on Approved Credits.
        List<contract> lstUpdateContracts = new List<contract>();
        List<contract> lstUpdateContracts1 = new List<contract>();
        if(!lstCompletedContracts.isEmpty())
        {
            for(contract c: [Select id,Status from contract where ID in: lstCompletedContracts])
            {
                c.status = 'Completed';
                lstUpdateContracts.add(c);
            } 
            Update lstUpdateContracts;
            lstToBeCloned.addAll(lstUpdateContracts);
        }
        
        
        if(!lstExpiredContracts.isEmpty())
        {
            for(contract c: [Select id,Status from contract where ID in: lstExpiredContracts])
          {
                c.status = 'Expired';
                lstUpdateContracts1.add(c);
          } 
            Update lstUpdateContracts1;
            lstToBeCloned.addAll(lstUpdateContracts1);
        }
        
        
        // Create new CPD Program
         List<Contract> lstInsertClone = New List<contract>();
        if(!lstToBeCloned.isEmpty())
        {
            for(contract c: [Select id,Status,StartDate,ContractTerm,AccountId from contract where ID in: lstToBeCloned])
              {
                    contract cloneProg = c.clone(false,true,false,false);
                    cloneProg.AccountId = c.AccountId;
                    cloneProg.Status = 'Draft';
                    cloneProg.RecordTypeId = CPEContRecordTypeID;
                    cloneProg.StartDate = Date.newInstance(2026, 01, 01);
                    cloneProg.ContractTerm = 24;
                    lstInsertClone.add(cloneProg);
              } 
             Insert lstInsertClone;
        }
        
        // Activate newly created CPD contracts
         List<contract> lstActivate = new List<contract>();
        if(!lstInsertClone.isEmpty())
        {
                for(contract c: [Select id,Status,StartDate,ContractTerm from contract where ID in: lstInsertClone])
                  {
                        
                        c.Status = 'Activated ( Auto-Renew )';
                        lstActivate.add(c);
                  } 
                 Update lstActivate;    
        }  
        // Create CPD Program Requirements 
        list< Candidate_Requirement__c > newCPERequirements = new List<Candidate_Requirement__c>(); 
        list< Candidate_Requirement__c > newAttestRequirements = new List<Candidate_Requirement__c>(); 
                    
        if(!lstActivate.isEmpty())
        {           
                    for(contract c: [Select id,Status,StartDate,ContractTerm from contract where ID in: lstActivate])
                    {
                        newCPERequirements.add( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = CPEPRRecordTypeID,Name = 'CPD Credit', Status__c = 'Initial' )) ;    
                        newAttestRequirements.add( new Candidate_Requirement__c ( Candidate_Commitment__c = c.id, recordTypeID = AttestPRRecordTypeID,Name = 'CPD Attest', Status__c = 'Initial' )) ;    
                    }
                    insert newCPERequirements;
                    insert newAttestRequirements;
        }      
    } // End of Execute method
    
    global void finish(Database.BatchableContext BC){
   
   }
    
}