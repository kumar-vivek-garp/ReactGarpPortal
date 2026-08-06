public class freeInvoiceController {
    public static Opportunity opps;
    public static List<OpportunityLineItem> oppLineItms = new List<OpportunityLineItem>{};
    Public static set<String> ProductCodes = new set<String>{'FRM1','SCR','ENC1','RAI','RAIJ'};//Chinnapa
    Public static String GLcode = '4020';
    @AuraEnabled 
    public static void cloneOpp(String InvoiceNumber){
        
        // cloning opp with products
        Opportunity opp = [select id,Name,AccountId,Exam_Comp_Type__c,ChinaLocationFee__c,Amount,StageName,Type,Exam_Emails__c,Risk_net_fee__c,CloseDate ,
                           Billing_First_Name__c,Billing_Last_Name__c,Billing_Email__c,Billing_Phone__c,ia_crm__Intacct_Transaction__c,Tax_Authority__c,
                           Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,Billing_State_text__c,
                           Billing_Country__c,Billing_Zip_Postal__c,Billing_Company__c,Additional_Invoice_Information__c,
                           Payment_Method_New__c,Payment_Received__c,Gateway__c,CardType__c,
                           Charge_Amount__c ,Program__c ,Institutional_Sale_Stage__c ,Membership_Fee__c ,FRM_1_Registration_Fee__c ,
                           FRM_2_Registration_Fee__c ,ERP_Registration_Fee__c ,ERP_1_Registration_Fee__c ,ERP_2_Registration_Fee__c ,FRM_Enrollment_Fee__c ,ERP_Enrollment_Fee__c ,
                           Probability ,Company__c , Current_Member_Type__c ,Exam_Registration_Modification__c ,Sub_Program__c ,Alternate_Method_of_Payment__c,
                           Exam_Registration_Modification__r.Part_I_Exam_Registration__c,Exam_Registration_Modification__r.Part_II_Exam_Registration__c,
                           (select OpportunityId,ProductCode,Product2Id ,Description ,Product_company__c ,Exam_Site__c,UnitPrice,Quantity,Product_ID__c,PriceBookEntryid
                            ,Product2.GL_Code__c,Intacct_Template__c,ia_crm__Department__c,ia_crm__Intacct_Location__c,ia_crm__Class__c,Vendor_ID__c,Vendor_Name__c,
                            Warehouse__c,Tax_Authority__c,ServiceDate,ia_crm__Service_End_Date__c,Sage_Reporting_State__c,Sage_Reporting_Country__c,
                            Sage_Shipping_State__c,Sage_Shipping_Country__c,Site_Code__c from OpportunityLineItems),
                           (Select Id from Chargent_Orders__r)
                           from Opportunity where Display_Invoice_Number__c =: InvoiceNumber];
        
        Set<Id> regIds = new Set<Id>();
        List<Exam_Attempt__c> regToUpdate = new List<Exam_Attempt__c>();
        if(opp.Exam_Registration_Modification__c != null){
            if(opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__c != null){
                regIds.add(opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__c);
            }
            if(opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__c != null){
                regIds.add(opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__c);
            }
        }
        
        if(!regIds.isEmpty()){
            List<Exam_Attempt__c> regList = [Select Id,Deferral_SubType__c from Exam_Attempt__c where Id IN: regIds];
            
            for(Exam_Attempt__c ea : regList){
                ea.Deferral_SubType__c = 'Deferral Free';
                regToUpdate.add(ea);
            }
        }
        
        Opportunity newOpp = opp.clone(false,true);
        newOpp.CloseDate  = system.Today();
        Datetime dt = datetime.newInstance(newOpp.CloseDate.year(),newOpp.CloseDate.month(),newOpp.CloseDate.day());
        String dateTimeStr = dt.format('MMddyy');
        newOpp.Sage_Document_Number__c = 'FE'+dateTimeStr;
        newopp.Deferral_SubType__c = 'Deferral Free';
        newOpp.Sage_Paid_Date__c = newOpp.CloseDate;
       // system.debug('newOpp.CloseDate =====>'+newOpp.CloseDate );
        Insert newOpp;
       /* system.debug('Id======>'+newOpp.id);
        system.debug('opp.OpportunityLineItems=======>'+opp.OpportunityLineItems);
        system.debug('opp.OpportunityLineItems.PriceBookEntryid=======>'+opp.OpportunityLineItems[0].PriceBookEntryid); */
        for(OpportunityLineItem oli : newOpp.OpportunityLineItems ){
            OpportunityLineItem oliNew = oli.clone(false, true);
            oliNew.OpportunityId = newOpp.id;
            if(ProductCodes.contains(oli.ProductCode) && oli.Product2.GL_Code__c == '4020' ){
                oliNew.UnitPrice = 0;
            }
            oppLineItms.add(oliNew);
        }
        insert oppLineItms;
        ChargentBase__Gateway__c gateWay = [select id,name from ChargentBase__Gateway__c where name = 'paypal garp' LIMIT 1];
        ChargentOrders__Transaction__c trns = new ChargentOrders__Transaction__c ();
        trns.ChargentOrders__Gateway_Date__c = system.now();
        trns.Opportunity__c = newOpp.id;
        trns.ChargentOrders__Gateway__c = gateWay.id;
        trns.ChargentOrders__Amount__c = 0.0;
        trns.ChargentOrders__Type__c = 'Charge';
        trns.ChargentOrders__Payment_Method__c ='free';
        trns.ChargentOrders__Response_Message__c  = 'Approved';
        trns.ChargentOrders__Response_Status__c = 'Approved';
        trns.ChargentOrders__Order__c = newOpp.Chargent_Orders__r[0].Id;
        insert trns;
        
        if(!regToUpdate.isEmpty()){
            update regToUpdate;
        }
        
    }
}