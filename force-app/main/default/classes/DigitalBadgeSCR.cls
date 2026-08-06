public without sharing class DigitalBadgeSCR {

    public Contract userCont { get; set; }
    public string Name {get; set;}
    public string GARPID {get; set;}
    public string SCRYearCertified {get; set;}

    public DigitalBadgeSCR() {
    
       List<Contact> lstCont = [select  Id, AccountID, Name, GARP_ID__c
                                 from Contact 
                                 where id = :ApexPages.currentPage().getParameters().get('id')]; 
        System.Debug('lstCont:'+ lstCont );
        
        if(!lstCont.IsEmpty()) {       
            Contact cont = lstCont[0]; 
            SCRYearCertified = '';
            List<Contract> lstContract = [SELECT All_Requirements_Completed_Date__c FROM Contract WHERE RecordType.Name = 'SCR Program' AND AccountId = :cont.AccountID AND All_Requirements_Completed__c = TRUE];
            System.Debug('lstContract:'+ lstContract);
            
            Name = cont.name;
            GARPID  = cont.GARP_ID__c;
            if(!lstContract.IsEmpty()) {
                userCont = lstContract[0];
                SCRYearCertified = String.valueOf(userCont.All_Requirements_Completed_Date__c.year());
            }
            System.Debug('SCRYearCertified:'+ SCRYearCertified);
            
        }
    }

    public PageReference urlRedirection() {
        //Considering the user as not certified if the year is null or empty
        
        
        System.Debug('INIT userCont:'+ userCont );
        System.Debug('INIT SCRYearCertified:'+ SCRYearCertified );
        
        if(userCont == null || String.isBlank(SCRYearCertified)){
            string url = 'https://www.garp.org/';
            PageReference page = new PageReference(url);
            page.setRedirect(true);
            return page;
        }
        else{
            return null;
        }
    }
}