public class CPDCertificateCtrl {
    

    public String firstName { get; set; }
    public String lastName { get; set; }
    public String garpId { get; set; }
    public String cycle { get; set; }

    public Contract contract { get; set; }
    
    public CPDCertificateCtrl (){
        
            Id contactId;
            
            User user = [
                SELECT Id, ContactId, Contact.FirstName, Contact.LastName, Contact.GARP_Member_ID__c 
                FROM User 
                WHERE Id = :UserInfo.getUserId()
            ];
            
            if(!Test.isRunningTest() && (user == NULL || user.ContactId == NULL)) {
                
                 return;
            }
            
            contactId = user.ContactId;
            this.firstName = user.Contact.FirstName;
            this.lastName = user.Contact.LastName;
            this.garpId = user.Contact.GARP_Member_ID__c;
        
        this.cycle = 'Unknown';
        this.contract = null;
            
            List<Contract> lstContarcts = [
                SELECT Id, All_Requirements_Completed_Date__c, CPE_Cycle__c 
                FROM Contract 
                WHERE RecordType.Name = 'CPE' AND id = :ApexPages.currentPage().getParameters().get('id')
            ];
            
            // Throw a page exceptions
            // if(scrContracts.isEmpty()){
            //     this.errorMessage = 'No SCR Program found.';
            //     return;
            // }
            
            if(lstContarcts != NULL && lstContarcts.size() > 0) {
                contract = lstContarcts[0];
                if(contract.CPE_Cycle__c != NULL) {
                    this.cycle = contract.CPE_Cycle__c.replace('-','/');
                }
            }
    }

}