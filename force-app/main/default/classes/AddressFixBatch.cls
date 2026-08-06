Global class AddressFixBatch implements Database.Batchable<SObject>{
    
    Public String mode; 
    
    global AddressFixBatch(String modeIn) {
        //System.debug('modeIn:' + modeIn);
        this.mode= modeIn;     
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'Select id, MailingStreet, AccountId, Account.BillingStreet, Account.ShippingStreet from Contact';
        if (mode!=NULL){
            query = 'Select id, MailingStreet, AccountId, Account.BillingStreet, Account.ShippingStreet from Contact where id =:mode';    
        }
        //System.debug('query:' + query);
        return Database.getQueryLocator(query);        
    }
    
    Global String formatAddress(String addressIn){
        
        if(addressIn != NULL && addressIn.length() > 0){
            String[] arrText = addressIn.split('\n|\r\n');
            //System.debug('arrText:' + arrText.Size());
            
            if(arrText.size() > 2){
                //System.debug('arrText[1]:' + arrText[1]);
                //System.debug('arrText[2]:' + arrText[2]);
                if(arrText[1] == arrText[2]){
                    addressIn = arrText[0]+'\n'+arrText[1];
                    //System.debug('addressIn:' + addressIn);
                    return addressIn;
                }
            }
        }
        return NULL;  
    }
    
    global void execute(Database.BatchableContext bc, List<contact> scope){
        List<Contact> updateContacts = new List<Contact>();
        Set<Id> accountIdsToUpdate = new Set<Id>();
        for(Contact con : Scope){
            String retAddress = formatAddress(con.MailingStreet);
            //System.debug('retAddress:' + retAddress);
            if(retAddress != NULL){
                con.MailingStreet = retAddress;
                updateContacts.add(con);
                accountIdsToUpdate.add(con.AccountId);              
            }
        }
        if(!updateContacts.isEmpty()){
            //System.debug('updateContacts:' + updateContacts);
            update updateContacts;
        }
        Map<Id, Account> accountsMap = new Map<Id, Account>([Select id,BillingStreet, ShippingStreet from account where Id IN :accountIdsToUpdate]);
        List<Account> updateAccounts = new List<Account>();
        for(Id accountId: accountIdsToUpdate){
            if(accountsMap.containsKey(accountId)){
                Account acc = accountsMap.get(accountId);
                //System.debug('accountId:' + accountId);
                String retBillAddress = formatAddress(acc.BillingStreet);
                String retShipAddress = formatAddress(acc.ShippingStreet);
                if(retBillAddress != NULL || retShipAddress != NULL){
                    acc.BillingStreet  = retBillAddress;
                    acc.ShippingStreet = retShipAddress;
                    updateAccounts.add(acc);
                }
            }
        }
        if(!updateAccounts.isEmpty()){
            //System.debug('updateAccounts:' + updateAccounts);
            update updateAccounts;
        }
    }
    
    global void finish(Database.BatchableContext bc){        
    }
}