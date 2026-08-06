global class batchExamPartConversion implements Database.Batchable<sObject>,Database.StateFul{
    private Failed_Exams_Setup__mdt setupData = Failed_Exams_Setup__mdt.getInstance('FRM');
    private string ExamGroupId = setupData.Exam_Group_For_Query__c;
    private string examAdminForResults = setupData.Exam_Admin_For_Query__c;
    private date conversionDate = setupData.Conversion_Date__c;
    private string examType;
    private string recordId;
    private boolean selectedRegonly;
    public batchExamPartConversion(string examTypeStr,boolean selectedReg){
        examType = examTypeStr;
        selectedRegonly = selectedReg;
    }
    public batchExamPartConversion(string examTypeStr,boolean selectedReg,string inputRecordId){
        examType = examTypeStr;
        recordId = inputRecordId;
        selectedRegonly = selectedReg;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        //run this batch for only one record at once.
        Set<String> strSection = new Set<String>{examType};
        String StrDefered = 'Approved';
        String oppstatus = 'closed';
        String passResult = 'Pass';
        
        String query1 = 'SELECT Id,Opportunity__c,Defered__c,Cloned_From__r.Deferral_SubType__c,Deferral_Status__c,Exam_Site__c,Exam_Site__r.Name,Exam_Administration__c,Exam_Site__r.Exam__c,Member__c,Site_code__c,Candidate_Commitment__c ,Exam_Site__r.Site__c,ADA_Status__c,RAD_Status__c,Opportunity_StageName__c ,Other_Exam_Registrations__c,Site_Id__c,Exam_Part__r.Exam_Start_Date__c FROM Exam_Attempt__c Where Section__c IN:strSection';
        query1 += ' AND Exam_Site__r.Exam__r.Exam_Group__c =:examGroupId';
        query1 += ' AND Exam_Administration__c =: examAdminForResults'; 
        query1 += ' AND Opportunity_StageName__c =:oppstatus';                 
        query1 += ' AND Cancelled__c != true';
        query1 += ' AND Updated_to_FRM_1__c = true';
        query1 += ' AND Convert_Invoice_Created__c = false';
        if(String.isNotBlank(recordId)) {
            query1 += ' AND Id=: recordId';
        }
        if(selectedRegonly == true){
            query1 += ' AND Select_to_move__c = true';
        }
        
        if(test.isRunningTest()){
            query1 = 'SELECT Id,Opportunity__c,Defered__c,Cloned_From__r.Deferral_SubType__c,Deferral_Status__c,Exam_Site__c,Exam_Site__r.Name,Exam_Administration__c,Exam_Site__r.Exam__c,Member__c,Candidate_Commitment__c,Site_code__c,Exam_Site__r.Site__c,ADA_Status__c,RAD_Status__c,Opportunity_StageName__c ,Other_Exam_Registrations__c,Site_Id__c,Exam_Part__r.Exam_Start_Date__c FROM Exam_Attempt__c Where Section__c IN:strSection';
            query1 += ' AND Opportunity_StageName__c =:oppstatus';  
            query1 += ' AND  Cancelled__c != true';
            query1 += ' AND Result__c != null Limit 1';
        }              
        
        return Database.getQueryLocator(query1);      
        
    }
    
    global void execute(Database.BatchableContext BC, List<Exam_Attempt__c> scope){
        set<Id> oppIds = new Set<Id>();
        Set<Id> oppsToIncludeDefrl = new Set<Id>();
        Set<String> productCodesPart2 = new Set<String>{'FRM2E','FRM2S'};
        List<Opportunity> oppsToInsert = new List<Opportunity>();
        List<Exam_Attempt__c> regToUpdate = new List<Exam_Attempt__c>();
        Map<String,String> classMap = new Map<String,String>();
        Map<String,String> IntacctTemplateMap = new Map<String,String>();
        Map<String,Date> serviceDateDeffMap = new Map<String,Date>();
        for(ia_crm__Class__c cls : [SELECT ia_crm__Class_ID__c,ia_crm__Status__c,Id,Name FROM ia_crm__Class__c LIMIT 2000]){
			classMap.put(cls.Name,cls.Id);
		}
        for(ia_crm__Revenue_Recognition_Template__c temp : [Select ID,Name from ia_crm__Revenue_Recognition_Template__c Where Name = 'Exam']){
            IntacctTemplateMap.put(temp.Name, temp.Id);
        }
        List<String> pcList = new List<String>{'FRM1E','FRM1S'};
        Map<String,PricebookEntry> pbeMap = new Map<String,PricebookEntry>();
        
        for(PricebookEntry pbe : [SELECT Id,Product2Id,UnitPrice,Product2.ProductCode,Product2.Product_Id__c FROM PricebookEntry 
                                  WHERE Product2.ProductCode IN : pcList AND Pricebook2.IsActive = TRUE AND Pricebook2.Name = 'GARP 2015/2016'])
        {
            pbeMap.put(pbe.Product2.Product_Id__c.substring(2),pbe);
        }
        
        for(Exam_Attempt__c objList : scope){
            oppIds.add(objList.Opportunity__c);
            if(objList.Defered__c == 'Approved')
                oppsToIncludeDefrl.add(objList.Opportunity__c);
        }
        
        Map<Id,Opportunity> oppsMap = new Map<Id,Opportunity>([Select Id,AccountId,Shipping_Address1__c,Shipping_Address2__c,Shipping_Address3__c,Shipping_City__c,Shipping_Country__c,Shipping_State__c,
                                     Billing_First_Name__c,Billing_Last_Name__c,Billing_Email__c,Billing_Phone__c,
                                     Billing_Address__c,Billing_Address_Line_2__c,Billing_City__c,Billing_State_Text__c,
                                     Billing_Country__c,Billing_Zip_Postal__c,Billing_Company__c,Additional_Invoice_Information__c,
                                     Payment_Method__c,Payment_Received__c,Gateway__c,CardType__c,EA_Id__c,
                                     (Select Id,ProductCode,Product_Id__c,Product2Id,UnitPrice,Quantity,PriceBookEntryid from OpportunityLineItems where ProductCode IN: productCodesPart2) 
                                     from Opportunity where Id IN: oppIds]);
        
        for(Exam_Attempt__c objScope : scope)
        {
            if(objScope.Exam_Administration__c != null){
                
                if(oppsMap.containsKey(objScope.Opportunity__c)){
                    Opportunity opp = oppsMap.get(objScope.Opportunity__c).clone(false,true);
                    opp.StageName = 'New Lead';
                    opp.CloseDate = conversionDate;
                    opp.ia_crm__Intacct_Transaction__c = 'Salesforce - Convert Register';
                    opp.Payment_Method_New__c = 'Convert';
                    opp.Name = 'Exam Registration Conversion';
                    opp.Cloned_From__c = objScope.Opportunity__c;
                    opp.EA_Id__c = objScope.Id;
                    oppsToInsert.add(opp);
                    
                    if(oppsToIncludeDefrl.contains(objScope.Opportunity__c)){
                        Opportunity opp1 = oppsMap.get(objScope.Opportunity__c).clone(false,true);
                        opp1.StageName = 'New Lead';
                        opp1.CloseDate = conversionDate;
                        if(objScope.Cloned_From__r.Deferral_Subtype__c == 'Deferral Postponement'){
                            opp1.ia_crm__Intacct_Transaction__c = 'Salesforce - Convert Postponed';
                            opp1.Name = 'Exam Postponement Conversion';
                        }else{
                            opp1.ia_crm__Intacct_Transaction__c = 'Salesforce - Convert Deferral';
                            opp1.Name = 'Exam Deferral Conversion';
                            serviceDateDeffMap.put(objScope.Id,objScope.Exam_Part__r.Exam_Start_Date__c);
                        }
                        opp1.Payment_Method_New__c = 'Convert';
                        opp1.Cloned_From__c = objScope.Opportunity__c;
                        opp1.EA_Id__c = objScope.Id;
                        oppsToInsert.add(opp1);
                    }
                    
                    objscope.Convert_Invoice_Created__c = true;
                    objscope.Original_Exam_Site__c = objScope.Exam_Site__r.Name;
                    objscope.Select_to_move__c = false;
                    regToUpdate.add(objscope);
                }
               
            }
        }
        
        if(!oppsToInsert.isEmpty()){
            insert oppsToInsert;
        }
        
        Map<String,Opportunity> oridToClonOpp = new Map<String,Opportunity>();
        List<OpportunityLineItem> oliToInsert = new List<OpportunityLineItem>();
        List<ChargentOrders__Transaction__c> newChrgntTransList = new List<ChargentOrders__Transaction__c>();
        List<Opportunity> insertedOpps = [Select Id,Cloned_From__c,ia_crm__Intacct_Transaction__c,EA_Id__c,
                                          (Select Id,ChargentOrders__Transaction_Total__c from Chargent_Orders__r) 
                                          from Opportunity where Id IN: oppsToInsert];
        
        Map<Id,List<Opportunity>> origOppToClonedOpps = new Map<Id,List<Opportunity>>();
        for(Opportunity opp :  insertedOpps){
            if(origOppToClonedOpps.containskey(opp.Cloned_From__c)){
                List<Opportunity> opps = origOppToClonedOpps.get(opp.Cloned_From__c);
                opps.add(opp);
                origOppToClonedOpps.put(opp.Cloned_From__c,opps);
            }else{
                origOppToClonedOpps.put(opp.Cloned_From__c,new List<Opportunity>{opp});
            }
        }
        
        for(Opportunity origOpp : oppsMap.values()){
            if(origOppToClonedOpps.containskey(origOpp.id)){
                OpportunityLineItem part2item = origOpp.OpportunityLineItems[0];
                String part1Id = part2item.Product_ID__c.substring(0,2)+part2item.Product_ID__c.substring(2).replace('2','1');
                PriceBookEntry pbePart1 = pbeMap.get(part1Id.substring(2));
                
                for(opportunity opp : origOppToClonedOpps.get(origOpp.id)){
                    if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Register'){
                        OpportunityLineItem oliPart2 = part2item.clone(false,true);
                        oliPart2.UnitPrice = -1 * oliPart2.UnitPrice;
                        oliPart2.OpportunityId = opp.id;
                        oliPart2.Description = 'Convert to Part 1';
                        if(oppsToIncludeDefrl.contains(origOpp.Id)){
                            oliPart2.ia_crm__Class__c = classMap.get(setupData.Registration_Class_For_Deferral__c);
                        }else{
                            oliPart2.ia_crm__Class__c = classMap.get(setupData.Registration_Class__c);
                        }
                        oliToInsert.add(oliPart2);
                        
                        OpportunityLineItem oliPart1 = part2item.clone(false,true);
                        oliPart1.PricebookEntryId = pbePart1.Id;
                        oliPart1.Product2Id = pbePart1.Product2Id;
                        oliPart1.Product_Id__c = part1Id;
                        oliPart1.OpportunityId = opp.id;
                        if(oppsToIncludeDefrl.contains(origOpp.Id)){
                            oliPart1.ia_crm__Class__c = classMap.get(setupData.Registration_Class_For_Deferral__c);
                        }else{
                            oliPart1.ia_crm__Class__c = classMap.get(setupData.Registration_Class__c);
                        }
                        oliToInsert.add(oliPart1);
                    }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Deferral' || opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Postponed'){
                        OpportunityLineItem oliPart2DfrIn = part2item.clone(false,true);
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Deferral'){
                            oliPart2DfrIn.ia_crm__Class__c = classMap.get(setupData.Defer_In_Class__c);
							oliPart2DfrIn.Intacct_Template__c = IntacctTemplateMap.get('Exam');
                            if(opp.EA_Id__c != null && serviceDateDeffMap.containsKey(opp.EA_Id__c))
                            oliPart2DfrIn.ServiceDate = serviceDateDeffMap.get(opp.EA_Id__c); 
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Postponed'){
                            oliPart2DfrIn.ia_crm__Class__c = classMap.get(setupData.Makeup_Class__c);
                        }
                        oliPart2DfrIn.UnitPrice = -1 * oliPart2DfrIn.UnitPrice;
                        oliPart2DfrIn.OpportunityId = opp.id;
                        oliPart2DfrIn.Do_Not_Show_on_Invoice__c = true;
                        oliPart2DfrIn.For_Sage_Sync_Only__c = true;
                        oliToInsert.add(oliPart2DfrIn);
                        
                        OpportunityLineItem oliPart2DfrOut = part2item.clone(false,true);
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Deferral'){
                            oliPart2DfrOut.ia_crm__Class__c = classMap.get(setupData.Defer_Out_Class__c);
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Postponed'){
                            oliPart2DfrOut.ia_crm__Class__c = classMap.get(setupData.Postpone_Class__c);
                        }
                        oliPart2DfrOut.OpportunityId = opp.id;
                        oliPart2DfrOut.Do_Not_Show_on_Invoice__c = true;
                        oliPart2DfrOut.For_Sage_Sync_Only__c = true;
                        oliToInsert.add(oliPart2DfrOut);
                        
                        OpportunityLineItem oliPart1DfrIn = part2item.clone(false,true);
                        oliPart1DfrIn.PricebookEntryId = pbePart1.Id;
                        oliPart1DfrIn.Product2Id = pbePart1.Product2Id;
                        oliPart1DfrIn.Product_Id__c = part1Id;
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Deferral'){
                            oliPart1DfrIn.ia_crm__Class__c = classMap.get(setupData.Defer_In_Class__c);
                            oliPart1DfrIn.Intacct_Template__c = IntacctTemplateMap.get('Exam'); 
                            if(opp.EA_Id__c != null && serviceDateDeffMap.containsKey(opp.EA_Id__c))
                                oliPart1DfrIn.ServiceDate = serviceDateDeffMap.get(opp.EA_Id__c); 
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Postponed'){
                            oliPart1DfrIn.ia_crm__Class__c = classMap.get(setupData.Makeup_Class__c);
                        }
                        oliPart1DfrIn.OpportunityId = opp.id;
                        oliPart1DfrIn.Do_Not_Show_on_Invoice__c = true;
                        oliPart1DfrIn.For_Sage_Sync_Only__c = true;
                        oliToInsert.add(oliPart1DfrIn);
                        
                        OpportunityLineItem oliPart1DfrOut = part2item.clone(false,true);
                        oliPart1DfrOut.UnitPrice = -1 * oliPart1DfrOut.UnitPrice;
                        oliPart1DfrOut.PricebookEntryId = pbePart1.Id;
                        oliPart1DfrOut.Product2Id = pbePart1.Product2Id;
                        oliPart1DfrOut.Product_Id__c = part1Id;
                        if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Deferral'){
                            oliPart1DfrOut.ia_crm__Class__c = classMap.get(setupData.Defer_Out_Class__c);
                        }else if(opp.ia_crm__Intacct_Transaction__c == 'Salesforce - Convert Postponed'){
                            oliPart1DfrOut.ia_crm__Class__c = classMap.get(setupData.Postpone_Class__c);
                        }
                        oliPart1DfrOut.OpportunityId = opp.id;
                        oliPart1DfrOut.Do_Not_Show_on_Invoice__c = true;
                        oliPart1DfrOut.For_Sage_Sync_Only__c = true;
                        oliToInsert.add(oliPart1DfrOut);    
                    }
                    
                    ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
                    trans.Opportunity__c = opp.Id;
                    trans.ChargentOrders__Order__c = opp.Chargent_Orders__r[0].Id;
                    trans.ChargentOrders__Amount__c = 0.00;
                    trans.ChargentOrders__Response_Message__c = 'Approved';
                    trans.ChargentOrders__Response_Status__c = 'Approved';
                    trans.ChargentOrders__Type__c = 'Charge';
                    trans.ChargentOrders__Payment_Method__c = 'Convert';
                    Time convTime = Time.newInstance(12, 0, 0, 0);
                    trans.ChargentOrders__Gateway_Date__c =DateTime.newInstance(conversionDate, convTime);
                    newChrgntTransList.add(trans);
                }
            }
        }
        
        if(!oliToInsert.isEmpty()){
            insert oliToInsert;
        }
        
        if(!newChrgntTransList.isEmpty()){
            insert newChrgntTransList;
        }
        
        if(!regToUpdate.isEmpty()){
            update regToUpdate;
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}