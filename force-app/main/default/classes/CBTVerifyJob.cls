global class CBTVerifyJob implements Schedulable {

    public static void fixID() {
        List<Contact> lstCont = [Select GARP_ID__c, ID_Type__c, Id FROM Contact where ID_Type__c like '%#39%'];
        for(Contact c :lstCont) {
            c.ID_Type__c = 'Driver\'s License';
        }
        update lstCont;
        
        List<Exam_Attempt__c> lsEA = [Select Id, ATA_Cert_Type__c FROM Exam_Attempt__c where ATA_Cert_Type__c like '%#39%'];
        for(Exam_Attempt__c ea :lsEA) {
            ea.ATA_Cert_Type__c = 'Driver\'s License';
        }
        update lsEA;
        
        List<Lead> lsLeads = [Select Id, ID_Type__c from Lead where ID_Type__c like '%#39%' and ConvertedDate = null];
        for(Lead l :lsLeads) {
            l.ID_Type__c = 'Driver\'s License';
        }
        update lsLeads;        
    }
    
    public void runVerify() {
        
        List<AppError__c> lstAppErr = [select Id, Name, Message__c, Status__c from AppError__c where Name = 'CBT Auth Failed' AND CreatedDate = TODAY AND Status__c != 'Fixed'];
        
        System.debug('lstAppErr:' + lstAppErr);
        
        Set<String> lds = new Set<String>();
        MAP<String,AppError__c> mapErrors = new MAP<String,AppError__c>();
        for(AppError__c ae :lstAppErr) {
			mapErrors.put(ae.Message__c,ae);
        }
        System.debug('mapErrors:' + mapErrors);
        
        List<Exam_Attempt__c> lsEAerr = [Select Id,Section__c,Candidate_Commitment__c, Active_Integration_Data__c, RPT_Exam_Program__c,Outbound_Type__c, Integration_Type__c FROM Exam_Attempt__c where ID in :mapErrors.keySet()];
        System.debug('lsEAerr:' + lsEAerr);
        
        List<AppError__c> lstErrUpdate = new List<AppError__c>();
        List<Exam_Attempt__c> lstExamAttempUpdate = new List<Exam_Attempt__c>();
        Set<Id> scrContractIds = new Set<Id>();
        for(Exam_Attempt__c ea :lsEAerr) {
            System.debug('ea:' + ea);
            if(ea.Active_Integration_Data__c != NULL) {
                AppError__c ae = mapErrors.get(ea.Id);
                if(ae != NULL) {
                    ae.Status__c = 'Fixed';
                    lstErrUpdate.add(ae);
                }
            } else if(ea.RPT_Exam_Program__c == 'ATA') {
                ea.Outbound_Type__c = 'ATA';
                ea.Integration_Type__c = 'Import Registration New';
                lstExamAttempUpdate.add(ea);
            } else  if(ea.RPT_Exam_Program__c == 'PSI') {
                ea.Outbound_Type__c = 'PSI';
                ea.Integration_Type__c = 'Eligibility Lifecycle';
                lstExamAttempUpdate.add(ea);
            }else if(ea.Section__c == 'SCR'){
                scrContractIds.add(ea.Candidate_Commitment__c);
            }
            
            List<Contract> scrContractsToUpdate = new List<Contract>();
            List<Contract> contractList = [Select Id,Status from Contract where Id IN: scrContractIds];
            for(Contract c : contractList){
                c.SCR_Deferred_Status__c = 'Approved';
                scrContractsToUpdate.add(c);
            }
            
            if(!scrContractsToUpdate.isEmpty())
                update scrContractsToUpdate;
            
            //scrContractsToUpdate.clear();
            
            for(Contract c : scrContractsToUpdate){
                system.debug('Inside this debug');
                c.SCR_Deferred_Status__c = null;
            }
            
            if(!scrContractsToUpdate.isEmpty())
                update scrContractsToUpdate;
        }
        System.debug('lstErrUpdate:' + lstErrUpdate);
        update lstErrUpdate;
        
        System.debug('lstExamAttempUpdate:' + lstExamAttempUpdate);
        update lstExamAttempUpdate;
        
    }
    
    global void execute(SchedulableContext SC) {
        runVerify();
        //fixID();
    }
    
}