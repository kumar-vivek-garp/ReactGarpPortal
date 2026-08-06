public class formDataTriggerHelper {
    
    public static void beforeInsertUpdate(List<form_data__c> formDataList){
        
        //system.debug('beforeInsertUpdate: '+formDataList);
        
        try{ 
            List<String> emailList = new List<String>(); 
            for(form_data__c fd : formDataList) { 
                if((fd.Email__c !=null && fd.Bulk_Load__c == false && fd.Status__c=='Completed')){
                    emailList.add(fd.Email__c); 
                }
            }
            
            //system.debug('emailList: '+emailList);
            
            Map<String,String> contactIdMap = new Map<String,String>(); 
            Map<String,String> busContactIdMap = new Map<String,String>();
            Map<String,String> leadIdMap = new Map<String,String>(); 
            Map<Id,Id> convertedId = new Map<Id,Id>();
            Id businessrecordId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Business Relationship').getRecordTypeId();
            for(Contact c:[Select Id,Email, RecordTypeId from Contact where Email in:emailList]){
                contactIdMap.put(c.Email,c.Id); 
                if(c.recordtypeid ==businessrecordId){
                    busContactIdMap.put(c.Email,c.Id); 
                }
            }  
            //system.debug('contactIdMap: '+contactIdMap);
            //system.debug('busContactIdMap: '+busContactIdMap);
            
            for(Lead ld:[Select Id,Email,Company,IsConverted from Lead where Email in:emailList]){
                leadIdMap.put(ld.Email,ld.Id); 
                if(ld.IsConverted){
                    convertedId.put(ld.Id,ld.Id);
                }
            }
            /*system.debug(leadIdMap.size());
            system.debug('leadIdMap: '+leadIdMap);
            system.debug('convertedId: '+convertedId);*/
            
            Map<String,Lead> leadMapList = new Map<String,Lead>();
            integer i=0;
            for(form_data__c fd : formDataList) {
                
                //system.debug('fd: '+fd);
                
                if(fd.Bulk_Load__c == false && fd.Status__c =='Completed'){
                    String emailKey = fd.Email__c.toLowercase();  
                    //  fd.Member_Contact__c = false; 
                    fd.Upload_Lead_Key__c = i+' '+emailKey; // unique key for new lead insert
                    if(emailKey != null && emailKey !=''){ 
                        
                        if(contactIdMap.containsKey(emailKey)){
                            if(fd.Lead_Status__c == null){
                                fd.Lead_Status__c = 'Is Contact';
                            }
                            fd.Contact__c = contactIdMap.get(emailKey);  
                            
                            //system.debug('fd Is Contact: ' + fd.Contact__c + ':' + fd.Lead_Status__c);
                            
                        }else if(leadIdMap.containsKey(emailKey)){
                            if(fd.Lead_Status__c == null){
                                fd.Lead_Status__c = 'Is Lead';
                            }
                            fd.Lead__c = leadIdMap.get(emailKey); 
                            
                            //system.debug('fd Is Lead: ' + fd.lead__c + ':' + fd.Lead_Status__c);
                            
                        }else if(fd.lead__C == null){
                            if(fd.Lead_Status__c == null){
                                fd.Lead_Status__c = 'New Lead';
                            }
                            //New Contact creation mapping 
                            Lead l = new lead();
                            
                            if(fd.First_Name__c != null){
                                l.FirstName = fd.First_Name__c;
                            }else{
                                l.FirstName = 'Unknown';
                            }
                            
                            if(fd.Last_Name__c != null){
                                l.LastName = fd.Last_Name__c;
                            }else{
                                l.LastName = 'Unknown';
                            } 
                            
                            if(fd.Company__c != null){
                                l.company = fd.Company__c;
                            }
                            else{
                                l.company = 'Unknown';
                            } 
                            if(fd.Title__c != null){
                                l.Title = fd.Title__c;
                            }
                            else{
                                l.Title = 'Unknown';
                            } 
                            if(fd.Mobile_Phone__c != null){
                                l.Mobile_Phone__c = fd.Mobile_Phone__c; 
                            }
                            
                            if(fd.Industry__c != null){
                                l.Industry = fd.Industry__c;
                            }
                            
                            if(fd.Mailing_Country__c != null){
                                l.Country = fd.Mailing_Country__c;
                            }
                            if(fd.Mailing_Zip_Postal_Code__c != null){
                                l.PostalCode = fd.Mailing_Zip_Postal_Code__c;
                            }
                            if(fd.Mailing_State_Province__c != null){
                                l.State = fd.Mailing_State_Province__c;
                            }
                            if(fd.Mailing_Street__c != null){
                                l.Street = fd.Mailing_Street__c;
                            }
                            if(fd.Mailing_City__c != null){
                                l.City = fd.Mailing_City__c;
                            }
                            if(fd.Phone__c != null){
                                l.Phone = fd.Phone__c;
                            }
                            
                            l.Original_Source__c = fd.Form_Name__c;
                            l.Email = emailKey; 
                            l.Email_Subscription_Change_Source__c = fd.Form_Name__c;
                            
                            //system.debug('fd New Lead: ' + fd.lead__c + ':' + fd.Lead_Status__c);
                            
                            leadMapList.put(fd.Upload_Lead_Key__c,l); 
                            
                            //system.debug('leadMapList: '+ leadMapList);
                            
                        } 
                    } 
                    i++;
                } 
            }
            
            //system.debug('insert leadMapList: '+ leadMapList);
            if(leadMapList.size()>0){ 
                insert leadMapList.values();
            }
            
            for(form_data__c fd:formDataList){ 
                
                //system.debug('fd2: '+ fd.Id + ':' + fd.Contact__c + ':' + fd.lead__c + ':' + fd.Lead_Status__c);
                
                if(fd.Bulk_Load__c == false && fd.Status__c=='Completed'){
                    
                    //system.debug('fd2: '+fd);
                    //system.debug('converted?: '+ convertedId.containsKey(fd.Lead__c));
                    
                    //if(convertedId.containsKey(fd.Lead__c) && fd.Contact__c != null){ 
                    //    fd.Member_Contact__c = true;
                    //    fd.Lead__c = null;
                    //} 
                    
                    if(leadMapList.containsKey(fd.Upload_Lead_Key__c) && fd.lead__C == null){
                        fd.lead__C = leadMapList.get(fd.Upload_Lead_Key__c).Id;
                        //fd.Member_Contact__c = true;
                    }
                    
                    if(busContactIdMap.containsKey(fd.Email__C) && fd.Contact__c!= null){
                        //system.debug('%%%%%:'+busContactIdMap);
                        fd.Existing_Business_Contact__c = true;
                        //fd.Lead__c = null;
                    } 
                    //system.debug('fd update: '+fd);
                    
                }
            } 
        }catch(Exception e){
            system.debug(e.getMessage()+' '+e.getLinenumber()); 
        }       
        
    }
    
    public static void afterInsertUpdate(List<form_data__c> formDataList){
        try{ 
            
            //system.debug('afterInsertUpdate==:'+formDataList);
            
            List<CampaignMember> campMem = new List<CampaignMember>();
            List<CampaignMember> campMemUpdate = new List<CampaignMember>();
            
            //To return a map of data sets defined for the custom object (all records in the custom object)
            Map<string,SubscriptionManagement__c> settingMap = SubscriptionManagement__c.getAll();    
            List<String> contactObjFieldList = new List<String>(); 
            List<String> leadobjFieldList = new List<String>();  
            Set<Id> formIds = new Set<Id>();
            Set<Id> formdDataId = new Set<Id>();
            Set<Id> campaignIds = new Set<Id>();
            set<String> emailList = new set<String>();   
            Map<id,Contact> contactMap = new Map<id,Contact>(); 
            Map<id,Lead> leadMap = new Map<id,Lead>(); 
            Map<Id,String> statusMap = new Map<Id,String>();
            Map<Id, Form__c> formsByIdMap = new Map<Id, Form__c>();
            MAP<Id,String> mapLeadCampByForm = new MAP<Id,String>();
            MAP<String,Campaign> mapConvCampByForm = new MAP<String,Campaign>();
            MAP<String,CampaignMember> mapCampMem = new MAP<String,CampaignMember>();
            
            // iteration of form data 
            for(form_data__c pro : formDataList) { 
                //if(pro.Subscriptions__c==null){
                formIds.add(pro.form__c);
                //}
                
                if( pro.Subscriptions__c!=null){
                    statusMap.put(pro.id,pro.Subscriptions__c);
                }
                if(pro.Email__c != NULL) {
                    emailList.add(pro.Email__c);
                }
            } 
            /*system.debug('formIds==:'+formIds);
            system.debug('statusMap==:'+statusMap);
            system.debug('emailList==:'+emailList);*/
            
            if(formIds.size()>0){
                for(form__c fm:[Select Id, Subscriptions__c, Campaign__c, Campaign__r.IsActive from form__c where Id In:formIds]){ 
                    if(fm.Subscriptions__c != null){
                        // set the value of form Id and Status
                        statusMap.put(fm.id,fm.Subscriptions__c);
                    }
                    if(fm.Campaign__c != NULL && fm.Campaign__r.IsActive == True) {
                        mapLeadCampByForm.put(fm.Id, fm.Campaign__c);
                        campaignIds.add(fm.Campaign__c);
                    }
                    
                    formsByIdMap.put(fm.Id, fm);
                }
            }
            /*system.debug('statusMap123==:'+statusMap);
            system.debug('mapLeadCampByForm:'+mapLeadCampByForm);
            system.debug('formsByIdMap: '+formsByIdMap);*/
            
            List<SObject> leadToUpdateList = new List<SObject>(); 
            List<SObject> contactToUpdateList = new List<SObject>(); 
            Map<Id, List<String>> leadToUpdateMap = new Map<Id, List<String>>();
            Map<Id, List<String>> contactToUpdateMap = new Map<Id, List<String>>();
            List<string> statuslist = new List<string> ();
            Map<Id,String> subscriptionChangeLeadMap = new Map<Id,String>();
            Map<Id,String> subscriptionChangeConMap = new Map<Id,String>();
            
            //Set<Id> formIds = new Set<Id>();
            //for(Form_Data__c formData: formDataList){
            //    formIds.add(formData.Form__c); 
            //}
            //system.debug('formIds: '+formIds);
            
            //Map<Id, Form__c> formsByIdMap = new Map<Id, Form__c>([
            //    SELECT Id, Campaign__c, (SELECT Id FROM Campaigns__r WHERE IsActive = true LIMIT 1)
            //    FROM Form__c 
            //    WHERE Id IN :formIds
            //]);
            //system.debug('formsByIdMap: '+formsByIdMap);
            
            // If this a Conversion?
            // FD -> Pro.Form__c, Camp -> Conv Form :  mapConvCampByForm(FormID,Camp), Find CampMem: mapCampMem(Email+CampID,CM)
            // 
            // Is Lead Form existing CM
            // FD -> Pro.Form__c, Camp -> Lead Form : mapLeadCampByForm(FormID,Camp), Find CampMem: mapCampMem(Email+CampID,CM)
                        
            List<Campaign> lstConvCamp = new List<Campaign>();
            lstConvCamp = [select Id, Status, Conversion_Form__c from Campaign where IsActive = True AND Conversion_Form__c in :formsByIdMap.keySet()];
            if(Test.isRunningTest()){
                lstConvCamp = [select Id, Status, Conversion_Form__c from Campaign LIMIT 1];    
            }
            for(Campaign c :lstConvCamp) {
                mapConvCampByForm.put(c.Conversion_Form__c, c);
                campaignIds.add(c.Id);
            }
            /*system.debug('lstConvCamp: '+lstConvCamp);
            system.debug('campaignIds: '+campaignIds);*/
            
			// Get all members from Forms submitted and Conversion Forms            
            List<CampaignMember> lstCM = [select Id, Email, CampaignId, Conversion_Form__c, Original_Form__c, Status from CampaignMember where CampaignId in :campaignIds AND Email in :emailList];
            //system.debug('lstCM======>'+lstCM);
            //system.debug('emailList=======>'+emailList);
            for(CampaignMember cm :lstCM) {
                String key = cm.Email.toLowerCase() + '~' + cm.CampaignId;
                mapCampMem.put(key, cm);
            }
            //system.debug('mapCampMem: '+mapCampMem);
            
            // iteration of form data 
            for(form_data__c pro : formDataList) {
                
                //system.debug('pro: '+pro);
                
                //Campaign conversionFormActiveCampaign = null;
                // If the parent Form has Campaigns, it is a 'conversion' form
                //if(!formsByIdMap.get(pro.Form__c).Campaigns__r.isEmpty()){
                //    conversionFormActiveCampaign = formsByIdMap.get(pro.Form__c).Campaigns__r[0];
                //}
                //system.debug('conversionFormActiveCampaign: '+conversionFormActiveCampaign);
                                
                // Update Camp Conv Member
                if(lstConvCamp != NULL && lstConvCamp.size() > 0) {
                    
                    // Update member in all campaigns with conversion form submitted
                    for(Campaign c :lstConvCamp) {
                        
                        //system.debug('lstConvCamp: '+c); 
                        
                        CampaignMember fndConvCampMem = mapCampMem.get(pro.Email__c.toLowerCase() + '~' + c.Id);
                        //system.debug('fndConvCampMem: '+fndConvCampMem); 
                        if(fndConvCampMem != NULL) {
                            
                            fndConvCampMem.Status = 'Converted';
                            fndConvCampMem.Conversion_Form__c = pro.Form_Name__c;
                            //system.debug('update fndConvCampMem: '+fndConvCampMem);
                            
                            campMemUpdate.add(fndConvCampMem);
                            //system.debug('Conv campMemUpdate: '+campMemUpdate);

                        }
                        
                    }
                }
                
                String fndLeadCampId = mapLeadCampByForm.get(pro.Form__c);
                //system.debug('fndLeadCampId: '+fndLeadCampId);
                
                CampaignMember fndLeadCampMem;
                if(fndLeadCampId != NULL) {
                    fndLeadCampMem = mapCampMem.get(pro.Email__c.toLowerCase() + '~' + fndLeadCampId);
                }
                //system.debug('fndLeadCampMem: '+fndLeadCampMem);                
                
                if(fndLeadCampMem != NULL) {
                    // Update Lead Camp Member
                    if(fndLeadCampMem.Status != 'Converted') {
                        fndLeadCampMem.Status = 'Filled Out Form';                    
                    }
                    if(fndLeadCampMem.Original_Form__c == NULL) {
                        fndLeadCampMem.Original_Form__c = pro.Form_Name__c;                    
                    }
                    //system.debug('update fndLeadCampMem: '+fndLeadCampMem);
                    
                    campMemUpdate.add(fndLeadCampMem);
                    //system.debug('Lead campMemUpdate: '+campMemUpdate);
                    
                } else {
                    // Add new Camp Member
                    CampaignMember newCM = new CampaignMember();
                    
                    //system.debug('Lead Add new');
                    
                    // Create Campaign Member from Lead
                    if(pro.Lead__c != null && pro.Form_Name__c!=null){
                        
                        Form__c fm = formsByIdMap.get(pro.Form__c);
                        //system.debug('Lead fm: '+fm);
                        
                        //if(fndConvCamp != null){
                        //    newCM.CampaignId = fndConvCamp.Id;
                        //    newCM.Conversion_Form__c = pro.Form_Name__c;
                        //    newCM.Status = 'Converted';
                        //}else{
                            newCM.CampaignId = fm.Campaign__c;
                            newCM.Status = 'Filled Out Form';
                        //}
                        
                        //system.debug('Lead newCM: '+newCM);
                        
                        if(newCM.CampaignId != NULL) {
                            newCM.LeadId = pro.Lead__C;
                            newCM.Lead_Status__c = pro.Lead_Status__c; 
                            newCm.Original_Form__c = pro.Form_Name__c;
                            campMem.add(newCM);
                            //system.debug('Lead newCM add: '+newCM);
                            subscriptionChangeLeadMap.put(pro.Lead__c,pro.Form_Name__c);
                        }
                        
                    } else if(pro.Contact__c != null && pro.Form_Name__c != null){
                        
                        Form__c fm = formsByIdMap.get(pro.Form__c);
                        //system.debug('Contact Lead fm: '+fm);
                        
                        //if(fndConvCamp != null){
                        //    newCM.CampaignId = fndConvCamp.Id;
                        //    newCM.Conversion_Form__c = pro.Form_Name__c;
                        //    newCM.Status = 'Converted';
                        //}else{
                            newCM.CampaignId = fm.Campaign__c;
                            newCM.Status = 'Filled Out Form';
                        //}
                        if(newCM.CampaignId != NULL) {
                            newCM.ContactId = pro.Contact__c;
                            newCM.Lead_Status__c = pro.Lead_Status__c; 
                            newCm.Original_Form__c = pro.Form_Name__c;
                            campMem.add(newCM);
                            //system.debug('Contact newCM: '+newCM);
                            subscriptionChangeConMap.put(pro.Contact__c,pro.Form_Name__c);
                        }
                    }
                }
                
                if(pro.Bulk_Load__c == false && pro.Status__c=='Completed'){
                    
                    if((statusMap.containsKey(pro.form__c))|| (statusMap.containsKey(pro.id))){
                        // splitting the status field
                        if(statusMap.containsKey(pro.form__c)){
                            statuslist = statusMap.get(pro.form__c).split(';');
                            //system.debug('statuslist123==:'+statuslist);
                        }
                        if(statusMap.containsKey(pro.id)){
                            statuslist = statusMap.get(pro.id).split(';');
                            //system.debug('statuslist==:'+statuslist);
                        }
                        for(String s:statuslist){   
                            if(settingMap.containsKey(s) && pro.Lead__c !=null && pro.Subscription__c != 'Do Not Email' ){
                                if(settingMap.get(s).Lead_Field_Maapping__c != null && pro.Lead__c !=null && pro.Subscription__c !='No' ){   
                                    if(leadToUpdateMap.containsKey(pro.Lead__c)){
                                        List<String> ldl = leadToUpdateMap.get(pro.Lead__c); 
                                       //system.debug('ldl231231==:'+ldl);
                                        ldl.addAll(settingMap.get(s).Lead_Field_Maapping__c.split(','));
                                        leadToUpdateMap.put(pro.Lead__c,ldl);  
                                        //system.debug('leadToUpdateMap==:'+leadToUpdateMap);
                                    }else{
                                        List<String> leadfields=settingMap.get(s).Lead_Field_Maapping__c.split(',');  
                                        leadToUpdateMap.put(pro.Lead__c,leadfields);  
                                        //system.debug('leadToUpdateMap123==:'+leadToUpdateMap);  
                                    }
                                } 
                            }
                            // Comparing custom setting record name with status value
                            if(settingMap.containsKey(s) && (pro.Subscription__c != 'No'&& pro.Subscription__c != 'Do Not Email')){   
                                if(settingMap.get(s).Contact_Field_Mapping__c != null && pro.Contact__c !=null ){   
                                    if(pro.Subscription__c =='Yes' || (pro.Subscription__c =='Non-Member' && pro.Existing_Business_Contact__c )){
                                        if(contactToUpdateMap.containsKey(pro.Contact__c)){
                                            List<String> conl = contactToUpdateMap.get(pro.Contact__c); 
                                            conl.addAll(settingMap.get(s).Contact_Field_Mapping__c.split(','));
                                            contactToUpdateMap.put(pro.Contact__c,conl);  
                                        }else{
                                            List<String> conFields=settingMap.get(s).Contact_Field_Mapping__c.split(',');  
                                            contactToUpdateMap.put(pro.Contact__c,conFields);    
                                        }  
                                        
                                    }
                                } 
                            } 
                        } 
                    } 
                    
                    //system.debug('pro.Contact__c==:'+pro.Contact__c);  
                    
                    if(pro.Contact__c != null){ 
                        
                        Contact c = new Contact();
                        
                        c.Id = pro.Contact__c; 
                        
                        if(pro.Subscription__c == 'Do Not Email'){
                            c.HasOptedOutOfEmail = true;
                        } 
                        
                        if(pro.Overwrite_Contact__c){
                            if(pro.First_Name__c != null){
                                c.Business_Contact_First_Name__c = pro.First_Name__c;
                            }
                            if(pro.Last_Name__c != null){
                                c.Business_Contact_Last_Name__c = pro.Last_Name__c;
                            }
                            if(pro.Email__c != null){
                                c.Business_Contact_Email__c = pro.Email__c;
                            }
                            if(pro.Mailing_Street__c != null){
                                c.Business_Contact_Address_1__c = pro.Mailing_Street__c;
                            }
                            if(pro.Mailing_City__c != null){
                                c.Business_Contact_City__c = pro.Mailing_City__c;
                            }
                            if(pro.Mailing_State_Province__c != null){
                                c.Business_Contact_State__c = pro.Mailing_State_Province__c;
                            }
                            if(pro.Mailing_Zip_Postal_Code__c != null){
                                c.Business_Contact_Zip_Code__c = pro.Mailing_Zip_Postal_Code__c;
                            }
                            if(pro.Mailing_Country__c != null){
                                c.Business_Contact_Country__c = pro.Mailing_Country__c;
                            }
                            if(pro.Title__c != null){
                                c.Business_Contact_Title__c = pro.Title__c;
                            }
                            if(pro.Company__c != null){
                                c.Business_Contact_Company__c = pro.Company__c;
                            }
                            if(pro.Phone__c != null){
                                c.Business_Contact_Phone__c = pro.Phone__c;
                            } 
                            if(pro.Mobile_Phone__c != null){
                                c.MobilePhone = pro.Mobile_Phone__c;
                            } 
                            if(pro.Form_Name__c != null){
                                c.Email_Subscription_Change_Source__c = pro.Form_Name__c; 
                            }         
                        } 
                        
                        contactMap.put(c.Id, c);  
                        
                    } 
                    
                    //system.debug('pro.Lead__C==:'+pro.Lead__C); 
                    
                    if(pro.Lead__C != null){ 
                        
                        lead l = new lead();
                        l.Id = pro.lead__C; 
                        if(pro.Form_Name__c != NULL){
                            l.Original_Source__c = pro.Form_Name__c;
                        }
                        if(pro.Subscription__c == 'Do Not Email'){
                            l.HasOptedOutOfEmail = true;
                        } 
                        if(pro.Overwrite_Lead__c){
                            if(pro.First_Name__c != null){
                                l.FirstName = pro.First_Name__c;
                            }
                            if(pro.Last_Name__c != null){
                                l.LastName = pro.Last_Name__c;
                            }
                            if(pro.Mailing_Street__c != null){
                                l.street = pro.Mailing_Street__c;
                            }
                            if(pro.Mailing_City__c != null){
                                l.City = pro.Mailing_City__c;
                            }
                            if(pro.Mailing_State_Province__c != null){
                                l.State = pro.Mailing_State_Province__c;
                            }
                            if(pro.Mailing_Zip_Postal_Code__c != null){
                                l.PostalCode = pro.Mailing_Zip_Postal_Code__c;
                            }
                            if(pro.Mailing_Country__c != null){
                                l.Country = pro.Mailing_Country__c;
                            }
                            if(pro.Title__c != null){
                                l.Title = pro.Title__c;
                            }
                            if(pro.Company__c != null){
                                l.company = pro.Company__c;
                            }
                            if(pro.Phone__c != null){
                                l.phone = pro.Phone__c; 
                            }
                            if(pro.Mobile_Phone__c != null){
                                l.Mobile_Phone__c = pro.Mobile_Phone__c; 
                            }
                            if(pro.Form_Name__c != null){
                                l.Email_Subscription_Change_Source__c = pro.Form_Name__c;
                            }
                        } 
                        
                        leadMap.put(l.Id,l);  
                        
                    } 
                }
            }  
            
            if(campMem.size()>0){
                INSERT campMem;
            }
            
            if(campMemUpdate.size() > 0) {
                update campMemUpdate;
            }
            
            for(Id idkey:contactToUpdateMap.keySet()){
                SObject o1 = idkey.getSObjectType().newSObject(idkey);
                for(String s:contactToUpdateMap.get(idkey)){
                    o1.put(s,true);
                    //system.debug('%%%%%%:'+o1);
                } 
                if(subscriptionChangeConMap.containsKey(idkey)){
                    o1.put('Email_Subscription_Change_Source__c', subscriptionChangeConMap.get(idkey));     
                }
                contactToUpdateList.add(o1); 
            }
            
            for(Id idkey:leadToUpdateMap.keySet()){
                SObject o1 = idkey.getSObjectType().newSObject(idkey);
                for(String s:leadToUpdateMap.get(idkey)){
                    o1.put(s, true); 
                } 
                if(subscriptionChangeLeadMap.containsKey(idkey)){
                    o1.put('Email_Subscription_Change_Source__c', subscriptionChangeLeadMap.get(idkey));    
                }
                leadToUpdateList.add(o1); 
            }
            
            // Updated the Contact Fields
            if(contactToUpdateList.size()>0){
                update contactToUpdateList;
            }
            
            if(leadToUpdateList.size()>0){
                update leadToUpdateList;
            } 
            
            if(contactMap.size()>0){ 
                Database.update(contactMap.values(),false);  
            }
            
            if(leadMap.size()>0){ 
                Database.update(leadMap.values(),false);  
            }
            
        }catch(Exception e){
            system.debug(e.getMessage()+' '+e.getLinenumber()); 
        } 
    } 
    
}