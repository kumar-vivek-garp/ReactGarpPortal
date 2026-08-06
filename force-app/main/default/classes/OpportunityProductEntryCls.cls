public class OpportunityProductEntryCls {
    @AuraEnabled
    public String errorMessage{get;set;}
    @AuraEnabled
    public boolean isvalidaopp{get;set;}
   /* @AuraEnabled
    public Country_Code__c countryCodeObj{get;set;}
    @AuraEnabled
    public boolean isCalculateGST{get;set;}*/
    @AuraEnabled
    public Opportunity opp{get;set;}
    @AuraEnabled
    public List<OpportunityLineItem> oppLineitemList{get;set;}
   /* @AuraEnabled
    public List<String> salesTaxProducts{get;set;}
    @AuraEnabled
    public boolean isNJSalesTax{get;set;}*/
    
    @AuraEnabled
    Public Static OpportunityProductEntryCls getOpportunityProducts(String InvoiceNumber){
        OpportunityProductEntryCls entrycls = new OpportunityProductEntryCls();
        entrycls.isvalidaopp = false;
        //entrycls.isCalculateGST = false;
       // entrycls.isNJSalesTax = false;        
        entrycls.opp = new Opportunity();
        entrycls.oppLineitemList = new List<OpportunityLineItem>();
        //entrycls.salesTaxProducts = new List<String>();
        if(String.isBlank(InvoiceNumber)){
            entrycls.errorMessage = 'Invalid Invoce Number Data';
        }else{
            List<Opportunity> oppList = [Select Id,Display_Invoice_Number__c,Billing_Country__c,Billing_State_Text__c,Shipping_Country__c,Account.Name,AccountId From Opportunity where Display_Invoice_Number__c =:InvoiceNumber and StageName = 'New Lead' LIMIT 1];
            if(oppList.size() > 0 ){
               // entrycls.countryCodeObj = new Country_Code__c();
               /* for(Country_Code__c cr:[SELECT Id,VAT__c,VAT_Product_Code__c,Country__c from Country_Code__c where VAT__c != null and Country__c=:oppList[0].Billing_Country__c limit 1]){
                    entrycls.isCalculateGST = true;
                    entrycls.countryCodeObj = cr;
                } */
                entrycls.isvalidaopp = true;
                entrycls.opp = oppList[0];
                /*if((oppList[0].Billing_Country__c == 'United States' || oppList[0].Billing_Country__c == 'US') && (oppList[0].Billing_State_Text__c == 'New Jersey' || oppList[0].Billing_State_Text__c == 'NJ')){
                    entrycls.isNJSalesTax = true;
                    entrycls.salesTaxProducts = getListOfSalesTaxProducts();
                }*/
                entrycls.oppLineitemList = [SELECT Id,Product2.Name,Product2.Tax_Rate__c,Product2.Product_ID__c,Product2.Do_Not_Charge_VAT__c, OpportunityId,Quantity,PricebookEntryId, UnitPrice,Product2.ProductCode, Product2Id FROM OpportunityLineItem  WHERE OpportunityId = :oppList[0].Id Order by CreatedDate Desc];
            }else{
                entrycls.errorMessage = 'Please Provide Only Unpaid Invoices..'; 
            }
        }
        
        return entrycls;
    }
    
    /*
    private static List<String> getListOfSalesTaxProducts(){
        List<String> prcodes = new List<String>();
        for(Product_Program_Configuration__mdt prc:[Select Id,Shipping_Product_Mapping__c,Study_Material_Mapping__c From Product_Program_Configuration__mdt]){
            if(prc.Study_Material_Mapping__c != null){
                List<String> studym = prc.Study_Material_Mapping__c.split(','); 
                prcodes.addAll(studym);
            }
            if(prc.Shipping_Product_Mapping__c != null){
                List<String> shippr = prc.Shipping_Product_Mapping__c.split(',');
                prcodes.addAll(shippr);
            }
        }
        return prcodes;
    } */
    
    @AuraEnabled
    Public Static String dateleOpportunityLineItem(String recordId){
        try{
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.id = recordId; 
            delete oli;
            return 'Product Delete Successfully..';
        }catch(Exception ex){
            return ex.getMessage();
        } 
    }
    
    @AuraEnabled(cacheable=true)
    public static PriceBookEntry getPriceBookEntry(Id productId) { 
        try{ 
            PriceBookEntry objPricebook = [select Id,UnitPrice,Product2.Tax_Rate__c, ProductCode,Product2.Product_ID__c, Product2Id, Pricebook2Id, Name from PriceBookEntry where Pricebook2.IsActive = true and Product2Id=:productId And isActive = true And Pricebook2.Name = 'GARP 2015/2016' limit 1];
            return objPricebook; 
        }catch(Exception ex){ 
            return null;
        }
    }
    
    @AuraEnabled
    public static String createOpportunityLineItems(List<OpportunityLineItem> lineItems) {
        try{ 
            upsert lineItems; 
            return 'Success';
        }catch(Exception ex){
            return  ex.getMessage();
        } 
    }
    
    @AuraEnabled
    public static String calculateStripeTax(String oppid){
        try{  
             Map<String, String> resMap = StripeTaxCalUtil.StripeTaxCulate(new Set<String>{oppid});
            if(resMap.get(oppid) == 'Success'){ 
                return 'Tax Calculationd Successfully';
            }else{
                return 'Tax Calculation Error';
            } 
        }catch(Exception ex){
            return  ex.getMessage();
        }   
    }
    
}