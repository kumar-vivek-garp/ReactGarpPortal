public class AccountingToolClass {
    
    @AuraEnabled
    Public Static List<OpportunityLineItem> getAllProducts(String InvoiceNumber){
        
        String retval ='';
        List<Opportunity> oppList = [Select Id,Display_Invoice_Number__c,AccountId From Opportunity 
                                     where Display_Invoice_Number__c =:InvoiceNumber LIMIT 1]; 
        
        if(!oppList.IsEmpty()){
            Opportunity opp = oppList[0];
            List<OpportunityLineItem> oliList = [SELECT Id,Product2.Id,Product2.ProductCode,Product2.Name,UnitPrice,Product_ID__c,Product2Id,
                                                 Quantity FROM OpportunityLineItem WHERE OpportunityId =: opp.Id AND UnitPrice > 0];
            if(!oliList.IsEmpty()){
                return oliList;
            }
        }
        return null;
    }
    
    @AuraEnabled
    Public Static String createNewOppAndOli(String InvoiceNumber,List<OpportunityLineItem> oliList,String ProductCodeSelected){
        String response = '' ;
        try{
            Opportunity oldOpp = [Select Id,StageName,AccountId,Billing_Email__c,CloseDate,
                                  Billing_First_Name__c,Billing_Last_Name__c,Name,
                                  Billing_Phone__c,Billing_Company__c,
                                  Billing_Address__c,Billing_City__c,
                                  Billing_State_Text__c,Billing_Zip_Postal__c,
                                  Billing_Country__c,Shipping_First_Name__c,Pricebook2Id,
                                  Shipping_Last_Name__c,Shipping_E_mail__c,Shipping_Company_Name__c,
                                  Shipping_Phone_No__c,Shipping_Street__c,Shipping_City__c,
                                  Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,RecordTypeId,
                                  Payment_Method_New__c,CardType__c from Opportunity 
                                  where Display_Invoice_Number__c =:InvoiceNumber LIMIT 1];
            
            List<ChargentOrders__Transaction__c> tranList = new List<ChargentOrders__Transaction__c>();
            tranList = [SELECT Id FROM ChargentOrders__Transaction__c 
                        WHERE Opportunity__c =: oldOpp.Id AND 
                        ChargentOrders__Response_Status__c = 'Approved' LIMIT 1];
            
            ChargentOrders__Transaction__c tran =  new ChargentOrders__Transaction__c();
            if(tranList.size() > 0){tran = tranList[0];}
            
            Product2 p2 = [SELECT Id, ProductCode FROM Product2 WHERE ProductCode=:ProductCodeSelected LIMIT 1];
            
            for(Opportunity existingOPP : [SELECT Id,Display_Invoice_Number__c FROM Opportunity WHERE Refund_Opportunity__c =: oldOpp.Id ]){
                //system.debug('existingOPP::>>   '+existingOPP);
                return 'Refund Opportunity Exists:- '+existingOPP.Display_Invoice_Number__c;
            }
            
            Opportunity newOpp  = oldOpp.clone(false, false, false, false);
            newopp.Name = 'E Book Discount Switch';
            newOpp.Refund_Opportunity__c = oldOpp.Id;
            newOpp.StageName = 'New Lead';
            newOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Refund';
            insert newOpp;
            //system.debug('createNewOppAndOli newOpp::>>   '+newOpp);
            
            List<OpportunityLineItem> oliListToInsert = new List<OpportunityLineItem>();
            List<Product_Refunds__c> productrefToInsert = new List<Product_Refunds__c>();
            if(oliList.size() > 0){
                for(OpportunityLineItem oli : oliList){
                    OpportunityLineItem newNegativeOli  = oli.clone(false, false, false, false);
                    newNegativeOli.UnitPrice = Double.valueOf(System.Label.AccountingToolDiscountPercentage)*(oli.UnitPrice) / 100;
                    newNegativeOli.OpportunityId = newOpp.Id;
                    newNegativeOli.Product2Id = p2.Id;
                    newNegativeOli.For_Sage_Sync_Only__c = true;
                    
                    Product_Refunds__c pr = new Product_Refunds__c(Opportunity__c = oldOpp.Id,Product__c = oli.Product2Id,
                                                                   Status__c='Approved',Refund_amount__c = newNegativeOli.UnitPrice,
                                                                   Reason__c='Switch');
                    if(tran != null){pr.Payment_Order_Transaction__c=tran.Id;}
                    
                    oliListToInsert.add(newNegativeOli);
                    productrefToInsert.add(pr);
                }
            }
            //system.debug(oliListToInsert.size()+'      <<::createNewOppAndOli oliListToInsert::>>   '+oliListToInsert);
            if(oliListToInsert.size() > 0){
                insert oliListToInsert;
            }
            
            if(productrefToInsert.size() > 0){
                insert productrefToInsert;
            }
            response = 'Success';
        }catch(Exception ex){
            System.debug('The following exception has occurred::>>   ' + ex.getMessage());
            response = ex.getMessage();
        }
        return response;
    }
}