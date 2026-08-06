public without sharing class MemberServicesTool_Controller {
    public static Set<String> examPartsdata = new Set<String>{'FRM Part 1','FRM Part 2','SCR','RiskAI','RAIJ'};
    @AuraEnabled
    Public Static List<Exam_Attempt__c> getRegistrations(String garpId){
        List<Exam_Attempt__c> regList = new List<Exam_Attempt__c>(); 
        if(String.isNotBlank(garpId)){
            regList = [Select Id,Name,Section__c,Exam_Date__c,Exam_Site__c,Exam_Administration__c,Candidate_Commitment__c,
                                Exam_Administration__r.Name,Exam_Site__r.Name,Exam_Part__c,Result__c,
                                Exam_Administration__r.Exam_Group__c,Exam_Administration__r.Exam_Group__r.Next_Exam_Group__c,
                                Exam_Administration__r.Exam_Group__r.Active__c,Exam_Administration__r.Exam_Group__r.SCR_Active__c
                                from Exam_Attempt__c 
                                where Garp_Id__c =: garpId
                                AND Section__c IN: examPartsdata
                                AND Cancelled__c = False
                                AND Opportunity_StageName__c ='closed'
                                AND (Result__c =null OR Result__c ='No-Show')
                                AND Defered__c != 'Pending'];        
        }
        return regList;
    }
    @AuraEnabled
    Public Static List<Exam_Group__c> getExamGroups(List<Exam_Attempt__c> examAttemptList){
        boolean isFRM = false;
        boolean isSCR = false;
        boolean isRiskAI = false;
        boolean isRAIJ = false;
        date activeGrpDate;
        List<Exam_Group__c> grpList = new List<Exam_Group__c>();
        for(Exam_Attempt__c ea: examAttemptList){
            if(ea.Section__c.contains('FRM')){
                isFRM = true;
            }else if(ea.Section__c.contains('SCR')){
                isSCR = true;
            }else if(ea.Section__c.contains('RiskAI')){  
                isRiskAI = true;
            }else if(ea.Section__c.contains('RAIJ')){ 
                isRAIJ = true;
            }
        } 
        List<Exam_Group__c> exmGrpList = [Select Id,Name,Next_Exam_Group__c,Active__c,SCR_Active__c,Exam_Date__c,RecordType.DeveloperName from Exam_Group__c Order By Exam_Date__c ASC];
        for(Exam_Group__c eg: exmGrpList){
            String rtypeName = eg.RecordType.DeveloperName;
            if((isFRM && eg.Active__c && rtypeName == 'FRM_ERP') || (isSCR && eg.SCR_Active__c && rtypeName == 'SCR') || (isRiskAI && eg.Active__c && rtypeName == 'RiskAI') || (isRAIJ && eg.Active__c && rtypeName == 'RAIJ')){
                activeGrpDate = eg.Exam_Date__c;
            }
        } 
        for(Exam_Group__c eg: exmGrpList){
          /*  if(eg.Exam_Date__c >= activeGrpDate){
                if(isFRM && eg.RecordType.DeveloperName == 'FRM_ERP'){
                    grpList.add(eg);
                }else if(isSCR && eg.RecordType.DeveloperName == 'SCR'){
                    grpList.add(eg);
                }else if(isRiskAI && eg.RecordType.DeveloperName == 'RiskAI'){
                    grpList.add(eg);
                }else if(isRAIJ && eg.RecordType.DeveloperName == 'RiskAI'){
                    grpList.add(eg);
                }
            }*/
            
            if (eg.Exam_Date__c >= activeGrpDate) {
                String devName = eg.RecordType.DeveloperName;                
                if (
                    (isFRM && devName == 'FRM_ERP') ||
                    (isSCR && devName == 'SCR') ||
                    (isRiskAI && devName == 'RiskAI') ||
                    (isRAIJ && devName == 'RAIJ')
                ) {
                    grpList.add(eg);
                }
            }
        }
        return grpList;
    }
    @AuraEnabled
    Public Static Map<Integer,Map<Id,Exam_Administration__c>> getExamAdministrations(string examGroupId,List<Exam_Attempt__c> examAttemptList){
        List<Exam_Part__c> examPartList = new List<Exam_Part__c>();
        Map<Integer,Map<Id,Exam_Administration__c>> partToAdminMap = new Map<Integer,Map<Id,Exam_Administration__c>>();
        Set<Id> examAdminIds = new Set<Id>();
        for(Exam_Attempt__c ea : examAttemptList){
            if(ea.Exam_Administration__c != null){
                examAdminIds.add(ea.Exam_Administration__c);
            }
        }
        
        Map<Id,Exam_Administration__c> adminMap = new Map<Id,Exam_Administration__c>([Select Id,Name,Exam_Group__r.Active__c,Exam_Group__r.SCR_Active__c from Exam_Administration__c where Exam_Group__c =: examGroupId]);
        
        examPartList = [Select Id,Exam__r.Exam__c,Exam_Part_Number__c,Exam_Administration__c,Exam_Date__c,Exam__r.Exam_Date__c from Exam_Part__c where Exam_Administration__c IN: adminMap.keySet() AND Exam__r.Exam__c IN:examPartsdata Order By Exam__r.Exam_Date__c ASC];
        
        for(Exam_Part__c ep : examPartList){
            Map<Id,Exam_Administration__c> adminListMap = new Map<Id,Exam_Administration__c>();
            Set<Exam_Administration__c> adminSet = new Set<Exam_Administration__c>();
            if(!examAdminIds.contains(ep.Exam_Administration__c)){
                if(ep.Exam_Part_Number__c== 1){
                    if(partToAdminMap.containsKey(1)){
                        adminListMap = partToAdminMap.get(1);
                        adminListMap.put(ep.Exam_Administration__c,adminMap.get(ep.Exam_Administration__c));
                        partToAdminMap.put(1,adminListMap);
                    }else{
                        adminListMap.put(ep.Exam_Administration__c,adminMap.get(ep.Exam_Administration__c));
                        partToAdminMap.put(1,adminListMap);
                    }
                }else if(ep.Exam_Part_Number__c== 2){
                    if(partToAdminMap.containsKey(2)){
                        adminListMap = partToAdminMap.get(2);
                        adminListMap.put(ep.Exam_Administration__c,adminMap.get(ep.Exam_Administration__c));
                        partToAdminMap.put(2,adminListMap);
                    }else{
                        adminListMap.put(ep.Exam_Administration__c,adminMap.get(ep.Exam_Administration__c));
                        partToAdminMap.put(2,adminListMap);
                    }
                }
            }
        }
        return partToAdminMap;
    }
    @AuraEnabled
    Public Static List<Exam_Sites__c> getExamSites(String examAdminId,List<String> selectedTypes,String examType){
        List<Exam_Sites__c> examSiteList = new List<Exam_Sites__c>();
        String examPart;
        if(examType == 'Part 1' && selectedTypes.contains('FRM Part 1')){
            examPart = 'FRM Part 1';
        }else if(examType == 'Part 2' && selectedTypes.contains('FRM Part 2')){
            examPart = 'FRM Part 2';
        }else if(examType == 'Part 1' && selectedTypes.contains('SCR')){
            examPart = 'SCR';
        }else if(examType == 'Part 1' && selectedTypes.contains('RiskAI')){
            examPart = 'RiskAI';
        }else if(examType == 'Part 1' && selectedTypes.contains('RAIJ')){
            examPart = 'RAIJ';
        }
        
        Map<Id,Exam_Part__c> examPartsMap = new Map<Id,Exam_Part__c>([Select Id,name from Exam_Part__c where Exam_Administration__c =: examAdminId AND Exam__r.Exam__c =: examPart]);
        
        examSiteList = [Select Id,Name,Exam_Date__c,Site__r.Active__c,Site__r.Non_Selectable__c from Exam_Sites__c where Site__r.Active__c = TRUE AND Site__r.Non_Selectable__c = FALSE AND Exam_Part__c IN: examPartsMap.keyset() Order By Name];
        
        return examSiteList;
    }
    
    @AuraEnabled
    public static string saveData(String requestWrapper){
        string response;
        string program;
        string examGroupId;
        boolean freeDeferral;
        boolean movingToActiveGroup;
        boolean doNotCountOneTimeDefrl;
        boolean doNotProcessMods = false;
        //Set<String> examParts = new Set<String>{'FRM Part 1','FRM Part 2','SCR','RiskAI','RAIJ'};
        requestWrapper request = new requestWrapper();
        try{
            request = (requestWrapper)JSON.deserialize(requestWrapper, requestWrapper.class);
            //system.debug('Check here');
            //system.debug(request);
            movingToActiveGroup = request.movingToActiveGroup;
            //if(request.changeType == 'Defer'){
                Contact con = [Select Id,Email,FirstName,LastName,HomePhone,Company__c,AccountId,GARP_Member_ID__c,
                                       Account.Billing_Address_Company__c,Account.BillingStreet,
                                       Account.BillingCity,Account.BillingState,Account.BillingPostalCode,
                                       Account.BillingCountry,MailingStreet,MailingCity,MailingState,
                                       MailingPostalCode,MailingCountry
                                       from Contact where GARP_Member_ID__c =: request.garpId];
                
                User u = [Select Id,ContactId from User where ContactId =: con.Id];
                
                List<Exam_Attempt__c> selectedRegistrations = request.registrations;
                for(Exam_Attempt__c ea : selectedRegistrations){
                    if(ea.Section__c == 'FRM Part 1' || ea.Section__c == 'FRM Part 2'){
                        program = 'frm';
                        examGroupId = ea.Exam_Administration__r.Exam_Group__c;
                        break;
                    }else if(ea.Section__c == 'SCR'){
                        program = 'SCR';
                        examGroupId = ea.Exam_Administration__r.Exam_Group__c;
                        break;
                    }else if(ea.Section__c == 'RiskAI'){
                        program = 'RiskAI';
                        examGroupId = ea.Exam_Administration__r.Exam_Group__c;
                        break;
                    }else if(ea.Section__c == 'RAIJ'){
                        program = 'RAIJ';
                        examGroupId = ea.Exam_Administration__r.Exam_Group__c;
                        break;
                    }
                }
                if(!movingToActiveGroup ){
                    if(request.part1ExamSite != null && !request.part1ExamSite.startsWithIgnoreCase('a1e'))
                        request.part1ExamSite = null;
                    if(request.part2ExamSite != null && !request.part2ExamSite.startsWithIgnoreCase('a1e'))
                        request.part2ExamSite = null;
                }
                //Get all registrations for the candidate
                List<Exam_Attempt__c> candidatesRegistrations = [SELECT Id, Exam_Site__c, Defered__c, Member_Email__c, Deferral_Status__c, Deferred_Exam_Administration__c,Exam_Administration__c,
                                                                        RPT_Exam_Part__c, Active_Integration_Data__c, Integration_Data_Exam_Scheduled_Date__c, Free_Deferral__c,
                                                                        Exam_Part__c, Exam_Part__r.Exam_Administration__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__r.Exam_Part_Number__c,
                                                                        Exam_Part__r.Delivery_Method__c,Exam_Site__r.Name,Exam_Site__r.Country__c,Exam_Site__r.Exam_Part__c,
                                                                        Exam_Site__r.Exam_Part__r.Exam_Administration__c, Exam_Site__r.Exam_Part__r.Exam__r.Exam__c,
                                                                        Exam_Site__r.Exam_Part__r.Exam_Part_Number__c,Exam_Site__r.Exam_Part__r.Delivery_Method__c,
                                                                        Exam_Site__r.Exam_Provider__r.Name,Exam_Site__r.Exam__c,Exam_Site__r.Exam__r.Exam__c, 
                                                                        Exam_Site__r.Exam__r.Exam_Group__c,Exam_Site__r.Site__c, Exam_Site__r.Site__r.Name,Section__c, 
                                                                        Exam_Site__r.Site__r.Is_OSTA_Information_Required__c, Exam_Site__r.Site__r.Is_Gender_Required__c, 
                                                                        Exam_Site__r.Site__r.AM_Exam_Capacity_Available__c, Exam_Site__r.Site__r.PM_Exam_Capacity_Available__c,
                                                                        Candidate_Commitment__c,Result__c
                                                                    FROM Exam_Attempt__c 
                                                                    WHERE Cancelled__c != TRUE 
                                                                    AND Opportunity__r.StageName = 'Closed'
                                                                    AND (Result__c =null OR Result__c ='No-Show')
                                                                    AND Exam_Site__r.Exam__r.Exam__c in :examPartsdata
                                                                    AND Member__c = :con.Id 
                                                                    AND Exam_Site__r.Exam__r.Exam_Group__c = :examGroupId];
                
                //Update 2nd registration details if only 1 part is selected
                for(Exam_Attempt__c ea: candidatesRegistrations){
                    if((ea.Section__c == 'FRM Part 1' || ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'RAIJ') && request.part1Administration == null){
                        if(ea.Defered__c == 'Pending'){
                            request.part1Administration = ea.Deferred_Exam_Administration__c;
                            request.part1ExamSite = ea.Exam_Site__c;
                        }else{
                            request.part1Administration = ea.Exam_Administration__c;
                        }   
                    }else if(ea.Section__c == 'FRM Part 2' && request.part2Administration == null){
                        if(ea.Defered__c == 'Pending'){
                            request.part2Administration = ea.Deferred_Exam_Administration__c;
                        }else{
                            request.part2Administration = ea.Exam_Administration__c;
                            request.part2ExamSite = ea.Exam_Site__c;
                        }
                    }
                }
                
                freeDeferral = request.freeDeferral == 'Yes'? true:false;
                doNotCountOneTimeDefrl = request.oneTimeDeferral == 'Yes'?true:false;
                //system.debug('freeDeferral:'+freeDeferral);
                //system.debug('doNotCountOneTimeDefrl:'+doNotCountOneTimeDefrl);
                ExamManagementController.examRescheduleData erd = ExamManagementController.getExamRescheduleFeesInternal(selectedRegistrations[0].Id,request.part1Administration,request.part2Administration,request.part1ExamSite,request.part2ExamSite,u.Id,freeDeferral,true);
                //system.debug(erd);
                if((erd.errMsg != null || String.isNotBlank(erd.errMsg)) && erd.errorCode != 501 && erd.errorCode != 503 && erd.errorCode != 507 && erd.errorCode != 510){
                    return erd.errMsg;
                }else{
                    for(ExamManagementController.prodLine product : erd.fees){
                        if(product.amount != null && product.amount > 0)
                            doNotProcessMods = true;
                    }
                    
                    if(doNotProcessMods){
                        ExamManagementController.examRescheduleData data = ExamManagementController.createExamRescheduleFeesOrderInternal(selectedRegistrations[0].Id,request.part1Administration,request.part2Administration,request.part1ExamSite,request.part2ExamSite,u.Id,freeDeferral,true,request.subType,doNotCountOneTimeDefrl);
                        if(movingToActiveGroup){
                            Exam_Registration_Modification__c mod = data.ExamRegMod;
                            mod.Status__c = 'Opportunity Created';
                            mod.Used_To_Move_to_New_Exam_Group__c = true;
                            update mod;
                        }
                    }else{
                        ExamManagementController.examRescheduleData data = ExamManagementController.createExamRescheduleFeesOrderInternal(selectedRegistrations[0].Id,request.part1Administration,request.part2Administration,request.part1ExamSite,request.part2ExamSite,u.Id,freeDeferral,true,request.subType,doNotCountOneTimeDefrl);
                        //system.debug(data);
                        if(movingToActiveGroup){
                            processRegistrations(new Set<Id>{data.ExamRegMod.Id},doNotCountOneTimeDefrl,freeDeferral);
                        }else{
                            ExamManagementController.processExamRegMods(new Set<Id>{data.ExamRegMod.Id});
                        }
                    }
                }
            /*}else if(request.changeType == 'ExamSite'){
                List<Exam_Attempt__c> registrations = request.registrations;
                for(Exam_Attempt__c ea : registrations){
                    if(ea.Section__c == 'FRM Part 1' || ea.Section__c == 'SCR'){
                        Response.Envelope response1 = ExamManagementController.changeExamSiteOnExamRegistrations(ea.Id,request.part1ExamSite);
                    }
                    if(ea.Section__c == 'FRM Part 2'){
                       Response.Envelope response2 = ExamManagementController.changeExamSiteOnExamRegistrations(ea.Id,request.part2ExamSite);
                    }
                }
            }*/
            response = 'SUCCESS';
        }catch(exception e){
            response = e.getMessage();
        }
        
        return response;
    }
    
    public static void processRegistrations(Set<Id> setExamRegMods,boolean doNotCountOneTimeDefrl,boolean freeDeferral){
        Map<Id,Exam_Registration_Modification__c> examAttemptToDeferralMap = new Map<Id,Exam_Registration_Modification__c>();
        Map<Id,Opportunity> modToOppMap = new Map<Id,Opportunity>();
        DescribeSObjectResult describeResult = Exam_Attempt__c.getSObjectType().getDescribe();
        List<Exam_Attempt__c> oldAttemptsList = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> oldAttemptsListToUpdate = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> newAttemptsList = new List<Exam_Attempt__c>();
        List<String> fieldNames = new List<String>( describeResult.fields.getMap().keySet() );
        List<Exam_Registration_Modification__c> modsToUpdate = new List<Exam_Registration_Modification__c>();
        Set<Id> programIds = new Set<Id>();
        List<Exam_Registration_Modification__c> lstExamRegMods = [
                                            SELECT Id, Customer_Email__c, Part_I_Exam_Admin_From__c,Part_I_Exam_Admin_To__c,
                                                    Part_I_Exam_Group_From__c,Part_I_Exam_Group_To__c,Deferral_Subtype__c,
                                                    Part_II_Exam_Group_From__c,Part_II_Exam_Group_To__c,
                                                    Part_I_Exam_Registration__c,Part_I_Exam_Site_From__c,
                                                    Part_I_Exam_Site_To__c,Part_II_Exam_Admin_From__c,Part_II_Exam_Admin_To__c,
                                                    Part_II_Exam_Registration__c,
                                                    Part_II_Exam_Site_From__c,
                                                    Part_II_Exam_Site_To__c,Status__c,User__c,
                                                    Part_I_Exam_Part_To__c,Part_I_Exam_Part_From__c,
                                                    Part_II_Exam_Part_To__c,Part_II_Exam_Part_From__c,
                                                    Part_I_Exam_Registration__r.Candidate_Commitment__r.AccountId,
                                                    Part_II_Exam_Registration__r.Candidate_Commitment__r.AccountId
                                            FROM Exam_Registration_Modification__c 
                                            WHERE Id = :setExamRegMods];
        for (Exam_Registration_Modification__c erm :lstExamRegMods) {
            if(erm.Part_I_Exam_Registration__c != null){
                if(erm.Part_I_Exam_Group_From__c != null && erm.Part_I_Exam_Group_To__c != null && erm.Part_I_Exam_Group_From__c != erm.Part_I_Exam_Group_To__c)
                    examAttemptToDeferralMap.put(erm.Part_I_Exam_Registration__c,erm);
            }
            if(erm.Part_II_Exam_Registration__c != null){
                if(erm.Part_II_Exam_Group_From__c != null && erm.Part_II_Exam_Group_To__c != null && erm.Part_II_Exam_Group_From__c != erm.Part_II_Exam_Group_To__c)
                    examAttemptToDeferralMap.put(erm.Part_II_Exam_Registration__c,erm);
            }
            //erm.Status__c = 'Completed';
            erm.Used_To_Move_to_New_Exam_Group__c = true;
            modsToUpdate.add(erm);
        }
        Set<Id> attemptsId = examAttemptToDeferralMap.keyset();
        String query = 'SELECT ' +String.join( fieldNames, ',' ) +' FROM Exam_Attempt__c'+' WHERE id IN: attemptsId';
        oldAttemptsList = Database.query(query);
        List<Opportunity> oppList = [select Id, AccountId,StageName,Exam_Registration_Modification__c,Free_Deferral__c
                                    from Opportunity 
                                    where Exam_Registration_Modification__c in :setExamRegMods];
        for(Opportunity opp : oppList){
            modToOppMap.put(opp.Exam_Registration_Modification__c,opp);
            
            //ChargentSFA__Transaction__c trans = ExamManagementController.createTransaction(opp.Id);
        }
        
        for(Exam_Attempt__c ea : oldAttemptsList){
            /*Exam_Attempt__c clonedRec = ea.clone(false,true,false,false);
            Exam_Registration_Modification__c erm = examAttemptToDeferralMap.containskey(ea.id) ? examAttemptToDeferralMap.get(ea.id) : null;
            if((erm != null && modToOppMap.containskey(erm.Id) && modToOppMap.get(erm.Id).Free_Deferral__c) || freeDeferral){
                clonedRec.Free_Deferral__c = true;
            }else{
                clonedRec.Free_Deferral__c = false;
            }
            if(doNotCountOneTimeDefrl){
                clonedRec.Allow_Future_Deferral__c = true;
            }else{
                clonedRec.Allow_Future_Deferral__c = false;
            }
            if(ea.Section__c == 'FRM Part 1' || ea.Section__c == 'ERP Exam Part I' || ea.Section__c == 'SCR'){
                if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c != null)
                    clonedRec.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Site_To__c;
                if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c != null){
                    clonedRec.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c;
                    //clonedRec.Original_Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Admin_To__c;
                }
                if(examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c != null)
                    clonedRec.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_I_Exam_Part_To__c;
            }else if(ea.Section__c == 'FRM Part 2' || ea.Section__c == 'ERP Exam Part II'){
                if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c != null)
                    clonedRec.Exam_Site__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Site_To__c;
                if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c != null){
                    clonedRec.Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c;
                    //clonedRec.Original_Exam_Administration__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Admin_To__c;
                }
                if(examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c != null)
                    clonedRec.Exam_Part__c = examAttemptToDeferralMap.get(ea.id).Part_II_Exam_Part_To__c;
            }*/
            if(ea.Result__c != null){
                if(ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' ||  ea.Section__c == 'RAIJ' && ea.Result__c == 'No-Show'){ 
                    programIds.add(ea.Candidate_Commitment__c);
                }
                //clonedRec.Result__c = null;
                ea.Result__c = null;
            }
            /*clonedRec.Future_Free_Deferral__c = false;
            clonedRec.Selected_To_Allow_Future_Deferral__c = false;
            clonedRec.Defered__c = 'Approved';
            clonedRec.Deferral_Status__c = 'Deferred In';
            clonedRec.Cloned_From__c = ea.id;
            clonedRec.Other_Exam_Registrations__c = null;
            clonedRec.Cancelled__c = false;
            clonedRec.Seat_No__c = '';
            clonedRec.Room__c = null;
            clonedRec.Candidate_ID__c = null;
            clonedRec.Deferred_Exam_Administration__c = null;
            clonedRec.ATA_Cert_id__c = null;
            clonedRec.ATA_Cert_Type__c = null;
            clonedRec.ATA_Name_as_it_appears_on_ID__c = null;
            clonedRec.Updated_to_FRM_1__c = false;
            clonedRec.Name = '';
            clonedRec.Active_Integration_Data__c = null;
            clonedRec.Category_1__c = '';
            clonedRec.Category_2__c = ''; 
            clonedRec.Category_3__c = ''; 
            clonedRec.Category_4__c = ''; 
            clonedRec.Category_5__c = ''; 
            clonedRec.Category_6__c = ''; 
            clonedRec.Category_7__c = ''; 
            clonedRec.Category_8__c = ''; 
            clonedRec.Category_9__c = '';
            clonedRec.Quartile_1__c = null;
            clonedRec.Quartile_2__c = null;
            clonedRec.Quartile_3__c = null;
            clonedRec.Quartile_4__c = null;
            clonedRec.Quartile_5__c = null;
            clonedRec.Quartile_6__c = null;
            clonedRec.Quartile_7__c = null;
            clonedRec.Quartile_8__c = null;
            clonedRec.Quartile_8__c = null;
            clonedRec.Outbound_Type__c = null;
            clonedRec.Integration_Type__c = null;
            clonedRec.EBooks_Created__c = false;
            clonedRec.Late_Deferral__c = null;
            clonedRec.Exam_Violation_Commets__c = '';
            clonedRec.Exam_Violation_Type__c = null;
            clonedRec.hasViolation__c = false;
            clonedRec.Hide_Exam_Result__c = false;
            clonedRec.ID_Exception__c = false;
            clonedRec.Accepted_ID_Type__c = '';

            ea.Defered__c = 'Approved';
            ea.Cancelled__c =true;
            ea.Cancel_Reason__c ='Deferral';
            ea.Deferral_Status__c ='Deferred Out';
            ea.Deferral_SubType__c = erm.Deferral_Subtype__c;*/
            if(freeDeferral)
                ea.Future_Free_Deferral__c = true;
                   
           oldAttemptsListToUpdate.add(ea);
           //newAttemptsList.add(clonedRec);
        }
        
        if(programIds != null){
            List<Contract> programList = [Select Id,Status,Eligible_For_Scr_Discount__c,Eligible_For_Scr_Discount_Date__c,SCR_Start_Date__c,SCR_End_Date__c
                                          from Contract where Id IN: programIds];
            for(Contract prg : programList){
                prg.Status = 'Activated';
                prg.Eligible_For_Scr_Discount__c = false;
                prg.Eligible_For_Scr_Discount_Date__c = null;
                prg.SCR_Start_Date__c = null;
                prg.SCR_End_Date__c = null;
            }
            
            update programList;
        }

        if(!oldAttemptsListToUpdate.isEmpty()){
            update oldAttemptsListToUpdate;
        }
        /*if(!newAttemptsList.isEmpty()){
            insert newAttemptsList;
        }*/
        if(!modsToUpdate.isEmpty()){
            update modsToUpdate;
        }
        
        
    }
    
    public class requestWrapper{
        @auraEnabled
        public string garpId{get;set;}
        @auraEnabled
        public List<Exam_Attempt__c> registrations{get;set;}
        @auraEnabled
        public string part1Administration{get;set;}
        @auraEnabled
        public string part2Administration{get;set;}
        @auraEnabled
        public string part1ExamSite{get;set;}
        @auraEnabled
        public string part2ExamSite{get;set;}
        @auraEnabled
        public string part1ExamPart{get;set;}
        @auraEnabled
        public string part2ExamPart{get;set;}
        @auraEnabled
        public string freeDeferral{get;set;}
        @auraEnabled
        public string oneTimeDeferral{get;set;}
        @auraEnabled
        public boolean movingToActiveGroup{get;set;}
        @auraEnabled
        public string changeType{get;set;}
        @auraEnabled
        public string subType{get;set;}
    }
}