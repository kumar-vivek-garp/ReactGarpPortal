public class B2BCreateOpportunityCls {
    
    @AuraEnabled(cacheable=true)
    public static OpportunityLineItemWrapper getProductName(Id productId) {
        OpportunityLineItemWrapper oli = new OpportunityLineItemWrapper();
        try{
            Product2 prod = [SELECT Id, Name,ProductCode FROM Product2 WHERE Id =:productId And IsActive = true LIMIT 1];
            PriceBookEntry objPricebook = [select unitprice, productcode, Product2Id, Pricebook2Id, Name from PriceBookEntry where Pricebook2.IsActive = true and Product2Id=:productId And isActive = true limit 1];
            oli.productId = prod.Id;
            oli.priceBookEntryId = objPricebook.Id;
            oli.unitPrice = objPricebook.unitprice;
            oli.productName = prod.Name;
            oli.productCode = prod.ProductCode;
            return oli; 
        }catch(Exception ex){
            oli.productError = 'Selected Product is inActive.'; 
            return oli;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Account getDefaultAccount(String dealItemId) {
        Account acc = new Account();
        try{
           B2B_Deal_Item__c bdi = [Select Id,B2B_Deal__r.Account__c,B2B_Deal__r.Account__r.Name,B2B_Deal__r.Account__r.GARP_ID__c From B2B_Deal_Item__c Where Id=:dealItemId];
            if(bdi.B2B_Deal__r.Account__c != null){
                acc.Id = bdi.B2B_Deal__r.Account__c;
                acc.Name = bdi.B2B_Deal__r.Account__r.Name +' ( '+bdi.B2B_Deal__r.Account__r.GARP_ID__c+' )';
            }
            return acc; 
        }catch(Exception ex){ 
            return acc;
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<OpportunityLineItemWrapper> getdefaultProductListName(String dealItemId) {
        
        List<OpportunityLineItemWrapper> olilist = new List<OpportunityLineItemWrapper>();
        try{
            List<Pricebook2> pricebook = [Select Id,IsActive, IsStandard,name from Pricebook2 where IsActive = true and Name = 'GARP 2015/2016' limit 1];
            if(Test.isRunningTest()){
                pricebook = [Select Id,IsActive, IsStandard,name from Pricebook2 Where IsActive = true limit 1];
            }
            B2B_Deal_Item__c bdi = [Select Id,RAI_Hard_Books__c,SCR_Hard_Books__c,Discounted_RAI_Hard_Books__c,Discounted_SCR_Hard_Books__c From B2B_Deal_Item__c Where Id=:dealItemId];
            List<String> productIDs = new List<String>();
            Map<String,Integer> productQueantity = new Map<String,Integer>();
             Map<String,Integer> discountPoductMap = new Map<String,Integer>();
            if(bdi.Discounted_RAI_Hard_Books__c != null && bdi.RAI_Hard_Books__c != null){
                integer totalq = integer.valueOf(bdi.Discounted_RAI_Hard_Books__c) + integer.valueOf(bdi.RAI_Hard_Books__c);
                productIDs.add('RAIH');
                productIDs.add('RAICANDISC');
                productQueantity.put('RAIH',totalq);
                discountPoductMap.put('RAICANDISC',integer.valueOf(bdi.Discounted_RAI_Hard_Books__c));
            }
            if(bdi.Discounted_SCR_Hard_Books__c != null && bdi.SCR_Hard_Books__c != null){
                integer totalq = integer.valueOf(bdi.Discounted_SCR_Hard_Books__c) + integer.valueOf(bdi.SCR_Hard_Books__c);
                productIDs.add('SCRH');
                productIDs.add('SCRCANDISC');
                productQueantity.put('SCRH',totalq);
                discountPoductMap.put('SCRCANDISC',integer.valueOf(bdi.Discounted_SCR_Hard_Books__c));
            }
            if(productIDs.size() == 0){
                return olilist;
            }
          Map<Id,PriceBookEntry> PriceBookMap = new Map<Id,PriceBookEntry>();
           for(PriceBookEntry pe:[select unitprice, productcode, Product2Id, Pricebook2Id, Name from PriceBookEntry where Pricebook2.IsActive = true and Pricebook2Id =:pricebook[0].Id  and Product2.ProductCode In:productIDs And isActive = true ]){
                PriceBookMap.put(pe.Product2Id,pe);
           } 
            for(Product2 prod:[SELECT Id, Name,ProductCode FROM Product2 WHERE IsActive = true and ProductCode In:productIDs]){
                OpportunityLineItemWrapper oli = new OpportunityLineItemWrapper();
                PriceBookEntry pbe = PriceBookMap.get(prod.Id);
                oli.productId = prod.Id;
                oli.priceBookEntryId = pbe.Id;
                oli.unitPrice = discountPoductMap.containsKey(prod.ProductCode)?-200:pbe.unitprice;
                oli.productName = prod.Name;
                oli.quantity = productQueantity.containsKey(prod.ProductCode)?productQueantity.get(prod.ProductCode):discountPoductMap.containsKey(prod.ProductCode)?discountPoductMap.get(prod.ProductCode):1;
                oli.productCode = prod.ProductCode;
                olilist.add(oli);
            }
           
            return olilist; 
        }catch(Exception ex){ 
            return olilist;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getAccountName(Id accountId) { 
        Account acc = [SELECT Id,GARP_ID__c, Name FROM Account WHERE Id = :accountId LIMIT 1];
        return acc.Name +' ( '+acc.GARP_ID__c+' )';
    }
    @AuraEnabled
    public static String createOpportunityLineItems(List<OpportunityLineItemWrapper> lineItems,String accountId,String dealItemId) {
        String retval = '';
        try{ 
            List<Pricebook2> pricebook = [Select Id,IsActive, IsStandard,name from Pricebook2 where IsActive = true and Name = 'GARP 2015/2016' limit 1];
            if(Test.isRunningTest()){
                pricebook = [Select Id,IsActive, IsStandard,name from Pricebook2 Where IsActive = true limit 1];
            }
            B2B_Deal_Item__c bdi = [Select Id,End_Date__c,Name,Exam_Type__c,B2B_Deal__c From B2B_Deal_Item__c Where Id=:dealItemId];
            Date dt = bdi.End_Date__c != null ?bdi.End_Date__c:system.today();
            Opportunity opportunity = new Opportunity(
                Name = bdi.Exam_Type__c+' '+dt.year()+' Bulk Order Close', 
                StageName = 'New Lead',
                AccountId = accountId,
                CloseDate =  dt,
                B2B_Deal_Item__c = bdi.Id,
                Pricebook2Id = pricebook[0].Id,
                Team_Registration__c = bdi.B2B_Deal__c 
            );
            
            insert opportunity; 
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
           
            for (OpportunityLineItemWrapper lineItem : lineItems) {  
                OpportunityLineItem oli = new OpportunityLineItem(
                    OpportunityId = opportunity.Id,
                    Product2Id = lineItem.productId,
                    Quantity = lineItem.quantity,
                    PricebookEntryId = lineItem.priceBookEntryId,
                    UnitPrice = lineItem.unitPrice
                );
                oliList.add(oli);
            }
            
            insert oliList;
            retval = 'Success';
        }catch(Exception ex){
            retval = ex.getMessage()+ ex.getStackTraceString();
        }
        return retval;
    }

    // Wrapper class to handle multiple line item inputs
    public class OpportunityLineItemWrapper {
        @AuraEnabled public String productId {get;Set;}
        @AuraEnabled public String productName{get;Set;}
        @AuraEnabled public String priceBookEntryId{get;Set;}
        @AuraEnabled public String productError{get;Set;}
        @AuraEnabled public String productCode{get;Set;}
        @AuraEnabled public Integer quantity{get;Set;}
        @AuraEnabled public Decimal unitPrice{get;Set;}
    }
}