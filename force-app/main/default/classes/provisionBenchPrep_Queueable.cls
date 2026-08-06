public class provisionBenchPrep_Queueable implements System.Queueable, Database.AllowsCallouts{

    public Set<Id> oppIdSet = new Set<Id>();
    
    public provisionBenchPrep_Queueable(Set<Id> oppIds){
        this.oppIdSet = oppIds;
    }
    
    public void execute(System.QueueableContext context) {
       updateuserinformation( this.oppIdSet);
        
    }
    
    public static void updateuserinformation(Set<Id> oppIdSet){
		 Set<Id> accountIds = new Set<Id>();
        Map<Id,List<String>> contactCourseMap = new Map<Id,List<String>>();
        List<String> BPProductcodes = IntegrationsMtdUtil.BPProductcodes;
        List<Opportunity> oppslist = [Select Id,name,Shipping_First_Name__c,Shipping_Last_Name__c,GARP_Member_ID__c,Shipping_E_mail__c,
                                             Billing_Email__c, Billing_First_Name__c, Billing_Last_Name__c,
                                             Display_Invoice_Number__c,AccountId,
                                            (SELECT Id,ProductCode, Product_ID__c FROM OpportunityLineItems),
                                            (select id, Product_ID__c from eBook_Keys__r)
                                      from Opportunity where Id IN: oppIdSet];
        //System.debug('oppslist:' + oppslist);
        
        for(Opportunity opp : oppslist){
            accountIds.add(opp.AccountId);
        }
        //System.debug('accountIds:' + accountIds);
        
        List<Contact> lstContacts = [select Id, AccountId from Contact where AccountId in :accountIds];
        //System.debug('lstContacts:' + lstContacts);
        Map<String,Contact> mapContactsByAccountId = new Map<String,Contact>();
        for(Contact cont :lstContacts) {
            mapContactsByAccountId.put(cont.AccountId,cont);
        }
        
        

        
        MAP<String, String> contactIdToInvMap = new MAP<String, String>();
        List<eBook_Key__c> lstNewEBooks = new List<eBook_Key__c>();
       
        for(Opportunity opp :oppslist) {
            Contact fndCont = mapContactsByAccountId.get(opp.AccountId);
            if(fndCont != NULL) {
                contactIdToInvMap.put(fndCOnt.Id,opp.Display_Invoice_Number__c);
                
                SET<String> existingEBookKeys = new SET<String>();
                for(eBook_Key__c ek :opp.eBook_Keys__r) {
                    existingEBookKeys.add(ek.Product_ID__c);
                }
               // System.debug('existingEBookKeys:' + existingEBookKeys);
                
                for(OpportunityLineItem ol :opp.OpportunityLineItems){
                    // Replace with Real Product Code
                    if(BPProductcodes.contains(ol.ProductCode)) { //Chinnapa
                        if(!existingEBookKeys.Contains(ol.Product_ID__c)) {
                            eBook_Key__c newEbook = new eBook_Key__c(
                                Member_EMail__c = opp.Shipping_E_mail__c,
                                Type__c = 'BenchPrep',
                                Opportunity__c = opp.Id,
                                Contact__c = fndCont.Id,
                                Product_ID__c = ol.Product_ID__c,
                                Key__c = opp.Id + ol.ProductCode.replace('BP','BenchPrep'),
                                Is_API__c = True,
                                Access_Duration_in_Months__c = 12,
                                Access_Expiration_Date__c = Date.today().addMonths(12)
                            );
                            lstNewEBooks.add(newEbook);
                        }
                        if(contactCourseMap.containskey(fndCont.Id)){
                            List<String> courses = contactCourseMap.get(fndCont.Id);
                            courses.add(ol.ProductCode);
                            contactCourseMap.put(fndCont.Id,courses);
                        }else{
                            contactCourseMap.put(fndCont.Id,new List<String>{ol.ProductCode});
                        } 
                        //break;
                    }else if(ol.ProductCode == 'FRMBP'){
                        if(!existingEBookKeys.Contains(ol.Product_ID__c)) {
                            eBook_Key__c newEbook = new eBook_Key__c(
                                Member_EMail__c = opp.Shipping_E_mail__c,
                                Type__c = 'BenchPrep',
                                Opportunity__c = opp.Id,
                                Contact__c = fndCont.Id,
                                Product_ID__c = ol.Product_ID__c,
                                Key__c = opp.Id + 'FRMBenchPrep',
                                Is_API__c = True,
                                Access_Duration_in_Months__c = 12,
                                Access_Expiration_Date__c = Date.today().addMonths(12)
                            );
                            lstNewEBooks.add(newEbook);
                        }
                        if(contactCourseMap.containskey(fndCont.Id)){
                            List<String> courses = contactCourseMap.get(fndCont.Id);
                            courses.add('FRMBP');
                            contactCourseMap.put(fndCont.Id,courses);
                        }else{
                            contactCourseMap.put(fndCont.Id,new List<String>{'FRMBP'});
                        }
                    }else if(ol.ProductCode == 'FRM1BPPE'){
                        if(!existingEBookKeys.Contains(ol.Product_ID__c)) {
                            eBook_Key__c newEbook = new eBook_Key__c(
                                Member_EMail__c = opp.Shipping_E_mail__c,
                                Type__c = 'BenchPrep',
                                Opportunity__c = opp.Id,
                                Contact__c = fndCont.Id,
                                Product_ID__c = ol.Product_ID__c,
                                Key__c = opp.Id + 'FRMBenchPrepExam',
                                Is_API__c = True,
                                Access_Duration_in_Months__c = 12,
                                Access_Expiration_Date__c = Date.today().addMonths(12)
                            );
                            lstNewEBooks.add(newEbook);
                        }
                        if(contactCourseMap.containskey(fndCont.Id)){
                            List<String> courses = contactCourseMap.get(fndCont.Id);
                            courses.add('FRM1BPPE');
                            contactCourseMap.put(fndCont.Id,courses);
                        }else{
                            contactCourseMap.put(fndCont.Id,new List<String>{'FRM1BPPE'});
                        }
                    } 
                }
            }
        }
                      
        if(!lstContacts.isEmpty()) {
            Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
            List<User> lstUsers = [select Id, Bench_Prep_SSO_Attribute__c,ContactId,Community_Contact_GARP_ID__c from User where ContactId in :lstContacts];
            //System.debug('lstUsers:' + lstUsers);
            
            for(User u :lstUsers) {
                System.debug('u:' + u);
                    
                Map<String,BenchPrepClass.benchPrepAttr> courseList = new Map<String,BenchPrepClass.benchPrepAttr>();
                //u.Bench_Prep_SSO_Attribute__c = '[ { "course_slug": "scr", "expiration_date": "' + String.valueOf(Date.today().addMonths(12)) + '" } ]';
                if(String.isNotBlank(u.Bench_Prep_SSO_Attribute__c)){
                    List<BenchPrepClass.benchPrepAttr> attrList = (List<BenchPrepClass.benchPrepAttr>)JSON.deserialize(u.Bench_Prep_SSO_Attribute__c,List<BenchPrepClass.benchPrepAttr>.class);
                    for(BenchPrepClass.benchPrepAttr attr : attrList){
                        courseList.put(attr.course_slug,attr);
                    }
                }
               // System.debug('courseList:' + courseList);
                
                if(contactCourseMap.containskey(u.ContactId)){
                    List<String> courses = contactCourseMap.get(u.ContactId);
                   // System.debug('courses:' + courses);
                    
                    boolean addOnAdded = false;
                    for(string course : courses){
                        
                        //System.debug('course:' + course);
                        
                        BenchPrepClass.benchPrepAttr newCourse = new BenchPrepClass.benchPrepAttr();
                        if(BPProductcodes.contains(course)){
                            newCourse.course_slug = courseMap.get(course).Course_Slug__c;
                            newCourse.expiration_date = String.valueOf(Date.today().addMonths(12));
                            courseList.put(courseMap.get(course).Course_Slug__c,newCourse);
                        }else if(course == 'FRMBP'){
                            newCourse.course_slug = courseMap.get('FRMBP').Course_Slug__c;
                            newCourse.expiration_date = String.valueOf(Date.today().addMonths(12));
                            if(courses.contains('FRM1BPPE')){
                                BenchPrepClass.eventAttr evt = new BenchPrepClass.eventAttr();
                                evt.event_slug = courseMap.get('FRM1BPPE').Course_Slug__c;
                                evt.external_id = contactIdToInvMap.containskey(u.ContactId) ? contactIdToInvMap.get(u.ContactId) : u.Community_Contact_GARP_ID__c;
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
                            evt.external_id = contactIdToInvMap.containskey(u.ContactId) ? contactIdToInvMap.get(u.ContactId) : u.Community_Contact_GARP_ID__c;
                            BenchPrepClass.eventAttr evt1 = new BenchPrepClass.eventAttr();
                            evt1.event_slug = courseMap.get('FRMBP').Course_Slug__c;
                            evt1.external_id = '_';
                            frmCourse.unlock_events = new List<BenchPrepClass.eventAttr>{evt,evt1};
                            courseList.put(courseMap.get('FRMBP').Course_Slug__c,frmCourse);
                        } 
                    }
                } 
                //System.debug('final courseList:' + courseList);
                
                u.Bench_Prep_SSO_Attribute__c =  JSON.serialize(courseList.values());
            }
            
            //System.debug('lstNewEBooks:' + lstNewEBooks);
            if(lstNewEBooks.size() >0){
            	insert lstNewEBooks;
            }
            if(!Test.isRunningTest()){
                update lstUsers;
            }
        }
    }
}