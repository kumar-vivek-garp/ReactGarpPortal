@isTest
public class updateDeferred_test {

    @isTest
    public static void test(){
        
        Account a = new Account();
        a.Name = 'TEST';
        INSERT a;
        
        Opportunity o = new Opportunity();
        o.Name = 'TEST';
        o.AccountId = a.Id;
        o.Amount = 5000;
        o.StageName = 'Closed';
        o.CloseDate = Date.today();
        INSERT o;
        
        o.Amount = 1000;
        UPDATE o;
        
    }
    
}