public class SageUpdateTriggerHandler { 
    public static void updateOpportunity(List<Sage_Updates__e> evtList){
        Set<String> oppIds = new Set<String>();
        Set<Id> ermIdList = new Set<Id>();
        Set<String> accIdSet = new Set<String>();
        Map<String,String> departmentMap = new Map<String,String>();
        Map<String,String> classMap = new Map<String,String>();
        Map<String,String> IntacctUserDimensionMap = new Map<String,String>();
        Map<String,String> IntacctEntityMap = new Map<String,String>();
        Map<String,String> IntacctTemplateMap = new Map<String,String>();
        Map<String,String> IntacctProjectMap = new Map<String,String>();
        Map<String,Integer> warehouseMap = new Map<String,Integer>();
        
        Map<String,Opportunity_Product_Mapping__mdt> oppProductToMethodMap = OpportunityTriggerHelper_New.getOppProductMethodMapAllProducts();
        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        List<OpportunityLineItem> oliToUpdate = new List<OpportunityLineItem>();
        Map<Id,Id> examRegToOppMap = new Map<Id,Id>();
        Map<String,Site_Code_MDT__mdt> siteCodeMap = new map<String,Site_Code_MDT__mdt>();
        Id memberRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership');
        Id OSTARecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        Map<String,Contract> garpIdToMemPrgrm = new Map<String,Contract>();
        Map<String,Contract> garpIdToOSTAPrgrm = new Map<String,Contract>();
        Map<String,PriceBookEntry> ostaPriceMap = new Map<String,PriceBookEntry>();
		Integer recordCount = 0;
        Map<String,String> countryISOCodeMap = new Map<String,String>();
        List<Account> accToUpdate = new List<Account>();
        boolean stripeEnabled = false;
        string gateway = Sage_Default_Records_Ref__mdt.getInstance('Stripe_Gateway').value__c;
        
        for(Sage_Updates__e evt : evtList){
            recordCount++;
            if (recordCount >=  15) {
                break;
            }
            if(String.isnotblank(evt.Opportunity_Id__c)){
                oppIds.add(evt.Opportunity_Id__c);
            }
            //platform event bus
            if(!Test.isRunningTest())
                EventBus.TriggerContext.currentContext().setResumeCheckpoint(evt.ReplayId);
        }
        
        List<PricebookEntry> pbeList = [SELECT Id, Name, Product2Id, ProductCode, Unitprice,Product2.Product_Id__c,Product2.ProductCode 
                                                  from PriceBookEntry 
                                                  where Pricebook2.Name = 'GARP 2015/2016' AND (Product2.ProductCode = 'CHLF' OR Product2.ProductCode = 'CHNDF')];
        
        for(PricebookEntry pbe : pbeList){
            ostaPriceMap.put(pbe.Product2.ProductCode,pbe);
        }
        
         List<Opportunity> oppList = [Select Id,EPP_Deal_Net_New__c,Exam_Registration_Modification__c,Billing_Country__c,Billing_State_Text__c,GARP_Member_ID__c,AccountId,Gateway__r.Name,Gateway__c,
                                     CardType__c,Shipping_Country__c,Shipping_State__c,ia_crm__Intacct_Transaction__c,CloseDate,Payment_Method_New__c,Tax_authority__c,Tax_Region__c,
                                     (SELECT Id, Name, ProductCode,Exam_Registration__r.Member__c, Product2Id,Opportunity.OSTA_Exam_Site_Code__c,TotalPrice,Tax_authority__c,
                                      Opportunity.OSTA_Opportunity_Refund__c, Opportunity.Exam_Registration_Modification__c, Product2.Family, ia_crm__Class__c,
                                      Product2.Department__c, Product2.Location__c, Product2.Class__c, Sage_Reporting_Country__c,Site_Code__c,Sage_Shipping_Country__c,
                                      Event__c, Exam_Site__r.Id, Exam_Registration__c, OpportunityId, UnitPrice, Quantity, Opportunity.AccountId,ia_crm__Project__c,
                                      Opportunity.GARP_Member_ID__c, Scholarship_Application__c,Exam_Registration__r.Exam_Date__c,Description,Product_Id__c,
                                      Product2.Is_Shippable__c, Product2.Weight__c, Product2.Product_ID__c,Product2.Bookstore__c,Product2.Name, Product2.Customs_Cost__c,
                                      Product2.GL_Code__c,Opportunity.StageName,Opportunity.Billing_Email__c,Product2.Company__c,Product2.ProductCode,Reference_Id__c,ServiceDate,Epp_Project_Id__c,Tax_Region__c
                                      FROM OpportunityLineItems Order By Name)
                                     from Opportunity where Id IN: oppIds];
        
        for(ia_crm__Department__c dep : [SELECT ia_crm__Department_ID__c,Id FROM ia_crm__Department__c WHERE ia_crm__Status__c = 'Active' LIMIT 2000]){
			departmentMap.put(dep.ia_crm__Department_ID__c,dep.Id);
		}
		
		for(ia_crm__Class__c cls : [SELECT ia_crm__Class_ID__c,ia_crm__Status__c,Id,Name FROM ia_crm__Class__c LIMIT 2000]){
			classMap.put(cls.Name,cls.Id);
		}
        
        for(ia_crm__Intacct_User_Dimension__c ciud : [SELECT ID,Name FROM ia_crm__Intacct_User_Dimension__c LIMIT 10000]){
            IntacctUserDimensionMap.put(ciud.Name.substring(0,4), ciud.Id);
        }
        
        for(Site_Code_MDT__mdt mdt : [Select DeveloperName,Label,code__c,ISO_Name__c from Site_Code_MDT__mdt]){
            siteCodeMap.put(mdt.Label, mdt);
            if(String.IsNotBlank(mdt.ISO_Name__c)){
                countryISOCodeMap.put(mdt.Label,mdt.ISO_Name__c);
            }
        }
        
        for(ia_crm__Intacct_Entity__c ent : [Select ID,ia_crm__Intacct_Entity_ID__c from ia_crm__Intacct_Entity__c]){
            IntacctEntityMap.put(ent.ia_crm__Intacct_Entity_ID__c, ent.Id);
        }
        
        for(ia_crm__Revenue_Recognition_Template__c temp : [Select ID,Name from ia_crm__Revenue_Recognition_Template__c]){
            IntacctTemplateMap.put(temp.Name, temp.Id);
        }
        
        for(ia_crm__Project__c project : [Select ID,ia_crm__Project_ID__c from ia_crm__Project__c]){
            IntacctProjectMap.put(project.ia_crm__Project_ID__c, project.Id);
        }
        
        for(ProductWarehouseMapping__mdt mdt : [Select DeveloperName,MasterLabel,Warehouse__c from ProductWarehouseMapping__mdt]){
            warehouseMap.put(mdt.DeveloperName, Integer.valueof(mdt.Warehouse__c));
        }
        
        for(Opportunity opp : oppList){
            //if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Sales Invoice'){
                accIdSet.add(opp.AccountId);
            //}
            if(opp.Exam_Registration_Modification__c != null){
                ermIdList.add(opp.Exam_Registration_Modification__c);
            }
        }
        for(Account acc : [SELECT Id,BillingCountry,ShippingCountry FROM Account WHERE Id IN:accIdSet]){
            if((String.isNotBlank(acc.BillingCountry) || String.isNotBlank(acc.ShippingCountry)) ){
                Boolean addToList = False;
                if(String.isNotBlank(acc.BillingCountry) && countryISOCodeMap.containsKey(acc.BillingCountry)){
                    acc.BillingCountry = countryISOCodeMap.get(acc.BillingCountry);
                    addToList = True;
                }
                if(String.isNotBlank(acc.ShippingCountry) && countryISOCodeMap.containsKey(acc.ShippingCountry)){
                    acc.ShippingCountry = countryISOCodeMap.get(acc.ShippingCountry);
                    addToList = True;
                }
                if(addToList){
                    accToUpdate.add(acc);
                }
            }
        }
       // system.debug('accToUpdate::>>   '+accToUpdate);
        
        if(!accIdSet.isEmpty()){
            List<Contract> membershpPrgList = [Select Id,GARP_ID__c,startDate,Enddate,RecordTypeId,OSTA_Last_Upload_Date__c,AccountId
                                               from Contract 
                                               where AccountId IN: accIdSet and Status Like 'Activated%' 
                                               and Membership_type__c != 'Affiliate' and (RecordTypeId =: memberRecordTypeID OR RecordTypeId =: OSTARecTypeId)
                                               Order by Startdate ASC];
            
            for(Contract prg : membershpPrgList){
                if(prg.RecordTypeId == memberRecordTypeID){
                	garpIdToMemPrgrm.put(prg.AccountId,prg);
                }else if(prg.RecordTypeId == OSTARecTypeId && prg.OSTA_Last_Upload_Date__c != null){
                    garpIdToOSTAPrgrm.put(prg.AccountId,prg);
                }
            }
        }
        
        Map<Id,Exam_Registration_Modification__c> ermMap = new Map<Id,Exam_Registration_Modification__c>([SELECT Id,Part_I_Exam_Group_From__c,Part_I_Exam_Group_To__r.Name,
                                                                                                          Part_I_Exam_Group_From__r.Name,Part_I_Exam_Group_To__c,
																										  Part_I_Exam_Admin_From__r.Exam_Group__r.Exam_Date__c,Part_II_Exam_Admin_From__r.Exam_Group__r.Exam_Date__c,
                                                                                                          Part_I_Exam_Admin_From__r.Month__c,Part_II_Exam_Admin_From__r.Month__c,
                                                                                                          Part_I_Exam_Admin_To__r.Exam_Group__r.Exam_Date__c,Part_II_Exam_Admin_To__r.Exam_Group__r.Exam_Date__c,
                                                                                                          Part_I_Exam_Admin_To__r.Month__c,Part_II_Exam_Admin_To__r.Month__c,
                                                                                                          Part_I_Exam_Registration__c,Part_II_Exam_Registration__c,
                                                                                                          Part_I_Exam_Registration__r.Exam_Site__r.Name,Part_II_Exam_Registration__r.Exam_Site__r.Name,
                                                                                                          Part_I_Exam_Admin_From__c,Part_II_Exam_Admin_From__c,
                                                                                                          Part_I_Exam_Part_From__c,Part_II_Exam_Part_From__c,
                                                                                                          Part_I_Exam_Part_From__r.Exam_Date__c,Part_II_Exam_Part_From__r.Exam_Date__c,
                                                                                                          Part_I_Exam_Part_From__r.Exam_Start_Date__c,Part_II_Exam_Part_From__r.Exam_Start_Date__c,
                                                                                                          Part_I_Exam_Part_To__c,Part_II_Exam_Part_To__c,
                                                                                                          Part_I_Exam_Part_To__r.Exam_Date__c,Part_II_Exam_Part_To__r.Exam_Date__c,
                                                                                                          Part_I_Exam_Part_To__r.Exam_Start_Date__c,Part_II_Exam_Part_To__r.Exam_Start_Date__c,
																										  Part_I_Exam_Registration__r.Opportunity__c,Part_II_Exam_Registration__r.Opportunity__c,
																										  Part_I_Exam_Registration__r.Section__c,Part_II_Exam_Registration__r.Section__c,
                                                                                                          Part_I_Exam_Registration__r.Garp_Id__c,Part_II_Exam_Registration__r.Garp_Id__c,Part_II_Exam_Registration__r.Defered__c,
                                                                                                          Part_I_Exam_Registration__r.Other_Exam_Registrations__c,Part_II_Exam_Registration__r.Other_Exam_Registrations__c,
                                                                                                          Part_I_Exam_Registration__r.Other_Exam_Registrations__r.Cancelled__c,Part_II_Exam_Registration__r.Other_Exam_Registrations__r.Cancelled__c,
                                                                                                          Part_I_Exam_Registration__r.Other_Exam_Registrations__r.Defered__c,Part_II_Exam_Registration__r.Other_Exam_Registrations__r.Defered__c,
                                                                                                          Part_I_Exam_Registration__r.Other_Exam_Registrations__r.Exam_Site__r.Name,Part_II_Exam_Registration__r.Other_Exam_Registrations__r.Exam_Site__r.Name,
                                                                                                          Part_I_Exam_Registration__r.Previous_Deferral_Type__c,Part_II_Exam_Registration__r.Previous_Deferral_Type__c,
                                                                                                          Part_I_Exam_Registration__r.Deferral_Status__c,Part_II_Exam_Registration__r.Deferral_Status__c
                                                                                                          FROM Exam_Registration_Modification__c WHERE Id IN:ermIdList]);
        
        for(Exam_Registration_Modification__c erm : ermMap.values()){
            if(erm.Part_I_Exam_Registration__c != null){
                examRegToOppMap.put(erm.Part_I_Exam_Registration__c,erm.Part_I_Exam_Registration__r.Opportunity__c);
            }
            
            if(erm.Part_II_Exam_Registration__c != null){
                examRegToOppMap.put(erm.Part_II_Exam_Registration__c,erm.Part_II_Exam_Registration__r.Opportunity__c);
            }
        }
		
		Map<Id,Opportunity> originalOppsMap = new Map<Id,Opportunity>([Select Id, (Select Id,UnitPrice,Product2Id,ProductCode,Product_Id__c,TotalPrice,OpportunityId,
                                                                                   ia_crm__Department__c,ia_crm__Intacct_Location__c,Warehouse__c,PricebookEntryId,Reference_Id__c,
                                                                                   Sage_Reporting_Country__c,Sage_Reporting_State__c,Site_Code__c,Vendor_Name__c,ia_crm__Project__c,
                                                                                   Vendor_Id__c,Sage_Shipping_Country__c,Sage_Shipping_State__c,ServiceDate,Epp_Project_Id__c from OpportunityLineItems)
																		from Opportunity where Id IN: examRegToOppMap.values()]);
        
        Map<Id,Exam_Attempt__c> eaMap = new Map<Id,Exam_Attempt__c>([SELECT ID,Opportunity__c,Exam_Site__c,Exam_Site__r.Name,Section__c,RPT_Administration_Month__c,
                                                                     Exam_Administration__r.Exam_Group__c,Garp_Id__c
                                                                     FROM Exam_Attempt__c WHERE Opportunity__c IN: oppIds]);
        
        Map<Id,Event_Registration__c> eventMap = new Map<Id,Event_Registration__c>([SELECT ID,Opportunity__c,Event__r.Class__c,Event__r.Site_Code__c,Event__r.Location__c,
                                                                                    Event__r.Project__c,RPT_Event_Start_Date__c
                                                                     FROM Event_Registration__c WHERE Opportunity__c IN: oppIds]);
        
        //system.debug(eaMap.size()+'      <<::inside updateSageOLI  eaMap::>>>   '+eaMap);
        
        
        Map<Id,List<Exam_Attempt__c>> oppEAMap = new Map<Id,List<Exam_Attempt__c>>();
        
        for(Exam_Attempt__c ea : eaMap.Values()){
            if(oppEAMap.containsKey(ea.Opportunity__c)){
                List<Exam_Attempt__c> eaList = oppEAMap.get(ea.Opportunity__c);
                eaList.add(ea);
                oppEAMap.put(ea.Opportunity__c,eaList);
            }else{
                oppEAMap.put(ea.Opportunity__c,new List<Exam_Attempt__c>{ea});
            }
        }
        
        Map<Id,Event_Registration__c> oppEventMap = new Map<Id,Event_Registration__c>();
        
        for(Event_Registration__c er : eventMap.Values()){
            oppEventMap.put(er.Opportunity__c,er);
        }
        Map<Id,Chapter_Meeting_Registration__c> chapterMeetingMap = new Map<Id,Chapter_Meeting_Registration__c>();
        for(Chapter_Meeting_Registration__c cm:[SELECT ID,Opportunity__c,Chapter_Meeting__r.Class__c,Chapter_Meeting__r.Site_Code__c,Chapter_Meeting__r.Location__c,
                                                                                    Chapter_Meeting__r.Project__c,Chapter_Meeting__r.Start_Date__c
                                                                     FROM Chapter_Meeting_Registration__c WHERE Opportunity__c IN: oppIds]){
            chapterMeetingMap.put(cm.Opportunity__c,cm);
        }
        for(Opportunity opp : oppList){
            String deferralClass;
            string deferralYear;
            string examClass;
            if(opp.Exam_Registration_Modification__c != null){
                Exam_Registration_Modification__c erm = ermMap.get(opp.Exam_Registration_Modification__c);
                
                boolean doNotMoveDataFee = false;
                boolean dataFeeMoved = false;
                //integer lineNum = 2;
                if(garpIdToOSTAPrgrm.containskey(opp.AccountId) && garpIdToOSTAPrgrm.get(opp.AccountId).OSTA_Last_Upload_Date__c != null){
                    doNotMoveDataFee = true;
                }
                if(erm.Part_I_Exam_Registration__c != null && erm.Part_I_Exam_Admin_From__c != erm.Part_I_Exam_Admin_To__c){
                    date frmDate;
                    date toDate;
                    String negativeAmtClass;
                    String positiveAmtClass;
                    Date negativeAmtDate;
                    Date positiveAmtDate;
                    boolean addTemplateToNegAmt = false;
                    boolean addTemplateToPostvAmt = false;
                    boolean moveDataFee = false;
                    if(erm.Part_I_Exam_Part_From__c != null){
                        frmDate = erm.Part_I_Exam_Part_From__r.Exam_Date__c != null ? erm.Part_I_Exam_Part_From__r.Exam_Date__c : erm.Part_I_Exam_Part_From__r.Exam_Start_Date__c;
                    }else{
                        frmDate = null;
                    }
                    if(erm.Part_I_Exam_Part_To__c != null){
                        toDate = erm.Part_I_Exam_Part_To__r.Exam_Date__c != null ? erm.Part_I_Exam_Part_To__r.Exam_Date__c : erm.Part_I_Exam_Part_To__r.Exam_Start_Date__c;
                    }else{
                        toDate = null;
                    }
                    
                    if(frmDate != null && (toDate == null || (toDate != null && frmDate < toDate))){
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral'){
                            if(erm.Part_I_Exam_Registration__r.Previous_Deferral_Type__c == 'Postponed'){
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Makeup';
                            }else{
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer Out';
                            }
                            if(toDate != null){
                                positiveAmtClass = convertMonthNumberToText(toDate.month())+' Defer In';
                            }else{
                                positiveAmtClass = erm.Part_I_Exam_Admin_To__r.Month__c.Substring(0,3)+' Defer In';
                            }
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Postponed'){
                            if(String.isBlank(erm.Part_I_Exam_Registration__r.Previous_Deferral_Type__c) && erm.Part_I_Exam_Registration__r.Deferral_Status__c == 'Defer In'){
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer In';
                            }else{
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Postponed';
                            }
                            if(toDate != null){
                                positiveAmtClass = convertMonthNumberToText(toDate.month())+' Makeup';
                            }else{
                                positiveAmtClass = erm.Part_I_Exam_Admin_To__r.Month__c.Substring(0,3)+' Makeup';
                            }
                        }
                        deferralClass = convertMonthNumberToText(frmDate.month())+' Registration';
                        deferralYear = string.valueof(frmDate.year()).right(2);
                        negativeAmtDate = opp.CloseDate;
                        positiveAmtDate = toDate != null ? toDate : erm.Part_I_Exam_Admin_To__r.Exam_Group__r.Exam_Date__c;
                        addTemplateToPostvAmt = true;
                        if(erm.Part_I_Exam_Registration__r.Section__c == 'FRM Part 1' && erm.Part_I_Exam_Registration__r.Exam_Site__r.Name == 'China' && !doNotMoveDataFee){
                            if(erm.Part_II_Exam_Registration__c != null 
                               && ((erm.Part_II_Exam_Admin_From__c != erm.Part_II_Exam_Admin_To__c && erm.Part_II_Exam_Registration__r.Exam_Site__r.Name == 'China') || erm.Part_II_Exam_Registration__r.Exam_Site__r.Name != 'China')){
                                   moveDataFee = true;
                            }else if(erm.Part_II_Exam_Registration__c != null 
                               && (erm.Part_II_Exam_Admin_From__c == erm.Part_II_Exam_Admin_To__c && erm.Part_II_Exam_Registration__r.Exam_Site__r.Name == 'China' && erm.Part_II_Exam_Registration__r.Defered__c == 'Pending')){
                                   moveDataFee = true;
                            }else if(erm.Part_II_Exam_Registration__c == null && erm.Part_I_Exam_Registration__r.Other_Exam_Registrations__c != null && erm.Part_I_Exam_Registration__r.Other_Exam_Registrations__r.Exam_Site__r.Name == 'China'
                                     && (erm.Part_I_Exam_Registration__r.Other_Exam_Registrations__r.cancelled__c == true || erm.Part_I_Exam_Registration__r.Other_Exam_Registrations__r.defered__c == 'Pending')){
                                   moveDataFee = true;
                            }else if(erm.Part_II_Exam_Registration__c == null && erm.Part_I_Exam_Registration__r.Other_Exam_Registrations__c == null){
                                   moveDataFee = true;
                            }
                        }
                    }else if(toDate != null && (frmDate == null || (frmDate != null && toDate < frmDate))){
                        if(frmDate != null){
                            negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer In';
                        }else{
                            negativeAmtClass = erm.Part_I_Exam_Admin_From__r.Month__c.substring(0,3)+' Defer In';
                        }
                        positiveAmtClass = convertMonthNumberToText(toDate.month())+' Defer Out';
                        deferralClass = convertMonthNumberToText(toDate.month())+' Registration';
                        deferralYear = string.valueof(toDate.year()).right(2);
                        negativeAmtDate = frmDate != null ? frmDate : erm.Part_I_Exam_Admin_From__r.Exam_Group__r.Exam_Date__c;
                        positiveAmtDate = opp.CloseDate;
                        addTemplateToNegAmt = true;
                        if(erm.Part_I_Exam_Registration__r.Section__c == 'FRM Part 1' && erm.Part_I_Exam_Registration__r.Exam_Site__r.Name == 'China' && !doNotMoveDataFee){
                            moveDataFee = true;
                        }
                    }
                    Opportunity origOpp = originalOppsMap.get(examRegToOppMap.get(erm.Part_I_Exam_Registration__c));
                    
                    for(OpportunityLineItem oli : origOpp.OpportunityLineItems){ //Chinnapa
                        if((erm.Part_I_Exam_Registration__r.Section__c == 'FRM Part 1' && oli.ProductCode.Contains('FRM1') && oppProductToMethodMap.containskey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' && oppProductToMethodMap.get(oli.ProductCode).Product_Sub_Category__c != 'Scholarship') 
                           || ((erm.Part_I_Exam_Registration__r.Section__c == 'SCR' && oli.ProductCode.Contains('SCR') || erm.Part_I_Exam_Registration__r.Section__c == 'RiskAI' && oli.ProductCode.Contains('RAI') || erm.Part_I_Exam_Registration__r.Section__c == 'RAIJ' && oli.ProductCode.Contains('RAIJ')) && oppProductToMethodMap.containskey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' && oppProductToMethodMap.get(oli.ProductCode).Product_Sub_Category__c != 'Scholarship')){
                               OpportunityLineItem oli1 = generateOppProd(opp.Id,oli,negativeAmtDate,negativeAmtClass,true,classMap,IntacctTemplateMap,null,addTemplateToNegAmt,IntacctProjectMap);
                               oliToInsert.add(oli1);
                               //lineNum++;
                               
                               OpportunityLineItem oli2 = generateOppProd(opp.Id,oli,positiveAmtDate,positiveAmtClass,false,classMap,IntacctTemplateMap,null,addTemplateToPostvAmt,IntacctProjectMap);
                               oliToInsert.add(oli2);
                               //lineNum++;
                               
                               if(erm.Part_I_Exam_Registration__r.Section__c == 'FRM Part 1' && erm.Part_I_Exam_Registration__r.Exam_Site__r.Name == 'China'){
                                   OpportunityLineItem oli3 = generateOppProd(opp.Id,oli,opp.CloseDate,negativeAmtClass,true,classMap,IntacctTemplateMap,ostapriceMap.get('CHLF'),false,IntacctProjectMap);
                                   oliToInsert.add(oli3);
                                   //lineNum++;
                                   
                                   OpportunityLineItem oli4 = generateOppProd(opp.Id,oli,opp.CloseDate,positiveAmtClass,false,classMap,IntacctTemplateMap,ostapriceMap.get('CHLF'),false,IntacctProjectMap);
                                   oliToInsert.add(oli4);
                                   //lineNum++;
                               }
                               
                               if(moveDataFee == true){
                                   OpportunityLineItem oli5 = generateOppProd(opp.Id,oli,opp.CloseDate,negativeAmtClass,true,classMap,IntacctTemplateMap,ostapriceMap.get('CHNDF'),false,IntacctProjectMap);
                                   oliToInsert.add(oli5);
                                   //lineNum++;
                                   
                                   OpportunityLineItem oli6 = generateOppProd(opp.Id,oli,opp.CloseDate,positiveAmtClass,false,classMap,IntacctTemplateMap,ostapriceMap.get('CHNDF'),false,IntacctProjectMap);
                                   oliToInsert.add(oli6);
                                   //lineNum++;
                                   dataFeeMoved = true;
                               }
                           }
                    }
                    
                }
                if(erm.Part_II_Exam_Registration__c != null && erm.Part_II_Exam_Admin_From__c != erm.Part_II_Exam_Admin_To__c){
                    date frmDate;
                    date toDate;
                    String negativeAmtClass;
                    String positiveAmtClass;
                    Date negativeAmtDate;
                    Date positiveAmtDate;
                    boolean addTemplateToNegAmt = false;
                    boolean addTemplateToPostvAmt = false;
                    boolean moveDataFee = false;
                    if(erm.Part_II_Exam_Part_From__c != null){
                        frmDate = erm.Part_II_Exam_Part_From__r.Exam_Date__c != null ? erm.Part_II_Exam_Part_From__r.Exam_Date__c : erm.Part_II_Exam_Part_From__r.Exam_Start_Date__c;
                    }else{
                        frmDate = null;
                    }
                    if(erm.Part_II_Exam_Part_To__c != null){
                        toDate = erm.Part_II_Exam_Part_To__r.Exam_Date__c != null ? erm.Part_II_Exam_Part_To__r.Exam_Date__c : erm.Part_II_Exam_Part_To__r.Exam_Start_Date__c;
                    }else{
                        toDate = null;
                    }

                    if(frmDate != null && (toDate == null || (toDate != null && frmDate < toDate))){
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Deferral'){
                            if(erm.Part_II_Exam_Registration__r.Previous_Deferral_Type__c == 'Postponed'){
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Makeup';
                            }else{
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer Out';
                            }
                            if(toDate != null){
                                positiveAmtClass = convertMonthNumberToText(toDate.month())+' Defer In';
                            }else{
                                positiveAmtClass = erm.Part_II_Exam_Admin_To__r.Month__c.substring(0,3)+' Defer In';
                            }
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Postponed'){
                            if(String.isBlank(erm.Part_II_Exam_Registration__r.Previous_Deferral_Type__c) && erm.Part_II_Exam_Registration__r.Deferral_Status__c == 'Defer In'){
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer In';
                            }else{
                                negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Postponed';
                            }
                            if(toDate != null){
                                positiveAmtClass = convertMonthNumberToText(toDate.month())+' Makeup';
                            }else{
                                positiveAmtClass = erm.Part_II_Exam_Admin_To__r.Month__c.substring(0,3)+' Makeup';
                            }
                        }
                        negativeAmtDate = opp.CloseDate;
                        positiveAmtDate = toDate != null ? toDate : erm.Part_II_Exam_Admin_To__r.Exam_Group__r.Exam_Date__c;
                        addTemplateToPostvAmt = true;
                        if(deferralClass == null)
                            deferralClass = convertMonthNumberToText(frmDate.month())+' Registration';
                        if(deferralYear == null)
                            deferralYear = string.valueof(frmDate.year()).right(2);
                        if(erm.Part_II_Exam_Registration__r.Section__c == 'FRM Part 2' && erm.Part_II_Exam_Registration__r.Exam_Site__r.Name == 'China' && !doNotMoveDataFee && !dataFeeMoved){
                            if(erm.Part_II_Exam_Registration__r.Other_Exam_Registrations__c != null && erm.Part_II_Exam_Registration__r.Other_Exam_Registrations__r.Exam_Site__r.Name != 'China'){
                               moveDataFee = true;
                            }
                        }
                    }else if(toDate != null && (frmDate == null || (frmDate != null && toDate < frmDate))){
                        if(frmDate != null){
                            negativeAmtClass = convertMonthNumberToText(frmDate.month())+' Defer In';
                        }else{
                            negativeAmtClass = erm.Part_II_Exam_Admin_From__r.month__c.substring(0,3)+' Defer In';
                        }
                        positiveAmtClass = convertMonthNumberToText(toDate.month())+' Defer Out';
                        negativeAmtDate = frmDate != null ? frmDate : erm.Part_II_Exam_Admin_From__r.Exam_Group__r.Exam_Date__c;
                        positiveAmtDate = opp.CloseDate;
                        addTemplateToNegAmt = true;
                        if(deferralClass == null)
                            deferralClass = convertMonthNumberToText(toDate.month())+' Registration';
                        if(deferralYear == null)
                            deferralYear = string.valueof(frmDate.year()).right(2);
                    }
                    Opportunity origOpp = originalOppsMap.get(examRegToOppMap.get(erm.Part_II_Exam_Registration__c));
                    for(OpportunityLineItem oli : origOpp.OpportunityLineItems){
                        if((erm.Part_II_Exam_Registration__r.Section__c == 'FRM Part 2' && oli.ProductCode.Contains('FRM2') && oppProductToMethodMap.containskey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam')){
                            OpportunityLineItem oli1 = generateOppProd(opp.Id,oli,negativeAmtDate,negativeAmtClass,true,classMap,IntacctTemplateMap,null,addTemplateToNegAmt,IntacctProjectMap);
                            oliToInsert.add(oli1);
                            //lineNum++;
                            
                            OpportunityLineItem oli2 = generateOppProd(opp.Id,oli,positiveAmtDate,positiveAmtClass,false,classMap,IntacctTemplateMap,null,addTemplateToPostvAmt,IntacctProjectMap);
                            oliToInsert.add(oli2);
                            //lineNum++;
                            
                            if(erm.Part_II_Exam_Registration__r.Exam_Site__r.Name == 'China'){
                                OpportunityLineItem oli3 = generateOppProd(opp.Id,oli,opp.CloseDate,negativeAmtClass,true,classMap,IntacctTemplateMap,ostapriceMap.get('CHLF'),false,IntacctProjectMap);
                                oliToInsert.add(oli3);
                                //lineNum++;
                                
                                OpportunityLineItem oli4 = generateOppProd(opp.Id,oli,opp.CloseDate,positiveAmtClass,false,classMap,IntacctTemplateMap,ostapriceMap.get('CHLF'),false,IntacctProjectMap);
                                oliToInsert.add(oli4);
                                //lineNum++;
                            }
                            
                            if(moveDataFee == true){
                                OpportunityLineItem oli5 = generateOppProd(opp.Id,oli,opp.CloseDate,negativeAmtClass,true,classMap,IntacctTemplateMap,ostapriceMap.get('CHNDF'),false,IntacctProjectMap);
                                oliToInsert.add(oli5);
                                //lineNum++;
                                
                                OpportunityLineItem oli6 = generateOppProd(opp.Id,oli,opp.CloseDate,positiveAmtClass,false,classMap,IntacctTemplateMap,ostapriceMap.get('CHNDF'),false,IntacctProjectMap);
                                oliToInsert.add(oli6);
                                //lineNum++;
                            }
                        }
                    }
                }
			}
            
            if(oppEAMap.size() > 0 && oppEAMap.containskey(opp.Id)){
                for(Exam_Attempt__c ea : oppEAMap.get(opp.Id)){
                    examClass = ea.RPT_Administration_Month__c.substring(0,3)+' Registration';
                    if(ea.Section__c == 'FRM Part 1' || ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ'){
                        break;
                    }
                }
            }
           Set<String> FRRSProductIds = new Set<String>();
           for(OpportunityLineItem oli : opp.opportunityLineItems){
               if(oli.ProductCode == 'FRRSNM' || oli.ProductCode == 'FRRSM'){
               		FRRSProductIds.add(oli.ProductCode);
               }
           }
            
             //integer lineNum = 1;
            for(OpportunityLineItem oli : opp.opportunityLineItems){
                //Epp Deal Net New 
                if(String.isNotBlank(oli.Epp_Project_Id__c)){
                    oli.EPP_Net_New__c = 'RC';
                    if(opp.EPP_Deal_Net_New__c == true){
                        oli.EPP_Net_New__c = 'NC';
                    } 
                }
                if(departmentMap.containsKey(oli.Product2.Department__c)){
                    //system.debug(oli.Product2.Department__c+'      <<::inside updateSageOLI inside departmentMap::>>>   '+departmentMap.get(oli.Product2.Department__c));
                    oli.ia_crm__Department__c = departmentMap.get(oli.Product2.Department__c);
                }
                if(oli.ia_crm__Class__c == null){
                    if(oppEventMap.containskey(opp.Id) && oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Event' )){
                        oli.ia_crm__Class__c = classMap.get(oppEventMap.get(opp.Id).Event__r.Class__c);
                    }else if(chapterMeetingMap.containskey(opp.Id) && oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Event' )){
                        oli.ia_crm__Class__c = classMap.get(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Class__c);
                    }else if(classMap.containsKey(oli.Product2.Class__c)){
                       // system.debug(oli.Product2.Class__c+'      <<::inside updateSageOLI inside classMap::>>>   '+classMap.get(oli.Product2.Class__c));
                        oli.ia_crm__Class__c = classMap.get(oli.Product2.Class__c);
                    }else if((oli.ProductCode == 'FRM1' || oli.ProductCode == 'SCR' || oli.ProductCode == 'RAI' || oli.ProductCode == 'RAIJ') && oli.Product2.GL_Code__c == '4020' && deferralClass != null && classMap.containsKey(deferralClass)){
                        oli.ia_crm__Class__c = classMap.get(deferralClass);
                        if(deferralYear != null){
                            if(oli.ProductCode == 'FRM1'){
                                oli.Product_ID__c = deferralYear+'FRMDefer';
                            }else if(oli.ProductCode == 'SCR'){
                                oli.Product_ID__c = deferralYear+'SCRDefer';
                            }else if(oli.ProductCode == 'RAI'){
                                oli.Product_ID__c = deferralYear+'RAIDefer';
                            }else if(oli.ProductCode == 'RAIJ'){
                                oli.Product_ID__c = deferralYear+'RAIJDefer';
                            }
                        }
                        //oli.Intacct_Template__c = IntacctTemplateMap.get('Exam');
                    //To get Class for CHNLF and CHNDF with reference id to make it specific to the exam admin
                    }else if(oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' ) 
                             && (oppProductToMethodMap.get(oli.ProductCode).Product_Sub_Category__c == 'OSTA' ) && oli.Reference_Id__c != null){
                        //Building the string for class from reference id and it is supposed to be camel case
                        oli.ia_crm__Class__c = classMap.get(oli.Reference_Id__c.substring(5,6)+oli.Reference_Id__c.substring(6,8).toLowercase()+' Registration');
                    }else if(oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' )){
                        oli.ia_crm__Class__c = classMap.get(examClass);
                    }else if(oppProductToMethodMap.containsKey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Enroll' && oli.ia_crm__Class__c == null){
                        oli.ia_crm__Class__c = classMap.get(examClass);
                    }
                }
                if(oppEventMap.containskey(opp.Id) && oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Event' )){
                    oli.ia_crm__Intacct_Location__c = IntacctEntityMap.containskey(oppEventMap.get(opp.Id).Event__r.Location__c) ? IntacctEntityMap.get(oppEventMap.get(opp.Id).Event__r.Location__c) : null;
                    oli.ServiceDate = oppEventMap.get(opp.Id).RPT_Event_Start_Date__c;
                    oli.Intacct_Template__c = IntacctTemplateMap.get('Event');
                    oli.Site_Code__c = IntacctUserDimensionMap.containskey(oppEventMap.get(opp.Id).Event__r.Site_Code__c) ? IntacctUserDimensionMap.get(oppEventMap.get(opp.Id).Event__r.Site_Code__c) : null;
                    oli.ia_crm__Project__c = IntacctProjectMap.containskey(oppEventMap.get(opp.Id).Event__r.Project__c) ? IntacctProjectMap.get(oppEventMap.get(opp.Id).Event__r.Project__c) : null;
                }else if(chapterMeetingMap.containskey(opp.Id) && oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Event' )){
                    oli.ia_crm__Intacct_Location__c = IntacctEntityMap.containskey(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Location__c) ? IntacctEntityMap.get(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Location__c) : null;
                    oli.ServiceDate = chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Start_Date__c;
                    oli.Intacct_Template__c = IntacctTemplateMap.get('Event');
                    oli.Site_Code__c = IntacctUserDimensionMap.containskey(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Site_Code__c) ? IntacctUserDimensionMap.get(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Site_Code__c) : null;
                    oli.ia_crm__Project__c = IntacctProjectMap.containskey(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Project__c) ? IntacctProjectMap.get(chapterMeetingMap.get(opp.Id).Chapter_Meeting__r.Project__c) : null;
                }else{
                    oli.ia_crm__Intacct_Location__c = IntacctEntityMap.containskey(oli.Product2.Location__c) ? IntacctEntityMap.get(oli.Product2.Location__c) : null;
                    if(oppProductToMethodMap.containsKey(oli.ProductCode) 
                       && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' || (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Enroll' && oli.Product2.Gl_Code__c == '4010'))
                       && oppProductToMethodMap.get(oli.ProductCode).Product_Sub_Category__c != 'OSTA'
                       && opp.CloseDate.month() == 12){
                           date newDate = date.newinstance(opp.CloseDate.year()+1,1,1);
                           oli.ServiceDate = newDate;
                           oli.Intacct_Template__c = IntacctTemplateMap.get('Exam');
                    }else if(oli.ServiceDate == null){
                        oli.ServiceDate = opp.CloseDate;
                    }
                    if(String.isNotBlank(oli.Reference_Id__c)){
                        oli.ia_crm__Project__c = IntacctProjectMap.containskey(oli.Reference_Id__c) ? IntacctProjectMap.get(oli.Reference_Id__c) : null;
                    }
                    //Epp Project Id
                    if(String.isNotBlank(oli.Epp_Project_Id__c)){ 
                         oli.ia_crm__Project__c = IntacctProjectMap.containskey(oli.Epp_Project_Id__c) ? IntacctProjectMap.get(oli.Epp_Project_Id__c) : null;
                    }
                }
                //oli.Line_No__c = lineNum;
                //lineNum++;
                
                if(oppProductToMethodMap.containsKey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Exam' && oppProductToMethodMap.get(oli.ProductCode).Product_Sub_Category__c != 'Scholarship'){
                    string siteId = Sage_Default_Records_Ref__mdt.getInstance('Unallocated_Site_Id').value__c;
                    oli.Site_Code__c = siteId;
                    
                }
                
                if(wareHouseMap != null && wareHouseMap.containskey(oli.ProductCode)){
                    Set<String> PrCodes = new Set<String>{'22FRM1X','22FRM2X','22SCRX','21FRM1X','21FRM2X','21SCRX','20FRM1X','20FRM2X','20SCRX'};
                    if(oli.Product_ID__c != null && PrCodes.contains(oli.Product_ID__c)){
                        oli.Warehouse__c = '5';
                    }else{
                    	oli.Warehouse__c = String.valueof(wareHouseMap.get(oli.ProductCode));
                    }
                }
                
                if(oppProductToMethodMap.containsKey(oli.ProductCode) && oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Membership'){
                    oli.Sage_Reporting_Country__c = opp.Billing_Country__c;
                    oli.Sage_Reporting_State__c = opp.Billing_State_Text__c;
                    if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Refund' || opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Switch'){
                        oli.Intacct_Template__c = IntacctTemplateMap.get('Membership Refund');
                    }else if(oppProductToMethodMap.get(oli.ProductCode).Map_Key__c == 'IndividualMemberHalfYear'){
                        oli.Intacct_Template__c = IntacctTemplateMap.get('Membership6');
                    }else{
                        oli.Intacct_Template__c = IntacctTemplateMap.get('Membership');
                    }
                    if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Sales Invoice' && garpIdToMemPrgrm.containskey(opp.AccountId) ){
                        if(oppProductToMethodMap.get(oli.ProductCode).Map_Key__c == 'IndividualMemberHalfYear'){
                            oli.ServiceDate = garpIdToMemPrgrm.get(opp.AccountId).EndDate.addMonths(-6).addDays(1);
                        }else{
                            oli.ServiceDate = garpIdToMemPrgrm.get(opp.AccountId).EndDate.addYears(-1).addDays(1);
                        }
                    }
                }else if(oppProductToMethodMap.containsKey(oli.ProductCode) && (oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Tax' 
                                                                                || oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Books'
                                                                                || oppProductToMethodMap.get(oli.ProductCode).Product_Category__c == 'Ship')){
                    if(String.isNotBlank(opp.Shipping_Country__c)){
                        oli.Sage_Shipping_Country__c = opp.Shipping_Country__c;
                        oli.Sage_Shipping_State__c = opp.Shipping_State__c;
                    }
                    oli.Sage_Reporting_Country__c = opp.Billing_Country__c;
                    oli.Sage_Reporting_State__c = opp.Billing_State_Text__c;
                }else{
                    oli.Sage_Reporting_Country__c = opp.Billing_Country__c;
                    oli.Sage_Reporting_State__c = opp.Billing_State_Text__c;
                }
                Site_Code_MDT__mdt siteCodeMDT = new Site_Code_MDT__mdt();
                
                if(String.isNotBlank(oli.Sage_Shipping_Country__c) && siteCodeMap.containskey(oli.Sage_Shipping_Country__c)){
                    siteCodeMDT = siteCodeMap.get(oli.Sage_Shipping_Country__c);
                }else if(String.isNotBlank(oli.Sage_Shipping_Country__c) && oli.Sage_Shipping_Country__c == 'United States'){
                    siteCodeMDT = siteCodeMap.get('United States of America (USA)');
                }else if(String.isNotBlank(oli.Sage_Reporting_Country__c) && siteCodeMap.containskey(oli.Sage_Reporting_Country__c)){
                    siteCodeMDT = siteCodeMap.get(oli.Sage_Reporting_Country__c);
                }else if(String.isNotBlank(oli.Sage_Reporting_Country__c) && oli.Sage_Reporting_Country__c == 'United States'){
                    siteCodeMDT = siteCodeMap.get('United States of America (USA)');
                }else{
                    siteCodeMDT = null;
                }
                
               // system.debug(oli.Sage_Reporting_Country__c+'      <<::inside updateSageOLI  siteCodeMDT::>>>   '+siteCodeMDT);
                
                if(oli.Site_Code__c == null && siteCodeMDT != null && IntacctUserDimensionMap!= null && IntacctUserDimensionMap.containsKey(siteCodeMDT.Code__c)){
                   // system.debug(oli.Sage_Reporting_Country__c+'      <<::inside updateSageOLI  IntacctUserDimensionMap::>>>   '+IntacctUserDimensionMap.get(siteCodeMDT.Code__c));
                    oli.Site_Code__c = IntacctUserDimensionMap.get(siteCodeMDT.Code__c);
                }
                
                if(opp.Payment_Method_New__c == 'Credit Card'){
                    if(opp.Gateway__c != null && opp.Gateway__c == gateway){
                        oli.Vendor_Name__c = 'Stripe';
                        oli.Vendor_ID__c = 'V00873';
                    }else{
                        if(opp.CardType__c != null && opp.CardType__c == 'AMEX'){
                            oli.Vendor_Name__c = 'American Express';
                            oli.Vendor_ID__c = 'V00427';
                        }else if(opp.CardType__c != null){
                            oli.Vendor_Name__c = 'First Data';
                            oli.Vendor_ID__c = 'V00097';
                        }
                    }
                }else if(opp.Payment_Method_New__c == 'Alipay' || opp.Payment_Method_New__c == 'Wechatpay'){
                    oli.Vendor_Name__c = 'Stripe';
                    oli.Vendor_ID__c = 'V00873';
                }else if(opp.Payment_Method_New__c == 'Wire Transfer'){
                    oli.Vendor_Name__c = 'Wire Transfer';
                    oli.Vendor_ID__c = 'V00657';
                }else if(opp.Payment_Method_New__c == 'Check'){
                    oli.Vendor_Name__c = 'Check';
                    oli.Vendor_ID__c = 'V00658';
                }else if(opp.Payment_Method_New__c == 'ACH'){
                    oli.Vendor_Name__c = 'ACH';
                    oli.Vendor_ID__c = 'V00659';
                }else if(opp.Payment_Method_New__c == 'Charge Back Accepted'){
                    oli.Vendor_Name__c = 'Chargeback Accepted';
                    oli.Vendor_ID__c = 'V00675';
                }else if(opp.Payment_Method_New__c == 'Charge Back Loss'){
                    oli.Vendor_Name__c = 'Chargeback Loss';
                    oli.Vendor_ID__c = 'V00676';
                }
                
                if(oli.ProductCode == 'CBRD'){
                    if(oli.TotalPrice == -150){
                        oli.Product_ID__c = 'FRRNMD';
                    }else if(oli.TotalPrice == -50){
                        oli.Product_ID__c = 'FRRMD';
                    }
                }
                //Case #00853997
                if(oli.ProductCode == 'FRRSD'){
                    if(FRRSProductIds.contains('FRRSNM')){
                        oli.Product_ID__c = 'FRRNMD';
                    }else if(FRRSProductIds.contains('FRRSM')){
                        oli.Product_ID__c = 'FRRMD';
                    }
                }
                
                if(String.isNotBlank(opp.Tax_Authority__c)){
                    oli.Tax_Authority__c = opp.Tax_Authority__c;
                }
                if(opp.Tax_Region__c != null && opp.Tax_Region__c != ''){
                    oli.Tax_Region__c = opp.Tax_Region__c;
                }
                
                oliToUpdate.add(oli);
            }
        }
        
        if(accToUpdate.size() > 0){
            update accToUpdate;
        }
        
        if(!oliToUpdate.isEmpty()){
            update oliToUpdate;
        }
        
        if(!oliToInsert.isEmpty()){
            insert oliToInsert;
        }
    }
    
    private static opportunityLineItem generateOppProd(string oppId,opportunityLineItem oli,date serviceDate,string revClass,boolean negativeAmt,Map<String,String> classMap,Map<String,String> IntacctTemplateMap,PriceBookEntry pbe,boolean addTemplate,Map<String,String> IntacctProjectMap){
        string siteId = Sage_Default_Records_Ref__mdt.getInstance('Unallocated_Site_Id').value__c;
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.serviceDate = serviceDate;
        oli1.OpportunityId = oppId;
        oli1.Quantity = 1;
        oli1.ia_crm__Class__c = classMap.get(revClass);
        oli1.ia_crm__Department__c = oli.ia_crm__Department__c;
        oli1.ia_crm__Intacct_Location__c = oli.ia_crm__Intacct_Location__c;
        oli1.Sage_Reporting_Country__c = oli.Sage_Reporting_Country__c;
        oli1.Sage_Shipping_Country__c = oli.Sage_Shipping_Country__c;
        oli1.Sage_Reporting_State__c = oli.Sage_Reporting_State__c;
        oli1.Sage_Shipping_State__c = oli.Sage_Shipping_State__c;
        oli1.Site_Code__c = siteId;
        oli1.Do_Not_Show_on_Invoice__c = true;
        oli1.For_Sage_Sync_Only__c = true;
        oli1.ia_crm__Project__c = oli.ia_crm__Project__c;
        oli1.Reference_Id__c = oli.Reference_Id__c;
        //For Location Fee
        if(pbe != null){
            oli1.Product2Id = pbe.Product2Id;
            oli1.PricebookEntryId = pbe.Id; 
            oli1.Reference_Id__c = oli.Product_ID__c;
            if(string.isnotblank(oli1.Reference_Id__c) && IntacctProjectMap.containskey(oli1.Reference_Id__c)){
                oli1.ia_crm__Project__c = IntacctProjectMap.get(oli1.Reference_Id__c);
            }
            //Epp Sage Project
            if(String.isNotBlank(oli.Epp_Project_Id__c) && IntacctProjectMap.containskey(oli.Epp_Project_Id__c)){
                 oli1.ia_crm__Project__c = IntacctProjectMap.get(oli.Epp_Project_Id__c);
            }
            string deferralYear = oli.Product_ID__c.substring(0,2);
            if(pbe.Product2.ProductCode == 'CHNDF'){
                oli1.Product_ID__c = deferralYear+'FRMCHNDF';
            }else if(pbe.Product2.ProductCode == 'CHLF'){
                oli1.Product_ID__c = deferralYear+'FRMCHNLF';
            }
            //oli1.Product_ID__c = pbe.Product2.Product_ID__c;
            if(negativeAmt){
                oli1.UnitPrice = pbe.UnitPrice*(-1);
            }else{
                oli1.UnitPrice = pbe.UnitPrice;
            }
        }else{
            oli1.Product2Id = oli.Product2Id;
            oli1.PricebookEntryId = oli.PricebookEntryId;
            oli1.Product_ID__c = oli.Product_ID__c;
            if(negativeAmt){
                oli1.UnitPrice = oli.UnitPrice*(-1);
            }else{
                oli1.UnitPrice = oli.UnitPrice;
            }
            if(addTemplate == true){
                oli1.Intacct_Template__c = IntacctTemplateMap.get('Exam');
            }
        }
        return oli1;
    }
    
    private static String convertMonthNumberToText(Integer month){
       /* if(matrixMonth == 1){
            return 'Jan';   
        }else if(matrixMonth == 2){
            return 'Feb';   
        }else if(matrixMonth == 3){
            return 'Mar';   
        }else if(matrixMonth == 4){
            return 'Apr';   
        }else if(matrixMonth == 5){
            return 'May';       
        }else if(matrixMonth == 6){            
            return 'Jun';   
        }else if(matrixMonth == 7){
            return 'Jul';   
        }else if(matrixMonth == 8){
            return 'Aug';   
        }else if(matrixMonth == 9){
            return 'Sep';   
        }else if(matrixMonth == 10){
            return 'Oct';  
        }else if(matrixMonth == 11){
            return 'Nov';  
        }else{
            return 'Dec';
        }*/
        if(month == null){
            return '';
        }
        List<String> months = new List<String>{
            'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
        };
		return months[month - 1];
    }

}