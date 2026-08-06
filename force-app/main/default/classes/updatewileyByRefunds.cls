public class updatewileyByRefunds
{
    public static boolean bRecursive = false;
    
    public static void updatewileyTerm(Set<id> setAccounts,integer quantity)
    {
    bRecursive = true;
        string memRecordType = RecordTypeHelper.GetRecordTypeId('Contract','Wiley Bookstore');
        
         List<Contract> lstContracts = new List<Contract>();
            for(Contract con : [select id,EndDate,ContractTerm,Technically_Zero__c from Contract where recordTypeId =: memRecordType and Status =: 'Activated'  and AccountId in: setAccounts])
            {
                integer iTerm =  con.ContractTerm - quantity;
                if(iTerm <= 0)
                {
                    iTerm = 1;
                    con.ContractTerm = iTerm;
                    con.Technically_Zero__c = true;
                    Date dtConEndDate = con.EndDate;
                    dtConEndDate = dtConEndDate.addMonths(-quantity);
                    Date dtToday = Date.today();
                    if(dtToday > dtConEndDate)
                        con.status = 'Expired';
                }
                else
                {
                    con.ContractTerm = iTerm;
                    Date dtConEndDate = con.EndDate;
                    dtConEndDate = dtConEndDate.addMonths(-quantity);
                    Date dtToday = Date.today();
                    if(dtToday < dtConEndDate)
                   
                    con.status = 'Activated';
                    
                    if(dtToday > dtConEndDate)
                        con.status = 'Expired';
                }
                lstContracts.add(con);
                
            }
             system.debug('lstContracts == '+lstContracts);
            if(!lstContracts.isEmpty())
                update lstContracts;    
        
    }
}