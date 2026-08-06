/*	Controller for SitePaymentGARPB2B. VF page action invokes fetchData().
 * 	06/03/2019 Xiang - [US-22619] Added check for paid/cancelled Bulk Registration
 */
global without sharing class SitePaymentGARPControllerB2B {
    
    /*private static final String SYS_DATE_FORMAT = 'MM/dd/yyyy h:mm a';
    private static final String SHORT_TIME_FORMAT = 'EEEE, MMMM d yyyy';*/
    
    public static final String SYS_DATE_FORMAT = 'MM/dd/yyyy h:mm a';
    public static final String SHORT_TIME_FORMAT = 'EEEE, MMMM d yyyy';
    
    global String sURL {get; set;}
    global String cURL {get; set;}   
    global String fURL {get; set;}   
    
    global Id oppId {get;set;} 
    global String status {get;set;}
    global string type {get;set;}
    global string msg {get;set;}
    global Boolean isPaid {get;set;}
    global Decimal OrderNet {get;set;}
    global Opportunity opp {get;set;}
    
    global OpportunityWrapper opportunity {get;set;}
       
    global String id {get; set;}
         global String company {get; set;}
         global String stage {get; set;}
         global String name{get;set;}
         global String account{get;set;}      
    
    global String getNow() {
        return System.now().format(SYS_DATE_FORMAT);
    }
    
    // Custom Label based URL to reflect environment
    global static String invoiceUrl {get; private set;}
    
    // sURL - success URL, cURL - Cancel URL, fURL - fail URL. These are used in redirect VF page (Example value: public_payment)
    global SitePaymentGARPControllerB2B() {
        Map<String, String> paraMap = ApexPages.currentPage().getParameters();
        String oppId = paraMap.get('id');
        
        sURL = '/chargent/redirect?pass=1&url=' + paraMap.get('sURL') + '&oppid=' + oppId;        
        cURL = '/chargent/redirect?url=' + paraMap.get('cURL') + '&oppid=' + oppId + (String.isEmpty(paraMap.get('curloverride')) ? '' : '&curloverride=1');
        fURL = '/chargent/redirect?pass=0&url=' + paraMap.get('fURL') + '&oppid=' + oppId;
        
        status = 'Unpaid';
        isPaid = false;
        type = ''; 
     
        msg = '';
        OrderNet = 0;
    }
    
    global void fetchData() {
       oppId = ApexPages.currentPage().getParameters().get('id');                
       opportunity = new OpportunityWrapper([Select id, Name, Account.name, Account.RecordTypeId, Company__c, StageName, LEGACY_Purchase_Date__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Company__c, 
                Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c,
                Billing_Phone__c, Billing_Email__c, Shipping_First_Name__c, Shipping_State__c, Shipping_Postal_Code__c,Shipping_Last_Name__c, 
                Shipping_Phone_No__c, Shipping_Company_Name__c, Shipping_Country__c, Display_Invoice_Number__c, Inst_Sale_Display_Invoice_Number__c, Product_Name__c, Shipping_City__c, Shipping_Street__c, Shipping_E_mail__c, Charge_Amount__c, Amount, CreatedDate,
                Institutional_Sale__c, Inst_Sale_Opp__c
                FROM Opportunity
                WHERE id= :oppId]);
        
        if(opportunity.stage == 'Closed') {
            status = 'Paid';
        }else if(opportunity.stage == 'Closed Lost') {
            status = 'Cancelled';
        }
        
        invoiceUrl = Label.Chargent_Site + '/Public_InstitutionalSalesInvoice?id=' + opportunity.id;
    }

    global class OpportunityWrapper {
        global String id {get; set;}
        global String company {get; set;}
        global String stage {get; set;}
        global String name{get;set;}
        global String account{get;set;}
        global Decimal chargentSFAChargeAmount {get; set;}
        global Decimal amount {get; set;}
        global DateTime createdDate {get; set;}
        global String createdDateFormatted {get; set;}
        global String garpInvoiceNumber {get; set;}
        global String instSaleInvoice {get; set;}
        global Boolean isB2B {get;set;}
        
        global Boolean isInstSale {get; private set;}
        global Boolean isMasterOrder {get; private set;}
        global Boolean canPay {get; private set;}
        
        global OpportunityWrapper(Opportunity opp) {
            id = opp.id;
            company = opp.Company__c;  
            stage = opp.StageName;
            name = opp.Name;
            account = opp.account.name;
            amount = opp.Amount;
            garpInvoiceNumber = opp.Display_Invoice_Number__c;
            instSaleInvoice = opp.Inst_Sale_Display_Invoice_Number__c;
            createdDate = opp.CreatedDate;
			
            isInstSale = opp.Institutional_Sale__c;
			isMasterOrder = opp.Institutional_Sale__c && opp.Inst_Sale_Opp__c == null;
            canPay = opp.StageName != 'Closed' && opp.StageName != 'Closed Lost';
            
            // Account Record Type - Sales 
            if(opp.Account.RecordTypeId == '012400000005iRI')
                isB2B = true;
            //else isB2B = false;
            
            //createdDateFormatted = opp.CreatedDate.format(SHORT_TIME_FORMAT);
            
            if(opp.LEGACY_Purchase_Date__c != null)
                createdDateFormatted = opp.LEGACY_Purchase_Date__c.format(SHORT_TIME_FORMAT);
            else createdDateFormatted = opp.CreatedDate.format(SHORT_TIME_FORMAT);
        }
    }
    
}