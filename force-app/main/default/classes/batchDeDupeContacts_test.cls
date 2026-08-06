@isTest
public class batchDeDupeContacts_test {

    static Account acc ;
    
    static void testData(){ 
        

    }
    
    static testMethod void unitTest_1(){   
        
        testdata();

		Account Acc1 = new Account(Name = 'individual', recordtypeid = '01240000000UdNx');
        insert acc1;

		Account Acc2 = new Account(Name = 'business', recordtypeid = '01240000000UdNv');
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Member', LastName='Frank', Email='a@a.com', accountid = acc1.id, recordtypeid = '01240000000UdO3');
        insert c1;

        Contact c2 = new Contact(FirstName='Business', LastName='Frank', Email='a@a.com', accountid = acc2.id, recordtypeid = '01240000000UdO2');
        insert c2;
        
        test.startTest();
        batchDeDupeContacts b = new batchDeDupeContacts('a@a.com','Account');
        database.executeBatch(b);
        
        batchDeDupeContacts b1 = new batchDeDupeContacts('a@a.com','Contact');
        database.executeBatch(b1);
        
        scheduleBatchDeDupeContacts s1= new scheduleBatchDeDupeContacts();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        
        test.stopTest();
        
    }
    
    static testMethod void unitTest_2(){   
        
        testdata();

		Account Acc1 = new Account(Name = 'individual', recordtypeid = '01240000000UdNx');
        insert acc1;

		Account Acc2 = new Account(Name = 'individual2', recordtypeid = '01240000000UdNx');
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Member', LastName='Frank', Email='b@b.com', accountid = acc1.id, recordtypeid = '01240000000UdO3');
        insert c1;

        Contact c2 = new Contact(FirstName='Business', LastName='Frank', Email='b@b.com', accountid = acc2.id, recordtypeid = '01240000000UdO2');
        insert c2;
        
        test.startTest();
        batchDeDupeContacts b = new batchDeDupeContacts('b@b.com','Account');
        database.executeBatch(b);
        batchDeDupeContacts b1 = new batchDeDupeContacts('b@b.com','Contact');
        database.executeBatch(b1);
        
        //scheduleBatchDeDupeLeads s1= new scheduleBatchDeDupeLeads();
        //system.schedule('Test Schedule','0 0 0 * * ?',s1);
        
        test.stopTest();
        
    }

    static testMethod void unitTest_3(){   
        
        testdata();

		Account Acc1 = new Account(Name = 'individual', recordtypeid = '01240000000UdNx');
        insert acc1;

		Account Acc2 = new Account(Name = 'business', recordtypeid = '01240000000UdNv');
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Member', LastName='Frank', Email='b@b.com', accountid = acc1.id, recordtypeid = '01240000000UdO3');
        insert c1;

        Contact c2 = new Contact(FirstName='Business', LastName='Frank', Email='b@b.com', accountid = acc2.id, recordtypeid = '01240000000UdO2');
        insert c2;


        test.startTest();
        batchDeDupeContacts b = new batchDeDupeContacts('b@b.com','Account');
        database.executeBatch(b);
        
		batchDeDupeContacts b1 = new batchDeDupeContacts('b@b.com','Contact');
        database.executeBatch(b1);
        
        scheduleBatchDeDupeContacts s1= new scheduleBatchDeDupeContacts();
        system.schedule('Test Schedule','0 0 0 * * ?',s1);
        
        test.stopTest();
        
    }
    
    static testMethod void unitTest_4(){   
        
        testdata();

		Account Acc1 = new Account(Name = 'individual', recordtypeid = '01240000000UdNx');
        insert acc1;

		Account Acc2 = new Account(Name = 'individual2', recordtypeid = '01240000000UdNx');
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Member', LastName='Frank', Email='b@b.com', accountid = acc1.id, recordtypeid = '01240000000UdO3');
        insert c1;

        Contact c2 = new Contact(FirstName='Business', LastName='Frank', Email='b@b.com', accountid = acc2.id, recordtypeid = '01240000000UdO2');
        insert c2;

        // FRM - 01240000000UdOH
        Contract p1 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), RecordTypeId='01240000000UdOH');
        insert p1;
        p1.status = 'Activated';
        update p1;
        
        // FRM - 01240000000UdOH
        Contract p2 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), RecordTypeId='01240000000UdOH');
        insert p2;
        p2.status = 'Activated';
		update p2;

        // Membership - 01240000000UdOJ
        Contract p3 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), Membership_Type__c = 'Individual', RecordTypeId='01240000000UdOJ');
        insert p3;
        p3.status = 'Activated';
        update p3;
        
        // Membership - 01240000000UdOJ
        Contract p4 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), Membership_Type__c = 'Affiliate', RecordTypeId='01240000000UdOJ');
        insert p4;
        p4.status = 'Activated';
        update p4;
        
        // OSTA - 0121W000000gzvV
        Contract p5 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), RecordTypeId='0121W000000gzvV');
        insert p5;
        p5.status = 'Activated';
        update p5;
        
        // OSTA - 0121W000000gzvV
        Contract p6 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), RecordTypeId='0121W000000gzvV');
        insert p6;
        p6.status = 'Activated';
		update p6;
        
        test.startTest();
        batchDeDupeContacts b = new batchDeDupeContacts('b@b.com','Account');
        database.executeBatch(b);

        //batchDeDupeContacts b1 = new batchDeDupeContacts('b@b.com','Contact');
        //database.executeBatch(b1);        
        //scheduleBatchDeDupeLeads s1= new scheduleBatchDeDupeLeads();
        //system.schedule('Test Schedule','0 0 0 * * ?',s1);
        
        test.stopTest();
        
    }
    
    static testMethod void unitTest_5(){   
        
        testdata();

		Account Acc1 = new Account(Name = 'individual', recordtypeid = '01240000000UdNx');
        insert acc1;

		Account Acc2 = new Account(Name = 'individual2', recordtypeid = '01240000000UdNx');
        insert acc2;
        
        Contact c1 = new Contact(FirstName='Member', LastName='Frank', Email='b@b.com', accountid = acc1.id, recordtypeid = '01240000000UdO3');
        insert c1;

        Contact c2 = new Contact(FirstName='Business', LastName='Frank', Email='b@b.com', accountid = acc2.id, recordtypeid = '01240000000UdO2');
        insert c2;

        // FRM - 01240000000UdOH
        Contract p1 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), RecordTypeId='01240000000UdOH');
        insert p1;
        p1.status = 'Completed';
        update p1;
        
        // FRM - 01240000000UdOH
        Contract p2 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), RecordTypeId='01240000000UdOH');
        insert p2;
        p2.status = 'Activated';
		update p2;

        // Membership - 01240000000UdOJ
        Contract p3 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), Membership_Type__c = 'Individual', RecordTypeId='01240000000UdOJ');
        insert p3;
        p3.status = 'Activated';
        update p3;
        
        // Membership - 01240000000UdOJ
        Contract p4 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), Membership_Type__c = 'Individual', RecordTypeId='01240000000UdOJ');
        insert p4;
        p4.status = 'Activated';
        update p4;
        
        // OSTA - 0121W000000gzvV
        Contract p5 = new Contract(AccountId = acc1.Id, status='draft', StartDate=Date.today().addDays(-2), RecordTypeId='0121W000000gzvV');
        insert p5;
        p5.status = 'Activated';
        update p5;
        
        // OSTA - 0121W000000gzvV
        Contract p6 = new Contract(AccountId = acc2.Id, status='draft', StartDate=Date.today().addDays(-1), RecordTypeId='0121W000000gzvV');
        insert p6;
        p6.status = 'Activated';
		update p6;
        
        test.startTest();
        batchDeDupeContacts b = new batchDeDupeContacts('b@b.com','Account');
        database.executeBatch(b);

        batchDeDupeContacts b1 = new batchDeDupeContacts('b@b.com','Contact');
        database.executeBatch(b1);        
        //scheduleBatchDeDupeLeads s1= new scheduleBatchDeDupeLeads();
        //system.schedule('Test Schedule','0 0 0 * * ?',s1);
        
        test.stopTest();
        
    }

    
}