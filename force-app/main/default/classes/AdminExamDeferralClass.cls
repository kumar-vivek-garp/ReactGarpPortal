public class AdminExamDeferralClass {
    Public class ExamAdministration{
        @AuraEnabled
        Public String FromGroupId; 
        @AuraEnabled
        Public String ToGroupId; 
        
        @AuraEnabled
        Public String FromExamAdminId;
        @AuraEnabled
        Public List<String> ToExamAdminId;  
        
        @AuraEnabled
        public Map<String,String> ToAdiminSelectionMap;
        @AuraEnabled    
        Public String ensOfExamGroup ='';
        @AuraEnabled    
        Public String moveSelectedMembers ='';
        @AuraEnabled    
        Public String subType ='';
        @AuraEnabled
        public List<String> selectedExamType;
        @AuraEnabled
        public List<String> fromRelatedExams;
        @AuraEnabled
        public Map<String,String> fromRelatedExamsMap;
        @AuraEnabled
        Public String FromToAdminData;
        public ExamAdministration(){ 
            ToExamAdminId = new  List<String>();
            fromRelatedExams = new List<String>();
            selectedExamType = new List<String>();
            fromRelatedExamsMap = new  Map<String,String>();
            ToAdiminSelectionMap =  new  Map<String,String>();
        } 
        
    }
    
    @AuraEnabled
    public static ExamAdministration getwrapper(){
        ExamAdministration wrap = new ExamAdministration();
        return wrap;
    }
    
    Public class ExamAdministrationWrapper{
        @AuraEnabled
        Public List<Exam_Administration__c> ExamadminFromList = new  List<Exam_Administration__c>();
        @AuraEnabled
        Public String FromToAdminData; 
    } 
    
    
    @AuraEnabled
    public static  List<Exam_Group__c> getFromToExamGroupList(){  
        List<Exam_Group__c> examgpList = [Select Id,Name,Exam_Date__c From Exam_Group__c where Exam_Date__c !=null Order by Exam_Date__c ]; 
        return examgpList;
    }
    
    @AuraEnabled
    public static List<Exam__c> getExamAdminExamList(String fromId){
        List<Exam__c> ExamadminExamList = new List<Exam__c>();  
        ExamadminExamList = [Select Id,Name,Exam_Date__c,Exam__c from Exam__c where Exam_Group__c =:fromId order by Exam__c]; 
        return ExamadminExamList;
    } 
    
    @AuraEnabled
    public static ExamAdministrationWrapper getExamAdministrationsList(String fromId,String toId){
        List<Exam_Administration__c> ExamadminPartList = new List<Exam_Administration__c>(); 
        ExamAdministrationWrapper exwrap = new ExamAdministrationWrapper(); 
        exwrap.ExamadminFromList = [Select Id,Name,Exam_Date__c,Exam_Start_Date__c,Exam_End_Date__c,Exam_Type__c,Exam_Group__r.Name from Exam_Administration__c where Exam_Group__c =:fromId];
        List<Exam_Administration__c> Examadmintolsit = [Select Id from Exam_Administration__c where Exam_Group__c =:toId];
        if(!exwrap.ExamadminFromList.isEmpty() && !Examadmintolsit.isEmpty()){
            exwrap.FromToAdminData = 'From To Not Empty'; 
        }else if(exwrap.ExamadminFromList.isEmpty() && Examadmintolsit.isEmpty()){
            exwrap.FromToAdminData = 'From To Empty'; 
        }else if(!exwrap.ExamadminFromList.isEmpty() && Examadmintolsit.isEmpty()){
            exwrap.FromToAdminData = 'To Empty'; 
        }else if(exwrap.ExamadminFromList.isEmpty() && !Examadmintolsit.isEmpty()){
            exwrap.FromToAdminData = 'From Empty'; 
        } 
        return exwrap;
    } 
    
    @AuraEnabled
    public static  LIst<Exam_Part__c> getExamExamPartList(String examAdminId){
        List<Exam_Part__c> ExamPartList = new List<Exam_Part__c>();
        ExamPartList = [Select Id,Exam_Administration__c,Delivery_Method__c,Exam_Date__c,Exam_End_Date__c,Exam_Start_Date__c,Exam__c,Exam__r.Exam__c from Exam_Part__c where  Exam__r.Exam__c !=null and Exam_Administration__c != null and Exam_Administration__c=:examAdminId];
        return ExamPartList;
    }
    
    @AuraEnabled
    public static Map<String,List<Exam_Administration__c>> getToExamadminList(String fromId,String toId,List<String> examType){
        Map<String,List<Exam_Administration__c>> ExamadminTomListMap = new Map<String,List<Exam_Administration__c>>();
        Set<Id> examAdminId = new Set<Id>();
        Map<String,Set<Id>> eamAdminMapId = new  Map<String,Set<Id>>();
        Map<String,List<String>> examadminMap = new Map<String,List<String>>();
        
        for(Exam_Part__c ep:[Select Id,Exam_Administration__c,Exam__r.Exam__c from Exam_Part__c where Exam_Administration__c != null and Exam__r.Exam__c In:examType and Exam_Administration__r.Exam_Group__c =:toId]){
            examAdminId.add(ep.Exam_Administration__c);
            
            if(examadminMap.containsKey(ep.Exam_Administration__c)){
                List<String> examadminIds = examadminMap.get(ep.Exam_Administration__c);
                examadminIds.add(ep.Exam__r.Exam__c);
                examadminMap.put(ep.Exam_Administration__c,examadminIds);
            }else{
                examadminMap.put(ep.Exam_Administration__c,new List<String>{ep.Exam__r.Exam__c});
            }
        }   
        for(Exam_Administration__c exadmin:[Select Id,Name,Exam_Date__c,Exam_Start_Date__c,Exam_End_Date__c,Exam_Type__c from Exam_Administration__c where Id In:examAdminId and Exam_Group__c =:toId]){
            for(string s:examadminMap.get(exadmin.Id)){
                if(ExamadminTomListMap.containsKey(s)){
                    List<Exam_Administration__c> examadminIds = ExamadminTomListMap.get(s);
                    examadminIds.add(exadmin);
                    ExamadminTomListMap.put(s,examadminIds);
                }else{
                    ExamadminTomListMap.put(s,new List<Exam_Administration__c>{exadmin});
                }
            }
        }
        return ExamadminTomListMap;
    }
    
    @AuraEnabled
    Public Static Map<String,List<Exam_Sites__c>> getExamPartSiteList(String fromgroupId,String toGroupId,List<String> selectedGroupFromexam,String selecetedFromExam,List<String> selecetedToExam,List<String> examType,String FromToAdminData){ 
        Map<String,List<Exam_Sites__c>> siteListMap = new Map<String,List<Exam_Sites__c>>();
        Set<String> siteCode = new Set<String>();
        
        List<Exam_Sites__c> examsiteList =new List<Exam_Sites__c>();
        String queryobj='Select Id,Name,Site__c,Site__r.Name,Site__r.Site_Code__c,Exam__r.Exam__c FROM Exam_Sites__c';
        
        if(FromToAdminData =='From To Empty' && selectedGroupFromexam !=null){  
            String query = queryobj+' Where Exam__r.Exam_Group__c =:toGroupId and Site__r.Site_Code__c != null and Exam__r.Exam__c IN:examType';
            List<Exam_Sites__c> examsite = database.query(query);
            for(Exam_Sites__c es:examsite){
                siteCode.add(es.Site__r.Site_Code__c);
            } 
            query  = queryobj+ ' Where Exam__c In:selectedGroupFromexam and Site__c !=null and Site__r.Site_Code__c In:siteCode and Exam__r.Exam__c != null order by Exam__r.Exam__c,Site__r.Site_Code__c';
            examsiteList = database.query(query);
        }else if(FromToAdminData =='From To Not Empty'){
            String query = queryobj+' Where Exam_Part__r.Exam_Administration__c =:selecetedFromExam and Site__r.Site_Code__c != null and Exam__r.Exam__c IN:examType';
            List<Exam_Sites__c> examsite = database.query(query);
            for(Exam_Sites__c es:examsite){
                siteCode.add(es.Site__r.Site_Code__c);
            } 
            query  = queryobj+ ' Where Exam_Part__r.Exam_Administration__c =:selecetedFromExam and Exam__r.Exam__c IN:examType and Site__c !=null and Exam__r.Exam__c != null order by Exam__r.Exam__c,Site__r.Site_Code__c';
            examsiteList = database.query(query);
        }else if(FromToAdminData == 'From Empty' && selectedGroupFromexam !=null){
            String query='';
            query  = queryobj+ ' Where Exam__c in:selectedGroupFromexam  and Exam__r.Exam__c IN:examType and Site__c !=null and Exam__r.Exam__c != null order by Exam__r.Exam__c,Site__r.Site_Code__c';
            examsiteList = database.query(query);
        }
        
        for(Exam_Sites__c es:examsiteList){ 
            if(siteListMap.containsKey(es.Exam__r.Exam__c)){
                List<Exam_Sites__c> esl = siteListMap.get(es.Exam__r.Exam__c);
                esl.add(es);
                siteListMap.put(es.Exam__r.Exam__c,esl);
            }else{
                siteListMap.put(es.Exam__r.Exam__c,new List<Exam_Sites__c>{es});
            }
        }
        
        return siteListMap;
    } 
    
    @AuraEnabled
    public static String saveExamAdmindata(Map<String,List<Exam_Sites__c>> siteMap,List<String> examType,Map<String,List<Exam_Sites__c>> allexamsitemap,String examwrap,String FromToAdminData){
        try{
            /*system.debug(siteMap);
            system.debug(examType);
            system.debug(allexamsitemap);*/
            List<String> stiteId = new List<String>();
            Map<String,String> FRMallsitelst = new Map<String,String>();
            Map<String,String> ERPallsitelst = new Map<String,String>(); 
            ExamAdministration examwrapobj = (ExamAdministration) JSON.deserialize(examwrap, ExamAdministration.class); 
            Map<String,String> fromSiteCodeMap = new Map<String,String>();
            Map<String,String> ToExamPartMap = new Map<String,String>();
            if(examwrapobj.ToGroupId != null && FromToAdminData =='From To Empty'){
                for(Exam_Sites__c es:[select Id,Name,Site__c,Site__r.Site_Code__c,Exam__r.Exam__c from Exam_Sites__c where Exam__r.Exam__c In:examType and Site__c !=null and Exam__r.Exam_Group__c =: examwrapobj.ToGroupId order by Name]){
                    String keyval = es.Exam__r.Exam__c +''+es.Site__r.Site_Code__c;
                    fromSiteCodeMap.put(keyval,es.Id);
                }
            }else if((FromToAdminData == 'From To Not Empty' || FromToAdminData == 'From Empty') && examwrapobj.ToExamAdminId !=null){ 
                for(Exam_Sites__c es:[select Id,Name,Site__c,Site__r.Site_Code__c,Exam__r.Exam__c from Exam_Sites__c where Exam__r.Exam__c In:examType and Site__c !=null and Exam_Part__r.Exam_Administration__c In:examwrapobj.ToExamAdminId order by Name]){
                    String keyval = es.Exam__r.Exam__c +''+es.Site__r.Site_Code__c;
                    fromSiteCodeMap.put(keyval,es.Id);
                }
                for(Exam_Part__c ep:[Select Id,Exam_Administration__c,Exam__r.Exam__c from Exam_Part__c where  Exam__r.Exam__c !=null and Exam_Administration__c != null and Exam_Administration__c In:examwrapobj.ToExamAdminId]){
                    String keyval = ep.Exam__r.Exam__c +''+ep.Exam_Administration__c;
                    ToExamPartMap.put(keyval,ep.Id);
                } 
                
            }  
            
            if(allexamsitemap.containsKey('FRM Part 2') && siteMap.containsKey('FRM Part 1')){ 
                for(Exam_Sites__c ss:allexamsitemap.get('FRM Part 2')){
                    FRMallsitelst.put(ss.Site__r.Site_Code__c,ss.Id);
                } 
            }
            if(allexamsitemap.containsKey('ERP Exam Part II') && siteMap.containsKey('ERP Exam Part I')){ 
                for(Exam_Sites__c ss:allexamsitemap.get('ERP Exam Part II')){
                    ERPallsitelst.put(ss.Site__r.Site_Code__c,ss.Id);
                } 
            }
            List<Admin_Exam_Deferral__c> examdefList = new List<Admin_Exam_Deferral__c>(); 
             Map<String,String> newExamSiteNewMap = getNewSIteCodes(examType,examwrapobj.ToGroupId,FromToAdminData);
            for(String s:siteMap.keySet()){  
                if(siteMap.containsKey(s)){ 
                    for(Exam_Sites__c ss:siteMap.get(s)){
                        Admin_Exam_Deferral__c examdef = new Admin_Exam_Deferral__c();
                        examdef.Deferral_SubType__c = examwrapobj.subType;
                        /*if(!FRMallsitelst.containsKey(ss.Site__r.Site_Code__c) && examType.contains('FRM Part 2')){
                           // return 'FRM Invalid Configuration';
                        }else */if(!ERPallsitelst.containsKey(ss.Site__r.Site_Code__c) && examType.contains('ERP Exam Part II')){
                            return 'ERP Invalid Configuration';
                        }else if(s=='ERP Exam Part I' || s == 'FRM Part 1' || s == 'SCR' || s == 'RiskAI' || s == 'RAIJ') { //Chinnapa
                            examdef.From_Exam_Group__c = examwrapobj.FromGroupId;
                            examdef.To_Exam_Group__c = examwrapobj.ToGroupId; 
                            examdef.Submitted_By_user__c = userinfo.getUserId();
                            String frmKey = s+''+ss.Site__r.Site_Code__c;
                            if(FromToAdminData =='From To Empty'){
                                if(fromSiteCodeMap.containsKey(frmKey))
                                    examdef.To_Exam_Site__c = fromSiteCodeMap.get(frmKey);
                                examdef.From_Exam_Site__c = ss.Id;
                            }else if(FromToAdminData =='From To Not Empty' || FromToAdminData == 'From Empty'){
                                if(examwrapobj.ToAdiminSelectionMap.containsKey(s))
                                    examdef.To_Exam_Administration__c = examwrapobj.ToAdiminSelectionMap.get(s);
                                String partkey = s+''+ examdef.To_Exam_Administration__c;
                                if(ToExamPartMap.containsKey(partkey))
                                    examdef.To_Exam_Part__c = ToExamPartMap.get(partkey);
                                if(FromToAdminData != 'From Empty'){
                                    examdef.From_Exam_Administration__c = examwrapobj.FromExamAdminId;  
                                    if(examwrapobj.fromRelatedExamsMap.containsKey(s))
                                        examdef.From_Exam_Part__c = examwrapobj.fromRelatedExamsMap.get(s);  
                                }
                                
                                if(fromSiteCodeMap.containsKey(frmKey))
                                    examdef.To_Exam_Site__c = fromSiteCodeMap.get(frmKey);
                                
                                examdef.From_Exam_Site__c = ss.Id; 
                                
                            }
                                examdef.Requested_Part__c = s;
                                examdef.Name = s+' '+ss.Name;
                                examdefList.add(examdef);
                            }else if(s=='FRM Part 2' && examType.contains('FRM Part 2')){
                                examdef = new Admin_Exam_Deferral__c();
                                examdef.From_Exam_Group__c = examwrapobj.FromGroupId;
                                examdef.To_Exam_Group__c = examwrapobj.ToGroupId; 
                                examdef.Submitted_By_user__c = userinfo.getUserId();
                                String frmKey1 = 'FRM Part 2'+''+ss.Site__r.Site_Code__c;
                                if(FromToAdminData =='From To Empty'){
                                    if(fromSiteCodeMap.containsKey(frmKey1))
                                        examdef.To_Exam_Site__c = fromSiteCodeMap.get(frmKey1);
                                    examdef.From_Exam_Site__c = FRMallsitelst.get(ss.Site__r.Site_Code__c);
                                }else if(FromToAdminData =='From To Not Empty' || FromToAdminData =='From Empty'){
                                    if(examwrapobj.ToAdiminSelectionMap.containsKey('FRM Part 2'))
                                        examdef.To_Exam_Administration__c = examwrapobj.ToAdiminSelectionMap.get('FRM Part 2');
                                    String partkey1 = 'FRM Part 2'+''+ examdef.To_Exam_Administration__c;
                                    if(ToExamPartMap.containsKey(partkey1))
                                        examdef.To_Exam_Part__c = ToExamPartMap.get(partkey1);
                                    if(FromToAdminData != 'From Empty'){
                                        examdef.From_Exam_Administration__c = examwrapobj.FromExamAdminId;  
                                        if(examwrapobj.fromRelatedExamsMap.containsKey('FRM Part 2'))
                                            examdef.From_Exam_Part__c = examwrapobj.fromRelatedExamsMap.get('FRM Part 2'); 
                                       
                                    }    
                                    /*if(newExamSiteNewMap.containsKey(frmKey1))
                                        examdef.To_Exam_Site__c = newExamSiteNewMap.get(frmKey1);
                                    examdef.From_Exam_Site__c = FRMallsitelst.get(ss.Site__r.Site_Code__c);*/
                                    if(fromSiteCodeMap.containsKey(frmKey1))
                                        examdef.To_Exam_Site__c = fromSiteCodeMap.get(frmKey1);
                                    
                                    examdef.From_Exam_Site__c = ss.Id;
                                    
                                } 
                                examdef.Requested_Part__c = 'FRM Part 2';
                                examdef.Name = 'FRM Part 2 '+ss.Name;
                                examdefList.add(examdef);
                            }
                            if(s=='ERP Exam Part II' && examType.contains('ERP Exam Part II')){
                                examdef = new Admin_Exam_Deferral__c();
                                examdef.From_Exam_Group__c = examwrapobj.FromGroupId;
                                examdef.To_Exam_Group__c = examwrapobj.ToGroupId; 
                                examdef.Submitted_By_user__c = userinfo.getUserId();
                                String frmKey2 = 'ERP Exam Part II'+''+ss.Site__r.Site_Code__c;
                                if(FromToAdminData =='From To Empty'){
                                    examdef.From_Exam_Site__c = ERPallsitelst.get(ss.Site__r.Site_Code__c); 
                                    if(fromSiteCodeMap.containsKey(frmKey2))
                                        examdef.To_Exam_Site__c = fromSiteCodeMap.get(frmKey2);
                                }else if(FromToAdminData =='From To Not Empty' || FromToAdminData == 'From Empty'){
                                    if(examwrapobj.ToAdiminSelectionMap.containsKey('ERP Exam Part II'))
                                        examdef.To_Exam_Administration__c = examwrapobj.ToAdiminSelectionMap.get('ERP Exam Part II');
                                     String partkey2 = 'ERP Exam Part II'+''+ examdef.To_Exam_Administration__c; 
                                    if(ToExamPartMap.containsKey(partkey2))
                                        examdef.To_Exam_Part__c = ToExamPartMap.get(partkey2); 
                                    if(FromToAdminData != 'From Empty'){
                                        examdef.From_Exam_Administration__c = examwrapobj.FromExamAdminId;  
                                        if(examwrapobj.fromRelatedExamsMap.containsKey('ERP Exam Part II'))
                                            examdef.From_Exam_Part__c = examwrapobj.fromRelatedExamsMap.get('ERP Exam Part II'); 
                                       
                                    } 
                                    examdef.To_Exam_Site__c = ERPallsitelst.get(ss.Site__r.Site_Code__c); 
                                    if(fromSiteCodeMap.containsKey(frmKey2))
                                        examdef.From_Exam_Site__c = fromSiteCodeMap.get(frmKey2);
                                      
                                        if(newExamSiteNewMap.containsKey(frmKey2)){
                                            examdef.To_Exam_Site__c =  newExamSiteNewMap.get(frmKey2);
                                        }else{
                                            examdef.To_Exam_Site__c = null;
                                        } 
                                }
                                examdef.Requested_Part__c = 'ERP Exam Part II';
                                examdef.Name = 'ERP Exam Part II ' +ss.Name;
                                examdefList.add(examdef);
                            }
                            
                        } 
                }
            }     
            
            if(examdefList.size()>0){
                insert examdefList; 
                for(integer i=0;i <examdefList.size();i++){
                    if(examwrapobj.ensOfExamGroup == 'Yes')
                        examdefList[i].Exam_Group_Registration_Deferral__c = true;
                    if(examwrapobj.moveSelectedMembers == 'Yes')
                        examdefList[i].Move_Selected_Members__c = true;
                    if(i != 0)
                        examdefList[i].Parent_Admin_Exam_Deferral__c = examdefList[0].Id;
                }
                update examdefList; 
                return 'Success: Admin Exam Deferral created successfully';
            }
        }catch(Exception ex){
            return ex.getMessage();
        }
        return null;
    }
    
    public static Map<String,String> getNewSIteCodes(List<String> examType,String ToGroupId,String FromToAdminData){ 
        Map<String,String> examAdminSiteMap = new Map<String,String>();
       // if(FromToAdminData == 'From Empty' ){
            Map<String,String> toadminExamSiteMap = new  Map<String,String>(); 
            List<SiteMappingCodes__c>  SiteMappingCodes = SiteMappingCodes__c.getAll().values();
            Set<String> newSiteId = new Set<String>();
            Map<String,String> SiteMappingCodesMap = new Map<String,String>();
            for(SiteMappingCodes__c sitest:SiteMappingCodes){  
                newSiteId.add(sitest.New_Site_Code__c);
                SiteMappingCodesMap.put(sitest.Old_Site_Code__c,sitest.New_Site_Code__c);
            }
            Map<String,Exam_Sites__c> examSiteOldMap = new  Map<String,Exam_Sites__c>();
            for(Exam_Sites__c es:[Select Id,Site__r.Site_Code__c,Exam__r.Exam__c From Exam_Sites__c Where Site__r.Site_Code__c In:newSiteId and Exam__r.Exam__c In:examType and Site__c !=null and Exam__r.Exam_Group__c =: ToGroupId ]){
                String s = es.Exam__r.Exam__c+''+es.Site__r.Site_Code__c;
                toadminExamSiteMap.put(s,es.Id);
            }  
            
            for(String s:SiteMappingCodesMap.KeySet()){
                String newval1 = 'FRM Part 1'+SiteMappingCodesMap.get(s);
                String newval2 = 'FRM Part 2'+SiteMappingCodesMap.get(s);
                String newval3 = 'ERP Exam Part I'+SiteMappingCodesMap.get(s);
                String newval4 = 'ERP Exam Part II'+SiteMappingCodesMap.get(s);
                if(toadminExamSiteMap.containsKey(newval1)) 
                    examAdminSiteMap.put('FRM Part 1'+s,toadminExamSiteMap.get(newval1));
                if(toadminExamSiteMap.containsKey(newval2)) 
                    examAdminSiteMap.put('FRM Part 2'+s,toadminExamSiteMap.get(newval2));
                if(toadminExamSiteMap.containsKey(newval3))
                    examAdminSiteMap.put('ERP Exam Part I'+s,toadminExamSiteMap.get(newval3));
                if(toadminExamSiteMap.containsKey(newval4))
                    examAdminSiteMap.put('ERP Exam Part II'+s,toadminExamSiteMap.get(newval4));
                
          //  }   
        }
        return examAdminSiteMap;
    }  
}