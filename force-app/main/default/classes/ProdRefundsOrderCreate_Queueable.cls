public class ProdRefundsOrderCreate_Queueable implements Queueable{
    public Set<Id> prodRefundIds ;
    
    public ProdRefundsOrderCreate_Queueable(Set<Id> refundIds){
        this.prodRefundIds = refundIds ;
    }
    
    public void execute(QueueableContext context) {
        Set<Id> oppIds = new Set<Id>();
        Set<Id> transactionIds = new Set<Id>();
        Set<Id> orderIds = new Set<Id>();
        List<ChargentOrders__ChargentOrder__c> ordersToInsert = new List<ChargentOrders__ChargentOrder__c>();
        List<ChargentOrders__Transaction__c> transactionsToInsert = new List<ChargentOrders__Transaction__c>();
        Map<Id,ChargentOrders__ChargentOrder__c> oppToOrderMap = new Map<Id,ChargentOrders__ChargentOrder__c>();
        Map<String,Id> tokenToTranIdMap = new Map<String,Id>();
        List<Product_Refunds__c> refundsToUpdate = new List<Product_Refunds__c>();
        
        List<Product_Refunds__c> refunds = [Select Id,Opportunity__c,Legacy_Transaction__c,Payment_Order_Transaction__c,
                                            Legacy_Transaction__r.Tokenization__c,Legacy_Transaction__r.Opportunity__c
                                            from Product_Refunds__c where Id IN: prodRefundIds];
        
        for(Product_Refunds__c refund : refunds){
            oppIds.add(refund.Opportunity__c);
            transactionIds.add(refund.Legacy_Transaction__c);
        }
        
        List<Opportunity> oppList = [Select Id,Gateway__c,Payment_Method_New__c, Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,
                                     Billing_Company__c, Billing_Country__c, Billing_Email__c, 	Billing_Fax__c, Billing_First_Name__c, 	
                                     Billing_Last_Name__c, Billing_Phone__c, Billing_State_Text__c, Billing_Zip_Postal__c, Charge_Date__c,
                                     Manual_Charge__c, Next_Transaction_Date__c, Payment_Count__c, Payment_End_Date__c, Payment_Frequency__c, 
                                     Payment_Start_Date__c, Payment_Status__c, Payment_Stop__c, Charge_Amount__c,Shipping_Address__c,
									 Do_Not_change_amount__c,Display_Invoice_Number__c from Opportunity where Id IN: oppIds];
        
        
        List<Legacy_Transaction__c> transactions = [select id, Opportunity__c, Billing_Email__c, Tokenization__c,Gateway__c,
                                                          Payment_Method__c,Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,
                                                          Billing_Company__c ,Billing_Country__c,Billing_Fax__c,Billing_First__c,  
                                                          Billing_Last__c,Do_not_fire__c,Fee__c,Accounting_Notes__c,Created_New_Opportunity__c,Backup_Auto_Renewal__c,Charge_Now__c,
                                                          Billing_Phone__c, Billing_State__c, Billing_Postal_Code__c ,Authorization__c,
                                                          Credit_Card_Name__c,Credit_Card_Type__c,Recurring__c, Security_Response__c,
                                                          Card_Last_4__c,Gateway_Response__c,Response_Message__c,Response_Status__c,
                                                          Response__c,Type__c,Gateway_Date__c,Gateway_ID__c,Amount__c
                                                          from Legacy_Transaction__c where Id IN: transactionIds];
        
        
        List<ChargentOrders__ChargentOrder__c> orders = [Select Id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c IN: oppIds];
        
        for(ChargentOrders__ChargentOrder__c order : orders){
            oppToOrderMap.put(order.Opportunity__c, order);
        }
        
        for(Opportunity opp : oppList){
            if(!oppToOrderMap.containsKey(opp.Id)){
                ChargentOrders__ChargentOrder__c order = new ChargentOrders__ChargentOrder__c();
                order.Opportunity__c = opp.id;
                order.ChargentOrders__Invoice_Number__c = opp.Display_Invoice_Number__c;
                order.ChargentOrders__Gateway__c = opp.Gateway__c;
                order.ChargentOrders__Payment_Method__c = opp.Payment_Method_New__c;
                order.ChargentOrders__Payment_Status__c = opp.Payment_Status__c;
                order.ChargentOrders__Payment_Frequency__c = opp.Payment_Frequency__c;
                order.ChargentOrders__Charge_Date__c = opp.Charge_Date__c;
                order.ChargentOrders__Payment_Stop__c = opp.Payment_Stop__c;
                order.ChargentOrders__Payment_End_Date__c = opp.Payment_End_Date__c;
                order.ChargentOrders__Payment_Start_Date__c = opp.Payment_Start_Date__c;
                order.ChargentOrders__Next_Transaction_Date__c = opp.Next_Transaction_Date__c;
                order.ChargentOrders__Manual_Charge__c = opp.Manual_Charge__c;
                order.ChargentOrders__Charge_Amount__c = opp.Charge_Amount__c;
                order.ChargentOrders__Payment_Count__c = opp.Payment_Count__c;
                order.ChargentOrders__Billing_Address__c = opp.Billing_Address__c;
                order.ChargentOrders__Billing_Address_Line_2__c = opp.Billing_Address_Line_2__c;
                order.ChargentOrders__Billing_City__c = opp.Billing_City__c;
                order.ChargentOrders__Billing_Company__c = opp.Billing_Company__c;
                order.ChargentOrders__Billing_Country__c = opp.Billing_Country__c;
                order.ChargentOrders__Billing_Email__c = opp.Billing_Email__c;
                order.ChargentOrders__Billing_Fax__c = opp.Billing_Fax__c;
                order.ChargentOrders__Billing_First_Name__c = opp.Billing_First_Name__c;
                order.ChargentOrders__Billing_Last_Name__c = opp.Billing_Last_Name__c;
                order.ChargentOrders__Billing_Phone__c = opp.Billing_Phone__c;
                order.ChargentOrders__Billing_State_Province__c = opp.Billing_State_Text__c;
                order.ChargentOrders__Billing_Zip_Postal__c = opp.Billing_Zip_Postal__c;
                order.ChargentOrders__Shipping_Address__c = opp.Shipping_Address__c;
                order.Do_Not_Change_Amount__c = opp.Do_Not_Change_Amount__c;
                ordersToInsert.add(order);
            }
        }
        
        if(!ordersToInsert.isEmpty()){
            insert ordersToInsert;
        }
        
        List<ChargentOrders__ChargentOrder__c> ordersList = [Select Id,Opportunity__c from ChargentOrders__ChargentOrder__c where Opportunity__c IN: oppIds];
        
        for(ChargentOrders__ChargentOrder__c order : ordersList){
            oppToOrderMap.put(order.Opportunity__c, order);
            orderIds.add(order.Id);
        }
        
        List<ChargentOrders__Transaction__c> orderTransList = [Select Id,ChargentOrders__Tokenization__c,Opportunity__c,ChargentOrders__Order__c from ChargentOrders__Transaction__c
                                                               Where ChargentOrders__Type__c = 'Charge'
                                                               AND ChargentOrders__Response__c = '0' AND ChargentOrders__Response_Status__c = 'Approved' 
                                                               AND ChargentOrders__Response_Message__c = 'Approved' 
                                                               AND Opportunity__c IN: oppIds AND ChargentOrders__Order__c IN: orderIds];
        
        for(ChargentOrders__Transaction__c tran : orderTransList){
            tokenToTranIdMap.put(tran.Opportunity__c, tran.Id);
        }
        
        for(Legacy_Transaction__c tran : transactions){
            if(!tokenToTranIdMap.containskey(tran.Opportunity__c)){
                ChargentOrders__Transaction__c ordTran = new ChargentOrders__Transaction__c();
                ordTran.Opportunity__c = tran.Opportunity__c;
                ordTran.ChargentOrders__Order__c = oppToOrderMap.get(tran.Opportunity__c).Id;
                ordTran.ChargentOrders__Gateway__c = tran.Gateway__c;
                ordTran.ChargentOrders__Tokenization__c = tran.Tokenization__c;
                ordTran.ChargentOrders__Payment_Method__c = tran.Payment_Method__c;
                ordTran.ChargentOrders__Billing_Address__c = tran.Billing_Address__c;
                ordTran.ChargentOrders__Billing_Address_Line_2__c = tran.Billing_Address_Line_2__c;
                ordTran.ChargentOrders__Billing_City__c = tran.Billing_City__c;
                ordTran.ChargentOrders__Billing_Company__c = tran.Billing_Company__c;
                ordTran.ChargentOrders__Billing_Country__c = tran.Billing_Country__c;
                ordTran.ChargentOrders__Billing_Email__c = tran.Billing_Email__c;
                ordTran.ChargentOrders__Billing_Fax__c = tran.Billing_Fax__c;
                ordTran.ChargentOrders__Billing_First__c = tran.Billing_First__c;
                ordTran.ChargentOrders__Billing_Last__c = tran.Billing_Last__c;
                ordTran.ChargentOrders__Billing_Phone__c = tran.Billing_Phone__c;
                ordTran.ChargentOrders__Billing_State__c = tran.Billing_State__c;
                ordTran.ChargentOrders__Billing_Postal_Code__c = tran.Billing_Postal_Code__c;
                ordTran.ChargentOrders__Authorization__c = tran.Authorization__c;
                ordTran.Do_Not_Fire__c = tran.Do_Not_Fire__c;
                ordTran.Fee__c = tran.Fee__c;
                ordTran.Accounting_Notes__c = tran.Accounting_Notes__c;
                ordTran.Created_New_Opportunity__c = tran.Created_New_Opportunity__c;
                ordTran.Backup_Auto_Renewal__c = tran.Backup_Auto_Renewal__c;
                ordTran.Charge_Now__c = tran.Charge_Now__c;
                ordTran.ChargentOrders__Gateway_ID__c  = tran.Gateway_ID__c;
                ordTran.ChargentOrders__Gateway_Date__c  = tran.Gateway_Date__c;
                ordTran.ChargentOrders__Response_Status__c = tran.Response_Status__c;
                ordTran.ChargentOrders__Response_Message__c = tran.Response_Message__c;
                ordTran.ChargentOrders__Response__c = tran.Response__c;
                ordTran.ChargentOrders__Type__c = tran.Type__c;
                ordTran.ChargentOrders__Gateway_Response__c = tran.Gateway_Response__c;
                ordTran.ChargentOrders__Card_Last_4__c = tran.Card_Last_4__c;
                ordTran.ChargentOrders__Card_Code_Response__c = tran.Security_Response__c;
                ordTran.ChargentOrders__Recurring__c = tran.Recurring__c;
                ordTran.ChargentOrders__Credit_Card_Type__c = tran.Credit_Card_Type__c;
                ordTran.ChargentOrders__Credit_Card_Name__c = tran.Credit_Card_Name__c;
                ordTran.ChargentOrders__Amount__c = tran.Amount__c;
                transactionsToInsert.add(ordTran);
            }
        }
        
        if(!transactionsToInsert.isEmpty()){
            insert transactionsToInsert;
        }
        
        List<ChargentOrders__Transaction__c> orderTrans = [Select Id,ChargentOrders__Tokenization__c,Opportunity__c,ChargentOrders__Order__c from ChargentOrders__Transaction__c
                                                           Where ChargentOrders__Type__c = 'Charge'
                                                           AND ChargentOrders__Response__c = '0' AND ChargentOrders__Response_Status__c = 'Approved' 
                                                           AND ChargentOrders__Response_Message__c = 'Approved' 
                                                           AND Opportunity__c IN: oppIds AND ChargentOrders__Order__c IN: orderIds];
        
        for(ChargentOrders__Transaction__c tran : orderTrans){
            tokenToTranIdMap.put(tran.Opportunity__c, tran.Id);
        }
        
        for(Product_Refunds__c refund : refunds){
            refund.Payment_Order_Transaction__c = tokenToTranIdMap.containskey(refund.Legacy_Transaction__r.Opportunity__c) ? tokenToTranIdMap.get(refund.Legacy_Transaction__r.Opportunity__c) : null;
            refundsToUpdate.add(refund);
        }
        
        if(!refundsToUpdate.isEmpty()){
            update refundsToUpdate;
        }
        
    }
}