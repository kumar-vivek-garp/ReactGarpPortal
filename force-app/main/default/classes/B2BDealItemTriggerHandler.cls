/**
* Class B2BDealItemTriggerHandler
* Trigger Handler for the B2B_Deal_Item__c SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class B2BDealItemTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    
    // Constructor
    public B2BDealItemTriggerHandler(){}
    
    /**
* bulkBefore
*
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(!stopRecurssion){
            if (!Trigger.isDelete){}
        }
    }
    
    public void bulkAfter(){
        if(!stopRecurssion){
            
            if (!Trigger.isDelete){}
            
        }
    }
    
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            B2B_Deal_Item__c newObj = (B2B_Deal_Item__c)so;
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        if(!stopRecurssion){
            B2B_Deal_Item__c newObj = (B2B_Deal_Item__c)so;
            B2B_Deal_Item__c oldObj = (B2B_Deal_Item__c)oldSo;
        }
    }
    
    public void beforeDelete(SObject so){
        B2B_Deal_Item__c newObj = (B2B_Deal_Item__c)so;
    }
    
    public void afterInsert(SObject so){
        if(!stopRecurssion){}
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        if(!stopRecurssion){}
    }
    
    public void afterDelete(SObject so){
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        if(!stopRecurssion){
            //stopRecurssion = true;
            if(trigger.isBefore){
                checkAccessCode(trigger.new);
            }
            
            if(trigger.isAfter){
                
                if(trigger.isUpdate){
                    stopRecurssion = true;
                }
            }
        }
    }
    
    
    public static void checkAccessCode(List<B2B_Deal_Item__c> regList){
        
        Set<String> accessCodeSet = new Set<String>();
        
        Id eventsRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Events');
        Id examsCoursesRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Exams_Courses');
        Id membershipRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Membership');
        Id studyMaterialsRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        Id eBooksRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'eBooks');
        
        List<B2B_Deal_Item__c> fullRegList = [Select Id,Access_Code__c from B2B_Deal_Item__c];
        for(B2B_Deal_Item__c reg : fullRegList){
            accessCodeSet.add(reg.Access_Code__c);
        }
        
        List<Country_Code__c> lstCC = [select Id, Country__c, Country_Code_Region__c, Country_Code_Subregion__c from Country_Code__c];
        //System.debug('lstCC:' + lstCC);
        
        MAP<String,Country_Code__c> mapCC = new MAP<String,Country_Code__c>();
        if(!lstCC.IsEmpty()) {
            for(Country_Code__c cc :lstCC) {
                mapCC.put(cc.Country__c, cc);
            }
        }
        if(regList != NULL) {
            
            for(B2B_Deal_Item__c reg : regList){
                Id recid = reg.RecordTypeId;
                if(string.isBlank(reg.Access_Code__c) && (recid == eBooksRecTypeid || recid == eventsRecTypeid || recid == examsCoursesRecTypeid || recid == membershipRecTypeid)){
                    string uniqueCode;
                    do{
                        uniqueCode = Utilities.getRandomCode();
                    }while(accessCodeSet.contains(uniqueCode));
                    reg.Access_Code__c = uniqueCode;
                }
                
                if(recid == studyMaterialsRecTypeid && reg.Override_Shipping_Calculation__c == false) {
                    String bookKey;
                    Integer quantity;
                    Decimal totalRate=0;
                    if(reg.FRM_Part_I_Hard_Books__c != NULL) {
                        bookKey = 'FRM1';
                        quantity = Integer.ValueOf(reg.FRM_Part_I_Hard_Books__c);
                        Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                        totalRate += rate;
                    }
                    if(reg.FRM_Part_II_Hard_Books__c != NULL) {
                        bookKey = 'FRM2';
                        quantity = Integer.ValueOf(reg.FRM_Part_II_Hard_Books__c);
                        Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                        totalRate += rate;
                    }
                    if(reg.SCR_Hard_Books__c != NULL || reg.Discounted_SCR_Hard_Books__c != null) {
                        bookKey = 'SCR';
                        Integer scrhard = reg.SCR_Hard_Books__c != NULL ?Integer.ValueOf(reg.SCR_Hard_Books__c):0;
                        Integer memberbook = reg.Discounted_SCR_Hard_Books__c != NULL ?Integer.ValueOf(reg.Discounted_SCR_Hard_Books__c):0;
                        quantity = scrhard+memberbook;
                        Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                        totalRate += rate;
                    }
                    if(reg.FRR_Hard_Books__c != NULL) {
                        bookKey = 'FRR';
                        quantity = Integer.ValueOf(reg.FRR_Hard_Books__c);                
                        Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                        totalRate += rate;
                    }
					if(reg.RAI_Hard_Books__c != NULL || reg.Discounted_RAI_Hard_Books__c != NULL) {
                        bookKey = 'RAI';
                        Integer raihard = reg.RAI_Hard_Books__c != NULL ?Integer.ValueOf(reg.RAI_Hard_Books__c):0;
                        Integer memberbook = reg.Discounted_RAI_Hard_Books__c != NULL ?Integer.ValueOf(reg.Discounted_RAI_Hard_Books__c):0;
                        quantity = raihard+memberbook;               
                        Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                        totalRate += rate;
                    }
                    //System.debug('totalRate:' + totalRate);
                    reg.Shipping_Cost__c = totalRate;
                }
            }
            
        }
    }
    
}