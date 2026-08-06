public class MembershipSwitchController {
    
    @AuraEnabled
    Public Static String OnclickMembershipSwitch(String InvoiceNumber){
        system.debug('InvoiceNumber::>>   '+InvoiceNumber);
        
        String retval ='Success';
        List<Opportunity> oppList = [Select Id,Display_Invoice_Number__c,AccountId From Opportunity where Display_Invoice_Number__c =:InvoiceNumber LIMIT 1];
        List<String> codeList = new List<String>{'MEMI','MEMC'};
            
            system.debug('oppList::>>   '+oppList); 
        if(!oppList.IsEmpty()){
            Opportunity opp = oppList[0];
                  
            for(Opportunity existingOPP : [SELECT Id,Display_Invoice_Number__c FROM Opportunity WHERE Refund_Opportunity__c =: Opp.Id ]){
                system.debug('existingOPP::>>   '+existingOPP);
                return 'Refund Opportunity Exists:- '+existingOPP.Display_Invoice_Number__c;
            }
            
            List<OpportunityLineItem> oliList = [SELECT Id,Product2.Id,Product2.ProductCode,UnitPrice FROM OpportunityLineItem 
                                                 WHERE OpportunityId =: opp.Id AND Product2.ProductCode IN: codeList];
            system.debug(oliList.size()+'  <<:: OnclickMembershipSwitch oliList::>>   '+oliList);
            if(!oliList.IsEmpty()){
                createProductRefund(opp.Id,oliList[0].Product2.Id,oliList[0].UnitPrice);
                createNewOpportunity(opp.Id);
            }
        }else{
            retval = 'Invalid Invoice Number';
        }
        return retval;
    }
    
    @future
    Public Static void createNewOpportunity(String OppId){
        
              
        
        Opportunity oldOpp = [Select Id,StageName,AccountId,Billing_Email__c,CloseDate,
                              Billing_First_Name__c,Billing_Last_Name__c,Name,
                              Billing_Phone__c,Billing_Company__c,
                              Billing_Address__c,Billing_City__c,
                              Billing_State_Text__c,Billing_Zip_Postal__c,
                              Billing_Country__c,Shipping_First_Name__c,Pricebook2Id,
                              Shipping_Last_Name__c,Shipping_E_mail__c,Shipping_Company_Name__c,
                              Shipping_Phone_No__c,Shipping_Street__c,Shipping_City__c,
                              Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,RecordTypeId,
                              Payment_Method_New__c,CardType__c from Opportunity WHERE Id =: OppId LIMIT 1];
        Opportunity newOpp  = oldOpp.clone(false, false, false, false);
        newopp.Name = 'Membership Switch';
        newOpp.Refund_Opportunity__c = oldOpp.Id;
        newOpp.StageName = 'New Lead';
        newOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Switch';
        insert newOpp;
        system.debug(OppId+'  <<:: createNewOpportunity ::>>   '+newOpp);
        
        List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
        List<String> codeList = new List<String>{'MEMI','MEMC'};
            List<OpportunityLineItem> oliList = [SELECT Id,Product2Id,UnitPrice,Product2.ProductCode,Quantity FROM OpportunityLineItem
                                                 WHERE OpportunityId =: oldOpp.Id AND Product2.ProductCode IN: codeList LIMIT 1];
        system.debug(oliList.size()+'  <<:: createNewOpportunity oliList::>>   '+oliList);
        if(oliList.size() > 0){
            OpportunityLineItem newNegativeOli  = oliList[0].clone(false, false, false, false);
            newNegativeOli.UnitPrice = oliList[0].UnitPrice*(-1);
            newNegativeOli.OpportunityId = newOpp.Id;
            newNegativeOli.For_Sage_Sync_Only__c = true;
            oliListToInsert.add(newNegativeOli);
            
            String productCode = oliList[0].Product2.ProductCode == 'MEMI' ? 'MEMC' : 'MEMI';
            Product2 prod = [SELECT Id,ProductCode FROM Product2 WHERE ProductCode =:productCode LIMIT 1];
            system.debug('createNewOpportunity prod::>>   '+prod);
            
            OpportunityLineItem newPositiveOli  = oliList[0].clone(false, false, false, false);
            newPositiveOli.UnitPrice = productCode == 'MEMI' ? 195 : 150;
            newPositiveOli.OpportunityId = newOpp.Id;
            newPositiveOli.Product2Id = prod.Id;
            newPositiveOli.For_Sage_Sync_Only__c = true;
            oliListToInsert.add(newPositiveOli);
        }
        
        system.debug(oliListToInsert.size()+'  <<:: createNewOpportunity oliListToInsert::>>   '+oliListToInsert);
        if(oliListToInsert.size() > 0){
            insert oliListToInsert;
        }
    }
    
    
    @future
    Public Static void createProductRefund(String OppId,String prodId,Decimal unitPrice){
        system.debug('in updateProductRefund::>>   '+OppId);
        ChargentOrders__Transaction__c tran = [SELECT Id FROM ChargentOrders__Transaction__c 
                                            WHERE Opportunity__c =: OppId AND ChargentOrders__Response_Status__c = 'Approved' LIMIT 1];
        Product_Refunds__c pr = new Product_Refunds__c(Opportunity__c = OppId,Product__c = prodId,Status__c='Approved',Refund_amount__c=unitPrice,
                                                       Reason__c='Switch',Payment_Order_Transaction__c=tran.Id);
        system.debug('in updateProductRefund  pr 11 ::>>   '+pr);
        insert pr;
    }
}