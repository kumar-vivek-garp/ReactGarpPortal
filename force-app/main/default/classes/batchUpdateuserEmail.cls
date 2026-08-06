global class batchUpdateuserEmail implements Database.Batchable<sObject>,Database.StateFul{
   //member email for all the programs should be updates
   global string icbrrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ICBRR Program');
    global string frmRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
    global string fbrRecordType = RecordTypeHelper.GetRecordTypeId('Contract','FBR Program');
    global string erpRecordType = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program'); 
        Set<String> recordtype = new Set<String>{'icbrrRecordType','frmRecordType','fbrRecordType','erpRecordType'};

   global Database.QueryLocator start(Database.BatchableContext BC){  
        String conId = '00329000003k2Wk';
        String fieldType = 'Email';
        date dtToday = System.today();
        if(!test.isRunningTest())
       return Database.getQueryLocator('Select id,field,ContactId,Contact.AccountID,Contact.email from contactHistory where  Field =: fieldType and CreatedDate= TODAY');
       else
        return Database.getQueryLocator('Select id,field,ContactId,Contact.AccountID,Contact.email from contactHistory where  Field =: fieldType');
   }

   global void execute(Database.BatchableContext BC, List<contactHistory> scope){
        Set<Id> setAccts = new Set<Id>();
         Map<Id,String> mapcontactEmail = new Map<Id,String>();
        Map<Id,String> mapAccountEmail = new Map<Id,String>();
        Set<Id> setContacts = new Set<Id>();
        for(contactHistory obj : scope)
        {
            setAccts.add(obj.Contact.accountId);
            mapAccountEmail.put(obj.Contact.AccountID,obj.Contact.email);
            mapcontactEmail.put(obj.Contactid,obj.Contact.email);
            setContacts.add(obj.ContactId);
        }

         List<user> lstuser = new List<user>();
        for(user u : [select id,Email,Username, Contactid from user where contactid in : mapcontactEmail.keyset()])
        {
            u.Email = mapcontactEmail.get(u.contactid);
            u.Username =mapcontactEmail.get(u.contactid);
            lstuser.add(u);
           
        }
        
        if(!lstuser.isEmpty() && !test.isRunningTest())
            update lstuser;
    }

     global void finish(Database.BatchableContext BC){
   
   }
}