public class GARP_BC_Webcasts {
    
  public class returnWebcastInformation {
        public List < Webcast__c > webcastInformation { get; set; }
        public List < Presenter__c > presentersAtWebcast { get; set; }
        public List < String  > allWebcastParticipantsMediaURLs { get; set; }
        public Boolean isAutenticated { get; set; }
    } 

    public class wrapperCreateWebcastRegistration {
        public Id contactId { get; set;}
        public String webcastRegistrationId { get; set;}
        public Boolean isExistingContact { get; set;}        
    }
    
    public static returnWebcastInformation getWebcastInformation(String webcastId){
        returnWebcastInformation rd = new returnWebcastInformation();
        
        rd.isAutenticated = GARP_BC_Authentication.isAuthenticated();
        
        List < Webcast__c > allWebcastInformation = [SELECT Name, Id, Description__c, Short_Description__c, Duration__c, Start_Time__c, End_Time__c, Start_Date__c, End_Date__c, Image__c, Status__c, Title__c, Is_Sponsored__c, Sponsor_Name__c, Content__r.Form__r.Form_Name__c, On_Demand_URL__c, Time_Zone__r.Name FROM Webcast__c where Id = :webcastId];
        List < Presenter__c > allWebcastParticipants = [SELECT Id, Name, Role__c, Contact__r.GARP_Profile__r.Bio__c, Contact__r.GARP_Profile__r.Id, Contact__r.Name, Contact__r.GARP_Profile__r.Qualifications__c, Contact__r.GARP_Profile__r.Default_Image__c, Webcast__r.Name, Webcast__r.Title__c, Webcast__r.Status__c, Webcast__r.Start_Date__c, Webcast__r.End_Date__c, Webcast__r.Description__c FROM Presenter__c where Webcast__r.Id = :webcastId];
        List<String> GARPProfileIDsOfWebcastParticipants = new List<String>();
        List<String> allWebcastParticipantsMediaURLs = new List<String>();
        
        for(Presenter__c webcastParticipant: allWebcastParticipants){
            GARPProfileIDsOfWebcastParticipants.add(webcastParticipant.Contact__r.GARP_Profile__r.Id);
        }
        
        List < cdrive__Cloud_Files__c > allWebcastParticipantsMedia = [SELECT Id, cdrive__contextID__c, cdrive__File_Name__c from cdrive__Cloud_Files__c where cdrive__contextID__c = :GARPProfileIDsOfWebcastParticipants]; 
        for(cdrive__Cloud_Files__c webcastParticipantMedia: allWebcastParticipantsMedia){
            allWebcastParticipantsMediaURLs.add('https://s3-us-west-2.amazonaws.com/garpsalesforcepublic/GARP_Profile__c/' + webcastParticipantMedia.cdrive__contextID__c + '/' + webcastParticipantMedia.Id + '_' + webcastParticipantMedia.cdrive__File_Name__c);
        }
        rd.webcastInformation = allWebcastInformation;
        rd.presentersAtWebcast = allWebcastParticipants;
        rd.allWebcastParticipantsMediaURLs = allWebcastParticipantsMediaURLs;
        return rd;
    }
    
    // AG 5/3/2024 - Use new GARP_ classes
    // Only for use by logged in member portal users
    public static wrapperCreateWebcastRegistration createWebcastRegistration(TempAccount objData,String contactId) {
        
        GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','objData',objData);
        GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','contactId',contactId);
        
        wrapperCreateWebcastRegistration returnWebcastWrapper = new wrapperCreateWebcastRegistration();
        
        // Prep reg info
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getWebcastRegistrationSettings(objData.webcastId);
        GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','Set programRegistrationInfo',programRegistrationInfo);
        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','Return regInfo', regInfo);
        
        regInfo = GARP_BC_Events.updateWebcastRegInfo(programRegistrationInfo, regInfo);
        
        GARP_BC_Registration.checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','checkAuth', checkAuth);
        
        if(checkAuth != NULL && checkAuth.user.contactId != NULL) {
            
            Contact contact = GARP_BC_Registration.getContactForFeesAndSetReg(checkAuth.contactId);
            GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','contact', contact);
            
            if(contact != NULL) {
                
                // Get Fees
                GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_BC_Registration.getRegistrationFeesInfoFromAuthedContact(contact, programRegistrationInfo, False, 'Credit Card');
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','getRegistrationFeesInfo', getRegistrationFeesInfo);
                
                GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','regFees', regFees);

				// Create Lead                
                GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
                verifyExistingCustomerInfo.firstName = contact.FirstName;
                verifyExistingCustomerInfo.lastName = contact.LastName;
                verifyExistingCustomerInfo.email = contact.Email;
                verifyExistingCustomerInfo.leadId = NULL;
                verifyExistingCustomerInfo.formKey = regInfo.programRegistrationInfo.formName;
                verifyExistingCustomerInfo.cta = NULL;
                verifyExistingCustomerInfo.allowMemberPublicRegistration = FALSE;
                
                GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_MS_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','verifyExistingCustomerReturnInfo', verifyExistingCustomerReturnInfo);
                
                // Set Registration
                GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_BC_Registration.setRegistrationInfoFromAuthedContact(contact, programRegistrationInfo, verifyExistingCustomerReturnInfo.leadId);
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','setRegistrationInfo', setRegistrationInfo);
                
                setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
                GARP_BC_Registration.setRegistrationReturnInfo setRegRet = GARP_BC_Registration.setRegistration(setRegistrationInfo);
                
                // Close Order
                GARP_BC_Registration.createOrderInfo createOrderInfo = GARP_BC_Registration.createOrderFromAuthedContact(setRegistrationInfo, regFees, setRegRet);    
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','createOrderInfo', createOrderInfo);
                
                GARP_BC_Orders.setOrderReturnInfo payRegInfo = GARP_BC_Registration.payOrder(createOrderInfo);
                GARP_Common.debugLog('GARP_BC_Webcast','createWebcastRegistration','payRegInfo', payRegInfo);
            }
        }
        

        /*
        Registration.wrapperCreateOrder newAffiliateOrder = new Registration.wrapperCreateOrder();
        String userContactId = null;
        
        System.Debug('objData:'+objData);
        System.Debug('contactId:'+contactId);
        
        // Get Existing Contact INfo
        Contact existingContact;
        Id memberRecId = RecordTypeHelper.GetRecordTypeId('Contact', 'Member');
        List<Contact> lstContacts = [select Id, Title, Company__c, MailingCountry from Contact where Email = :objData.Email AND RecordTypeId = :memberRecId];
        System.Debug('lstContacts:'+lstContacts);

        if(!lstContacts.IsEmpty()) {
            existingContact = lstContacts[0];
            returnWebcastWrapper.isExistingContact = True;
        } else {
            returnWebcastWrapper.isExistingContact = False;
        }
        System.Debug('existingContact:'+existingContact);
        
        // Check it public reg email is already a contact
        if(existingContact != NULL && contactId == NULL) {
            contactId = existingContact.Id;
            System.Debug('Update contactId:'+contactId);
        }
        
        List<Webcast__c> lstWebcasts = [select ID, Name, EventId__c, X0n24_API_Key__c from Webcast__c where ID = :objData.webcastId];
        System.Debug('lstWebcasts:'+lstWebcasts);
        
        // Get Webcast Registration - see is already exists
        List<Webcast_Registration__c> lstWebCastRegs;
        if(contactId != NULL) {
            lstWebCastRegs = [select Id, Lead__r.Id, Contact__r.Id from Webcast_Registration__c where Webcast__c = :objData.webcastId and Contact__c = :contactId];
            userContactId = contactId;
            returnWebcastWrapper.contactId = contactId;
        } else if(objData.Email != NULL) {
            lstWebCastRegs = [select Id, Lead__r.Id, Contact__r.Id from Webcast_Registration__c where Webcast__c = :objData.webcastId and (Email__c = :objData.Email OR Contact__r.Email = :objData.Email)];
        } else {
            // Error missing user
            return returnWebcastWrapper;
        }
        System.Debug('lstWebCastRegs:'+lstWebCastRegs);
        
        String newWebcastRegId;
        if(!lstWebcasts.IsEmpty()) {
        
            Webcast__c webCast = lstWebcasts[0];
             
            // Already Registered?        
            if(lstWebCastRegs.IsEmpty()) {

                System.Debug('webCast :'+webCast );
                
                if(contactId != null){
                    // PORTAL
                    userContactId = contactId;
                    System.Debug('insertWebcastRegistration :'+objData );
                    newWebcastRegId = insertWebcastRegistration(objData, contactId);
                    
                    // Update Title and Company
                    existingContact.Title = objData.jobtitle;
                    existingContact.Company__c = objData.company;
                    existingContact.MailingCountry = objData.MailingCountry;
                    
                    System.Debug('update existingContact:'+existingContact);
                    update existingContact;
                    
                    Utilities.migrateLeadFormDataToContact(null, existingContact.Id, objData.formName, null);
                    
                } else if(contactId == null){
                    // PUBLIC
                    if(objData.Membership_Type == 'Affiliate') {
                        newAffiliateOrder = Registration.CreateOrder(objData);
                        userContactId = newAffiliateOrder.contactId;
                        System.Debug('***Affiliate insertWebcastRegistration :'+objData );
                        newWebcastRegId = insertWebcastRegistration(objData, newAffiliateOrder.contactId);
                        
                        Utilities.migrateLeadFormDataToContact(null, newAffiliateOrder.contactId, objData.formName, null);
                        
                    } else {
                        System.Debug('***createNonMemberWebcastRegistration :'+objData );
                        Response.Detail ret = (Response.Detail)createNonMemberWebcastRegistration(objData);
                        if(ret != NULL && ret.data != NULL) {
                            Webcast_Registration__c wcr = (Webcast_Registration__c)ret.data;
                            userContactId = wcr.Contact__c;
                            newWebcastRegId = wcr.Id;
                        }
                    }
                }
                System.Debug('newWebcastRegId:'+newWebcastRegId);
                
                returnWebcastWrapper.webcastRegistrationId = newWebcastRegId;
                returnWebcastWrapper.contactId = userContactId;
                
                lstWebCastRegs = [SELECT Id,Lead__r.Id FROM Webcast_Registration__c where id = :newWebcastRegId];
                System.Debug('Insert Done:' + lstWebcasts ); 
           } else {
                returnWebcastWrapper.webcastRegistrationId = lstWebCastRegs[0].Id;
                returnWebcastWrapper.contactId = lstWebCastRegs[0].Contact__r.Id;
                
                if(existingContact != NULL) {
                    // Update Title and Company
                    existingContact.Title = objData.jobtitle;
                    existingContact.Company__c = objData.company;
                    existingContact.MailingCountry = objData.MailingCountry;
                    
                    System.Debug('update existingContact:'+existingContact);
                    update existingContact;
                }
                
           }
           //List < Webcast_Registration__c  > webcastRegistration = [SELECT Id,Lead__r.Id FROM Webcast_Registration__c where (Contact__c =: userContactId and Webcast__c =: objData.webcastId)];        
           
           if(!lstWebcasts.IsEmpty() && !lstWebCastRegs.IsEmpty() && newWebcastRegId != NULL) {
                // API_Transaction__c trans = on24API.createAPITransactionRecord(webcastRegistration[0].Id, userContactId, webCast.EventId__c, webCast.X0n24_API_Key__c);
                API_Transaction__c trans = on24API.createAPITransactionRecord('webcast',lstWebCastRegs[0].Id, userContactId, webCast.EventId__c, webCast.X0n24_API_Key__c);
                
                if(trans != null)
                    on24API.SendRequest(null, trans.Id);
                
                returnWebcastWrapper.webcastRegistrationId = lstWebCastRegs[0].Id;
                returnWebcastWrapper.contactId = userContactId;
            }
        }
        */
        
        return returnWebcastWrapper;
    }
    
    public static String insertWebcastRegistration(TempAccount objData,Id contactId){
        Webcast_Registration__c  newWebcastRegistration = new Webcast_Registration__c();
        
        String objName = objData.FirstName + ' ' + objData.LastName + '/' + objData.webcastId;
        
        newWebcastRegistration.Name = objName;
        newWebcastRegistration.Contact__c = contactId;
        newWebcastRegistration.Status__c = 'Registered';
        newWebcastRegistration.Webcast__c = objData.webcastId;
        
        newWebcastRegistration.Webcast_Registration_Date__c = Date.Today();
        newWebcastRegistration.Email__c = objData.Email;
               
        //newWebcastRegistration.Agree_To_Sponsor_Contact__c = objData.sponsorInformationExchangeAttestation ? DateTime.Now() : NULL;
        
        if(objData.sponsorInformationExchangeAttestation != null && objData.sponsorInformationExchangeAttestation){
            newWebcastRegistration.Agree_To_Sponsor_Contact__c = System.now();
        }
        
        if(objData.garpInformationExchangeAttestation != null && objData.garpInformationExchangeAttestation){
            newWebcastRegistration.Agree_To_GARP_Content__c = System.now();
        }
        
        if(objData.privacyPolicyAttestation != null && objData.privacyPolicyAttestation){
            newWebcastRegistration.Privacy_Policy_Attestation__c = System.now();
        }        
        
        System.debug('newWebcastRegistratione:' + newWebcastRegistration);
        
        
        if(objData.Company != NULL || objData.jobtitle != NULL) {
            GARP_MS_MemberProfile.memberProfileUpdate profileUpdate = new GARP_MS_MemberProfile.memberProfileUpdate();
            profileUpdate.profileParts.CompanyTitle = True;
            profileUpdate.ContactId = contactId;
            profileUpdate.Company = objData.Company;
            profileUpdate.Title = objData.jobtitle;
            
            System.debug('profileUpdate:' + profileUpdate);
            
            GARP_MS_MemberProfile.setMemberProfile(profileUpdate);
        }
        
        insert newWebcastRegistration;
        
        return newWebcastRegistration.Id;
    }

    public static Response.Envelope createNonMemberWebcastRegistration(TempAccount wrapper){
        
        Response.Detail res = new Response.Detail();
        
        try{
            
            Id eventId          = wrapper.webcastId;
            Id entityId         = wrapper.id;        
            Id accountId        = null;
            String companyName  = wrapper.Company;
            
            Webcast__c webcast = null;
            
            List<Webcast__c> webcasts = [select ID, Name, Status__c, EventId__c, X0n24_API_Key__c from Webcast__c where ID = :eventId];
            
            //Ensure the Webcast exists and is Active
            if(webcasts.isEmpty()){          
                res.errors = new List<String>{'Event with the ID ' + eventId + ' was not found.'};
                res.status = 404;
                return res;
            } else if(webcasts[0].Status__c != 'Active'){
                res.errors = new List<String>{'Webcast is not active.'};
                res.status = 400;
                return res;            
            }
            
            webcast = webcasts[0];
            
            List<Lead> leads       = [SELECT Id FROM Lead WHERE Id = :entityId LIMIT 1];
            List<Contact> contacts = [SELECT Id, Email FROM Contact WHERE Id = :entityId LIMIT 1];
            
            System.Debug('!!leads:'+leads);
            System.Debug('!!contacts:'+contacts);
            
            List<Account> relatedAccounts = [SELECT Id, Name FROM Account WHERE Customer_Company_List__c = TRUE AND Name = :companyName LIMIT 1]; 
            if(relatedAccounts.isEmpty()){
                accountId = Default_Record_References__c.getAll().get('UNMATCHED-BUSINESS-ACCOUNT').Record_Reference_ID__c;
            }else{
                accountId = relatedAccounts[0].Id;
            }
            
            Contact contact = null;
            
            if(!leads.isEmpty()) {
                
                Lead lead = leads[0];
                lead.Do_not_fire__c = True;
                update Lead;
                
                Database.LeadConvert convertLead = new Database.LeadConvert();            
                convertLead.setLeadId(entityId);
                
                LeadStatus ls = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted = TRUE LIMIT 1];
                convertLead.setConvertedStatus(ls.MasterLabel);
                
                convertLead.setAccountId(accountId);
                convertLead.setDoNotCreateOpportunity(true);
                
                Database.LeadConvertResult lcr = Database.convertLead(convertLead);               
                if (lcr.isSuccess()){
                    Lead convertedLead = [SELECT ConvertedAccountId, ConvertedContactId FROM Lead WHERE Id = :entityId LIMIT 1];
                    contact = [SELECT Id, Name, Email FROM Contact WHERE Id = :convertedLead.ConvertedContactId LIMIT 1];
                }else{
                    
                    res.errors = new List<String>{'Lead conversion failed.'};
                    res.status = 400;
                    return res; 
                    
                }
                               
                contact.RecordTypeId        = [SELECT Id, Name, sObjectType FROM RecordType WHERE sObjectType = 'Contact' AND Name = 'Business Relationship' LIMIT 1].Id;
                
                // Do not create user
                contact.do_not_fire__c      = True;
                
                contact.MailingStreet       = wrapper.MailingStreet;
                contact.MailingCity         = wrapper.MailingCity;
                contact.MailingState        = wrapper.MailingState;
                contact.MailingPostalCode   = wrapper.MailingPostalCode;
                contact.MailingCountry      = wrapper.MailingCountry;
                
                contact.Email               = wrapper.Email;
                contact.FirstName           = wrapper.FirstName;
                contact.LastName            = wrapper.LastName;
                contact.Title               = wrapper.jobtitle;
                contact.Company__c          = wrapper.Company;
                
                contact.Corporate_Title__c          = wrapper.Title;
                contact.Job_Function__c             = wrapper.JobFunction;
                contact.Risk_Specialty__c           = wrapper.RiskSpecialty;
                contact.Area_of_Concentration__c    = wrapper.Industry;
                
                // If Event has Participant Login enable add Role to Contact which will trigger User creation
                //if(event.Event_Participant_Login__c) {
                //    contact.Event_Participant__c = TRUE;
                //}
                
                // Assign MC Unique ID
                contact.MC_Unique_Id__c = lead.id;                
                
                System.Debug('!!lead convert update contact:'+contact);
                
                UPDATE contact;
                
                // Move Form Data
                Utilities.migrateLeadFormDataToContact(lead.id, contact.Id, wrapper.formName, null);
                
            }else if(!contacts.isEmpty()){
                
                contact = contacts[0];
                
                contact.MailingStreet       = wrapper.MailingStreet;
                contact.MailingCity         = wrapper.MailingCity;
                contact.MailingState        = wrapper.MailingState;
                contact.MailingPostalCode   = wrapper.MailingPostalCode;
                contact.MailingCountry      = wrapper.MailingCountry;
                
                contact.Email               = wrapper.Email;
                contact.FirstName           = wrapper.FirstName;
                contact.LastName            = wrapper.LastName;
                contact.Title               = wrapper.jobtitle;
                contact.Company__c          = wrapper.Company;
                
                contact.Corporate_Title__c          = wrapper.Title;
                contact.Job_Function__c             = wrapper.JobFunction;
                contact.Risk_Specialty__c           = wrapper.RiskSpecialty;
                contact.Area_of_Concentration__c    = wrapper.Industry;
                
                // Do not create user
                contact.do_not_fire__c      = True;
                
                System.Debug('!!update contact:'+contact);
                UPDATE contact;
                
                Utilities.migrateLeadFormDataToContact(null, contact.Id, wrapper.formName, null);
                
            }else{
                
                res.errors = new List<String>{'No Lead or Contact exists for the individual attempting to register.'};
                res.status = 404;
                return res;  
                
            }
            
            Webcast_Registration__c webcastRegistration = null;
            
            List<Webcast_Registration__c> existingWebcastRegistrations = [SELECT Id, Contact__c, Webcast__c FROM Webcast_Registration__c WHERE Contact__c = :contact.Id AND Webcast__c = :webcast.Id];
            if(existingWebcastRegistrations.isEmpty()){    
                
                webcastRegistration = new Webcast_Registration__c();
                
                webcastRegistration.Contact__c = contact.Id;
                webcastRegistration.Webcast__c = webcast.Id;     
                webcastRegistration.Webcast_Registration_Date__c = Date.today();     
                webcastRegistration.Email__c = wrapper.Email;
                webcastRegistration.Status__c = 'Registered';
                
                if(wrapper.sponsorInformationExchangeAttestation != null && wrapper.sponsorInformationExchangeAttestation){
                    webcastRegistration.Agree_To_Sponsor_Contact__c = System.now();
                }

                if(wrapper.garpInformationExchangeAttestation != null && wrapper.garpInformationExchangeAttestation){
                    webcastRegistration.Agree_To_GARP_Content__c = System.now();
                }
                
                if(wrapper.privacyPolicyAttestation != null && wrapper.privacyPolicyAttestation){
                    webcastRegistration.Privacy_Policy_Attestation__c = System.now();
                }
                
                system.debug('webcastRegistration:' + webcastRegistration);
                
                INSERT webcastRegistration;     
                
            }else{
                
                //webcastRegistration = existingWebcastRegistrations[0];
                //eventRegistration.Contact__c = contact.Id;
                //eventRegistration.Status__c = 'RSVP Accept';
                //if(event.Max_Capacity_Met__c){
                //    eventRegistration.Status__c = 'Waitlisted';
                //}
                
                //UPDATE eventRegistration;
                
            }
            
            res.data = webcastRegistration;
            res.status = 200;
            return res;  
            
        }catch(Exception e){
            
            res.errors = new List<String>{e.getMessage(), e.getStackTraceString()};
            res.status = 400;
            return res;
                       
        }
        
    }
}