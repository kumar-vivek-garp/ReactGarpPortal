public with sharing class AccountingLWCToolController {

	@AuraEnabled
    public static string createDeferralRefund(string invoiceNumber){
        string result = 'Success';
        try {
            List<OpportunityLineItem> lineItemsToInsert = new List<OpportunityLineItem>();
            List<Opportunity> oppsList = [Select Id,StageName,AccountId,Billing_Email__c,Payment_Method_New__c,
                                          Billing_First_Name__c,Billing_Last_Name__c,
                                          Billing_Phone__c,Billing_Company__c,Gateway__c,Gateway__r.Name,
                                          Billing_Address__c,Billing_City__c,
                                          Billing_State_text__c,Billing_Zip_Postal__c,
                                          Billing_Country__c,Shipping_First_Name__c,ia_crm__Intacct_Transaction__c,
                                          Shipping_Last_Name__c,Shipping_E_mail__c,Shipping_Company_Name__c,
                                          Shipping_Phone_No__c,Shipping_Street__c,Shipping_City__c,
                                          Shipping_State__c,Shipping_Postal_Code__c,Shipping_Country__c,
                                          RecordTypeId,priceBook2Id,CardType__c,Display_Invoice_Number__c,
                                          (Select Id,UnitPrice,PricebookEntryId,OpportunityId,Product_Id__c,Product2Id,Quantity,TotalPrice,ProductCode,
                                           ia_crm__Class__c,ia_crm__Department__c,ia_crm__Intacct_Location__c,Sage_Reporting_Country__c,Site_Code__c,
                                           Intacct_Template__c,Warehouse__c,Sage_Reporting_State__c,Sage_Shipping_Country__c,Sage_Shipping_State__c,
                                           Vendor_Id__c,Vendor_Name__c,ServiceDate,ia_crm__Project__c,Reference_Id__c from OpportunityLineItems)
                                          from Opportunity where Display_Invoice_Number__c =: invoiceNumber];
            
            if(!oppsList.isEmpty()){
                Opportunity opp = oppsList[0];
                List<Opportunity> refundOpps = [Select Id,Refund_Opportunity__c,Display_Invoice_Number__c from Opportunity 
                                         where Refund_Opportunity__c =: opp.Id and ia_crm__Intacct_Transaction__c = 'Salesforce - Internal Refund'];
                
                if(!refundOpps.isEmpty()){
                    result = 'Internal Refund already exists for this Invoice: '+refundOpps[0].Display_Invoice_Number__c;
                    return result;
                }
                Opportunity objOpp = new Opportunity();
                objOpp.AccountId = opp.AccountId;
                objOpp.Billing_Email__c = opp.Billing_Email__c;
                objOpp.Billing_First_Name__c = opp.Billing_First_Name__c;
                objOpp.Billing_Last_Name__c = opp.Billing_Last_Name__c;
                objOpp.Billing_Phone__c = opp.Billing_Phone__c;
                objOpp.Billing_Company__c = opp.Billing_Company__c;
                objOpp.Billing_Address__c = opp.Billing_Address__c;
                objOpp.Billing_City__c = opp.Billing_City__c;
                objOpp.Billing_State_Text__c = opp.Billing_State_Text__c;
                objOpp.Billing_Zip_Postal__c = opp.Billing_Zip_Postal__c;
                objOpp.Billing_Country__c = opp.Billing_Country__c;
                objOpp.Shipping_First_Name__c = opp.Shipping_First_Name__c;
                objOpp.Shipping_Last_Name__c = opp.Shipping_Last_Name__c;
                objOpp.Shipping_E_mail__c = opp.Shipping_E_mail__c;
                objOpp.Shipping_Company_Name__c = opp.Shipping_Company_Name__c;
                objOpp.Shipping_Phone_No__c = opp.Shipping_Phone_No__c;
                objOpp.Shipping_Street__c = opp.Shipping_Street__c;
                objOpp.Shipping_City__c = opp.Shipping_City__c;
                objOpp.Shipping_State__c = opp.Shipping_State__c;
                objOpp.Shipping_Postal_Code__c = opp.Shipping_Postal_Code__c;
                objOpp.Shipping_Country__c = opp.Shipping_Country__c;
                objOpp.StageName = 'New Lead';
                objOpp.CloseDate = system.today();
                objOpp.Name = 'Refund Invoice';
                objOpp.Refund_Opportunity__c = opp.Id;
                objOpp.RecordTypeId = opp.RecordTypeId;
                objOpp.priceBook2Id = opp.priceBook2Id;
                objOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Internal Refund';
                objOpp.Payment_Method_New__c = 'Internal Refund';
                objOpp.Display_Invoice_Number__c = opp.Display_Invoice_Number__c+'CN';
                objOpp.Gateway__c = opp.Gateway__c;
                objOpp.Gateway_Time__c = system.now();
                
                insert objOpp;
                
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    OpportunityLineItem newOli = new OpportunityLineItem();
                    newOli.OpportunityId = objOpp.Id;
                    newOli.Quantity = oli.Quantity;
                    String pdcode = oli.Productcode;
                    if(pdcode == 'FRM1' || pdcode == 'SCR' || pdcode == 'RAI' || pdcode == 'RAIJ'){//Chinnapa
                        newOli.UnitPrice = oli.UnitPrice;
                    }else{
                    	newOli.UnitPrice = -1 * oli.UnitPrice;
                    }
                    newOli.Product_ID__c = oli.Product_ID__c;
                    newOli.PricebookEntryId = oli.PricebookEntryId;
                    newoli.Product2Id = oli.Product2Id;
                    newOli.For_Sage_Sync_Only__c = true;
                    newOli.ia_crm__Class__c = oli.ia_crm__Class__c;
                    newOli.ia_crm__Department__c = oli.ia_crm__Department__c;
                    newOli.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
                    newOli.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
                    newOli.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
                    newOli.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
                    newOli.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
                    newOli.Vendor_Name__c = oli.Vendor_Name__c;
                    newOli.Vendor_Id__c = oli.Vendor_Id__c;
                    newOli.Warehouse__c = oli.Warehouse__c;
                    newOli.Site_Code__c = oli.Site_Code__c;
                    newOli.Intacct_Template__c = oli.Intacct_Template__c;
                    newOli.ia_crm__Project__c = oli.ia_crm__Project__c;
                    newOli.Reference_Id__c = oli.Reference_Id__c;
                    if(oli.ServiceDate > system.today()){
                        newOli.ServiceDate = oli.ServiceDate;
                    }else{
                        newOli.ServiceDate = system.today();
                    }
                    lineItemsToInsert.add(newoli);
                }
                
                if(!lineItemsToInsert.isEmpty()){
                    insert lineItemsToInsert;
                }
                
                ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: objOpp.Id Limit 1];
                
                ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                trans.Opportunity__c = objOpp.Id;
                trans.ChargentOrders__Order__c = order.Id;
                trans.ChargentOrders__Amount__c = 0.00;
                trans.ChargentOrders__Response_Message__c = 'Approved';
                trans.ChargentOrders__Response_Status__c = 'Approved';
                trans.ChargentOrders__Type__c = 'Charge';
                trans.ChargentOrders__Payment_Method__c ='Internal Refund';
                trans.ChargentOrders__Gateway_Date__c =system.now();
                insert trans;
            }else{
                result = 'Opportunity not found';
            }
        } catch (Exception e) {
            result = e.getMessage();
        }
        
        return result;
    }
}