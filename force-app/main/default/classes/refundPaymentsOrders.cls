public  without sharing class refundPaymentsOrders
{
    public ChargentOrders__Transaction__c payment;
    public list<wrapperOpps> lstWrapper{get;set;}
    public list<Exam_Attempt__c> scheduledRegList{get;set;}
    public boolean bRender{get;set;}
    public Boolean bIsEditable {get;set;}
    
    public refundPaymentsOrders(Apexpages.StandardController std)
    { 
        
        User us = [Select id, Event_Management__c from User where id = :userinfo.getuserId()];
        bIsEditable = us.Event_Management__c;
        payment = (ChargentOrders__Transaction__c)std.getRecord();
        try
        {
            payment = [select id,Opportunity__c,ChargentOrders__Type__c,ChargentOrders__Amount__c,ChargentOrders__Response_Status__c
                       from ChargentOrders__Transaction__c where id=: payment.Id];
        }
        catch(Exception ex)
        {
            
        }
        
        bRender = true;
        if(payment.ChargentOrders__Type__c != 'Charge' && payment.ChargentOrders__Response_Status__c != 'Approved')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You cannot issue a refund for this transaction.');
            ApexPages.addMessage(myMsg);
            bRender = false;
            return;
            
        }
        
        
        loadLineItems(payment);
        
    }
    
    public class wrapperOpps
    {
        public boolean isSelected{get;set;}
        public Product_Refunds__c objProductRefund{get;set;}
        public Decimal dAmount{get;set;}
        public Decimal Sale_Price{get;set;}
        public String Refund_Code{get;set;}
        public String productCode;
        public String eventId;
        public List<SelectOption> discountCodes{get;set;} 
        public String code{get;set;}
        
        public wrapperOpps(OpportunityLineItem oppLine,ChargentOrders__Transaction__c objPayment)
        {	
            discountCodes = new List<SelectOption>();
            List<Discount_Product_Code__mdt> mdt = [SELECT Id, Label, Value__c FROM Discount_Product_Code__mdt];  
            discountCodes.add(new SelectOption('', '-- NONE --'));
            for( Discount_Product_Code__mdt md : mdt)
            {
                discountCodes.add(new SelectOption(md.Value__c, md.Value__c));
            }  
            discountCodes.sort();
            
            objProductRefund = new Product_Refunds__c();
            objProductRefund.Product__c = oppLine.Product2Id;
            objProductRefund.Payment_Order_Transaction__c = objPayment.Id;
            objProductRefund.Reason__c = '';
            //objProductRefund.Discount_Product_Code__c = code;
            
            decimal dQuantity = oppLine.Quantity;
            if(oppLine.Quantity == null || oppLine.Quantity == 0)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Quantity for '+ oppLine.Product2Id +' is empty.'));
                
            }
            
            if(oppLine.ProductCode == 'MEMW'){
                objProductRefund.Refund_amount__c = oppLine.UnitPrice * dQuantity;
                objProductRefund.Sales_Price__c = objProductRefund.Refund_amount__c;
                objProductRefund.Wiley_Quantity__c= dQuantity;
            }
            else
            {
                objProductRefund.Refund_amount__c = oppLine.UnitPrice;
                objProductRefund.Sales_Price__c = oppLine.UnitPrice;
            }
            objProductRefund.Opportunity__c = oppLine.OpportunityID;
            objProductRefund.Unique_Id__c = string.valueOf(oppLine.OpportunityID)+string.valueOf(oppLine.Product2Id); 
            if(oppLine.Product_ID__c!='')
                objProductRefund.Product_ID__c = string.valueOf(oppLine.Product_ID__c) ;
            objProductRefund.Take_Membership__c = false;
            if(oppLine.Event__c != null){
                objProductRefund.Event__c = oppLine.Event__c;  
            }
            productCode = oppLine.ProductCode;
        }
    }
    
    public pageReference saveData(){
        List<Product_Refunds__c> lstProdRefunds = new List<Product_Refunds__c>();
        decimal dTotal = 0;
        boolean bSelected = false;
        
        for(wrapperOpps objWrap : lstWrapper){
            
            if(objWrap.isSelected){
                system.debug('objWrap::>>  '+objWrap);
                dTotal += objWrap.objProductRefund.Refund_amount__c;
                objWrap.objProductRefund.Discount_Product_Code__c = objWrap.code;
                //objWrap.objProductRefund.UniqueProductOpportunity__c = String.ValueOf(Integer.valueof((Math.random() * 1000000000)));
                lstProdRefunds.add(objWrap.objProductRefund);
            }
        }
        
        if(lstProdRefunds.size() <= 0)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Please select record before saving.'));
            return null;
        }
        
        if(!scheduledRegList.isEmpty())
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'You cannot issue a refund for this transaction because the candidate has an exam scheduled with Pearson.'));
            return null;
        }
        
        
        Decimal dRefundAmount = payment.ChargentOrders__Amount__c;
        if(dRefundAmount < 0)
            dRefundAmount = -dRefundAmount;
        
        if(dTotal > dRefundAmount)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, 'Total amount should not exceed than refund amount.'));
            return null;
        }
        
        try{
            system.debug('lstProdRefunds::>> '+lstProdRefunds);
            upsert lstProdRefunds;
        }
        catch(DMLException ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,ex.getMessage()));
            return null;
        }
        
        PageReference pageRef = new PageReference('/'+payment.Id);
        pageRef.setRedirect(true);
        
        return pageRef;
    }
    
    public void loadLineItems(ChargentOrders__Transaction__c objPay)
    {
        lstWrapper = new list<wrapperOpps>();
        Id oppId = null;
        
        oppId = payment.Opportunity__c;
        for(OpportunityLineItem opp : [select id,ProductCode,UnitPrice,Event__c, Product_ID__c ,opportunity.stagename, TotalPrice,Quantity,Product2Id,OpportunityID from OpportunityLineItem
                                       where OpportunityID =: oppId and opportunity.stagename='closed' ])
        {
            lstWrapper.add(new wrapperOpps(opp,objPay));
            if(opp.ProductCode == 'GSTTAX' || opp.ProductCode == 'IGSTTAX'){
                bIsEditable = false;
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please contact IT for GST partial refunds',''));
            }
        }
        system.debug('lstWrapper: ' + lstWrapper);
        
        scheduledRegList = new List<Exam_Attempt__c>();
        scheduledRegList = [Select Id,Integration_Data_Status__c,Opportunity__c from Exam_Attempt__c
                            where Opportunity__c =: oppId and Integration_Data_Status__c = 'Paid Scheduled' and RPT_Exam_Provider__c = 'Pearson'];
    }
    
}