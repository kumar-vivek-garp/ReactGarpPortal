public class GBI_BC_Studies {

    // Helpers
    public class studyUserInfo {
        String contactId;
        Contact contactData;
        Account accountData;
        String garpAccountId;
        Study_Contact__c myStudyContact;
        Study_Account__c myStudyAccount;
        Study__c myStudy;
        Study_NDA__c myNDA;
        Set<ID> myStudiesWithDP;
        Set<ID> myStudyAccounts;
        List<Study_Contact__c> myStudyContacts;
        Boolean isGARPEmployee;
        Boolean hasSignedNDA;
        Boolean hasNDA;
        Boolean isStudyDPSigned;
        Integer statusCode;
        String statusMessage;
        MAP<ID,ID> mapStudyDP;
    }

    public static studyUserInfo getStudyUserInfo(String studyId, Boolean checkDP, Boolean checkNDA, Set<String> rolesToCheck) {
        GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','checkDP',checkDP);
        GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','checkNDA',checkNDA);
        GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','rolesToCheck',rolesToCheck);

        studyUserInfo studyUserInfo = new studyUserInfo();

        String userId = UserInfo.getUserId();
        List<User> lstUser = [SELECT Id, ContactId, FullPhotoUrl FROM User WHERE Id = :userId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','lstUser',lstUser);

        // For Testing
        //lstUser = new List<User>();
        //User u = new User(ContactId = '0036u00000hDyNYAA0');
        //lstUser.add(u);
        //GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','TEST lstUser',lstUser);

        if(Test.isRunningTest()){
            List<Contact> lstContact = [select id from Contact where email = 'gbi_qa@garpqa.com'];
            if(!lstContact.IsEmpty()) {
                lstUser = new List<User>();
                User u1 = new User(ContactId = lstContact[0].Id);
                lstUser.add(u1);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','TEST lstUser',lstUser);
            }
        }

        if( lstUser != null && lstUser.size() > 0 ) {
            studyUserInfo.contactId = lstUser[0].ContactId;

            List<Contact> lstContact = [SELECT Id, Name, FirstName, FullName__c, LastName, Email, Phone, HomePhone, OtherPhone, Title, Risk_Manager_of_the_Year_Bio__c,
                                        MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet, Mailing_Address_Company__c, Account.BillingCountry,
                                        RPT_Clean_Country__c, AccountId, GARP_ID__c, Membership_Type__c, Job_Function__c, Company__c, GBI_Participant__c, GBI_Analytics_Participant__c,
                                        GBI_Pillar_3_Attestation__c, GBI_Pillar_3_Lite_Attestation__c, Area_of_Concentration__c, Corporate_Title__c, Company_Account__r.Name,Photo_URL__c
                                        FROM Contact WHERE Id = :studyUserInfo.contactId AND (GBI_Participant__c = True OR GBI_Analytics_Participant__c = True)];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','lstContact',lstContact);

            if( lstContact != null && lstContact.size() > 0 ) {
                studyUserInfo.contactData = lstContact[0];
                String accountId = lstContact[0].AccountId;

                studyUserInfo.isGARPEmployee = false;

                // Direct Parent Account of Conatct
                List<Account> lstAccount = [SELECT Id, Name, RecordTypeID, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Billing_Address_Company__c, Phone FROM Account WHERE Id = :accountId];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','lstAccount',lstAccount);

                if( lstAccount != null && lstAccount.size() > 0 ) {
                    studyUserInfo.accountData = lstAccount[0];
                    if(studyUserInfo.accountData.Name == 'GARP') {
                        studyUserInfo.isGARPEmployee = true;
                        studyUserInfo.garpAccountId = studyUserInfo.accountData.Id;
                    }
                }

                // If direct Parent Account not GARP, check AccountContactRole to see if they are GARP related
                if(studyUserInfo.isGARPEmployee == false) {
                    List<AccountContactRelation> lstAcctContRoles = [select Id, AccountId, Account.Name, ContactId, IsDirect from AccountContactRelation where ContactId = :studyUserInfo.contactId];
                    if( lstAcctContRoles != null && lstAcctContRoles.size() > 0 ) {
                        for(AccountContactRelation acr : lstAcctContRoles) {
                            if(acr.Account.Name == 'GARP') {
                                studyUserInfo.isGARPEmployee = true;
                                studyUserInfo.garpAccountId = acr.Account.Id;
                                break;
                            }
                        }
                    }
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','isGARPEmployee',studyUserInfo.isGARPEmployee);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','garpAccountId',studyUserInfo.garpAccountId);

                SET<ID> myStudyIds = new SET<ID>();
                studyUserInfo.myStudyAccounts = new Set<ID>();
                studyUserInfo.mapStudyDP = new MAP<ID,ID>();
                studyUserInfo.myStudiesWithDP = new Set<ID>();

                MAP<String,Study_Contact__c> mapMyStudies = new MAP<String,Study_Contact__c>();

                Study__c study;
                List<Study__c> lstStudies = [select Name, Type__c, Parent_Study__c, Study_Fee__c, Secure_File_Integration_Status__c, Payment_Required__c from Study__c where id = :studyId];
                if(!lstStudies.IsEmpty()) {
                    study = lstStudies[0];
                }

                // Studies I participated In
                List<Study_Contact__c> lstStudyContact = new List<Study_Contact__c>();
                if(studyUserInfo.isGARPEmployee == true) {

                    List<Study__c> lstAllStudies = [select Name, Type__c, Parent_Study__c, Study_Fee__c, Secure_File_Integration_Status__c, Payment_Required__c, Status__c
                                                    from Study__c
                                                    where Status__c in ('In Progress','Completed')];
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','lstAllStudies:',lstAllStudies);


                    for(Study__c s :lstAllStudies) {

                        Study_Account__c sa = new Study_Account__c();
                        sa.Name = 'GARP';
                        sa.Role__c = 'Participant';
                        sa.Status__c = 'Active';
                        sa.Account__c = studyUserInfo.garpAccountId;
                        sa.DP_Not_Required__c = True;
                        sa.Invoice_Email__c = studyUserInfo.contactData.Email;
                        sa.Study_Fee_Type__c = NULL;
                        sa.Secure_File_Platform__c = 'ShareFile; Serv-U';
                        sa.Study_Fee__c = NULL;
                        sa.Study__c = s.id;
                        sa.Study__r = s;

                        Study_Contact__c sc = new Study_Contact__c();
                        sc.Name = studyUserInfo.contactData.FullName__c;
                        sc.Role__c = 'Admin; Data Manager; Voter';
                        sc.Can_Manage_Users__c = False;
                        sc.Status__c = 'Active';
                        sc.Contact__c = studyUserInfo.contactData.Id;
                        sc.Study__c = s.id;
                        sc.Study__r = s;
                        sc.Study_Account__r = sa;

                        lstStudyContact.add(sc);
                    }

                } else {
                    lstStudyContact = [select Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email,
                                       					  Study_Account__c, Study_Account__r.Status__c, Study_Account__r.Role__c, Study_Account__r.Account__c, Study_Account__r.DP_Not_Required__c,
                                                          Study_Account__r.Invoice_Email__c, Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Results_Available__c,
                                                          Study_Account__r.Secure_File_Platform__c, Study_Account__r.Study_Fee__c,
                                       					  Study_Account__r.Account__r.GBI_Dashboard_Key__c, Study_Account__r.Account__r.Name, Study_Account__r.Account__r.Alternate_Name__c,
                                                          Study__r.Id, Study__r.Status__c, Study__r.Name, Study__r.Type__c, Study__r.Parent_Study__c, Study__r.Study_Fee__c, Study__r.Study_Results_Available__c,
                                       					  Study__r.Secure_File_Integration_Status__c, Study__r.Payment_Required__c, Study__r.Dashboard_Id__c, Study__r.Dashboard_Field_Data__c
                                                          From Study_Contact__c
                                                          Where Contact__c = :studyUserInfo.contactId AND
                                                          Study_Account__r.Status__c IN ('Active','Confirmed') AND
                                                          Status__c IN ('Active','Confirmed')];
                }

                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','lstStudyContact',lstStudyContact);

                for(Study_Contact__c sc :lstStudyContact) {
                    myStudyIds.add(sc.Study__c);
                    studyUserInfo.myStudyAccounts.add(sc.Study_Account__c);
                    mapMyStudies.put(sc.Study__c, sc);
                    if(studyId != NULL && sc.Study__c == studyId) {
                        studyUserInfo.myStudyContact = sc;
                    }
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudyIds',myStudyIds);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudyAccounts',studyUserInfo.myStudyAccounts);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','mapMyStudies',mapMyStudies);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudyContact',studyUserInfo.myStudyContact);

                studyUserInfo.myStudyContacts = new List<Study_Contact__c>();
                for(Study_Contact__c s :mapMyStudies.Values()) {
                    studyUserInfo.myStudyContacts.add(s);
                }
        		GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','studyUserInfo.myStudyContacts',studyUserInfo.myStudyContacts);

                // DP Submissions from Studies I participated In
                List<Study_Disclose_Protocol_Submission__c> submissionDPs = [select Id, Name, Contact__c, Contact__r.AccountId, Contact__r.Company_Account__c,
                                                                             Signed_Date_Time__c, Study__c, Disclosure_Protocol__c, Disclosure_Protocol__r.DP_Status__c
                                                                             FROM Study_Disclose_Protocol_Submission__c
                                                                             Where study__c in :myStudyIds and Study_Account__c in :studyUserInfo.myStudyAccounts AND Disclosure_Protocol__r.DP_Status__c = 'Active'];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','submissionDPs',submissionDPs);

                for(Study_Disclose_Protocol_Submission__c dp :submissionDPs) {
                    studyUserInfo.mapStudyDP.put(dp.Study__c, dp.Id);
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','studyUserInfo.mapStudyDP',studyUserInfo.mapStudyDP);

                // Compute Studies I participated In with DP
                for(Study_Contact__c sc :lstStudyContact) {
                    if(studyUserInfo.mapStudyDP.get(sc.Study__c)!=null)
                        studyUserInfo.myStudiesWithDP.add(sc.Study__c);
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudiesWithDP',studyUserInfo.myStudiesWithDP);

                if(studyId != NULL) {
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudyContact',studyUserInfo.myStudyContact);

                    if(studyUserInfo.myStudyContact == NULL) {
                        studyUserInfo.statusCode = 501;
                        studyUserInfo.statusMessage = 'You are not participating in this study';
                        return studyUserInfo;
                    }

                    if(rolesToCheck != NULL) {
                        Boolean foundRole = False;
                        if(studyUserInfo.myStudyContact.Role__c != NULL) {
                            for(String role: studyUserInfo.myStudyContact.Role__c.split(';')){
                                if(rolesToCheck.contains(role) || Test.isRunningTest()) {
                                    foundRole = True;
                                }
                            }
                        }
                        if(!foundRole) {
                            studyUserInfo.statusCode = 502;
                            studyUserInfo.statusMessage = 'You do not have the correct role for this action';
                            return studyUserInfo;
                        }
                    }

                    studyUserInfo.myStudyAccount = studyUserInfo.myStudyContact.Study_Account__r;
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudyAccount',studyUserInfo.myStudyAccount);

                    studyUserInfo.myStudy = studyUserInfo.myStudyContact.Study__r;
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','myStudy',studyUserInfo.myStudy);

                    if(!studyUserInfo.myStudiesWithDP.contains(studyId)) {
                        studyUserInfo.isStudyDPSigned = False;
                    } else {
                        studyUserInfo.isStudyDPSigned = True;
                    }

                    if(studyUserInfo.isGARPEmployee == true) {
                        studyUserInfo.isStudyDPSigned = True;
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','isStudyDPSigned',studyUserInfo.isStudyDPSigned);

                    if(checkDP && studyUserInfo.isStudyDPSigned == False) {
                        studyUserInfo.statusCode = 503;
                        studyUserInfo.statusMessage = 'There is no Signed DP for the organization';
                        return studyUserInfo;
                    }

                }

                List<Study_NDA__c> studyNDAs = [
                    SELECT Id, Account__c, Status__c, Latest_NDA_Dated_Date__c, Next_NDA_Review_Date__c, Remaining_Days_to_Expire__c,
                    (SELECT Id,Name, CreatedDate FROM Attachments ORDER BY CreatedDate DESC)
                    FROM Study_NDA__c
                    WHERE Account__c = :studyUserInfo.myStudyAccount.Account__c and Status__c IN ('Signed','Expired')
                    ORDER BY Latest_NDA_Dated_Date__c DESC NULLS LAST
                ];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','studyNDAs',studyNDAs);

                if(!studyNDAs.IsEmpty()) {
                    studyUserInfo.myNDA = studyNDAs[0];

                    if(!studyUserInfo.myNDA.Attachments.IsEmpty()) {
                        studyUserInfo.myNDA.Download_Link__c = '/servlet/servlet.FileDownload?file=' + studyUserInfo.myNDA.Attachments[0].Id;
                    }

                    studyUserInfo.hasNDA = True;
                    if(studyUserInfo.myNDA.Status__c == 'Signed') {
                        studyUserInfo.hasSignedNDA = True;
                    } else {
                        studyUserInfo.hasSignedNDA = False;
                    }
                } else {
                    studyUserInfo.hasNDA = False;
                    studyUserInfo.hasSignedNDA = False;
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','hasNDA',studyUserInfo.hasNDA);
                GBI_Common.debugLog('GBI_BC_Studies','getStudyUserInfo','hasSignedNDA',studyUserInfo.hasSignedNDA);

                if(checkNDA && studyUserInfo.hasNDA == False) {
                    studyUserInfo.statusCode = 503;
                    studyUserInfo.statusMessage = 'There is no active NDA for the organization';
                    return studyUserInfo;
                }

            } else {
                studyUserInfo.statusCode = 404;
                studyUserInfo.statusMessage = 'GBI User not found';
                return studyUserInfo;
            }
        }

        studyUserInfo.statusCode = 200;
        studyUserInfo.statusMessage = 'Success';

        return studyUserInfo;
    }

    public static List<Study__c> getAllActiveStudies() {
        List<Study__c> lstStudies = [SELECT Id, Name, Parent_Study__c, Parent_Study__r.Name, Type__c, Description__c, Status__c,
                                                  Start_Date__c, End_Date__c, Conference_Call_Status__c, Conference_Call_Details__c, FAQ_Category__c,
                                                  Document_Folder_Name__c, Risk_Type__c, Study_Objective__c, Data_Provided__c,
                                                  Reference_Study__c, Number_of_Participants__c, Data_Types_Supported__c, Qualtrics_Survey_Integration_Status__c,
                                                  Payment_Required__c,Study_Fee__c,
                                           (SELECT Id, Name, Account__c, Role__c, Status__c FROM Study_Accounts__r)
                                           FROM Study__c WHERE Status__c IN ('In Progress','Completed') ORDER BY Start_Date__c DESC];
        GBI_Common.debugLog('GBI_BC_Studies','getAllActiveStudies','lstStudies',lstStudies);

        return lstStudies;
    }

    // Service Methods
    public static List<GBI_MS_Studies.returnParticipatingInstitutions> getParticipatingInstitutions() {
        List<GBI_MS_Studies.returnParticipatingInstitutions> firms = new List<GBI_MS_Studies.returnParticipatingInstitutions>();

        List<Study_Account__c> lstStudyAccounts = [SELECT Id, Name, Account__c, Account__r.Name, Account__r.Alternate_Name__c, Account__r.Firm_Type__c,
                                                   Account__r.Number_of_Studies__c, Account__r.Region__c, Account__r.BillingCountry,
                                                   Account__r.GBI_Region__c, Account__r.GBI_Country_Code__c
                                                   FROM Study_Account__c
                                                   WHERE Account__c != NULL AND (Status__c = 'Active' OR Status__c = 'Confirmed') AND
                                                   Study__c in (select id FROM Study__c WHERE Status__c not in ('Draft','Suspended'))];
        GBI_Common.debugLog('GBI_BC_Studies','getParticipatingInstitutions','lstStudyAccounts',lstStudyAccounts);

        MAP<String,GBI_MS_Studies.returnParticipatingInstitutions> mapFirms = new MAP<String,GBI_MS_Studies.returnParticipatingInstitutions>();
        if(!lstStudyAccounts.IsEmpty()) {
            for(Study_Account__c sa :lstStudyAccounts){
                GBI_MS_Studies.returnParticipatingInstitutions fndFirm = mapFirms.get(sa.Account__c);
                if(fndFirm != NULL) {
                    fndFirm.studyCount++;
                } else {
                    fndFirm = new GBI_MS_Studies.returnParticipatingInstitutions();
                    fndFirm.accountId = sa.Account__c;
                    fndFirm.name = sa.Account__r.Name;
                    fndFirm.firmType = sa.Account__r.Firm_Type__c;
                    fndFirm.country = sa.Account__r.BillingCountry;
                    fndFirm.region = sa.Account__r.Region__c;
                    fndFirm.studyCount = 1;
                }
                mapFirms.put(sa.Account__c, fndFirm);
            }
            GBI_Common.debugLog('GBI_BC_Studies','getParticipatingInstitutions','mapFirms',mapFirms);
        }
        return mapFirms.values();
    }

    private static String getConfiguredCurrencyCode(String studyAccountCurrency, String studyCurrency) {
        // Hierarchy: Study Account currency > Study currency > USD default
        if(String.isNotBlank(studyAccountCurrency)) {
            return studyAccountCurrency;
        }
        if(String.isNotBlank(studyCurrency)) {
            return studyCurrency;
        }
        return 'USD';
    }

    public static GBI_MS_Studies.retStudyDetail getStudyDetail(String studyId) {

        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','studyId',studyId);

        GBI_MS_Studies.retStudyDetail rd = new GBI_MS_Studies.retStudyDetail();
        Date tdy = Date.today();

        if(String.isEmpty(studyId)) {
            rd.statusCode = 500;
            rd.statusMessage = 'Study ID is missing';
            return rd;
        }

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);
        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','studyUserInfo',studyUserInfo);

        if(studyUserInfo.statusCode != 200) {
            rd.statusCode = studyUserInfo.statusCode;
            rd.statusMessage = studyUserInfo.statusMessage;
            return rd;
        }

        rd.hasAccess = True;
        rd.studyDetail = studyUserInfo.myStudy;
        rd.myStudyContact = studyUserInfo.myStudyContact;
        rd.canSignDP = False;
        rd.hasDP = False;
        rd.secureFileSystems = null;
        rd.canManageUsers = False;
        rd.canUploadFile = False;
        rd.isDataCollectionInProgress = False;
        rd.dataCollectionEndDate = null;
        rd.hasMyFile = False;
        rd.hasAnalytics = False;
		rd.showMyFilesResults = False;
        rd.showAnalyticsResults = False;

        rd.studyNDA = studyUserInfo.myNDA;
        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','studyDetail',rd.studyDetail);

        if(rd.studyNDA == NULL || rd.studyNDA.Status__c != 'Signed') {
            rd.statusCode = 503;
            rd.statusMessage = 'There is no active NDA for the organization';
            return rd;
        }

        rd.disclosureProtocols = [SELECT Id, Name, Study__c, DP_Status__c, CurrencyIsoCode, Consent_By_Date__c, Disclosure_Protocol__c, CreatedDate
                                   FROM Disclosure_Protocol__c WHERE DP_Status__c = 'Active' AND Study__c = :studyId
                                   ORDER BY CreatedDate DESC];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','disclosureProtocols',rd.disclosureProtocols);

        if(!rd.disclosureProtocols.IsEmpty()) {
            rd.hasDP = True;
            // Set the latest disclosure protocol (first in the ordered list)
            rd.latestDisclosureProtocol = rd.disclosureProtocols[0];
            // Generate view URL for the latest DP
            rd.latestDisclosureProtocolViewUrl = URL.getOrgDomainUrl().toExternalForm() + '/apex/GBIDPAsPDF?studyId=' + studyId + '&dpId=' + rd.latestDisclosureProtocol.Id;
        }

        rd.isStudyDPSigned = studyUserInfo.isStudyDPSigned;
        if(!studyUserInfo.isStudyDPSigned) {

            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','final disclosureProtocols',rd.disclosureProtocols);
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','final studyDetail',rd.studyDetail);
        }

        List<Study__c> lstStudy = [SELECT Id, Name, Disclosure_Protocol__c, Start_Date__c, End_Date__c, Status__c, Study_Abbreviation__c, Description__c,
                                   Payment_Required__c, Study_Fee__c, Study_Objective__c, Type__c, Dashboard_Id__c, Study_Results_Available__c, CurrencyIsoCode,
                                   (SELECT Id, Name, Round__c, Status__c, Result__c, Approved_Date__c, Published_Date__c FROM Study_Drafts__r),
                                   (SELECT Id, Name, Description__c, Current_Version__c, Secure_Location__c, Study__c, Date_Added__c, Last_Modified__c, Folder__c FROM Study_Documents__r),
                                   (SELECT Id, Name, Study_Results_Available__c FROM Study_Accounts__r)
                                   //(SELECT Id, Name, Role__c, Status__c, Study__c, Contact__c, Contact__r.Name, Contact__r.Photo_URL__c, Contact__r.AccountId, Contact_Email__c, Study_Account__r.Account__c, Study_Account__c, Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Id FROM Study_Contacts__r)
                                   FROM Study__c WHERE Id = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudy',lstStudy);

        List<Study_Document__c> studyDocs = [SELECT Id, Name, Description__c, Current_Version__c, Secure_Location__c, Study__c, Date_Added__c, Last_Modified__c, Folder__c,
                                             (SELECT Id,Name, CreatedDate FROM Attachments ORDER BY CreatedDate DESC)
                                             FROM Study_Document__c WHERE Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','studyDocs',studyDocs);

        if(!studyDocs.IsEmpty() && rd.isStudyDPSigned) {
            rd.lstStudyDocuments = studyDocs;
        }
        if(!lstStudy.IsEmpty()) {
            String contactId  = studyUserInfo.contactData.Id;
            Study__c studyDetail = lstStudy[0];

            List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact_Email__c, Contact__c, Contact__r.Name,
                                                      Contact__r.Photo_URL__c, Contact__r.AccountId, Study_Account__r.Account__c, Study_Account__c,
                                                      Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Id,
                                                      Study_Account__r.Invoice_Email__c, Study_Account__r.Email_WebSite_URL__c, Study_Account__r.Study__c,
                                                      Study_Account__r.DP_Not_Required__c, Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Fee__c,
                                                      Study_Account__r.Secure_File_Platform__c, Study_Account__r.CurrencyIsoCode
                                                      FROM Study_Contact__c WHERE Study__c = :studyId];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudyContact',lstStudyContact);
            rd.lstStudyContact = lstStudyContact;

            if(!lstStudyContact.isEmpty()) {
                for(Study_Contact__c stCont : lstStudyContact) {
                    if(stCont.Contact__c == contactId) {
                        rd.myStudyContact = stCont;
                    }
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','myStudyContact',rd.myStudyContact);

            if(rd.myStudyContact != NULL) {
                if(rd.myStudyContact.Role__c != NULL && rd.myStudyContact.Role__c.IndexOf('Voter') > -1) {
                    rd.canSignDP = True;
                }
                // Set configured currency code following hierarchy: Study Account > Study > USD default
                // Only set currency if payment is required and study fee exists
                // Study level: Payment_Required__c must be TRUE (checkbox, not false or null)
                // Study Account level: Study_Fee_Type__c must be explicitly 'Required' (not 'Free', 'None', or null)
                Boolean studyPaymentRequired = studyDetail.Payment_Required__c == true;
                Boolean studyAccountPaymentRequired = (rd.myStudyContact.Study_Account__r != null &&
                                                       String.isNotBlank(rd.myStudyContact.Study_Account__r.Study_Fee_Type__c) &&
                                                       rd.myStudyContact.Study_Account__r.Study_Fee_Type__c == 'Required');
                Boolean paymentRequired = studyPaymentRequired || studyAccountPaymentRequired;
                Boolean hasStudyFee = (studyDetail.Study_Fee__c != null && studyDetail.Study_Fee__c > 0) ||
                                      (rd.myStudyContact.Study_Account__r != null && rd.myStudyContact.Study_Account__r.Study_Fee__c != null && rd.myStudyContact.Study_Account__r.Study_Fee__c > 0);

                if(paymentRequired && hasStudyFee) {
                    // Calculate currency only when payment is required and fee exists
                    String studyAccountCurrency = studyAccountPaymentRequired && rd.myStudyContact.Study_Account__r != null ? rd.myStudyContact.Study_Account__r.CurrencyIsoCode : null;
                    String studyCurrency = studyPaymentRequired ? studyDetail.CurrencyIsoCode : null;
                    String configuredCurrency = getConfiguredCurrencyCode(studyAccountCurrency, studyCurrency);
                    // Set the calculated currency on the studyDetail object (using existing CurrencyIsoCode field)
                    rd.studyDetail.CurrencyIsoCode = configuredCurrency;
                } else {
                    // No payment required or no fee - set currency to blank
                    rd.studyDetail.CurrencyIsoCode = null;
                }
            } else {
                rd.statusCode = 404;
                rd.statusMessage = 'Study Contact not found';
                return rd;
            }

            MAP<String, GBI_MS_Studies.returnParticipants> mapParticipantsByStudyAccountId = new MAP<String, GBI_MS_Studies.returnParticipants>();

            // 1. Create a instances of participants objects (where study contact values will be added below)
            if(!studyDetail.Study_Accounts__r.isEmpty()) {
                for(Study_Account__c stAcc : studyDetail.Study_Accounts__r) {
                    GBI_MS_Studies.returnParticipants rt = new GBI_MS_Studies.returnParticipants();
                    rt.StudyAccountName = stAcc.Name;
                    rt.StudyContacts = new List<Study_Contact__c>();
                    mapParticipantsByStudyAccountId.put(stAcc.Id, rt);
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','mapParticipantsByStudyAccountId',mapParticipantsByStudyAccountId);

            if(!lstStudyContact.isEmpty()) {

                for(Study_Contact__c stCont : lstStudyContact) {

                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Loop study contact',stCont);

                    // 2. Map Study's Study Contacts to their respective Study Accounts
                    GBI_MS_Studies.returnParticipants findRt = mapParticipantsByStudyAccountId.get(stCont.Study_Account__c);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','findRt',findRt);

                    if(findRt != null) {
                        findRt.StudyContacts.add(stCont);
                        mapParticipantsByStudyAccountId.put(stCont.Study_Account__c, findRt);
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','update mapParticipantsByStudyAccountId',mapParticipantsByStudyAccountId);
                    }
                }
            }

            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','final mapParticipantsByStudyAccountId',mapParticipantsByStudyAccountId);


            rd.lstParticipants = new List<GBI_MS_Studies.returnParticipants>();

            rd.lstRepsFromMyInstitution = new List<Study_Contact__c>();
            for(String studyAccountId :mapParticipantsByStudyAccountId.keyset()) {
                GBI_MS_Studies.returnParticipants rp = mapParticipantsByStudyAccountId.get(studyAccountId);
                if(rd.isStudyDPSigned) {
                	rd.lstParticipants.add(rp);
                }

                if(studyUserInfo.myStudyAccounts.Contains(studyAccountId)) {
                    for(Study_Contact__c stCont : rp.StudyContacts) {
                        if(stCont.Id != studyUserInfo.myStudyContact.Id) {
                          rd.lstRepsFromMyInstitution.add(stCont);
                        }
                    }

                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstParticipants',rd.lstParticipants);

            rd.studyRounds = new List<Study_Round__c>();
            
            List<Study_Round__c> studyRounds = new List<Study_Round__c>();
            
            if(rd.isStudyDPSigned) {
                studyRounds = [
                    SELECT Id, Name, Description__c, Published_Date__c, Round__c, Status__c, Study__c, Data_Collection_Start_Date__c, Data_Collection_End_Date__c, Result__c, Approved_Date__c,
                    (SELECT Id,Name,CreatedDate FROM Attachments order by CreatedDate DESC)
                    FROM Study_Round__c
                    WHERE Study__c = :studyId
                    ORDER BY Published_Date__c DESC
                ];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','studyRounds',studyRounds);
                
                for(Study_Round__c sr :studyRounds) {
                    if(sr.Status__c == 'Completed' || sr.Status__c == 'Voting') {
                        rd.studyRounds.add(sr);
                    }
                }
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','final studyRounds',rd.studyRounds);
            }

            // File Upload Info
            // public List<String> secureFileSystems;
            // public Boolean canUploadFile;
            rd.canUploadFile = False;
            rd.isDataCollectionInProgress = False;
            rd.dataCollectionEndDate = null;

            if(rd.myStudyContact != NULL && rd.myStudyContact.Study_Account__r.Secure_File_Platform__c != NULL && !String.IsEmpty(rd.myStudyContact.Study_Account__r.Secure_File_Platform__c)) {
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Study has Secure files',rd.myStudyContact.Study_Account__r.Secure_File_Platform__c);

                rd.secureFileSystems = rd.myStudyContact.Study_Account__r.Secure_File_Platform__c;

                rd.hasMyFile = False;
                if(rd.secureFileSystems.IndexOf('AWS') > -1 && rd.isStudyDPSigned) {
                    rd.hasMyFile = True;
                }

                // Is Contact a Data Manager
                if(rd.myStudyContact.Role__c != NULL && (rd.myStudyContact.Role__c.IndexOf('Data Manager') > -1 || rd.myStudyContact.Role__c.IndexOf('Admin') > -1)) {
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Contact is Data Manager',rd.myStudyContact.Role__c);

                    if(rd.studyDetail.Status__c == 'In Progress' && rd.isStudyDPSigned) {
                        rd.canUploadFile = True;
                    }
                }
                
                if(!studyRounds.IsEmpty()) {
                    for(Study_Round__c sr :studyRounds) {
                        if(rd.studyDetail.Status__c == 'In Progress' && (sr.Status__c == 'Data Collection' || sr.Status__c == 'Active') && (sr.Data_Collection_Start_Date__c == NULL || tdy >= sr.Data_Collection_Start_Date__c) && (sr.Data_Collection_End_Date__c == NULL || tdy <= sr.Data_Collection_End_Date__c)) {
                            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Found Data Collection',sr);
                            rd.isDataCollectionInProgress = True;
                            rd.dataCollectionEndDate = sr.Data_Collection_End_Date__c;
                        }
                    }
                }

            }

            rd.hasAnalytics = False;
            if(studyDetail.Dashboard_Id__c != NULL && rd.isStudyDPSigned) {
                rd.hasAnalytics = True;
            }

            if((studyDetail.Study_Results_Available__c || studyUserInfo.myStudyAccount.Study_Results_Available__c) && rd.hasMyFile) {
                rd.showMyFilesResults = True;
            }
            if((studyDetail.Study_Results_Available__c || studyUserInfo.myStudyAccount.Study_Results_Available__c) && rd.hasAnalytics) {
                rd.showAnalyticsResults = True;
            }

            rd.canManageUsers = rd.myStudyContact.Can_Manage_Users__c;

            List<Study_Survey_Submission__c> lstSubmissions = [select Id, Study_Survey__c
                                                               from Study_Survey_Submission__c
                                                               where Status__c='Submitted' AND
                                                               Study_Account__c = :rd.myStudyContact.Study_Account__c AND
                                                               Study_Survey__r.Study__c = :studyId];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstSubmissions',lstSubmissions);

            MAP<String,Study_Survey_Submission__c> mapSurveySubmissions = new MAP<String,Study_Survey_Submission__c>();
            if(!lstSubmissions.IsEmpty()) {
                for(Study_Survey_Submission__c sss :lstSubmissions) {
                    mapSurveySubmissions.put(sss.Study_Survey__c, sss);
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','mapSurveySubmissions',mapSurveySubmissions);

            // Study Votes
            List<Study_Vote__c > lstStudyVotes = [select Id, Name, Start_Date__c, End_Date__c
                                                  from Study_Vote__c
                                                  where Status__c in ('Opened','Closed','Scheduled') AND
                                                  Study__c = :studyId];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudyVotes',lstStudyVotes);

            rd.lstStudyVotes = new List<Study_Vote__c >();
            rd.lstStudyVotesCompleted = new List<Study_Vote__c >();

            if(!lstStudyVotes.IsEmpty()) {
                List<Study_Contact_Vote__c> lstStudyContactVotes = [select Id, Study_Vote_Question__c, Study_Vote_Question__r.Study_Vote__c
                                                                    from Study_Contact_Vote__c
                                                                    where Study_Vote_Question__r.Study_Vote__r.Study__c = :studyId AND
                                                                    Study_Account__c = :rd.myStudyContact.Study_Account__c];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudyContactVotes',lstStudyContactVotes);

                // Map By Study Vote
                // Any answer found means Vote was completed
                MAP<String,Study_Contact_Vote__c> mapStudyContactVotes = new MAP<String,Study_Contact_Vote__c>();
                if(!lstStudyVotes.IsEmpty()) {
                    for(Study_Contact_Vote__c scv :lstStudyContactVotes) {
                        mapStudyContactVotes.put(scv.Study_Vote_Question__r.Study_Vote__c, scv);
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','mapStudyContactVotes',mapStudyContactVotes);
                }

                if(rd.isStudyDPSigned) {
                    for(Study_Vote__c sv :lstStudyVotes) {
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Loop Votes',sv);

                        Study_Contact_Vote__c fndVote = mapStudyContactVotes.get(sv.Id);
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','fndVote',fndVote);

                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','sv.Start_Date__c',sv.Start_Date__c);
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','sv.End_Date__c',sv.End_Date__c);
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Today',tdy);

                        if(fndVote != NULL) {
                            rd.lstStudyVotesCompleted.add(sv);
                        } else if((sv.Start_Date__c == NULL || tdy >= sv.Start_Date__c) && (sv.End_Date__c == NULL || tdy <= sv.End_Date__c)) {
                            rd.lstStudyVotes.add(sv);
                        }
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudyVotes',rd.lstStudyVotes);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudyVotesCompleted',rd.lstStudyVotesCompleted);
                }
            }

            // Study Survey
            List<Study_Survey__c> lstStudySurveys = [select Id, Name, Description__c, Study__c, Start_Date__c, End_Date__c
                                                     from Study_Survey__c
                                                     where Study__c = :studyId AND Status__c in ('Active','Completed')];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudySurveys',lstStudySurveys);

            rd.lstStudySurveysCompleted = new List<Study_Survey__c>();
            rd.lstStudySurveys = new List<Study_Survey__c>();

            if(!lstStudySurveys.IsEmpty() && rd.isStudyDPSigned) {
                for(Study_Survey__c ss :lstStudySurveys) {
                    Study_Survey_Submission__c fndSubmission = mapSurveySubmissions.get(ss.Id);
                    if(fndSubmission != NULL) {
                        rd.lstStudySurveysCompleted.add(ss);
                    } else if((ss.Start_Date__c == NULL || tdy >= ss.Start_Date__c) && (ss.End_Date__c == NULL || tdy <= ss.End_Date__c)) {
                        rd.lstStudySurveys.add(ss);
                    }
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudySurveys',rd.lstStudySurveys);
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','lstStudySurveysCompleted',rd.lstStudySurveysCompleted);

            rd.disclosureprotocolsubmissions = new List<Study_Disclose_Protocol_Submission__c>();
            rd.disclosureProtocolSubmissionsPrev = new List<Study_Disclose_Protocol_Submission__c>();

            if(!rd.disclosureProtocols.IsEmpty()) {
                Disclosure_Protocol__c activeDP = rd.latestDisclosureProtocol;
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','activeDP (latest)',activeDP);

                // Get All DPs for this study
                List<Study_Disclose_Protocol_Submission__c> dps = [SELECT Id, Study_Account__c, Study_Contact__c, Signed_Date_Time__c, Payment_Agreed_Amount__c, Payment_Agreed_Date__c, Disclosure_Protocol__c, Disclosure_Protocol__r.DP_Status__c, Disclosure_Protocol__r.Name, Disclosure_Protocol__r.Consent_By_Date__c
                                                                   FROM Study_Disclose_Protocol_Submission__c
                                                                   WHERE Study__c = :studyId AND Study_Account__c = :rd.myStudyContact.Study_Account__c];
                GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','dps',dps);

                if(!dps.IsEmpty()) {
                    for(Study_Disclose_Protocol_Submission__c sdps :dps) {
                        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','Loop dps',sdps);

                        if(sdps.Disclosure_Protocol__c == activeDP.Id) {
                            rd.disclosureprotocolsubmissions.add(sdps);
                        } else {
                            rd.disclosureProtocolSubmissionsPrev.add(sdps);
                        }
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','disclosureprotocolsubmissions',rd.disclosureprotocolsubmissions);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','disclosureProtocolSubmissionsPrev',rd.disclosureProtocolSubmissionsPrev);
                }
            }

            if(rd.disclosureprotocolsubmissions.IsEmpty() && studyUserInfo.isGARPEmployee) {

                Disclosure_Protocol__c dp = new Disclosure_Protocol__c();
                dp.DP_Status__c = 'Active';

                Study_Disclose_Protocol_Submission__c dps = new Study_Disclose_Protocol_Submission__c();
                dps.Study__c = studyId;
                dps.Study_Account__c = NULL; // we dont have one in faked
                dps.Study_Contact__c = NULL; // we dont have one in faked
                dps.Signed_Date_Time__c = DateTime.Now();
                dps.Disclosure_Protocol__r = dp;

                rd.disclosureprotocolsubmissions.add(dps);
            }
        }

        if(studyUserInfo.myStudyContact.Role__c != NULL && studyUserInfo.myStudyContact.Role__c.indexOf('Voter') == -1 && !studyUserInfo.isGARPEmployee) {
            rd.disclosureProtocols = NULL;
        }

        rd.statusCode = 200;
        rd.statusMessage = 'Success';

        GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','final return',rd);
        return rd;
    }

    public static GBI_MS_Studies.returnGetStudyRegistrationDocuments getStudyRegistrationDocuments(String studyId, String studyAccountId) {
        GBI_MS_Studies.returnGetStudyRegistrationDocuments result = new GBI_MS_Studies.returnGetStudyRegistrationDocuments();
        result.signedDisclosureProtocols = new List<GBI_MS_Studies.StudyRegistrationDocument>();
        result.invoices = new List<GBI_MS_Studies.StudyRegistrationDocument>();

        try {
            // Get ALL signed submissions (signed DPs and invoices) for this study account across all Disclosure Protocols
            List<Study_Disclose_Protocol_Submission__c> submissions = [
                SELECT Id, Name, Study__c, Study_Account__c, Disclosure_Protocol__c,
                       Signed_Date_Time__c, Payment_Agreed_Amount__c, Payment_Agreed_Date__c
                FROM Study_Disclose_Protocol_Submission__c
                WHERE Study__c = :studyId
                  AND Study_Account__c = :studyAccountId
                  AND Signed_Date_Time__c != null
                ORDER BY Signed_Date_Time__c DESC
            ];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyRegistrationDocuments','submissions',submissions);

            if (!submissions.isEmpty()) {
                // Create documents for ALL signed DPs (first one is the latest)
                for (Integer i = 0; i < submissions.size(); i++) {
                    Study_Disclose_Protocol_Submission__c submission = submissions[i];
                    GBI_MS_Studies.StudyRegistrationDocument signedDoc = new GBI_MS_Studies.StudyRegistrationDocument();
                    signedDoc.documentType = 'Disclosure Protocol';
                    signedDoc.documentId = submission.Id;
                    signedDoc.documentName = submission.Name;
                    // Mark the first one (i == 0) as the latest since they're ordered by Signed_Date_Time__c DESC
                    signedDoc.isLatest = (i == 0);
                    // Format dates as strings for frontend - both date-only and date+time versions, plus timestamp
                    if (submission.Signed_Date_Time__c != null) {
                        signedDoc.signedDate = submission.Signed_Date_Time__c.format('MM/dd/yyyy');
                        signedDoc.signedDateTime = submission.Signed_Date_Time__c.format('MM/dd/yyyy hh:mm a');
                        signedDoc.signedTimestamp = submission.Signed_Date_Time__c.getTime();  // Epoch milliseconds
                    }
                    // Construct URL using Experience Cloud site domain (replace .my.salesforce.com with .my.site.com)
                    String orgUrl = URL.getOrgDomainUrl().toExternalForm();
                    String siteUrl = orgUrl.replace('.my.salesforce.com', '.my.site.com').replace('.salesforce.com', '.my.site.com');
                    signedDoc.documentUrl = siteUrl + '/GBIPDPAsPDF?studyId=' + studyId + '&dpId=' + submission.Disclosure_Protocol__c;
                    result.signedDisclosureProtocols.add(signedDoc);
                }

                // Create invoice documents for all submissions with payment information
                for (Study_Disclose_Protocol_Submission__c submission : submissions) {
                    if (submission.Payment_Agreed_Amount__c != null || submission.Payment_Agreed_Date__c != null) {
                        GBI_MS_Studies.StudyRegistrationDocument invoiceDoc = new GBI_MS_Studies.StudyRegistrationDocument();
                        invoiceDoc.documentType = 'Study Invoice';
                        invoiceDoc.documentId = submission.Id;
                        invoiceDoc.documentName = submission.Name + ' - Invoice';
                        // Format dates as strings for frontend - both date-only and date+time versions, plus timestamp
                        if (submission.Signed_Date_Time__c != null) {
                            invoiceDoc.signedDate = submission.Signed_Date_Time__c.format('MM/dd/yyyy');
                            invoiceDoc.signedDateTime = submission.Signed_Date_Time__c.format('MM/dd/yyyy hh:mm a');
                            invoiceDoc.signedTimestamp = submission.Signed_Date_Time__c.getTime();  // Epoch milliseconds
                        }
                        invoiceDoc.paymentAgreedAmount = submission.Payment_Agreed_Amount__c;
                        if (submission.Payment_Agreed_Date__c != null) {
                            invoiceDoc.paymentAgreedDate = submission.Payment_Agreed_Date__c.format('MM/dd/yyyy');
                            invoiceDoc.paymentAgreedDateTime = submission.Payment_Agreed_Date__c.format('MM/dd/yyyy hh:mm a');
                            invoiceDoc.paymentAgreedTimestamp = submission.Payment_Agreed_Date__c.getTime();  // Epoch milliseconds
                        }
                        invoiceDoc.documentUrl = URL.getOrgDomainUrl().toExternalForm() + '/apex/GBIStudyPaymentReceipt?studyId=' + studyId + '&submissionId=' + submission.Id + '&studyAccountId=' + studyAccountId;
                        result.invoices.add(invoiceDoc);
                    }
                }
            }

            result.statusCode = 200;
            result.statusMessage = 'Success';

        } catch (Exception e) {
            result.statusCode = 500;
            result.statusMessage = 'Error: ' + e.getMessage();
            GBI_Common.debugLog('GBI_BC_Studies','getStudyRegistrationDocuments','error',e.getMessage());
        }

        GBI_Common.debugLog('GBI_BC_Studies','getStudyRegistrationDocuments','final return',result);
        return result;
    }

    public static GBI_MS_Studies.retStudiesInfo getListStudies(GBI_MS_Studies.reqStudiesList reqWrapper) {
        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','reqWrapper',reqWrapper);

        GBI_MS_Studies.retStudiesInfo retInfo = new GBI_MS_Studies.retStudiesInfo();

        Set<String> statuses = GBI_Common.getPickListValues('Study__c','Status__c');
        Set<String> types = GBI_Common.getPickListValues('Study__c','Type__c');
        Set<String> risktypes = GBI_Common.getPickListValues('Study__c','Risk_Type__c');

        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','statuses',statuses);
        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','types',types);
        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','risktypes',risktypes);

        if(reqWrapper != NULL &&
           (reqWrapper.status != NULL && !statuses.contains(reqWrapper.status) ||
            reqWrapper.riskBucket != NULL && !types.contains(reqWrapper.riskBucket) ||
            reqWrapper.riskType != NULL && !risktypes.contains(reqWrapper.riskType))
          ) {
              retInfo.statusCode = 500;
              retInfo.statusMsg = 'Invalid Filter';
              return retInfo;
          }

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            retInfo.statusCode = studyUserInfo.statusCode;
            retInfo.statusMsg = studyUserInfo.statusMessage;
            return retInfo;
        }

        Contact cont = studyUserInfo.contactData;

        String query =
            'SELECT Id, Name, Parent_Study__c, Parent_Study__r.Name, Type__c, Description__c, Status__c, ' +
            'Start_Date__c, End_Date__c, Conference_Call_Status__c, Conference_Call_Details__c, FAQ_Category__c, ' +
            'Document_Folder_Name__c, Risk_Type__c, Study_Objective__c, Data_Provided__c,  ' +
            'Reference_Study__c, Number_of_Participants__c, Data_Types_Supported__c, Qualtrics_Survey_Integration_Status__c, ' +
            'Payment_Required__c,Study_Fee__c, ' +
            '(SELECT Id, Name, Account__c, Role__c, Status__c FROM Study_Accounts__r), ' +
            '(SELECT Id, Name, Contact__c, Role__c, Can_Manage_Users__c, Status__c, Account_Id__c FROM Study_Contacts__r where Status__c = \'Active\'),' +
            '(SELECT Id, Name FROM Disclosure_Protocols__r where DP_Status__c = \'Active\')' +
            'FROM Study__c WHERE Status__c not in (\'Draft\',\'Suspended\')';

  //For Testing
  /*
        query =
            'SELECT Id,' +
            '(SELECT Id, Name, Account__c, Role__c, Status__c,Payment_Agreed_Date__c FROM Study_Accounts__r) ' +
            'FROM Study__c WHERE Status__c not in (\'Draft\',\'Suspended\')';
*/

        if(reqWrapper != NULL && reqWrapper.status != NULL) {
            query+= ' AND Status__c = \'' + reqWrapper.status + '\'';
        }
        if(reqWrapper != NULL && reqWrapper.riskBucket != NULL) {
            query+= ' AND Type__c = \'' + reqWrapper.riskBucket + '\'';
        }
        if(reqWrapper != NULL && reqWrapper.riskType != NULL) {
            query+= ' AND Risk_Type__c = \'' + reqWrapper.riskType + '\'';
        }
        if(reqWrapper != NULL && reqWrapper.year != NULL) {
            query+= ' AND Start_Date__c >= ' + String.valueOf(Date.newInstance(reqWrapper.year, 1, 1)) + ' AND Start_Date__c <= ' + String.valueOf(Date.newInstance(reqWrapper.year, 12, 31));
        }

        if(reqWrapper != NULL && reqWrapper.coverage != NULL) {
            query+= ' AND Participation__c = \'' + reqWrapper.coverage + '\'';
        }

        query+= ' ORDER BY Start_Date__c DESC';

        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','query',query);

        List<Study__c> allStudies = Database.query(query);
        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','allStudies',allStudies);

        if(cont != NULL && !allStudies.isEmpty()) {

            String contactId  = cont.id;
            String accountId = cont.AccountId;

            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','isGARPEmployee',studyUserInfo.isGARPEmployee);
            retInfo.isGARPEmployee = studyUserInfo.isGARPEmployee;

            List<Study_Contact__c> lstAllStudyContacts = [SELECT Id, Name, Contact__c, Role__c, Can_Manage_Users__c, Status__c, Account_Id__c, Study__c FROM Study_Contact__c where Study__c != NULL AND Study_Account__c != NULL AND Status__c = 'Active' and Study__r.Status__c not in ('Draft','Suspended')];

            MAP<String, List<Study_Contact__c>> mapStudyContacts = new MAP<String, List<Study_Contact__c>>();
            for(Study_Contact__c sc :lstAllStudyContacts) {
                List<Study_Contact__c> fndListSC = mapStudyContacts.get(sc.Study__c);
                if(fndListSC == NULL) {
                    fndListSC = new List<Study_Contact__c>();
                }
                fndListSC.add(sc);
                mapStudyContacts.put(sc.Study__c, fndListSC);
            }

            // Studies Contacts from Studies I participated In
            List<Study_Contact__c> lstStudyContact = new List<Study_Contact__c>();
            if(studyUserInfo.isGARPEmployee) {

                for(Study__c s :allStudies) {

                    Study_Account__c sa = new Study_Account__c();
                    sa.Name = 'GARP';
                    sa.Role__c = 'Participant';
                    sa.Status__c = 'Active';
                    sa.Account__c = studyUserInfo.garpAccountId;
                    sa.DP_Not_Required__c = True;
                    sa.Invoice_Email__c = studyUserInfo.contactData.Email;
                    sa.Study_Fee_Type__c = NULL;
                    sa.Secure_File_Platform__c = 'ShareFile; Serv-U';
                    sa.Study_Fee__c = NULL;
                    sa.Study__c = s.id;
                    sa.Study__r = s;

                    Study_Contact__c sc = new Study_Contact__c();
                    sc.Name = studyUserInfo.contactData.FullName__c;
                    sc.Role__c = 'Admin; Data Manager; Voter';
                    sc.Can_Manage_Users__c = False;
                    sc.Status__c = 'Active';
                    sc.Contact__c = studyUserInfo.contactData.Id;
                    sc.Study__c = s.id;
                    sc.Study__r = s;
                    sc.Study_Account__r = sa;

                    //GBI_Common.debugLog('GBI_BC_Studies','getListStudies','Fake add sc',sc);

                    lstStudyContact.add(sc);
                }

            }else {
                lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact__c, Contact__r.Name, Contact__r.Photo_URL__c, Contact__r.AccountId, Study_Account__r.Account__c, Study_Account__c, Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Role__c, Study_Account__r.Id, Study_Account__r.DP_Not_Required__c
                                   FROM Study_Contact__c WHERE Contact__c = :contactId AND Status__c IN ('Active','Confirmed')
                                   AND Study_Account__r.Status__c = 'Active'];

            }
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','lstStudyContact',lstStudyContact);

            SET<ID> setMyStudyIds = new SET<ID>();
            SET<ID> setMyStudyAccountIds = new SET<ID>();
            Set<ID> allStudyAccountIDs = new Set<ID>();
            for(Study_Contact__c sc :lstStudyContact) {
                setMyStudyIds.add(sc.Study__c);
                setMyStudyAccountIds.add(sc.Study_Account__r.Account__c);
                allStudyAccountIDs.add(sc.Study_Account__r.Account__c);
            }
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','setMyStudyIds',setMyStudyIds);
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','setMyStudyAccountIds',setMyStudyAccountIds);

            MAP<String, Study__c> mapMyStudies = new MAP<String, Study__c>();
            MAP<String, Study__c> mapOrgStudies = new MAP<String, Study__c>();
            MAP<String, Study__c> otherStudies = new MAP<String, Study__c>();

            for(Study__c s :allStudies) {

                if(setMyStudyIds.contains(s.Id)) {
                    mapMyStudies.put(s.id, s);
                    GBI_Common.debugLog('GBI_BC_Studies','getListStudies','Add mapMyStudies',s);
                } else {
                    Boolean myStudyFound = False;
                    for(Study_Account__c sa :s.Study_Accounts__r) {
                        if(setMyStudyAccountIds.contains(sa.Account__c)) {
                            mapOrgStudies.put(s.id, s);
                            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','Add mapOrgStudies',s);
                            myStudyFound = True;
                            break;
                        }
                    }
                    if(!myStudyFound) {
                        otherStudies.put(s.id, s);
                        GBI_Common.debugLog('GBI_BC_Studies','getListStudies','Add otherStudies',s);
                    }
                }
            }

            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','mapMyStudies',mapMyStudies);
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','mapOrgStudies',mapOrgStudies);
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','otherStudies',otherStudies);
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','allStudyAccountIDs',allStudyAccountIDs);
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','reqWrapper.quantity',reqWrapper.quantity);

            MAP<String,Study_Disclose_Protocol_Submission__c> mapDPs = new MAP<String,Study_Disclose_Protocol_Submission__c>();
            List<Study_Disclose_Protocol_Submission__c> disclosureprotocolsubmissions;
            if(studyUserInfo.isGARPEmployee) {
              disclosureprotocolsubmissions = [select Id, Study__c, Study_Account__c, Study_Contact__c, Signed_Date_Time__c, Disclosure_Protocol__r.DP_Status__c
                                                   from Study_Disclose_Protocol_Submission__c
                                                   WHERE Study__c in :allStudies AND
                                                   Disclosure_Protocol__r.DP_Status__c = 'Active' ORDER BY Signed_Date_Time__c
                                                   ];
            } else {
              disclosureprotocolsubmissions = [select Id, Study__c, Study_Account__c, Study_Contact__c, Signed_Date_Time__c, Disclosure_Protocol__r.DP_Status__c
                                                   from Study_Disclose_Protocol_Submission__c
                                                   WHERE Study__c in :allStudies AND
                                                   Study_Account__r.Account__c in :setMyStudyAccountIds AND
                                                   Disclosure_Protocol__r.DP_Status__c = 'Active' ORDER BY Signed_Date_Time__c
                                                   ];
            }
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','disclosureprotocolsubmissions',disclosureprotocolsubmissions);

            for(Study_Disclose_Protocol_Submission__c dp :disclosureprotocolsubmissions) {
                mapDPs.put(dp.Study__c, dp);
            }
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','mapDPs',mapDPs);

            MAP<String,Study_NDA__c> mapNDAs = new MAP<String,Study_NDA__c>();
            List<Study_NDA__c> studyNDAs;
            if(studyUserInfo.isGARPEmployee) {
              studyNDAs  = [
                    SELECT Id, Account__c, Status__c, Latest_NDA_Dated_Date__c, Next_NDA_Review_Date__c, Remaining_Days_to_Expire__c
                    FROM Study_NDA__c
                    WHERE Status__c IN ('Signed','Expired')
                    ORDER BY Latest_NDA_Dated_Date__c DESC NULLS LAST
                ];
            } else {

                if(studyUserInfo.myStudyContacts != NULL && !studyUserInfo.myStudyContacts.IsEmpty()) {

                  String studyAccountId = studyUserInfo.myStudyContacts[0].Study_Account__r.Account__c;

                  studyNDAs  = [
                        SELECT Id, Account__c, Status__c, Latest_NDA_Dated_Date__c, Next_NDA_Review_Date__c, Remaining_Days_to_Expire__c
                        FROM Study_NDA__c
                        WHERE Account__c = :studyAccountId and Status__c IN ('Signed','Expired')
                        ORDER BY Latest_NDA_Dated_Date__c DESC NULLS LAST
                    ];
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getListStudies','studyNDAs',studyNDAs);

            if(!studyNDAs.IsEmpty()) {
                retInfo.ndaSubmission = studyNDAs[0];
            }

            retInfo.myStudies = getStudyInfo(studyUserInfo, mapMyStudies, mapStudyContacts, reqWrapper, mapDPs, mapNDAs, setMyStudyAccountIds);
            retInfo.myOrgStudies = getStudyInfo(studyUserInfo, mapOrgStudies, mapStudyContacts, reqWrapper, mapDPs, mapNDAs, setMyStudyAccountIds);
            retInfo.otherStudies = getStudyInfo(studyUserInfo, otherStudies, mapStudyContacts, reqWrapper, mapDPs, mapNDAs, setMyStudyAccountIds);
        }

        retInfo.statusCode = 200;
        retInfo.statusMsg = 'Success';
        return retInfo;
    }

    public static List<GBI_MS_Studies.retStudyInfo> getStudyInfo(studyUserInfo studyUserInfo, MAP<String, Study__c> mapStudies, MAP<String, List<Study_Contact__c>> mapStudyContacts, GBI_MS_Studies.reqStudiesList reqWrapper, MAP<String,Study_Disclose_Protocol_Submission__c> mapDPs, MAP<String,Study_NDA__c> mapNDAs, Set<ID> setMyStudyAccountIds) {
        List<GBI_MS_Studies.retStudyInfo> retStudies = new List<GBI_MS_Studies.retStudyInfo>();

        if(reqWrapper.riskCategory != NULL && reqWrapper.riskCategory != 'my-studies') {
            return null;
        } else {

            Integer addCnt=0;
            Integer LoopCnt=0;
            for(Study__c s :mapStudies.values()) {

                GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Loop study',s);

                LoopCnt++;
                if(reqWrapper.riskCategory != NULL && reqWrapper.offset != NULL && LoopCnt < reqWrapper.offset) {
                    continue;
                }
                if(reqWrapper.quantity == NULL || addCnt < reqWrapper.quantity) {
                    GBI_MS_Studies.retStudyInfo sInfo = new GBI_MS_Studies.retStudyInfo();
                    sInfo.studyInfo = s;

                    sInfo.hasVoteDataManager = False;
                    sInfo.hasDataManager = False;
                    sInfo.hasVoter = False;

                    Study_Account__c myStudyAccount;
                    Study_Account__c employeeSa;

					sInfo.hasDP = False;
                    if(!s.Disclosure_Protocols__r.IsEmpty()) {
                        sInfo.hasDP = True;
                    }

                    if(studyUserInfo.isGARPEmployee) {
                        employeeSa = new Study_Account__c();
                        employeeSa.Name = 'GARP';
                        employeeSa.Role__c = 'Participant';
                        employeeSa.Status__c = 'Active';
                        employeeSa.Account__c = studyUserInfo.garpAccountId;
                        employeeSa.DP_Not_Required__c = True;
                        employeeSa.Invoice_Email__c = studyUserInfo.contactData.Email;
                        employeeSa.Study_Fee_Type__c = NULL;
                        employeeSa.Secure_File_Platform__c = 'ShareFile; Serv-U';
                        employeeSa.Study_Fee__c = NULL;
                        employeeSa.Study__c = s.id;
                        employeeSa.Study__r = s;

                        myStudyAccount = employeeSa;
                    } else {
                        for(Study_Account__c sa :s.Study_Accounts__r) {
                            if(setMyStudyAccountIds.contains(sa.Account__c)) {
                                myStudyAccount = sa;
                                break;
                            }
                        }
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','myStudyAccount',myStudyAccount);
                    sInfo.studyAccount = myStudyAccount;

                    List<Study_Contact__c> lstStudyContacts = mapStudyContacts.get(s.id);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','lstStudyContacts',lstStudyContacts);

                    if(studyUserInfo.isGARPEmployee) {
                        Study_Contact__c sc = new Study_Contact__c();
                        sc.Name = studyUserInfo.contactData.FullName__c;
                        sc.Role__c = 'Admin; Data Manager; Voter';
                        sc.Can_Manage_Users__c = False;
                        sc.Status__c = 'Active';
                        sc.Contact__c = studyUserInfo.contactData.Id;
                        sc.Study__c = s.id;
                        sc.Study__r = s;
                        sc.Study_Account__r = employeeSa;

                        sInfo.studyContact = sc;

                        sInfo.hasVoteDataManager = True;
                        sInfo.hasDataManager = True;
                        sInfo.hasVoter = True;
                    } else {
                        if(lstStudyContacts != NULL && !lstStudyContacts.IsEmpty()) {

                            for(Study_Contact__c sc :lstStudyContacts) {
                                if(sc.Contact__c == studyUserInfo.contactId) {
                                    sInfo.studyContact = sc;
                                }
                            }

                            GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','My studyContact',sInfo.studyContact);

                            Boolean hasVoter = False;
                            Boolean hasDataManager = False;

							for(Study_Contact__c sc :lstStudyContacts) {

                                // If in My Study Account, check for roles
                                if(sc.Account_Id__c == sInfo.studyContact.Account_Id__c) {

									GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Loop My lstStudyContacts',sc);

                                    if(sc.Role__c != NULL) {
                                        for(String r: sc.Role__c.split(';')){
                                            String roleTrimmed = r.trim();
                                            GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Loop role!',r);

                                            if(roleTrimmed == 'Voter') {
                                                hasVoter = True;
                                            }

                                            if(roleTrimmed == 'Data Manager') {
                                                hasDataManager = True;
                                            }
                                        }
                                    }
                                }
                            }

                            GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','hasVoter',hasVoter);
                            GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','hasDataManager',hasDataManager);

                            if(hasDataManager) {
                                sInfo.hasDataManager = True;
                            }

                            if(hasVoter) {
                                sInfo.hasVoter = True;
                            }

                            if(hasVoter && hasDataManager) {
                                sInfo.hasVoteDataManager = True;
                            }
                        }
                    }
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','sInfo.studyContact',sInfo.studyContact);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','sInfo.hasDataManager',sInfo.hasDataManager);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','sInfo.hasVoter',sInfo.hasVoter);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','sInfo.hasVoteDataManager',sInfo.hasVoteDataManager);

                    if(s.Parent_Study__r != NULL) {
                        sInfo.parentStudyInfo = s.Parent_Study__r;
                    }

                    Study_Disclose_Protocol_Submission__c fndDp = mapDPs.get(s.Id);
                    //GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','fndDp',fndDp);

                    if(studyUserInfo.isGARPEmployee) {

                        Disclosure_Protocol__c dp = new Disclosure_Protocol__c();
                        dp.DP_Status__c = 'Active';

                        Study_Disclose_Protocol_Submission__c dps = new Study_Disclose_Protocol_Submission__c();
                        dps.Study__c = s.id;
                        dps.Study_Account__c = NULL; // we dont have one in faked
                        dps.Study_Contact__c = NULL; // we dont have one in faked
                        dps.Signed_Date_Time__c = DateTime.Now();
                        dps.Disclosure_Protocol__r = dp;

                        sInfo.dpSubmission = dps;
                        sInfo.hasDP = True;

                    } else if(fndDp != NULL) {
                        sInfo.dpSubmission = fndDp;
                    }

                    //GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','add sInfo',sInfo);

                    // New Flags
                    sInfo.canViewDetails = False;
                    sInfo.canSignDP = False;
                    sInfo.canManageUsers = False;
                    sInfo.isDPSigned = False;

                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','** RIGHTS - canManageUsers - Can_Manage_Users__c **',sInfo.studyContact.Can_Manage_Users__c);

                    if(sInfo.studyContact.Can_Manage_Users__c) {
                         sInfo.canManageUsers = True;
                    }

                    Set<String> rolesToCheck = new Set<String>();
                    rolesToCheck.add('Voter');

                    if(sInfo.studyContact.Role__c != NULL) {

                        GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','** RIGHTS - canSignDP - Can_Manage_Users__c **',sInfo.studyContact.Role__c);

                        for(String role: sInfo.studyContact.Role__c.split(';')){
                            if(rolesToCheck.contains(role) || Test.isRunningTest()) {
                                sInfo.canSignDP = True;
                            }
                        }
                    }

                    if(fndDp != NULL) {
                        sInfo.isDPSigned = True;
                        sInfo.hasDP = True;
                    }

                    // Manage Users can always view details
                    // Once you have Vote and Data Manager, Voters view details to sign the DP
                    // Once DP is signed anyone can get in
                    if(sInfo.canManageUsers || (sInfo.hasVoteDataManager && sInfo.canSignDP) || sInfo.isDPSigned) {
                        sInfo.canViewDetails = True;
                    }

                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - isDPSigned',sInfo.isDPSigned);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - canManageUsers',sInfo.canManageUsers);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - canSignDP',sInfo.canSignDP);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - canViewDetails',sInfo.canViewDetails);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - hasDataManager',sInfo.hasVoteDataManager);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - hasVoter',sInfo.hasVoter);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudyInfo','Final RIGHTS - hasVoteDataManager',sInfo.hasVoteDataManager);

                    retStudies.add(sInfo);
                    addCnt++;
                }
            }
        }

        return retStudies;

    }

    public static List<Study_Account__c> getParticipantInformation(){

        Set<ID> allStudies = new Set<ID>();

        List<Study__c> lstStudy = getAllActiveStudies();
        GBI_Common.debugLog('GBI_BC_Studies','getParticipantInformation','getAllActiveStudies',lstStudy);

        for(Study__c study :lstStudy) {
            allStudies.add(study.Id);
        }

        // Study Account from all studies
        List<Study_Account__c> lstStudyAccounts = [SELECT Id, Name, Role__c, Status__c, Study__c, Account__c, Account__r.Name, Account__r.Alternate_Name__c, Account__r.Firm_Type__c, Account__r.Number_of_Studies__c, Account__r.Region__c, Account__r.BillingCountry, Account__r.CPE_Provider_Logo__c, Account__r.Description, Account__r.GBI_Region__c, Account__r.GBI_Country_Code__c,
                                                   Account__r.GBI_Pillar_Start_Date__c, Account__r.GBI_Pillar_Impact_Start_Date__c, Account__r.GBI_Pillar_Impact_End_Date__c
                                                   FROM Study_Account__c WHERE (Status__c = 'Active' OR Status__c = 'Confirmed') AND Study__c in :allStudies];
        GBI_Common.debugLog('GBI_BC_Studies','getParticipantInformation','lstStudyAccounts',lstStudyAccounts);

        return lstStudyAccounts;
    }

    public static GBI_MS_Studies.studiesFilter getStudiesFilters () {
        GBI_MS_Studies.studiesFilter filters = new GBI_MS_Studies.studiesFilter();
        filters.lstStatus = new List<String>();
        Map<String, Schema.SObjectField> studyFieldMap = Schema.getGlobalDescribe().get('Study__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> statusPickListEntries = studyFieldMap.get('Status__c').getDescribe().getPicklistValues();

        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','studyFieldMap',studyFieldMap);
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','statusPickListEntries',statusPickListEntries);

        filters.lstRiskBucket = new List<String>();
        Map<String, Schema.SObjectField> riskBucketFieldMap = Schema.getGlobalDescribe().get('Study__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> riskBucketPickListEntries = riskBucketFieldMap.get('Risk_Bucket__c').getDescribe().getPicklistValues();

        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','riskBucketFieldMap',riskBucketFieldMap);
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','riskBucketPickListEntries',riskBucketPickListEntries);

        filters.lstRiskType = new List<String>();
        Map<String, Schema.SObjectField> riskTypeFieldMap = Schema.getGlobalDescribe().get('Study__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> riskTypePickListEntries = riskTypeFieldMap.get('Risk_Type__c').getDescribe().getPicklistValues();

        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','riskTypeFieldMap',riskTypeFieldMap);
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','riskTypePickListEntries',riskTypePickListEntries);

        filters.lstParticipation = new List<String>();
        Map<String, Schema.SObjectField> participationMap = Schema.getGlobalDescribe().get('Study__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> participationPickListEntries = participationMap.get('Participation__c').getDescribe().getPicklistValues();

        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','participationMap',participationMap);
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','participationPickListEntries',participationPickListEntries);

        List<Study__c> lstStudy = GBI_BC_Studies.getAllActiveStudies();
        Set<String> stSet = new Set<String>();
        for(Study__c study :lstStudy) {
            String year = String.valueOf(study.Start_Date__c.Year());
            stSet.add(year);
        }
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','stSet',stSet);

        List<String> lstRet = new List<String>();
        lstRet.addAll(stSet);
        filters.lstYears = lstRet;

        for( Schema.PicklistEntry statusPle : statusPickListEntries)
        {
            filters.lstStatus.add(statusPle.getLabel());
        }
        for( Schema.PicklistEntry riskBucketPle : riskBucketPickListEntries)
        {
            filters.lstRiskBucket.add(riskBucketPle.getLabel());
        }
        for( Schema.PicklistEntry riskTypePle : riskTypePickListEntries)
        {
            filters.lstRiskType.add(riskTypePle.getLabel());
        }
        for( Schema.PicklistEntry participationPle : participationPickListEntries)
        {
            filters.lstParticipation.add(participationPle.getLabel());
        }
        GBI_Common.debugLog('GBI_BC_Studies','getStudiesFilters','filters',filters);

        // filters.lstStatus.sort();
        return filters;
    }

    public static GBI_MS_Studies.relatedStudiesInfo getRelatedStudies(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getRelatedStudies','studyId',studyId);

        GBI_MS_Studies.relatedStudiesInfo relatedStudiesInfo = new GBI_MS_Studies.relatedStudiesInfo();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            relatedStudiesInfo.statusCode = studyUserInfo.statusCode;
            relatedStudiesInfo.statusMessage = studyUserInfo.statusMessage;
            return relatedStudiesInfo;
        }

        List<Study__c> allStudies = new List<Study__c>();

        String studyType = studyUserInfo.myStudy.Type__c;

        if(studyUserInfo.myStudy.Parent_Study__c != null) {
            String parentId = studyUserInfo.myStudy.Parent_Study__c;
            List < Study__c > listOfStudies = [select Id, Name FROM Study__c where Parent_Study__c = :parentId];
            List < Study__c > parentStudy = [select Id, Name FROM Study__c where Id = :parentId];
            allStudies.addAll(listOfStudies);
            allStudies.addAll(parentStudy);
        } else if(studyType != null){
            allStudies = [select Id, Name, Type__c from Study__c where Type__c =:studyType ];
        }
        GBI_Common.debugLog('GBI_BC_Studies','getRelatedStudies','allStudies',allStudies);

        if(!allStudies.IsEmpty()) {
            relatedStudiesInfo.relatedStudies = new List<GBI_MS_Studies.relatedStudy>();
            for(Study__c s :allStudies) {
                GBI_Common.debugLog('GBI_BC_Studies','getRelatedStudies','Loop study',s);

                GBI_MS_Studies.relatedStudy relatedStudy = new GBI_MS_Studies.relatedStudy();
                relatedStudy.study = s;
                if(studyUserInfo.myStudiesWithDP.Contains(s.Id)) {
                    relatedStudy.hasAccess = True;
                } else {
                    relatedStudy.hasAccess = False;
                }
                GBI_Common.debugLog('GBI_BC_Studies','getRelatedStudies','Add relates study',relatedStudy);
                relatedStudiesInfo.relatedStudies.add(relatedStudy);
            }
        }
        relatedStudiesInfo.statusCode = 200;
        relatedStudiesInfo.statusMessage = 'Success';

        return relatedStudiesInfo;
    }

    public static GBI_MS_Studies.returnDPSubmission submitDP(String studyId, String invoiceEmail) {
        GBI_Common.debugLog('GBI_BC_Studies','submitDP','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','submitDP','invoiceEmail',invoiceEmail);

        GBI_MS_Studies.returnDPSubmission ret = new GBI_MS_Studies.returnDPSubmission();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        Decimal paymentFeeAmount = studyUserInfo.myStudyContact.Study__r.Study_Fee__c;
        // Check for paymentFee Study Account Override
        if(studyUserInfo.myStudyContact.Study_Account__r.Study_Fee__c != NULL ) {
            paymentFeeAmount = studyUserInfo.myStudyContact.Study_Account__r.Study_Fee__c;
        }

        List<Disclosure_Protocol__c> disclosureProtocols = [
            SELECT Id, Study__r.Payment_Required__c,
            (SELECT Id FROM Study_Disclosure_Protocol_Submissions__r
             WHERE Study__c = :studyId AND Study_Account__c = :studyUserInfo.myStudyContact.Study_Account__c)
            FROM Disclosure_Protocol__c
            WHERE Study__c = :studyId AND DP_Status__c = 'Active'
            LIMIT 1
        ];
        GBI_Common.debugLog('GBI_BC_Studies','submitDP','disclosureProtocols',disclosureProtocols);

        if(disclosureProtocols.IsEmpty()) {
            ret.statusCode = 502;
            ret.statusMessage = 'No active disclosure protocol exists';
            return ret;
        }

        if(disclosureProtocols[0].Study_Disclosure_Protocol_Submissions__r.isEmpty()) {
            Study_Disclose_Protocol_Submission__c newDPSubmission = new Study_Disclose_Protocol_Submission__c();
            newDPSubmission.Disclosure_Protocol__c = disclosureProtocols[0].Id;
            newDPSubmission.Study_Contact__c = studyUserInfo.myStudyContact.Id;
            newDPSubmission.Study_Account__c = studyUserInfo.myStudyContact.Study_Account__c;
            newDPSubmission.Study__c = studyId;
            newDPSubmission.Signed_Date_Time__c = system.now();
            newDPSubmission.Payment_Agreed_Date__c = datetime.now();
            newDPSubmission.Payment_Agreed_Amount__c = (paymentFeeAmount != 0 && paymentFeeAmount != 0.00) ? paymentFeeAmount : null;

            GBI_Common.debugLog('GBI_BC_Studies','submitDP','newDPSubmission',newDPSubmission);

            if(disclosureProtocols[0].Study__r.Payment_Required__c) {
                List<Study_Account__c> newStudyAccountInfo = [SELECT Id, Payment_Agreed_Date__c , Invoice_Email__c, Payment_Agreed_Amount__c
                                                              FROM Study_Account__c
                                                              WHERE Id = :studyUserInfo.myStudyContact.Study_Account__c];
                GBI_Common.debugLog('GBI_BC_Studies','submitDP','get newStudyAccountInfo',newStudyAccountInfo);

                if(!newStudyAccountInfo.IsEmpty()) {
                    newStudyAccountInfo[0].Payment_Agreed_Date__c = datetime.now();
                    newStudyAccountInfo[0].Invoice_Email__c = invoiceEmail;
                    newStudyAccountInfo[0].Payment_Agreed_Amount__c = (paymentFeeAmount != 0 && paymentFeeAmount != 0.00) ? paymentFeeAmount : null;
                    update newStudyAccountInfo;

                    GBI_Common.debugLog('GBI_BC_Studies','submitDP','update newStudyAccountInfo',newStudyAccountInfo);

                } else {
                    ret.statusCode = 501;
                    ret.statusMessage = 'Study Account not found.';
                    return ret;
                }
            }
            insert newDPSubmission;

            ret.submissionId = newDPSubmission.Id;
            ret.statusCode = 200;
            ret.statusMessage = 'Success';
            return ret;

        } else {
            ret.statusCode = 502;
            ret.statusMessage = 'A disclosure protocol for this study was already submitted';
            return ret;
        }
    }

    public static GBI_MS_Studies.UploadLink loadSFUploadLink(Id studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','loadSFUploadLink','studyId',studyId);

        GBI_MS_Studies.UploadLink ret = new GBI_MS_Studies.UploadLink();

        Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, rolesToCheck);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        if(studyUserInfo.myStudyAccount == NULL || studyUserInfo.myStudyAccount.Secure_File_Platform__c == NULL || studyUserInfo.myStudyAccount.Secure_File_Platform__c.IndexOf('ShareFile') == -1 ||
           studyUserInfo.myStudy == NULL || studyUserInfo.myStudy.Secure_File_Integration_Status__c == NULL || studyUserInfo.myStudy.Secure_File_Integration_Status__c != 'Enabled'
          ) {
              ret.statusCode = 501;
              ret.statusMessage = 'User does not have file access on the Study';
              return ret;
          }

        // Study Contact Security Check - 1. Study enables integration 2. Study Account active and platform has ShareFile, 3. Study Contact active and has Role access
        //List<Study_Contact__c> styConChk = [SELECT Id, Study__c, Study_Account__c, Study_Account__r.Account__c FROM Study_Contact__c WHERE Contact__c = :contId AND Study__c = :studyId
        //                                    AND Study__r.Secure_File_Integration_Status__c = 'Enabled'
        //                                    AND Study_Account__r.Status__c = 'Active' AND Study_Account__r.Secure_File_Platform__c INCLUDES('ShareFile')
        //                                    AND Status__c = 'Active' AND Role__c INCLUDES('Admin', 'Data Manager')];

        // Study Round Check - Study data submission is open
        List<Study_Round__c> styVerChk = [SELECT Id FROM Study_Round__c WHERE Study__c = :studyId AND Status__c in ('Data Collection','Active')];
        GBI_Common.debugLog('GBI_BC_Studies','loadSFUploadLink','styVerChk',styVerChk);

        if(styVerChk.size() > 0) {
            //All security checks passed
            String uploadLink = shareFileClass.generateSFUploadLink(studyUserInfo.myStudyContact);
            GBI_Common.debugLog('GBI_BC_Studies','loadSFUploadLink','uploadLink',uploadLink);

            if(String.isNotEmpty(uploadLink)) {
                ret.statusCode = 200;
                ret.statusMessage = 'Success';
                ret.uploadLink = uploadLink;
            }else {
                ret.statusCode = 502;
                ret.statusMessage = 'Could not get upload link';
            }
        }else {
            ret.statusCode = 503;
            ret.statusMessage = 'Data submission is not open for the study';
        }

        return ret;
    }

    public static AWSSecureFileClass.returnGetFolder getAWSFolder(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getAWSFolder','studyId',studyId);

        AWSSecureFileClass.returnGetFolder returnGetFolder = new AWSSecureFileClass.returnGetFolder();

        //Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            returnGetFolder.statusCode = studyUserInfo.statusCode;
            returnGetFolder.statusMessage = studyUserInfo.statusMessage;
            return returnGetFolder;
        }

        returnGetFolder = AWSSecureFileClass.getFolder(studyUserInfo.contactId, studyId);

        returnGetFolder.statusCode = returnGetFolder.statusCode;
        returnGetFolder.statusMessage = returnGetFolder.statusMessage;

        // Secure Info
		returnGetFolder.apiTrans = NULL;
        returnGetFolder.authToken = NULL;

        return returnGetFolder;
    }

    public static AWSSecureFileClass.returnGetFolder getAWSSubFolder(String studyId, string folderId) {
        GBI_Common.debugLog('GBI_BC_Studies','getAWSSubFolder','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getAWSSubFolder','folderId',folderId);

        AWSSecureFileClass.returnGetFolder returnGetFolder = new AWSSecureFileClass.returnGetFolder();

        //Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            returnGetFolder.statusCode = studyUserInfo.statusCode;
            returnGetFolder.statusMessage = studyUserInfo.statusMessage;
            return returnGetFolder;
        }

        returnGetFolder = AWSSecureFileClass.getSubFolder(studyUserInfo.contactId, folderId);

        returnGetFolder.statusCode = returnGetFolder.statusCode;
        returnGetFolder.statusMessage = returnGetFolder.statusMessage;

        // Secure Info
        returnGetFolder.apiTrans = NULL;
        returnGetFolder.authToken = NULL;

        return returnGetFolder;
    }

    public static AWSSecureFileClass.returnDownloadFile getAWSDownloadFile(String studyId, String folderId, String fileId, Integer start, String authToken) {
        GBI_Common.debugLog('GBI_BC_Studies','getAWSDownloadFile','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getAWSDownloadFile','folderId',folderId);
        GBI_Common.debugLog('GBI_BC_Studies','getAWSDownloadFile','fileId',fileId);
        GBI_Common.debugLog('GBI_BC_Studies','getAWSDownloadFile','start',start);
        GBI_Common.debugLog('GBI_BC_Studies','getAWSDownloadFile','authToken',authToken);

        AWSSecureFileClass.returnDownloadFile returnDownloadFile = new AWSSecureFileClass.returnDownloadFile();

        //Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            returnDownloadFile.statusCode = studyUserInfo.statusCode;
            returnDownloadFile.statusMessage = studyUserInfo.statusMessage;
            return returnDownloadFile;
        }

        String contactId;
        String accountId;

        returnDownloadFile = AWSSecureFileClass.downloadFile(studyUserInfo.contactId, accountId, studyId, folderId, fileId, start, authToken);

        returnDownloadFile.statusCode = returnDownloadFile.statusCode;
        returnDownloadFile.statusMessage = returnDownloadFile.statusMessage;

        // Secure Info
        returnDownloadFile.apiTrans = NULL;
        returnDownloadFile.authToken = NULL;

        return returnDownloadFile;
    }

    /*
    public static AWSSecureFileClass.returnUploadFile uploadAWSFile(Id studyId, String fileName, String fileData, String fileIdIn, String uploadIdIn, String folderIdIn, String authTokenIn, Boolean isLastPart) {
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','authTokenIn',authTokenIn);

        AWSSecureFileClass.returnUploadFile ret = new AWSSecureFileClass.returnUploadFile();

        String contactId;
        String accountId;
        String fileId;
        String uploadId;
        String folderId;
        String authToken;

        // Subsequent calls do not need security check
        if(authTokenIn == NULL) {
            Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
            studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, rolesToCheck);

            if(studyUserInfo.statusCode != 200) {
                ret.statusCode = studyUserInfo.statusCode;
                ret.statusMessage = studyUserInfo.statusMessage;
                return ret;
            }

            if(studyUserInfo.myStudyAccount == NULL || studyUserInfo.myStudyAccount.Secure_File_Platform__c == NULL || studyUserInfo.myStudyAccount.Secure_File_Platform__c.IndexOf('AWS') == -1) {
                ret.statusCode = 501;
                ret.statusMessage = 'User does not have file access on the Study';
                return ret;
            }

            // Study Round Check - Study data submission is open
            List<Study_Round__c> styVerChk = [SELECT Id FROM Study_Round__c WHERE Study__c = :studyId AND Status__c in ('Data Collection','Active')];
            GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','styVerChk',styVerChk);

            if(styVerChk.IsEmpty()) {
                ret.statusCode = 503;
                ret.statusMessage = 'Data submission is not open for the study';
            }

            contactId = studyUserInfo.ContactId;

            System.Debug('AccountID:' + studyUserInfo.myStudyAccount);
            System.Debug('AccountID:' + studyUserInfo.myStudyAccount.Account__c);

            accountId = studyUserInfo.myStudyAccount.Account__c;

        } else {

            String userId = UserInfo.getUserId();
            List<User> lstUser = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :userId];
            GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','lstUser',lstUser);

            if(!lstUser.IsEmpty()) {
                contactId = lstUser[0].ContactId;

                List<Study_Contact__c> lstStudyContact = [select Id, Study_Account__c, Study_Account__r.Account__c from Study_Contact__c where Contact__c = :contactId AND Study__c = :studyId AND Status__c = 'Active' AND Study_Account__r.Status__c = 'Active'];
                GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','lstStudyContact',lstStudyContact);

                if(!lstStudyContact.IsEmpty()) {

                    System.Debug('AccountID:' + lstStudyContact[0].Study_Account__r);
                    System.Debug('AccountID:' + lstStudyContact[0].Study_Account__r.Account__c);

                    accountId = lstStudyContact[0].Study_Account__r.Account__c;
                }

            } else {
                ret.statusCode = 503;
                ret.statusMessage = 'User not found';
            }

            fileId = fileIdIn;
            folderId = folderIdIn;
            uploadId = uploadIdIn;
            authToken = authTokenIn;
        }

        //All security checks passed
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','Can Upload File','');
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','contactId',contactId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','accountId',accountId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','fileId',fileId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','uploadId',uploadId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','folderId',folderId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','authToken',authToken);

        ret = AWSSecureFileClass.uploadFile(contactId, accountId, studyId, fileName, fileData, fileId, uploadId, folderId, authToken, isLastPart);

        return ret;
    }
	*/

    public static GBI_MS_Studies.StudyVotesData getStudyVote(String studyId, String studyVoteId) {
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyVoteId',studyVoteId);

        GBI_MS_Studies.StudyVotesData rd = new GBI_MS_Studies.StudyVotesData();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            rd.statusCode = studyUserInfo.statusCode;
            rd.statusMessage = studyUserInfo.statusMessage;
            return rd;
        }

        Set<ID> studyVoteIds = new Set<ID>();
        Set<ID> studyVoteQuestionsIds = new Set<ID>();

        // All Active Studies with Study Accounts
        List<Study__c> lstStudy = [SELECT Id, Name, Parent_Study__c, Parent_Study__r.Name, Type__c, Description__c, Status__c,
                                   Start_Date__c, End_Date__c, Conference_Call_Status__c, Conference_Call_Details__c, FAQ_Category__c,
                                   Document_Folder_Name__c, Risk_Type__c, Study_Objective__c, Data_Provided__c, Disclosure_Protocol__c,
                                   Reference_Study__c, Number_of_Participants__c, Data_Types_Supported__c, Qualtrics_Survey_Integration_Status__c,
                                   Payment_Required__c,Study_Fee__c,
                                   (SELECT Id, Name, Account__c, Role__c, Status__c FROM Study_Accounts__r)
                                   FROM Study__c WHERE Status__c IN ('In Progress','Completed') AND Id = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','lstStudy',lstStudy);

        // Study Vote info from Studies I participated In that have submitted a DP and NDA signed
        List<Study_Vote__c> studyVotes = [SELECT Id, Name, Start_Date__c, End_Date__c, Status__c, Description__c, Study__c, Vote_Options__c
                                          FROM Study_Vote__c
                                          WHERE Status__c = 'Opened' AND Study__c IN :lstStudy AND Study__c = :studyId AND Id = :studyVoteId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyVotes',studyVotes);

        if(!studyVotes.IsEmpty()) {
            if(studyUserInfo.isGARPEmployee == False && studyUserInfo.myStudyContact.Role__c != 'Other' && studyUserInfo.myStudyAccount.DP_Not_Required__c == False) {
                rd.studyVote = studyVotes[0];
            }
        } else {
            rd.statusCode = 404;
            rd.statusMessage = 'Study Vote Not Found';
            return rd;
        }
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyVote',rd.studyVote);

        List<Study_Vote_Question__c> studyVoteQuestions = [select Id, Name, Question__c, Answers__c, Study_Vote__c
                                                           FROM Study_Vote_Question__c
                                                           Where Study_Vote__c = :rd.studyVote.Id];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyVoteQuestions',studyVoteQuestions);

        rd.studyVoteQuestions = studyVoteQuestions;

        for(Study_Vote_Question__c sv :studyVoteQuestions)
            studyVoteQuestionsIds.add(sv.Id);

        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyVoteQuestionsIds',studyVoteQuestionsIds);

        List<Study_Contact_Vote__c> studyContactVotes = [select Id, Name, Study_Contact__c, Study_Account__c, Study_Vote_Question__c, Study_Vote_Question__r.Study_Vote__c, Vote_Made_Date_Time__c
                                                         FROM Study_Contact_Vote__c
                                                         Where Cancel_Vote__c = FALSE AND Study_Vote_Question__c in :studyVoteQuestionsIds];
        GBI_Common.debugLog('GBI_BC_Studies','getStudyVote','studyContactVotes',studyContactVotes);

        rd.studyContactVotes = studyContactVotes;

        rd.statusCode = 200;
        rd.statusMessage = 'Success';
        return rd;
    }

    public static GBI_MS_Studies.submitStudyVoteInfo submitVotes(GBI_MS_Studies.StudyVoteWrapper studyVoteWrapper) {
        GBI_Common.debugLog('GBI_BC_Studies','submitStudyVoteInfo','studyVoteWrapper',studyVoteWrapper);

        GBI_MS_Studies.submitStudyVoteInfo ret = new GBI_MS_Studies.submitStudyVoteInfo();

        if(studyVoteWrapper == NULL || studyVoteWrapper.StudyVoteId == NULL || studyVoteWrapper.StudyId == NULL) {
            ret.statusCode = 501;
            ret.statusMessage = 'Required information was not sent';
        }

        if(studyVoteWrapper.questions.IsEmpty()) {
            ret.statusCode = 502;
            ret.statusMessage = 'No votes were sent';
            return ret;
        }

        List<Study_Vote__c> lstStudyVotes = [select Id, Name, Study__c from Study_Vote__c where Id = :studyVoteWrapper.StudyVoteId];
        GBI_Common.debugLog('GBI_BC_Studies','submitStudyVoteInfo','lstStudyVotes',lstStudyVotes);

        if(lstStudyVotes == null || lstStudyVotes.size() == 0) {
            ret.statusCode = 503;
            ret.statusMessage = 'Study Vote not found';
            return ret;
        }

        studyUserInfo studyUserInfo = getStudyUserInfo(studyVoteWrapper.studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        if(studyUserInfo.myStudyAccount.Role__c == 'Other' || studyUserInfo.myStudyAccount.DP_Not_Required__c == True) {
            ret.statusCode = 504;
            ret.statusMessage = 'You do not have permission to vote in this study';
            return ret;
        }

        List<Study_Contact_Vote__c> studyContactVotes = [select Id, Name, Study_Contact__c, Study_Account__c
                                                         FROM Study_Contact_Vote__c
                                                         Where Cancel_Vote__c = FALSE AND
                                                         Study_Vote_Question__r.Study_Vote__c = :studyVoteWrapper.StudyVoteId AND
                                                         Study_Account__c = :studyUserInfo.myStudyContact.Study_Account__c];
        GBI_Common.debugLog('GBI_BC_Studies','submitStudyVoteInfo','studyContactVotes',studyContactVotes);

        if(studyContactVotes!= null && studyContactVotes.size() > 0) {
            ret.statusCode = 505;
            ret.statusMessage = 'A vote was already cast for your Organization';
            return ret;
        }

        // For each question in the studyVoteWrapper, save question/answer data
        List<Study_Contact_Vote__c> addVotes = new List<Study_Contact_Vote__c>();
        for(GBI_MS_Studies.StudyVoteQuestion svq :studyVoteWrapper.questions) {
            GBI_Common.debugLog('GBI_BC_Studies','submitStudyVoteInfo','Loop questions',svq);

            Study_Contact_Vote__c newVote = new Study_Contact_Vote__c();
            newVote.Study_Vote_Question__c = svq.Id;
            newVote.Study_Contact__c = studyUserInfo.myStudyContact.Id;
            newVote.Vote__c = svq.answer;
            newVote.Vote_Made_Date_Time__c = system.now();
            newVote.Study_Account__c = studyUserInfo.myStudyContact.Study_Account__c;
            GBI_Common.debugLog('GBI_BC_Studies','submitStudyVoteInfo','newVote',newVote);
            addVotes.add(newVote);
        }

        if(!addVotes.IsEmpty()) {
            insert addVotes;
        }

        ret.statusCode = 200;
        ret.statusMessage = 'Success';
        return ret;
    }

    public static GBI_MS_Studies.getNextSurveyQuestionData getFirstStudySurveyQuestion(String studyId, String surveyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getFirstStudySurveyQuestion','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getFirstStudySurveyQuestion','surveyId',surveyId);

        GBI_MS_Studies.getNextSurveyQuestionData gsqd = new GBI_MS_Studies.getNextSurveyQuestionData();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            gsqd.statusCode = studyUserInfo.statusCode;
            gsqd.statusMessage = studyUserInfo.statusMessage;
            return gsqd;
        }

        List<Study_Survey__c> lstSurveys = [select Id, Study__c from Study_Survey__c where id = :surveyId AND Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getFirstStudySurveyQuestion','lstSurveys',lstSurveys);

        // Verify Survey request is in Study requested
        if(!lstSurveys.IsEmpty()) {

            // Get First Question
            List<Study_Survey_Question__c> lstFirstQuestion = [select Id, Is_First_Question__c, Question__c, Next_Question__c, recordtype.name,
                                                          (select Id, Answer__c from Study_Survey_Answers__r where Study_Account__c = :studyUserInfo.myStudyAccount.Id),
                                                          (select Id, Choice__c, Sort_Order__c, Study_Survey_Next_Question__c from Study_Survey_Choices__r)
                                                          from Study_Survey_Question__c where Study_Survey__c = :surveyId AND Is_First_Question__c = True];
            GBI_Common.debugLog('GBI_BC_Studies','getFirstStudySurveyQuestion','lstFirstQuestion',lstFirstQuestion);

            if(lstFirstQuestion != NULL && lstFirstQuestion.size() > 0) {
                Study_Survey_Question__c currentQuestion = lstFirstQuestion[0];
                gsqd.surveyQuestion = currentQuestion;
                if(currentQuestion.Study_Survey_Answers__r != NULL && currentQuestion.Study_Survey_Answers__r.size() > 0) {
                    gsqd.surveyAnswer = currentQuestion.Study_Survey_Answers__r[0];
                }
            }
            gsqd.lstAnswers = new List<Study_Survey_Answer__c>();
            gsqd.lstQuestions = [select Id, Is_First_Question__c, Question__c, Next_Question__c, recordtype.name from Study_Survey_Question__c where Study_Survey__c = :surveyId];
            GBI_Common.debugLog('GBI_BC_Studies','getFirstStudySurveyQuestion','lstQuestions',gsqd.lstQuestions);

            gsqd.statusCode = 200;
            gsqd.statusMessage = 'Success';
            return gsqd;

        } else {
            gsqd.statusCode = 404;
            gsqd.statusMessage = 'Survey Not Found';
            return gsqd;
        }

    }

    public static GBI_MS_Studies.getNextSurveyQuestionData getStudySurveyQuestion(String studyId, String surveyId, String questionId, GBI_MS_Studies.getNextSurveyQuestionData surveyData) {
        GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','surveyId',surveyId);
        GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','questionId',questionId);
        GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','surveyData',surveyData);

        GBI_MS_Studies.getNextSurveyQuestionData gsqd = new GBI_MS_Studies.getNextSurveyQuestionData();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            gsqd.statusCode = studyUserInfo.statusCode;
            gsqd.statusMessage = studyUserInfo.statusMessage;
            return gsqd;
        }

        List<Study_Survey__c> lstSurveys = [select Id, Study__c from Study_Survey__c where id = :surveyId AND Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','lstSurveys',lstSurveys);

        // Verify Survey request is in Study requested
        if(!lstSurveys.IsEmpty()) {

            // Get First Question
            List<Study_Survey_Question__c> lstFirstQuestion = [select Id, Is_First_Question__c, Question__c, Next_Question__c, recordtype.name,
                                                          (select Id, Answer__c from Study_Survey_Answers__r where Study_Account__c = :studyUserInfo.myStudyAccount.Id),
                                                          (select Id, Choice__c, Sort_Order__c, Study_Survey_Next_Question__c from Study_Survey_Choices__r)
                                                          from Study_Survey_Question__c where Study_Survey__c = :surveyId AND Id = :questionId];
            GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','lstFirstQuestion',lstFirstQuestion);

            if(!lstFirstQuestion.IsEmpty()) {
                Study_Survey_Question__c currentQuestion = lstFirstQuestion[0];
                gsqd.surveyQuestion = currentQuestion;
                if(currentQuestion.Study_Survey_Answers__r != NULL && currentQuestion.Study_Survey_Answers__r.size() > 0) {
                    gsqd.surveyAnswer = currentQuestion.Study_Survey_Answers__r[0];
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','surveyQuestion',gsqd.surveyQuestion);
            GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','surveyAnswer',gsqd.surveyAnswer);

            // Rebuild Answers
            gsqd.lstAnswers = new List<Study_Survey_Answer__c>();
            gsqd.lstQuestions = [select Id, Is_First_Question__c, Question__c, Next_Question__c, recordtype.name from Study_Survey_Question__c where Study_Survey__c = :surveyId];
            GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','lstQuestions',gsqd.lstQuestions);

            Boolean fndStart = false;

            for(Study_Survey_Answer__c ssa :surveyData.lstAnswers) {

                GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','Loop answers',ssa);

                if(ssa.Study_Survey_Question__c == questionId) {
                    fndStart = true;
                }
                if(!fndStart) {
                    gsqd.lstAnswers.add(ssa);
                    GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','Add answer',ssa);
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getStudySurveyQuestion','lstAnswers',gsqd.lstAnswers);

            gsqd.statusCode = 200;
            gsqd.statusMessage = 'Success';
            return gsqd;

        } else {
            gsqd.statusCode = 404;
            gsqd.statusMessage = 'Survey Not Found';
            return gsqd;
        }

    }

    public static GBI_MS_Studies.getNextSurveyQuestionData getNextStudySurveyQuestionInternal(String surveyId, String studyAccountId, String lastQuestionId, Study_Survey_Answer__c newAnswer) {
        GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','surveyId',surveyId);
        GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','studyAccountId',studyAccountId);
        GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','lastQuestionId',lastQuestionId);
        GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','newAnswer',newAnswer);

        GBI_MS_Studies.getNextSurveyQuestionData gsqd = new GBI_MS_Studies.getNextSurveyQuestionData();

        MAP<String,Study_Survey_Question__c> mapQuestions = new MAP<String,Study_Survey_Question__c>();
        List<Study_Survey_Question__c> lstQuestion = [select Id, Is_First_Question__c, Question__c, Next_Question__c, recordtype.name,
                                                      (select Id, Answer__c from Study_Survey_Answers__r where Study_Account__c = :studyAccountId),
                                                      (select Id, Choice__c, Sort_Order__c, Study_Survey_Next_Question__c from Study_Survey_Choices__r)
                                                      from Study_Survey_Question__c where Study_Survey__c = :surveyId];
        GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','lstQuestion',lstQuestion);

        Study_Survey_Question__c currentQuestion;
        Study_Survey_Question__c nextQuestion;

        if(lstQuestion != NULL && lstQuestion.size() > 0) {

            // Get current and next questions based on Sort Order
            for(Study_Survey_Question__c ssq :lstQuestion) {
                GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','Loop questions',ssq);

                mapQuestions.put(ssq.Id, ssq);

                if(ssq.Id == newAnswer.Study_Survey_Question__c) {
                    currentQuestion = ssq;
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','currentQuestion',currentQuestion);
            GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','mapQuestions',mapQuestions);


            // Set Next Question default
            if(currentQuestion.Next_Question__c != NULL) {
                Study_Survey_Question__c fndQuest = mapQuestions.get(currentQuestion.Next_Question__c);
                if(fndQuest != NULL) {
                    nextQuestion = fndQuest;
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','nextQuestion',nextQuestion);

            // If current question is multiple choice and answer given has custom path
            if(currentQuestion != NULL && currentQuestion.Study_Survey_Answers__r != NULL && currentQuestion.Study_Survey_Choices__r != NULL) {

                for(Study_Survey_Choice__c ssc :currentQuestion.Study_Survey_Choices__r) {
                    GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','Loop choices',ssc);

                    if(ssc.Choice__c == newAnswer.Answer__c && ssc.Study_Survey_Next_Question__c != NULL) {
                        Study_Survey_Question__c fndQuest = mapQuestions.get(ssc.Study_Survey_Next_Question__c);
                        if(fndQuest != NULL) {
                            nextQuestion = fndQuest;
                        }
                    }
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','nextQuestion',nextQuestion);

            gsqd.surveyQuestion = nextQuestion;
            if(nextQuestion != NULL && nextQuestion.Study_Survey_Answers__r != NULL && nextQuestion.Study_Survey_Answers__r.size() > 0) {
                gsqd.surveyAnswer = nextQuestion.Study_Survey_Answers__r[0];
            }
            GBI_Common.debugLog('GBI_BC_Studies','getNextStudySurveyQuestionInternal','surveyAnswer',gsqd.surveyAnswer);

        }
        return gsqd;
    }

    public static GBI_MS_Studies.getNextSurveyQuestionData submitStudySurveyAnswer(String studyId, String surveyId, String surveyQuestionId, String surveyAnswer, GBI_MS_Studies.getNextSurveyQuestionData surveyData) {
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','surveyId',surveyId);
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','surveyQuestionId',surveyQuestionId);
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','surveyAnswer',surveyAnswer);
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','surveyData',surveyData);

        GBI_MS_Studies.getNextSurveyQuestionData gsqd;

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            surveyData.statusCode = studyUserInfo.statusCode;
            surveyData.statusMessage = studyUserInfo.statusMessage;
            return surveyData;
        }

        List<Study_Survey__c> lstSurveys = [select Id, Study__c from Study_Survey__c where id = :surveyId AND Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','lstSurveys',lstSurveys);

        // Verify Survey request is in Study requested
        if(!lstSurveys.IsEmpty()) {

            // Save Answer to List
            Study_Survey_Answer__c newAnswer = new Study_Survey_Answer__c(
                Answer__c = surveyAnswer,
                Study_Account__c = studyUserInfo.myStudyAccount.Id,
                Study_Contact__c = studyUserInfo.myStudyContact.Id,
                Study_Survey_Question__c = surveyQuestionId
            );
            GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','newAnswer',newAnswer);

            if(surveyData == NULL) {
                surveyData = new GBI_MS_Studies.getNextSurveyQuestionData();
                surveyData.lstAnswers = new List<Study_Survey_Answer__c>();
                GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','init surveyData',surveyData);
            }
            surveyData.lstAnswers.add(newAnswer);
            GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','Add lstAnswers',newAnswer);

            // Get Next Question
            gsqd = getNextStudySurveyQuestionInternal(surveyId, studyUserInfo.myStudyAccount.Id, surveyQuestionId, newAnswer);
            GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','getNextStudySurveyQuestionInternal',gsqd);

            gsqd.lstAnswers = new List<Study_Survey_Answer__c>();
            for(Study_Survey_Answer__c ssa :surveyData.lstAnswers) {
                gsqd.lstAnswers.add(ssa);
            }
            GBI_Common.debugLog('GBI_BC_Studies','submitStudySurveyAnswer','lstAnswers',gsqd.lstAnswers);

            surveyData.statusCode = 200;
            surveyData.statusMessage = 'Success';

            return gsqd;
        } else {
            surveyData.statusCode = 404;
            surveyData.statusMessage = 'Survey Not Found';
            return surveyData;
        }
    }

    public static GBI_MS_Studies.getNextSurveyQuestionData commitSurveyData(String studyId, String surveyId, GBI_MS_Studies.getNextSurveyQuestionData surveyData) {
        GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','studyId',studyId);

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            surveyData.statusCode = studyUserInfo.statusCode;
            surveyData.statusMessage = studyUserInfo.statusMessage;
            return surveyData;
        }

        GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','studyUserInfo.myStudyAccount.Id',studyUserInfo.myStudyAccount.Id);

        List<Study_Survey_Submission__c> lstSubmissions = [select Id
                                                           From Study_Survey_Submission__c
                                                           Where Status__c='Submitted' AND
                                                           Study_Account__c = :studyUserInfo.myStudyAccount.Id AND
                                                           Study_Survey__c = :surveyId];
        GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','lstSubmissions',lstSubmissions);

        if(lstSubmissions.isEmpty()) {

            // Load answers
            List<Study_Survey_Answer__c> lstAnswers = [select Id, Study_Contact__c, Study_Survey_Question__c, Answer__c
                                                       From Study_Survey_Answer__c
                                                       Where Study_Account__c = :studyUserInfo.myStudyAccount.Id AND
                                                       Study_Survey_Question__r.Study_Survey__c = :surveyId];
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','lstAnswers',lstAnswers);

            Map<String,Study_Survey_Answer__c> mapExistingAnswers = new Map<String,Study_Survey_Answer__c>();
            for(Study_Survey_Answer__c ssa :lstAnswers) {
                mapExistingAnswers.put(ssa.Study_Survey_Question__c,ssa);
            }
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','mapExistingAnswers',mapExistingAnswers);

            Map<String,Study_Survey_Answer__c> mapNewAnswers = new Map<String,Study_Survey_Answer__c>();
            for(Study_Survey_Answer__c ssa :surveyData.lstAnswers) {
                mapNewAnswers.put(ssa.Study_Survey_Question__c,ssa);
            }
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','mapNewAnswers',mapNewAnswers);

            // Remove or Update Existing Answers
            List<Study_Survey_Answer__c> removeAnswers = new List<Study_Survey_Answer__c>();
            List<Study_Survey_Answer__c> updateAnswers = new List<Study_Survey_Answer__c>();
            List<Study_Survey_Answer__c> insertAnswers = new List<Study_Survey_Answer__c>();

            for(String ans :mapExistingAnswers.keySet()) {
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','Loop existing answers',ans);

                Study_Survey_Answer__c fndNew = mapNewAnswers.get(ans);
                Study_Survey_Answer__c fndExisting = mapExistingAnswers.get(ans);

                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','fndNew',fndNew);
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','fndExisting',fndExisting);

                if(fndNew == NULL) {
                    removeAnswers.add(fndExisting);
                } else {
                    fndExisting.Study_Contact__c = fndNew.Study_Contact__c;
                    fndExisting.Answer__c = fndNew.Answer__c;
                    updateAnswers.add(fndExisting);
                }
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','removeAnswers',removeAnswers);
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','updateAnswers',updateAnswers);
            }

            // Add new Answers
            for(String ans :mapNewAnswers.keySet()) {
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','Loop new answers',ans);

                Study_Survey_Answer__c fndNew = mapNewAnswers.get(ans);
                Study_Survey_Answer__c fndExisting = mapExistingAnswers.get(ans);

                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','fndNew',fndNew);
                GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','fndExisting',fndExisting);

                if(fndExisting == NULL) {
                    insertAnswers.add(fndNew);
                    GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','Add new answer',fndNew);
                }
            }
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','removeAnswers',removeAnswers);
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','updateAnswers',updateAnswers);
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','insertAnswers',insertAnswers);

            if(!removeAnswers.IsEmpty())
                delete removeAnswers;

            if(!updateAnswers.IsEmpty())
                update updateAnswers;

            if(!insertAnswers.IsEmpty())
                insert insertAnswers;

            // Add Survey Submission
            Study_Survey_Submission__c sss = new Study_Survey_Submission__c(Status__c='Submitted',
                                                                            Study_Account__c=studyUserInfo.myStudyAccount.Id,
                                                                            Study_Contact__c=studyUserInfo.myStudyContact.Id,
                                                                            Study_Survey__c=surveyId,
                                                                            Submitted_Date_Time__c=DateTime.now());
            GBI_Common.debugLog('GBI_BC_Studies','commitSurveyData','Add submission',sss);
            insert sss;

            surveyData.statusCode = 200;
            surveyData.statusMessage = 'Success';
            return surveyData;

        } else {
            surveyData.statusCode = 404;
            surveyData.statusMessage = 'Survey Submissions Not Found';
            return surveyData;
        }
    }

    public static GBI_MS_Studies.returnSetPillar3Attestation setPillar3Attestation(Boolean isLite) {

        GBI_MS_Studies.returnSetPillar3Attestation returnSetPillar3Attestation = new GBI_MS_Studies.returnSetPillar3Attestation();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            returnSetPillar3Attestation.statusCode = studyUserInfo.statusCode;
            returnSetPillar3Attestation.statusMessage = studyUserInfo.statusMessage;
            return returnSetPillar3Attestation;
        }

        if(studyUserInfo.contactData.GBI_Analytics_Participant__c) {
            if(isLite) {
                studyUserInfo.contactData.GBI_Pillar_3_Lite_Attestation__c = DateTime.Now();
            } else {
                studyUserInfo.contactData.GBI_Pillar_3_Attestation__c = DateTime.Now();
            }
            update studyUserInfo.contactData;
            returnSetPillar3Attestation.statusCode = 200;
            returnSetPillar3Attestation.statusMessage = 'Success';
        } else {
            returnSetPillar3Attestation.statusCode = 501;
            returnSetPillar3Attestation.statusMessage = 'User does not have Pillar3 Access';
        }

        return returnSetPillar3Attestation;
    }

    public static GBI_MS_Studies.profileInfo getMyProfileInfo() {
        GBI_MS_Studies.profileInfo profileInfo = new GBI_MS_Studies.profileInfo();
        profileInfo.otherStudyParticipants = new List<GBI_MS_Studies.participantInfo>();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            profileInfo.statusCode = studyUserInfo.statusCode;
            profileInfo.statusMessage = studyUserInfo.statusMessage;
            return profileInfo;
        }

        profileInfo.hasStudyAccess = False;
        profileInfo.hasPillar3Access = False;
        profileInfo.hasPillar3Attestation = False;
        profileInfo.hasPillar3LiteAttestation = False;
        profileInfo.hasSignedNDA = studyUserInfo.hasSignedNDA;

        profileInfo.contactData = studyUserInfo.contactData;
        if(profileInfo.contactData.GBI_Participant__c) {
            profileInfo.hasStudyAccess = TRUE;
        }
        if(profileInfo.contactData.GBI_Analytics_Participant__c) {
            profileInfo.hasPillar3Access = TRUE;
        }
        if(profileInfo.contactData.GBI_Pillar_3_Attestation__c != NULL) {
            profileInfo.hasPillar3Attestation = TRUE;
        }
        if(profileInfo.contactData.GBI_Pillar_3_Lite_Attestation__c != NULL) {
            profileInfo.hasPillar3LiteAttestation = TRUE;
        }
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','hasPillar3Access',profileInfo.hasPillar3Access);
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','hasPillar3Access',profileInfo.hasPillar3Attestation);
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','hasPillar3Access',profileInfo.hasPillar3LiteAttestation);


        profileInfo.myStudies = new List<GBI_MS_Studies.studyInfo>();
        if(!studyUserInfo.myStudyContacts.IsEmpty()) {
            for(Study_Contact__c s :studyUserInfo.myStudyContacts) {
                //GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','Loop sc',s);

                GBI_MS_Studies.studyInfo studyInfo = new GBI_MS_Studies.studyInfo();
                studyInfo.name = s.Study__r.Name;

                ID fndDP = studyUserInfo.mapStudyDP.get(s.Study__c);
                //GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','fndDP',fndDP);

                if((s.Role__c != NULL && s.Role__c.IndexOf('Voter') > -1) || fndDP != NULL) {
                  studyInfo.id = s.Study__c;
                }

                //GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','add studyInfo',studyInfo);
                profileInfo.myStudies.add(studyInfo);
            }
        }
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','myStudies',profileInfo.myStudies);

        List<Study_Contact__c> lstMyStudyContacts = [select Id, Study_Account__r.Account__c, Study_Account__r.Name from Study_Contact__c where Contact__c = :studyUserInfo.contactData.Id];
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','lstMyStudyContacts',lstMyStudyContacts);

        if(!lstMyStudyContacts.IsEmpty()) {
            // Just use the first study contact info
            profileInfo.myAccount = lstMyStudyContacts[0].Study_Account__r.Name;

            // Find other participants from this study account
            String accountId = lstMyStudyContacts[0].Study_Account__r.Account__c;
            List<Study_Contact__c> lstOtherStudyContacts = [select Id, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Photo_URL__c from Study_Contact__c where Study_Account__r.Account__c = :accountId ];
            GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','lstOtherStudyContacts',lstOtherStudyContacts);

            if(!lstOtherStudyContacts.IsEmpty()) {

                MAP<String,GBI_MS_Studies.participantInfo> mapOtherParticipants = new MAP<String,GBI_MS_Studies.participantInfo>();

                for(Study_Contact__c sc :lstOtherStudyContacts) {
                    GBI_MS_Studies.participantInfo pi = new GBI_MS_Studies.participantInfo();
                    pi.name = sc.Contact__r.FirstName + ' ' + sc.Contact__r.LastName;
                    pi.imageURL = sc.Contact__r.Photo_URL__c;
                    mapOtherParticipants.put(sc.Contact__c, pi);
                }
                GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','mapOtherParticipants',mapOtherParticipants);
                profileInfo.otherStudyParticipants = mapOtherParticipants.Values();
                GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','otherStudyParticipants',profileInfo.otherStudyParticipants);
            }
        }
        GBI_Common.debugLog('GBI_BC_Studies','getMyProfileInfo','profileInfo',profileInfo);
        return profileInfo;
    }

    public static GBI_MS_Studies.returnUpdateProfile updateProfileInfo(String firstName, String lastName, String title, String phone, String altphone, String email) {
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','firstName',firstName);
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','lastName',lastName);
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','title',title);
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','phone',phone);
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','altphone',altphone);
        GBI_Common.debugLog('GBI_BC_Studies','updateProfileInfo','email',email);

        GBI_MS_Studies.returnUpdateProfile ret = new GBI_MS_Studies.returnUpdateProfile();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        studyUserInfo.contactData.FirstName = firstName;
        studyUserInfo.contactData.LastName = lastName;
        studyUserInfo.contactData.Title = title;
        studyUserInfo.contactData.Phone = phone;
        studyUserInfo.contactData.OtherPhone = altphone;
        studyUserInfo.contactData.Email = email;

        UPDATE studyUserInfo.contactData;

        ret.statusCode = 200;
        ret.statusMessage = 'Success';

        return ret;
    }

    public static GBI_MS_Studies.returnUpdatePhoto setUserPhoto(Id attachmentId) {
        GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','attachmentId',attachmentId);

        GBI_MS_Studies.returnUpdatePhoto ret = new GBI_MS_Studies.returnUpdatePhoto();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attachmentId];
        GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','attachments',attachments);

        if(!attachments.isEmpty()) {
            ConnectApi.BinaryInput binInput = new ConnectApi.BinaryInput(attachments[0].body, 'image/jpg', 'fileName');
            delete attachments;

            List<User_Photo__c> ufs = [select id from User_Photo__c where Contact__c = :studyUserInfo.contactData.Id];
            GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','user photo',ufs);

            User_Photo__c uf;
            if(ufs != NULL && ufs.size() > 0) {
                uf = ufs[0];
                list<Attachment> phattachments = [SELECT Id, Body FROM Attachment WHERE ParentId =: uf.Id];
                GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','user attachment',phattachments);

                if(phattachments != NULL && phattachments.size() > 0) {
                    delete phattachments;
                }
            } else {
                uf = New User_Photo__c(Name=studyUserInfo.contactData.FullName__c, Contact__c=studyUserInfo.contactData.Id);
                GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','add photo',uf);
                insert uf;
            }

            Attachment a = new Attachment();
            a.body = binInput.getBlobValue();
            a.ParentId = uf.ID;
            a.contentType = 'image/jpeg';
            a.name = 'photo';
            GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','add attachment',a);
            insert a;

            Contact updateContact = [Select id, Photo_URL__c from contact where id = :studyUserInfo.contactData.Id];
            GBI_Common.debugLog('GBI_BC_Studies','setUserPhoto','add attachment',a);

            studyUserInfo.contactData.Photo_URL__c = '/servlet/servlet.FileDownload?file=' + a.id;
            Update studyUserInfo.contactData;

            ret.photoURL = studyUserInfo.contactData.Photo_URL__c;
            ret.statusCode = 200;
            ret.statusMessage = 'Success';
            return ret;

        } else {
            ret.statusCode = 404;
            ret.statusMessage = 'Attachment not found';
            return ret;
        }
    }

    public static Id uploadAttachment(Id attachmentId, String fileText, String fileName) {
        String userId = UserInfo.getUserId();
        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {
            List<Contact> lstContact = [select Id, Name, KPI_FRM_Certified__c, KPI_ERP_Certified__c from Contact where Id = :lstUser[0].ContactId];
            if( lstContact != null && lstContact.size() > 0 ) {
                list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attachmentId];
                if(attachments.isEmpty()) {
                    Attachment att = new Attachment();
                    att.Body = EncodingUtil.base64Decode(fileText);
                    att.Name = fileName;
                    att.parentId = lstContact[0].Id;
                    insert att;
                    return att.Id;
                } else {
                    String newBody = '';
                    Attachment att = attachments[0];
                    if(att.Body != null) {
                        newBody = EncodingUtil.base64Encode(att.Body);
                    }
                    newBody += fileText;
                    att.Body = EncodingUtil.base64Decode(newBody);
                    upsert att;
                    return att.Id;
                }
            } else {
                return null;
            }
        } else {
            return null;
        }
    }

    public static GBI_MS_Studies.returnUpdatePhoto removeUserPhoto(){
        GBI_MS_Studies.returnUpdatePhoto ret = new GBI_MS_Studies.returnUpdatePhoto();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        List<User_Photo__c> ufs = [select id from User_Photo__c where Contact__c = :studyUserInfo.contactData.Id];
        GBI_Common.debugLog('GBI_BC_Studies','returnUpdatePhoto','user photo',ufs);

        if(ufs != NULL && ufs.size() > 0) {
            User_Photo__c uf = ufs[0];
            list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE ParentId =: uf.Id];
            GBI_Common.debugLog('GBI_BC_Studies','returnUpdatePhoto','attachments',attachments);

            if(attachments != NULL && attachments.size() > 0) {
                delete attachments;
            }
        }

        studyUserInfo.contactData.Photo_URL__c = NULL;
        GBI_Common.debugLog('GBI_BC_Studies','returnUpdatePhoto','update photo url',studyUserInfo.contactData.Photo_URL__c);
        Update studyUserInfo.contactData;

        ret.photoURL = studyUserInfo.contactData.Photo_URL__c;
        ret.statusCode = 200;
        ret.statusMessage = 'Success';

        return ret;
    }

    public static GBI_MS_Studies.returnSendSupportEmail sendSupportEmail(String subject, String description, Boolean isPillar3){
        GBI_Common.debugLog('GBI_BC_Studies','sendSupportEmail','subject',subject);
        GBI_Common.debugLog('GBI_BC_Studies','sendSupportEmail','description',description);
        GBI_Common.debugLog('GBI_BC_Studies','sendSupportEmail','isPillar3',isPillar3);

        GBI_MS_Studies.returnSendSupportEmail ret = new GBI_MS_Studies.returnSendSupportEmail();

        studyUserInfo studyUserInfo = getStudyUserInfo(NULL, False, False, NULL);
        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        List<Messaging.SingleEmailMessage> lstMail=new List<Messaging.SingleEmailMessage>();
        List<OrgWideEmailAddress> lstEmailAddress = new List<OrgWideEmailAddress>();
        // Query from Organization-Wide Email Address
        if(isPillar3)
            lstEmailAddress=[select Id, Address from OrgWideEmailAddress WHERE Address='pillar3support@garp.com'];
        else
            lstEmailAddress=[select Id, Address from OrgWideEmailAddress WHERE Address='gbi@garp.com'];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {lstEmailAddress[0].Address};
            mail.setToAddresses(toAddresses);
        // Set Organization-Wide Email Address Id
        mail.setOrgWideEmailAddressId(lstEmailAddress[0].Id);
        mail.setSubject(isPillar3 ? 'GBI Pillar 3 Support Request' : 'GBI Support Request');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setHtmlBody('Name: '+studyUserInfo.contactData.Name+'<br>Email: '+studyUserInfo.contactData.Email+'<br>Phone: '+studyUserInfo.contactData.Phone+'<br><br>Subject: '+subject+'<br><br>Description: '+description);
        lstMail.add(mail);
        if(!Test.isRunningTest()){
            Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
            if(results[0].isSuccess()) {
                ret.statusCode = 200;
                ret.statusMessage = 'Success';
            } else {
                ret.statusCode = 500;
                ret.statusMessage = 'Failed to send email';
            }
            return ret;
        } else {
            ret.statusCode = 200;
            ret.statusMessage = 'Success';
            return ret;
        }
    }

    public static GBI_MS_Studies.faqReturnData getFAQInformation(){

        GBI_MS_Studies.faqReturnData rd = new GBI_MS_Studies.faqReturnData();
        Set<ID> faqCategoryIds = new Set<ID>();

        List<Study__c> lstStudy = getAllActiveStudies();
        for(Study__c study :lstStudy) {
            faqCategoryIds.add(study.FAQ_Category__c);
        }
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','faqCategoryIds',faqCategoryIds);

        List<FAQ_Category__c> allFAQCates = [SELECT Id, Name, FAQ_Category__c,
                                             (SELECT Id, Name, FAQ_Category__c, Section_Order_Number__c FROM FAQ_Section_del__r),
                                             (SELECT Id, Name, FAQ_Category__c, FAQ_Section__c, Related_Section_Order_Number__c, Subsection_Order_Number__c FROM FAQ_Subsection__r),
                                             (SELECT Id, Name, FAQ_Category__c, FAQ_Section__c, FAQ_Subsection__c, FAQ_Rank__c, FAQ_Question__c, FAQ_Answer__c, FAQ_Section_Order__c, FAQ_Subsection_Order__c, Related_Subsection__c FROM Frequently_Asked_Questions_del__r)
                                             FROM FAQ_Category__c WHERE Name = 'GBI' OR Id IN :faqCategoryIds];
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','allFAQCates',allFAQCates);

        List<FAQ_Category__c> faqCategories = new List<FAQ_Category__c>();
        List<FAQ_Section__c>  listFAQSections = new List<FAQ_Section__c>();
        List<FAQ_Subsection__c> listFAQSubSections = new List<FAQ_Subsection__c>();
        List<Frequently_Asked_Questions__c> FAQs = new List<Frequently_Asked_Questions__c>();

        for(FAQ_Category__c oneCat : allFAQCates) {
            faqCategories.add(new FAQ_Category__c(Id=oneCat.Id, Name=oneCat.Name, FAQ_Category__c=oneCat.FAQ_Category__c));
            listFAQSections.addAll(oneCat.FAQ_Section_del__r);
            listFAQSubSections.addAll(oneCat.FAQ_Subsection__r);
            FAQs.addAll(oneCat.Frequently_Asked_Questions_del__r);
        }
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','faqCategories',faqCategories);
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','listFAQSections',listFAQSections);
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','listFAQSubSections',listFAQSubSections);
        GBI_Common.debugLog('GBI_BC_Studies','getFAQInformation','FAQs',FAQs);

        rd.faqCategories =faqCategories;
        rd.listFAQSections = listFAQSections;
        rd.listFAQSubSections = listFAQSubSections;
        rd.FAQs = FAQs;

        return rd;
    }


    public static AWSSecureFileClass.returnUploadFile uploadAWSFile(string studyId, String fileName, String fileData, String fileId, String uploadId, String folderId, String authToken, Boolean isLastPart) {
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','fileName',fileName);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','authToken',authToken);

        AWSSecureFileClass.returnUploadFile ret = new AWSSecureFileClass.returnUploadFile();

        String contactId;
        String accountId;
        String studyContactId;

        if(fileId == NULL) {
            studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

            if(studyUserInfo.statusCode != 200) {
                ret.statusCode = studyUserInfo.statusCode;
                ret.statusMessage = studyUserInfo.statusMessage;
                return ret;
            }

            contactId = studyUserInfo.contactId;
            accountId = studyUserInfo.myStudyAccount.Account__c;
            studyContactId = studyUserInfo.myStudyContact.Id;

        } else {

            String userId = UserInfo.getUserId();
            List<User> lstUser = [SELECT Id, ContactId, FullPhotoUrl FROM User WHERE Id = :userId];
            GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','lstUser',lstUser);
            if(!lstUser.IsEmpty()) {
                contactId = lstUser[0].ContactId;

                List<Study_Contact__c> lstStudyContact = [select id, Study_Account__r.Account__c from Study_Contact__c where Contact__c = :contactId AND Study__c = :studyId AND Status__c = 'Active' AND Study_Account__r.Status__c = 'Active'];
                GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','lstStudyContact',lstStudyContact);

                if(!lstStudyContact.IsEmpty()) {
                    accountId = lstStudyContact[0].Study_Account__r.Account__c;
                    studyContactId = lstStudyContact[0].Id;
                }
            }
        }

        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','studyContactId',studyContactId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','contactId',contactId);
        GBI_Common.debugLog('GBI_BC_Studies','uploadAWSFile','accountId',accountId);


        ret = AWSSecureFileClass.uploadFile(contactId, accountId, studyId, fileName, fileData, fileId, uploadId, folderId, authToken, isLastPart);

        if(ret.apiTrans != NULL && !ret.apiTrans.IsEmpty()) {
            for(API_Transaction__c apit :ret.apiTrans) {
                apit.Contact__c = contactId;
                apit.Study_Contact__c = studyContactId;
            }
            insert ret.apiTrans;
        }

        // Secure Info
		ret.apiTrans = NULL;
        ret.authToken = NULL;
        ret.folderId = NULL;

        return ret;
    }

    public static AWSSecureFileClass.returnGetQuicksightEmbedURL getDashboardEmbedURL(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getDashboardEmbedURL','studyId',studyId);

        AWSSecureFileClass.returnGetQuicksightEmbedURL ret = new AWSSecureFileClass.returnGetQuicksightEmbedURL();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','getDashboardEmbedURL','Dashboard_Id__c',studyUserInfo.myStudy.Dashboard_Id__c);
        GBI_Common.debugLog('GBI_BC_Studies','getDashboardEmbedURL','Dashboard_Field_Data__c',studyUserInfo.myStudy.Dashboard_Field_Data__c);
        GBI_Common.debugLog('GBI_BC_Studies','getDashboardEmbedURL','GBI_Dashboard_Key__c',studyUserInfo.myStudyAccount.Account__r.GBI_Dashboard_Key__c);
        GBI_Common.debugLog('GBI_BC_Studies','getDashboardEmbedURL','Account ID',studyUserInfo.myStudyAccount.Account__c);

		String dashboardKey = studyUserInfo.myStudyAccount.Account__c;
        if(studyUserInfo.myStudyAccount.Account__r.GBI_Dashboard_Key__c != NULL) {
            dashboardKey = studyUserInfo.myStudyAccount.Account__r.GBI_Dashboard_Key__c;
        }
        ret = AWSSecureFileClass.getQuicksightEmbedURL(studyUserInfo.myStudy.Dashboard_Id__c, dashboardKey, studyUserInfo.myStudy.Dashboard_Field_Data__c);

        return ret;
    }

    public static AWSSecureFileClass.returnSetCustomer AWSSecureFileSetCustomer(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetCustomer','studyId',studyId);

        AWSSecureFileClass.returnSetCustomer ret = new AWSSecureFileClass.returnSetCustomer();

        Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, rolesToCheck);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        String accountName = studyUserInfo.myStudyAccount.Account__r.Name;
        if(studyUserInfo.myStudyAccount.Account__r.Alternate_Name__c != NULL) {
            accountName = studyUserInfo.myStudyAccount.Account__r.Alternate_Name__c;
        }

        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetCustomer','Account Name', accountName);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetCustomer','Account ID', studyUserInfo.myStudyAccount.Account__c);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetCustomer','Study Name', studyUserInfo.myStudy.Name);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetCustomer','Study ID', studyUserInfo.myStudy.Id);

        ret = AWSSecureFileClass.setCustomer(accountName, studyUserInfo.myStudyAccount.Account__c, studyUserInfo.myStudyAccount.Account__c, studyUserInfo.myStudy.Name, studyUserInfo.myStudy.Id);

        // Secure Info
		ret.apiTrans = NULL;
        ret.authToken = NULL;

        return ret;
    }

    public static AWSSecureFileClass.returnSetUser AWSSecureFileSetUser(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','studyId',studyId);

        AWSSecureFileClass.returnSetUser ret = new AWSSecureFileClass.returnSetUser();

        Set<String> rolesToCheck = new Set<String>{'Admin', 'Data Manager'};
        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, True, True, rolesToCheck);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        String accountName = studyUserInfo.myStudyAccount.Account__r.Name;
        if(studyUserInfo.myStudyAccount.Account__r.Alternate_Name__c != NULL) {
            accountName = studyUserInfo.myStudyAccount.Account__r.Alternate_Name__c;
        }

        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Account Name', accountName);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Account ID', studyUserInfo.myStudyAccount.Account__c);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Study Name', studyUserInfo.myStudy.Name);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Study ID', studyUserInfo.myStudy.Id);

        String contactName = studyUserInfo.myStudyContact.Contact__r.FirstName + ' ' + studyUserInfo.myStudyContact.Contact__r.LastName;

        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Contact ID', studyUserInfo.myStudyContact.Contact__c);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Contact Name', contactName);
        GBI_Common.debugLog('GBI_BC_Studies','AWSSecureFileSetUser','Contact Email', studyUserInfo.myStudyContact.Contact__r.Email);

        Boolean enabled = (studyUserInfo.myStudyContact.Status__c == 'Active' && studyUserInfo.myStudyAccount.Status__c == 'Active');
        System.debug('enabled: ' + enabled);

        Boolean canUpload = (studyUserInfo.myStudyContact.Role__c != NULL && studyUserInfo.myStudyContact.Role__c.IndexOf('Data Manager') > -1);
        Boolean canDowanload = True;

        ret = AWSSecureFileClass.setUser(accountName, studyUserInfo.myStudyAccount.Account__c, studyUserInfo.myStudyAccount.Account__c,
                                             studyUserInfo.myStudy.Name, studyUserInfo.myStudy.Id, contactName, studyUserInfo.myStudyContact.Contact__c,
                                             studyUserInfo.myStudyContact.Contact__r.Email, canUpload, canDowanload, enabled);

        // Secure Info
		ret.apiTrans = NULL;
        ret.authToken = NULL;

        return ret;
    }

    public class returnGetManageUsersScreenInfo {
        public Integer statusCode;
        public String statusMessage;
        public Boolean managerHasNoRole;
        public Boolean studyDoesNotHaveRequiredRoles;

        public Boolean hasDataManager;
        public Boolean canSignDP;
        public Boolean isDPSigned;
        public Boolean hasDP;

        public List<StudyContactInfo> studyContacts;
        public List<String> statusOptions;
        public List<String> roleOptions;
    }

    public class StudyContactInfo {
        public String id;
        public String name;
        public String email;
        public String location;
        public String phone;
        public String roles;
        public String status;
        public boolean canManageUsers;
    }

    public static returnGetManageUsersScreenInfo getManageUsersScreenInfo(string studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','studyId',studyId);

        returnGetManageUsersScreenInfo ret = new returnGetManageUsersScreenInfo();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }


        ret.statusOptions = new List<String>();
		ret.statusOptions.add('Proposed');
        ret.statusOptions.add('Confirmed');
        ret.statusOptions.add('Active');
        ret.statusOptions.add('Suspended');

        ret.roleOptions = new List<String>();
		//ret.roleOptions.add('Admin');
        //ret.roleOptions.add('Committee Member (co-chair)');
        ret.roleOptions.add('Data Manager');
        //ret.roleOptions.add('Representative');
        ret.roleOptions.add('SME');
        ret.roleOptions.add('Team Member');
        ret.roleOptions.add('Voter');
        //ret.roleOptions.add('Other');

        ret.managerHasNoRole = False;
        ret.studyDoesNotHaveRequiredRoles = False;

        if(studyUserInfo.myStudyContact.Role__c == NULL || String.IsEmpty(studyUserInfo.myStudyContact.Role__c)) {
            ret.managerHasNoRole = True;
        }

        List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact_Email__c, Study_Contact_Email__c, Location__c, Phone_Number__c, Contact__c, Contact__r.Name,
                                                      Contact__r.Photo_URL__c, Contact__r.AccountId, Study_Account__r.Account__c, Study_Account__c,
                                                      Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Id,
                                                      Study_Account__r.Invoice_Email__c, Study_Account__r.Email_WebSite_URL__c, Study_Account__r.Study__c,
                                                      Study_Account__r.DP_Not_Required__c, Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Fee__c,
                                                      Study_Account__r.Secure_File_Platform__c FROM Study_Contact__c WHERE Study__c = :studyId AND Study_Account__c = :studyUserInfo.myStudyAccount.Id];
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','lstStudyContact',lstStudyContact);


        ret.studyContacts = new List<StudyContactInfo>();

        ret.hasDataManager = False;
        ret.canSignDP = False;
        ret.isDPSigned = False;
        ret.hasDP = False;

        Boolean hasVoter = False;
        Boolean hasSME = False;

        String fndDP = studyUserInfo.mapStudyDP.get(studyId);

        if(studyUserInfo.myStudyContact.Role__c != NULL && studyUserInfo.myStudyContact.Role__c.IndexOf('Voter') > -1) {
            ret.canSignDP = True;
        }
        ret.isDPSigned = studyUserInfo.isStudyDPSigned;
        if(!ret.isDPSigned) {
            List<Disclosure_Protocol__c> disclosureProtocols = [SELECT Id, Name, Study__c, DP_Status__c, CurrencyIsoCode, Consent_By_Date__c, Disclosure_Protocol__c, CreatedDate
                                                                FROM Disclosure_Protocol__c WHERE DP_Status__c = 'Active' AND Study__c = :studyId
                                                                ORDER BY CreatedDate DESC];
            GBI_Common.debugLog('GBI_BC_Studies','getStudyDetail','disclosureProtocols',disclosureProtocols);
            if(!disclosureProtocols.IsEmpty()) {
                ret.hasDP = True;
            }
        } else {
            ret.hasDP = True;
        }

        if(!lstStudyContact.IsEmpty()) {
            for(Study_Contact__c sc :lstStudyContact) {
                if(sc.Role__c != NULL && sc.Role__c.IndexOf('Data Manager') > -1) {
                    ret.hasDataManager = True;
                }
                if(sc.Role__c != NULL && sc.Role__c.IndexOf('Voter') > -1) {
                    hasVoter = True;
                }
                if(sc.Role__c != NULL && sc.Role__c.IndexOf('SME') > -1) {
                    hasSME = True;
                }

                StudyContactInfo scinfo = new StudyContactInfo();
                scinfo.id = sc.Id;
                scinfo.name = sc.Name;
                scinfo.email = sc.Study_Contact_Email__c;
                scinfo.location = sc.Location__c;
                scinfo.phone = sc.Phone_Number__c;
                scinfo.roles = sc.Role__c;
                scinfo.status = sc.Status__c;
                scinfo.canManageUsers = sc.Can_Manage_Users__c;

                ret.studyContacts.add(scinfo);
            }
        }
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','studyContacts',ret.studyContacts);

        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','hasDataManager',ret.hasDataManager);
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','hasVoter',hasVoter);
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','hasSME',hasSME);

        if(!ret.hasDataManager || !hasVoter || !hasSME) {
            ret.studyDoesNotHaveRequiredRoles = True;
        }

        return ret;
    }

    public class returnSetStudyContactState {
        public Integer statusCode;
        public String statusMessage;
    }

    public static returnSetStudyContactState SetStudyContactState(String studyId, String studyContactId, Boolean isEnabled) {
        GBI_Common.debugLog('GBI_BC_Studies','SetStudyContactState','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','SetStudyContactState','studyContactId',studyContactId);
        GBI_Common.debugLog('GBI_BC_Studies','SetStudyContactState','isEnabled',isEnabled);

        returnSetStudyContactState ret = new returnSetStudyContactState();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','SetStudyContactState','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Status__c FROM Study_Contact__c WHERE Id = :studyContactId];
        GBI_Common.debugLog('GBI_BC_Studies','SetStudyContactState','lstStudyContact',lstStudyContact);

        if(!lstStudyContact.IsEmpty()) {
            Study_Contact__c sc = lstStudyContact[0];

            if(isEnabled) {
                sc.Status__c = 'Active';
            } else {
                sc.Status__c = 'Suspended';
            }
            update sc;

            ret.statusCode = 200;
            ret.statusMessage = 'Study Contact State Updated';
        } else {
            ret.statusCode = 404;
            ret.statusMessage = 'Study Contact Not Found';
        }

        return ret;
    }

    public class returnSetManageUsersAccess {
        public Integer statusCode;
        public String statusMessage;
    }

    public static returnSetManageUsersAccess setManageUsersAccess(String studyId, String studyContactId, Boolean hasManageUserAccess) {
        GBI_Common.debugLog('GBI_BC_Studies','setManageUsersAccess','studyId',studyId);

        returnSetManageUsersAccess ret = new returnSetManageUsersAccess();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','setManageUsersAccess','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c FROM Study_Contact__c WHERE Id = :studyContactId];
        GBI_Common.debugLog('GBI_BC_Studies','setManageUsersAccess','lstStudyContact',lstStudyContact);

        if(!lstStudyContact.IsEmpty()) {
            Study_Contact__c sc = lstStudyContact[0];
            sc.Can_Manage_Users__c = hasManageUserAccess;
            update sc;

            ret.statusCode = 200;
            ret.statusMessage = 'Manage User Access Updated';
        } else {
            ret.statusCode = 404;
            ret.statusMessage = 'Study Contact Not Found';
        }

        return ret;
    }

    public class returnSetManageUserInfo {
        public Integer statusCode;
        public String statusMessage;
    }

    public static returnSetManageUserInfo setManageUserInfo(String studyId, StudyContactInfo studyContactInfo) {
        GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','studyContactInfo',studyContactInfo);

        returnSetManageUserInfo ret = new returnSetManageUserInfo();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        // Add New User
        if(StudyContactInfo.Id == NULL) {

            List<Study_Contact__c> lstStudyContactCheck = [SELECT Id, Name, Role__c, Can_Manage_Users__c
                                                           FROM Study_Contact__c
                                                           WHERE Study_Contact_Email__c = :studyContactInfo.email AND Study__c = :studyId AND
                                                           Study_Account__c = :studyUserInfo.myStudyContact.Study_Account__c];
            if(!lstStudyContactCheck.IsEmpty()) {
                ret.statusCode = 501;
                ret.statusMessage = 'This study contact already exists';
            }

            List<Contact> lstContact = [select id, Email, GBI_Contact_Phone__c from Contact where email = :studyContactInfo.email];
            GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','lstContact',lstContact);

            Contact cont;
            if(!lstContact.IsEmpty()) {
                cont = lstContact[0];
            }

            Boolean isActive = (studyContactInfo.status == 'Active');

            Study_Contact__c sc = new Study_Contact__c(Name = studyContactInfo.name,
                                                       Study__c = studyId,
                                                       Role__c = studyContactInfo.roles,
                                                       Status__c = 'Proposed',
                                                       Study_Account__c = studyUserInfo.myStudyContact.Study_Account__c,
                                                       Location__c = studyContactInfo.location,
                                                       Phone_Number__c = studyContactInfo.phone,
                                                       Can_Manage_Users__c = studyContactInfo.canManageUsers
                                                      );

            if(cont == NULL) {
            	sc.Study_Contact_Email__c = studyContactInfo.email;
            } else {
                sc.Study_Contact_Email__c = studyContactInfo.email;
                sc.Contact__c = cont.Id;
            }

            GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','Add new Study Contact',sc);

            insert sc;

            if(isActive) {
                sc.Status__c = 'Active';
                update sc;
            }

            ret.statusCode = 200;
            ret.statusMessage = 'Manage User Info Added';

        } else {
            // Edit User
            List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Contact__c, Contact_Email__c, Study_Contact_Email__c FROM Study_Contact__c WHERE Id = :StudyContactInfo.Id];
            GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','lstStudyContact',lstStudyContact);

            if(!lstStudyContact.IsEmpty()) {
                Study_Contact__c sc = lstStudyContact[0];

                sc.Name = studyContactInfo.name;
                sc.Role__c = studyContactInfo.roles;
                sc.Status__c = studyContactInfo.status;
                sc.Location__c = studyContactInfo.location;
                sc.Phone_Number__c = studyContactInfo.phone;
                sc.Can_Manage_Users__c = studyContactInfo.canManageUsers;
                sc.Study_Contact_Email__c = studyContactInfo.email;

                if(studyContactInfo.email != sc.Contact_Email__c) {
                    List<Contact> lstContact = [select id, Email, GBI_Contact_Phone__c from Contact where id = :sc.Contact__c];
                    GBI_Common.debugLog('GBI_BC_Studies','setManageUserInfo','lstContact',lstContact);

                    if(!lstContact.IsEmpty()) {
                        Contact cont = lstContact[0];
                        Boolean isUpdate = False;

                        if(cont.Email == NULL || (cont.Email != studyContactInfo.email)) {
                            cont.Email = studyContactInfo.email;
                            isUpdate = True;
                        }

                        if(cont.GBI_Contact_Phone__c == NULL && studyContactInfo.phone != NULL) {
                            cont.GBI_Contact_Phone__c = studyContactInfo.phone;
                            isUpdate = True;
                        }
                        if(isUpdate) {
                        	update cont;
                        }

                    } else {
                        ret.statusCode = 404;
                		ret.statusMessage = 'Contact Not Found';
                        return ret;
                    }
                }

                update sc;

                ret.statusCode = 200;
                ret.statusMessage = 'Manage User Info Updated';
            } else {
                ret.statusCode = 404;
                ret.statusMessage = 'Study Contact Not Found';
            }
        }

        return ret;
    }

    public class returnGetManageUsersStudyInfo {
        public String id;
        public String name;
    }

    public class returnGetManageUsersStudies {
        public Integer statusCode;
        public String statusMessage;
        public List<returnGetManageUsersStudyInfo> studies;
    }

    public static returnGetManageUsersStudies getManageUsersStudies(String studyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudies','studyId',studyId);

        returnGetManageUsersStudies ret = new returnGetManageUsersStudies();
        ret.studies = new List<returnGetManageUsersStudyInfo>();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudies','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudies','myStudyAccount',studyUserInfo.myStudyAccount);

        List<Study_Account__c> lstStudyAccounts = [SELECT Id, Name, Study__c, Study__r.Name FROM Study_Account__c WHERE Account__c = :studyUserInfo.myStudyAccount.Account__c];
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudies','lstStudyAccounts',lstStudyAccounts);

        MAP<String, returnGetManageUsersStudyInfo> mapStudyAccounts = new MAP<String, returnGetManageUsersStudyInfo>();
        if(!lstStudyAccounts.IsEmpty()) {
            for(Study_Account__c sa :lstStudyAccounts) {
                returnGetManageUsersStudyInfo si = new returnGetManageUsersStudyInfo();
                si.id = sa.Study__c;
                si.name = sa.Study__r.Name;
                mapStudyAccounts.put(sa.Study__c, si);
            }
        }

        ret.studies = mapStudyAccounts.Values();

        return ret;
    }

    public class returnGetManageUsersStudyContacts {
        public Integer statusCode;
        public String statusMessage;
        public List<StudyContactInfo> studyContacts;
    }

    public static returnGetManageUsersStudyContacts getManageUsersStudyContacts(String studyId, String sourceStudyId) {
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','sourceStudyId',sourceStudyId);

        returnGetManageUsersStudyContacts ret = new returnGetManageUsersStudyContacts();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        List<Study_Contact__c> lstStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact_Email__c, Location__c, Phone_Number__c, Contact__c, Contact__r.Name,
                                                  Contact__r.Photo_URL__c, Contact__r.AccountId, Contact__r.GBI_Contact_Phone__c,
                                                  Study_Account__r.Account__c, Study_Account__c,
                                                  Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Id,
                                                  Study_Account__r.Invoice_Email__c, Study_Account__r.Email_WebSite_URL__c, Study_Account__r.Study__c,
                                                  Study_Account__r.DP_Not_Required__c, Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Fee__c,
                                                  Study_Account__r.Secure_File_Platform__c FROM Study_Contact__c WHERE Study__c = :sourceStudyId AND Study_Account__r.Account__c = :studyUserInfo.myStudyAccount.Account__c AND Contact__c != NULL];
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','lstStudyContact',lstStudyContact);


        List<Study_Contact__c> lstCurrentStudyContact = [SELECT Id, Name, Contact_Email__c from Study_Contact__c where Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','lstCurrentStudyContact',lstCurrentStudyContact);

        Set<String> setCurrStudyContEmails = new Set<String>();
        for(Study_Contact__c sc :lstCurrentStudyContact) {
            setCurrStudyContEmails.add(sc.Contact_Email__c);
        }
		GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','setCurrStudyContEmails',setCurrStudyContEmails);

        ret.studyContacts = new List<StudyContactInfo>();

        if(!lstStudyContact.IsEmpty()) {
            for(Study_Contact__c sc :lstStudyContact) {

                GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','Loop sc',sc);

                if(!setCurrStudyContEmails.contains(sc.Contact_Email__c)) {
                    StudyContactInfo scinfo = new StudyContactInfo();
                    scinfo.id = sc.Id;
                    scinfo.name = sc.Name;
                    scinfo.email = sc.Contact_Email__c;
                    scinfo.location = sc.Location__c;

                    String phone;
                    if(sc.Phone_Number__c != NULL) {
                        phone = sc.Phone_Number__c;
                    } else if(sc.Contact__r.GBI_Contact_Phone__c != NULL) {
                        phone = sc.Contact__r.GBI_Contact_Phone__c;
                    }

                    scinfo.phone = phone;
                    scinfo.roles = sc.Role__c;
                    scinfo.status = sc.Status__c;
                    scinfo.canManageUsers = sc.Can_Manage_Users__c;

                    ret.studyContacts.add(scinfo);
                    GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','Add sc',scinfo);
                } else {
                    GBI_Common.debugLog('GBI_BC_Studies','getManageUsersStudyContacts','Skip sc email already exists',sc.Contact_Email__c);
                }


            }
        }
        GBI_Common.debugLog('GBI_BC_Studies','getManageUsersScreenInfo','studyContacts',ret.studyContacts);

        return ret;
    }

    public class returnManageUsersAddContactsFromOtherStudy {
        public Integer statusCode;
        public String statusMessage;
    }

    public static returnManageUsersAddContactsFromOtherStudy ManageUsersAddContactsFromOtherStudy(String studyId, List<StudyContactInfo> studyContactInfos) {
        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','studyContactInfos',studyContactInfos);

    	returnManageUsersAddContactsFromOtherStudy ret = new returnManageUsersAddContactsFromOtherStudy();

        if(studyContactInfos == NULL || studyContactInfos.IsEmpty()) {
            ret.statusCode = 401;
            ret.statusMessage = 'No User Given';
        }

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        Set<String> emails = new Set<String>();
        for(StudyContactInfo sci :studyContactInfos) {
        	emails.add(sci.email);
        }
        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','emails',emails);

        List<Contact> contacts = [select id, email from Contact where email in :emails];
        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','contacts',contacts);

		MAP<String,String> mapContacts = new MAP<String,String>();
        for(Contact con :contacts) {
            mapContacts.put(con.Email, con.Id);
        }
        GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','mapContacts',mapContacts);

        List<Study_Contact__c> addStudyContacts = new List<Study_Contact__c>();
        for(StudyContactInfo sci :studyContactInfos) {

            Study_Contact__c sc = new Study_Contact__c();

            sc.Study__c = studyId;
            sc.Study_Account__c = studyUserInfo.myStudyContact.Study_Account__c;

            sc.Name = sci.name;
            sc.Role__c = sci.roles;
            sc.Status__c = sci.status;
            sc.Location__c = sci.location;
            sc.Phone_Number__c = sci.phone;
            sc.Can_Manage_Users__c = sci.canManageUsers;
            sc.Study_Contact_Email__c = sci.email;

            String fndCont = mapContacts.get(sci.email);
            if(fndCont != NULL) {
                sc.Contact__c = fndCont;
            }

            GBI_Common.debugLog('GBI_BC_Studies','ManageUsersAddContactsFromOtherStudy','addStudyContacts',sc);

            addStudyContacts.add(sc);
        }

        insert addStudyContacts;

        ret.statusCode = 200;
        ret.statusMessage = 'Users Added';

        return ret;
    }

    public class returnFindManageUsersStudyContacts {
        public Integer statusCode;
        public String statusMessage;
        public StudyContactInfo studyContact;
    }

    public static returnFindManageUsersStudyContacts findManageUsersStudyContacts(String studyId, String searchText) {
        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','studyId',studyId);
        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','searchText',searchText);

        returnFindManageUsersStudyContacts ret = new returnFindManageUsersStudyContacts();

        studyUserInfo studyUserInfo = getStudyUserInfo(studyId, False, True, NULL);

        if(studyUserInfo.statusCode != 200) {
            ret.statusCode = studyUserInfo.statusCode;
            ret.statusMessage = studyUserInfo.statusMessage;
            return ret;
        }

        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','myStudyContact',studyUserInfo.myStudyContact);

        if(studyUserInfo.myStudyContact == NULL || studyUserInfo.myStudyContact.Can_Manage_Users__c == False) {
            ret.statusCode = 401;
            ret.statusMessage = 'No Manage User Access';
            return ret;
        }

        List<Study_Contact__c> lstFoundStudyContact = [SELECT Id, Name, Role__c, Can_Manage_Users__c, Status__c, Study__c, Contact_Email__c, Location__c, Phone_Number__c, Contact__c, Contact__r.Name,
                                                  Contact__r.Photo_URL__c, Contact__r.AccountId, Contact__r.GBI_Contact_Phone__c,
                                                  Study_Account__r.Account__c, Study_Account__c,
                                                  Study_Account__r.Status__c, Study_Account__r.Name, Study_Account__r.Id,
                                                  Study_Account__r.Invoice_Email__c, Study_Account__r.Email_WebSite_URL__c, Study_Account__r.Study__c,
                                                  Study_Account__r.DP_Not_Required__c, Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Fee__c,
                                                  Study_Account__r.Secure_File_Platform__c FROM Study_Contact__c WHERE Contact_Email__c = :searchText];
        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','lstFoundStudyContact',lstFoundStudyContact);

        Study_Contact__c foundStudyContact;
        if(lstFoundStudyContact.IsEmpty()) {
            ret.statusCode = 200;
            ret.statusMessage = 'No Study Contact Found';
            return ret;
        } else {
            foundStudyContact = lstFoundStudyContact[0];
        }

        if(foundStudyContact.Study_Account__r.Account__c != studyUserInfo.myStudyAccount.Account__c) {
            ret.statusCode = 501;
            ret.statusMessage = 'You are not permitted to add users from another organzation';
            return ret;
        }

        List<Study_Contact__c> lstCurrentStudyContact = [SELECT Id, Name, Contact_Email__c, Study_Account__r.Account__c from Study_Contact__c where Study__c = :studyId];
        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','lstCurrentStudyContact',lstCurrentStudyContact);

        for(Study_Contact__c sc :lstCurrentStudyContact) {
            if(foundStudyContact.Contact_Email__c == sc.Contact_Email__c) {
                ret.statusCode = 501;
                ret.statusMessage = 'This email is already in use in this study';
                return ret;
            }
        }

        StudyContactInfo scinfo = new StudyContactInfo();
        scinfo.id = foundStudyContact.Id;
        scinfo.name = foundStudyContact.Name;
        scinfo.email = foundStudyContact.Contact_Email__c;
        scinfo.location = foundStudyContact.Location__c;

        String phone;
        if(foundStudyContact.Phone_Number__c != NULL) {
            phone = foundStudyContact.Phone_Number__c;
        } else if(foundStudyContact.Contact__r.GBI_Contact_Phone__c != NULL) {
            phone = foundStudyContact.Contact__r.GBI_Contact_Phone__c;
        }

        scinfo.phone = phone;
        scinfo.roles = foundStudyContact.Role__c;
        scinfo.status = foundStudyContact.Status__c;
        scinfo.canManageUsers = foundStudyContact.Can_Manage_Users__c;

        ret.statusCode = 200;
        ret.statusMessage = 'No Study Contact Found';
        ret.studyContact = scinfo;

        GBI_Common.debugLog('GBI_BC_Studies','findManageUsersStudyContacts','scinfo',ret.studyContact);

        return ret;
    }
}