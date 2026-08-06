@isTest

public class UpdateContracts_test{

    static Account acc;
    static Opportunity opp;
    static Contract contract;
    static Candidate_Requirement__c reqt;
    
    static void testData(){
        
        
        ChargentBase__Gateway__c chrgGtway = new ChargentBase__Gateway__c(Name = 'Test',ChargentBase__Active__c = true );
        insert chrgGtway;
        
        insert new UpdateIds__c(Name = 'GARP', Record_Id__c = chrgGtway.id);
        
        Acc = new Account(Name = 'test');
        insert acc;
         
        opp = new Opportunity(amount = 123,Name = 'Test',Eligible_for_Membership_Extension__c = false,company__c = 'Payment', accountId = acc.id,stageName = 'New Lead',Program__c = 'Print' ,closedate = system.today()- 100);        
        insert opp;
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contract; 
        Map<String,Schema.RecordTypeInfo> ContractRecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        Id rtId = ContractRecordTypeInfo .get('FRM Program').getRecordTypeId();

        string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        string icbrrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
        string frmRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
        string fbrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FBR Program');
        string erpRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
        string cpeRecordType = RecordTypeHelper.GetRecordTypeId('Contract','CPE');
        
        
        Contract Contract6  = new Contract(recordtypeId = erpRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract6;
        contract6.Status = 'Draft';
        update contract6;
        
               
       
        Contract Contract4  = new Contract(recordtypeId = frmRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract4;
        contract4.Status = 'Draft';
        update contract4;
        
        Contract Contractf4  = new Contract(recordtypeId = frmRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contractf4;
        contractf4.Status = 'Activated ( Auto-Renew )';
        update contractf4;
             
        Contract Contract5  = new Contract(recordtypeId = fbrRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract5;
        contract5.Status = 'Draft';
        update contract5;
        
        Contract Contract3  = new Contract(recordtypeId = icbrrRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate);
        insert contract3;
        contract3.Status = 'Draft';
        update contract3;
        
        Contract Contract2  = new Contract(recordtypeId = memRecordType ,Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12,StartDate = opp.CloseDate,Membership_Type__c = 'Student');
        insert contract2;
        contract2.Status = 'Activated ( Auto-Renew )';
        update contract2;
        
        Contract  = new Contract(Opportunity__c = opp.id, AccountId = opp.AccountId ,ContractTerm = 12   ,recordtypeID =cpeRecordType  ,StartDate = opp.CloseDate);
        insert contract;

        contract.Status = 'Draft';
        update contract;
        
       
        
        
        reqt = new Candidate_Requirement__c();
        reqt.Candidate_Commitment__c = contract4.id;
        reqt.name = 'FRM1 test';
        insert reqt;
        
       
        
       
        
        
        
    }
    
    static testMethod void unitTest_1(){
    
        testData();
        test.startTest();
        updateContracts contracts = new updateContracts();
        Database.executebatch(contracts,10);
        test.stopTest();
    }


}