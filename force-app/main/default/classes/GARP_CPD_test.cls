@isTest
public class GARP_CPD_test {

    public static Account account;
    public static Contact contact;
    
    public static void setup(){
        
        List<String> prodsFRR = new List<String>{'MEMI:MEMI:4040:100','MEMC:MEMC:4040:100','CBRNM:CBRNM:4040:100','CBR:CBR:4040:100','CBRHB:CBRHB:4040:100','SHIP:SHIP:4040:100'};
        GARP_TestFactory.createProducts(prodsFRR, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        List<String> prodsFFR = new List<String>{'FCBR:FCBR:4000:100','FBRNM:FBRNM:4000:100'};
        GARP_TestFactory.createProducts(prodsFFR, new Set<String>{}, new Set<String>{}, new Set<String>{});

        List<String> prodsSCR = new List<String>{'SCRME:SCRME:4004:100','SCRNME:SCRNME:4004:100','SCRH:SCRH:4030:100','SCRX:SCRX:4030:100','SCRCN:SCRCN:4030:100'};
        GARP_TestFactory.createProducts(prodsFFR, new Set<String>{}, new Set<String>{}, new Set<String>{});
        
        GARP_TestFactory.createCountryCodes();
        contact = GARP_TestFactory.createMember('garpqamem@garpqa.com', True);
        System.debug('!!setup contact:' + contact);
    }
    
    public static testmethod void testGetProfile() {        
        setup();
        
        Id cpdProgRecId = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        Contract cpdContract = new Contract(Opportunity__c = null, AccountId = contact.AccountId, recordTypeId = cpdProgRecId, Status='Draft',
                                            StartDate=Date.newInstance(Date.today().Year(), 1, 1), ContractTerm=24);
        insert cpdContract;
        cpdContract.Status = 'Activated';
        update cpdContract;
        
        Id cpdProgReqRecId = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c','CPE');
        Candidate_Requirement__c canReqCpe = new Candidate_Requirement__c(Candidate_Commitment__c=cpdContract.Id, Name='CPE', Status__c='Active', recordTypeId=cpdProgReqRecId);
        insert canReqCpe;
        Candidate_Requirement__c canReqAttest = new Candidate_Requirement__c(Candidate_Commitment__c=cpdContract.Id, Name='Attest', Status__c='Active', recordTypeId=cpdProgReqRecId);
        insert canReqAttest;
        
        CPE_Claim__c claim = new CPE_Claim__c(Credits_Earned__c=5,Approved__c=True,Candidate_Requirement__c=canReqCpe.Id);
        insert claim;
        
        Test.startTest();
        //GARP_MS_CPD.getCPDProgramInfo();
        GARP_BC_MemberPortal.getCPDListingInfo(contact.Id);
        
        GARP_BC_CPD.cpdClaim cpdClaim = new GARP_BC_CPD.cpdClaim(claim);
        cpdClaim.credits=5;
        cpdClaim.dateOfCompletion=Date.ValueOf('2023-01-01');
        cpdClaim.comments='Did stuff';
        //GARP_MS_CPD.setCPDProgramInfo(cpdClaim); 
        //GARP_BC_CPD.setCPDProgramInfo(contact.AccountId, cpdClaim); 
            
        Test.stopTest();
    }
}