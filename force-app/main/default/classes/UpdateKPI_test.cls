@isTest
public class UpdateKPI_test {
    static Contact contact;
    static Account acc ;
    static Contract cont;
    
    static void testData(){
        Acc = new Account(Name = 'test');
        insert acc;
        
        contact = new Contact(KPI_Last_Updated_Date__c = system.today() - 2,lastname = 'Test', AccountId = acc.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
        
        cont = new Contract(AccountID = acc.ID, Days_Left__c = 20, Membership_Type__c = 'Individual', RecordTypeId = recordTypeID);
        insert cont;
        
        cont.Status = 'Activated';
        update cont;
        
    }
    
    static testMethod void unitTest_1(){
        testData();
        UpdateKPI kpi = new UpdateKPI(NULL);
        database.executeBatch(kpi);
        
    }
    
    static testMethod void unitTest_2(){
        testData();
        UpdateKPI kpi = new UpdateKPI('clear');
        database.executeBatch(kpi);
        
    }

    static testMethod void unitTest_3(){
        testData();
        UpdateKPI kpi = new UpdateKPI('memberprogram');
        database.executeBatch(kpi);
        
    }

    static testMethod void unitTest_4(){
        testData();
        UpdateKPI kpi = new UpdateKPI('memberprogram~' + contact.Id);
        database.executeBatch(kpi);
        
    }

    static testMethod void unitTest_5(){
        testData();
        UpdateKPI kpi = new UpdateKPI('memberprogramcountdown');
        database.executeBatch(kpi);

        UpdateKPI kpi1 = new UpdateKPI('precycle');
        database.executeBatch(kpi1);

        UpdateKPI kpi2 = new UpdateKPI('fixexamattempt');
        database.executeBatch(kpi2);

        
    
        
    }
    
}