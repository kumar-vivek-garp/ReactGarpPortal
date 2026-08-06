@isTest
public class sendAttachments_test {
    
    static Team_Registration__c Reg ;
    static Contact con;
    
    @testsetup 
    static void testData(){
        con = new Contact(
            FirstName = 'FirstName',
            LastName = 'LastName',
            Email='email@email.com',
            phone='12345678');
        insert con;
        
        Account acct = new Account(Name='TEST_ACCT');
        insert acct;
        
        Reg = new Team_Registration__c(BD_Rep_Email__c='test123@gmail.com',Name='test team reg',Contact__c=con.Id,Exam_Type__c = 'FRM I',
                                       Start_Date__c = system.today() ,End_Date__c=system.today(),Seats_Allowed__c =1,
                                       Manual_Invoice_Number__c='INV-000115',Include_Exam_or_Courses__c = true);
        insert reg;
        //Attachment att = new Attachment(Name='INV-000115.pdf',parentId=reg.id,body=blob.valueOf('test'));
        
        //insert att;
    }
    static testMethod void testMethod1 (){
        Test.startTest();
        List<Team_Registration__c> Treg = [SELECT Id FROM Team_Registration__c WHERE Name = 'test team reg'];
        List<Id> trID = new List<Id>();
        trID.add(Treg[0].Id);
        sendAttachments.sendEmailWithAttachements(trID);
        Test.stopTest();
        
    }
    
    /*static testMethod void testMethod2 (){
        Test.startTest();
        List<Team_Registration__c> Treg = [SELECT Id FROM Team_Registration__c WHERE Name = 'test team reg'];
        String trID = String.valueOf(Treg[0].Id);
        sendAttachments.sendInvoiceEmailButton(trID);
        Test.stopTest();
       */ 
    }
    
//}