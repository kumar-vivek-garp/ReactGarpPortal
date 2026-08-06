global class Utilities{
    
    public static Boolean disableCaptcha = false;
    public static User objUser = null;
    
    public class applicationException extends Exception {}
    
    public class FormDataResponse {
        public Id leadId { get; set; }
        public Id contactId { get; set; }
        public Id formDataId { get; set; }
    }
    
/*    
    public static Response.Detail upsertLead(String jsonLeadString, String formKey){

        try{

            Lead lead = (Lead)JSON.deserialize(jsonLeadString, Lead.class);

            if(formKey == null || formKey == ''){
                throw new Response.ResponseException(
                    'Form Key is missing.', 400,
                    new List<String>{'Form Key is missing.'}
                ); 
            }

            formKey = formKey.toLowerCase();

            List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId()];

            if(users.isEmpty()){
                throw new Response.ResponseException(
                    'Invalid user ID.', 404,
                    new List<String>{'Invalid user ID.'}
                );
            }

            User user = users[0];
            Boolean isAuthenticated = false;

            // Implies running under Community User context
            if(user.ContactId != null){
                isAuthenticated = true;
            }

            Response.Detail res = new Response.Detail();
            
            String email = lead.Email;
        
            if(lead.Id != null && email != null){

                List<Contact> contacts = [
                    SELECT Id, Email, RecordType.Name 
                    FROM Contact 
                    WHERE Email = :email AND RecordType.Name = 'Member'
                ];
            
                if(!contacts.isEmpty() && !isAuthenticated){
                                
                    throw new Response.ResponseException(
                        'Contact with the email address ' + email + ' already exists.', 205,
                        new List<String>{'Contact with the email address ' + email + ' already exists.'}
                    );

                }
                
                List<Lead> leads = [
                    SELECT Id, Email, IsConverted, ConvertedContactId 
                    FROM Lead 
                    WHERE Id = :lead.Id
                ];
                
                if(!leads.isEmpty() && !leads[0].IsConverted && leads[0].Email != email){

                 
                    List<Lead> convertedLeads = [
                        SELECT Id, Email, IsConverted, ConvertedContactId 
                        FROM Lead 
                        WHERE Email = :email AND IsConverted = TRUE AND Backup_Exam_Registration__c = FALSE
                    ];                  

                    if(!convertedLeads.isEmpty()){
                        throw new Response.ResponseException(
                            'Contact ' + convertedLeads[0].ConvertedContactId + ' with from converted Lead ' + convertedLeads[0].Id + ' already exists.', 205,
                            new List<String>{'Contact ' + convertedLeads[0].ConvertedContactId + ' with from converted Lead ' + convertedLeads[0].Id + ' already exists.'}
                        );
                    }

               
                    leads[0].Email = email;
                    
                    UPDATE leads[0];
                    
                    res.data = leads[0];
                    res.status = 204;
                    res.message = 'Unconverted Lead with Id ' + leads[0].Id + ' already exists.  Updated email address of existing Lead to ' + leads[0].Email + '.';

                }else if(!leads.isEmpty() && !leads[0].IsConverted && leads[0].Email == email){

                    res.data = leads[0];
                    res.status = 100;
                    res.message = 'Unconverted Lead with Id ' + leads[0].Id + ' already exists.';

                }else if(!leads.isEmpty() && leads[0].IsConverted){

                    throw new Response.ResponseException(
                        'Contact ' + leads[0].ConvertedContactId + ' with from converted Lead ' + leads[0].Id + ' already exists.', 205,
                        new List<String>{'Contact ' + leads[0].ConvertedContactId + ' with from converted Lead ' + leads[0].Id + ' already exists.'}
                    );

                }

                return res;    

            }else if(email != null){

                List<Contact> contacts = [
                    SELECT Id, Email, RecordType.Name 
                    FROM Contact 
                    WHERE Email = :email AND RecordType.Name = 'Member'
                ];
            
                if(!contacts.isEmpty() && !isAuthenticated){
                                        
                    throw new Response.ResponseException(
                        'Contact with the email address ' + email + ' already exists.', 205,
                        new List<String>{'Contact with the email address ' + email + ' already exists.'}
                    );

                }

                List<Lead> unconvertedLeads = [
                    SELECT Id, Email 
                    FROM Lead 
                    WHERE Email = :email AND IsConverted = FALSE
                ];

                if(!unconvertedLeads.isEmpty()){
                
                    res.data = unconvertedLeads[0];
                    res.status = 200;
                    res.message = 'Unconverted Lead with the email address ' + email + ' already exists.';

                    return res;

                }

                if(unconvertedLeads.isEmpty()){

                    lead = new Lead(
                        Email=email, 
                        LeadSource=formKey,
                        LastName=lead.LastName, 
                        FirstName=lead.FirstName, 
                        Company=lead.LastName + ', ' + lead.FirstName
                    );
                    
                    INSERT lead;
                                                            
                    Form_Data__c formData = new Form_Data__c(
                        Email__c = lead.Email,
                        First_Name__c = lead.FirstName,
                        Last_Name__c = lead.LastName
                    );

                    Utilities.manageFormSubmission(formData, formKey);
                    
                    res.data = lead;
                    res.status = 201;
                    res.message = 'Lead created for ' + email + '.';

                    return res;                      

                }
                                                                    
            }else if(email == null){

                throw new Response.ResponseException(
                    'No email address was provided.', 400,
                    new List<String>{'No email address was provided.'}
                );

            }

            return res;

        }catch(Response.ResponseException e){

            return new Response.Detail(e.getMessage(), e.status, e.errors);

        }catch(Exception e){

            return new Response.Detail(null, 400, new List<Object>{
                e.getMessage(),
                e.getLineNumber(),
                e.getStackTraceString()
            });

        } 

    }
*/
    
    public static void migrateLeadFormDataToContact(String leadId, String contactId, String formName, Set<String> subscriptions) { 
        
        System.debug('migrateLeadFormDataToContact:' + leadId + ':' + contactId + ':' + formName + ':' + subscriptions);
        
        List<Form_Data__c> formData = new List<Form_Data__c>();
        
        if(leadId != null && contactId != null){
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c
                FROM Form_Data__c
                WHERE Lead__c = :leadId OR Contact__c = :contactId
                ORDER BY CreatedDate DESC
            ];
        }else if(leadId != null){
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c
                FROM Form_Data__c
                WHERE Lead__c = :leadId
                ORDER BY CreatedDate DESC
            ];
        }else if(contactId != null){
            formData = [
                SELECT Id, Lead__c, Contact__c, Status__c, Form__r.Form_Name__c
                FROM Form_Data__c
                WHERE Contact__c = :contactId
                ORDER BY CreatedDate DESC
            ];
        }
        System.debug('migrateLeadFormDataToContact:formData:' + formData);
        
        if(!formData.isEmpty()){
            
            Boolean isMarkedCompleted = false;
            
            // Create a unique set of Form IDs
            Set<Id> formIds = new Set<Id>();
            for(Form_Data__c fd: formData){
                formIds.add(fd.Form__c);
            }
            
            // Create a hashmap of Campaign by Form ID
            Map<Id, Campaign> campaignByFormIdMap = new Map<Id, Campaign>();
            List<Campaign> campaigns = [
                SELECT Id, IsActive, Conversion_Form__c, (SELECT Id, Status, Conversion_Form__c, ContactId, LeadId FROM CampaignMembers WHERE LeadId = :leadId OR ContactId = :contactId LIMIT 1)
                FROM Campaign
                WHERE IsActive = TRUE AND Conversion_Form__c IN :formIds 
            ];
            for(Campaign campaign: campaigns){
                campaignByFormIdMap.put(campaign.Conversion_Form__c, campaign);
            }
            
            List<CampaignMember> campaignMembersToUpdate = new List<CampaignMember>();
            
            // Take the most recently submitted Form Data record related to the Form and mark it 'Completed'.            
            for(Form_Data__c fd: formData){
                
                System.debug('migrateLeadFormDataToContact:Loop formData:' + fd);
                
                // Set the status on the Form Data in context.
                if(!isMarkedCompleted && fd.Form__r.Form_Name__c == formName){
                    
                    isMarkedCompleted = true;
                    
                    fd.Status__c = 'Completed';
                    
                    // Set Campaign Member Status to 'Converted'. 
                    if(campaignByFormIdMap.containsKey(fd.Form__c) && !campaignByFormIdMap.get(fd.Form__c).CampaignMembers.isEmpty()){
                        CampaignMember cm = campaignByFormIdMap.get(fd.Form__c).CampaignMembers[0];
                        cm.Status = 'Converted';
                        if(cm.Conversion_Form__c == null){
                            cm.Conversion_Form__c = fd.Form__r.Form_Name__c;
                        }
                        campaignMembersToUpdate.add(cm);
                    }
                    
                    if(subscriptions != null && !subscriptions.isEmpty()){
                        String semiColonDelimitedString = String.join(new List<String>(subscriptions), '; ');
                        fd.Subscriptions__c = semiColonDelimitedString;
                    }
                    
                }
                
                // Migrate all Form Data associated with the Form from the Lead to Contact.    
                if(contactId != null){
                    fd.Lead__c = null;
                    fd.Contact__c = contactId;  
                }
                
            }
            System.debug('migrateLeadFormDataToContact:UPDATE formData:' + formData);
            UPDATE formData;
            
            if(!campaignMembersToUpdate.isEmpty()){
                UPDATE campaignMembersToUpdate;
            }
            
        }
        
        // Move Object_History__c
        if(leadId != null && contactId != null){
            List<Object_History__c> lstObjHist = [select Id, Lead__c, Contact__c from Object_History__c where Lead__c = :leadId];
            for(Object_History__c oh :lstObjHist) {
                oh.Contact__c = contactId;
            }
        }        
    }    
    
    public static FormDataResponse manageFormSubmission(Form_Data__c formData, String formName) {
        
        System.debug('manageFormSubmission:formName:' + formName);
        
        FormDataResponse formDataResponse = new FormDataResponse();
        
        List< Form__c > forms = [
            SELECT id, Name, Form_Name__c 
            FROM Form__c 
            WHERE Form_Name__c = :formName
        ];
        
        // Return an empty FormDataResponse if no Form was found for the provided Form Name (form key)
        if(forms.isEmpty()) {   
            return formDataResponse;         
        }
        
        FINAL String email = formData.Email__c;
        FINAL String lastName = formData.Last_Name__c;
        FINAL String firstName = formData.First_Name__c;
        FINAL String fullName = formData.First_Name__c + ' ' + formData.Last_Name__c;
        
        List < Lead > leads = [
            SELECT id, Name, Email 
            FROM Lead 
            WHERE Email = :email AND IsConverted = FALSE 
            LIMIT 1
        ];
        
        List < Contact > contacts = [
            SELECT Id, Name, AccountId 
            FROM Contact 
            WHERE Email = :email
            LIMIT 1
        ];
        
        Id formId = forms[0].Id; 
        
        formData.Form__c = formId;
        formData.Company__c = fullName;
        
        if(formData.Status__c == null){
            formData.Status__c = 'Abandoned';
        }
        
        Lead lead = null;
        Contact contact = null;
        
        if (!contacts.isEmpty()) {
            
            contact = contacts[0];
            
            Id contactId = contacts[0].Id;
            
            // Associate Form Data with the Contact if it exists.
            formData.Contact__c = contactId;
            
            // Set Contact ID on response object.
            formDataResponse.contactId = contactId;
            
        } else if (!leads.isEmpty()) {
            
            lead = leads[0];
            
            lead.FirstName = firstName;
            lead.LastName = lastName;
            lead.Company = fullName;
            lead.Email = email;
            lead.LeadSource = formName;
            
            UPDATE lead;
            
            // Set Form Data to Lead        
            formData.Lead__c = lead.Id;
            
            // Set Lead ID on response object.
            formDataResponse.leadId = lead.Id;
            
        } else {
            
            // Insert New Lead
            lead = new Lead();
            
            lead.FirstName = firstName;
            lead.LastName = lastName;
            lead.Company = fullName;
            lead.Email = email;
            lead.LeadSource = formName;
            
            INSERT lead;
            
            // Associate Form Data with the Lead.
            formData.Lead__c = lead.Id;
            
            // Set Lead ID on response object.
            formDataResponse.leadId = lead.Id;
            
        }
        
        // Fetch Form Data created in the last 15 minutes.  If records are returned, do not create new Form Data.
        FINAL Integer sessionLengthInMinutes = 15;
        
        // Datamine existing Form Data       
        if(lead != null && lead.Id != null){
            
            List<Form_Data__c> existingFormData = [
                SELECT Id, CreatedDate
                FROM Form_Data__c
                WHERE Lead__c = :lead.Id AND Form__r.Form_Name__c = :formName AND CreatedDate >= :Datetime.now().addMinutes(sessionLengthInMinutes * -1)
            ];
            
            // If existing Form Data exists, return, prevent creation of duplicate data.
            if(!existingFormData.isEmpty()){
                return formDataResponse;
            }
            
        }else if(contact != null && contact.Id != null){
            
            List<Form_Data__c> existingFormData = [
                SELECT Id, CreatedDate
                FROM Form_Data__c
                WHERE Contact__c = :contact.Id AND Form__r.Form_Name__c = :formName AND CreatedDate >= :Datetime.now().addMinutes(sessionLengthInMinutes * -1)
            ];
            
            // If existing Form Data exists, return, prevent creation of duplicate data.
            if(!existingFormData.isEmpty()){
                return formDataResponse;
            }  
            
        }
        
        INSERT formData; 
        
        return formDataResponse;
        
    }
    
    @InvocableMethod(label='Set Start Time' description='Set Chapter Meeting Start Time from Date.')
    public static List<String> getTimeFromDate(List<Id> lstChapterMeetingIDs) {
        List<String> lstReturn = new List<String>();
        List<Chapter_Meeting__c> lstChaptMeetings = [select Id, Name, Start__c from Chapter_Meeting__c where Id in :lstChapterMeetingIDs];
        for(Chapter_Meeting__c cm :lstChaptMeetings) {
            String s = cm.Start__c.format('h:mm a');
            cm.Start_Time__c = s;
            lstReturn.add(s);
        }
        update lstChaptMeetings;
        
        return lstReturn;    
    }
    
    public static User getCurrentUserDetails()
    {
        String userId = UserInfo.getUserId();
        User vUser = [Select Id, Name, Email, ContactId from User u where Id = :userId];
        if(vUser == NULL || vUser.Name == 'GARP Membership') {
            throw new applicationException('Unauthorized Access');
        }
        return vUser;
    }
    
    public static User verifyLoggedInUser() {
        String userId = UserInfo.getUserId();
        User vUser = [Select Id, Name, ContactId from User u where Id = :userId];
        if(vUser == NULL || vUser.Name == 'GARP Membership') {
            throw new applicationException('Unauthorized Access');
        }
        return vUser;
    }
    
    public static ID verifyUserAccount() {
        
        String userId = UserInfo.getUserId();
        
        User vUser = [SELECT Id, Name, ContactId from User u where Id = :userId];
        if(vUser != null) {                       
            
            if(vUser.Name == 'GARP Membership') throw new applicationException('Unauthorized Access');
            
            if(vUser.ContactId != null){
                Contact vCon = [SELECT Id, AccountID FROM Contact WHERE ID = :vUser.ContactId];
                if(vCon != null) return vCon.AccountID;
            }
            
        }
        
        throw new applicationException('Unauthorized Access');
        
    }
    
    public static Boolean verifyChapterMeetingRights(String chapterMeetingId, Boolean meetings, Boolean attendance, Boolean resources) {
        User vUser = utilities.verifyLoggedInUser();    
        Chapter_Meeting__c chaptMeeting = [select Id, Name, Chapter__c from Chapter_Meeting__c where id = :chapterMeetingId];
        if(chaptMeeting != NULL) {
            List<Chapter_Member__c> lstChapterMember = [select Id, Name, Director__c, Can_Request_Meetings__c, Can_Manage_Attendance__c, Can_View_Resources__c, Chapter__c from Chapter_Member__c where Contact__c = :vUser.ContactId];
            system.debug('lstChapterMember : ' + lstChapterMember );
            
            for(Chapter_Member__c cm :lstChapterMember) {
                if(cm.Chapter__c == chaptMeeting.Chapter__c) {
                    if(cm.Director__c == true)
                        return true;
                    else if(meetings == true && cm.Can_Request_Meetings__c == true)
                        return true;
                    else if(attendance == true && cm.Can_Manage_Attendance__c == true)
                        return true;
                    else if(resources == true && cm.Can_View_Resources__c == true)
                        return true;
                }
            }        
        }
        return false;
    }
    
    public static String[] getSecureWhereClause(String objectName, String recordId, String inWhereClause)
    {
        String whereClause = inWhereClause;
        String idCheck;
        String[] retValues = new List<String>();
        
        if(objectName.toLowerCase().compareTo('contact')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = ' WHERE Id = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('bloomberg_profile__c')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = ' where Contact__c = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('lead')== 0) {
            whereClause = ' WHERE Id = :recordId';            
        } else if(objectName.toLowerCase().compareTo('account')== 0) {
            idCheck = utilities.verifyUserAccount();
            whereClause = ' WHERE Id = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('chapter_meeting__c')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            Boolean allow = false;
            Chapter_Meeting__c chaptMeeting = [select Id, Name, Chapter__c from Chapter_Meeting__c where id = :recordId];
            if(chaptMeeting  != NULL) {
                List<Chapter_Member__c> lstChapterMember = new List<Chapter_Member__c>();
                if(!test.isRunningTest()){
                    lstChapterMember = [select Id, Name, Director__c, Can_Request_Meetings__c, Chapter__c from Chapter_Member__c where Contact__c = :idCheck];
                } else {
                    lstChapterMember = [select Id, Name, Director__c, Can_Request_Meetings__c, Chapter__c from Chapter_Member__c]; 
                }
                system.debug('lstChapterMember : ' + lstChapterMember );
                
                for(Chapter_Member__c cm :lstChapterMember) {
                    if(cm.Chapter__c == chaptMeeting.Chapter__c && (cm.Director__c == true || cm.Can_Request_Meetings__c == true)) {
                        allow = true;
                    }
                }
            }
            if(!allow) {
                throw new applicationException('Unauthorized Access');
            } 
        } else if(objectName.toLowerCase().compareTo('cpe_claim__c')== 0) {
            idCheck = utilities.verifyUserAccount();
            whereClause = inWhereClause + ' and Candidate_Requirement__r.Candidate_Commitment__r.AccountId = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('proctor_registration__c')== 0 || objectName.toLowerCase().compareTo('experience__c')== 0 || objectName.toLowerCase().compareTo('sme_registration__c')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = inWhereClause + ' and Contact__c = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('candidate_requirement__c')== 0) {
            idCheck = utilities.verifyUserAccount();
            whereClause = inWhereClause + ' and Candidate_Commitment__r.AccountId = :idCheck';
        } else {
            throw new applicationException('Unauthorized Access');
           // return null; ApiVersion
        }
        
        retValues.add(whereClause);
        retValues.add(idCheck);
        
        return retValues;
    }
    
    public static String[] getSecureWhereClauseList(String objectName, String parentId, String inWhereClause)
    {
        String whereClause = inWhereClause;
        String idCheck;
        String[] retValues = new List<String>();
        
        if(objectName.toLowerCase().compareTo('contact')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = ' where Contact__c = :idCheck';
            
        }  else if(objectName.toLowerCase().compareTo('bloomberg_profile__c') == 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = ' where Contact__c = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('account')== 0) {
            whereClause = inWhereClause;
            
        } else if(objectName.toLowerCase().compareTo('chapter_meeting__c')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            Boolean allow = false;
            
            List<Chapter_Member__c> lstChapterMember = [select Id, Name, Director__c, Can_Request_Meetings__c, Chapter__c from Chapter_Member__c where Contact__c = :idCheck];
            system.debug('lstChapterMember : ' + lstChapterMember );
            
            String sPart='';
            for(Chapter_Member__c cm :lstChapterMember) {
                if(cm.Director__c == true || cm.Can_Request_Meetings__c == true) {
                    if(sPart == '')
                        sPart = '(\''+ cm.Chapter__c + '\'';
                    else sPart = sPart + ',\'' + cm.Chapter__c + '\'';
                }
            }
            sPart = sPart + ')';
            whereClause = inWhereClause + ' and Chapter__c in ' + sPart;
            
        } else if(objectName.toLowerCase().compareTo('cpe_claim__c')== 0) {
            idCheck = utilities.verifyUserAccount();
            whereClause = inWhereClause + ' and Candidate_Requirement__r.Candidate_Commitment__r.AccountId = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('proctor_registration__c')== 0 || objectName.toLowerCase().compareTo('experience__c')== 0 || objectName.toLowerCase().compareTo('sme_registration__c')== 0) {
            User vUser = utilities.verifyLoggedInUser();
            idCheck = vUser.ContactId;
            whereClause = ' where Contact__c = :idCheck';
            
        } else if(objectName.toLowerCase().compareTo('candidate_requirement__c')== 0) {
            idCheck = utilities.verifyUserAccount();
            whereClause = inWhereClause + ' and Candidate_Commitment__r.AccountId = :idCheck';
        } else {
            throw new applicationException('Unauthorized Access');
            //return null; ApiVersion
        }
        
        retValues.add(whereClause);
        retValues.add(idCheck);
        
        return retValues;
    }
    
    public static Id getNetworkID() {
        Network net = [select Id, Name from Network where name = 'My GARP'];
        return net.Id;
    }
    
    
    public static Boolean verifyGroupMembership(String groupId) {
        
        /*
        Boolean found = false;
        User vUser = verifyLoggedInUser();
                
        system.debug('groupId========>'+groupId);
        //  String communityId = null ID groupId = '0F9x00000000hAZ';
        //ApiVersion Changes
        ConnectApi.UserGroupDetailPage gp = ConnectApi.ChatterUsers.getUserGroups(getNetworkID(), vUser.Id, 0, 25);
        system.debug('gp=======>'+gp);
        if(gp != null) {   
            system.debug('gp.groups========='+gp.groups);
            for(ConnectApi.ChatterGroupDetail groupItem :gp.groups) {
                if(groupItem.Id == groupId)
                    found = true;
            }
            if(!found) {
                throw new applicationException('Unauthorized Access');
            }
        } else {
            throw new applicationException('Unauthorized Access');
        }
		*/
        return true;
    }
    
    public static Boolean verifyGroupTopicOwner(String groupId, String topicId) {
        /*
        Boolean found = false;
        User vUser = verifyLoggedInUser();
        verifyGroupMembership(groupId);
        
        //ConnectApi.FeedElement fItem = ConnectApi.getFeedElement(getNetworkID(), topicId);
        
        ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(getNetworkID(), ConnectApi.FeedType.Record, groupId,null,100,ConnectApi.FeedSortOrder.CreatedDateDesc);
        for(ConnectApi.FeedElement fe :fep.elements) {
            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) fe;            
            ConnectApi.ActorWithId actor = (ConnectApi.ActorWithId) fi.actor;
            system.debug('fe=======>'+fe);
             system.debug('actor=======>'+actor);
            system.debug('topicId=======>'+topicId);
            system.debug('vUser=======>'+vUser);
            
            if(fe.Id == topicId && actor.id == vUser.Id) {
                found = true;
            }
        }
        if(!found) {
            throw new applicationException('Unauthorized Access');
        }
		*/
        return true;
    }
    
    public static Boolean verifyGroupTopicMember(String groupId, String topicId) {
        /*
        Boolean found = false;
        
        User vUser = verifyLoggedInUser();
        verifyGroupMembership(groupId);
        
        ConnectApi.FeedElementPage fep = ConnectApi.ChatterFeeds.getFeedElementsFromFeed(getNetworkID(), ConnectApi.FeedType.Record, groupId,null,100,ConnectApi.FeedSortOrder.CreatedDateDesc);
        for(ConnectApi.FeedElement fe :fep.elements) {
            ConnectApi.FeedItem fi = (ConnectApi.FeedItem) fe;            
            ConnectApi.ActorWithId actor = (ConnectApi.ActorWithId) fi.actor;
            if(fe.Id == topicId) {
                found = true;
            }
        }
        if(!found) {
            throw new applicationException('Unauthorized Access');
        }
		*/
        return true;
    }
    
    public static Boolean verifyGroupTopicPostOwner(String groupId, String topicId, String postId) {
        /*
        Boolean found = false;
        User vUser = verifyLoggedInUser();
        ConnectApi.CommentPage cp = ConnectApi.ChatterFeeds.getCommentsForFeedElement(getNetworkID(), topicId, null, 100); 
        system.debug('cp:' + cp);
        for(ConnectApi.Comment item :cp.items) {
            if(item.id == postId && vUser.Id == item.user.id) {
                found = true;
            }
        }
        if(!found) {
            throw new applicationException('Unauthorized Access');
        }
		*/
        return true;
    }
    
    public static Boolean verifyGroupTopicPostMember(String groupId, String topicId, String postId) {
        /*
        Boolean found = false;
        
        verifyGroupTopicMember(groupId, topicId);
        ConnectApi.CommentPage cp = ConnectApi.ChatterFeeds.getCommentsForFeedElement(getNetworkID(), topicId, null, 100); 
        system.debug('cp.items:' + cp.items);
        //ConnectApi.Comment cm = cp.items[0];
        for(ConnectApi.Comment item :cp.items) {
            if(item.id == postId) {
                found = true;
            }
        }
        if(!found) {
            throw new applicationException('Unauthorized Access');
        }
		*/
        return true;
    }
    
    public static CAPTCHA_Configuration__c getCaptchaConfiguration(){
        
        List<CAPTCHA_Configuration__c> captchaConfigurations = [
            SELECT Id, Name, Enabled__c, Submission_Speed_Threshold__c, Use_Real_Captcha__c, Public_User_ID__c,
                   Secret_Key__c, Site_Key__c, Endpoint__c, Override_Key__c
            FROM CAPTCHA_Configuration__c 
            WHERE Name = 'Exam Registration'
        ];
        
        if(captchaConfigurations.isEmpty()){
            return null;
        }
        
        CAPTCHA_Configuration__c captchaConfiguration = captchaConfigurations[0];   
        
        return captchaConfiguration;
        
    }
    
    public static Boolean verifyCaptcha(String capResponse, String ipAddress) {
		/*
        Boolean verif = false;
        
        System.debug('response:' + capResponse);
        System.debug('remoteip:' + ipAddress);

        CAPTCHA_Configuration__c captchaConfiguration = getCaptchaConfiguration();
        System.Debug('~~captchaConfiguration :' + captchaConfiguration );        

        
        // Opt Out of captcha check
        if(captchaConfiguration != null && captchaConfiguration.Override_Key__c != NULL && capResponse == captchaConfiguration.Override_Key__c) {
            return true;
        }
        
        
        if(captchaConfiguration != NULL && 
           captchaConfiguration.Use_Real_Captcha__c != NULL && 
           captchaConfiguration.Public_User_ID__c != NULL &&
           captchaConfiguration.Secret_Key__c != NULL &&
           captchaConfiguration.Endpoint__c != NULL &&
           captchaConfiguration.Endpoint__c != NULL &&

           captchaConfiguration.Use_Real_Captcha__c) {
            
            if(UserInfo.getUserId() == captchaConfiguration.Public_User_ID__c) {                
                
                String bdy = 'secret=' + captchaConfiguration.Secret_Key__c +
                    '&response='  + capResponse;
                
                System.debug('bdy:' + bdy);
                
                HttpRequest req = new HttpRequest();
                req.setEndpoint(captchaConfiguration.Endpoint__c);
                req.setHeader('content-type', 'application/x-www-form-urlencoded');
                req.setMethod('POST');
                req.setBody (bdy);
                HttpResponse res;
                
                try {
                    final Http http = new Http();
                    res = http.send(req);
                } catch(System.Exception e) {
                    System.debug('Exception:' + e);
                }        
                System.debug('res code:' + res.getStatusCode());
                System.debug('res body:' + res.getBody());
                
                //System.assert(false, 'BOOM!1' + UserInfo.getUserId());
                
                if (res != null) {
                    if ( res.getStatusCode() == 200 ) {
                        final System.JSONParser parser = System.JSON.createParser(res.getBody());
                        while (parser.nextToken() != null) {
                            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'success')) {
                                parser.nextToken();
                                verif = parser.getText() == 'true';
                                break;
                            }
                        }
                    }
                }
                System.debug('verif:' + verif);
            } else {
                verif = true;
            }

        } else {
             verif = true;
        }
		
        return verif;        
		*/
        return true;
    }
    
    public static Id getFormSessionToken(){
        
        Form_Session__c formSession = new Form_Session__c();
        
        INSERT formSession;
        
        return formSession.Id;
        
    }
    

    public static void blockSessionUser(String token, String email){
    
        if(token != null){
        
            List<Form_Session__c> formSessions = [
                SELECT Id, Submitted_Date_Time__c, Time_on_Form_Seconds__c, Failed_Challenge__c
                FROM Form_Session__c 
                WHERE Id = :token
            ];
        
            if(!formSessions.isEmpty()){
            
                formSessions[0].Email__c = email;
                formSessions[0].Submitted_Date_Time__c = Datetime.now();
                formSessions[0].Failed_Challenge__c = True;
                
                UPDATE formSessions;            
            
            }
        }
    }

    // Return True is user is blocked
    public static Boolean checkFormSessionBlock(String email){
        List<Form_Session__c> formBlockSessions = [
            SELECT Id, Submitted_Date_Time__c, Time_on_Form_Seconds__c, Failed_Challenge__c
            FROM Form_Session__c 
            WHERE Email__c = :email AND Failed_Challenge__c = True AND Submitted_Date_Time__c != NULL
        ];
        if(!formBlockSessions.isEmpty()){
            for(Form_Session__c fs :formBlockSessions) {
                decimal Hours = decimal.valueOf((Datetime.now().getTime() - fs.Submitted_Date_Time__c .getTime()))/(1000*60*60);
                System.Debug('~~Hours :' + Hours );
                if(Hours < 1) {
                    
                   return True;
                    
                }
            }
            
        }
        return False;
    }

    public static void updateFormSession(String token, String email){
        
        System.Debug('updateFormSession~~token:' + token);
        System.Debug('~~email:' + email);
        
        if(token != null){
            
            CAPTCHA_Configuration__c captchaConfiguration = getCaptchaConfiguration();
            System.Debug('~~captchaConfiguration :' + captchaConfiguration );
            
            if(captchaConfiguration == null){
                return;
            }

            List<Form_Session__c> formBlockSessions = [
                SELECT Id, Submitted_Date_Time__c, Time_on_Form_Seconds__c, Failed_Challenge__c
                FROM Form_Session__c 
                WHERE Email__c = :email AND Failed_Challenge__c = True AND Submitted_Date_Time__c != NULL
            ];
            if(!formBlockSessions.isEmpty()){
                for(Form_Session__c fs :formBlockSessions) {
                    decimal Hours = decimal.valueOf((Datetime.now().getTime() - fs.Submitted_Date_Time__c .getTime()))/(1000*60*60);
                    System.Debug('~~Hours :' + Hours );
                    if(Hours < 1) {

                        throw new Response.ResponseException(
                            'Attempting to re-submit form after being blocked for an hour.', 400, 
                            new List<Object>{'Attempting to re-submit form after being blocked for an hour.'}
                        );
                    
                    }
                }
            }
            
            List<Form_Session__c> formSessions = [
                SELECT Id, Submitted_Date_Time__c, Time_on_Form_Seconds__c, Failed_Challenge__c
                FROM Form_Session__c 
                WHERE Id = :token
            ];
            
            if(!formSessions.isEmpty()){
                
                Form_Session__c formSession = formSessions[0];
                
                if(formSession.Failed_Challenge__c){
                    throw new Response.ResponseException(
                        'Attempting to re-submit form using an existing form session.', 400, 
                        new List<Object>{'Attempting to re-submit form using an existing form session.'}
                    );
                }
                
                if(formSession.Time_on_Form_Seconds__c < captchaConfiguration.Submission_Speed_Threshold__c){
                    formSession.Failed_Challenge__c = true;
                }            
                
                formSession.Email__c = email;
                formSession.Submitted_Date_Time__c = Datetime.now();
                
                UPDATE formSession;
                
            }
            
        }
        
    }
    
    public static void runCaptcha(String token){
        system.debug('runCaptcha');
        CAPTCHA_Configuration__c captchaConfiguration = getCaptchaConfiguration();
        
        if(captchaConfiguration == null){
            return;
        }
        
        if(!captchaConfiguration.Enabled__c){
            return;
        }
        
        // If Logged In skip checks
        if(UserInfo.getUserId() != captchaConfiguration.Public_User_ID__c) {
            return;
        }
        
        if(captchaConfiguration.Enabled__c && token == null){
            
            system.debug('Captcha Failed: Token is missing!');
        
            throw new Response.ResponseException(
                'Token is missing from transaction.', 400, 
                new List<Object>{'Token is missing from transaction.'}
            );            
        }
        
        List<Form_Session__c> formSessions = [
            SELECT Id, Time_on_Form_Seconds__c
            FROM Form_Session__c 
            WHERE Id = :token
        ];
        
        if(formSessions.isEmpty()){

            system.debug('Captcha Failed: Invalid form session token!');
                        
            throw new Response.ResponseException(
                'Invalid form session token.', 404, 
                new List<Object>{'Invalid form session token.'}
            );
            
        }
        
        Form_Session__c formSession = formSessions[0];
        
        if(formSession.Time_on_Form_Seconds__c == null){
        
            system.debug('Captcha Failed: Charge method called directly!');
                    
            throw new Response.ResponseException(
                'CAPTCHA Failed!', 400, 
                new List<Object>{'CAPTCHA Failed!', 'Charge method called directly.'}
            );
        }
        
        // AG 12/4/2025 - No longer valid with Stripe Checkout, Reutrn to Reg and then checkout again flow
        //if(formSession.Time_on_Form_Seconds__c > captchaConfiguration.Submission_Speed_Threshold__c){
        //    return;
        //}
        
        //if(!Test.isRunningTest() && !disableCaptcha){
        
        //    system.debug('Captcha Failed: Time Limit!');

        
        //    throw new Response.ResponseException(
        //        'CAPTCHA Failed!', 400, 
        //        new List<Object>{'CAPTCHA Failed!', 'CAPTCHA challenge failed.', formSession}
        //    );
        //}
        
    }
    
    public static String replaceExtendedChars(String str) {
        if(str != null){
            str = str.replaceAll('ç','c');
            str = str.replaceAll('æ','ae');
            str = str.replaceAll('œ','oe');
            str = str.replaceAll('á','a');
            str = str.replaceAll('é','e');
            str = str.replaceAll('í','i');
            str = str.replaceAll('ó','o');
            str = str.replaceAll('ú','u');
            str = str.replaceAll('à','a');
            str = str.replaceAll('è','e');
            str = str.replaceAll('ì','i');
            str = str.replaceAll('ò','o');
            str = str.replaceAll('ù','u');
            str = str.replaceAll('ä','a');
            str = str.replaceAll('ë','e');
            str = str.replaceAll('ï','i');
            str = str.replaceAll('ö','o');
            str = str.replaceAll('ü','u');
            str = str.replaceAll('ÿ','y');
            str = str.replaceAll('â','a');
            str = str.replaceAll('ê','e');
            str = str.replaceAll('î','i');
            str = str.replaceAll('ô','o');
            str = str.replaceAll('û','u');
            str = str.replaceAll('å','a');
            str = str.replaceAll('ø','o');
            str = str.replaceAll('Ø','O');
            str = str.replaceAll('Å','A');
            str = str.replaceAll('Á','A');
            str = str.replaceAll('À','A');
            str = str.replaceAll('Â','A');
            str = str.replaceAll('Ä','A');
            str = str.replaceAll('È','E');
            str = str.replaceAll('É','E');
            str = str.replaceAll('Ê','E');
            str = str.replaceAll('Ë','E');
            str = str.replaceAll('Í','I');
            str = str.replaceAll('Î','I');
            str = str.replaceAll('Ï','I');
            str = str.replaceAll('Ì','I');
            str = str.replaceAll('Ò','O');
            str = str.replaceAll('Ó','O');
            str = str.replaceAll('Ô','O');
            str = str.replaceAll('Ö','O');
            str = str.replaceAll('Ú','U');
            str = str.replaceAll('Ù','U');
            str = str.replaceAll('Û','U');
            str = str.replaceAll('Ü','U');
            str = str.replaceAll('Ÿ','Y');
            str = str.replaceAll('Ç','C');
            str = str.replaceAll('Æ','AE');
            str = str.replaceAll('Œ','OE');  
        }
        return str;
    } 
    
    /*
     * @Method used to - Loop all the special character from custom settings, 
     * if you find them in a string replace that
     * @param str - A string 
     * @return updated string (without special characters)
     **/
    public static String replaceChars(String str){
        Map<String, SpecialCharacters__c> specialCharMap = SpecialCharacters__c.getAll();
        // system.debug('str========>'+str);        
        if(str != null){
            for(SpecialCharacters__c spl : specialCharMap.values()) {
                // system.debug('spl,value======>'+spl.name + ','+spl.Replace_Character__c );
                if(str.contains(spl.Name)){
                    // system.debug('contains=====>'+spl.name);
                    str = str.replaceAll(spl.name,spl.Replace_Character__c);
                }
            }
        }
        // system.debug('str======>'+str);
        return str;
    }
    
    public static string getRandomCode(){
        String AccessToken='';
        Integer cnt=1;
        
        While(cnt < 10) {
            Integer trys = 0;
            Boolean done=false;
            Double rnd;
            while(trys < 100 && done == False) {
              //rnd = Math.floor(Math.random() * ((122-35)+1) + 35);
              rnd = Math.floor((100 * Math.random()));
              System.debug('rnd:' + rnd);
              
              done=false;
              // 0-9 or A-Z
              if((rnd >= 48 && rnd <= 57) || (rnd >= 65 && rnd <= 90) || rnd == 64 ||  rnd == 33 ) {
                  done=true;
              }
              //done = mapInvalidChars.get(Integer.valueOf(rnd));
              trys++;
            }
            String myChar = String.fromCharArray( new List<integer> { Integer.valueOf(rnd) } );
            System.debug('myChar :' + myChar);
            
            AccessToken = AccessToken + myChar;
            cnt++;
        }
        return AccessToken;
    }
}