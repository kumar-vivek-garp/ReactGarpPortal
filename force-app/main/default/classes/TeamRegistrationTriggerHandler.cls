/**
* Class TeamRegistrationTriggerHandler
* Trigger Handler for the Team_Registration__c SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class TeamRegistrationTriggerHandler implements TriggerAbstract {
    public static boolean stopRecurssion = false;
    List<Team_Registration__c> trList = new List<Team_Registration__c>();
    static Map<Id,List<B2B_Deal_Item__c>> teamRegB2BDIMap = new Map<Id,List<B2B_Deal_Item__c>>();
    
    // Constructor
    public TeamRegistrationTriggerHandler(){}
    
    /**
    * bulkBefore
    *
    * This method is called prior to execution of a BEFORE trigger. Use this to cache
    * any data required into maps prior execution of the trigger.
    */
    public void bulkBefore() {
		if(!stopRecurssion){
            
            if (Trigger.isDelete){}
        }
    }
    
    public void bulkAfter(){
        if(!stopRecurssion){
            if (!Trigger.isDelete){
                
            }
        }
    }
    
    public void beforeInsert(SObject so){
        if(!stopRecurssion){
            Team_Registration__c newObj = (Team_Registration__c)so;
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        if(!stopRecurssion){
            Team_Registration__c newObj = (Team_Registration__c)so;
            Team_Registration__c oldObj = (Team_Registration__c)oldSo;
        }
    }
     
    public void beforeDelete(SObject so){
        Team_Registration__c newObj = (Team_Registration__c)so;
    }
    
    public void afterInsert(SObject so){
        if(!stopRecurssion){
            Team_Registration__c newRec = (Team_Registration__c)so;
            if(newRec.Payment_Status__c == 'Paid' && newRec.Include_Books__c){
                trList.add(newRec);
            }
        }
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        if(!stopRecurssion){
            Team_Registration__c newRec = (Team_Registration__c)so;
        	Team_Registration__c oldRec = (Team_Registration__c)oldSo;
            //if(newRec.Payment_Status__c != oldRec.Payment_Status__c && newRec.Payment_Status__c == 'Paid' && newRec.Include_Books__c &&newRec.Shipping_Cost__c != null){
            if(newRec.Payment_Status__c != oldRec.Payment_Status__c && newRec.Payment_Status__c == 'Paid' && newRec.Include_Study_Materials__c){
                trList.add(newRec);
            }
        }
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
                //checkAccessCode(trigger.new);
            }
            
            if(trigger.isAfter){
                if(trList.size() > 0){
                    createBulkOrder(trList);
                }
                if(trigger.isUpdate){
                    stopRecurssion = true;
                }
            }
        }
    }
    
    
    public static void createBulkOrder(List<Team_Registration__c> regList){
        List<Bulk_Orders__c> boList = new List<Bulk_Orders__c>();
        String studyMaterialRT = RecordTypehelper.getRecordTypeIdFromSchema('B2B_Deal_Item__c', 'Study_Materials');
        
        for(B2B_Deal_Item__c bdi : [SELECT Id,B2B_Deal__c,RecordTypeId,Shipping_Contact_Name__c,Shipping_Contact_Email__c,Shipping_Contact_Phone__c,
                                    	   Shipping_Address__c,Shipping_State_Provence__c,Shipping_City__c,Shipping_Postal_Code__c,Shipping_Country__c
                                    FROM B2B_Deal_Item__c 
                                    WHERE B2B_Deal__c IN: regList AND RecordTypeId =: studyMaterialRT])
        {
            if(teamRegB2BDIMap.containsKey(bdi.B2B_Deal__c)){
                teamRegB2BDIMap.get(bdi.B2B_Deal__c).add(bdi);
            }else{
                teamRegB2BDIMap.put(bdi.B2B_Deal__c, new List<B2B_Deal_Item__c>{bdi});
            }
        }
        
        
        for(Team_Registration__c tr : regList){
            if(teamRegB2BDIMap.containsKey(tr.Id)){
                for(B2B_Deal_Item__c di : teamRegB2BDIMap.get(tr.Id)){
                        Bulk_Orders__c bo = new Bulk_Orders__c();
                        bo.Team_Registration__c = tr.Id;
                        bo.B2B_Deal_Item__c = di.Id;
                        bo.E_mail__c = di.Shipping_Contact_Email__c;
                        bo.Shipping_Address_1__c = di.Shipping_Address__c;
                        bo.Shipping_City__c = di.Shipping_City__c;
                        bo.Shipping_Country__c = di.Shipping_Country__c;
                        bo.Shipping_State_Provence__c = di.Shipping_State_Provence__c;
                        bo.Shipping_Postal_Code__c = di.Shipping_Postal_Code__c;
                    	bo.Shipping_Phone_Number__c = di.Shipping_Contact_Phone__c;
                        bo.Status__c = 'Approved';
                        bo.Shipping_Attention__c = di.Shipping_Contact_Name__c;
                        boList.add(bo);
                }
            }
        }
        
        if(boList.size() > 0){
            insert boList;
        }
    }
    
    /*
    public static void checkAccessCode(List<Team_Registration__c> regList){
        Set<String> accessCodeSet = new Set<String>();
        Id teamregRecTypeid = RecordTypehelper.getRecordTypeIdFromSchema('Team_Registration__c', 'Team_Registration');
        List<Team_Registration__c> fullRegList = [Select Id,Access_Code__c from Team_Registration__c];
        for(Team_Registration__c reg : fullRegList){
            accessCodeSet.add(reg.Access_Code__c);
        }
        
        List<Country_Code__c> lstCC = [select Id, Country__c, Country_Code_Region__c, Country_Code_Subregion__c from Country_Code__c];
        System.debug('lstCC:' + lstCC);

        MAP<String,Country_Code__c> mapCC = new MAP<String,Country_Code__c>();
        if(!lstCC.IsEmpty()) {
            for(Country_Code__c cc :lstCC) {
                mapCC.put(cc.Country__c, cc);
            }
        }
        
        for(Team_Registration__c reg : regList){
            if(string.isBlank(reg.Access_Code__c) && reg.RecordTypeId == teamregRecTypeid){
                string uniqueCode;
                do{
                    uniqueCode = Utilities.getRandomCode();
                }while(accessCodeSet.contains(uniqueCode));
                reg.Access_Code__c = uniqueCode;
            }
            
            if(reg.Include_Books__c != NULL) {
                String bookKey;
                Integer quantity;
                Decimal totalRate=0;
                if(reg.FRM_Part_I_Books__c != NULL) {
                    bookKey = 'FRM1';
                    quantity = Integer.ValueOf(reg.FRM_Part_I_Books__c);
                    Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                    totalRate += rate;
                }
                if(reg.FRM_Part_II_Books__c != NULL) {
                    bookKey = 'FRM2';
                    quantity = Integer.ValueOf(reg.FRM_Part_II_Books__c);
                    Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                    totalRate += rate;
                }
                if(reg.SCR_Books__c != NULL) {
                    bookKey = 'SCR';
                    quantity = Integer.ValueOf(reg.SCR_Books__c);
                    Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                    totalRate += rate;
                }
                if(reg.FRR_Books__c != NULL) {
                    bookKey = 'FRR';
                    quantity = Integer.ValueOf(reg.FRR_Books__c);                
                    Decimal rate = GARP_BC_Shipping.getBulkShippingRate(reg.Shipping_Country__c, bookKey, quantity, mapCC);
                    totalRate += rate;
                }
                System.debug('totalRate:' + totalRate);
                reg.Shipping_Cost__c = totalRate;
            }
        }
        
    }*/
}