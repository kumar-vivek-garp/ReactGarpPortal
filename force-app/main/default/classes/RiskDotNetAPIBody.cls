/**
* Class to edit the JSON structure based on the Opportunity ID and User active status
*/
public with sharing class RiskDotNetAPIBody {
    
    /**
* Body Method to Activate and deActivate User in Risk.net
**/
    public static String Body(Contract objContract,List<Id> contactIds,Map<Id,Contact> Contacts ) {
        string body;
        try{
            system.debug('Entered RiskDotNetAPIBody================>');
            
            // RiskDotNetAPI Data
            RiskDotNetAPI.JSONBody objUserRecord = new RiskDotNetAPI.JSONBody();
            objUserRecord.id = RiskDotNetUserCreation__c.getValues('id').Value__c;
            objUserRecord.name = RiskDotNetUserCreation__c.getValues('Name').Value__c;
            System.debug('objUserRecord============>'+objUserRecord);
            
            
            // Companies Data
            RiskDotNetAPI.Companies companiesData = new RiskDotNetAPI.Companies();
            companiesData.id = RiskDotNetUserCreation__c.getValues('CompaniesId').Value__c;
            system.debug('companiesData.id===========>'+companiesData.id);
            companiesData.name = RiskDotNetUserCreation__c.getValues('CompaniesName').Value__c;
            system.debug('companiesData.name===========>'+companiesData.name);
            objUserRecord.companies.add(companiesData);
            
            // Users Data
            RiskDotNetAPI.Users usersData = new RiskDotNetAPI.Users();
            usersData.id = RiskDotNetUserCreation__c.getValues('GARP').Value__c +Contacts.get(objContract.CustomerSignedId).GARP_Member_ID__c;
            system.debug('usersData.id===========>'+usersData.id);
            usersData.name_id = RiskDotNetUserCreation__c.getValues('GARP').Value__c+Contacts.get(objContract.CustomerSignedId).GARP_Member_ID__c;
            system.debug('usersData.name_id===========>'+usersData.name_id);
            usersData.email = Contacts.get(objContract.CustomerSignedId).email;
            String email_hash  = Contacts.get(objContract.CustomerSignedId).email; 
            Blob data= Blob.valueOf(email_hash);
            Blob hash = Crypto.generateDigest('MD5', data); 
            
            //Convert MD5 Hash data to String
            email_hash =EncodingUtil.convertToHex(hash);
            email_hash = email_hash .tolowercase();
            usersData.email_hash = email_hash;
            usersData.first_name = Contacts.get(objContract.CustomerSignedId).FirstName;
            usersData.surname = Contacts.get(objContract.CustomerSignedId).LastName;
            usersData.delivery_country = Contacts.get(objContract.CustomerSignedId).RPT_Clean_Country__c;
            companiesData.users.add(usersData);
            
            RiskDotNetAPI.Subscriptions subscriptionData = new RiskDotNetAPI.Subscriptions();
            subscriptionData.price = RiskDotNetUserCreation__c.getValues('SubscriptionPrice').Value__c;	
            subscriptionData.vat = RiskDotNetUserCreation__c.getValues('SubscriptionVat').Value__c;	
            subscriptionData.seats = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionSeats').Value__c);	
            subscriptionData.type = RiskDotNetUserCreation__c.getValues('SubscriptionType').Value__c;	
            subscriptionData.subscription_type = RiskDotNetUserCreation__c.getValues('subscription_type').Value__c;	
            subscriptionData.paid = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionPaid').Value__c);	
            subscriptionData.corp_offer = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionCorp_offer').Value__c);	
            subscriptionData.trial = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('subscriptionTrial').Value__c);	
            subscriptionData.id = RiskDotNetUserCreation__c.getValues('GARP').Value__c +objContract.id;
            subscriptionData.order_header = RiskDotNetUserCreation__c.getValues('GARP').Value__c +objContract.id;
            subscriptionData.start_date = string.valueOfGmt(objContract.StartDate).replace(' ','T');
            subscriptionData.end_date = string.valueOfGmt(objContract.EndDate).replace(' ','T');
            subscriptionData.order_date = string.valueOFGmt(system.today()).replace(' ','T');
            subscriptionData.payment_date = string.valueOFGmt(system.today()).replace(' ','T');
            subscriptionData.email_suppress = 0;
            
            // To activate/DeActivate User based on status in Risk.net
            if(objContract.Status == 'Activated'){
                subscriptionData.active = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionActive').Value__c);
                subscriptionData.suspended = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionInActive').Value__c);
                subscriptionData.canceled = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionInActive').Value__c);
            } else if(objContract.Status == 'Canceled' || objContract.Status == 'Expired') { 
                subscriptionData.active = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionInActive').Value__c);
                subscriptionData.suspended = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionActive').Value__c);
                subscriptionData.canceled = Integer.ValueOf(RiskDotNetUserCreation__c.getValues('SubscriptionActive').Value__c);
            } 
            
            RiskDotNetAPI.Product productData = new RiskDotNetAPI.Product();
            productData.name = RiskDotNetUserCreation__c.getValues('ProductName').Value__c;
            productData.id = RiskDotNetUserCreation__c.getValues('ProductId').Value__c;
            productData.BB8_id = RiskDotNetUserCreation__c.getValues('ProductBB8_id').Value__c;
            productData.family = RiskDotNetUserCreation__c.getValues('ProductFamily').Value__c;
            productData.type = RiskDotNetUserCreation__c.getValues('ProductType').Value__c;
            subscriptionData.product = productData;
            
            objUserRecord.Companies[0].users[0].subscriptions.add(subscriptionData);
            System.debug('objUserRecord============>'+objUserRecord);
            body = JSON.serialize(objUserRecord);
            system.debug('Before body==========>'+body);
            
            return body;
        }
        catch(Exception e){
            system.debug('e=======>'+e);
            return e.getMessage();
            
        }
    }
    
}