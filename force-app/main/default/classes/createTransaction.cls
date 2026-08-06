public class createTransaction
{
    public Opportunity opp{get;set;}
    public String[] options{get;set;}
    public String strSelectedVal{get;set;}
    public decimal dAmount{get;set;}
    public boolean bPaidInFull {get;set;}
    public string notes {get;set;}
    public ChargentOrders__Transaction__c objTrans{get;set;}
    public boolean bRender{get;set;}  
    public boolean trbRender{get;set;}  
    public Opportunity taxopp {get;set;}
    public createTransaction(Apexpages.StandardController std)
    {
        opp = (opportunity)std.getRecord();
        opp = [select id,Amount,StageName,Gateway__c,Payment_Method_New__c, Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,Do_Not_change_amount__c,
               Billing_Company__c, Billing_Country__c, Billing_Email__c, Billing_Fax__c, Billing_First_Name__c, Shipping_Address__c,
               Billing_Last_Name__c, Billing_Phone__c, Billing_State_Text__c, Billing_Zip_Postal__c, Charge_Date__c,Manual_Charge__c, 
               Next_Transaction_Date__c, Payment_Count__c, Payment_End_Date__c, Payment_Frequency__c, Payment_Start_Date__c,Display_Invoice_Number__c, 
               Payment_Status__c, Payment_Stop__c, Charge_Amount__c,(Select Id from Chargent_Orders__r) from opportunity where id =: opp.Id];
        system.debug('opp : '+opp);
        objTrans = new ChargentOrders__Transaction__c();
        bRender = true;
        if(opp.stageName != 'New Lead')
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'You can process payment for only open invoice.');
            ApexPages.addMessage(myMsg);
            bRender = false;
            //return null;

        }
        
    }

     public List<SelectOption> getItems() {
            List<SelectOption> options = new List<SelectOption>();
            options.add(new SelectOption('Credit Card By Fax','Credit Card By Fax'));
            options.add(new SelectOption('Check','Check'));
            options.add(new SelectOption('Wire Transfer','Wire Transfer'));
            options.add(new SelectOption('Free','Free'));
            options.add(new SelectOption('ACH','ACH'));
            return options;
        }

    public PageReference SaveTransaction()
    {
       
        if(dAmount == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Amount should not blank.');
            ApexPages.addMessage(myMsg);
            return null;

        }
         if(dAmount > opp.Amount)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Amount should not be greater than Opportunity total.');
            ApexPages.addMessage(myMsg);
            return null;

        }
        
        List<ChargentOrders__ChargentOrder__c> ordersToInsert = new List<ChargentOrders__ChargentOrder__c>();
        
        if(opp.Chargent_Orders__r.isEmpty()){
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
        
        if(!ordersToInsert.isEmpty()){
            insert ordersToInsert;
        }
        
        Opportunity oppty = [select id,Amount,StageName,(Select Id from Chargent_Orders__r) from opportunity where id =: opp.Id];

        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        trans.Opportunity__c = oppty.Id;
        trans.ChargentOrders__Amount__c = dAmount;
        trans.ChargentOrders__Payment_Method__c = strSelectedVal;
        trans.Accounting_Notes__c = objTrans.Accounting_Notes__c;
        trans.ChargentOrders__Response_Message__c = 'Approved';
        trans.ChargentOrders__Response_Status__c = 'Approved';
        trans.ChargentOrders__Type__c = 'Charge';
        if(!bPaidInFull)
        {
            trans.Do_not_fire__c = TRUE;
       
        }
        trans.ChargentOrders__Gateway_Date__c = objTrans.ChargentOrders__Gateway_Date__c;
        trans.ChargentOrders__Order__c = oppty.Chargent_Orders__r[0].Id;
        insert trans;
         PageReference pageRef = new PageReference('/'+oppty.id);
        pageRef.setRedirect(true);
        return pageref;



    }

    public PageReference CancelTransaction()
    {
        
        PageReference pageRef = new PageReference('/'+opp.id);
        pageRef.setRedirect(true);
        return pageref; 
    }
    
    public void CalculateTax(){   
        Map<String, String> resMap = StripeTaxCalUtil.StripeTaxCulate(new Set<String>{opp.Id});
        String status = resMap.get(opp.Id); 
        Boolean isSuccess = (status == 'Success');        
        ApexPages.Severity severity = isSuccess ? ApexPages.Severity.CONFIRM : ApexPages.Severity.ERROR;
        String displayMsg = isSuccess ? 'Tax calculated successfully. Proceed with the transaction.' : status;        
        ApexPages.addMessage(new ApexPages.Message(severity, displayMsg));     
        this.trbRender = isSuccess;
        this.bRender = !isSuccess;
        taxopp = new Opportunity();
        taxopp = [Select Id,Stripe_Tax_Total_Amount__c,Stripe_Tax_Type__c,Stripe_Tax_Country__c,Stripe_Tax_Percent__c,Stripe_Tax_Taxable_Amount__c,Amount From Opportunity Where Id=:opp.Id];
        
    } 
}