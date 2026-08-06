public class BenchprepMembersAccess {
    static Id SCRRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','SCR_Program');
    static Id RAIRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Risk_AI_Program');
    static Id RAIJRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','RAIJ_Program');//Chinnapa
    static Id FRMRecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRM_Program');
    static Id FRR25RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','FRR25_Program');
    static Id MembershipContractRTId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract','Membership'); 
    public static void updateMemberBenchprep(List<String> contractIds,String memtype){
        try{
        List<String> recordtypeName = new List<String>{SCRRecordTypeId,FRR25RecordTypeId,RAIRecordTypeId,RAIJRecordTypeId,FRMRecordTypeId,MembershipContractRTId};
        
        Map<String,List<Contract>> memberContractMap = new Map<String,List<Contract>>();
        Map<String,String> ebookMap = new Map<String,String>(); 
        Map<String,String> cancelEbookMap = new Map<String,String>(); 
        Map<String,eBook_Key__c> updateEbookMap = new Map<String,eBook_Key__c>(); 
        Map<Id,Contract> memberProgramMap = new Map<Id,Contract>(); 
        Set<Id> removememberId = new Set<Id>();
        Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
        Set<String> removeCourceList = new Set<String>();
        for(String bpc:courseMap.keySet()){
            BenchPrep_Config__mdt b = courseMap.get(bpc);
            if(b.Type__c == 'Members Benchprep'){
                removeCourceList.add(b.Course_Slug__c);
            }
        } 
            //system.debug(removeCourceList);
        Map<String,User> benchPrepUserMap = new Map<String,User>(); 
        for(Contract con:[Select Id,Part_2_completed_date__c,AccountId,CustomerSignedId,Status,RecordTypeId,RecordType.DeveloperName,EndDate From Contract Where (Id In:contractIds Or AccountId In:contractIds) and RecordTypeId In:recordtypeName]){
            if(((con.RecordTypeId == SCRRecordTypeId || con.RecordTypeId == RAIRecordTypeId || con.RecordTypeId == RAIJRecordTypeId || con.RecordTypeId == FRR25RecordTypeId) && con.Status == 'Completed') || (con.RecordTypeId == FRMRecordTypeId && (con.Part_2_completed_date__c != null || con.Status == 'Completed')) || (con.RecordTypeId == MembershipContractRTId)){
                if(memberContractMap.containsKey(con.AccountId)){
                    memberContractMap.get(con.AccountId).add(con);
                }else{
                    memberContractMap.put(con.AccountId,new List<Contract>{con}); 
                } 
            }
        }   
        if(memberContractMap.size() >0){
            for(eBook_Key__c ebook:[Select Id,Cancelled__c,Key__c,Contact__r.AccountId,Product_ID__c From eBook_Key__c Where Contact__r.AccountId In:memberContractMap.keySet() and Product_ID__c In:removeCourceList]){
                if(memtype == 'MemberBenchprep'){
                    ebookMap.put(ebook.Key__c,ebook.Id);
                }else if(memtype == 'MemberRenewal' && ebook.Cancelled__c == false){
                    String key = ebook.Contact__r.AccountId+''+ebook.Product_ID__c;
                    cancelEbookMap.put(key,ebook.Id); 
                }
            } 
            for(Contract mc:[Select Id,AccountId,StartDate,EndDate From Contract Where RecordTypeId =: MembershipContractRTId and AccountId In:memberContractMap.keySet() and Membership_Type__c = 'Individual' and (Status = 'Activated ( Auto-Renew )' or Status = 'Activated')]){
                memberProgramMap.put(mc.AccountId,mc);
            }  
            //Canceled Program
            for(Contract mc:[Select Id,AccountId,EndDate,StartDate From Contract Where  RecordTypeId =: MembershipContractRTId and AccountId In:memberContractMap.keySet() and AccountId Not In:memberProgramMap.keySet() and Membership_Type__c = 'Individual' and (Status = 'Expired' or Status = 'Canceled') Order By LastModifiedDate Desc]){
                if(!memberProgramMap.containsKey(mc.AccountId)){
                    memberProgramMap.put(mc.AccountId,mc);
                }
                removememberId.add(mc.AccountId); 
            }  
            List<User> lstUsers = new List<User>();
            for(User u:[Select Id,contact.AccountId,contactId,Bench_Prep_SSO_Attribute__c From User Where contact.AccountId In:memberContractMap.keySet()]){
                Boolean isupdate = false;
                Map<String,BenchPrepClass.benchPrepAttr> courseList = new Map<String,BenchPrepClass.benchPrepAttr>();
                if(String.isNotBlank(u.Bench_Prep_SSO_Attribute__c)){
                    List<BenchPrepClass.benchPrepAttr> attrList = (List<BenchPrepClass.benchPrepAttr>)JSON.deserialize(u.Bench_Prep_SSO_Attribute__c,List<BenchPrepClass.benchPrepAttr>.class);
                    for(BenchPrepClass.benchPrepAttr attr : attrList){
                        if(removememberId.contains(u.contact.AccountId)){
                            //system.debug(attr.course_slug);
                            if(attr.course_slug != null && !removeCourceList.contains(attr.course_slug)){
                                courseList.put(attr.course_slug,attr);  
                                isupdate = true; 
                            }else if(removeCourceList.contains(attr.course_slug)){ 
                                Contract con = memberProgramMap.get(u.contact.AccountId); 
                                String stdate =  con.StartDate.format().replace('/','');
                                String eddate =  con.EndDate.format().replace('/','');
                                string key = con.Id+stdate+eddate+attr.course_slug+'BenchPrep'; 
                                if(ebookMap.containskey(key)){
                                     isupdate = true;
                                    eBook_Key__c eb = new eBook_Key__c();
                                    eb.Id = ebookMap.get(key);
                                    eb.Cancelled__c = true;
                                    eb.Canceled_Date_Time__c = system.now();
                                    updateEbookMap.put(key,eb);
                                }
                            }
                        }else{
                            if(courseMap.containsKey('FRM_Program') && courseMap.get('FRM_Program').Course_Slug__c != attr.course_slug){
                                courseList.put(attr.course_slug,attr); 
                                isupdate = true;
                            }
                        }
                    } 
                } 
                
                if(!removememberId.contains(u.contact.AccountId) && memberContractMap.containsKey(u.contact.AccountId) && memberProgramMap.containsKey(u.contact.AccountId)){
                    for(Contract c:memberContractMap.get(u.contact.AccountId)){ 
                        if(courseMap.containsKey(c.RecordType.DeveloperName)){
                            BenchPrepClass.benchPrepAttr newCourse = new BenchPrepClass.benchPrepAttr();
                            newCourse.course_slug = courseMap.get(c.RecordType.DeveloperName).Course_Slug__c;
                            Contract con = memberProgramMap.get(u.contact.AccountId); 
                            String stdate =  con.StartDate.format().replace('/','');
                            String eddate =  con.EndDate.format().replace('/','');
                            string key = con.Id+stdate+eddate+newCourse.course_slug+'BenchPrep'; 
                            newCourse.expiration_date = string.valueOf(con.EndDate);
                            if((c.RecordTypeId == FRMRecordTypeId && c.Status != 'Expired') || c.RecordTypeId != FRMRecordTypeId){
                            	courseList.put(courseMap.get(c.RecordType.DeveloperName).Course_Slug__c,newCourse);
                                isupdate = true;
                            } 
                            if(c.RecordTypeId == SCRRecordTypeId && c.Status == 'Completed' && ((courseMap.containsKey('SCR_Holders') && courseMap.get('SCR_Holders').Start_Date__c != null && courseMap.get('SCR_Holders').Start_Date__c <= system.today() && courseMap.get('SCR_Holders').End_Date__c >= system.today()) || Test.isRunningTest())){
                            	newCourse = new BenchPrepClass.benchPrepAttr();
                                newCourse.course_slug = courseMap.get('SCR_Holders').Course_Slug__c;
                                newCourse.expiration_date = string.valueOf(courseMap.get('SCR_Holders').End_Date__c);
                                courseList.put(newCourse.course_slug,newCourse); 
                                eBook_Key__c eb = new eBook_Key__c(); 
                                eb.Product_ID__c = newCourse.course_slug;
                                eb.Contact__c = u.ContactId;
                                eb.Is_API__c = true;
                                eb.Cancelled__c = false;
                                eb.Complimentary__c = true;
                                String scrholderkey = con.Id+''+u.ContactId+newCourse.course_slug+'BenchPrep';  
                                eb.Access_Duration_in_Months__c = 12;
                                eb.Access_Expiration_Date__c = system.today().addMonths(12); 
                                eb.Key__c = scrholderkey;
                                eb.Type__c = 'BenchPrep'; 
                                updateEbookMap.put(scrholderkey,eb); 
                                isupdate = true;
                            }
                            string ebkey = u.contact.AccountId+newCourse.course_slug; 
                            if(memtype == 'MemberRenewal' && cancelEbookMap.containsKey(ebkey)){
                                eBook_Key__c eb = new eBook_Key__c();
                                eb.Id = cancelEbookMap.get(ebkey);
                                eb.Cancelled__c = true;
                                eb.Canceled_Date_Time__c = system.now();
                                updateEbookMap.put(eb.Id,eb); 
                            }
                            if(!ebookMap.containsKey(key)){
                                eBook_Key__c eb = new eBook_Key__c(); 
                                eb.Product_ID__c = newCourse.course_slug;
                                eb.Contact__c = u.ContactId;
                                eb.Is_API__c = true;
                                eb.Cancelled__c = false;
                                eb.Complimentary__c = true;
                                if(!ebookMap.containsKey(key)){
                                    eb.Access_Duration_in_Months__c = 12;
                                    eb.Access_Expiration_Date__c = system.today().addMonths(12);
                                }
                                eb.Key__c = key;
                                eb.Type__c = 'BenchPrep'; 
                                updateEbookMap.put(key,eb); 
                            }else if(ebookMap.containsKey(key) && c.RecordTypeId == FRMRecordTypeId){
                                eBook_Key__c eb = new eBook_Key__c();
                                eb.Id = ebookMap.get(key);
                                if(c.Status == 'Expired'){
                                    eb.Cancelled__c = true;
                                    eb.Canceled_Date_Time__c = system.now();
                                }else if(c.Status == 'Activated'){
                                    eb.Cancelled__c = false; 
                                }
                                updateEbookMap.put(eb.Id,eb); 
                            }
                        } 
                    } 
                    
                } 
                if(isupdate == true){ 
                    u.Bench_Prep_SSO_Attribute__c =  courseList.size()>0 ? JSON.serialize(courseList.values()):''; 
                    lstUsers.add(u); 
                }
            }              
            if(!updateEbookMap.isEmpty() && !Test.isRunningTest()){
                database.upsert(updateEbookMap.values(),false);
            } 
            if(!lstUsers.isEmpty()){ 
                update lstUsers; 
            } 
        }
        }catch(Exception ex){
            system.debug(ex.getMessage() +' '+ex.getLineNumber());
        }
    }
}