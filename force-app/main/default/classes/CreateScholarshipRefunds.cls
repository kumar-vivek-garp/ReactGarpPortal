public class CreateScholarshipRefunds {
    
    public static string message;
    public static string response;
    
    @auraEnabled
    public static string Pricecal(string oppid1){ 

        String oppid = oppid1;
        Decimal amount;
        String prodid;
        
        List<OpportunityLineItem> oppLine =[
            SELECT Id, OpportunityId, Product2Id, Quantity, ProductCode, Opportunity.Stagename, Product2.GL_Code__c, UnitPrice     
            FROM OpportunityLineItem 
            WHERE Opportunityid = :oppid
        ];
        
        for(OpportunityLineItem ol: oppLine){           
            if(ol.ProductCode =='FRM1E' ){
                amount = ol.UnitPrice;
                prodid = ol.Product2Id;
            }else if(ol.ProductCode =='FRM1S'){
                amount = ol.UnitPrice;  
                prodid = ol.Product2Id;
            }else if(ol.ProductCode =='FRM1L'){
                amount = ol.UnitPrice;
                prodid = ol.Product2Id;
            }  
        }
        
        system.debug('######:'+oppLine); 
        
        // calling next method to create programs.
        message = createOpportunityLineItems(oppid,amount,prodid);
        return message;
        
    }
    
    @auraEnabled
    public static string createOpportunityLineItems(string oppid,decimal amount,string prodid){ 
        
        List<OpportunityLineItem> oppls = new list<OpportunityLineItem> ();
        for (PriceBookEntry PricebookEntryId: [
            SELECT UnitPrice, productcode, product2.Gl_Code__c 
            FROM PriceBookEntry 
            WHERE Pricebook2.IsActive = true AND ProductCode = 'SAFRM1' AND Product2.Gl_Code__c = '4003' AND IsActive = true
        ]) {
            system.debug('PricebookEntryId:'+PricebookEntryId);
            OpportunityLineItem oppLineItem = new OpportunityLineItem();
            oppLineItem.OpportunityId = oppid;
            oppLineItem.UnitPrice  = -amount;
            oppLineItem.PricebookEntryId = PricebookEntryId.Id;
            oppLineItem.Description ='Scholarship Awarded for FRM Exam Part I' ;
            oppLineItem.Quantity = 1;
            oppls.add(oppLineItem);
            system.debug('oppls:'+oppls);
        }
        
        INSERT oppls;
        system.debug('######:'+oppls); 
        
        response= createprodcutrefund(oppid, amount, prodid);
        system.debug('****:'+response);
        return response;
    }
    
    @auraEnabled
    public static string createprodcutrefund(string oppid,decimal amount,string prodid){  
        list<Product_Refunds__c> prList = new list<Product_Refunds__c>();
        
        ChargentOrders__Transaction__c tranId =[
            SELECT id,Opportunity__c,ChargentOrders__Type__c,ChargentOrders__Amount__c,ChargentOrders__Response_Status__c
            FROM ChargentOrders__Transaction__c 
            WHERE Opportunity__c = :oppid AND ChargentOrders__Type__c = 'charge' AND ChargentOrders__Response_Status__c ='Approved' AND ChargentOrders__Response_Message__c ='Approved'
        ];
    
        Product_Refunds__c pr = new Product_Refunds__c();
                
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Product_Refunds__c', 'Product Refunds');

        pr.Product__c = prodid;
        pr.recordTypeID = recordTypeID;
        pr.Payment_Order_Transaction__c = tranId.id;
        pr.Reason__c = 'Scholarship Awarded for FRM Exam Part I';
        pr.Opportunity__c =oppid;
        pr.Status__c ='Submitted';
        pr.Sales_Price__c =amount; 
        pr.Given_Scholarship__c  =true;
         
        INSERT pr;
        
        response = 'success';
        return response;
         
    }
}