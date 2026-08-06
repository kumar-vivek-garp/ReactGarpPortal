public class GlobalBenchprepAccessClass {
   
    public class requestparems{
        @AuraEnabled
        public String garpId;
        @AuraEnabled
        public String conId;
        @AuraEnabled
        public List<courseslug> coursesluglist;
    }
    
    public class courseslug{
        @AuraEnabled
        public String expirationdate;
        @AuraEnabled
        public String slugId;
        @AuraEnabled
        public String courseId;
        @AuraEnabled
        public String slugtype;
        @AuraEnabled
        public String membershipslug;
        @AuraEnabled
        public String externalid;
        @AuraEnabled
        public Boolean isslugfound;  
    }
    
    public class responseclass{
        @AuraEnabled
        public Integer statuscode;
        @AuraEnabled
        public String  Message;
    }
    @AuraEnabled
    public static responseclass updatebenchpreAccess(String req){
        responseclass res = benchpreAccess(req);
        return res;
    }
    
    @AuraEnabled
    public static responseclass createEbookSlug(String req){
        responseclass res = createEbookSlugRecords(req);
        return res;
    }
    
    @AuraEnabled
    public static Map<String,String> getbenchpreuserAccess(String garpId){
        Map<String,String> getUserInfo = new Map<String,String>();
        if(garpId != null){
            List<User> userList = [SELECT Id,Bench_Prep_SSO_Attribute__c,Contact.GARP_Member_ID__c From User WHERE ContactId != null and Contact.GARP_Member_ID__c =:garpId];
            if(userList.size() > 0){
                User u = userList[0];  
                getUserInfo.put('Success',u.Bench_Prep_SSO_Attribute__c);
            }else{
                 getUserInfo.put('Error','Invalid GarpId.'); 
            } 
        }else{
           getUserInfo.put('Error','GarpId Not Found.');
        }
        return getUserInfo;
    }
    
    public static responseclass benchpreAccess(String req){
        responseclass res = new responseclass();
        try{
        requestparems reqcls = (requestparems) JSON.deserialize(req,requestparems.class);
        List<String> removeCourceList = new List<String>();
        List<courseslug> addsluglist = new List<courseslug>(); 
        Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
        Map<String,courseslug> addnewcourseMap = new Map<String,courseslug>();
        List<String> courses = new List<String>();
        for(courseslug cr:reqcls.coursesluglist){
            if(cr.slugtype == 'Remove'){
                removeCourceList.add(cr.slugId);
            }else if(cr.slugtype == 'Add'){
                addsluglist.add(cr); 
                addnewcourseMap.put(cr.courseId,cr);
                courses.add(cr.courseId);
            } 
        }
        if(reqcls.garpId != null){
            List<User> userList = [SELECT Id,Bench_Prep_SSO_Attribute__c,Contact.GARP_Member_ID__c From User WHERE ContactId != null and Contact.GARP_Member_ID__c =:reqcls.garpId];
            if(userList.size() > 0){
               User u = userList[0];
               Map<String,BenchPrepClass.benchPrepAttr> courseList = new Map<String,BenchPrepClass.benchPrepAttr>();
               String slug = u.Bench_Prep_SSO_Attribute__c;
                if(slug != null && slug != ''){
                    List<BenchPrepClass.benchPrepAttr> attrList = (List<BenchPrepClass.benchPrepAttr>)JSON.deserialize(slug,List<BenchPrepClass.benchPrepAttr>.class);
                    for(BenchPrepClass.benchPrepAttr attr : attrList){
                        if(attr.course_slug != null){
                            BenchPrepClass.benchPrepAttr newCourse = new BenchPrepClass.benchPrepAttr(); 
                            if(!removeCourceList.contains(attr.course_slug)){
                                courseList.put(attr.course_slug,attr);   
                            }
                        }
                    }
                }
                boolean addOnAdded = false;
                for(String course:addnewcourseMap.keySet()){  
                     BenchPrepClass.benchPrepAttr newCourse = new BenchPrepClass.benchPrepAttr();
                     courseslug crinfo = addnewcourseMap.get(course);
                        if(course == 'FRMBP'){
                            newCourse.course_slug = courseMap.get('FRMBP').Course_Slug__c;
                            newCourse.expiration_date = crinfo.expirationdate;
                            if(courses.contains('FRM1BPPE')){
                                BenchPrepClass.eventAttr evt = new BenchPrepClass.eventAttr();
                                evt.event_slug = courseMap.get('FRM1BPPE').Course_Slug__c;
                                evt.external_id = addnewcourseMap.get('FRM1BPPE').externalid;
                                BenchPrepClass.eventAttr evt1 = new BenchPrepClass.eventAttr();
                                evt1.event_slug = courseMap.get('FRMBP').Course_Slug__c;
                                evt1.external_id = '_';
                                newCourse.unlock_events = new List<BenchPrepClass.eventAttr>{evt,evt1};
                                addOnAdded = true;
                            }
                            courseList.put(courseMap.get('FRMBP').Course_Slug__c,newCourse);
                        }else if(course == 'FRM1BPPE' && addOnAdded == false && !courses.contains('FRMBP') && courseList.containskey(courseMap.get('FRMBP').Course_Slug__c)){
                            BenchPrepClass.benchPrepAttr frmCourse = courseList.get(courseMap.get('FRMBP').Course_Slug__c);
                            BenchPrepClass.eventAttr evt = new BenchPrepClass.eventAttr();
                            evt.event_slug = courseMap.get('FRM1BPPE').Course_Slug__c;
                            evt.external_id = crinfo.externalid;
                            BenchPrepClass.eventAttr evt1 = new BenchPrepClass.eventAttr();
                            evt1.event_slug = courseMap.get('FRMBP').Course_Slug__c;
                            evt1.external_id = '_';
                            frmCourse.unlock_events = new List<BenchPrepClass.eventAttr>{evt,evt1};
                            courseList.put(courseMap.get('FRMBP').Course_Slug__c,frmCourse);
                        }else if(course != 'FRM1BPPE'){
                            newCourse.course_slug = courseMap.get(course).Course_Slug__c;
                            newCourse.expiration_date = crinfo.expirationdate;
                            courseList.put(courseMap.get(course).Course_Slug__c,newCourse);
                        }
                    
                } 
                u.Bench_Prep_SSO_Attribute__c =  courseList.size()>0 ? JSON.serialize(courseList.values()):''; 
                update u;
                res.statuscode = 200;
                res.Message = u.Bench_Prep_SSO_Attribute__c; 
            }else{
                res.statuscode = 400;
                res.Message = 'Invalid GarpId.'; 
            }
        }else{
            res.statuscode = 400;
            res.Message = 'GarpId Not Found.';
        } 
        }catch(Exception ex){
            system.debug(ex.getMessage() +' '+ex.getLineNumber());
            res.statuscode = 400;
            res.Message = ex.getMessage();
        }
        return res;
    }
    
    
    public static responseclass createEbookSlugRecords(String req){
        responseclass res = new responseclass();
        try{
            requestparems reqcls = (requestparems) JSON.deserialize(req,requestparems.class);
            List<String> removeCourceList = new List<String>();
            List<courseslug> addsluglist = new List<courseslug>(); 
            Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
            Map<String,courseslug> addnewcourseMap = new Map<String,courseslug>();
            if(reqcls.garpId != null){
                List<User> userList = [SELECT Id,ContactId,Bench_Prep_SSO_Attribute__c,Contact.GARP_Member_ID__c From User WHERE ContactId != null and Contact.GARP_Member_ID__c =:reqcls.garpId];
                if(userList.size() > 0){
                    User u = userList[0];
                    Map<String,eBook_Key__c> updateEbookMap = new Map<String,eBook_Key__c>();
                    set<String> ebookaddkey = new set<String>();
                    set<String> ebookremovekey = new set<String>();
                     for(courseslug cr:reqcls.coursesluglist){
                        if(cr.slugtype == 'Remove'){
                            removeCourceList.add(cr.courseId); 
                            String removekey = u.ContactId+cr.slugId+'BenchPrep'; 
                            ebookremovekey.add(removekey);    
                        }else if(cr.slugtype == 'Add'){
                            String key = u.ContactId+cr.slugId+'BenchPrep'; 
                            ebookaddkey.add(key);
                            removeCourceList.add(cr.courseId); 
                        }
                     }
                    Map<String,String> ProductCodeMap = new Map<String,String>();
                    Set<String> productIdSet = new Set<String>();
                    for(Product2 pr:[Select Id,ProductCode,Product_Id__c From Product2 Where ProductCode In:removeCourceList and Product_Id__c != null]){
                        ProductCodeMap.put(pr.Product_Id__c,pr.ProductCode);
                        productIdSet.add(pr.Product_Id__c);
                    }  
                    Set<String> extEbookIds = new Set<String>();
                    for(eBook_Key__c eb:[Select Id,Key__c From eBook_Key__c Where Key__c In:ebookaddkey and Contact__c =:u.ContactId and Type__c = 'BenchPrep']){
						extEbookIds.add(eb.Key__c);                        
                    }
                    
                    Map<String,Id> removeEbookMap = new Map<String,Id>();
                     Map<String,Id> removeProductEbookMap = new Map<String,Id>();
                    for(eBook_Key__c eb:[Select Id,Key__c From eBook_Key__c Where Key__c In:ebookremovekey and Contact__c =:u.ContactId and Type__c = 'BenchPrep']){
						removeEbookMap.put(eb.Key__c,eb.Id);                        
                    }
                    for(eBook_Key__c eb:[Select Id,Product_ID__c From eBook_Key__c Where Product_ID__c In:productIdSet and Contact__c =:u.ContactId and Type__c = 'BenchPrep']){
						String prkey = ProductCodeMap.get(eb.Product_ID__c);
                        removeProductEbookMap.put(prkey,eb.Id);                        
                    } 
                    List<String> courses = new List<String>(); 
                    for(courseslug cr:reqcls.coursesluglist){
                        if(cr.slugtype == 'Remove'){
                            String removekey = u.ContactId+cr.slugId+'BenchPrep';  
                            if(removeEbookMap.containsKey(removekey)){ 
                                eBook_Key__c eb = new eBook_Key__c();
                                eb.Id = removeEbookMap.get(removekey);
                                eb.Cancelled__c = true;
                                eb.Canceled_Date_Time__c = system.now();
                                updateEbookMap.put(removekey,eb);
                            }else if(removeProductEbookMap.containsKey(cr.courseId)){
                                eBook_Key__c eb = new eBook_Key__c();
                                eb.Id = removeProductEbookMap.get(cr.courseId);
                                eb.Cancelled__c = true;
                                eb.Canceled_Date_Time__c = system.now();
                                updateEbookMap.put(removekey,eb);
							}
                        }else if(cr.slugtype == 'Add' && !removeProductEbookMap.containsKey(cr.courseId)){
                            eBook_Key__c eb = new eBook_Key__c(); 
                            eb.Product_ID__c = cr.slugId;
                            eb.Contact__c = u.ContactId;
                            eb.Is_API__c = true;
                            eb.Cancelled__c = false;
                            eb.Complimentary__c = true;
                            String addkey = u.ContactId+cr.slugId+'BenchPrep';
                            if(cr.expirationdate != null){
                                Date dt = Date.valueOf(cr.expirationdate);
                                eb.Access_Duration_in_Months__c = system.today().monthsBetween(dt);
                                eb.Access_Expiration_Date__c = dt; 
                            }else{
                                eb.Access_Duration_in_Months__c = 12;
                                eb.Access_Expiration_Date__c = system.today().addMonths(12);  
                            }
                            eb.Key__c = addkey;
                            eb.Type__c = 'BenchPrep'; 
                            if(!extEbookIds.contains(addkey)){
                                updateEbookMap.put(addkey,eb); 
                            }
                        } 
                    }
                    
                    if(!updateEbookMap.isEmpty()){
                        database.upsert(updateEbookMap.values(),false);
                    } 
                    res.statuscode = 200;
                    res.Message = 'Ebook Updated Successfully..';
                }
            }
        }catch(Exception ex){
            system.debug(ex.getMessage() +' '+ex.getLineNumber());
            res.statuscode = 400;
            res.Message = ex.getMessage();
        }
        return res;
    }
    
    @AuraEnabled
    public static requestparems getBenchPrepConfig(String objinfo) { 
        
        requestparems requestdata = new requestparems(); 
        requestdata.garpId = '';
        requestdata.coursesluglist = new List<courseslug>();
        system.debug(objinfo);
        Map<String, Map<String, String>> slugDataMap = getexestingSlugs(objinfo);
        for(BenchPrep_Config__mdt mtd:[Select Id,Course_Slug__c,Label,DeveloperName,Parent_Product_Code__c,Type__c From BenchPrep_Config__mdt Order By Type__c]){
            courseslug cr = new courseslug();
            cr.slugId = mtd.Course_Slug__c;
            cr.courseId = mtd.DeveloperName;
            cr.membershipslug = mtd.Type__c;
            cr.isslugfound = false;
            if (slugDataMap.containsKey(cr.slugId)) {
                Map<String, String> matchData = slugDataMap.get(cr.slugId);
                cr.isslugfound = true;
                cr.expirationdate = matchData.containskey('expiration_date')?matchData.get('expiration_date'):null;
                cr.externalid =  matchData.containskey('external_id')?matchData.get('external_id'):null;
                cr.slugtype = 'Add';
            }
             
            requestdata.coursesluglist.add(cr);
        }
        return requestdata;
    }
    
    public static Map<String, Map<String, String>> getexestingSlugs(String objinfo){ 
        // Step 1: Parse JSON and build lookup Map<event_slug, (external_id + expiration)>
        Map<String, Map<String, String>> slugDataMap = new Map<String, Map<String, String>>();
        system.debug(objinfo);
        if(objinfo != null && objinfo != ''){
            List<Object> parsedList = (List<Object>) JSON.deserializeUntyped(objinfo);
            
            for (Object obj : parsedList) {
                if (obj instanceof Map<String, Object>) {
                    Map<String, Object> recordMap = (Map<String, Object>) obj;
                    
                    String expirationDate = (String) recordMap.get('expiration_date');
                    String courseSlug = (String) recordMap.get('course_slug');
                    
                    // First, add course_slug to map
                    if (courseSlug != null) {
                        slugDataMap.put(courseSlug, new Map<String, String>{
                            'expiration_date' => expirationDate,
                                'external_id' => null
                                });
                    }
                    
                    // Then scan unlock_events if present
                    if (recordMap.containsKey('unlock_events')) {
                        Object unlockObj = recordMap.get('unlock_events');
                        if (unlockObj instanceof List<Object>) {
                            for (Object entry : (List<Object>) unlockObj) {
                                if (entry instanceof Map<String, Object>) {
                                    Map<String, Object> entryMap = (Map<String, Object>) entry;
                                    
                                    if (entryMap.containsKey('event_slug')) {
                                        String eventSlug = (String) entryMap.get('event_slug');
                                        String externalId = (String) entryMap.get('external_id');
                                        
                                        slugDataMap.put(eventSlug, new Map<String, String>{
                                            'expiration_date' => expirationDate,
                                                'external_id' => externalId
                                                });
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        return slugDataMap;
    }
    
    
    
}