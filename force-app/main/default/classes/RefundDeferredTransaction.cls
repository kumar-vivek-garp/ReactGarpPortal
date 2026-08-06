public without sharing class RefundDeferredTransaction
{
    public ChargentOrders__Transaction__c trans{get;set;}
    public String[] options{get;set;}
    public String strSelectedVal{get;set;}
    public decimal dAmount{get;set;}
    public String strCusToken{get;set;}
    public String strGateToken{get;set;}
    public boolean bPaidInFull {get;set;}
    //public DateTime dtDate {get;set;}
    public RefundDeferredTransaction(Apexpages.StandardController std)
    {
        trans = (ChargentOrders__Transaction__c)std.getRecord();
        trans = [select id,ChargentOrders__Order__c,Opportunity__c,Opportunity__r.Amount,Accounting_Notes__c,ChargentOrders__Gateway_Date__c from ChargentOrders__Transaction__c where id =: trans.Id];

    }

    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Check','Check'));
        options.add(new SelectOption('Wire Transfer','Wire Transfer'));
        options.add(new SelectOption('Charge Back Accepted','Charge Back Accepted'));
        options.add(new SelectOption('Charge Back Loss','Charge Back Loss'));
        options.add(new SelectOption('ACH','ACH'));
        options.add(new SelectOption('Alipay','Alipay'));
        options.add(new SelectOption('Wechatpay','Wechatpay'));
        return options;
    }

    public PageReference SaveTransaction()
    {
        /*if(dAmount > trans.ChargentSFA__Opportunity__r.Amount)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Amount should not be greater than Opportunity total.');
            ApexPages.addMessage(myMsg);
            return null;

        }*/
        ChargentOrders__Transaction__c tr = new ChargentOrders__Transaction__c();
        tr.ChargentOrders__Order__c = trans.ChargentOrders__Order__c;
        tr.Opportunity__c = trans.Opportunity__c;
        tr.ChargentOrders__Tokenization__c = strCusToken;
        tr.ChargentOrders__Gateway_ID__c = strGateToken;
  //      tr.ChargentSFA__Amount__c = dAmount;
        if(strSelectedVal == 'Charge Back Accepted'){
            tr.ChargentOrders__Payment_Method__c = 'Charge Back Accepted';
        }
        else if(strSelectedVal == 'Charge Back Loss'){
            tr.ChargentOrders__Payment_Method__c = 'Charge Back Loss';
        }
        else{
            tr.ChargentOrders__Payment_Method__c = strSelectedVal;
        }
        tr.ChargentOrders__Response_Message__c = 'Approved';
        tr.ChargentOrders__Response_Status__c = 'Approved';
        if(strSelectedVal == 'Charge Back Accepted' || strSelectedVal == 'Charge Back Loss')
            tr.ChargentOrders__Type__c = strSelectedVal;
        else
            tr.ChargentOrders__Type__c = 'Refund';
        tr.ChargentOrders__Gateway_Date__c = trans.ChargentOrders__Gateway_Date__c;
        tr.Accounting_Notes__c = trans.Accounting_Notes__c;
        
        
        if(strSelectedVal == 'Charge Back Accepted' || strSelectedVal == 'Charge Back Loss' || strSelectedVal == 'Check' || strSelectedVal == 'Wire Transfer' || strSelectedVal == 'ACH' || strSelectedVal == 'Alipay' || strSelectedVal == 'Wechatpay') {
        	tr.ChargentOrders__Amount__c = dAmount*-1;    
        }
        
       
        
        insert tr;
        PageReference pageRef = new PageReference('/'+trans.id);
        pageRef.setRedirect(true);
        return pageref;

    }

    public PageReference CancelTransaction()
    {
        
        PageReference pageRef = new PageReference('/'+trans.id);
        pageRef.setRedirect(true);
        return pageref;

    }
    
    
}