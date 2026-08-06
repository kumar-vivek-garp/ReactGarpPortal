public class technicalglitchClass {
    public Static list<String> label {get; set;}
    public Static Map<String,String> mapExamAdmins;
    public Static Map<String,String> loopMapExamAdmins;
    public Static Map<String,String> mapExamSites; 
    public Static Map<String,Exam_Attempt__c> mapExamRegistrations;
    public Static List<String> lstExamAttempt {get; set;}
    public Static List<String> lstExamAdmins {get; set;}
    public Static List<String> lstExamSites {get; set;}
    
    @AuraEnabled 
    public static List<String> getPicklistValues() {
        label = System.Label.Drop_down.split(',');  
        system.debug('label=====>'+label);
        return label;
    }
    
    @AuraEnabled
    public static Map<String,Exam_Attempt__c> getExamRegistrations(String garpId){
        mapExamRegistrations = new Map<String,Exam_Attempt__c>();
        lstExamAttempt = new List<String> ();
        if(!Test.isRunningTest()){
          for(Exam_Attempt__c er : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c 
                                  where Garp_Id__c =:garpId AND Cancelled__c = FALSE 
                                  AND Result__c = NULL AND Opportunity__r.StageName = 'Closed']) {
                                      mapExamRegistrations.put(er.Section__c,er);
                                  }  
        } else {
            for(Exam_Attempt__c er : [Select id,name, Exam_Name__c,Section__c ,
                                  Exam_Administration__r.Exam_Group__c,Member__c,Exam_Part__r.Exam__r.Exam__c,Exam_Part__c
                                  from Exam_Attempt__c 
                                  where Cancelled__c = FALSE 
                                  AND Result__c = NULL AND Opportunity__r.StageName = 'Closed']) {
                                      mapExamRegistrations.put(er.Section__c,er);
                                  }  
        }
        
        system.debug('obj.mapExamRegistrations========>'+mapExamRegistrations);
        return mapExamRegistrations;
    }
    
    @AuraEnabled
    public static Map<String,String> getExamAdmins(String examReg,Map<String,Exam_Attempt__c> examRegs ){
        lstExamAdmins = new List<String>();
        List<Exam_Attempt__c>  er = new List<Exam_Attempt__c>();
        List<String> examgroupIds = new List<String>();
        loopMapExamAdmins = new Map<String,String>();
        mapExamAdmins = new Map<String,String>();
        system.debug('examRegs=====>'+examRegs);
        system.debug('examReg=====>'+examReg);
        er.add(examRegs.get(examReg));
        for(Exam_Attempt__c e: er) {
            examgroupIds.add(e.Exam_Administration__r.Exam_Group__c);
        }     
        system.debug('examgroupIds====>'+examgroupIds);
        system.debug('er=========>'+er);
        List<String> nextExamGroup = new List<String>();
        for (Exam_Group__c examgroup: [Select id,Next_Exam_Group__c from Exam_Group__c where id IN: examgroupIds]){
            nextExamGroup.add(examgroup.Next_Exam_Group__c);
        }
        for(Exam_Administration__c a : [select id, name from Exam_Administration__c where Exam_Group__c IN: nextExamGroup]) {
            loopMapExamAdmins.put(a.name, a.id);
            // lstExamAdmins.add(a.name);
        }
        
       for (String a : loopMapExamAdmins.keySet()) {
            system.debug('loopMapExamAdmins==>'+a);
            List<Exam_Part__c> p = [Select id,Exam__c from Exam_Part__c where Exam_Administration__c =: loopMapExamAdmins.get(a) and Exam__r.Exam__c =: examReg];
            system.debug('p======>'+p);
            if( p.size() > 0) {
                mapExamAdmins.put(a,loopMapExamAdmins.get(a));
                lstExamAdmins.add(a);
            }    
        }
        
        system.debug('mapExamAdmins======>'+mapExamAdmins);
        return mapExamAdmins;
    }
    
    @AuraEnabled
    public static Map<String,String> getExamSites(String selectedExamAdmin, Map<String,String> mapExamAdmins, String selectedExamReg){
        system.debug('============Entered ExamSites============');
        system.debug('mapExamAdmins==========>'+mapExamAdmins);
        system.debug('selectedExamAdmin=========>'+selectedExamAdmin);
        system.debug('mapExamAdmins.get(selectedExamAdmin)=======>'+mapExamAdmins.get(selectedExamAdmin));
        system.debug('selectedExamReg==========>'+selectedExamReg);
        
        List<Id> examPartId = new List<Id>();
        mapExamSites = new Map<String,String>();
        lstExamSites = new List<String>();
        for(Exam_Part__c ep : [Select id from Exam_Part__c
                               where Exam_Administration__c =: mapExamAdmins.get(selectedExamAdmin)
                               and Exam__r.Exam__c =: selectedExamReg ])
        {
            examPartId.add(ep.id) ;   
        }
        
        List<Exam_Sites__c > es = [Select id,name from Exam_Sites__c 
                                   where Exam_Part__c IN: examPartId];
        // Exam__r.Exam__C
        system.debug('es=======>'+es);
        for (Exam_Sites__c examSite : es) {
            
            mapExamSites.put(examSite.name,examSite.id);
            lstExamSites.add(examSite.name);
        }
        system.debug('lstExamSites=====>'+lstExamSites);
        return mapExamSites;
    } 
    
    
    @AuraEnabled
    public static String getvalidateFrm1Frm2(String SelectedFrm1ExamAdmin,Map <String,String> frm1MapExamAdmins,
                                             String SelectedFrm2ExamAdmin,Map <String,String> frm2MapExamAdmins,
                                             List<String> selectedExamRegs) {
                                                 system.debug('=========Entered validation=========');
                                                 Date frm1StartDate ;
                                                 Date frm2StartDate ;
                                                 Boolean ValidateStartDate;
                                                 String strMessage = '';
                                                 List<Exam_Part__c> epfrm1 = new List<Exam_Part__c>();
                                                 List<Exam_Part__c> epfrm2 = new List<Exam_Part__c>();
                                                 for(String selectedExamReg : selectedExamRegs){
                                                    // system.debug('selectedExamReg =====>'+selectedExamReg);
                                                    // system.debug('SelectedFrm1ExamAdmin=====>'+SelectedFrm1ExamAdmin);
                                                    // system.debug('SelectedFrm2ExamAdmin=====>'+SelectedFrm2ExamAdmin);
                                                    // system.debug('SelectedFrm2ExamAdmin=====>'+SelectedFrm2ExamAdmin);
                                                     // system.debug('mapExamAdmins.get(SelectedFrm1ExamAdmin) =====>'+frm1MapExamAdmins.get(SelectedFrm1ExamAdmin));
                                                     // system.debug('mapExamAdmins.get(SelectedFrm2ExamAdmin) =====>'+frm1MapExamAdmins.get(SelectedFrm2ExamAdmin));            
                                                    // system.debug('frm1MapExamAdmins=====>'+frm1MapExamAdmins);
                                                    // system.debug('frm2MapExamAdmins=====>'+frm2MapExamAdmins);
                                                     if(selectedExamReg == 'FRM Part 1'){
                                                         epfrm1 = [Select id, Exam_Start_Date__c  from Exam_Part__c
                                                                   where Exam_Administration__c =: frm1MapExamAdmins.get(SelectedFrm1ExamAdmin)
                                                                   and Exam__r.Exam__c =: selectedExamReg];
                                                         
                                                         if(epfrm1.size() > 0) {
                                                             system.debug('ep======>'+epfrm1);
                                                             frm1StartDate = epfrm1[0].Exam_Start_Date__c;
                                                         } else {
                                                             strMessage = 'Exam Parts are not created for selected frm1 Exam Adminstartions';
                                                         }
                                                     }
                                                     
                                                     if(selectedExamReg == 'FRM Part 2') {
                                                         system.debug('mapExamAdmins.get(SelectedFrm2ExamAdmin)=======>'+frm2MapExamAdmins.get(SelectedFrm2ExamAdmin));
                                                         epfrm2 = [Select id, Exam_Start_Date__c  from Exam_Part__c
                                                                   where Exam_Administration__c =: frm2MapExamAdmins.get(SelectedFrm2ExamAdmin)
                                                                   and Exam__r.Exam__c =: selectedExamReg ];
                                                         system.debug('epfrm2======>'+epfrm2);
                                                         if(epfrm2.size() > 0) {
                                                             frm2StartDate = epfrm2[0].Exam_Start_Date__c;
                                                         } else {
                                                             strMessage = 'Exam Parts are not created for selected frm2 Exam Adminstartions';
                                                         }
                                                     }
                                                 }     
                                                 /*if(epfrm1.size() == 0 & epfrm1.size() == 0) {
strMessage = 'Exam Parts are not created for selected frm1 and frm2 Exam Adminstartions';
}  */                                     
                                                 if(epfrm1.size() > 0 & epfrm2.size() > 0){                  
                                                     if(frm1StartDate.month() <= frm2StartDate.month()) { 
                                                         strMessage = 'true';
                                                     } else {
                                                         strMessage = 'false';
                                                     }
                                                 }
                                                 system.debug('strMessage======>'+strMessage);
                                                 return strMessage;
                                             }
    
    @AuraEnabled
    public static void getSaveRecord( string examDetails){
        system.debug('===========saveRecord Called=======');
        system.debug('examDetails========>'+examDetails);
        examDetails request = new examDetails();
        request = (examDetails)JSON.deserialize(examDetails, examDetails.class);
        List<Exam_Attempt__c> lstexamRegs = new List<Exam_Attempt__c>();
        Map<string,Id> mapExamRegIds = new Map<string,Id>();
        Map<Id,Id> mapExamRegContactIds = new Map<Id,Id>();
        Set<string> setExamReg = new Set<string>();
        setExamReg.addAll(request.selectedExamRegs);
        Map<String,Id> lstExamAdminIds = new Map<String,Id>();
        Map<String,Id> lstExamSiteIds = new Map<String,Id>();
        Map<String,String> mapExamRegExamParts = new Map<String,String>();
        List<Approval_Matrix__c> lsttehnicalGlitchRecord = new List<Approval_Matrix__c>();
        system.debug('request.selectedExamRegs======>'+request.selectedExamRegs);
          system.debug('request.examRegs======>'+request.examRegs);
        for(string examReg : request.selectedExamRegs) {
            system.debug('examReg======>'+examReg);
            lstexamRegs.add(request.examRegs.get(examReg));
        } 
        system.debug('lstexamRegs=======>'+lstexamRegs);
        for (Exam_Attempt__c examReg : lstexamRegs) {
            system.debug('examReg.Exam_Part__r.Exam__r.Exam__c=====>'+examReg.Exam_Part__r.Exam__r.Exam__c);
            mapExamRegIds.put(examReg.Exam_Part__r.Exam__r.Exam__c,examReg.id);
            system.debug('examReg.Member__c=====>'+examReg.Member__c);
            system.debug('examReg.Exam_Part__c=====>'+examReg.Exam_Part__c);
            mapExamRegContactIds.put(examReg.id,examReg.Member__c);
            mapExamRegExamParts.put(examReg.id,examReg.Exam_Part__c);
        }
        system.debug('mapExamRegExamParts=======>'+mapExamRegExamParts);
        system.debug('mapExamRegIds=====>'+mapExamRegIds);
        
        Approval_Matrix__c tehnicalGlitchRecord = new Approval_Matrix__c();
        tehnicalGlitchRecord.Source__c = 'Technical Glitch';
        tehnicalGlitchRecord.Free_Deferral__c  = request.freeDefferalCheck == 'Yes'? true:false;
        // tehnicalGlitchRecord.One_Time_Deferral__c = request.oneTimeDeferralCheck == 'Yes'? true:false;
        tehnicalGlitchRecord.Garp_id__c = request.garpId ;
        if(setExamReg.contains('FRM Part 1') & request.frm1Exists == true){
            tehnicalGlitchRecord.Part_I_Exam_Admin__c = request.frm1MapExamAdmins.get(request.SelectedFrm1ExamAdmin);
            tehnicalGlitchRecord.Part_I_Exam_Registration__c = mapExamRegIds.get('FRM Part 1');
            tehnicalGlitchRecord.Contact__c = mapExamRegContactIds.get(mapExamRegIds.get('FRM Part 1'));
            tehnicalGlitchRecord.Part_I_Exam_Part__c  = mapExamRegExamParts.get(mapExamRegIds.get('FRM Part 1'));
            if(request.examFrm1Sites != NULL) {
                tehnicalGlitchRecord.Part_I_Exam_Site__c = request.mapFrm1ExamSites.get(request.examFrm1Sites);
            }
        } 
        if(setExamReg.contains('FRM Part 2') & request.frm2Exists == true){
            tehnicalGlitchRecord.Part_II_Exam_Admin__c  = request.frm2MapExamAdmins.get(request.SelectedFrm2ExamAdmin);
            tehnicalGlitchRecord.Part_II_Exam_Registration__c = mapExamRegIds.get('FRM Part 2');
            tehnicalGlitchRecord.Contact__c = mapExamRegContactIds.get(mapExamRegIds.get('FRM Part 2'));
            tehnicalGlitchRecord.Part_II_Exam_Part__c  = mapExamRegExamParts.get(mapExamRegIds.get('FRM Part 2'));
            if(request.examFrm2Sites != NULL) {
                tehnicalGlitchRecord.Part_II_Exam_Site__c = request.mapFrm2ExamSites.get(request.examFrm2Sites);
            }
        }
        if(setExamReg.contains('SCR') & request.scrExists == true){
            tehnicalGlitchRecord.Part_I_Exam_Admin__c = request.scrMapExamAdmins.get(request.SelectedScrExamAdmin);
            tehnicalGlitchRecord.Part_I_Exam_Registration__c = mapExamRegIds.get('SCR');
            tehnicalGlitchRecord.Contact__c = mapExamRegContactIds.get(mapExamRegIds.get('SCR'));
            tehnicalGlitchRecord.Part_I_Exam_Part__c  = mapExamRegExamParts.get(mapExamRegIds.get('SCR'));
            if(request.examScrSites != NULL) {
                tehnicalGlitchRecord.Part_I_Exam_Site__c = request.mapScrExamSites.get(request.examScrSites);
            }
        }
        
        lsttehnicalGlitchRecord.add(tehnicalGlitchRecord);
        
        insert lsttehnicalGlitchRecord;
    }
    
    public class examDetails {
        @AuraEnabled
        public string garpId {get;set;}
        @AuraEnabled
        public List<string> selectedExamRegs {get;set;}
        @AuraEnabled
        public Map<String,Exam_Attempt__c> examRegs {get;set;}
        @AuraEnabled
        public String SelectedFrm1ExamAdmin {get;set;}
        @AuraEnabled
        public Map <String,String> frm1MapExamAdmins {get;set;}
        @AuraEnabled
        public String SelectedFrm2ExamAdmin {get;set;}
        @AuraEnabled
        public Map <String,String> frm2MapExamAdmins {get;set;}
        @AuraEnabled
        public String SelectedScrExamAdmin {get;set;}
        @AuraEnabled
        public Map <String,String> scrMapExamAdmins {get;set;}
        @AuraEnabled
        public String examFrm1Sites {get;set;}
        @AuraEnabled
        public Map <String,String> mapFrm1ExamSites {get;set;}
        @AuraEnabled
        public String examFrm2Sites {get;set;}
        @AuraEnabled
        public Map <String,String> mapFrm2ExamSites {get;set;}
        @AuraEnabled
        public String examScrSites {get;set;}
        @AuraEnabled
        public Map <String,String> mapScrExamSites {get;set;}
        @AuraEnabled
        public Boolean frm1Exists {get;set;}
        @AuraEnabled
        public Boolean frm2Exists {get;set;}
        @AuraEnabled
        public Boolean scrExists {get;set;}
        @auraEnabled
        public String freeDefferalCheck{get;set;}
       // @auraEnabled
       // public String oneTimeDeferralCheck{get;set;}
        
    }
}