public without sharing class DigitalBadge{
    
    public Contact userCont { get; set; }
    public string Name {get; set;}
    public string FRMYearCertified {get; set;}
    public string ERPYearCertified {get; set;}
 
    public DigitalBadge() {
    
        List<Contact> lstCont = [select  Id, AccountID, Name, GARP_ID__c, Fax, KPI_CPE_Current_Cycle__c, 
                                 KPI_CPE_Last_Completed_Cycle__c, Name_as_it_Appears_on_ID__c
                                 from Contact 
                                 where id = :ApexPages.currentPage().getParameters().get('id')]; 
                 
        System.Debug('lstCont:'+ lstCont );

        if(lstCont.IsEmpty()) {
            lstCont = [select  Id, AccountID, Name, GARP_ID__c, Fax, KPI_CPE_Current_Cycle__c, 
                       KPI_CPE_Last_Completed_Cycle__c, Name_as_it_Appears_on_ID__c
                       from Contact 
                       where GARP_Member_ID__c = :ApexPages.currentPage().getParameters().get('id')];
                             
            System.Debug('lstCont:'+ lstCont );
            if(!lstCont.IsEmpty()) {                          
                userCont = lstCont[0];
            }
            
        } else {
            userCont = lstCont[0];
        }

        if(userCont != NULL) {
            
            
            List<Contract> lstContractsFRM = [select Id, All_Requirements_Completed_Date__c from Contract where Recordtype.Name = 'FRM Program' AND AccountId = :userCont.AccountID AND All_Requirements_Completed__c = TRUE];
            List<Contract> lstContractsERP = [select Id, All_Requirements_Completed_Date__c from Contract where Recordtype.Name = 'ERP Program' AND AccountId = :userCont.AccountID AND All_Requirements_Completed__c = TRUE];
            
            if(userCont.Name_as_it_Appears_on_ID__c != NULL) {
                Name = userCont.Name_as_it_Appears_on_ID__c;
            } else {
                Name = lstCont[0].name;
            }
            
            if(!lstContractsFRM.IsEmpty() && lstContractsFRM[0].All_Requirements_Completed_Date__c != NULL)
                FRMYearCertified = String.ValueOf( lstContractsFRM[0].All_Requirements_Completed_Date__c.year() );
                
            if(!lstContractsERP.IsEmpty() && lstContractsERP [0].All_Requirements_Completed_Date__c != NULL)
                ERPYearCertified = String.ValueOf( lstContractsERP [0].All_Requirements_Completed_Date__c.year() );
         
        }
             
        System.Debug('userCont :'+ userCont );  
        System.Debug('Name:'+ Name );  
        System.Debug('FRMYearCertified :'+ FRMYearCertified );  
        System.Debug('ERPYearCertified :'+ ERPYearCertified  );  
    }
    
    public PageReference urlRedirection() {
        string url = ApexPages.currentPage().getUrl();
        System.Debug('url :'+ url );  
        
            if(userCont != null && ((String.isNotBlank(FRMYearCertified) && url.indexOf('DigitalBadgeFRM') != -1) || (String.isNotBlank(ERPYearCertified) && url.indexOf('DigitalBadgeERP') != -1)))
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