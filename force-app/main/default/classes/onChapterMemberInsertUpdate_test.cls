@isTest
public class onChapterMemberInsertUpdate_test {

    static testMethod void unitTest_1(){
        test.startTest();
        Account acc = new Account(name = 'GARP');
        insert acc;
        
        CPE_Activity_Type__c CAT = new CPE_Activity_Type__c(name ='Professional Association Meetings');
        insert CAT;
        
        Opportunity opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opp;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = ContractRecordTypeInfo.get('FRM Program').getRecordTypeId();
        Contract Contract  = new Contract(Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate        );
        insert contract;
        contract.Status = 'Activated';
        update contract;
        
        
        Id recType4CPEReq = RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c', 'CPE');
        Candidate_Requirement__c  reqt = new Candidate_Requirement__c (Candidate_Commitment__c  = contract.id,recordtypeid= recType4CPEReq);
        insert reqt;
        
        
        CPE_Claim__c claim = new CPE_Claim__c();
        claim.Candidate_Requirement__c  = reqt.id ;
        claim.Credits_Earned__c   = 123;
        insert claim;
        
        
        Contact contact = new Contact(lastname = 'Test',AccountId = acc.id,CPE_Current_Program_Requirement__c=reqt.id,KPI_FRM_Certified__c=true,email='test@testgarp1232323.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        Chapter_Member__c member = new Chapter_Member__c(Director__c = true,IsPrimary__c = true,Contact__c = contact.id);
        insert member;
        
        Chapter_Meeting__c cm = new Chapter_Meeting__c(Name ='test');
        insert cm;
        
        Chapter_Meeting_Registration__c cmr = new Chapter_Meeting_Registration__c(Contact__c =contact.id, Chapter_Meeting__c =cm.id,Attended__c = false);
        insert cmr;
        cmr.Attended__c = true;
        update cmr;
        
        
        
        
        test.stopTest();
        
        
    }
}