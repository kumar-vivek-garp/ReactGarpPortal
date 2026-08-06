public class Payment  {

    public String ObjectId      { get; set; }
    public String CardMonth     { get; set; }
    public String CardYear      { get; set; }
    public String PaymentMethod { get; set; }
    public String CardType      { get; set; }
    public String CardSecurity  { get; set; } 
    public String CardNumber    { get; set; }
    public Decimal ChargeAmount { get; set; }

    public Payment(String cardNumber, String cardSecurity, String cardMonth, String cardYear){

        this.CardNumber     = cardNumber.replaceAll('\\s', '');
        this.CardSecurity   = cardSecurity;
        this.CardMonth      = cardMonth;
        this.CardYear       = cardYear;

        this.PaymentMethod  = 'Credit Card';

        Pattern americanExpressPattern = Pattern.compile('^3[47][0-9]{13}$');
        Pattern dinerClubPattern = Pattern.compile('^3(?:0[0-5]|[68][0-9])[0-9]{11}$');
        Pattern visaPattern = Pattern.compile('^4[0-9]{12}(?:[0-9]{3})?$');
        Pattern masterCardPattern = Pattern.compile('^(?:5[1-5][0-9]{2}|222[1-9]|22[3-9][0-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}$');
        Pattern discoverPattern = Pattern.compile('^6(?:011|5[0-9]{2})[0-9]{12}$');        

        if(americanExpressPattern.matcher(this.CardNumber).matches()){
            this.CardType = 'AMEX';
        }else if(dinerClubPattern.matcher(this.CardNumber).matches()){
            this.CardType = 'DC';
        }else if(visaPattern.matcher(this.CardNumber).matches()){
            this.CardType = 'VISA';
        }else if(masterCardPattern.matcher(this.CardNumber).matches()){
            this.CardType = 'MC';
        }else if(discoverPattern.matcher(this.CardNumber).matches()){
            this.CardType = 'DS';
        }
        
        System.debug(this);

    }

     // ChargentSFA changed to ChargentOrders
    public ChargentOrders.TChargentOperations.TChargentResult charge(Id opportunityId){

        Opportunity opportunity = [
            SELECT Id,Amount,Payment_Method__c,
            (Select Id,ChargentOrders__Transaction_Total__c from Chargent_Orders__r)
            FROM Opportunity 
            WHERE Id = :opportunityId
        ];

        this.ObjectId = opportunity.Chargent_Orders__r[0].Id;

        Decimal amount = opportunity.Amount - opportunity.Chargent_Orders__r[0].ChargentOrders__Transaction_Total__c;

        this.ChargeAmount = amount.setScale(2);
        
        String jsonString = JSON.serialize(this);

        Default_Settings__c enableChargentBackup = Default_Settings__c.getValues('EnableChargentBackup');
        
         ChargentOrders.TChargentOperations.TChargentResult result = null;

       /* if(System.Test.isRunningTest() && enableChargentBackup == null){
            Type t = Type.forName('ChargentOrders.TChargentOperations.TChargentResult'); 
            result = (ChargentOrders.TChargentOperations.TChargentResult)t.newInstance(); 
            result.Message = 'Approved';
        }else if(System.Test.isRunningTest() && enableChargentBackup != null && !enableChargentBackup.Active__c){   
            Type t = Type.forName('ChargentOrders.TChargentOperations.TChargentResult'); 
            result = (ChargentOrders.TChargentOperations.TChargentResult)t.newInstance(); 
            result.Message = 'Approved';
        }else */
		if(!System.Test.isRunningTest() && enableChargentBackup != null && enableChargentBackup.Active__c){
            Type t = Type.forName('ChargentOrders.TChargentOperations.TChargentResult'); 
            result = (ChargentOrders.TChargentOperations.TChargentResult)t.newInstance(); 
            result.Message = ChargentBackup.paypalcallout(
                this.ObjectId,
                this.CardMonth,
                this.CardYear,
                this.CardType,
                this.CardNumber,
                this.CardSecurity,
                this.ChargeAmount
            );
        }else if(!System.Test.isRunningTest()){
            result = ChargentOrders.TChargentOperations.ChargeOrder_ClickJSON(jsonString);
        }

        System.debug(this);
        
        System.debug(result);

        return result;      
        
    }
    
    
    public class TChargentResult {
    public Boolean Success;
    public String Message;
    public String ErrorCode;
    public String TransactionID;

    // Public constructor
    public TChargentResult() {}
}

}