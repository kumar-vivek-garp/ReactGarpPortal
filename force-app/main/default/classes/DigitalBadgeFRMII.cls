public without sharing class DigitalBadgeFRMII {
    
    public Contact userCont { get; set; }
    public string Name {get; set;}
    public string FRMPartIIYearCompleted {get; set;}
 
    public DigitalBadgeFRMII() {
    
        String paramId = ApexPages.currentPage().getParameters().get('id');
        
        List<Contact> lstCont = [select  Id, AccountID, Name, GARP_ID__c, Name_as_it_Appears_on_ID__c
                                 from Contact 
                                 where id = :paramId OR GARP_Member_ID__c = :paramId]; 
                 
        System.Debug('lstCont:'+ lstCont );
        if(!lstCont.IsEmpty()) {                          
            userCont = lstCont[0];
        }
        
        System.Debug('userCont :'+ userCont );  
        
        if(userCont != NULL) {
            
            List<Contract> lstContractsFRM = [select Id, All_Requirements_Completed_Date__c,
                                              (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Approved_Credits_Total__c, CPE_Credit_Requirement__c, recordType.DeveloperName FROM Candidate_Requirements__r)
                                              from Contract 
                                              where Recordtype.Name = 'FRM Program' AND AccountId = :userCont.AccountID AND Status in ('Activated','Activated ( Auto-Renew )','Completed')];
        	System.Debug('lstContractsFRM :'+ lstContractsFRM );  
            
            if(!lstContractsFRM.IsEmpty()) {
                Contract frmContract = lstContractsFRM[0];
                
                Candidate_Requirement__c frmPartIICanReq;
                for(Candidate_Requirement__c cr :frmContract.Candidate_Requirements__r) {
                    if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                        frmPartIICanReq = cr;
                        break;
                    }
                }
                System.Debug('frmPartIICanReq :'+ frmPartIICanReq);  
                
                if(frmPartIICanReq != NULL) {
                    if(userCont.Name_as_it_Appears_on_ID__c != NULL) {
                        Name = userCont.Name_as_it_Appears_on_ID__c;
                    } else {
                        Name = lstCont[0].name;
                    }
                    
                    FRMPartIIYearCompleted = String.ValueOf(frmPartIICanReq.Date_of_Completion__c.year());
                }
                
            }
        }
             
        
        System.Debug('Name:'+ Name );  
        System.Debug('FRMPartIIYearCompleted :'+ FRMPartIIYearCompleted );  
    }
    
    public PageReference urlRedirection() {
        string url = ApexPages.currentPage().getUrl();
        System.Debug('url :'+ url );  
        
            if(FRMPartIIYearCompleted != null)
            {
                return null;
            }
            else
            {
                PageReference page = new PageReference('https://www.garp.org/');
                page.setRedirect(true);
                return page;
            }
    }
}