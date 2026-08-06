/*  Apex Controller for Opportunity "Download Invoce" button
 *  02/15/2019 Xiang - [US-17765] Added redirect logic for handling Institutional Sale master Invoice
 *  05/14/2019 Xiang - [US-21939] Replaced Invoice number field for master order
 */
global without sharing class InvoiceAsPDFController{
    
    private static final String LONG_TIME_FORMAT = 'EEEE, MMMM d, yyyy h:mm a';
    private static final String SHORT_TIME_FORMAT = 'EEEE, MMMM d yyyy';
    private static final String SYS_DATE_FORMAT = 'MM/dd/yyyy h:mm a';
    
    @TestVisible private static final String IND_GL = '4040';
    @TestVisible private static final String NOV_EXAM_REG_GL = '4002';
    @TestVisible private static final String MAY_EXAM_REG_GL = '4001';
    @TestVisible private static final String JUL_EXAM_REG_GL = '4007';
    @TestVisible private static final String DEC_EXAM_REG_GL = '4012';
    @TestVisible private static final String APR_EXAM_REG_GL = '4004';
    @TestVisible private static final String AUG_EXAM_REG_GL = '4008';
    @TestVisible private static final String OCT_EXAM_REG_GL = '4011';
        
    @TestVisible private static final String FBR_GL = '4000';
    @TestVisible private static final String PAY_DEFERRED_GL = '6110';
    @TestVisible private static final String FRM_PARCTICE_1_PROD_CODE = 'FRMC1';
    @TestVisible private static final String FRM_PARCTICE_2_PROD_CODE = 'FRMC2';
    @TestVisible private static final String ERP_PARCTICE_1_PROD_CODE = 'ENCC1';
    @TestVisible private static final String ERP_PARCTICE_2_PROD_CODE = 'ENCC2';
    @TestVisible private static final List<String> BooksProductList = new List<String>{'RAIH','SCRH','FRM2H','FRM1H','FRMBP2'};
    @TestVisible private static Date dec25 = Date.newInstance(2025, 12, 1);
    global Id oppId {get;set;} 
    global String status {get;set;}
    global string type {get;set;}
    global string displayPayType {get;set;}
    global string msg {get;set;}
    global Boolean isPaid {get;set;}

    global Boolean hasNoWeightProducts {get;set;}
    global Boolean hasElectronicDelivery {get;set;}
    
    global OpportunityWrapper oppty {get;set;}
    global ExamAttemptWrapper exam {get; set;}
    global ExamAttemptWrapper Otherexam {get; set;}
    global List<LineItemWrapper> lineItems {get; set;}
    global List<LineItemWrapper> taxLineItems {get; set;}
    
    global Decimal subTotal {get; set;}
    global Boolean renderSubTotal {get; set;}
    
    global List<PaymentWrapper> payments {get; set;}
    global List<String> specialNotes {get; set;}
    
    global EventRegWrapper eventInfo {get; set;}
        
    global ChaptMeetingRegWrapper chaptMeetReg {get; set;}
    
    global Boolean Practice {get;set;}
    global Boolean refundBooks {get;set;}
	global String refundMessage {get;set;}
    global Boolean FRM1 {get;set;}
    global Boolean FRM2 {get;set;}


    global Boolean FRM {get;set;}
    global Boolean ERP {get;set;}
    global Boolean SCR {get;set;}
    global Boolean RAI {get;set;}
    global Boolean RAIJ {get;set;}
    global Boolean ICBRR {get;set;}
    global Boolean FBR {get;set;}
    global Boolean ChaptMeeting {get;set;}
    global Boolean Membership {get; set;}    
    global Boolean MembershipAutoRenew {get; set;}    
    global Boolean Wire  {get;set;}
    global Boolean Check {get;set;}
    global Boolean CreditByFax {get;set;}
    global Boolean CC {get;set;}
    global Boolean ACH  {get;set;}
    global Decimal OrderNet {get;set;}
   
    global Boolean FBRA {get;set;}
    
    global Boolean Event {get;set;}
   
    global String examRegistrationType{get;set;}
    global String examAdminType {get;set;}
    global String invoiceType {get;set;}
    global Boolean showSpecialNotes {get;set;}
    
    global Boolean isBeyond2023 {get;set;}    
 	global String StripePaymentMessage {get;set;}
    global Boolean isIGST {get;set;}  
    global Decimal taxableValue {get; set;}
   global InvoiceAsPDFController() {
     StripePaymentMessage = '';
     status = 'Unpaid';
     isPaid = false;
     type = ''; 
     
     msg='hi';
       
     FRM = false;
     FRM1 = false;
     FRM2 = false;
     ERP= false;
     ICBRR = false;
     FBR = false;
     SCR = false;
     RAI = false; 
     RAIJ = false;
     Membership = false;
     MembershipAutoRenew = false;
       
     Wire = false;
     Check = false;
     CreditByFax = false;
     ACH = false;
     CC = true;  
     OrderNet = 0;
     FBRA = false;
     Event = false;
     ChaptMeeting = false;
     showSpecialNotes = false;
       
     specialNotes = new List<String>();
   }
   
   global String getNow() {
       return System.now().format(SYS_DATE_FORMAT);
   }
 
   global PageReference fetchData() {
   	   refundMessage = 'There are no refunds given under any circumstances.';
       isIGST = false; 
       //Get opportunity data
       oppId = ApexPages.currentPage().getParameters().get('id');
       // Removed ChargentSFA prefix
       Opportunity rawOpp = [Select id, Company__c, StageName, CloseDate, Additional_Invoice_Information__c, EA_Id__c, Undefred_EA_Id__c, Alternate_Method_of_Payment__c, Payment_Method__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Company__c, 
                Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c,Payment_Method_New__c,
                Billing_Phone__c, Billing_Email__c, Shipping_First_Name__c, Shipping_State__c, Shipping_Postal_Code__c,Shipping_Last_Name__c, 
                Shipping_Phone_No__c, Shipping_Company_Name__c, Shipping_Country__c, Display_Invoice_Number__c,Product_Name__c, Shipping_City__c,
                Institutional_Sale__c, Inst_Sale_Opp__c, Inst_Sale_Opp__r.StageName, Inst_Sale_Opp__r.Billing_Company__c, Inst_Sale_Opp__r.CloseDate, Inst_Sale_Opp__r.Display_Invoice_Number__c, Inst_Sale_Opp__r.Inst_Sale_Display_Invoice_Number__c, 
                Shipping_Street__c, Shipping_E_mail__c, Charge_Amount__c, Amount, GARP_Member_ID__c, CreatedDate, LEGACY_Purchase_Date__c, Program_Name__c, Program_Abbrev__c,
                Team_Registration__c, Team_Registration__r.Manual_Invoice_Number__c, Team_Registration__r.Manual_Invoice_Payment_Date__c, Team_Registration__r.Account__r.Name,
                Team_Registration__r.Is_Scholarship__c,  Team_Registration__r.Discounted_Price__c, 
                B2B_Deal_Item__c, B2B_Deal_Item__r.B2B_Deal__r.Manual_Invoice_Number__c, B2B_Deal_Item__r.B2B_Deal__r.Manual_Invoice_Payment_Date__c, B2B_Deal_Item__r.B2B_Deal__r.Account__r.Name,
                B2B_Deal_Item__r.Is_Scholarship__c, B2B_Deal_Item__r.Discounted_Price__c,B2B_Deal_Item__r.RecordType.Name,
                ia_crm__Intacct_Transaction__c, Auto_Renew__c
                FROM Opportunity
                WHERE id= :oppId and StageName != 'Recurring Intent'];
       
       for(ChargentOrders__Transaction__c ct:[Select Id,StripePresentmentAmount__c,StripePresentmentCurrency__c,ChargentOrders__Amount__c From ChargentOrders__Transaction__c Where Opportunity__c =:oppId and ChargentOrders__Response_Status__c = 'Approved' and StripePresentmentAmount__c != null and StripePresentmentCurrency__c != null Order BY CreatedDate Desc limit 1]){
           Decimal tamout = (ct.StripePresentmentAmount__c/100);

            tamout = (tamout / ct.ChargentOrders__Amount__c).setScale(4);
 
           String stamount = (ct.StripePresentmentAmount__c/100).setScale(2,RoundingMode.HALF_UP).format();

           // Split integer and decimal parts
           List<String> parts = stAmount.split('\\.');
           
           // If there’s no decimal part, add ".00"
           if (parts.size() == 1) {
               stAmount += '.00';
           } else if (parts[1].length() == 1) {
               // If decimal part has only 1 digit, append a 0
               stAmount += '0';
           }
 
           StripePaymentMessage = 'Charged '+stamount+' '+ct.StripePresentmentCurrency__c.toUpperCase()+' using 1 USD = '+tamout+' '+ ct.StripePresentmentCurrency__c.toUpperCase();
       }
       
       // [US-17765] Handle Master Invoice in a seperate visualforce page
       if(rawOpp.Institutional_Sale__c == true && rawOpp.Inst_Sale_Opp__c == null) {
            PageReference pageRef = new PageReference('/apex/InstitutionalSalesInvoice?id=' + rawOpp.Id);
            pageRef.setRedirect(true);
            
            return pageRef;
       }
       
       isBeyond2023 = False;
       Integer thisYear = Date.Today().Year();
       if(thisYear >= 2023) {
           isBeyond2023 = True;
       }
                
       oppty = new OpportunityWrapper(rawOpp);
       //system.debug('Exam?:' + oppty.examAttemptId);
       
       if(oppty.sageTransactionType == 'Salesforce - Switch'){
           invoiceType = 'Debit/ Credit Note:';
       }else if(oppty.sageTransactionType == 'Salesforce - Refund'){
           invoiceType = 'Credit Note:';
       }else{
           invoiceType = 'Invoice #:';
       }
       
       if(rawOpp.Auto_Renew__c) {
           MembershipAutoRenew = True;
       }
       
       if(rawOpp.CloseDate >= dec25){
       		refundMessage = 'Candidates have 48 hours after their exam registration to submit a refund request. Exam registrations are non-transferable.';
       }
       
       //system.debug('Event Oppty:' + oppty);
       
       //Get exam data 
       list<Exam_Attempt__c> ea = [Select id, Section__c, Exam_Site__r.Country__c,Exam_Site__r.Exam__r.Exam__c, Exam_Site__r.Name, Exam_Site__r.Site__r.Name, Original_Exam_Site__c, Exam_Date__c, Opportunity__r.Id, RPT_Administration_Year__c, RPT_Administration_Month__c, Original_Exam_Administration__r.Month__c, Original_Exam_Administration__r.Year__c, RPT_Exam_Program__c, RPT_Exam_Part__c from  Exam_Attempt__c where (Opportunity__r.Id = :oppID OR Id = :oppty.deferExamAttemptId OR Id = :oppty.undeferExamAttemptId) and Exam_Site__r.Exam__r.Exam__c <> 'ICBRR' Order By Exam_Date__c ASC];
       list<Exam_Attempt__c> eaCloned = [Select id, Section__c, Exam_Site__r.Country__c,Exam_Site__r.Exam__r.Exam__c, Exam_Site__r.Name, Exam_Site__r.Site__r.Name, Original_Exam_Site__c, Exam_Date__c, Opportunity__r.Id, RPT_Administration_Year__c, RPT_Administration_Month__c, Original_Exam_Administration__r.Month__c, Original_Exam_Administration__r.Year__c, RPT_Exam_Program__c, RPT_Exam_Part__c from  Exam_Attempt__c where Cloned_From__c in :ea Order By Exam_Date__c ASC];
       list<Exam_Attempt__c> eaAll = new list<Exam_Attempt__c>();
       
       eaAll.addAll(ea);
       eaAll.addAll(eaCloned);
       
       Exam_Attempt__c lastEA = null;
       Exam_Attempt__c otherEA = null;       
       if (!eaAll.isEmpty() && eaAll.size() > 0) {
       
           for(Exam_Attempt__c e :eaAll ) {
               if(lastEA == null) {
                   lastEA = e;
               } else if(otherEA == null) {
                   otherEA = e;
               }
           }
           exam = new ExamAttemptWrapper(lastEA);
           if(otherEA != NULL) {
               otherExam = new ExamAttemptWrapper(otherEA );
           }
       }

        //system.debug('lastEA:' + lastEA );
        //system.debug('otherEA:' + otherEA );

        //system.debug('Exam?:' + exam);
        
        
       //Get event data
       Map<Id,Id> mapEventtoReg = new Map<Id,Id>();
       
       list<Event_Registration__c> eventregs = [
           SELECT Id, Name, Event_Registration_Date__c, CreatedDate, Contact__c, Event__c, Event__r.Online_Meeting_URL__c, Event__r.Online_Meeting_Notes__c, Event__r.ON24_Event_Id__c, Event__r.Name, Event__r.Event_Date__c, Event__r.Cancellation_Policy__c, Event__r.Payment_Policy__c, RPT_Event_Location__c, Event__r.Last_Date_for_Wire_Check_Registration__c, Event__r.Event_Cancellation_Days__c, Event__r.Event_Cancellation_Date__c, Last_Date_For_Rate_Effectiveness__c, Event__r.Start_Date__c, Event__r.Grace_Period__c, Status__c, Opportunity__r.Id, Member_Email__c, Substitute_Attendant__c, Event_Paid_Date__c, RPT_Event_Date__c 
           FROM Event_Registration__c 
           WHERE Opportunity__r.Id = :oppID
       ];
       //system.debug('eventregs:' + eventregs);
       
       if(!eventregs.IsEmpty()) {
           Event = True;
           Event_Registration__c eventReg = eventregs[0];
           Date regDate = Date.ValueOf(eventReg.CreatedDate);
           if(eventReg.Event_Registration_Date__c != NULL) {
               regDate = Date.ValueOf(eventReg.Event_Registration_Date__c);
           }
           List<Event_Rate__c> lstRates = [select Id, Start_Date__c, End_Date__c, Type__c, Alternate_Payment_Deadline__c from Event_Rate__c where Start_Date__c <= :regDate AND End_Date__c >= :regDate AND Event__c = :eventReg.Event__c];
          // system.debug('lstRates:' + lstRates);
           
           if(!lstRates.IsEmpty()) {
               Event_Rate__c eventRate = lstRates[0];
               eventInfo = new EventRegWrapper(eventReg, eventRate);
           }
       }
       
       /*
       system.debug('Event:' + eventregs);
       if (!eventregs.isEmpty() && eventregs.size() > 0) {
           
           for(Event_Registration__c ev :eventregs ) {
               EventRegWrapper eventcancel = new EventRegWrapper(ev);  
               
               eventLstWrapper.add(eventcancel);
               mapEventtoReg.put(ev.Event__c, ev.Id);
           } 
           
       }
       */
       
       list<Chapter_Meeting_Registration__c> lstCMR = [select id, name, Chapter_Meeting__r.ON24_Event_Id__c, Chapter_Meeting__r.Payment_Policy__c, Chapter_Meeting__r.Cancellation_Policy__c from Chapter_Meeting_Registration__c where Opportunity__c = :oppId];
       //system.debug('lstCMR:'+ lstCMR);
       if(lstCMR != null && lstCMR.size() > 0) {
           chaptMeetReg = new ChaptMeetingRegWrapper(lstCMR[0]);
           ChaptMeeting = true;
           //system.debug('chaptMeetReg:' +chaptMeetReg);
       }

              
       Decimal total = oppty.Amount;
       String payType = '';
       
       if(oppty.ampMethod != null) {
           type = oppty.ampMethod;
           displayPayType = type;
           if(displayPayType.containsIgnoreCase('cc')) {
               displayPayType = 'Credit Card';
           } else if(displayPayType.containsIgnoreCase('wire')) {
               displayPayType = 'Wire Transfer';
           } else if(displayPayType.containsIgnoreCase('check')) {
               displayPayType = 'Check';
           } else if(displayPayType.containsIgnoreCase('ach')) {
               displayPayType = 'ACH';
           } else if(displayPayType.containsIgnoreCase('alipay')) {
               displayPayType = 'Alipay';
           } else if(displayPayType.containsIgnoreCase('wechat')) {
               displayPayType = 'Wechatpay';
           }
       }
        
       
      
       //Get payment data
       payments = new List<PaymentWrapper>();
       // replaced ChargentSFA with ChargentOrders
       List<ChargentOrders__Transaction__c> transactions =  [Select id ,Name, ChargentOrders__Amount__c, Opportunity__r.CloseDate , Opportunity__c,Opportunity__r.GARP_Member_ID__c,
              Opportunity__r.StageName , ChargentOrders__Type__c, ChargentOrders__Payment_Method__c, ChargentOrders__Response_Status__c, ChargentOrders__Gateway_Date__c, ChargentOrders__Reason_Text__c, Fee__c,Accounting_Notes__c,CreatedDate
              FROM ChargentOrders__Transaction__c  where ChargentOrders__Amount__c!= NULL and Opportunity__c = :oppId and Opportunity__r.StageName != 'Recurring Intent' AND ((ChargentOrders__Type__c = 'Void' OR ChargentOrders__Type__c = 'Debit' OR ChargentOrders__Type__c = 'Charge' OR ChargentOrders__Type__c = 'Credit' or ChargentOrders__Type__c = 'Refund' or ChargentOrders__Type__c = 'Charge Back Accepted' or ChargentOrders__Type__c = 'Charge Back Loss') AND (ChargentOrders__Response_Status__c = 'Approved' OR ChargentOrders__Response_Status__c = '' OR ChargentOrders__Response_Status__c = NULL)) ORDER BY ChargentOrders__Gateway_Date__c ASC];
       
       List<ID> ids = new List<ID>();
       for (ChargentOrders__Transaction__c payment :transactions){
           ids.add(payment.Id);
       }
       List<Product_Refunds__c> prf = [select Id, Name, Payment_Order_Transaction__c, Reason__c, Show_Reason__c from Product_Refunds__c where Payment_Order_Transaction__c in :ids];
       
       Map<ID,Product_Refunds__c> mapReason = new Map<ID,Product_Refunds__c>();
       for (Product_Refunds__c pr :prf){
           mapReason.put(pr.Payment_Order_Transaction__c, pr);
       }
       
       date tempDate = date.newInstance(2022, 1, 1);
       for (ChargentOrders__Transaction__c payment :transactions){
           
           Product_Refunds__c fndPR = mapReason.get(payment.Id);
           String reason = '';
           Boolean show = false;
           //if(fndPR != null) {
           //    if(fndPR.Reason__c != null)
           //        reason = fndPR.Reason__c;
           //    if(fndPR.Show_Reason__c != null)
           //        show = fndPR.Show_Reason__c;               
           //}
           payments.add(new PaymentWrapper(payment, reason, show));

           //system.debug('pay?:' + payment);
           
           
           if (payment.ChargentOrders__Type__c!=null && payment.ChargentOrders__Amount__c!=null) {
               if(payment.ChargentOrders__Type__c == 'Charge' || payment.ChargentOrders__Type__c == 'Credit' || payment.ChargentOrders__Type__c == 'Debit' || payment.ChargentOrders__Type__c=='Refund' || payment.ChargentOrders__Type__c=='Charge Back Accepted' || payment.ChargentOrders__Type__c=='Charge Back Loss' || payment.ChargentOrders__Type__c=='Void') {
                   
                   //system.debug('pay:' + payment.ChargentOrders__Amount__c);
                   
                   if(oppty.sageTransactionType == 'Salesforce - Refund'){
                       OrderNet+=payment.ChargentOrders__Amount__c * -1;
                   }else{
                       OrderNet+=payment.ChargentOrders__Amount__c;
                   }
                   //OrderNet+=payment.ChargentSFA__Amount__c;
                   if(payment.Fee__c != null) {
                       OrderNet+=(payment.Fee__c * -1);
                   }
                   
                   if(payment.ChargentOrders__Payment_Method__c!=null) {
                       if(payment.ChargentOrders__Payment_Method__c == 'Credit Card' || payment.ChargentOrders__Payment_Method__c == 'Alipay' || payment.ChargentOrders__Payment_Method__c == 'Wechatpay') {
                           CC=true;
                           Wire=false;
                           Check=false;
                           CreditByFax=false; 
                           ACH=false;
                       }
                   }
                   if(payment.ChargentOrders__Type__c == 'Charge' ) {
                       
                       //system.debug('Charge:' + payment.ChargentOrders__Type__c);
                       
                       if (payType == null || payType == '') {
                           payType = payment.ChargentOrders__Payment_Method__c;
                       } else if (payment.ChargentOrders__Payment_Method__c != null && payment.ChargentOrders__Payment_Method__c != '') {
                           if (!payType.containsIgnoreCase(payment.ChargentOrders__Payment_Method__c)) {
                               payType = payType + ', ' + payment.ChargentOrders__Payment_Method__c;
                           }
                       }
                   }
                   
                   if(String.isNotBlank(payment.Accounting_Notes__c) && payment.CreatedDate >= tempDate &&
                      (payment.ChargentOrders__Type__c == 'Charge Back Loss' || payment.ChargentOrders__Type__c == 'Charge Back Accepted'
                       || payment.ChargentOrders__Payment_Method__c == 'Wire Transfer' || payment.ChargentOrders__Payment_Method__c == 'Check' 
                       || payment.ChargentOrders__Payment_Method__c == 'Credit Card by Fax' || payment.ChargentOrders__Payment_Method__c == 'ACH')){
                       specialNotes.add(payment.Accounting_Notes__c);
                       showSpecialNotes = true;
                   }
               }          
           }   
       }
       
       if(transactions.isEmpty()){
           List<Legacy_Transaction__c> transactionsOld =  [Select id ,Name, Amount__c, Opportunity__r.CloseDate , Opportunity__c,Opportunity__r.GARP_Member_ID__c,
                                                              Opportunity__r.StageName , Type__c, Payment_Method__c, Response_Status__c, Gateway_Date__c, Reason_Text__c, Fee__c,Accounting_Notes__c,CreatedDate
                                                              FROM Legacy_Transaction__c  where Amount__c!= NULL and Opportunity__c = :oppId and Opportunity__r.StageName != 'Recurring Intent' AND ((Type__c = 'Void' OR Type__c = 'Debit' OR Type__c = 'Charge' OR Type__c = 'Credit' or Type__c = 'Refund' or Type__c = 'Charge Back Accepted' or Type__c = 'Charge Back Loss') AND (Response_Status__c = 'Approved' OR Response_Status__c = '' OR Response_Status__c = NULL)) ORDER BY Gateway_Date__c ASC];
           
           List<ID> idsOld = new List<ID>();
           for (Legacy_Transaction__c payment :transactionsOld){
               idsOld.add(payment.Id);
           }
           List<Product_Refunds__c> prfOld = [select Id, Name, Legacy_Transaction__c, Reason__c, Show_Reason__c from Product_Refunds__c where Legacy_Transaction__c in :idsOld];
           
           Map<ID,Product_Refunds__c> mapReasonOld = new Map<ID,Product_Refunds__c>();
           for (Product_Refunds__c pr :prf){
               mapReasonOld.put(pr.Legacy_Transaction__c, pr);
           }
           
           date tempDateOld = date.newInstance(2022, 1, 1);
           for (Legacy_Transaction__c payment :transactionsOld){
               
               Product_Refunds__c fndPR = mapReason.get(payment.Id);
               String reason = '';
               Boolean show = false;
               //if(fndPR != null) {
               //    if(fndPR.Reason__c != null)
               //        reason = fndPR.Reason__c;
               //    if(fndPR.Show_Reason__c != null)
               //        show = fndPR.Show_Reason__c;               
               //}
               payments.add(new PaymentWrapper(payment, reason, show));
               
               //system.debug('pay?:' + payment);
               
               
               if (payment.Type__c!=null && payment.Amount__c!=null) {
                   if(payment.Type__c == 'Charge' || payment.Type__c == 'Credit' || payment.Type__c == 'Debit' || payment.Type__c=='Refund' || payment.Type__c=='Charge Back Accepted' || payment.Type__c=='Charge Back Loss' || payment.Type__c=='Void') {
                       
                       //system.debug('pay:' + payment.Amount__c);
                       
                       if(oppty.sageTransactionType == 'Salesforce - Refund'){
                           OrderNet+=payment.Amount__c * -1;
                       }else{
                           OrderNet+=payment.Amount__c;
                       }
                       //OrderNet+=payment.ChargentSFA__Amount__c;
                       if(payment.Fee__c != null) {
                           OrderNet+=(payment.Fee__c * -1);
                       }
                       
                       if(payment.Payment_Method__c!=null) {
                           if(payment.Payment_Method__c == 'Credit Card' || payment.Payment_Method__c == 'Alipay' || payment.Payment_Method__c == 'Wechatpay') {
                               CC=true;
                               Wire=false;
                               Check=false;
                               CreditByFax=false;   
                               ACH=false;
                           }
                       }
                       if(payment.Type__c == 'Charge' ) {
                           
                           //system.debug('Charge:' + payment.Type__c);
                           
                           if (payType == null || payType == '') {
                               payType = payment.Payment_Method__c;
                           } else if (payment.Payment_Method__c != null && payment.Payment_Method__c != '') {
                               if (!payType.containsIgnoreCase(payment.Payment_Method__c)) {
                                   payType = payType + ', ' + payment.Payment_Method__c;
                               }
                           }
                       }
                       
                       if(String.isNotBlank(payment.Accounting_Notes__c) && payment.CreatedDate >= tempDate &&
                          (payment.Type__c == 'Charge Back Loss' || payment.Type__c == 'Charge Back Accepted'
                           || payment.Payment_Method__c == 'Wire Transfer' || payment.Payment_Method__c == 'Check' 
                           || payment.Payment_Method__c == 'Credit Card by Fax' || payment.Payment_Method__c == 'ACH')){
                               specialNotes.add(payment.Accounting_Notes__c);
                               showSpecialNotes = true;
                           }
                   }          
               }   
           }
       }
       
       //system.debug('payments:' + payments);
       
       if(payType != NULL && payType != '')
           type = payType;
       
       if(type.containsIgnoreCase('wire')) {
           CC=false;
           Wire=true;
       } else if(type.containsIgnoreCase('check')) {
           CC=false;
           Check=true;
       } else if(type.containsIgnoreCase('ach')) {
           CC=false;
           ACH=true;           
       } else if(type.containsIgnoreCase('fax')) {
           CC=false;
           CreditByFax=true;
       } else if(oppty != null && oppty.chrgAmpMethod != null && oppty.chrgAmpMethod.containsIgnoreCase('wire')) {              
           CC=false;
           Wire=true;
       }
       
       if(oppty.instSale && oppty.instStageName == 'Closed') {
           status = 'Paid'; 
           isPaid = true;                      
       } else if(!oppty.instSale && oppty.stage == 'Closed') {
           status = 'Paid'; 
           isPaid = true;           
       }
       
       //if (total != null && countTotal > 0 && countTotal >= total) {
       //    status = 'Paid'; 
       //    isPaid = true;
       //}  else if(total != null && countTotal > 0 && countTotal < total) {
       //    status = 'Partially Paid'; 
       //    isPaid = true;
       //}
                      
       //Get line item data                 
       lineItems = new List<LineItemWrapper>();
       taxLineItems= new List<LineItemWrapper>();      
       subTotal = 0;
       taxableValue = 0;
       for(OpportunityLineItem oProd : [Select Product2.Name, Exam_Date__c, Product2.ProductCode, Product2.GL_Code__c, Product2.Weight__c, Product2.Electronic_Delivery__c, UnitPrice, OpportunityId, Description, TotalPrice, Quantity,Product2.HSN_Code__c,Product2.Do_Not_Charge_VAT_Countries__c from OpportunityLineItem where OpportunityId=:oppID AND Do_Not_SHow_On_Invoice__c = false order by Product2.Calc_Sort_Order__c DESC, TotalPrice DESC, Product2.Name DESC] ) {
    
           LineItemWrapper lineItem  = new LineItemWrapper(oProd, oppty);
           if(oProd.Product2.ProductCode == 'GSTTAX' || oProd.Product2.ProductCode == 'SLSTX' || oProd.Product2.ProductCode =='IGSTTAX') {
               if(oProd.Product2.ProductCode =='IGSTTAX'){
                  isIGST = true;  
               } 
               taxLineItems.add(lineItem);
            } else {
                lineItems.add(lineItem);
                subTotal += lineItem.totalPrice;
                if(oProd.Product2.Do_Not_Charge_VAT_Countries__c == null){
                    taxableValue += lineItem.totalPrice;
                }
                
            }
    
             if(oProd.Product2.Electronic_Delivery__c)
                 hasElectronicDelivery = true;
    
           String prodName = oProd.Product2.Name; 
           String description = oProd.Description;
           Decimal totAmt = oProd.UnitPrice;
           String prodCode = oProd.Product2.ProductCode;
           String GLCode = oProd.Product2.GL_Code__c; 
           Decimal weight = oProd.Product2.Weight__c;
           
           Date examDate = oProd.Exam_Date__c;
           
           //system.debug('GLCode:' + GLCode);
           
           if(weight == 0)
               hasNoWeightProducts=true;
           
           	
           if(BooksProductList.contains(prodCode)){
               refundBooks = true; 
           } 
           
           if (GLCode !=null && prodCode != null) {
                   if (GLCode == IND_GL) {
                   Membership = true;
               } 
               if (GLCODE == AUG_EXAM_REG_GL || GLCode == NOV_EXAM_REG_GL || GLCode == MAY_EXAM_REG_GL || GLCode == JUL_EXAM_REG_GL || GLCode == DEC_EXAM_REG_GL || GLCode == APR_EXAM_REG_GL || GLCode == OCT_EXAM_REG_GL) {
                   if (prodCode.containsIgnoreCase('frm')) {
                       FRM=true; 
                   }
                   if (prodCode.containsIgnoreCase('frm1')) {
                       FRM1=true; 
                   }
                   if (prodCode.containsIgnoreCase('frm2')) {
                       FRM2=true; 
                   }
                   
                   if (prodCode.containsIgnoreCase('enc')) {
                       ERP=true; 
                   }
                   if (prodCode.containsIgnoreCase('scr')) {
                       SCR=true; 
                   }
                   if (prodCode.containsIgnoreCase('raij')) {
                       RAIJ=true; 
                   }
                   if (prodCode.containsIgnoreCase('rai')) {
                       RAI=true; 
                   }
                   
                   examRegistrationType = getExamType(prodCode);
                   if(GLCode == MAY_EXAM_REG_GL) {
                       examAdminType = 'MAY';
                   } else if(GLCode == JUL_EXAM_REG_GL) {
                       examAdminType = 'JUL';
                   } else if(GLCode == NOV_EXAM_REG_GL) {
                       examAdminType = 'NOV';
                   } else if(GLCode == DEC_EXAM_REG_GL) {
                       examAdminType = 'DEC';
                   } else if(GLCode == APR_EXAM_REG_GL) {
                       examAdminType = 'APR';
                   } else if(GLCode == AUG_EXAM_REG_GL) {
                       examAdminType = 'AUG';
                   }else if(GLCode == OCT_EXAM_REG_GL) {
                       examAdminType = 'OCT';
                   }
               }
               
               else if (GLCode == FBR_GL) {
                   if (prodCode.startsWithIgnoreCase('cbr')) {
                       ICBRR=true; 
                   }
                   if (prodCode =='FBRA') {
                       FBRA=true; 
                   }
                   else if (prodCode.containsIgnoreCase('fcbr') || prodCode.containsIgnoreCase('fbr')) {
                       FBR=true; 
                   }
               }
               else if(prodCode == FRM_PARCTICE_1_PROD_CODE || prodCode == FRM_PARCTICE_2_PROD_CODE || prodCode == ERP_PARCTICE_1_PROD_CODE || prodCode == ERP_PARCTICE_2_PROD_CODE) {
                   Practice = True;
               }
               else if (eventInfo != NULL) {
                   Event = true;
               }
           } else {
               if (prodName != null) {
                   if (prodName.containsIgnoreCase('exam') && prodName.containsIgnoreCase('erp'))
                       ERP=true; 
                   if (prodName.containsIgnoreCase('exam') && prodName.containsIgnoreCase('frm'))
                       FRM=true;
                   if (prodName.containsIgnoreCase('exam') && prodName.containsIgnoreCase('scr'))
                       SCR=true; 
                   if (prodName.containsIgnoreCase('exam') && prodName.containsIgnoreCase('raij'))
                       RAIJ=true;
                   if (prodName.containsIgnoreCase('exam') && prodName.containsIgnoreCase('rai'))
                       RAI=true; 
                   if (prodName.containsIgnoreCase('icbrr'))
                       ICBRR=true; 
                   if (prodName.containsIgnoreCase('wire'))
                       Wire=true; 
                   if (prodName.containsIgnoreCase('ach'))
                       ACH=true; 
                   if (prodName.containsIgnoreCase('check') || prodName.containsIgnoreCase('fax'))
                       CreditByFax=true; 
                   If(prodName.containsIgnoreCase('practice'))
                       Practice = True;
               }          
           }         
       }
       if(refundBooks == true && rawOpp.CloseDate >= dec25){
           refundMessage += ' Both GARP Learning and printed books are non-refundable.';
       }
       //lineItems.sort();
       if(subTotal != oppty.amount) {
           renderSubTotal = True;
       }
       
       if(otherEA != NULL && (FRM1==False || FRM2==False)) {
           otherExam = NULL;
       }
       
       return null;
     }
     
     global class OpportunityWrapper {
         global String id {get; set;}
         global String company {get; set;}
         global String stage {get; set;}
         global String ampMethod {get;set;}
         global String deferExamAttemptId {get;set;}    
         global String undeferExamAttemptId {get;set;}             
         global String chrgAmpMethod {get;set;}
         global String chargentSFAPaymentMethod {get;set;}
         global String chargentSFABillingFirst {get; set;}
         global String chargentSFABillingLast {get; set;}
         global String chargentSFABillingCompany {get; set;}
         global String chargentSFABillingAddress {get; set;}
         global String chargentSFABillingCity {get; set;}
         global String chargentSFABillingState {get; set;}
         global String chargentSFABillingZip {get; set;}
         global String chargentSFABillingCountry {get; set;}
         global String chargentSFABillingPhone {get; set;}
         global String chargentSFABillingEmail {get; set;}
         global String shippingFirstName {get; set;} 
         global String shippingState {get; set;}
         global String shippingPostalCode {get; set;}
         global String shippingLastName {get; set;}
         global String shippingPhoneNo {get; set;}
         global String shippingCompanyName {get; set;}
         global String shippingCountry {get; set;} 
         global String garpInvoiceNumber {get; set;}
         global String garpMemberId {get; set;}
         global String productName {get; set;}
         global String shippingCity {get; set;}
         global String shippingStreet {get; set;}
         global String shippingEmail {get; set;}
         global Decimal chargentSFAChargeAmount {get; set;}
         global Decimal amount {get; set;}
         global String createdDateFormatted {get; set;}
         global Boolean hasBillingAddress {get; set;}
         global Boolean hasShippingAddress {get; set;}
         
         global String additionalInfo {get; set;}

         global String programName {get; set;}
         global String programAbbrev {get; set;}
         global DateTime createdDate {get; set;}
         
         global Boolean instSale {get; set;}
         global String instCompany {get; set;}
         global String instStageName {get; set;}
         global String instCloseDate {get; set;}
         global String instInvoiceNumber {get; set;}
         
         global Boolean isTeamRegistration {get; set;}
         global Boolean isstudymat {get; set;}
         global String teamRegCompany {get; set;}
         global String teamRegInvoiceNumber {get; set;}
         global String teamRegPaidDate {get; set;}
         global String teamRegCloseDate {get; set;}
         global String sageTransactionType {get; set;}
         global String taxRegion {get; set;}    
         global OpportunityWrapper(Opportunity opp) {
             id = opp.id;
             company = opp.Company__c;  
             stage = opp.StageName;
             ampMethod = opp.Alternate_Method_of_Payment__c; 
             deferExamAttemptId = opp.EA_Id__c;
             undeferExamAttemptId = opp.Undefred_EA_Id__c;             
             chrgAmpMethod = opp.Payment_Method_New__c;
             chargentSFABillingFirst = opp.Billing_First_Name__c;
             chargentSFABillingLast = opp.Billing_Last_Name__c;
             chargentSFABillingCompany = opp.Billing_Company__c;
             chargentSFABillingAddress = opp.Billing_Address__c;
             chargentSFABillingCity = opp.Billing_City__c;
             chargentSFABillingState = opp.Billing_State_Text__c;
             chargentSFABillingZip = opp.Billing_Zip_Postal__c;
             chargentSFABillingCountry = opp.Billing_Country__c;
             chargentSFABillingPhone = opp.Billing_Phone__c;
             chargentSFABillingEmail = opp.Billing_Email__c;
             shippingFirstName = opp.Shipping_First_Name__c; 
             shippingLastName = opp.Shipping_Last_Name__c;
             shippingCompanyName = opp.Shipping_Company_Name__c;
             shippingStreet = opp.Shipping_Street__c;
             shippingCity = opp.Shipping_City__c;
             shippingState = opp.Shipping_State__c;
             shippingPostalCode = opp.Shipping_Postal_Code__c;
             shippingCountry = opp.Shipping_Country__c;
             shippingPhoneNo = opp.Shipping_Phone_No__c;
             shippingEmail = opp.Shipping_E_mail__c;             
             garpInvoiceNumber = opp.Display_Invoice_Number__c;
             garpMemberId = opp.GARP_Member_ID__c;
             productName = opp.Product_Name__c;           
             chargentSFAChargeAmount = opp.Charge_Amount__c;
             amount = opp.Amount;
             sageTransactionType = opp.ia_crm__Intacct_Transaction__c;

             additionalInfo = opp.Additional_Invoice_Information__c;
            
             programName = opp.Program_Name__c;
             programAbbrev = opp.Program_Abbrev__c;
             
             instSale = opp.Institutional_Sale__c;             
             taxRegion = opp.Billing_Country__c == 'India'?opp.Billing_Country__c +' - '+opp.Billing_State_Text__c:opp.Shipping_Country__c == 'India'?opp.Shipping_Country__c +' - '+opp.Shipping_State__c:'';
             if(opp.Inst_Sale_Opp__c != null) {
                 instCompany = opp.Inst_Sale_Opp__r.Billing_Company__c;
                 instStageName = opp.Inst_Sale_Opp__r.StageName;
                 instCloseDate = datetime.newInstance(opp.Inst_Sale_Opp__r.CloseDate.year(), opp.Inst_Sale_Opp__r.CloseDate.month(),opp.Inst_Sale_Opp__r.CloseDate.day()).format('MM/dd/yyyy');
                 // Xiang: Replaced Display_Invoice_Number__c with Inst_Sale_Display_Invoice_Number__c as Invoice format is different for Master Order
                 instInvoiceNumber = opp.Inst_Sale_Opp__r.Inst_Sale_Display_Invoice_Number__c;
             }
                        
             isTeamRegistration = False;
             isstudymat = False;
             if(opp.B2B_Deal_Item__c != NULL && opp.B2B_Deal_Item__r.RecordType.Name == 'Study Materials'){
                 isstudymat = True;
             }
             if(opp.B2B_Deal_Item__c != NULL && opp.B2B_Deal_Item__r.Is_Scholarship__c == False && opp.B2B_Deal_Item__r.Discounted_Price__c == Null && opp.B2B_Deal_Item__r.B2B_Deal__r.Manual_Invoice_Number__c != null) {
                 isTeamRegistration = True;
                 teamRegCompany = opp.B2B_Deal_Item__r.B2B_Deal__r.Account__r.Name;
                 teamRegInvoiceNumber = opp.B2B_Deal_Item__r.B2B_Deal__r.Manual_Invoice_Number__c;
                 teamRegPaidDate = datetime.newInstance(opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.year(), opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.month(), opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.day()).format('MMMM dd, yyyy');
                 teamRegCloseDate = datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format('MM/dd/yyyy');
             } else if(opp.B2B_Deal_Item__c == NULL && opp.Team_Registration__c != NULL && opp.Team_Registration__r.Is_Scholarship__c == False && opp.Team_Registration__r.Discounted_Price__c == Null && opp.Team_Registration__r.Manual_Invoice_Number__c != null) {
                 isTeamRegistration = True;
                 teamRegCompany = opp.Team_Registration__r.Account__r.Name;
                 teamRegInvoiceNumber = opp.Team_Registration__r.Manual_Invoice_Number__c;
                 teamRegPaidDate = datetime.newInstance(opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.year(), opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.month(), opp.Team_Registration__r.Manual_Invoice_Payment_Date__c.day()).format('MMMM dd, yyyy');
                 teamRegCloseDate = datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()).format('MM/dd/yyyy');
             }
             createdDate = opp.CreatedDate;
             
             if(opp.LEGACY_Purchase_Date__c != null){
                createdDateFormatted = opp.LEGACY_Purchase_Date__c.format(SHORT_TIME_FORMAT );
             }else if(sageTransactionType == 'Salesforce - Refund'){
                 datetime dt = Datetime.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day());
                 createdDateFormatted = dt.format(SHORT_TIME_FORMAT );
             }
             else {
                 createdDateFormatted = opp.CreatedDate.format(SHORT_TIME_FORMAT );
             }
   
             hasBillingAddress = opp.Billing_First_Name__c!=null||opp.Billing_Last_Name__c!=null||opp.Billing_Company__c!=null||
                                 opp.Billing_Address__c!=null||opp.Billing_City__c!=null||opp.Billing_Company__c!=null||
                                 opp.Billing_Zip_Postal__c!=null||opp.Billing_Country__c!=null||opp.Billing_Phone__c!=null||
                                 opp.Billing_Email__c!=null;
             hasShippingAddress = opp.Shipping_First_Name__c!=null||opp.Shipping_Last_Name__c!=null||opp.Shipping_Company_Name__c!=null||
                                 opp.Shipping_Street__c!=null||opp.Shipping_City__c!=null||opp.Shipping_State__c!=null||
                                 opp.Shipping_Postal_Code__c!=null||opp.Shipping_Country__c!=null||opp.Shipping_Phone_No__c!=null||
                                 opp.Shipping_E_mail__c!=null;
         }
     }
     
     global class ExamAttemptWrapper {
         
         global String examSiteName {get; set;}
         global String examDateFormatted {get; set;}
         global String examPart {get; set;}
         global Boolean isERP {get; set;}
         global Boolean isFRM {get; set;}
         global Boolean isSCR {get; set;}
         global Boolean isRAI {get; set;}
         global Boolean isRAIJ {get; set;}
         global ExamAttemptWrapper(Exam_Attempt__c ea) {
             if(ea.Original_Exam_Site__c != null){
                examSiteName = ea.Original_Exam_Site__c;
             }else if(ea.Exam_Site__r.Country__c != null){
                 examSiteName = ea.Exam_Site__r.Country__c;
             }
             
             if(ea.Original_Exam_Administration__r != NULL) {
                 examDateFormatted = ea.Original_Exam_Administration__r.Month__c + ' ' + ea.Original_Exam_Administration__r.Year__c;
             } else {
                 examDateFormatted = ea.RPT_Administration_Month__c + ' ' + ea.RPT_Administration_Year__c;
             }
             
             isERP=false;
             isFRM=false;
             isSCR=false;
             isRAI=false;
             isRAIJ=false;
             if(ea.Section__c.indexOf('ERP') > -1){
                isERP=true;
             } else if(ea.Section__c.indexOf('FRM') > -1){
                isFRM=true;
             } else if(ea.Section__c.indexOf('SCR') > -1){
                isSCR=true;             
             } else if(ea.Section__c.indexOf('RiskAI') > -1){
                isRAI=true;             
             } else if(ea.Section__c.indexOf('RAIJ') > -1){
                isRAIJ=true;             
             }
             
             if(ea.RPT_Exam_Program__c != NULL && ea.RPT_Exam_Part__c != NULL) {
                 examPart = ea.RPT_Exam_Program__c + ' Exam Part ' + ea.RPT_Exam_Part__c;
             }
         }
         
     }
     
     global class EventRegWrapper {

         global string eventName {get; set;}
         global string eventDate {get; set;}
         global string eventLocation {get; set;}
         global Boolean isEarlyRegistration {get; set;}
         global Boolean isStandardRegistration {get; set;}
         global Boolean isLateRegistration {get; set;}
         global string earlyRegistrationPaymentDeadline {get; set;}
         global string standardRegistrationPaymentDeadline {get; set;}
         global string lateRegistrationPaymentDeadline {get; set;}
         
         //global string cancellationPolicy { get; set; }
         //global string cancellationDate {get; set;}
         //global string paymentPolicy {get; set;}
         //global string eventId {get; set;}
         //global decimal eventCancelDays {get; set;}
         //global decimal rateGraceDays {get; set;}
         //global string lastRateDate {get; set;}
         //global date lastDateForCheckWire {get; set;}         
         
         
                  
         global EventRegWrapper(Event_Registration__c eve, Event_Rate__c eventRate) {

             eventName = eve.Event__r.Name;
             eventDate = datetime.newInstance(eve.Event__r.Start_Date__c.year(), eve.Event__r.Start_Date__c.month(), eve.Event__r.Start_Date__c.day()).format(SHORT_TIME_FORMAT );
             eventLocation = eve.RPT_Event_Location__c;
                         
             if(eve.Event__r.Online_Meeting_URL__c != NULL || eve.Event__r.Online_Meeting_Notes__c != NULL || eve.Event__r.ON24_Event_Id__c != NULL) {
                 eventLocation = 'Online';
             }
             
             isEarlyRegistration = False;
             isStandardRegistration = False;
             isLateRegistration = False;             
             if(eventRate != NULL && eventRate.Type__c != NULL && eventRate.Alternate_Payment_Deadline__c != NULL){                 
                 if(eventRate.Type__c == 'Early') {                     
                     isEarlyRegistration = True;                     
                     Date deadline = eventRate.Alternate_Payment_Deadline__c;                     
                     DateTime dt = DateTime.newInstance(deadline.Year(), deadline.Month(), deadline.Day());                     
                     earlyRegistrationPaymentDeadline = dt.format('MMMM dd, yyyy');                     
                 } else if(eventRate.Type__c == 'Standard') {                     
                     isStandardRegistration = True;                     
                     Date deadline = eventRate.Alternate_Payment_Deadline__c;                     
                     DateTime dt = DateTime.newInstance(deadline.Year(), deadline.Month(), deadline.Day());                     
                     standardRegistrationPaymentDeadline = dt.format('MMMM dd, yyyy');                     
                 } else if(eventRate.Type__c == 'Late') {                     
                     isLateRegistration = True;                     
                     Date deadline = eventRate.Alternate_Payment_Deadline__c;                     
                     DateTime dt = DateTime.newInstance(deadline.Year(), deadline.Month(), deadline.Day());                     
                     lateRegistrationPaymentDeadline = dt.format('MMMM dd, yyyy');                     
                 }                    
             }
             
             //lastDateForCheckWire = eve.Event__r.Last_Date_for_Wire_Check_Registration__c;
             //cancellationPolicy = eve.Event__r.Cancellation_Policy__c;
             //cancellationDate = datetime.newInstance(eve.Event__r.Event_Cancellation_Date__c.year(), eve.Event__r.Event_Cancellation_Date__c.month(), eve.Event__r.Event_Cancellation_Date__c.day()).format(SHORT_TIME_FORMAT );
             //paymentPolicy = eve.Event__r.Payment_Policy__c;
             //eventId = eve.Event__c;
             //eventCancelDays = eve.Event__r.Event_Cancellation_Days__c;
             //rateGraceDays = eve.Event__r.Grace_Period__c;
             //if(eve.Last_Date_For_Rate_Effectiveness__c != null) {
             //    lastRateDate = datetime.newInstance(eve.Last_Date_For_Rate_Effectiveness__c.year(), eve.Last_Date_For_Rate_Effectiveness__c.month(), eve.Last_Date_For_Rate_Effectiveness__c.day()).format(SHORT_TIME_FORMAT );
             //}else{ 
             //    lastRateDate = date.today().format();
             //}
         }
         
     }     
    
    global class ChaptMeetingRegWrapper {
        global string paymentPolicy {get; set;}
        global string cancellationPolicy {get; set;}
        
        global ChaptMeetingRegWrapper(Chapter_Meeting_Registration__c cmr) {
            paymentPolicy = cmr.Chapter_Meeting__r.Payment_Policy__c;
            cancellationPolicy = cmr.Chapter_Meeting__r.Cancellation_Policy__c;
        }
    }

         
     global class PaymentWrapper {
         global String chargentSFAType {get;set;}
         global String chargentSFAPaymentMethod {get;set;}
         global String chargentSFAResponseStatus {get;set;}
         global String chargentSFAGatewayDateFormatted {get;set;}
         global Decimal chargentSFAAmount {get; set;}
         global String refundReason {get;set;}
         global Boolean showReason {get;set;}
         global Decimal fee {get;set;}
         
         global PaymentWrapper(ChargentOrders__Transaction__c payment, String inRefundReason, Boolean inShowReason) {
             chargentSFAType = payment.ChargentOrders__Type__c;
             chargentSFAPaymentMethod = payment.ChargentOrders__Payment_Method__c;
             chargentSFAResponseStatus = payment.ChargentOrders__Response_Status__c;
             chargentSFAGatewayDateFormatted = payment.ChargentOrders__Gateway_Date__c!=null?payment.ChargentOrders__Gateway_Date__c.format(LONG_TIME_FORMAT):null;
             chargentSFAAmount = payment.ChargentOrders__Amount__c;
             refundReason = payment.ChargentOrders__Reason_Text__c;
             if(payment.Fee__c != null)
                fee = (payment.Fee__c * -1);
             else fee =null;
             showReason = inShowReason;
         }
         
         global PaymentWrapper(Legacy_Transaction__c payment, String inRefundReason, Boolean inShowReason) {
             chargentSFAType = payment.Type__c;
             chargentSFAPaymentMethod = payment.Payment_Method__c;
             chargentSFAResponseStatus = payment.Response_Status__c;
             chargentSFAGatewayDateFormatted = payment.Gateway_Date__c!=null?payment.Gateway_Date__c.format(LONG_TIME_FORMAT):null;
             chargentSFAAmount = payment.Amount__c;
             refundReason = payment.Reason_Text__c;
             if(payment.Fee__c != null)
                fee = (payment.Fee__c * -1);
             else fee =null;
             showReason = inShowReason;
         }
     } 
 
     
     global class LineItemWrapper {
         global String productName {get;set;}
         global String description {get;set;}
         global Integer quantity {get;set;}
         global String productCode {get;set;}
         global Decimal totalPrice {get;set;}
         global Decimal unitPrice {get;set;}         
         global Decimal weight {get;set;}         
         global Boolean electronicDelivery {get;set;}  
        
         global string examDate {get;set;}       
         global String hsnCode {get;set;}  
         global LineItemWrapper(OpportunityLineItem oli, OpportunityWrapper oppty) {
             
             if(oli.Product2.Name.indexOf('Risk & Regulations')> -1 && (oppty.programAbbrev == 'FRR' || (oppty.programAbbrev == null && oppty.createdDate.year() >= 2016))){
                 productName = oli.Product2.Name;
             }else {
                 productName = oli.Product2.Name.replace('Risk & Regulations', 'ICBRR');
             }
             
             if(oli.Product2.Name.IndexOf('Complimentary') == -1) {
             
                 // Added (Complimentary) to the OLI name for comped eBook, and Membership
                 if((oli.Product2.ProductCode == 'FRM1X' || oli.Product2.ProductCode == 'SCRX' || oli.Product2.ProductCode == 'FRMC1' || oli.Product2.ProductCode == 'FRMC2' || 
                     oli.Product2.ProductCode == 'ENCC1' || oli.Product2.ProductCode == 'ENCC2' || oli.Product2.ProductCode == 'SCRCN' || 
                     oli.Product2.ProductCode == 'MEMF' || oli.Product2.ProductCode == 'SCRBP' || oli.Product2.ProductCode == 'RAIBP' || oli.Product2.ProductCode == 'RAIJBP') && oli.UnitPrice == 0){
                     productName = oli.Product2.Name + ' (Complimentary)';
                 }
                 
             }
                 
             if(oppty.sageTransactionType == 'Salesforce - Postponed'){
                 productName = oli.Product2.Name.replace('Deferral','Postponement');
             }
             
             //system.debug('oppty:' + oppty);
             
             productCode = oli.Product2.ProductCode;
             
             description = oli.Description;
             quantity = Integer.ValueOf(oli.Quantity);
             totalPrice = oli.TotalPrice;
             unitPrice = oli.UnitPrice;
             weight = oli.Product2.Weight__c;        
             electronicDelivery = oli.Product2.Electronic_Delivery__c;
             hsnCode = oli.Product2.HSN_Code__c; 
             if(oli.exam_Date__C != null) 
                 
       //      examDate = oli.exam_Date__C;
             examDate = datetime.newInstance(oli.exam_Date__C.year(), oli.exam_Date__C.month(), oli.exam_Date__C.day()).format(SHORT_TIME_FORMAT );
      
         }         
     }
     
    
    private static String getExamType(String code) {
        if(code == FRMExamPart1Early || code == FRMExamPart2Early || code == ERPExamEarly || code == ERPExamPart1Early || code == ERPExamPart2Early || code == SCRMemberEarly || code == SCRNonMemberEarly || code == SCRCertifiedEarly || code == RAIMemberEarly || code == RAINonMemberEarly || code == RAICertifiedEarly || RAIJEarly.contains(code))
            return 'early';
        if(code == FRMExamPart1Standard || code == FRMExamPart2Standard || code == ERPExamStandard || code == ERPExamPart1Standard || code == ERPExamPart2Standard || code == SCRMemberStandard || code == SCRNonMemberStandard || code == SCRRetake || code == SCRCertifiedStandard || code == RAIMemberStandard || code == RAINonMemberStandard || code == RAICertifiedStandard || code == RAIRetake || RAIJStandard.contains(code))
            return 'standard';
        if(code == FRMExamPart1Late || code == FRMExamPart2Late || code == ERPExamLate || code == ERPExamPart1Late || code == ERPExamPart2Late)
            return 'late';
        return '';
    }

         
    @TestVisible private static final String DEFERAL_FRM_PROD_CODE = 'FRM1';
    @TestVisible private static final String ERP_PROD_KEY = 'ENC';
    @TestVisible private static final String ICBRR_NONMEM_PROD_CODE = 'CBRNM';
    @TestVisible private static final String ICBRR_MEM_PROD_CODE = 'CBR';
    @TestVisible private static final String ICBRR_RETAKE_PROD_CODE = 'CBR2A';
    @TestVisible private static final String FBR_MEM_PROD_CODE = 'FCBR';
    @TestVisible private static final String FBR_NONMEM_PROD_CODE = 'FBRNM';
    @TestVisible private static final String MEMBER_PROD_CODE = 'MEMI';
    @TestVisible private static final String MEMBER_STUDENT_PROD_CODE = 'MEMS';
    @TestVisible private static final String MEMBER_FREE_PROD_CODE = 'MEMF';
    
    @TestVisible private static final String SCRMemberEarly = 'SCRME';
    @TestVisible private static final String SCRMemberStandard = 'SCRMS';
    @TestVisible private static final String SCRNonMemberEarly = 'SCRNME';
    @TestVisible private static final String SCRNonMemberStandard = 'SCRNMS';
    @TestVisible private static final String SCRCertifiedEarly = 'SCRCME';
    @TestVisible private static final String SCRCertifiedStandard = 'SCRCMS';
    @TestVisible private static final String SCRRetake = 'SCR2A';
   	
    @TestVisible private static final String RAIMemberEarly = 'RAIME'; 
    @TestVisible private static final String RAIMemberStandard = 'RAIMS';
    @TestVisible private static final String RAINonMemberEarly = 'RAINME';
    @TestVisible private static final String RAINonMemberStandard = 'RAINMS';
    @TestVisible private static final String RAICertifiedEarly = 'RAICME';
    @TestVisible private static final String RAICertifiedStandard = 'RAICMS';
    @TestVisible private static final String RAIRetake = 'RAI2A'; 
            
    @TestVisible 
    private static final List<String> RAIJEarly = new List<String>{
        'RAIJME', 
        'RAIJNME', 
        'RAIJCME' 
    };
    @TestVisible 
    private static final List<String> RAIJStandard = new List<String>{     
        'RAIJMS', 
        'RAIJNMS', 
        'RAIJCMS',
        'RAI2A'    
    };
    
    
    @TestVisible private static final String FRMExamPart1Late = 'FRM1L';
    @TestVisible private static final String FRMExamPart1Standard = 'FRM1S';
    @TestVisible private static final String FRMExamPart1Early = 'FRM1E';
    @TestVisible private static final String FRMExamPart2Late = 'FRM2L';
    @TestVisible private static final String FRMExamPart2Standard = 'FRM2S';
    @TestVisible private static final String FRMExamPart2Early = 'FRM2E';

    @TestVisible private static final String ERPExamPart1Late = 'ENC1L';
    @TestVisible private static final String ERPExamPart1Standard = 'ENC1S';
    @TestVisible private static final String ERPExamPart1Early = 'ENC1E';
    @TestVisible private static final String ERPExamPart2Late = 'ENC2L';
    @TestVisible private static final String ERPExamPart2Standard = 'ENC2S';
    @TestVisible private static final String ERPExamPart2Early = 'ENC2E';
    
    @TestVisible private static final String ERPExamLate = 'ENCL';
    @TestVisible private static final String ERPExamStandard = 'ENCS';
    @TestVisible private static final String ERPExamEarly = 'ENCE';
    @TestVisible private static final String FRMPart2BooksNonCandidate = 'FRM2N';
    @TestVisible private static final String FRMPracticeExamsCandidate = 'FRMCP';
    @TestVisible private static final String EnergyCertificateCoursePackCandidate = 'ENCCP';
    @TestVisible private static final String FRMPart2BooksCandidate = 'FRM2H';
    @TestVisible private static final String FRMPart1BooksCandidate = 'FRM1H';
    @TestVisible private static final String FoundationHandbook = 'FBRHB';
    @TestVisible private static final String ICBRRHandBooks = 'CBRHB';
    @TestVisible private static final String ICBRRHandBooksIndividual = 'CBRHI';

    @TestVisible private static final String FRMPracticeExamsNonCandidate = 'FRMCN';
    @TestVisible private static final String EnergyCertificateCoursePackNonCandidate = 'ENCBN';
    @TestVisible private static final String SHIP_PROD_CODE = 'SHIP';
    @TestVisible private static final String PAY_DEFERRED_PROD_CODE = 'PRFEE';
    @TestVisible private static final String TAX_PROD_CODE = 'SLSTX';
    @TestVisible private static final String MISC_PROD_CODE = 'MISC';  
}