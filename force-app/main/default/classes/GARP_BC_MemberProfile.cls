public class GARP_BC_MemberProfile {

    // New Portal V2

    // Member Profile Page

    public class personalInfo {
        public String firstName;
        public String lastName;
        public String garpId;
        public String avatarPhoto;
        public String email;
        public String mobilePhoneCode;
        public String mobilePhone;
        public String billingAddressPhone;
        public String mailingAddressPhone;
        public GARP_Common.address billingAddress;
        public GARP_Common.address mailingAddress;
        public Boolean isBillingAndMailingAddressSame;
        public Boolean isAwaitingEmailChange;
    }


    public static personalInfo getPersonalInfo(User user, Contact contact) {
        personalInfo personalInfo = new personalInfo();

        personalInfo.firstName = contact.FirstName;
        personalInfo.lastName = contact.LastName;
        personalInfo.garpId = contact.GARP_Member_ID__c;
        personalInfo.avatarPhoto = contact.Photo_URL__c;
        personalInfo.email = contact.Email;

        String homePhone = contact.HomePhone;
        if(homePhone != NULL) {
            homePhone = homePhone.replaceAll(' ','');
            homePhone = homePhone.replaceAll('\\(','');
            homePhone = homePhone.replaceAll('\\)','');
            homePhone = homePhone.replaceAll('-','');
        }
        String phone = contact.Phone;
        if(phone != NULL) {
            phone = phone.replaceAll(' ','');
            phone = phone.replaceAll('\\(','');
            phone = phone.replaceAll('\\)','');
            phone = phone.replaceAll('-','');
        }

        personalInfo.mobilePhone = contact.MobilePhone;
        personalInfo.mobilePhoneCode = contact.Mobile_Phone_Code__c;

        personalInfo.mailingAddress = new GARP_Common.address();
        personalInfo.mailingAddress.company = contact.Mailing_Address_Company__c;
        personalInfo.mailingAddress.city = contact.MailingCity;
        personalInfo.mailingAddress.province = contact.MailingState;
        personalInfo.mailingAddress.postalCode = contact.MailingPostalCode;
        personalInfo.mailingAddress.country = contact.MailingCountry;
        personalInfo.mailingAddress.phone = homePhone;

        GARP_Common.address streets = GARP_Common.parseMultiAddressLine(contact.MailingStreet);
        personalInfo.mailingAddress.street1 = streets.street1;
        personalInfo.mailingAddress.street2 = streets.street2;
        personalInfo.mailingAddress.street3 = streets.street3;

        personalInfo.billingAddress = new GARP_Common.address();

        personalInfo.billingAddress.company = contact.Account.Billing_Address_Company__c;
        personalInfo.billingAddress.city = contact.Account.BillingCity;
        personalInfo.billingAddress.province = contact.Account.BillingState;
        personalInfo.billingAddress.postalCode = contact.Account.BillingPostalCode;
        personalInfo.billingAddress.country = contact.Account.BillingCountry;
        personalInfo.billingAddress.phone = phone;

        streets = GARP_Common.parseMultiAddressLine(contact.Account.BillingStreet);
        personalInfo.billingAddress.street1 = streets.street1;
        personalInfo.billingAddress.street2 = streets.street2;
        personalInfo.billingAddress.street3 = streets.street3;

        personalInfo.isBillingAndMailingAddressSame = False;
        if(GARP_Common.isAddressesTheSame(personalInfo.billingAddress, personalInfo.mailingAddress)) {
            personalInfo.isBillingAndMailingAddressSame = True;
        }
        
         if(user.Email != user.UserName) {
            personalInfo.isAwaitingEmailChange = true;    
        } else {
            personalInfo.isAwaitingEmailChange = false;
        }

        return personalInfo;
    }

    public static GARP_Common.returnInfo setPersonalInfo(Contact contact, personalInfo personalInfo) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','personalInfo',personalInfo);
        
        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        contact.FirstName = personalInfo.firstName;
        contact.LastName = personalInfo.lastName;
        contact.GARP_Member_ID__c = personalInfo.garpId;
        contact.Photo_URL__c = personalInfo.avatarPhoto;
        contact.Email = personalInfo.email;

        contact.MobilePhone = personalInfo.mobilePhone;
        contact.Mobile_Phone_Code__c = personalInfo.mobilePhoneCode;

        GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','contact update 1',contact);
        
        MAP<String,Country_Code__c> mapCC = GARP_Common.getCountriesMapByCountryName();
        
        GARP_Common.address shippingAddress = new GARP_Common.address();
        GARP_Common.address billingAddress = new GARP_Common.address();
        
        if(personalInfo.isBillingAndMailingAddressSame) {
            contact.Mailing_Address_Company__c = personalInfo.billingAddress.company;
            contact.MailingCity = personalInfo.billingAddress.city;
            contact.MailingState = personalInfo.billingAddress.province;
            contact.MailingPostalCode = personalInfo.billingAddress.postalCode;
            contact.MailingCountry = personalInfo.billingAddress.country;
            contact.MailingStreet = GARP_Common.formatAddressTextArea(personalInfo.billingAddress.street1, personalInfo.billingAddress.street2, personalInfo.billingAddress.street3);
            contact.HomePhone = personalInfo.billingAddress.phone;
            contact.Phone = personalInfo.billingAddress.phone;
            
            shippingAddress.street1 = personalInfo.billingAddress.street1;
            shippingAddress.street2 = personalInfo.billingAddress.street2;
            shippingAddress.street3 = personalInfo.billingAddress.street3;
            shippingAddress.city = personalInfo.billingAddress.city;
            shippingAddress.province = personalInfo.billingAddress.province;
            shippingAddress.postalCode = personalInfo.billingAddress.postalCode;
            shippingAddress.country = GARP_Common.getMappedCountryCode(mapCC, personalInfo.billingAddress.country);
            
        } else {
            contact.Mailing_Address_Company__c = personalInfo.mailingAddress.company;
            contact.MailingCity = personalInfo.mailingAddress.city;
            contact.MailingState = personalInfo.mailingAddress.province;
            contact.MailingPostalCode = personalInfo.mailingAddress.postalCode;
            contact.MailingCountry = personalInfo.mailingAddress.country;
            contact.MailingStreet = GARP_Common.formatAddressTextArea(personalInfo.mailingAddress.street1, personalInfo.mailingAddress.street2, personalInfo.mailingAddress.street3);
            contact.HomePhone = personalInfo.mailingAddress.phone;
            contact.Phone = personalInfo.billingAddress.phone;
            
            shippingAddress.street1 = personalInfo.mailingAddress.street1;
            shippingAddress.street2 = personalInfo.mailingAddress.street2;
            shippingAddress.street3 = personalInfo.mailingAddress.street3;
            shippingAddress.city = personalInfo.mailingAddress.city;
            shippingAddress.province = personalInfo.mailingAddress.province;
            shippingAddress.postalCode = personalInfo.mailingAddress.postalCode;
            shippingAddress.country = GARP_Common.getMappedCountryCode(mapCC, personalInfo.mailingAddress.country);

        }
        
        GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','shippingAddress',shippingAddress);

        List<Account> acct = [select Id, Billing_Address_Company__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where id = :contact.AccountId];
		Account account;
        
        if(!acct.IsEmpty()) {
            account = acct[0];
            account.Billing_Address_Company__c = personalInfo.billingAddress.company;
            account.BillingCity = personalInfo.billingAddress.city;
            account.BillingState = personalInfo.billingAddress.province;
            account.BillingPostalCode = personalInfo.billingAddress.postalCode;
            account.BillingCountry = personalInfo.billingAddress.country;
            account.BillingStreet = GARP_Common.formatAddressTextArea(personalInfo.billingAddress.street1, personalInfo.billingAddress.street2, personalInfo.billingAddress.street3);
            
            billingAddress.street1 = personalInfo.billingAddress.street1;
            billingAddress.street2 = personalInfo.billingAddress.street2;
            billingAddress.street3 = personalInfo.billingAddress.street3;
            billingAddress.city = personalInfo.billingAddress.city;
            billingAddress.province = personalInfo.billingAddress.province;
            billingAddress.postalCode = personalInfo.billingAddress.postalCode;
            billingAddress.country = GARP_Common.getMappedCountryCode(mapCC, personalInfo.billingAddress.country);
            
            GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','billingAddress',billingAddress);
            GARP_Common.debugLog('GARP_BC_MemberProfile','setPersonalInfo','updated contact',contact);
            
            // Update Stripe Customer Info
            GARP_StripeClass.updateCustomer(NULL, contact.Stripe_Customer_ID__c, contact.FirstName + ' ' + contact.LastName, contact.Email, contact.GARP_Member_ID__c, NULL, billingAddress, shippingAddress);

            update account;
            update contact;
        } else {
            ret.status = 'Failure';
        	ret.errorCode = 200;
        }

        ret.status = 'Success';
        ret.errorCode = 200;

        return ret;
    }

    public static GARP_Common.returnInfo uploadMemberPhoto(Contact contact, String attachmentId, String fileText, String fileName) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','uploadMemberPhoto','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','uploadMemberPhoto','attachmentId',attachmentId);
        GARP_Common.debugLog('GARP_BC_MemberProfile','uploadMemberPhoto','fileName',fileName);

        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        String newFileId = GARP_Common.uploadAttachmentToObject(attachmentId, fileText, fileName, contact.Id);
        if(newFileId != NULL) {
            ret.msg = newFileId;
            ret.status = 'Success';
            ret.errorCode = 200;
        } else {
            ret.msg = 'Attachment not found';
            ret.status = 'Failure';
            ret.errorCode = 501;
        }

        GARP_Common.debugLog('GARP_BC_MemberProfile','uploadMemberPhoto','ret',ret);
        return ret;
    }

    public static GARP_Common.returnInfo setMemberPhoto(Contact contact, String userId, String attachmentId) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','attachmentId',attachmentId);

        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attachmentId];
        GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','attachments',attachments);

        if(!attachments.isEmpty()) {
            ConnectApi.BinaryInput binInput = new ConnectApi.BinaryInput(attachments[0].body, 'image/jpg', 'fileName');
            delete attachments;

            // Replace Photo
            User usr = [Select id, Name, FullPhotoUrl, ContactId from User where id = :userId];
            GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','usr',usr);


            List<User_Photo__c> ufs = [select id from User_Photo__c where Contact__c = :usr.ContactId];
            GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','ufs',ufs);

            User_Photo__c uf;
            if(ufs != NULL && ufs.size() > 0) {
                uf = ufs[0];
                list<Attachment> phattachments = [SELECT Id, Body FROM Attachment WHERE ParentId =: uf.Id];
                GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','phattachments',phattachments);

                if(phattachments != NULL && phattachments.size() > 0) {
                    delete phattachments;
                }

            } else {
                uf = New User_Photo__c(Name=usr.Name, Contact__c=usr.ContactID);
                insert uf;
            }

            Attachment a = new Attachment();
            a.body = binInput.getBlobValue();
            a.ParentId = uf.ID;
            a.contentType = 'image/jpeg';
            a.name = 'photo';
            insert a;

            Contact updateContact = [Select id, Photo_URL__c from contact where id = :usr.ContactId];
            updateContact.Photo_URL__c = '/servlet/servlet.FileDownload?file=' + a.id;
            Update updateContact;

            GARP_Common.debugLog('GARP_BC_MemberProfile','setMemberPhoto','update contact',updateContact);

            ret.msg = updateContact.Photo_URL__c;
            ret.status = 'Success';
            ret.errorCode = 200;

        } else {
            ret.msg = 'Attachment not found';
            ret.status = 'Failure';
            ret.errorCode = 401;
        }


        return ret;
    }

    public static GARP_Common.returnInfo removeMemberPhoto(Contact contact) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','removeMemberPhoto','contact',contact);

        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        List<User_Photo__c> ufs = [select id from User_Photo__c where Contact__c = :contact.Id];
        GARP_Common.debugLog('GARP_BC_MemberProfile','removeMemberPhoto','ufs',ufs);

        if(ufs != NULL && ufs.size() > 0) {
            User_Photo__c uf = ufs[0];
            list<Attachment> attachments = [SELECT Id, Body FROM Attachment WHERE ParentId =: uf.Id];
            GARP_Common.debugLog('GARP_BC_MemberProfile','removeMemberPhoto','attachments',attachments);

            if(attachments != NULL && attachments.size() > 0) {
                delete attachments;
            }
        }

        Contact updateContact = [Select id, Photo_URL__c from contact where id = :contact.Id];
        GARP_Common.debugLog('GARP_BC_MemberProfile','removeMemberPhoto','updateContact',updateContact);

        updateContact.Photo_URL__c = NULL;
        Update updateContact;

        ret.status = 'Success';
        ret.errorCode = 200;

        GARP_Common.debugLog('GARP_BC_MemberProfile','removeMemberPhoto','ret',ret);
        return ret;
    }

    public class expertiseInfo {
        public String areaofExpertise;
        public String publishingExperience;
        public String teachingExperience;
        public String expertParticipation;
    }

    public static expertiseInfo getExpertiseInfo(Contact contact) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','contact',contact);

        expertiseInfo expertiseInfo = new expertiseInfo();

        expertiseInfo.areaofExpertise = '';
        expertiseInfo.publishingExperience = '';
        expertiseInfo.teachingExperience = '';
        expertiseInfo.expertParticipation = '';

        List<SME_Registration__c> lstSME = [select id, Self_Identification_Topic_Tags__c, Publishing_Experience__c, Teaching_Experience__c, Expert_Participation__c from SME_Registration__c where Contact__c = :contact.Id];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','lstSME',lstSME);

        if(!lstSME.isEmpty()) {
            expertiseInfo.areaofExpertise = lstSME[0].Self_Identification_Topic_Tags__c;
            expertiseInfo.publishingExperience = lstSME[0].Publishing_Experience__c;
            expertiseInfo.teachingExperience = lstSME[0].Teaching_Experience__c;
            expertiseInfo.expertParticipation = lstSME[0].Expert_Participation__c;
        }
        return expertiseInfo;
    }

    public static GARP_Common.returnInfo setExpertiseInfo(Contact contact, expertiseInfo expertiseInfo) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','expertiseInfo',expertiseInfo);

        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        List<SME_Registration__c> lstSME = [select id, Self_Identification_Topic_Tags__c, Publishing_Experience__c, Teaching_Experience__c, Expert_Participation__c from SME_Registration__c where Contact__c = :contact.Id];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','lstSME',lstSME);

        SME_Registration__c smeReg = new SME_Registration__c();
        if(!lstSME.isEmpty()) {
            smeReg = lstSME[0];
        }
        smeReg.Contact__c = contact.Id;
        smeReg.Self_Identification_Topic_Tags__c = expertiseInfo.areaofExpertise;
        smeReg.Publishing_Experience__c = expertiseInfo.publishingExperience;
        smeReg.Teaching_Experience__c = expertiseInfo.teachingExperience;
        smeReg.Expert_Participation__c = expertiseInfo.expertParticipation;

        upsert smeReg;

        ret.status = 'Success';
        ret.errorCode = 200;

        return ret;
    }

    // Update Profile Form
    public class demographicsContactInfo {
        public String workingStatus;
        public String industry;
        public String industryStartWorkingYear;
        public String company;
        public String professionalLevel;
        public String jobFunction;
        public String riskSpecialty;
        public String riskManagementStartWorkingYear;
        public Boolean smsPromotionalUpdates;
        public Boolean smsRegistrationUpdates;
        public Boolean professionalDesignationACCA;
        public Boolean professionalDesignationCA;
        public Boolean professionalDesignationCAIA;
        public Boolean professionalDesignationCFA;
        public Boolean professionalDesignationCFP;
        public Boolean professionalDesignationCIA;
        public Boolean professionalDesignationCMA;
        public Boolean professionalDesignationCMT;
        public Boolean professionalDesignationCPA;
        public Boolean professionalDesignationCQF;
        public Boolean professionalDesignationPMP;
        public Boolean professionalDesignationOther;
        public String professionalDesignationOtherQualifications;
        public String school;
        public String highestDegree;
        public String expectedGraduationYear;
        public String expectedGraduationMonth;
    }

    public static demographicsContactInfo getDemographicsContactInfo(Contact contact) {
        demographicsContactInfo demographicsContactInfo = new demographicsContactInfo();

        demographicsContactInfo.workingStatus = contact.Currently_Working_Status__c;
        demographicsContactInfo.industry = contact.Area_of_Concentration__c;
        demographicsContactInfo.industryStartWorkingYear = contact.Industry_Working_Year__c;
        demographicsContactInfo.company = contact.Company__c;
        demographicsContactInfo.professionalLevel = contact.Corporate_Title__c;
        demographicsContactInfo.jobFunction = contact.Job_Function__c;
        demographicsContactInfo.riskSpecialty = contact.Risk_Specialty__c;
        demographicsContactInfo.riskManagementStartWorkingYear = contact.Risk_Management_Working_Year__c;
        demographicsContactInfo.smsPromotionalUpdates = contact.SMS_Promotional_Updates__c;
        demographicsContactInfo.smsRegistrationUpdates = contact.SMS_Registration_Updates__c;
        demographicsContactInfo.professionalDesignationACCA = contact.Professional_Designation_ACCA__c;
        demographicsContactInfo.professionalDesignationCA = contact.Professional_Designation_CA__c;
        demographicsContactInfo.professionalDesignationCAIA = contact.Professional_Designation_CAIA__c;
        demographicsContactInfo.professionalDesignationCFA = contact.Professional_Designation_CFA__c;
        demographicsContactInfo.professionalDesignationCFP = contact.Professional_Designation_CFP__c;
        demographicsContactInfo.professionalDesignationCIA = contact.Professional_Designation_CIA__c;
        demographicsContactInfo.professionalDesignationCMA = contact.Professional_Designation_CMA__c;
        demographicsContactInfo.professionalDesignationCMT = contact.Professional_Designation_CMT__c;
        demographicsContactInfo.professionalDesignationCPA = contact.Professional_Designation_CPA__c;
        demographicsContactInfo.professionalDesignationCQF = contact.Professional_Designation_CQF__c;
        demographicsContactInfo.professionalDesignationPMP = contact.Professional_Designation_PMP__c;
        demographicsContactInfo.professionalDesignationOther = contact.Professional_Designation_Other__c;
        demographicsContactInfo.professionalDesignationOtherQualifications = contact.Other_Qualifications__c;
        demographicsContactInfo.school = contact.School_Name__c;
        demographicsContactInfo.highestDegree = contact.Highest_Degree__c;
        demographicsContactInfo.expectedGraduationYear = contact.Expected_Graduation_Date__c;
        demographicsContactInfo.expectedGraduationMonth = contact.Expected_Graduation_Month__c;

        return demographicsContactInfo;
    }

    public static boolean isChangedString(String origVal, String newVal) {
        if((origVal == NULL && newVal != NULL) || (origVal != NULL && newVal != NULL && newVal != origVal)) {
            return True;
        }
        return False;
    }
    public static boolean isChangedBoolean(boolean origVal, boolean newVal) {
        if((origVal == NULL && newVal != NULL) || (origVal != NULL && newVal != NULL && newVal != origVal)) {
            return True;
        }
        return False;
    }
    public static boolean isChangedDate(Date origVal, Date newVal) {
        if((origVal == NULL && newVal != NULL) || (origVal != NULL && newVal != NULL && newVal != origVal)) {
            return True;
        }
        return False;
    }

    public static void setDemographicsContactInfo(Contact contact, demographicsContactInfo demographicsContactInfo) {
        contact.Currently_Working_Status__c = demographicsContactInfo.workingStatus;
        contact.Area_of_Concentration__c = demographicsContactInfo.industry;
        contact.Industry_Working_Year__c = demographicsContactInfo.industryStartWorkingYear;
        contact.Company__c = demographicsContactInfo.company;
        contact.Corporate_Title__c = demographicsContactInfo.professionalLevel;
        contact.Job_Function__c = demographicsContactInfo.jobFunction;
        contact.Risk_Specialty__c = demographicsContactInfo.riskSpecialty;
        contact.Risk_Management_Working_Year__c = demographicsContactInfo.riskManagementStartWorkingYear;
        contact.Professional_Designation_ACCA__c = demographicsContactInfo.professionalDesignationACCA;
        contact.Professional_Designation_CA__c = demographicsContactInfo.professionalDesignationCA;
        contact.Professional_Designation_CAIA__c = demographicsContactInfo.professionalDesignationCAIA;
        contact.Professional_Designation_CFA__c = demographicsContactInfo.professionalDesignationCFA;
        contact.Professional_Designation_CFP__c = demographicsContactInfo.professionalDesignationCFP;
        contact.Professional_Designation_CIA__c = demographicsContactInfo.professionalDesignationCIA;
        contact.Professional_Designation_CMA__c = demographicsContactInfo.professionalDesignationCMA;
        contact.Professional_Designation_CMT__c = demographicsContactInfo.professionalDesignationCMT;
        contact.Professional_Designation_CPA__c = demographicsContactInfo.professionalDesignationCPA;
        contact.Professional_Designation_CQF__c = demographicsContactInfo.professionalDesignationCQF;
        contact.Professional_Designation_PMP__c = demographicsContactInfo.professionalDesignationPMP;
        contact.Professional_Designation_Other__c = demographicsContactInfo.professionalDesignationOther;
        contact.Other_Qualifications__c = demographicsContactInfo.professionalDesignationOtherQualifications;
        contact.School_Name__c = demographicsContactInfo.school;
        contact.Highest_Degree__c = demographicsContactInfo.highestDegree;
        contact.Expected_Graduation_Date__c = demographicsContactInfo.expectedGraduationYear;
        contact.Expected_Graduation_Month__c = demographicsContactInfo.expectedGraduationMonth;

        if(isChangedString(contact.Currently_Working_Status__c,demographicsContactInfo.workingStatus) ||
           isChangedString(contact.Area_of_Concentration__c,demographicsContactInfo.industry) ||
           isChangedString(contact.Industry_Working_Year__c,demographicsContactInfo.industryStartWorkingYear) ||
           isChangedString(contact.Company__c,demographicsContactInfo.company) ||
           isChangedString(contact.Corporate_Title__c,demographicsContactInfo.professionalLevel) ||
           isChangedString(contact.Job_Function__c,demographicsContactInfo.jobFunction) ||
           isChangedString(contact.Risk_Specialty__c,demographicsContactInfo.riskSpecialty) ||
           isChangedString(contact.Risk_Management_Working_Year__c,demographicsContactInfo.riskManagementStartWorkingYear) ||
           isChangedBoolean(contact.Professional_Designation_ACCA__c,demographicsContactInfo.professionalDesignationACCA) ||
           isChangedBoolean(contact.Professional_Designation_CA__c,demographicsContactInfo.professionalDesignationCA) ||
           isChangedBoolean(contact.Professional_Designation_CAIA__c,demographicsContactInfo.professionalDesignationCAIA) ||
           isChangedBoolean(contact.Professional_Designation_CFA__c,demographicsContactInfo.professionalDesignationCFA) ||
           isChangedBoolean(contact.Professional_Designation_CFP__c,demographicsContactInfo.professionalDesignationCFP) ||
           isChangedBoolean(contact.Professional_Designation_CIA__c,demographicsContactInfo.professionalDesignationCIA) ||
           isChangedBoolean(contact.Professional_Designation_CMA__c,demographicsContactInfo.professionalDesignationCMA) ||
           isChangedBoolean(contact.Professional_Designation_CMT__c,demographicsContactInfo.professionalDesignationCMT) ||
           isChangedBoolean(contact.Professional_Designation_CPA__c,demographicsContactInfo.professionalDesignationCPA) ||
           isChangedBoolean(contact.Professional_Designation_CQF__c,demographicsContactInfo.professionalDesignationCQF) ||
           isChangedBoolean(contact.Professional_Designation_PMP__c,demographicsContactInfo.professionalDesignationPMP) ||
           isChangedBoolean(contact.Professional_Designation_Other__c,demographicsContactInfo.professionalDesignationOther) ||
           isChangedString(contact.Other_Qualifications__c,demographicsContactInfo.professionalDesignationOtherQualifications)) {
               contact.Date_Employment_LastUpdated_GARP_Member__c = Date.Today();
           }


        if(isChangedString(contact.School_Name__c,demographicsContactInfo.school) ||
           isChangedString(contact.Highest_Degree__c,demographicsContactInfo.highestDegree) ||
           isChangedString(contact.Expected_Graduation_Date__c,demographicsContactInfo.expectedGraduationYear) ||
           isChangedString(contact.Expected_Graduation_Month__c,demographicsContactInfo.expectedGraduationMonth)) {
               contact.Date_Educational_Info_LastUpdated_Member__c = Date.Today();
           }

        GARP_Common.debugLog('GARP_BC_MemberProfile','setDemographicsContactInfo','updated contact',contact);

        update contact;
    }

    // Directory Settings
    // Feature Wrappers
    public class chapterMembershipInfo {
        public String chapterId;
        public String chapterName;
        public Boolean isDirector;
        public Boolean isCommitteeMember;
        public Boolean canManageAttendance;
        public Boolean canRequestMeetings;
        public Boolean canViewResources;
    }

    public class memberChapterMembershipInfo {
        public chapterMembershipInfo primaryChapter;
        public chapterMembershipInfo secondaryChapter;
    }

    // Also used in V2 Portal
    public class memberDirectorySettings {

        // User Settings
        public Boolean isOptedIn;
        public Boolean showAdditionalDetails;
        public Boolean showJobInformation;
        public Boolean showProfessionalBackground;
        public Boolean isDirectoryConnectEnabled;
    }

    public class memberDirectorySettingsInfo {

        // User Settings
        public memberDirectorySettings memberDirectorySettings;

        // Access Control
        public Boolean hasDirectoryAccess;
        public Boolean hasDirectoryCPDAccess;
        public Boolean hasDirectoryConnectAccess;
        public Boolean hasDirectoryAdvancedSearchAccess;
        public Boolean hasDirectoryNonCertifiedAccess;
        public Boolean hasDirectorySettingsAccess;

        // Preview Fields
        public String memberName;
        public String city;
        public String state;
        public String country;
        public Date frmCertifiedYear;
        public Date erpCertifiedYear;
        public String cpdCurrentCycle;
        public String cpdLastCompletedCycle;
        public String jobFunction;
        public String areaOfConcentration;
        public String riskSpecialty;
        public String professionalLevel;
        public String company;

        Public Boolean Professional_Designation_ACCA;
        Public Boolean Professional_Designation_CA;
        Public Boolean Professional_Designation_CAIA;
        Public Boolean Professional_Designation_CFA;
        Public Boolean Professional_Designation_CFP;
        Public Boolean Professional_Designation_CIA;
        Public Boolean Professional_Designation_CMA;
        Public Boolean Professional_Designation_CMT;
        Public Boolean Professional_Designation_CPA;
        Public Boolean Professional_Designation_CQF;
        Public Boolean Professional_Designation_PMP;
        Public Boolean Professional_Designation_Other;
        Public String Other_Qualifications;
    }

    public static memberDirectorySettingsInfo getMemberDirectorySettingsInfo(Contact contact, MAP<String,Contract> mapContracts) {

        GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberDirectorySettingsInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberDirectorySettingsInfo','mapContracts',mapContracts);

        memberDirectorySettingsInfo dirInfo = new memberDirectorySettingsInfo();

        dirInfo.memberDirectorySettings = new memberDirectorySettings();

        Contract membershipContract = mapContracts.get('Membership');
        Contract frmContract = mapContracts.get('FRM_Program');
        Contract erpContract = mapContracts.get('ERP_Program');

        Boolean isFRMCertified = False;
        Boolean isERPCertified = False;
        Boolean isIndividualMemberInGoodStanding = False;

        if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && (membershipContract.status == 'Activated' || membershipContract.status == 'Activated ( Auto-Renew )')) {
            isIndividualMemberInGoodStanding = True;
        }
        if(frmContract != NULL && frmContract.status == 'Completed') {
            isFRMCertified = True;
        }
        if(erpContract != NULL && erpContract.status == 'Completed') {
            isERPCertified = True;
        }

        // User Settings
        dirInfo.memberDirectorySettings.isOptedIn = contact.GARP_Directory_Opt_In__c;
        dirInfo.memberDirectorySettings.showAdditionalDetails = contact.GARP_Dir_Privacy_Additional_Detail__c;
        dirInfo.memberDirectorySettings.showJobInformation = contact.GARP_Dir_Privacy_Job_Information__c;
        dirInfo.memberDirectorySettings.showProfessionalBackground = contact.GARP_Dir_Privacy_Prof_Background__c;
        dirInfo.memberDirectorySettings.isDirectoryConnectEnabled = contact.GARP_Directory_Connect_Feature__c;

        // Access Control
        dirInfo.hasDirectoryAccess = True;
        dirInfo.hasDirectoryCPDAccess = (isFRMCertified || isERPCertified);
        dirInfo.hasDirectoryConnectAccess = isIndividualMemberInGoodStanding;
        dirInfo.hasDirectoryAdvancedSearchAccess = isIndividualMemberInGoodStanding;
        dirInfo.hasDirectoryNonCertifiedAccess = isIndividualMemberInGoodStanding;
        dirInfo.hasDirectorySettingsAccess = (isFRMCertified || isERPCertified || isIndividualMemberInGoodStanding);

        // Preview Fields
        dirInfo.memberName = contact.FirstName + ' ' + contact.LastName;
        dirInfo.city = contact.MailingCity;
        dirInfo.state = contact.MailingState;
        dirInfo.country = contact.MailingCountry;
        if(isFRMCertified) {
            dirInfo.frmCertifiedYear = frmContract.All_Requirements_Completed_Date__c;
        }
        if(isERPCertified) {
            dirInfo.erpCertifiedYear = erpContract.All_Requirements_Completed_Date__c;
        }
        dirInfo.cpdCurrentCycle = contact.KPI_CPE_Current_Cycle__c;
        dirInfo.cpdLastCompletedCycle = contact.KPI_CPE_Last_Completed_Cycle__c;
        dirInfo.jobFunction = contact.Job_Function__c;
        dirInfo.areaOfConcentration = contact.Area_of_Concentration__c;
        dirInfo.riskSpecialty = contact.Risk_Specialty__c;
        dirInfo.professionalLevel = contact.Corporate_Title__c;
        dirInfo.company = contact.Company__c;

        dirInfo.Professional_Designation_ACCA = contact.Professional_Designation_ACCA__c;
        dirInfo.Professional_Designation_CA = contact.Professional_Designation_CA__c;
        dirInfo.Professional_Designation_CAIA = contact.Professional_Designation_CAIA__c;
        dirInfo.Professional_Designation_CFA = contact.Professional_Designation_CFA__c;
        dirInfo.Professional_Designation_CFP = contact.Professional_Designation_CFP__c;
        dirInfo.Professional_Designation_CIA = contact.Professional_Designation_CIA__c;
        dirInfo.Professional_Designation_CMA = contact.Professional_Designation_CMA__c;
        dirInfo.Professional_Designation_CMT = contact.Professional_Designation_CMT__c;
        dirInfo.Professional_Designation_CPA = contact.Professional_Designation_CPA__c;
        dirInfo.Professional_Designation_CQF = contact.Professional_Designation_CQF__c;
        dirInfo.Professional_Designation_PMP = contact.Professional_Designation_PMP__c;
        dirInfo.Professional_Designation_Other = contact.Professional_Designation_Other__c;
        dirInfo.Other_Qualifications = contact.Other_Qualifications__c;

        return dirInfo;
    }

    public static void setMemberDirectorySettingsInfo(Contact contact, memberDirectorySettings directorySettings) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','getDirectorySettingsInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_MemberProfile','getDirectorySettingsInfo','directorySettings',directorySettings);

        contact.GARP_Directory_Opt_In__c = directorySettings.isOptedIn;
        contact.GARP_Dir_Privacy_Additional_Detail__c = directorySettings.showAdditionalDetails;
        contact.GARP_Dir_Privacy_Job_Information__c = directorySettings.showJobInformation;
        contact.GARP_Dir_Privacy_Prof_Background__c = directorySettings.showProfessionalBackground;
        contact.GARP_Directory_Connect_Feature__c = directorySettings.isDirectoryConnectEnabled;

        update contact;
    }

    // Compute profilePercentComplete
    public static Decimal computeProfilePercentComplete(Contact contact) {
        GARP_Common.debugLog('GARP_BC_MemberProfile','computeProfilePercentComplete','contact',contact);

        Decimal profilePercentComplete;

        Decimal profileCnt=0;
        if(contact.Currently_Working_Status__c != NULL)
            profileCnt++;
        if(contact.Area_of_Concentration__c != NULL)
            profileCnt++;
        if(contact.Industry_Working_Year__c != NULL)
            profileCnt++;
        if(contact.Company__c != NULL)
            profileCnt++;
        if(contact.Corporate_Title__c != NULL)
            profileCnt++;
        if(contact.Job_Function__c != NULL)
            profileCnt++;
        if(contact.Risk_Management_Working_Year__c != NULL)
            profileCnt++;
        if(contact.School_Name__c != NULL)
            profileCnt++;
        if(contact.Highest_Degree__c != NULL)
            profileCnt++;
        if(contact.Expected_Graduation_Date__c != NULL)
            profileCnt++;
        if(contact.Expected_Graduation_Month__c != NULL)
            profileCnt++;

        GARP_Common.debugLog('GARP_BC_MemberProfile','computeProfilePercentComplete','profileCnt',profileCnt);

        Decimal percentComplete = ((profileCnt / 11) * 100).intValue();
        GARP_Common.debugLog('GARP_BC_MemberProfile','computeProfilePercentComplete','percentComplete',percentComplete);

        return percentComplete;
    }

    // New Portal V1

    // Wrappers
    /*
    public class memberProfileInfo {
        public String firstName;
        public String lastName;
        public String garpId;
        public String membershipType;
        public String membershipStatus;
        public Boolean isIndividualMemberInGoodStanding;
        public String avatarPhoto;
        public Boolean isFRMCertified;
        public Boolean isERPCertified;
        public Boolean isSCEHolder;
        public Boolean isChapterDirector;
        public Boolean hasPillar3LiteAccess;
        public Contact contact;
        public Decimal profilePercentComplete;
        public memberProgramsInfo memberProgramsInfo;
        public portalAccessInfo portalAccessInfo;
        //public GARP_BC_MyPrograms.allProgramData allProgramData;
        public List<dashboardComponent> dashboardComponents;
    }

    public class portalAccessInfo {
        public Boolean hasGARPPortal;
        public Boolean hasEventPortal;
        public Boolean hasGBIPortal;
        public Boolean hasEPPPortal;
        public Boolean hasGTPortal;
    }

    public class memberProgramsInfo {
        public programInfo memberProgram;
        public programInfo frmProgram;
        public programInfo erpProgram;
        public programInfo scrProgram;
        public programInfo frrProgram;
        public programInfo ffrProgram;
        public programInfo cpdProgram;
        public programInfo riskNetProgram;
    }

    public class programInfo {
        public String type; // FRM, SCR, CPD, …
        public String Status; // Active, Expired, Draft
        public Date expireDate;
        public Date completionDate;
        public Boolean isAutoRenewing;
        public String openOrderId;
        Public String PassFRMFullStatus;
        Public String PassFRM1Status;
        Public String PassFRM2Status;
        Public String PassERPFullStatus;
        Public String PassERP1Status;
        Public String PassERP2Status;
        Public String JobRequirementStatus;
        Public String CPDAttestStatus;
        Public String CPDCycleStatus;
    }
    */

    // General Profile Call
    /*
    public static memberProfileInfo getMemberProfileInfo(String contactId){
        memberProfileInfo memberProfileInfo = new memberProfileInfo();

        //memberProfileInfo.allProgramData = GARP_BC_MyPrograms.getAllProgramInfo('');

        memberProfileInfo.memberProgramsInfo = new memberProgramsInfo();
        memberProfileInfo.memberProgramsInfo.memberProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.memberProgram.type = 'membership';
        memberProfileInfo.memberProgramsInfo.frmProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.frmProgram.type = 'frm';
        memberProfileInfo.memberProgramsInfo.erpProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.erpProgram.type = 'erp';
        memberProfileInfo.memberProgramsInfo.scrProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.scrProgram.type = 'scr';
        memberProfileInfo.memberProgramsInfo.ffrProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.ffrProgram.type = 'ffr';
        memberProfileInfo.memberProgramsInfo.frrProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.frrProgram.type = 'frr';
        memberProfileInfo.memberProgramsInfo.cpdProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.cpdProgram.type = 'cpd';
        memberProfileInfo.memberProgramsInfo.riskNetProgram = new programInfo();
        memberProfileInfo.memberProgramsInfo.riskNetProgram.type = 'risknet';

        MAP<String,String> mapProductCodes = new MAP<String,String>();
        mapProductCodes.put('FRM1E','frm');
        mapProductCodes.put('FRM1S','frm');
        mapProductCodes.put('FRM2E','frm');
        mapProductCodes.put('FRM2S','frm');
        mapProductCodes.put('SCRCME','scr');
        mapProductCodes.put('SCRCMS','scr');
        mapProductCodes.put('SCRME','scr');
        mapProductCodes.put('SCRMS','scr');
        mapProductCodes.put('SCRNME','scr');
        mapProductCodes.put('SCRNMS','scr');
        mapProductCodes.put('CBR','ffr');
        mapProductCodes.put('CBRNM','ffr');
        mapProductCodes.put('FCBR','frr');
        mapProductCodes.put('FBRNM','frr');

        memberProfileInfo.portalAccessInfo = new portalAccessInfo();
        memberProfileInfo.portalAccessInfo.hasGARPPortal = False;
        memberProfileInfo.portalAccessInfo.hasGBIPortal = False;
        memberProfileInfo.portalAccessInfo.hasEPPPortal = False;
        memberProfileInfo.portalAccessInfo.hasGTPortal = False;

        List<Contact> lstContacts = [select Id, AccountId, FirstName, LastName, GARP_Member_ID__c, Photo_URL__c,
                                     GBI_Participant__c, GBI_Analytics_Participant__c, EPP_Data_Manager__c,
                                     Currently_Working_Status__c, Area_of_Concentration__c, Industry_Working_Year__c,
                                     Company__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c, Risk_Management_Working_Year__c,
                                     School_Name__c, Highest_Degree__c, Expected_Graduation_Date__c, Expected_Graduation_Month__c,
                                     (select id, Director__c from Chapter_Members__r where Director__c = True)
                                     from Contact where Id = :contactId];
        if(!lstContacts.isEmpty()) {
            Contact contact = lstContacts[0];
            memberProfileInfo.contact = contact;

            // Basic Info
            memberProfileInfo.firstName = contact.FirstName;
            memberProfileInfo.lastName = contact.LastName;
            memberProfileInfo.garpId = contact.GARP_Member_ID__c;
            memberProfileInfo.avatarPhoto = contact.Photo_URL__c;

            // Compute profilePercentComplete
            Integer profileCnt=0;
            if(contact.Currently_Working_Status__c != NULL)
                profileCnt++;
            if(contact.Area_of_Concentration__c != NULL)
                profileCnt++;
            if(contact.Industry_Working_Year__c != NULL)
                profileCnt++;
            if(contact.Company__c != NULL)
                profileCnt++;
            if(contact.Corporate_Title__c != NULL)
                profileCnt++;
            if(contact.Job_Function__c != NULL)
                profileCnt++;
            if(contact.Risk_Specialty__c != NULL)
                profileCnt++;
            if(contact.Risk_Management_Working_Year__c != NULL)
                profileCnt++;
            if(contact.School_Name__c != NULL)
                profileCnt++;
            if(contact.Highest_Degree__c != NULL)
                profileCnt++;
            if(contact.Expected_Graduation_Date__c != NULL)
                profileCnt++;
            if(contact.Expected_Graduation_Month__c != NULL)
                profileCnt++;

            memberProfileInfo.profilePercentComplete = profileCnt / 12;

            // Assign access control
            if(contact.GBI_Participant__c || contact.GBI_Analytics_Participant__c) {
                memberProfileInfo.portalAccessInfo.hasGBIPortal = True;
            }

            memberProfileInfo.hasPillar3LiteAccess = False;
            if(contact.GBI_Analytics_Participant__c) {
                memberProfileInfo.hasPillar3LiteAccess = True;
            }

            if(contact.EPP_Data_Manager__c) {
                memberProfileInfo.portalAccessInfo.hasEPPPortal = True;
            }

            if(!contact.Chapter_Members__r.IsEmpty()) {
                memberProfileInfo.isChapterDirector = True;
            }

            // Get Open Orders
            List<Opportunity> lstOpenOpps = [select Id, (SELECT Id, Product2.ProductCode FROM OpportunityLineItems
                                             where Product2.ProductCode in :mapProductCodes.keySet())
                                             from Opportunity
                                             where StageName = 'New Lead' AND AccountId = :contact.AccountId];
            GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','lstOpenOpps',lstOpenOpps);

            MAP<String, Opportunity> mapOpenOpp = new  MAP<String, Opportunity>();
            if(!lstOpenOpps.IsEmpty()) {
                for(Opportunity opp :lstOpenOpps) {
                    mapOpenOpp.put(opp.Id, opp);
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','mapOpenOpp',mapOpenOpp);

            // Get Contracts and assign program status
            List<Contract> lstContracts = [select Id, recordType.DeveloperName, EndDate, Status, Opportunity__c, All_Requirements_Completed_Date__c, Membership_Type__c,
                                           (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Recordtype.Developername FROM Candidate_Requirements__r)
                                           from Contract
                                           where status != 'Draft' and status != 'canceled' AND AccountId = :contact.AccountId
                                           ORDER BY recordType.Name, StartDate DESC];
            GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','lstContracts',lstContracts);

            for(Contract cont :lstContracts) {
                String contractStatus = cont.Status.toLowerCase();
                Boolean isAutoRenewing = False;
                if(contractStatus == 'activated ( auto-renew )') {
                    contractStatus = 'activated';
                    isAutoRenewing = True;
                }
                GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','contractStatus',contractStatus);

                Opportunity openOpp = mapOpenOpp.get(cont.Opportunity__c);
                GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','openOpp',openOpp);
                String openOrderId;
                if(openOpp != NULL) {
                    openOrderId = openOpp.Id;
                }

                GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','recordType',cont.recordType.DeveloperName);

                if(cont.recordType.DeveloperName == 'FRM_Program') {
                    if(memberProfileInfo.memberProgramsInfo.frmProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.frmProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.frmProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.frmProgram.completionDate = cont.All_Requirements_Completed_Date__c;
                        memberProfileInfo.memberProgramsInfo.frmProgram.openOrderId = openOrderId;
                        memberProfileInfo.memberProgramsInfo.frmProgram.PassFRM1Status = '';
                        memberProfileInfo.memberProgramsInfo.frmProgram.PassFRM2Status = '';
                        memberProfileInfo.memberProgramsInfo.frmProgram.JobRequirementStatus = '';
                        // Compute Program Requirement Status
                        if(!cont.Candidate_Requirements__r.IsEmpty()) {
                            for(Candidate_Requirement__c canReq :cont.Candidate_Requirements__r) {
                                if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'FRM Part I') {
                                    memberProfileInfo.memberProgramsInfo.frmProgram.PassFRM1Status = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'FRM Part II') {
                                    memberProfileInfo.memberProgramsInfo.frmProgram.PassFRM2Status = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'FRM Full') {
                                    memberProfileInfo.memberProgramsInfo.frmProgram.PassFRMFullStatus = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Job Experience') {
                                    memberProfileInfo.memberProgramsInfo.frmProgram.JobRequirementStatus = canReq.Status__c;
                                }
                            }
                        }
                    }
                } else if(cont.recordType.DeveloperName == 'ERP_Program') {
                    if(memberProfileInfo.memberProgramsInfo.erpProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.erpProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.erpProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.erpProgram.openOrderId = openOrderId;
                        memberProfileInfo.memberProgramsInfo.erpProgram.PassERP1Status = '';
                        memberProfileInfo.memberProgramsInfo.erpProgram.PassERP2Status = '';
                        memberProfileInfo.memberProgramsInfo.erpProgram.JobRequirementStatus = '';
                        // Compute Program Requirement Status
                        if(!cont.Candidate_Requirements__r.IsEmpty()) {
                            for(Candidate_Requirement__c canReq :cont.Candidate_Requirements__r) {
                                if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'ERP Part I') {
                                    memberProfileInfo.memberProgramsInfo.erpProgram.PassERP1Status = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'ERP Part II') {
                                    memberProfileInfo.memberProgramsInfo.erpProgram.PassERP2Status = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Exam' && canReq.Exam__c == 'ERP Full') {
                                    memberProfileInfo.memberProgramsInfo.erpProgram.PassERPFullStatus = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Job Experience') {
                                    memberProfileInfo.memberProgramsInfo.erpProgram.JobRequirementStatus = canReq.Status__c;
                                }
                            }
                        }
                    }
                } else if(cont.recordType.DeveloperName == 'SCR_Program') {
                    if(memberProfileInfo.memberProgramsInfo.scrProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.scrProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.scrProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.scrProgram.openOrderId = openOrderId;
                    }
                } else if(cont.recordType.DeveloperName == 'ICBRR_Program') {
                    if(memberProfileInfo.memberProgramsInfo.frrProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.frrProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.frmProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.frmProgram.openOrderId = openOrderId;
                    }
                } else if(cont.recordType.DeveloperName == 'FBR_Program') {
                    if(memberProfileInfo.memberProgramsInfo.ffrProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.ffrProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.ffrProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.ffrProgram.openOrderId = openOrderId;
                    }
                } else if(cont.recordType.DeveloperName == 'CPE') {
                    if(memberProfileInfo.memberProgramsInfo.cpdProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.cpdProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.cpdProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.cpdProgram.openOrderId = openOrderId;
                        memberProfileInfo.memberProgramsInfo.cpdProgram.CPDCycleStatus = '';
                        memberProfileInfo.memberProgramsInfo.cpdProgram.CPDAttestStatus = '';
                        // Compute Program Requirement Status
                        if(!cont.Candidate_Requirements__r.IsEmpty()) {
                            for(Candidate_Requirement__c canReq :cont.Candidate_Requirements__r) {
                                if(canReq.Recordtype.Developername == 'CPE') {
                                    memberProfileInfo.memberProgramsInfo.cpdProgram.CPDCycleStatus = canReq.Status__c;
                                } else if(canReq.Recordtype.Developername == 'Attest') {
                                    memberProfileInfo.memberProgramsInfo.cpdProgram.CPDAttestStatus = canReq.Status__c;
                                }
                            }
                        }
                    }
                } else if(cont.recordType.DeveloperName == 'Risk_Net') {
                    if(memberProfileInfo.memberProgramsInfo.riskNetProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.riskNetProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.riskNetProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.riskNetProgram.openOrderId = openOrderId;
                    }
                } else if(cont.recordType.DeveloperName == 'Membership') {

                    memberProfileInfo.portalAccessInfo.hasGARPPortal = True;

                    if(memberProfileInfo.memberProgramsInfo.memberProgram.status == NULL) {
                        memberProfileInfo.memberProgramsInfo.memberProgram.status = contractStatus;
                        memberProfileInfo.memberProgramsInfo.memberProgram.isAutoRenewing = isAutoRenewing;
                        memberProfileInfo.memberProgramsInfo.memberProgram.expireDate = cont.EndDate;
                        memberProfileInfo.memberProgramsInfo.memberProgram.openOrderId = openOrderId;

                        memberProfileInfo.membershipType = cont.Membership_Type__c;
                        memberProfileInfo.membershipStatus = contractStatus;
                        memberProfileInfo.isIndividualMemberInGoodStanding = (cont.Membership_Type__c == 'Individual' && contractStatus == 'activated');
                    }
                }
                GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','memberProfileInfo',memberProfileInfo);
            }

            // If logged in and have no other portal access, given them Event Portal
            if(!memberProfileInfo.portalAccessInfo.hasGARPPortal && !memberProfileInfo.portalAccessInfo.hasGBIPortal &&
               !memberProfileInfo.portalAccessInfo.hasEPPPortal && !memberProfileInfo.portalAccessInfo.hasGTPortal) {
                memberProfileInfo.portalAccessInfo.hasEventPortal = True;
            }

            memberProfileInfo.isFRMCertified = false;
            if(memberProfileInfo.memberProgramsInfo.frmProgram.status != NULL && memberProfileInfo.memberProgramsInfo.frmProgram.status == 'completed') {
                memberProfileInfo.isFRMCertified = true;
            }
            memberProfileInfo.isERPCertified = false;
            if(memberProfileInfo.memberProgramsInfo.erpProgram.status != NULL && memberProfileInfo.memberProgramsInfo.erpProgram.status == 'completed') {
                memberProfileInfo.isERPCertified = true;
            }
            memberProfileInfo.isSCEHolder = false;
            if(memberProfileInfo.memberProgramsInfo.scrProgram.status != NULL && memberProfileInfo.memberProgramsInfo.scrProgram.status == 'completed') {
                memberProfileInfo.isSCEHolder = true;
            }

            // Loop over Opps for open order
            for(Opportunity openOpp :lstOpenOpps) {
                GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','openOpp',openOpp);

                for(OpportunityLineItem oppLine :openOpp.OpportunityLineItems) {
                    GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','oppLine',oppLine);

                    String program = mapProductCodes.get(oppLine.Product2.ProductCode);
                    GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','program',program);

                    if(program != NULL) {
                        if(program == 'frm') {
                            memberProfileInfo.memberProgramsInfo.frmProgram.openOrderId = openOpp.Id;
                        } else if(program == 'scr') {
                            memberProfileInfo.memberProgramsInfo.scrProgram.openOrderId = openOpp.Id;
                        } else if(program == 'ffr') {
                            memberProfileInfo.memberProgramsInfo.ffrProgram.openOrderId = openOpp.Id;
                        } else if(program == 'frr') {
                            memberProfileInfo.memberProgramsInfo.frrProgram.openOrderId = openOpp.Id;
                        }
                        GARP_Common.debugLog('GARP_BC_MemberProfile','getMemberProfileInfo','memberProfileInfo',memberProfileInfo);
                    }
                }
            }

        }

        return memberProfileInfo;
    }

    public static GARP_Common.returnInfo setChapterMembershipInfo(String contactId, memberChapterMembershipInfo chapterMembershipInfo){
        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();

        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','chapterMembershipInfo',chapterMembershipInfo);

        if(contactId == NULL || chapterMembershipInfo == NULL) {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Missing required parameters';
            return returnInfo;
        }

        List<Chapter_Member__c> lstChapterMember = [select Id, Name, Director__c, Chapter__c, Chapter__r.Name, Committee_Member__c, Can_Manage_Attendance__c, Can_Request_Meetings__c,
                                                    Can_View_Resources__c, IsPrimary__c, IsSecondary__c
                                                    from Chapter_Member__c
                                                    where Contact__c = :contactId AND (IsPrimary__c = true OR IsSecondary__c = true) AND
                                                    (Status__c = NULL OR Status__c = 'Active')];
        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','lstChapterMember',lstChapterMember);

        Boolean hasUpdatedPrimary = False;
        Boolean hasUpdatedSecondary = False;
        List<Chapter_Member__c> removeMembership = new List<Chapter_Member__c>();
        if(!lstChapterMember.IsEmpty()) {
            for(Chapter_Member__c cm :lstChapterMember) {

                GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','Loop Chapter_Member__c',cm);

                if(cm.IsPrimary__c) {
                    // If updates made and is Director, do not allow
                    if(cm.Director__c) {
                        returnInfo.status = 'Failed';
                        returnInfo.msg = 'Chapter Director cannot update chapter membership';
                        return returnInfo;
                    }

                    if(chapterMembershipInfo.primaryChapter != NULL) {
                        cm.Chapter__c = chapterMembershipInfo.primaryChapter.chapterId;
                        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','update primary',cm);

                    } else {
                        removeMembership.add(cm);
                        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','remove primary','');
                    }
                    hasUpdatedPrimary = True;
                } else if(cm.IsSecondary__c) {
                    // If updates made and is Director, do not allow
                    if(cm.Director__c) {
                        returnInfo.status = 'Failed';
                        returnInfo.msg = 'Chapter Director cannot update chapter membership';
                        return returnInfo;
                    }

                    if(chapterMembershipInfo.secondaryChapter != NULL) {
                        cm.Chapter__c = chapterMembershipInfo.secondaryChapter.chapterId;
                        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','update secondary',cm);

                    } else {
                        removeMembership.add(cm);
                        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','remove secondary','');
                    }
                    hasUpdatedSecondary = True;
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','hasUpdatedPrimary',hasUpdatedPrimary);
        GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','hasUpdatedPrimary',hasUpdatedPrimary);

        List<Chapter_Member__c> addMembership = new List<Chapter_Member__c>();
        if(!hasUpdatedPrimary && chapterMembershipInfo.primaryChapter != NULL) {
            Chapter_Member__c cm = new Chapter_Member__c(
                Chapter__c = chapterMembershipInfo.primaryChapter.chapterId,
                IsPrimary__c = True
            );
            addMembership.add(cm);
            GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','add primary',cm);
        }
        if(!hasUpdatedSecondary && chapterMembershipInfo.secondaryChapter != NULL) {
            Chapter_Member__c cm = new Chapter_Member__c(
                Chapter__c = chapterMembershipInfo.secondaryChapter.chapterId,
                IsPrimary__c = True
            );
            addMembership.add(cm);
            GARP_Common.debugLog('GARP_BC_MemberProfile','setChapterMembershipInfo','add secondary',cm);
        }

        delete removeMembership;
        insert addMembership;

        returnInfo.status = 'Success';
        return returnInfo;
    }

    public static memberChapterMembershipInfo getChapterMembershipInfo(String contactId){
        memberChapterMembershipInfo chapInfo = new memberChapterMembershipInfo();

        GARP_Common.debugLog('GARP_BC_MemberProfile','getChapterMembershipInfo','contactId',contactId);

        List<Chapter_Member__c> lstChapterMember = [select Id, Name, Director__c, Chapter__c, Chapter__r.Name, Committee_Member__c, Can_Manage_Attendance__c, Can_Request_Meetings__c, Can_View_Resources__c, IsPrimary__c, IsSecondary__c from Chapter_Member__c where Contact__c = :contactId AND (IsPrimary__c = true OR IsSecondary__c = true)];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getChapterMembershipInfo','lstChapterMember',lstChapterMember);

        if(!lstChapterMember.IsEmpty()) {
            for(Chapter_Member__c cm :lstChapterMember) {
                GARP_Common.debugLog('GARP_BC_MemberProfile','getChapterMembershipInfo','Loop Chapter_Member__c',cm);

                if(cm.IsPrimary__c) {
                    chapInfo.primaryChapter = new chapterMembershipInfo();
                    chapInfo.primaryChapter.chapterId = cm.Chapter__c;
                    chapInfo.primaryChapter.chapterName = cm.Chapter__r.Name;
                    chapInfo.primaryChapter.isCommitteeMember = cm.Committee_Member__c;
                    chapInfo.primaryChapter.canManageAttendance = cm.Can_Manage_Attendance__c;
                    chapInfo.primaryChapter.canRequestMeetings = cm.Can_Request_Meetings__c;
                    chapInfo.primaryChapter.canViewResources = cm.Can_View_Resources__c;
                } else if(cm.IsSecondary__c) {
                    chapInfo.secondaryChapter = new chapterMembershipInfo();
                    chapInfo.secondaryChapter.chapterId = cm.Chapter__c;
                    chapInfo.secondaryChapter.chapterName = cm.Chapter__r.Name;
                    chapInfo.secondaryChapter.isCommitteeMember = cm.Committee_Member__c;
                    chapInfo.secondaryChapter.canManageAttendance = cm.Can_Manage_Attendance__c;
                    chapInfo.secondaryChapter.canRequestMeetings = cm.Can_Request_Meetings__c;
                    chapInfo.secondaryChapter.canViewResources = cm.Can_View_Resources__c;
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','getChapterMembershipInfo','return chapInfo',chapInfo);
        return chapInfo;
    }

    public static List<Membership_Exclusive_Offers__c> getMembershipExclusiveOffers(String contactId) {
        return [select Id, Authenticated_Affiliate_Can_Use_Offer__c, US_Description__c, Display_Name__c, Non_Member_Description__c, Non_US_Description__c, Member_Description__c, Name, US_Required__c, External_Link_Name__c, Info_Link__c, Membership_Required__c, Authenticated_Description__c, Memb_Offer_Description__c, Values_List__c, Memb_Offer_External_Link__c, Memb_Offer_Hashtag__c, Memb_Offer_Logo__c, Memb_Offer_Promo_Code__c, Memb_Offer_Status__c, Memb_Offer_Public_Button_Text__c, Memb_Offer_Portal_Route__c from Membership_Exclusive_Offers__c];
    }
    */

    public static memberDirectorySettingsInfo getDirectorySettingsInfo(String contactId) {

        GARP_Common.debugLog('GARP_BC_MemberProfile','getDirectorySettingsInfo','contactId',contactId);
        memberDirectorySettingsInfo dirInfo = new memberDirectorySettingsInfo();

        dirInfo.memberDirectorySettings = new memberDirectorySettings();

        List<Contact> lstContact = [select Id, Name, GARP_Directory_Opt_In__c, GARP_Directory_Connect_Feature__c, GARP_Dir_Privacy_Prof_Background__c,
                                    GARP_Dir_Privacy_Job_Information__c, GARP_Dir_Privacy_Additional_Detail__c, AccountId,
                                    MailingCity, MailingState, MailingCountry, KPI_FRM_Certified_Year__c, KPI_ERP_Certified_Year__c,
                                    KPI_CPE_Current_Cycle__c, KPI_CPE_Last_Completed_Cycle__c, Job_Function__c, Area_of_Concentration__c,
                                    Risk_Specialty__c, Corporate_Title__c, Company__c, Professional_Designation_ACCA__c, Professional_Designation_CA__c,
                                    Professional_Designation_CAIA__c, Professional_Designation_CFA__c, Professional_Designation_CFP__c,
                                    Professional_Designation_CIA__c, Professional_Designation_CMA__c, Professional_Designation_CMT__c,
                                    Professional_Designation_CPA__c, Professional_Designation_CQF__c, Professional_Designation_PMP__c,
                                    Professional_Designation_Other__c, Other_Qualifications__c
                                    from Contact where Id = :contactId];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getDirectorySettingsInfo','lstContact',lstContact);
        if(!lstContact.IsEmpty()) {
            Contact contact = lstContact[0];

            // Get Contracts
            List<Contract> lstContracts = [SELECT Id, Status, StartDate, EndDate, recordType.DeveloperName, Opportunity__c, Opportunity__r.StageName, Membership_Type__c, All_Requirements_Completed_Date__c,
                                           (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Approved_Credits_Total__c, CPE_Credit_Requirement__c, recordType.DeveloperName FROM Candidate_Requirements__r)
                                           FROM Contract
                                           WHERE status in ('Activated','Activated ( Auto-Renew )','Expired','Draft','Completed') AND
                                           AccountId = :contact.accountId
                                           ORDER BY recordType.DeveloperName, StartDate DESC];
            GARP_Common.debugLog('GARP_BC_MemberPortal','verifyMemberPortalAccess','lstContracts',lstContracts);

            MAP<String,Contract> mapContracts = new MAP<String,Contract>();
            if(!lstContracts.IsEmpty()) {
                for(Contract con :lstContracts) {
                    mapContracts.put(con.recordType.DeveloperName,con);
                }
            }

            //memberProfileInfo memberProfileInfo = getMemberProfileInfo(contactId);

            Contract membershipContract = mapContracts.get('Membership');
            Contract frmContract = mapContracts.get('FRM_Program');
            Contract erpContract = mapContracts.get('ERP_Program');

            Boolean isFRMCertified = False;
            Boolean isERPCertified = False;
            Boolean isIndividualMemberInGoodStanding = False;

            if(membershipContract != NULL && membershipContract.Membership_Type__c == 'Individual' && (membershipContract.status == 'Activated' || membershipContract.status == 'Activated ( Auto-Renew )')) {
                isIndividualMemberInGoodStanding = True;
            }
            if(frmContract != NULL && frmContract.status == 'Completed') {
                isFRMCertified = True;
            }
            if(erpContract != NULL && frmContract.status == 'Completed') {
                isERPCertified = True;
            }

            // User Settings
            dirInfo.memberDirectorySettings.isOptedIn = contact.GARP_Directory_Opt_In__c;
            dirInfo.memberDirectorySettings.showAdditionalDetails = contact.GARP_Dir_Privacy_Additional_Detail__c;
            dirInfo.memberDirectorySettings.showJobInformation = contact.GARP_Dir_Privacy_Job_Information__c;
            dirInfo.memberDirectorySettings.showProfessionalBackground = contact.GARP_Dir_Privacy_Prof_Background__c;
            dirInfo.memberDirectorySettings.isDirectoryConnectEnabled = contact.GARP_Directory_Connect_Feature__c;

            // Access Control
            dirInfo.hasDirectoryAccess = True;
            dirInfo.hasDirectoryCPDAccess = (isFRMCertified || isERPCertified);
            dirInfo.hasDirectoryConnectAccess = isIndividualMemberInGoodStanding;
            dirInfo.hasDirectoryAdvancedSearchAccess = isIndividualMemberInGoodStanding;
            dirInfo.hasDirectoryNonCertifiedAccess = isIndividualMemberInGoodStanding;
            dirInfo.hasDirectorySettingsAccess = (isFRMCertified || isERPCertified || isIndividualMemberInGoodStanding);

            // Preview Fields
            dirInfo.memberName = contact.Name;
            dirInfo.city = contact.MailingCity;
            dirInfo.state = contact.MailingState;
            dirInfo.country = contact.MailingCountry;
            if(isFRMCertified) {
                dirInfo.frmCertifiedYear = frmContract.All_Requirements_Completed_Date__c;
            }
            if(isERPCertified) {
                dirInfo.erpCertifiedYear = erpContract.All_Requirements_Completed_Date__c;
            }
            dirInfo.cpdCurrentCycle = contact.KPI_CPE_Current_Cycle__c;
            dirInfo.cpdLastCompletedCycle = contact.KPI_CPE_Last_Completed_Cycle__c;
            dirInfo.jobFunction = contact.Job_Function__c;
            dirInfo.areaOfConcentration = contact.Area_of_Concentration__c;
            dirInfo.riskSpecialty = contact.Risk_Specialty__c;
            dirInfo.professionalLevel = contact.Corporate_Title__c;
            dirInfo.company = contact.Company__c;

            dirInfo.Professional_Designation_ACCA = contact.Professional_Designation_ACCA__c;
            dirInfo.Professional_Designation_CA = contact.Professional_Designation_CA__c;
            dirInfo.Professional_Designation_CAIA = contact.Professional_Designation_CAIA__c;
            dirInfo.Professional_Designation_CFA = contact.Professional_Designation_CFA__c;
            dirInfo.Professional_Designation_CFP = contact.Professional_Designation_CFP__c;
            dirInfo.Professional_Designation_CIA = contact.Professional_Designation_CIA__c;
            dirInfo.Professional_Designation_CMA = contact.Professional_Designation_CMA__c;
            dirInfo.Professional_Designation_CMT = contact.Professional_Designation_CMT__c;
            dirInfo.Professional_Designation_CPA = contact.Professional_Designation_CPA__c;
            dirInfo.Professional_Designation_CQF = contact.Professional_Designation_CQF__c;
            dirInfo.Professional_Designation_PMP = contact.Professional_Designation_PMP__c;
            dirInfo.Professional_Designation_Other = contact.Professional_Designation_Other__c;
            dirInfo.Other_Qualifications = contact.Other_Qualifications__c;
        }


        return dirInfo;
    }

    public static GARP_Common.returnInfo setDirectorySettingsInfo(String contactId, memberDirectorySettings directorySettings) {
        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
        List<Contact> lstContact = [select Id, Name, GARP_Directory_Opt_In__c, GARP_Directory_Connect_Feature__c, GARP_Dir_Privacy_Prof_Background__c,
                                    GARP_Dir_Privacy_Job_Information__c, GARP_Dir_Privacy_Additional_Detail__c
                                    from Contact where Id = :contactId];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getDirectorySettingsInfo','lstContact',lstContact);
        if(!lstContact.IsEmpty()) {
            Contact contact = lstContact[0];
            contact.GARP_Directory_Opt_In__c = directorySettings.isOptedIn;
            contact.GARP_Dir_Privacy_Additional_Detail__c = directorySettings.showAdditionalDetails;
            contact.GARP_Dir_Privacy_Job_Information__c = directorySettings.showJobInformation;
            contact.GARP_Dir_Privacy_Prof_Background__c = directorySettings.showProfessionalBackground;
            contact.GARP_Directory_Connect_Feature__c = directorySettings.isDirectoryConnectEnabled;

            update contact;
            returnInfo.status = 'Success';
        } else {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'User not found';
        }

        return returnInfo;
    }

    /*
    public class memberExpertiseInfo {
        public String memberExpertise;
        public list<String> expertiseOptions;
    }

    public static memberExpertiseInfo getExpertiseInfo(String contactId) {
        memberExpertiseInfo memberExpertiseInfo = new memberExpertiseInfo();

        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','contactId',contactId);
        memberExpertiseInfo.expertiseOptions = getPickListValues('SME_Registration__c', 'Self_Identification_Topic_Tags__c');
        List<SME_Registration__c> smeRegs = [select Id, Self_Identification_Topic_Tags__c from SME_Registration__c where Contact__c = :contactId];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','smeRegs',smeRegs);

        if(!smeRegs.IsEmpty()) {
            memberExpertiseInfo.memberExpertise = smeRegs[0].Self_Identification_Topic_Tags__c;
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','memberExpertiseInfo',memberExpertiseInfo);
        return memberExpertiseInfo;
    }

    public static GARP_Common.returnInfo setExpertiseInfo(String contactId, String memberExpertise) {
        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
        GARP_Common.debugLog('GARP_BC_MemberProfile','setExpertiseInfo','contactId',contactId);

        List<SME_Registration__c> smeRegs = [select Id, Self_Identification_Topic_Tags__c from SME_Registration__c where Contact__c = :contactId];
        GARP_Common.debugLog('GARP_BC_MemberProfile','getExpertiseInfo','smeRegs',smeRegs);

        if(!smeRegs.IsEmpty()) {
            smeRegs[0].Self_Identification_Topic_Tags__c = memberExpertise;
            update smeRegs;
            returnInfo.status = 'Success';
        } else {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'SME Registration not found';
        }

        return returnInfo;
    }
    */

    // Legacy Methods for LWC

    public static Contact getMemberProfile(String contactId){

        System.debug('GARP_BC_MemberProfile.getMemberProfile:'+ contactId);

        List<Contact> lstCont = [select Id, FirstName, LastName, Email, MobilePhone, Mobile_Phone_Code__c,
                                 How_Did_You_Hear_About_Us__c, How_Did_You_Hear_About_Us_Other__c,
                                 HomePhone, OtherPhone, Fax, LinkedIn_URL__c,
                                 Mailing_Address_Company__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                                 AccountId, Account.Billing_Address_Company__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                                 Currently_Working_Status__c, Area_of_Concentration__c, Industry_Working_Year__c, Company__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c, Risk_Management_Working_Year__c,
                                 Professional_Designation_ACCA__c, Professional_Designation_CA__c, Professional_Designation_CAIA__c, Professional_Designation_CFA__c, Professional_Designation_CFP__c,
                                 Professional_Designation_CIA__c, Professional_Designation_CMA__c, Professional_Designation_CMT__c, Professional_Designation_CPA__c,
                                 Professional_Designation_CQF__c, Professional_Designation_PMP__c, Professional_Designation_Other__c, Other_Qualifications__c,
                                 School_Name__c, Degree_Program_Name__c, Highest_Degree__c, Expected_Graduation_Date__c, Expected_Graduation_Month__c, Title
                                 from Contact where Id = :contactId];

        System.debug('GARP_BC_MemberProfile.lstCont:'+ lstCont);

        if(!lstCont.isEmpty()) {
            return lstCont[0];
        } else {
            return null;
        }
    }

    public static List<Country_Code__c> getCountries(){
        return [select id, Country__c, LetterCode__c, PhoneCode__c, (select id, name, code__c from Provinces__r Order by Name) from Country_Code__c Order By Country__c];
    }

    public static List<Institution__c> getInstitutions(){
        return [select id, Institution_Name__c, RecordType.Name from Institution__c Order By Institution_Name__c];
    }

    @AuraEnabled
    public static List<GARP_MS_MemberProfile.InstitutionSearchResult> searchInstitutions(String searchTerm, String institutionType) {

        String recId = recordtypehelper.getrecordtypeidfromschema('Institution__c',institutionType);

        List<GARP_MS_MemberProfile.InstitutionSearchResult> searchResultList = new List<GARP_MS_MemberProfile.InstitutionSearchResult>();
        for(sObject so : Database.Query('Select Id, Institution_Name__c FROM Institution__c WHERE Institution_Name__c LIKE \'%' + searchTerm + '%\' AND RecordTypeId = :recId order by Institution_Name__c limit 15')) {
            String fieldvalue = (String)so.get('Institution_Name__c');
            searchResultList.add(new GARP_MS_MemberProfile.InstitutionSearchResult(fieldvalue, so.Id));
        }

        return searchResultList;
    }

    public static List<String> getPickListValues(String strObjectName, String strPicklistField) {

        List<String> retValues = new List<String>();

        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            retValues.add(objPickList.getLabel());
        }

        return retValues;
    }

    public static Boolean setMemberEmail(GARP_MS_MemberProfile.memberProfileUpdate profileUpdate){
        Boolean ret = false;

        if(profileUpdate == NULL) {
            return false;
        }

        if(profileUpdate.ContactId != NULL) {
            String userId = UserInfo.getUserId();
            System.debug('userId:' + userId);

            List<User> users = [SELECT Id, ContactId, Email, Username, Name FROM User WHERE Id = :userId];
            System.debug('users:' + users);
            if(!users.isEmpty() && users[0].Name != 'GARP Membership') {
                User user = users[0];
                if(user.Email != profileUpdate.Email) {
                    user.Email = profileUpdate.Email;
                    user.Username = profileUpdate.Email;
                    System.debug('user update:' + user);
                    if(!Test.isRunningTest()) {
                        update user;
                    }
                    ret = true;
                }
            }
        }
        return ret;
    }

    public static Boolean setMemberProfile(GARP_MS_MemberProfile.memberProfileUpdate profileUpdate){
        Boolean ret = false;

        if(profileUpdate == NULL) {
            return false;
        }

        System.debug('setMemberProfile profileUpdate:' + profileUpdate);

        if(profileUpdate.ContactId != NULL && profileUpdate.AccountId != NULL) {
            List<Contact> lstCont = [select Id, FirstName, LastName, Email, MobilePhone, Mobile_Phone_Code__c,
                                     HomePhone, OtherPhone, Fax, LinkedIn_URL__c,
                                     Mailing_Address_Company__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                                     How_Did_You_Hear_About_Us__c, How_Did_You_Hear_About_Us_Other__c,
                                     AccountId, Account.Billing_Address_Company__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry,
                                     Currently_Working_Status__c, Area_of_Concentration__c, Industry_Working_Year__c, Company__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c, Risk_Management_Working_Year__c,
                                     Professional_Designation_ACCA__c, Professional_Designation_CA__c, Professional_Designation_CAIA__c, Professional_Designation_CFA__c, Professional_Designation_CFP__c,
                                     Professional_Designation_CIA__c, Professional_Designation_CMA__c, Professional_Designation_CMT__c, Professional_Designation_CPA__c,
                                     Professional_Designation_CQF__c, Professional_Designation_PMP__c, Professional_Designation_Other__c, Other_Qualifications__c,
                                     School_Name__c, Degree_Program_Name__c, Highest_Degree__c, Expected_Graduation_Date__c, Expected_Graduation_Month__c, Title
                                     from Contact where Id = :profileUpdate.ContactId];

            System.debug('lstCont:' + lstCont);

            if(!lstCont.isEmpty()) {
                Contact updateContact = lstCont[0];
                if(profileUpdate.profileParts.NameEmail) {
                    updateContact.FirstName = profileUpdate.FirstName;
                    updateContact.LastName = profileUpdate.LastName;
                    updateContact.Email = profileUpdate.Email;
                    updateContact.MobilePhone = profileUpdate.MobilePhone;
                    updateContact.Mobile_Phone_Code__c = profileUpdate.Mobile_Phone_Code;
                    update updateContact;

                    System.debug('updateContact:' + updateContact);

                    return true;
                } else if(profileUpdate.profileParts.MailingAddress) {
                    updateContact.Mailing_Address_Company__c = profileUpdate.Mailing_Address_Company;
                    updateContact.MailingStreet = profileUpdate.MailingStreet;
                    updateContact.MailingCity = profileUpdate.MailingCity;
                    updateContact.MailingState = profileUpdate.MailingState;
                    updateContact.MailingPostalCode = profileUpdate.MailingPostalCode;
                    updateContact.MailingCountry = profileUpdate.MailingCountry;
                    update updateContact;

                    System.debug('updateContact:' + updateContact);
                    return true;

                } else if(profileUpdate.profileParts.PhoneNumbers) {
                    updateContact.HomePhone = profileUpdate.HomePhone;
                    updateContact.OtherPhone = profileUpdate.OtherPhone;
                    updateContact.Fax = profileUpdate.Fax;
                    updateContact.LinkedIn_URL__c = profileUpdate.LinkedIn_URL;
                    update updateContact;

                    System.debug('updateContact:' + updateContact);
                    return true;
                } else if(profileUpdate.profileParts.EmploymentInformation) {

                    updateContact.Currently_Working_Status__c = profileUpdate.Currently_Working_Status;
                    updateContact.Area_of_Concentration__c = profileUpdate.Area_of_Concentration;
                    updateContact.Industry_Working_Year__c = profileUpdate.Industry_Working_Year;
                    updateContact.Company__c = profileUpdate.Company;
                    updateContact.Corporate_Title__c = profileUpdate.Corporate_Title;
                    updateContact.Job_Function__c = profileUpdate.Job_Function;
                    updateContact.Risk_Specialty__c = profileUpdate.Risk_Specialty;
                    updateContact.Risk_Management_Working_Year__c = profileUpdate.Risk_Management_Working_Year;
                    updateContact.Professional_Designation_ACCA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_ACCA);
                    updateContact.Professional_Designation_CA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CA);
                    updateContact.Professional_Designation_CAIA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CAIA);
                    updateContact.Professional_Designation_CFA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CFA);
                    updateContact.Professional_Designation_CFP__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CFP);
                    updateContact.Professional_Designation_CIA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CIA);
                    updateContact.Professional_Designation_CMA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CMA);
                    updateContact.Professional_Designation_CMT__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CMT);
                    updateContact.Professional_Designation_CPA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CPA);
                    updateContact.Professional_Designation_CQF__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CQF);
                    updateContact.Professional_Designation_PMP__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_PMP);
                    updateContact.Professional_Designation_Other__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_Other);
                    updateContact.Other_Qualifications__c = profileUpdate.Other_Qualifications;

                    update updateContact;

                    System.debug('updateContact:' + updateContact);
                    return true;

                } else if(profileUpdate.profileParts.AcademicInformation) {
                    updateContact.School_Name__c = profileUpdate.School_Name;
                    updateContact.Degree_Program_Name__c = profileUpdate.Degree_Program_Name;
                    updateContact.Highest_Degree__c = profileUpdate.Highest_Degree;
                    updateContact.Expected_Graduation_Date__c = profileUpdate.Expected_Graduation_Date;
                    updateContact.Expected_Graduation_Month__c = profileUpdate.Expected_Graduation_Month;
                    update updateContact;

                    System.debug('updateContact:' + updateContact);
                    return true;

                } else if(profileUpdate.profileParts.CompanyTitle) {

                    updateContact.Company__c = profileUpdate.Company;
                    updateContact.Title = profileUpdate.Title;

                    System.debug('updateContact:' + updateContact);

                    update updateContact;
                } else if(profileUpdate.profileParts.Survey) {

                    updateContact.How_Did_You_Hear_About_Us__c = profileUpdate.How_Did_You_Hear_About_Us;

                    updateContact.Currently_Working_Status__c = profileUpdate.Currently_Working_Status;
                    updateContact.Area_of_Concentration__c = profileUpdate.Area_of_Concentration;
                    updateContact.Industry_Working_Year__c = profileUpdate.Industry_Working_Year;
                    updateContact.Company__c = profileUpdate.Company;
                    updateContact.Corporate_Title__c = profileUpdate.Corporate_Title;
                    updateContact.Job_Function__c = profileUpdate.Job_Function;
                    updateContact.Risk_Specialty__c = profileUpdate.Risk_Specialty;
                    updateContact.Risk_Management_Working_Year__c = profileUpdate.Risk_Management_Working_Year;
                    updateContact.Professional_Designation_ACCA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_ACCA);
                    updateContact.Professional_Designation_CA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CA);
                    updateContact.Professional_Designation_CAIA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CAIA);
                    updateContact.Professional_Designation_CFA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CFA);
                    updateContact.Professional_Designation_CFP__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CFP);
                    updateContact.Professional_Designation_CIA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CIA);
                    updateContact.Professional_Designation_CMA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CMA);
                    updateContact.Professional_Designation_CMT__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CMT);
                    updateContact.Professional_Designation_CPA__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CPA);
                    updateContact.Professional_Designation_CQF__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_CQF);
                    updateContact.Professional_Designation_PMP__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_PMP);
                    updateContact.Professional_Designation_Other__c = GARP_Common.setSafeBoolean(profileUpdate.Professional_Designation_Other);

                    updateContact.Other_Qualifications__c = profileUpdate.Other_Qualifications;

                    updateContact.School_Name__c = profileUpdate.School_Name;
                    updateContact.Degree_Program_Name__c = profileUpdate.Degree_Program_Name;
                    updateContact.Highest_Degree__c = profileUpdate.Highest_Degree;
                    updateContact.Expected_Graduation_Date__c = profileUpdate.Expected_Graduation_Date;
                    updateContact.Expected_Graduation_Month__c = profileUpdate.Expected_Graduation_Month;
                    update updateContact;

                    System.debug('updateContact:' + updateContact);
                    return true;

                } else if(profileUpdate.profileParts.BillingAddress) {
                    List<Account> lstAcct = [select Id, Billing_Address_Company__c, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry from Account where Id = :profileUpdate.AccountId];
                    if(!lstAcct.isEmpty()) {
                        Account updateAcct = lstAcct[0];
                        updateAcct.Billing_Address_Company__c = profileUpdate.Billing_Address_Company;
                        updateAcct.BillingStreet = profileUpdate.BillingStreet;
                        updateAcct.BillingCity = profileUpdate.BillingCity;
                        updateAcct.BillingState = profileUpdate.BillingState;
                        updateAcct.BillingPostalCode = profileUpdate.BillingPostalCode;
                        updateAcct.BillingCountry = profileUpdate.BillingCountry;

                        System.debug('updateAcct:' + updateAcct);
                        update updateAcct;
                        ret = true;
                    }
                }
            }
        }
        return ret;
    }

    public static Boolean updateMemberProfileSummary(String contactId) {
        Boolean ret;
        MAP<String,String> mapExistingMemProfileIdContactIds = new MAP<String,String>();
        MAP<String,Member_Profile_Summary__c> mapContactMemProfiles = new MAP<String,Member_Profile_Summary__c>();
        List<Contact> lstNewContacts = new List<Contact>();
        List<Contact> lstExsitingContacts = new List<Contact>();
        Set<String> accountIDs = new Set<String>();
        Set<String> contactIDs = new Set<String>();
        Set<Contact> neededContacts = new Set<Contact>();

        List<Contact> lstContacts = [SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c from Contact where id = :contactId];
        if(!lstContacts.IsEmpty()) {
            Contact cont = lstContacts[0];
            if(cont.Member_Profile_Summary__c != NULL) {
                mapExistingMemProfileIdContactIds.put(cont.Member_Profile_Summary__c, cont.Id);
            } else {
                lstNewContacts.add(cont);
                Member_Profile_Summary__c newMemProfile = new Member_Profile_Summary__c();
                newMemProfile.ContactId__c = cont.Id;
                mapContactMemProfiles.put(cont.Id, newMemProfile);
            }
            contactIDs.add(cont.Id);
            contactIDs.add(cont.AccountId);
            neededContacts.add(cont);
        }
        ret = calcMemberProfileSummary(mapExistingMemProfileIdContactIds, mapContactMemProfiles, accountIDs, contactIDs, neededContacts, lstNewContacts, lstExsitingContacts, 'normal', true, false);
        return ret;
    }

    //List<String> updateContactIds = new List<String>();
    //updateContactIds.add('0034000001acwmY');
    //GARP_BC_MemberProfile.updateMemberProfileSummarys(updateContactIds);

    public static Boolean updateMemberProfileSummarys(List<String> updateContactIds) {
        Boolean ret;
        MAP<String,String> mapExistingMemProfileIdContactIds = new MAP<String,String>();

        MAP<String,Member_Profile_Summary__c> mapContactMemProfiles = new MAP<String,Member_Profile_Summary__c>();
        List<Contact> lstNewContacts = new List<Contact>();
        List<Contact> lstExsitingContacts = new List<Contact>();
        Set<String> accountIDs = new Set<String>();
        Set<String> contactIDs = new Set<String>();
        Set<Contact> neededContacts = new Set<Contact>();

        List<Contact> lstContacts = [SELECT Id, AccountId, Member_Profile_Summary__c, Member_Profile_Last_Updated__c from Contact where id in :updateContactIds];
        if(!lstContacts.IsEmpty()) {
            for(Contact cont :lstContacts) {
                if(cont.Member_Profile_Summary__c != NULL) {
                    mapExistingMemProfileIdContactIds.put(cont.Member_Profile_Summary__c, cont.Id);
                } else {
                    lstNewContacts.add(cont);
                    Member_Profile_Summary__c newMemProfile = new Member_Profile_Summary__c();
                    newMemProfile.ContactId__c = cont.Id;
                    mapContactMemProfiles.put(cont.Id, newMemProfile);
                }
                contactIDs.add(cont.Id);
                accountIDs.add(cont.AccountId);
                neededContacts.add(cont);
            }
        }
        ret = calcMemberProfileSummary(mapExistingMemProfileIdContactIds, mapContactMemProfiles, accountIDs, contactIDs, neededContacts, lstNewContacts, lstExsitingContacts, 'normal', true, false);
        return ret;
    }

    public static Member_Profile_Summary__c setRevenueByProduct(Member_Profile_Summary__c mp, Opportunity opp, oppInfo oppInfo, String debug) {

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','setRevenueByProduct','mp',mp);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','setRevenueByProduct','opp',opp);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','setRevenueByProduct','oppInfo',oppInfo);

        if(oppInfo.orderSummaryProductLine == 'ERP') {
            if(mp.ERP_Orders__c == NULL) {
                mp.ERP_Orders__c = 1;
                mp.ERP_Revenue__c = opp.Amount;
            } else {
                mp.ERP_Orders__c++;
                mp.ERP_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'Events') {
            if(mp.Events_Orders__c == NULL) {
                mp.Events_Orders__c = 1;
                mp.Events_Revenue__c = opp.Amount;
            } else {
                mp.Events_Orders__c++;
                mp.Events_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'FFR') {
            if(mp.FFR_Orders__c == NULL) {
                mp.FFR_Orders__c = 1;
                mp.FFR_Revenue__c = opp.Amount;
            } else {
                mp.FFR_Orders__c++;
                mp.FFR_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'FRM') {
            if(mp.FRM_Orders__c == NULL) {
                mp.FRM_Orders__c = 1;
                mp.FRM_Revenue__c = opp.Amount;
            } else {
                mp.FRM_Orders__c++;
                mp.FRM_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'FRR') {
            if(mp.FRR_Orders__c == NULL) {
                mp.FRR_Orders__c = 1;
                mp.FRR_Revenue__c = opp.Amount;
            } else {
                mp.FRR_Orders__c++;
                mp.FRR_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'GARP') {
            if(mp.GARP_Orders__c == NULL) {
                mp.GARP_Orders__c = 1;
                mp.GARP_Revenue__c = opp.Amount;
            } else {
                mp.GARP_Orders__c++;
                mp.GARP_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'GARP Content') {
            if(mp.GARP_Content_Orders__c == NULL) {
                mp.GARP_Content_Orders__c = 1;
                mp.GARP_Content_Revenue__c = opp.Amount;
            } else {
                mp.GARP_Content_Orders__c++;
                mp.GARP_Content_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'Membership') {
            if(mp.Membership_Orders__c == NULL) {
                mp.Membership_Orders__c = 1;
                mp.Membership_Revenue__c = opp.Amount;
            } else {
                mp.Membership_Orders__c++;
                mp.Membership_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'RAI') {
            if(mp.RAI_Orders__c == NULL) {
                mp.RAI_Orders__c = 1;
                mp.RAI_Revenue__c = opp.Amount;
            } else {
                mp.RAI_Orders__c++;
                mp.RAI_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'SCR') {
            if(mp.SCR_Orders__c == NULL) {
                mp.SCR_Orders__c = 1;
                mp.SCR_Revenue__c = opp.Amount;
            } else {
                mp.SCR_Orders__c++;
                mp.SCR_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'FRR25') {
            if(mp.FRR_Series_Orders__c == NULL) {
                mp.FRR_Series_Orders__c = 1;
                mp.FRR_Series_Revenue__c = opp.Amount;
            } else {
                mp.FRR_Series_Orders__c++;
                mp.FRR_Series_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'Micro Course') {
            if(mp.Micro_Course_Orders__c == NULL) {
                mp.Micro_Course_Orders__c = 1;
                mp.Micro_Course_Revenue__c = opp.Amount;
            } else {
                mp.Micro_Course_Orders__c++;
                mp.Micro_Course_Revenue__c += opp.Amount;
            }
        } else if(oppInfo.orderSummaryProductLine == 'Unknown') {
            if(mp.Unknown_Orders__c == NULL) {
                mp.Unknown_Orders__c = 1;
                mp.Unknown_Revenue__c = opp.Amount;
            } else {
                mp.Unknown_Orders__c++;
                mp.Unknown_Revenue__c += opp.Amount;
            }
        } else {
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','setRevenueByProduct','*** Unknown Type',oppInfo.oppType);
        }

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','setRevenueByProduct','mp',mp);


        return mp;
    }


    public class OpportunityCloseDateComparator implements System.Comparator<Opportunity> {
        // Compare two Opportunity records by CloseDate
        public Integer compare(Opportunity o1, Opportunity o2) {
            if (o1.Closed_Date__c == o2.Closed_Date__c) {
                return 0;   // equal
            } else if (o1.Closed_Date__c < o2.Closed_Date__c) {
                return -1;  // o1 comes before o2
            } else {
                return 1;   // o1 comes after o2
            }
        }
    }


    public class OpportunityComparator implements Comparator<Opportunity> {
        public Integer compare(Opportunity o1, Opportunity o2) {
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;

            if(o1 == null && o2 == null) {
                returnValue = 0;
            } else if(o1 == null) {
                // nulls-first implementation
                returnValue = -1;
            } else if(o2 == null) {
                // nulls-first implementation
                returnValue = 1;
            } else if ((o1.Closed_Date__c == null) && (o2.Closed_Date__c == null)) {
                // both have null Amounts
                returnValue = 0;
            } else if (o1.Closed_Date__c == null){
                // nulls-first implementation
                returnValue = -1;
            } else if (o2.Closed_Date__c == null){
                // nulls-first implementation
                returnValue = 1;
            } else if (o1.Closed_Date__c < o2.Closed_Date__c || o1.Order_Summary_Membership_Type__c == 'Affiliate') {
                // Set return value to a negative value.
                returnValue = -1;
            } else if (o1.Closed_Date__c > o2.Closed_Date__c || o2.Order_Summary_Membership_Type__c == 'Affiliate') {
                // Set return value to a positive value.
                returnValue = 1;
            }
            return returnValue;
        }
    }

    public class returnFindContract {
        public Boolean isOnlyOpp;
        public Boolean isNearStart;
        public Boolean isNearEnd;
        public Contract contract;
    }

    public static returnFindContract findMembershipContract(String oppId, String accountId, Date OppCloseDate, MAP<String, List<Contract>> mapAccountContracts, String debug) {

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','oppId',oppId);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','accountId',accountId);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','OppCloseDate',OppCloseDate);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','mapAccountContracts',mapAccountContracts);

        returnFindContract ret = new returnFindContract();
        ret.isOnlyOpp = False;
        ret.isNearStart = False;
        ret.isNearEnd = False;
        ret.contract = NULL;

        List<Contract> contracts = mapAccountContracts.get(accountId);

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','contracts',contracts);


        if(contracts != NULL && !contracts.IsEmpty()) {
            /*
            for(Contract contract :contracts) {

                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','Loop contracts',contract);

                if(contract.recordType.DeveloperName == 'Membership' && ((contract.Membership_Type__c == 'Individual' && contract.Status != 'Canceled') || contract.Membership_Type__c == 'Affiliate')) {

                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','Yes look contract',contract.Membership_Type__c + ':' + contract.Membership_Type__c);

                    if(contract.Opportunity__c == oppId) {
                        ret.contract = contract;

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','Yes is opp contract','');

                        if(OppCloseDate < contract.StartDate.AddDays(30)) {
                            ret.isNearStart = True;
                        } else if(OppCloseDate > contract.EndDate.AddDays(-30)) {
                            ret.isNearEnd = True;
                        }

                        if(contract.ContractTerm == 12 || contract.ContractTerm == 6) {
                            ret.isOnlyOpp = True;
                        }

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.contract',ret.contract);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isNearStart',ret.isNearStart);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isNearEnd',ret.isNearEnd);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isOnlyOpp',ret.isOnlyOpp);

                        return ret;
                    }
                }
            }
            */

            // Loop Most Recent First
            for(Contract contract :contracts) {

                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','Search by date Loop contracts',contract);

                if(contract.recordType.DeveloperName == 'Membership' && contract.Membership_Type__c == 'Individual' && contract.Status != 'Canceled') {

                    if(OppCloseDate >= contract.StartDate && OppCloseDate <= contract.EndDate) {

                        ret.contract = contract;

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','Found contract',contract);

                        if(OppCloseDate < contract.StartDate.AddDays(30)) {
                            ret.isNearStart = True;
                        } else if(OppCloseDate > contract.EndDate.AddDays(-30)) {
                            ret.isNearEnd = True;
                        }

                        if(contract.ContractTerm == 12 || contract.ContractTerm == 6) {
                            ret.isOnlyOpp = True;
                        }

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.contract',ret.contract);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isNearStart',ret.isNearStart);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isNearEnd',ret.isNearEnd);
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','findMembershipContract','ret.isOnlyOpp',ret.isOnlyOpp);

                        return ret;
                    }
                }
            }
        }
        return NULL;
    }

    public static Boolean calcMemberProfileSummary(MAP<String,String> mapExistingMemProfileIdContactIds, MAP<String,Member_Profile_Summary__c> mapContactMemProfiles, Set<String> accountIDs, Set<String> contactIDs, Set<Contact> neededContacts, List<Contact> lstNewContacts, List<Contact> lstExsitingContacts, String debug, Boolean doUpdates, Boolean forceOppUpdates) {
        Boolean ret;
        Date tdy = Date.Today();

        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapExistingMemProfileIdContactIds',mapExistingMemProfileIdContactIds);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactMemProfiles',mapContactMemProfiles);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','accountIDs',accountIDs);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','contactIDs',contactIDs);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','neededContacts',neededContacts);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstNewContacts',lstNewContacts);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstExsitingContacts',lstExsitingContacts);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','debug',debug);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','doUpdates',doUpdates);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','forceOppUpdates',forceOppUpdates);

        String query = 'Select Id, Found_Bad_Contracts__c, Found_Bad_Contracts_Type__c, ContactId__c, CreatedDate, ERP_Completed__c, ERP_Completed_Date__c, ERP_Program_Expire_Date__c, ERP_Program_Start_Date__c, FFR_Program_Expire_Date__c, ';
        query += 'FFR_Program_Start_Date__c, FRM_Attempts__c, FRM_Completed__c, FRM_Completed_Date__c, FRM_CV_Status__c, FRM_Program_Expire_Date__c, FRM_Program_Start_Date__c, FRM_Program_Status__c, ';
        query += 'FRM_Part_I_Next_Exam_Admin__c, FRM_Part_I_Last_Exam_Admin__c, FRM_Part_I_Last_Result__c, FRM_Part_I_Last_Score__c, FRM_Part_II_Next_Exam_Admin__c, FRM_Part_II_Last_Exam_Admin__c, ';
        query += 'FRM_Part_II_Last_Result__c, FRM_Part_II_Last_Score__c, FRR_Attempts__c, FRR_Completed__c, FRR_Completed_Date__c, FRR_Last_Result__c, FRR_Last_Taken_Date__c, FRR_Program_Expire_Date__c, ';
        query += 'FRR_Program_Start_Date__c, FRR25_Attempts__c, FRR25_Completed__c, FRR25_Completed_Date__c, FRR25_Last_Result__c, FRR25_Last_Taken_Date__c, FRR25_Program_Expire_Date__c, ';
        query += 'FRR25_Program_Start_Date__c, Membership_Autorenew_On__c, Membership_Days_Since_Lapsed__c, Membership_Has_Risk_Net__c, Membership_Next_Renewal_Date__c, Membership_Number_of_Renewals__c, ';
        query += 'Membership_Last_Renewal_Date__c, Membership_Days_as_Member__c, Membership_Status__c, Membership_Type__c, Membership_Original_Type__c, Membership_Start_Date__c, Membership_Expire_Date__c, ';
        query += 'Membership_Is_Complimentary__c, Membership_Individual_Original_Source__c, Membership_Individual_Original_Date__c, Membership_Individual_Latest_Start_Date__c, Membership_Individual_Latest_End_Date__c, Membership_Affiliate_Original_Source__c, Membership_Affiliate_Original_Date__c, ';
        query += 'Membership_Affiliate_Original_AMP__c, Orders_First_Products__c, Orders_First_Amount__c, Orders_First_Date__c, Orders_First_Type__c, Orders_Last_Amount__c, Orders_Last_Date__c, Orders_Last_Type__c, ';

        query += 'ERP_Orders__c, ERP_Revenue__c, Events_Orders__c, Events_Revenue__c, FFR_Orders__c, FFR_Revenue__c, FRM_Orders__c, FRM_Revenue__c, FRR_Orders__c, FRR_Revenue__c, GARP_Orders__c, GARP_Revenue__c, ';
        query += 'GARP_Content_Orders__c, GARP_Content_Revenue__c, Membership_Orders__c, Membership_Revenue__c, RAI_Orders__c, RAI_Revenue__c, SCR_Orders__c, SCR_Revenue__c, FRR_Series_Orders__c, FRR_Series_Revenue__c, ';
        query += 'Micro_Course_Orders__c, Micro_Course_Revenue__c, Unknown_Orders__c, Unknown_Revenue__c, ';

        query += 'Orders_Placed__c, Orders_Total_Revenue__c, SCR_Attempts__c, SCR_Completed__c, SCR_Completed_Date__c, SCR_Next_Exam_Admin__c, SCR_Last_Exam_Admin__c, SCR_Last_Result__c, SCR_Last_Score__c, ';
        query += 'SCR_Program_Start_Date__c, RAI_Attempts__c, RAI_Completed__c, RAI_Completed_Date__c, RAI_Next_Exam_Admin__c, RAI_Last_Exam_Admin__c, RAI_Last_Result__c, RAI_Last_Score__c, RAI_Program_Start_Date__c, ';
        query += 'Event_Registrations__c, Event_First_Registration_Date__c, Chapter_Meeting_First_Registration_Date__c, Chapter_Meeting_Registrations__c, Webcast_First_Registration_Date__c, Webcast_Registrations__c, ';
        query += 'Source_First_Date__c, Source_First_Type__c, Source_First_Paid__c, Source_Last_Date__c, Source_Last_Type__c, Source_UTM_Campaign__c, Source_UTM_Content__c, Source_UTM_Medium__c, Source_UTM_Source__c, Source_UTM_Term__c';

        // Get Mirco Course Info
         List<Exam__c> lstExam = [select id, Name, MC_Course_Non_Member_Product_Code__c, MC_Course_Member_Product_Code__c, MC_Course_Certified_Product_Code__c,
                                  MC_Course_Retake_Product_Code__c from Exam__c where Exam_Group__r.RecordType.Name = 'MicroCourse'];
     //, Course_Program_Record_Type_API_Name__c
        MAP<String,String> mapMicroCourseByProductCodes = new MAP<String,String>();
        MAP<String,Exam__c> mapMicroCourseByProgramType = new MAP<String,Exam__c>();
        MAP<String,Exam__c> mapMicroCourseByName = new MAP<String,Exam__c>();

        Set<String> existingMemberProfileSummaryIDs = mapExistingMemProfileIdContactIds.KeySet();
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','existingMemberProfileSummaryIDs',existingMemberProfileSummaryIDs);

        for(Exam__c ex :lstExam) {
            mapMicroCourseByProductCodes.put(ex.Name, ex.MC_Course_Non_Member_Product_Code__c + ':' + ex.MC_Course_Member_Product_Code__c + ':' + ex.MC_Course_Certified_Product_Code__c + ':' + ex.MC_Course_Retake_Product_Code__c);
             //mapMicroCourseByProgramType.put(ex.Course_Program_Record_Type_API_Name__c, ex);
             mapMicroCourseByName.put(ex.Name, ex);

             String addQuery = '';

             // Add to Query
             addQuery += ', ' + ex.Name + '_Program_Start_Date__c';
             addQuery += ', ' + ex.Name + '_Program_Expire_Date__c';
             addQuery += ', ' + ex.Name + '_Attempts__c';
             addQuery += ', ' + ex.Name + '_Last_Taken_Date__c';
             addQuery += ', ' + ex.Name + '_Last_Result__c';
             addQuery += ', ' + ex.Name + '_Completed__c';
             addQuery += ', ' + ex.Name + '_Completed_Date__c';

             GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','addQuery',addQuery);

             query += addQuery;
         }

        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapMicroCourseByProductCodes',mapMicroCourseByProductCodes);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapMicroCourseByProgramType',mapMicroCourseByProgramType);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapMicroCourseByName',mapMicroCourseByName);


        query += ' FROM Member_Profile_Summary__c Where Id in :existingMemberProfileSummaryIDs';

        List<Member_Profile_Summary__c> lstMemProSums = Database.query(query);

        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','query',query);

        /*
        List<Member_Profile_Summary__c> lstMemProSums = [select Id, ContactId__c, CreatedDate, ERP_Completed__c, ERP_Completed_Date__c, ERP_Program_Expire_Date__c, ERP_Program_Start_Date__c,
                                                         FFR_Program_Expire_Date__c, FFR_Program_Start_Date__c, FRM_Attempts__c, FRM_Completed__c,
                                                         FRM_Completed_Date__c, FRM_CV_Status__c, FRM_Program_Expire_Date__c, FRM_Program_Start_Date__c,
                                                         FRM_Part_I_Next_Exam_Admin__c, FRM_Part_I_Last_Exam_Admin__c, FRM_Part_I_Last_Result__c, FRM_Part_I_Last_Score__c,
                                                         FRM_Part_II_Next_Exam_Admin__c, FRM_Part_II_Last_Exam_Admin__c, FRM_Part_II_Last_Result__c, FRM_Part_II_Last_Score__c,
                                                         FRR_Attempts__c, FRR_Completed__c, FRR_Completed_Date__c, FRR_Last_Result__c,
                                                         FRR_Last_Taken_Date__c, FRR_Program_Expire_Date__c, FRR_Program_Start_Date__c,
                                                         FRR25_Attempts__c, FRR25_Completed__c, FRR25_Completed_Date__c, FRR25_Last_Result__c,
                                                         FRR25_Last_Taken_Date__c, FRR25_Program_Expire_Date__c, FRR25_Program_Start_Date__c,
                                                         Membership_Autorenew_On__c, Membership_Days_Since_Lapsed__c,
                                                         Membership_Has_Risk_Net__c, Membership_Next_Renewal_Date__c, Membership_Number_of_Renewals__c, Membership_Last_Renewal_Date__c,
                                                         Membership_Days_as_Member__c, Membership_Status__c, Membership_Type__c, Membership_Original_Type__c, Membership_Start_Date__c, Membership_Expire_Date__c,
                                                         Membership_Is_Complimentary__c, Membership_Individual_Original_Source__c, Membership_Individual_Original_Date__c,
                                                         Membership_Affiliate_Original_Source__c, Membership_Affiliate_Original_Date__c, Membership_Affiliate_Original_AMP__c,
                                                         Orders_First_Products__c, Orders_First_Amount__c, Orders_First_Date__c, Orders_First_Type__c, Orders_Last_Amount__c, Orders_Last_Date__c, Orders_Last_Type__c, Orders_Placed__c, Orders_Total_Revenue__c,
                                                         SCR_Attempts__c, SCR_Completed__c, SCR_Completed_Date__c,
                                                         SCR_Next_Exam_Admin__c, SCR_Last_Exam_Admin__c, SCR_Last_Result__c, SCR_Last_Score__c, SCR_Program_Start_Date__c,

                                                         RAI_Attempts__c, RAI_Completed__c, RAI_Completed_Date__c,
                                                         RAI_Next_Exam_Admin__c, RAI_Last_Exam_Admin__c, RAI_Last_Result__c, RAI_Last_Score__c, RAI_Program_Start_Date__c,

                                                         Event_Registrations__c, Event_First_Registration_Date__c, Chapter_Meeting_First_Registration_Date__c, Chapter_Meeting_Registrations__c,
                                                         Webcast_First_Registration_Date__c, Webcast_Registrations__c,
                                                         Source_First_Date__c, Source_First_Type__c, Source_First_Paid__c, Source_Last_Date__c, Source_Last_Type__c,
                                                         Source_UTM_Campaign__c, Source_UTM_Content__c, Source_UTM_Medium__c, Source_UTM_Source__c, Source_UTM_Term__c
                                                         FROM Member_Profile_Summary__c Where Id in :existingMemberProfileSummaryIDs];
        */
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstMemProSums',lstMemProSums);

        if(!lstMemProSums.IsEmpty()) {
            for(Member_Profile_Summary__c mp :lstMemProSums) {

                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop lstMemProSums',mp);

                // Reset All Values
                mp.Found_Bad_Contracts__c = NULL;
                mp.Found_Bad_Contracts_Type__c = NULL;

                mp.ERP_Completed__c = FALSE;
                mp.ERP_Completed_Date__c = NULL;
                mp.ERP_Program_Expire_Date__c = NULL;
                mp.ERP_Program_Start_Date__c = NULL;
                mp.FFR_Program_Expire_Date__c = NULL;
                mp.FFR_Program_Start_Date__c = NULL;
                mp.FRM_Attempts__c = NULL;
                mp.FRM_Completed__c = FALSE;
                mp.FRM_Completed_Date__c = NULL;
                mp.FRM_CV_Status__c = NULL;
                mp.FRM_Program_Expire_Date__c = NULL;
                mp.FRM_Program_Start_Date__c = NULL;
                mp.FRM_Program_Status__c = NULL;

                mp.FRM_Part_I_Next_Exam_Admin__c = NULL;
                mp.FRM_Part_I_Last_Exam_Admin__c = NULL;
                mp.FRM_Part_I_Last_Result__c = NULL;
                mp.FRM_Part_I_Last_Score__c = NULL;
                mp.FRM_Part_II_Next_Exam_Admin__c = NULL;
                mp.FRM_Part_II_Last_Exam_Admin__c = NULL;
                mp.FRM_Part_II_Last_Result__c = NULL;
                mp.FRM_Part_II_Last_Score__c = NULL;

                mp.FRR_Attempts__c = NULL;
                mp.FRR_Completed__c = FALSE;
                mp.FRR_Completed_Date__c = NULL;
                mp.FRR_Last_Taken_Date__c = NULL;
                mp.FRR_Last_Result__c = NULL;
                mp.FRR_Program_Expire_Date__c = NULL;
                mp.FRR_Program_Start_Date__c = NULL;

                mp.FRR25_Attempts__c = NULL;
                mp.FRR25_Completed__c = FALSE;
                mp.FRR25_Completed_Date__c = NULL;
                mp.FRR25_Last_Taken_Date__c = NULL;
                mp.FRR25_Last_Result__c = NULL;
                mp.FRR25_Program_Expire_Date__c = NULL;
                mp.FRR25_Program_Start_Date__c = NULL;

                mp.Membership_Autorenew_On__c = FALSE;
                mp.Membership_Days_Since_Lapsed__c = NULL;
                mp.Membership_Has_Risk_Net__c = FALSE;
                mp.Membership_Next_Renewal_Date__c = NULL;
                mp.Membership_Number_of_Renewals__c = NULL;
                mp.Membership_Last_Renewal_Date__c = NULL;
                mp.Membership_Days_as_Member__c = NULL;
                mp.Membership_Status__c = NULL;
                mp.Membership_Type__c = NULL;
                mp.Membership_Start_Date__c = NULL;
                mp.Membership_Expire_Date__c = NULL;
                mp.Membership_Is_Complimentary__c = FALSE;
                mp.Membership_Individual_Original_Source__c = NULL;
                mp.Membership_Individual_Original_Date__c = NULL;
                mp.Membership_Affiliate_Original_Source__c = NULL;
                mp.Membership_Affiliate_Original_Date__c = NULL;
                mp.Membership_Original_Type__c = NULL;

                mp.Membership_Individual_Latest_Start_Date__c = NULL;
                mp.Membership_Individual_Latest_End_Date__c = NULL;

                mp.Orders_First_Products__c = NULL;
                mp.Orders_First_Amount__c = NULL;
                mp.Orders_First_Date__c = NULL;
                mp.Orders_First_Type__c = NULL;
                mp.Orders_Last_Amount__c = NULL;
                mp.Orders_Last_Date__c = NULL;
                mp.Orders_Last_Type__c = NULL;
                mp.Orders_Placed__c = NULL;
                mp.Orders_Total_Revenue__c = NULL;

                mp.ERP_Orders__c = NULL;
                mp.ERP_Revenue__c = NULL;
                mp.Events_Orders__c = NULL;
                mp.Events_Revenue__c = NULL;
                mp.FFR_Orders__c = NULL;
                mp.FFR_Revenue__c = NULL;
                mp.FRM_Orders__c = NULL;
                mp.FRM_Revenue__c = NULL;
                mp.FRR_Orders__c = NULL;
                mp.FRR_Revenue__c = NULL;
                mp.GARP_Orders__c = NULL;
                mp.GARP_Revenue__c = NULL;
                mp.GARP_Content_Orders__c = NULL;
                mp.GARP_Content_Revenue__c = NULL;
                mp.Membership_Orders__c = NULL;
                mp.Membership_Revenue__c = NULL;
                mp.RAI_Orders__c = NULL;
                mp.RAI_Revenue__c = NULL;
                mp.SCR_Orders__c = NULL;
                mp.SCR_Revenue__c = NULL;
                mp.FRR_Series_Orders__c = NULL;
                mp.FRR_Series_Revenue__c = NULL;
                mp.Micro_Course_Orders__c = NULL;
                mp.Micro_Course_Revenue__c = NULL;
                mp.Unknown_Orders__c = NULL;
                mp.Unknown_Revenue__c = NULL;


                mp.SCR_Attempts__c = NULL;
                mp.SCR_Completed__c = FALSE;
                mp.SCR_Completed_Date__c = NULL;
                mp.SCR_Program_Start_Date__c = NULL;
                mp.SCR_Next_Exam_Admin__c = NULL;
                mp.SCR_Last_Exam_Admin__c = NULL;
                mp.SCR_Last_Result__c = NULL;
                mp.SCR_Last_Score__c = NULL;

                mp.RAI_Attempts__c = NULL;
                mp.RAI_Completed__c = FALSE;
                mp.RAI_Completed_Date__c = NULL;
                mp.RAI_Program_Start_Date__c = NULL;
                mp.RAI_Next_Exam_Admin__c = NULL;
                mp.RAI_Last_Exam_Admin__c = NULL;
                mp.RAI_Last_Result__c = NULL;
                mp.RAI_Last_Score__c = NULL;

                mp.Source_UTM_Campaign__c = NULL;
                mp.Source_UTM_Content__c = NULL;
                mp.Source_UTM_Medium__c = NULL;
                mp.Source_UTM_Source__c = NULL;
                mp.Source_UTM_Term__c = NULL;

                mp.Event_Registrations__c = NULL;
                mp.Event_First_Registration_Date__c = NULL;
                mp.Chapter_Meeting_First_Registration_Date__c = NULL;
                mp.Chapter_Meeting_Registrations__c = NULL;
                mp.Source_First_Date__c = NULL;
                mp.Source_First_Type__c = NULL;
                mp.Source_First_Paid__c = FALSE;
                mp.Source_Last_Date__c = NULL;
                mp.Source_Last_Type__c = NULL;
                mp.Webcast_First_Registration_Date__c = NULL;
                mp.Webcast_Registrations__c = NULL;

                // Set Micro Course Info
                if(!lstExam.IsEmpty()) {
                    for(Exam__c ex :lstExam) {
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop lstExam',ex);

                        mp.put(ex.Name + '_Program_Start_Date__c', NULL);
                        mp.put(ex.Name + '_Program_Expire_Date__c', NULL);
                        mp.put(ex.Name + '_Attempts__c', NULL);
                        mp.put(ex.Name + '_Last_Taken_Date__c', NULL);
                        mp.put(ex.Name + '_Last_Result__c', NULL);
                        mp.put(ex.Name + '_Completed__c', FALSE);
                        mp.put(ex.Name + '_Completed_Date__c', NULL);
                    }
                }

                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final mp',mp);

                String fndContact = mapExistingMemProfileIdContactIds.get(mp.Id);
                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndContact',fndContact);

                if(fndContact != NULL) {
                    mp.ContactId__c = fndContact;
                    mapContactMemProfiles.put(fndContact, mp);
                }

                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','add mapContactMemProfiles',mapContactMemProfiles);
            }
        }

        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactMemProfiles',mapContactMemProfiles);

        // Query all the data and put in maps
        MAP<String, List<Contract>> mapAccountContracts = new MAP<String, List<Contract>>();
        List<Contract> lstContracts = [select Id, AccountId, recordType.DeveloperName, recordType.Name, StartDate, EndDate, Status, ContractTerm, Opportunity__c, All_Requirements_Completed_Date__c, Membership_Type__c,
                                       (SELECT Id, Name, Status__c, Date_of_Completion__c, Exam__c, Recordtype.Developername FROM Candidate_Requirements__r)
                                       from Contract
                                       where status != 'Draft' AND StartDate != NULL AND EndDate != NULL AND AccountId in :accountIDs
                                       ORDER BY recordType.Name DESC, StartDate DESC, CreatedDate DESC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstContracts',lstContracts);

        for(Contract cont :lstContracts) {
            List<Contract> fndConts = mapAccountContracts.get(cont.AccountId);
            if(fndConts == NULL) {
                fndConts = new List<Contract>();
            }
            fndConts.add(cont);
            mapAccountContracts.put(cont.AccountId, fndConts);
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapAccountContracts',mapAccountContracts);

        MAP<String, List<Exam_Attempt__c>> mapContactExamAttempts = new MAP<String, List<Exam_Attempt__c>>();
        List<Exam_Attempt__c> lstExamAttempts = [select Id, RPT_Exam_Program__c, Member__c, Result__c, Reg_Status__c, Exam_Site__r.Exam__r.Exam__c,
                                                 RPT_Administration_Month__c, RPT_Administration_Year__c, RPT_Exam_Part__c, Icbrr_Exam_Date__c,
                                                 Quartile_1__c, Quartile_2__c, Quartile_3__c,
                                                 Quartile_4__c, Quartile_5__c, Quartile_6__c, Quartile_7__c, Quartile_8__c
                                                 from Exam_Attempt__c
                                                 where Member__c in :contactIDs AND Cancelled__c = FALSE AND
                                                 Opportunity__c != NULL AND Opportunity_StageName__c = 'Closed'
                                                 ORDER BY RPT_Administration_Date__c DESC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstExamAttempts',lstExamAttempts);

        for(Exam_Attempt__c ea :lstExamAttempts) {
            List<Exam_Attempt__c> fndEAs = mapContactExamAttempts.get(ea.Member__c);
            if(fndEAs == NULL) {
                fndEAs = new List<Exam_Attempt__c>();
            }
            fndEAs.add(ea);
            mapContactExamAttempts.put(ea.Member__c, fndEAs);
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactExamAttempts',mapContactExamAttempts);

         MAP<String, List<Opportunity>> mapAccountOpportunites = new MAP<String, List<Opportunity>>();
         MAP<String, Opportunity> mapOpportunitesById = new MAP<String, Opportunity>();
         SET<String> setRefundedOpportunites = new SET<String>();
         MAP<String, Opportunity> updateOpps = new MAP<String, Opportunity>();

         MAP<String, Opportunity> lastOppByAccountId = new MAP<String, Opportunity>();
         MAP<String, Opportunity> sisterOpps = new MAP<String, Opportunity>();

        List<Opportunity> lstOpps = [select Id, Name, AccountId, Amount, StageName, Alternate_Method_of_Payment__c, Purchase_Date__c, Purchase_Date_Time__c, Closed_Date__c,
                                     Order_Summary_Last_Updated_Date__c, Order_Summary_Product_Line__c, Order_Summary_Payment_Status__c, Order_Summary_Is_Scholarship__c, Order_summary_Is_B2B__c, Auto_Renew__c,
                                     Order_Summary_Membership_Business_Type__c, Order_Summary_Membership_Is_AutoRenew__c, Order_Summary_Membership_Payment__c, Order_Summary_Membership_Type__c, Order_Summary_Membership_Lapsed__c,
                                     Order_Summary_Membership_Start_Date__c, Order_Summary_Membership_End_Date__c,
                                     (SELECT Id, ProductCode, Product2.GL_Code__c, Product2.Name, Product2.Product_ID__c, Description,
                                      PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Order_Summary_Product_Name__c,
                                      Order_Summary_Product_Category__c, Order_Summary_Product_Line__c, Order_summary_Is_B2B__c, Order_Summary_Is_Scholarship__c
                                      FROM OpportunityLineItems),
                                     (SELECT Id, Product_Code__c, Refund_amount__c from Product_Refunds__r where Status__c = 'Completed'),
                                     (SELECT Id, ChargentOrders__Gateway_Date__c from Transactions__r where ChargentOrders__Gateway_Date__c != NULL AND ChargentOrders__Type__c = 'Charge' AND ChargentOrders__Response_Status__c = 'Approved' ORDER BY ChargentOrders__Gateway_Date__c ASC),
                                     (SELECT Id, Field, NewValue, OldValue, CreatedDate FROM Histories WHERE Field = 'StageName' order by CreatedDate asc)
                                     FROM Opportunity where AccountId in :accountIDs AND ia_crm__Intacct_Transaction__c != 'Salesforce - Refund' AND Amount != NULL
                                     ORDER BY Purchase_Date_Time__c DESC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstOpps',lstOpps);

        for(Opportunity opp :lstOpps) {
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop Opp',opp);

            //if(opp.StageName == 'Closed Lost' && (opp.Alternate_Method_of_Payment__c == NULL || opp.Alternate_Method_of_Payment__c.toLowerCase() == 'cc' || opp.Alternate_Method_of_Payment__c.toLowerCase() == 'credit card')) {
            //    continue;
            //}

            if(opp.StageName == 'Closed') {

                // Only count Opps without total refunds
                if(!opp.Product_Refunds__r.IsEmpty()) {
                    Decimal totalRefunded = 0;
                    for(Product_Refunds__c pr :opp.Product_Refunds__r) {
                        if(pr.Refund_amount__c != NULL && pr.Refund_amount__c > 0)
                            totalRefunded+=pr.Refund_amount__c;
                    }
                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','totalRefunded',totalRefunded);
                    if(totalRefunded >= opp.Amount) {
                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Skip refunded',opp.Amount);
                        setRefundedOpportunites.add(opp.Id);
                    }
                }

                // Fix Closed Date
                opp.Closed_Date__c = NULL;
                for(OpportunityFieldHistory oh :opp.Histories) {
                    if(oh.NewValue == 'Closed') {
                        opp.Closed_Date__c = oh.CreatedDate;

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Closed Date By History',opp.Closed_Date__c );

                        break;
                    }
                }

                if(opp.Closed_Date__c == NULL) {
                    for(ChargentOrders__Transaction__c ct :opp.Transactions__r) {
                        opp.Closed_Date__c = ct.ChargentOrders__Gateway_Date__c;

                        if(debug=='fine')
                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Close Date by Transaction',opp.Closed_Date__c );
                        break;
                    }
                }

                if(opp.Closed_Date__c == NULL && opp.Purchase_Date_Time__c != NULL) {
                    opp.Closed_Date__c = opp.Purchase_Date_Time__c;

                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Close Date by Purchase Date',opp.Closed_Date__c );

                }

                if(opp.Closed_Date__c == NULL) {
                    opp.Closed_Date__c = opp.CreatedDate;

                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final Close Date by Created Date',opp.Closed_Date__c );
                }


                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final Close Date',opp.Closed_Date__c );

                /*
                opp.Closed_Date__c = opp.Purchase_Date_Time__c;
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Paid Date',opp.Closed_Date__c );

                */
            }

            List<Opportunity> fndOpps = mapAccountOpportunites.get(opp.AccountId);
            if(fndOpps == NULL) {
                fndOpps = new List<Opportunity>();
            }
            fndOpps.add(opp);
            mapAccountOpportunites.put(opp.AccountId, fndOpps);
            mapOpportunitesById.put(opp.Id,opp);

            // Save Related Opps
            Opportunity lastOpp = lastOppByAccountId.get(opp.AccountId); // Aff order
            // TO DO - Remove
            //if(debug=='fine')
            //    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lastOpp',lastOpp);

            if(lastOpp != NULL) {
                Long diff = lastOpp.Purchase_Date_Time__c.getTime() - opp.Purchase_Date_Time__c.getTime();
                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','diff',diff);
                if(diff < 60000) { // same minute
                    sisterOpps.put(lastOpp.Id, opp);
                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','add sisterOpps',lastOpp.Id + '>' + Opp);
                }
            } else {
                lastOppByAccountId.put(opp.AccountId, opp);
                // TO DO - Remove
                //if(debug=='fine')
                //    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lastOpp',lastOpp);
            }
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapAccountOpportunites',mapAccountOpportunites);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','setRefundedOpportunites',setRefundedOpportunites);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','sisterOpps',sisterOpps);

        List<Event_Registration__c> lstEventRegistrations = [select Id, Contact__c, Opportunity__c, Opportunity__r.Amount, Opportunity__r.Purchase_Date_Time__c,
                                                             CreatedDate, Event__r.Content__r.Form__r.Form_Name__c
                                                             from Event_Registration__c where
                                                             Opportunity__r.StageName = 'Closed' AND Contact__c in :contactIDs
                                                             ORDER BY CreatedDate ASC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstEventRegistrations',lstEventRegistrations);
        MAP<String, String> mapOppEventRegs = new MAP<String, String>();
        MAP<String, List<Event_Registration__c>> mapContactEventRegs = new MAP<String, List<Event_Registration__c>>();
        for(Event_Registration__c er :lstEventRegistrations) {
            mapOppEventRegs.put(er.Opportunity__c, er.Id);

            List<Event_Registration__c> fndERs = mapContactEventRegs.get(er.Contact__c);
            if(fndERs == NULL) {
                fndERs = new List<Event_Registration__c>();
            }
            fndERs.add(er);
            mapContactEventRegs.put(er.Contact__c, fndERs);
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapOppEventRegs',mapOppEventRegs);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactEventRegs',mapContactEventRegs);

        List<Webcast_Registration__c> lstWebcastRegistrations = [select Id, Contact__c, CreatedDate, Webcast__r.Content__r.Form__r.Form_Name__c
                                                                from Webcast_Registration__c
                                                                where Contact__c in :contactIDs
                                                                ORDER BY CreatedDate ASC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstWebcastRegistrations',lstWebcastRegistrations);

        MAP<String, List<Webcast_Registration__c>> mapContactWebcastRegs = new MAP<String, List<Webcast_Registration__c>>();
        for(Webcast_Registration__c wr :lstWebcastRegistrations) {
            List<Webcast_Registration__c> fndWRs = mapContactWebcastRegs.get(wr.Contact__c);
            if(fndWRs == NULL) {
                fndWRs = new List<Webcast_Registration__c>();
            }
            fndWRs.add(wr);
            mapContactWebcastRegs.put(wr.Contact__c, fndWRs);
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactWebcastRegs',mapContactWebcastRegs);

        List<Chapter_Meeting_Registration__c> lstChapterMeetingRegistrations = [select Id, Contact__c, CreatedDate, Opportunity__c, Chapter_Meeting__r.Content__r.Form__r.Form_Name__c
                                                               from Chapter_Meeting_Registration__c
                                                               WHERE Contact__c in :contactIDs
                                                               ORDER BY CreatedDate ASC];
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstChapterMeetingRegistrations',lstChapterMeetingRegistrations);

        MAP<String, List<Chapter_Meeting_Registration__c>> mapContactChapterMeetingRegs = new MAP<String, List<Chapter_Meeting_Registration__c>>();
        for(Chapter_Meeting_Registration__c cmr :lstChapterMeetingRegistrations) {
            List<Chapter_Meeting_Registration__c> fndCMRs = mapContactChapterMeetingRegs.get(cmr.Contact__c);
            if(fndCMRs == NULL) {
                fndCMRs = new List<Chapter_Meeting_Registration__c>();
            }
            fndCMRs.add(cmr);
            mapContactChapterMeetingRegs.put(cmr.Contact__c, fndCMRs);
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContactChapterMeetingRegs',mapContactChapterMeetingRegs);

        MAP<String,Form_Data__c> mapOppIdFormData = new MAP<String,Form_Data__c>();
        MAP<String,Form_Data__c> mapContFormNameDateFormData = new MAP<String,Form_Data__c>();
        MAP<String,Form_Data__c> mapContFirstFormData = new MAP<String,Form_Data__c>();

        List<Form_Data__c> lstFormData = [select Id, Contact__c, Contact__r.AccountId, Form__r.Form_Name__c, OpportunityId__c, CreatedDate,
                                          UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c
                                          from Form_Data__c where Contact__c in :contactIDs order by CreatedDate ASC];
        for(Form_Data__c fd :lstFormData) {
            if(fd.OpportunityId__c != NULL) {
                mapOppIdFormData.put(fd.OpportunityId__c, fd);
            }
            if(fd.Contact__c != NULL && fd.Form__r != NULL) {
                String dt = fd.CreatedDate.format('yyyy-MM-dd');
                String key = fd.Contact__c + ':' + fd.Form__r.Form_Name__c + ':' + dt;
                mapContFormNameDateFormData.put(key, fd);
            }
            Form_Data__c fnd = mapContFirstFormData.get(fd.Contact__c);
            if(fnd == NULL) {
                mapContFirstFormData.put(fd.Contact__c, fd);
            }
        }
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapOppIdFormData',mapOppIdFormData);
        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapContFormNameDateFormData',mapContFormNameDateFormData);

        String lastContact;

        // Calc Values
        try{
            // For event AccountID save the first Opp seen
            MAP<String, String> mapAccountFirstOpp = new MAP<String, String>();
            MAP<String, DateTime> mapAccountOriginalSourceDateTime = new MAP<String, DateTime>();
            MAP<String, DateTime> mapAccountLastSourceDateTime = new MAP<String, DateTime>();

            for(Contact cont :neededContacts) {

                lastContact = cont.Id;

                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop Contacts',cont);

                Member_Profile_Summary__c mp = mapContactMemProfiles.get(cont.Id);

                if(debug=='fine')
                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mp',mp);

                if(mp != NULL) {
                    List<Contract> lstPrograms = mapAccountContracts.get(cont.AccountId);

                    if(debug=='fine')
                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstPrograms',lstPrograms);

                    if(lstPrograms != NULL && !lstPrograms.IsEmpty()) {

                        MAP<String,Contract> mapLastContract = new MAP<String,Contract>();

                        List<Contract> updateContracts = new List<Contract>();

                        // Loop Most Recent First
                        for(Contract contract :lstPrograms) {
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop Programs',contract);

                            String contractStatus = contract.Status.toLowerCase();
                            Boolean isAutoRenewing = False;
                            if(contractStatus == 'activated ( auto-renew )') {
                                contractStatus = 'activated';
                                isAutoRenewing = True;
                            }
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','contractStatus',contractStatus);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','contract Type',contract.recordType.DeveloperName);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','contract Type Name',contract.recordType.Name);

                            Contract lastContract = mapLastContract.get(contract.recordType.DeveloperName);

                            if(contract.status == 'activated') {
                                // Look for overlapping contracts of the same type
                                if(lastContract != NULL && contract.EndDate > lastContract.StartDate) {

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','overlapping conrract',contract.Id);

                                    //Found_Bad_Contracts_Type
                                    mp.Found_Bad_Contracts__c = DateTime.Now();
                                    mp.Found_Bad_Contracts_Type__c = contract.recordType.DeveloperName + '~' + contract.StartDate;
                                    continue;
                                } else {
                                    mapLastContract.put(contract.recordType.DeveloperName, contract);
                                }
                            }

                            if(contract.recordType.DeveloperName == 'FRM_Program' && contractStatus != 'canceled') {

                                mp.FRM_Program_Status__c = contractStatus;

                                // Only most recent
                                //if(mp.FRM_Program_Start_Date__c == NULL) {
                                //    if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                //        mp.Source_Last_Date__c = contract.StartDate;
                                //        mp.Source_Last_Type__c = 'FRM';
                                //    }
                                //}

                                // Set each time, so last one is the first time they entered the program
                                mp.FRM_Program_Start_Date__c = contract.StartDate;

                                if(contractStatus == 'activated') {

                                    // Only do for most recent program
                                    if(mp.FRM_Program_Expire_Date__c == NULL) {

                                        // Set for now, clear if not passed Part I yet, never expires
                                        mp.FRM_Program_Expire_Date__c = contract.EndDate;

                                        // Check Parts Status
                                        if(!contract.Candidate_Requirements__r.IsEmpty()) {

                                            Boolean p1Done = False;
                                            Boolean p2Done = False;
                                            for(Candidate_Requirement__c cr :contract.Candidate_Requirements__r) {
                                                if(cr.Recordtype.Developername == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c != 'Completed') {
                                                    // Cant expire if Part I is not Pass
                                                    mp.FRM_Program_Expire_Date__c = NULL;
                                                } else if(cr.Recordtype.Developername == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                                                    p1Done = True;
                                                } else if(cr.Recordtype.Developername == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                                                    // Cant expire if Part II is Pass
                                                    mp.FRM_Program_Expire_Date__c = NULL;
                                                    p2Done = True;
                                                } else if(cr.Recordtype.Developername == 'Job_Experience') {
                                                    // Get CV Status
                                                    if(cr.Status__c == 'Initial') {
                                                        mp.FRM_CV_Status__c = 'Not Yet Submitted';
                                                    } else if(cr.Status__c == 'Ready For Review') {
                                                        mp.FRM_CV_Status__c = 'Awaiting Approval';
                                                    } else if(cr.Status__c == 'Completed') {
                                                        mp.FRM_CV_Status__c = 'Approved';
                                                    } else if(cr.Status__c == 'Failed Review') {
                                                        mp.FRM_CV_Status__c = 'Denied';
                                                    }
                                                }
                                            }
                                            if(p1Done == False || p2Done == False) {
                                                mp.FRM_CV_Status__c = NULL;
                                            }
                                        }
                                    }
                                }

                                if(contractStatus == 'completed') {
                                    mp.FRM_Completed__c = TRUE;
                                    mp.FRM_Program_Expire_Date__c = NULL;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.FRM_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract FRM',mp);

                            } else if(contract.recordType.DeveloperName == 'SCR_Program' && contractStatus != 'canceled') {

                                // Only most recent
                                //if(mp.SCR_Program_Start_Date__c == NULL) {
                                //    if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                //        mp.Source_Last_Date__c = contract.StartDate;
                                //        mp.Source_Last_Type__c = 'SCR';
                                //    }
                                //}

                                // Set each time, so last one is the first time they entered the program
                                mp.SCR_Program_Start_Date__c = contract.StartDate;

                                if(contractStatus == 'completed') {
                                    mp.SCR_Completed__c = TRUE;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.SCR_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract SCR',mp);

                            } else if(contract.recordType.DeveloperName == 'Risk_AI_Program' && contractStatus != 'canceled') {

                                // Set each time, so last one is the first time they entered the program
                                mp.RAI_Program_Start_Date__c = contract.StartDate;

                                if(contractStatus == 'completed') {
                                    mp.RAI_Completed__c = TRUE;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.RAI_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract RAI',mp);

                            } else if(contract.recordType.DeveloperName == 'ERP_Program') {

                                // Only most recent
                                //if(mp.ERP_Program_Start_Date__c == NULL) {
                                //    if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                //        mp.Source_Last_Date__c = contract.StartDate;
                                //        mp.Source_Last_Type__c = 'ERP';
                                //    }
                                //}

                                // Set each time, so last one is the first time they entered the program
                                mp.ERP_Program_Start_Date__c = contract.StartDate;

                                if(contractStatus == 'completed') {
                                    mp.ERP_Completed__c = TRUE;
                                    mp.ERP_Program_Expire_Date__c = NULL;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.ERP_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                } else {
                                    // Only do for most recent program
                                    if(mp.ERP_Program_Expire_Date__c == NULL) {
                                        // Set for now, clear if not passed Part I yet, never expires
                                        mp.ERP_Program_Expire_Date__c = contract.EndDate;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract ERP',mp);

                            } else if(contract.recordType.DeveloperName == 'ICBRR_Program' && contractStatus != 'canceled') {

                                // Only do for most recent program
                                if(mp.FRR_Program_Start_Date__c == NULL) {
                                    mp.FRR_Program_Start_Date__c = contract.StartDate;
                                    mp.FRR_Program_Expire_Date__c = contract.EndDate;

                                    //if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                    //    mp.Source_Last_Date__c = contract.StartDate;
                                    //    mp.Source_Last_Type__c = 'FRR';
                                    //}
                                }

                                if(contractStatus == 'completed') {
                                    mp.FRR_Completed__c = TRUE;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.FRR_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                    mp.FRR_Program_Expire_Date__c = NULL;
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract FRR',mp);

                            } else if(contract.recordType.DeveloperName == 'FRR25_Program' && contractStatus != 'canceled') {

                                // Only do for most recent program
                                if(mp.FRR25_Program_Start_Date__c == NULL) {
                                    mp.FRR25_Program_Start_Date__c = contract.StartDate;
                                    mp.FRR25_Program_Expire_Date__c = contract.EndDate;
                                }

                                if(contractStatus == 'completed') {
                                    mp.FRR25_Completed__c = TRUE;
                                    if(contract.All_Requirements_Completed_Date__c != NULL) {
                                        mp.FRR25_Completed_Date__c = contract.All_Requirements_Completed_Date__c;
                                    }
                                    mp.FRR25_Program_Expire_Date__c = NULL;
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract FRR25',mp);

                            } else if(contract.recordType.DeveloperName == 'FBR_Program' && contractStatus != 'canceled') {

                                // Only do for most recent program
                                if(mp.FFR_Program_Start_Date__c == NULL) {
                                    mp.FFR_Program_Start_Date__c = contract.StartDate;
                                    mp.FFR_Program_Expire_Date__c = contract.EndDate;

                                    //if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                    //    mp.Source_Last_Date__c = contract.StartDate;
                                    //    mp.Source_Last_Type__c = 'FFR';
                                    //}
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract FFR',mp);

                            } else if(contract.recordType.DeveloperName == 'Membership') {

                                // Only most recent
                                //if(mp.Membership_Start_Date__c == NULL) {
                                //    if(mp.Source_Last_Date__c == NULL || contract.StartDate < mp.Source_Last_Date__c) {
                                //        mp.Source_Last_Date__c = contract.StartDate;
                                //        mp.Source_Last_Type__c = 'Membership';
                                //    }
                                //}

                                // Each one so we get the oldest
                                mp.Membership_Start_Date__c = contract.StartDate;
                                mp.Membership_Original_Type__c = contract.Membership_Type__c;

                                // First / Most Recent Only
                                if(mp.Membership_Type__c == NULL) {

                                    mp.Membership_Individual_Latest_Start_Date__c = contract.StartDate;
                                    mp.Membership_Individual_Latest_End_Date__c = contract.EndDate;

                                    if(contractStatus == 'activated') {
                                        mp.Membership_Type__c = contract.Membership_Type__c;
                                        mp.Membership_Status__c = 'Active';
                                        mp.Membership_Next_Renewal_Date__c = contract.EndDate;
                                        if(contract.Membership_Type__c == 'Individual' && contract.Status== 'Activated ( Auto-Renew )') {
                                            mp.Membership_Autorenew_On__c = TRUE;
                                        }
                                        Opportunity fndOpp = mapOpportunitesById.get(contract.Opportunity__c);
                                        if(fndOpp != NULL) {
                                            oppInfo oppInfo = getOppTypeInformation(fndOpp, mapOppEventRegs, debug);
                                            if(oppInfo != NULL && oppInfo.hasCompMembership == TRUE) {
                                                mp.Membership_Is_Complimentary__c = True;
                                            }
                                        }

                                    } else if(contractStatus == 'expired') {
                                        mp.Membership_Type__c = contract.Membership_Type__c;
                                        mp.Membership_Status__c = 'Lapsed';
                                        mp.Membership_Expire_Date__c = contract.EndDate;
                                        mp.Membership_Days_Since_Lapsed__c = contract.EndDate.daysBetween(tdy);
                                    }
                                }

                                if(contract.Membership_Type__c == 'Individual' || contract.Membership_Type__c == 'Student') {
                                    if(contractStatus == 'activated') {
                                        if(mp.Membership_Days_as_Member__c == NULL) {
                                            mp.Membership_Days_as_Member__c = 0;  // Will compute by adding days until today
                                        } else {
                                            mp.Membership_Days_as_Member__c += contract.StartDate.daysBetween(tdy);
                                        }

                                    } else if(contractStatus == 'expired') {
                                        if(mp.Membership_Days_as_Member__c == NULL) {
                                            mp.Membership_Days_as_Member__c = contract.StartDate.daysBetween(contract.EndDate);
                                        } else {
                                            mp.Membership_Days_as_Member__c += contract.StartDate.daysBetween(contract.EndDate);
                                        }
                                    }
                                }

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Membership_Days_as_Member__c',mp.Membership_Days_as_Member__c);

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract mem',mp);

                            } else if(contract.recordType.DeveloperName == 'Risk_Net') {
                                if(contractStatus == 'activated') {
                                    mp.Membership_Has_Risk_Net__c = TRUE;
                                }
                            } else if(mapMicroCourseByProgramType.get(contract.recordType.Developername) != NULL) {

                                // Get Micro Course
                                Exam__c microCourseExam = mapMicroCourseByProgramType.get(contract.recordType.Developername);
                                if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','microCourseExam',microCourseExam);

                                if(microCourseExam != NULL) {

                                    // Only do for most recent program
                                    if(mp.get(microCourseExam.Name + '_Program_Start_Date__c') == NULL) {
                                        mp.put(microCourseExam.Name + '_Program_Start_Date__c', contract.StartDate);
                                        mp.put(microCourseExam.Name + '_Program_Expire_Date__c', contract.EndDate);
                                    }

                                    if(contractStatus == 'completed') {
                                        mp.put(microCourseExam.Name + '_Completed__c', TRUE);

                                        if(contract.All_Requirements_Completed_Date__c != NULL) {
                                            mp.put(microCourseExam.Name + '_Completed_Date__c', contract.All_Requirements_Completed_Date__c);
                                        }
                                        mp.put(microCourseExam.Name + '_Program_Expire_Date__c', NULL);
                                    }
                                    if(debug=='fine') {
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract micro',mp.get(microCourseExam.Name + '_Program_Start_Date__c'));
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract micro',mp.get(microCourseExam.Name + '_Program_Expire_Date__c'));
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract micro',mp.get(microCourseExam.Name + '_Completed__c'));
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set contract micro',mp.get(microCourseExam.Name + '_Completed_Date__c'));
                                    }
                                }
                            }
                        }

                        // Check Overlapping contracts - Loop Most Recent First
                        for(Contract contractA :lstPrograms) {
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop contractA',contractA);

                            if(mp.Found_Bad_Contracts__c != NULL) {
                                break;
                            }

                            String contractStatusA = contractA.Status.toLowerCase();
                            if(contractStatusA == 'activated ( auto-renew )') {
                                contractStatusA = 'activated';
                            }
                            if(contractA.recordType.DeveloperName == 'Membership' &&
                               (contractA.Membership_Type__c == 'Individual' || contractA.Membership_Type__c == 'Student') &&
                               (contractStatusA == 'activated' || contractStatusA == 'expired' || contractStatusA == 'completed')) {
                                for(Contract contractB :lstPrograms) {
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop contractB',contractA);

                                    String contractStatusB = contractA.Status.toLowerCase();
                                    if(contractStatusB == 'activated ( auto-renew )') {
                                        contractStatusB = 'activated';
                                    }

                                    if(contractB.recordType.DeveloperName == 'Membership' &&
                                       (contractB.Membership_Type__c == 'Individual' || contractB.Membership_Type__c == 'Student') &&
                                       (contractStatusB == 'activated' || contractStatusB == 'expired' || contractStatusB == 'completed')) {

                                        // If overlap
                                        if((contractB.StartDate >= contractA.StartDate && contractB.StartDate <= contractA.EndDate) ||
                                           (contractB.EndDate >= contractA.StartDate && contractB.EndDate <= contractA.EndDate)) {
                                            mp.Found_Bad_Contracts__c = DateTime.Now();
                                            mp.Found_Bad_Contracts_Type__c = contractA.recordType.DeveloperName + '~' + contractA.Id + ':' + contractB.Id;

                                               if(debug=='fine')
                                                   GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Overlap Found',contractA.Id + ':' + contractB.Id);
                                               break;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    List<Exam_Attempt__c> lstMemberExamAttempts = mapContactExamAttempts.get(cont.Id);
                    if(lstMemberExamAttempts != NULL && !lstMemberExamAttempts.IsEmpty()) {
                        // Loop Most Recent First
                        for(Exam_Attempt__c examAttempt :lstMemberExamAttempts) {
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop exam attempt',examAttempt);

                            if(examAttempt.RPT_Exam_Program__c == 'FRM') {

                                if(examAttempt.RPT_Exam_Part__c == 'I' || examAttempt.RPT_Exam_Part__c == 'Full') {
                                    // Most Recent Part I with Result
                                    if(examAttempt.Result__c != NULL && mp.FRM_Part_I_Last_Exam_Admin__c == NULL) {
                                        mp.FRM_Part_I_Last_Exam_Admin__c = getExamAdminDate(examAttempt);
                                        mp.FRM_Part_I_Last_Result__c = getExamResult(examAttempt.Result__c);
                                        mp.FRM_Part_I_Last_Score__c = getExamScore(examAttempt, debug);
                                    } else if(examAttempt.Result__c == NULL && mp.FRM_Part_I_Next_Exam_Admin__c == NULL) {
                                        // Most Recent Part I without Result
                                        mp.FRM_Part_I_Next_Exam_Admin__c = getExamAdminDate(examAttempt);
                                    }
                                } else if(examAttempt.RPT_Exam_Part__c == 'II') {
                                    if(examAttempt.Result__c != NULL && mp.FRM_Part_II_Last_Exam_Admin__c == NULL) {
                                        mp.FRM_Part_II_Last_Exam_Admin__c = getExamAdminDate(examAttempt);
                                        mp.FRM_Part_II_Last_Result__c = getExamResult(examAttempt.Result__c);
                                        mp.FRM_Part_II_Last_Score__c = getExamScore(examAttempt, debug);
                                    } else if(examAttempt.Result__c == NULL && mp.FRM_Part_II_Next_Exam_Admin__c == NULL) {
                                        mp.FRM_Part_II_Next_Exam_Admin__c = getExamAdminDate(examAttempt);
                                    }
                                }

                                // For Each Result Pass/Fail
                                if(examAttempt.Result__c != NULL && (examAttempt.Result__c == 'Fail' || examAttempt.Result__c == 'Pass')) {
                                    if(mp.FRM_Attempts__c == NULL) {
                                        mp.FRM_Attempts__c=1;
                                    } else {
                                        mp.FRM_Attempts__c++;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set attempt FRM',mp);

                            } else if(examAttempt.RPT_Exam_Program__c == 'SCR') {

                                // Most Recent with Result
                                if(examAttempt.Result__c != NULL && mp.SCR_Last_Exam_Admin__c == NULL) {
                                    mp.SCR_Last_Exam_Admin__c = getExamAdminDate(examAttempt);
                                    mp.SCR_Last_Result__c = getExamResult(examAttempt.Result__c);
                                    mp.SCR_Last_Score__c = getExamScore(examAttempt, debug);
                                } else if(examAttempt.Result__c == NULL && mp.SCR_Next_Exam_Admin__c  == NULL) {
                                    // Most Recent without Result
                                    mp.SCR_Next_Exam_Admin__c = getExamAdminDate(examAttempt);
                                }

                                // For Each Result Pass/Fail
                                if(examAttempt.Result__c != NULL && (examAttempt.Result__c == 'Fail' || examAttempt.Result__c == 'Pass')) {
                                    if(mp.SCR_Attempts__c == NULL) {
                                        mp.SCR_Attempts__c=1;
                                    } else {
                                        mp.SCR_Attempts__c++;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set attempt SCR',mp);

                            } else if(examAttempt.RPT_Exam_Program__c == 'RiskAI') {

                                // Most Recent with Result
                                if(examAttempt.Result__c != NULL && mp.RAI_Last_Exam_Admin__c == NULL) {
                                    mp.RAI_Last_Exam_Admin__c = getExamAdminDate(examAttempt);
                                    mp.RAI_Last_Result__c = getExamResult(examAttempt.Result__c);
                                    mp.RAI_Last_Score__c = getExamScore(examAttempt, debug);
                                } else if(examAttempt.Result__c == NULL && mp.RAI_Next_Exam_Admin__c  == NULL) {
                                    // Most Recent without Result
                                    mp.RAI_Next_Exam_Admin__c = getExamAdminDate(examAttempt);
                                }

                                // For Each Result Pass/Fail
                                if(examAttempt.Result__c != NULL && (examAttempt.Result__c == 'Fail' || examAttempt.Result__c == 'Pass')) {
                                    if(mp.RAI_Attempts__c == NULL) {
                                        mp.RAI_Attempts__c=1;
                                    } else {
                                        mp.RAI_Attempts__c++;
                                    }
                                }
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set attempt RAI',mp);

                            } else if(examAttempt.Exam_Site__r.Exam__r.Exam__c == 'ICBRR') {

                                // If has result
                                if(examAttempt.Result__c != NULL) {
                                    // Only most recent Result
                                    if(mp.FRR_Last_Taken_Date__c == NULL) {
                                        mp.FRR_Last_Result__c = getExamResult(examAttempt.Result__c);
                                        mp.FRR_Last_Taken_Date__c = examAttempt.Icbrr_Exam_Date__c;
                                    }
                                    if(mp.FRR_Attempts__c == NULL) {
                                        mp.FRR_Attempts__c=1;
                                    } else {
                                        mp.FRR_Attempts__c++;
                                    }
                                }

                            } else if(examAttempt.Exam_Site__r.Exam__r.Exam__c == 'FRR25') {

                                // If has result
                                if(examAttempt.Result__c != NULL) {
                                    // Only most recent Result
                                    if(mp.FRR25_Last_Taken_Date__c == NULL) {
                                        mp.FRR25_Last_Result__c = getExamResult(examAttempt.Result__c);
                                        mp.FRR25_Last_Taken_Date__c = examAttempt.Icbrr_Exam_Date__c;
                                    }
                                    if(mp.FRR25_Attempts__c == NULL) {
                                        mp.FRR25_Attempts__c=1;
                                    } else {
                                        mp.FRR25_Attempts__c++;
                                    }
                                }
                            } else if(mapMicroCourseByName.get(examAttempt.Exam_Site__r.Exam__r.Exam__c) != NULL) {
                                Exam__c ex = mapMicroCourseByName.get(examAttempt.Exam_Site__r.Exam__r.Exam__c);

                                // If has result
                                if(examAttempt.Result__c != NULL) {
                                    // Only most recent Result
                                    if(mp.get(ex.Name + '_Last_Taken_Date__c') == NULL) {
                                        mp.put(ex.Name + '_Last_Result__c', examAttempt.Result__c);
                                        mp.put(ex.Name + '_Last_Taken_Date__c', examAttempt.Icbrr_Exam_Date__c);
                                    }
                                    if(mp.get(ex.Name + '_Attempts__c') == NULL) {
                                         mp.put(ex.Name + '_Attempts__c', 1);
                                    } else {
                                        Decimal cnt = (Decimal) mp.get(ex.Name + '_Attempts__c');
                                        mp.put(ex.Name + '_Attempts__c', cnt+1);
                                    }
                                }

                                if(debug=='fine') {
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set exam attempt micro',mp.get(ex.Name + '_Last_Taken_Date__c'));
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set exam attemp micro',mp.get(ex.Name + '_Last_Result__c'));
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','set exam attemp micro',mp.get(ex.Name + '_Attempts__c'));
                                }
                            }
                        }
                    }

                    List<Opportunity> lstMemberOpps = mapAccountOpportunites.get(cont.AccountId);
                    if(lstMemberOpps != NULL && !lstMemberOpps.IsEmpty()) {

                        MAP<String, oppInfo> mapOppInfo = new MAP<String, oppInfo>();

                        // remove invalid affiliate orders
                        Boolean hasIndividualMembership = False;
                        Boolean hasAffiliateMembership = False;

                        lstMemberOpps.sort(new OpportunityCloseDateComparator());

                        // Oldest to newest
                        for(Opportunity opp :lstMemberOpps) {
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff',opp);

                            oppInfo oppInfo = getOppTypeInformation(opp, mapOppEventRegs, debug);
                            mapOppInfo.put(opp.Id, oppInfo);

                            Boolean isRefunded = setRefundedOpportunites.contains(opp.Id);
                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Opp Order Summary: isRefunded',isRefunded);

                            if(oppInfo.hasMembership) {
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - member opp',opp);

                                if(oppInfo.hasOnlyAFREE && (oppInfo.hasMembershipRefund || isRefunded)) {
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - is Aff only and refunded - skip',opp);
                                    continue;
                                }

                                if(oppInfo.hasMembership && oppInfo.hasMembershipRefund) {
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - is member opp and membership refunded - skip',opp);
                                    continue;

                                }

                                String membershipType = oppInfo.membershipType.Replace(' Membership','');
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - membershipType',membershipType);

                                if((hasAffiliateMembership || hasIndividualMembership) && membershipType == 'Affiliate') {

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - is Aff and already has aff before',opp);

                                    // If invalid Affiliate and only prdocut, skil all logic
                                    //if(oppInfo.hasOnlyAFREE) {

                                        //if(debug=='fine')
                                        //    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - only aff - skip',opp);

                                        //continue;
                                    //}

                                    // Remove hasMembership
                                    oppInfo.hasMembership = False;
                                    oppInfo.hasAFREE = False;
                                    mapOppInfo.put(opp.Id, oppInfo);

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - remove membership from oppInfo',opp);

                                }

                                if(membershipType == 'Affiliate') {
                                    hasAffiliateMembership = True;

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - found Affiliate',null);
                                } else if(membershipType == 'Individual') {
                                    hasIndividualMembership = True;
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp remove aff - found Individual',null);
                                }
                            }
                        }

                        // Membership Vars
                        Opportunity lastOpp = NULL;
                        Contract lastContract = NULL;
                        Date firstIndividualStartDate = NULL;
                        Date firstAffiliateStartDate = NULL;
                        Boolean isGap = False;

                        Opportunity firstAffiliateOpp = NULL;

                        // Oldest to newest
                        for(Opportunity opp :lstMemberOpps) {

                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Loop opp',opp);

                            //oppInfo oppInfo = getOppTypeInformation(opp, mapOppEventRegs, debug);
                            oppInfo oppInfo = mapOppInfo.get(opp.Id);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','oppInfo',opp.Id +':'+oppInfo);

                            Boolean isRefunded = setRefundedOpportunites.contains(opp.Id);
                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Opp Order Summary: isRefunded',isRefunded);

                            //opp.Order_Summary_Opp_Type_Is_First__c = False;

                            // Update Opp Order Summary Fields
                            if(oppInfo != NULL) {

                                if(oppInfo.orderSummaryProductLine != NULL) {
                                    opp.Order_Summary_Product_Line__c = oppInfo.orderSummaryProductLine;
                                    opp.Order_Summary_Opp_Type__c = oppInfo.oppType;

                                    if(oppInfo.IsB2B)
                                        opp.Order_summary_Is_B2B__c = True;
                                    if(oppInfo.IsScholarship)
                                        opp.Order_Summary_Is_Scholarship__c = True;

                                } else {
                                    opp.Order_Summary_Product_Line__c = 'Unknown';
                                }

                                if(opp.StageName != NULL) {
                                    if(isRefunded) {
                                        opp.Order_Summary_Payment_Status__c = 'Refunded';
                                    } else if(opp.StageName == 'Closed') {
                                        opp.Order_Summary_Payment_Status__c = 'Paid';
                                    } else if(opp.StageName == 'New Lead' && opp.Alternate_Method_of_Payment__c != NULL && (opp.Alternate_Method_of_Payment__c.toLowerCase() != 'cc' || opp.Alternate_Method_of_Payment__c.toLowerCase() != 'credit card')) {
                                        opp.Order_Summary_Payment_Status__c = 'Awaiting Payment';
                                    } else {
                                        opp.Order_Summary_Payment_Status__c = 'Canceled';
                                    }

                                } else {
                                    opp.Order_Summary_Payment_Status__c = 'Canceled';
                                }
                            }

                            // Only Used Closed Opps
                            if(opp.StageName == NULL || opp.StageName != 'Closed') {
                                continue;
                            }

                            String fndFirstOpp = mapAccountFirstOpp.get(cont.AccountId);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFirstOpp',fndFirstOpp);

                            // Only on the first, most recent Opp - no more
                            // Do all to get newest
                            //if(fndFirstOpp == NULL) {
                                mapAccountFirstOpp.put(cont.AccountId, opp.Id);
                                mapAccountLastSourceDateTime.put(cont.AccountId, opp.Purchase_Date_Time__c);
                                mp.Source_Last_Date__c = opp.Purchase_Date__c;
                                mp.Source_Last_Type__c = oppInfo.oppType;
                            //}

                            // For each opp, to get the oldest - no more
                            // Only on the first, most oldest Opp
                            if(fndFirstOpp == NULL) {
                                mp.Source_First_Date__c = opp.Purchase_Date__c;
                                mp.Source_First_Type__c = oppInfo.oppType;
                                mp.Source_First_Paid__c = (opp.Amount > 0);
                            }

                            Form_Data__c fndFormData = mapOppIdFormData.get(opp.Id);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);

                            if(fndFormData == NULL) {
                                fndFormData = mapContFirstFormData.get(cont.Id);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData by contact',fndFormData);
                            }

                            if(fndFormData != NULL) {
                                mp.Source_UTM_Campaign__c = fndFormData.UTM_Campaign__c;
                                mp.Source_UTM_Content__c = fndFormData.UTM_Content__c;
                                mp.Source_UTM_Medium__c = fndFormData.UTM_Medium__c;
                                mp.Source_UTM_Source__c = fndFormData.UTM_Source__c;
                                mp.Source_UTM_Term__c = fndFormData.UTM_Term__c;
                            }
                            mapAccountOriginalSourceDateTime.put(cont.AccountId, opp.Purchase_Date_Time__c);

                            // Only Opps of values and not refunded
                            if(!oppInfo.hasOnlyAFREE && !isRefunded) {
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','value opp',opp);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Orders_Placed__c',mp.Orders_Placed__c);

                                // Only for first order to get newest - no more
                                //if(mp.Orders_Last_Amount__c == NULL) {

                                // Do all to get newest
                                mp.Orders_Last_Amount__c = opp.Amount;
                                mp.Orders_Last_Date__c = opp.Purchase_Date__c;
                                mp.Orders_Last_Type__c = oppInfo.oppType;

                                // Initialize count
                                if(mp.Orders_Placed__c == NULL) {
                                    mp.Orders_Placed__c = 1;
                                    mp.Orders_Total_Revenue__c = opp.Amount;

                                    // First opp is oldest/first
                                    mp.Orders_First_Amount__c = opp.Amount;
                                    mp.Orders_First_Date__c = opp.Purchase_Date__c;
                                    mp.Orders_First_Type__c = oppInfo.oppType;
                                    mp.Orders_First_Products__c = oppInfo.products;
                                } else {

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Least Order',oppInfo);

                                    mp.Orders_Placed__c++;
                                    mp.Orders_Total_Revenue__c += opp.Amount;
                                }

                                mp = setRevenueByProduct(mp, opp, oppInfo, debug);

                            }

                            // Membership Logic
                            opp.Order_Summary_Membership_Type__c = NULL;
                            opp.Order_Summary_Membership_Payment__c = NULL;
                            opp.Order_Summary_Membership_Is_AutoRenew__c = False;
                            opp.Order_Summary_Membership_Business_Type__c = NULL;
                            opp.Order_Summary_Membership_Start_Date__c = NULL;
                            opp.Order_Summary_Membership_End_Date__c = NULL;
                            opp.Order_Summary_Membership_Lapsed__c = False;

                            if(oppInfo.hasMembership && !oppInfo.hasMembershipRefund) {

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mebership opp',opp);


                                Date oppPaidDate = Date.NewInstance(opp.Closed_Date__c.Year(), opp.Closed_Date__c.Month(), opp.Closed_Date__c.Day());
                                returnFindContract fndContract = findMembershipContract(opp.Id, cont.AccountId, oppPaidDate, mapAccountContracts, debug);

                                opp.Order_Summary_Membership_Type__c = oppInfo.membershipType.Replace(' Membership','');

                                if(oppInfo.hasCompMembership || oppInfo.hasAFREE) {
                                    opp.Order_Summary_Membership_Payment__c = 'Complimentary';
                                } else {
                                    opp.Order_Summary_Membership_Payment__c = 'Paid';
                                }

                                opp.Order_Summary_Membership_Is_AutoRenew__c = oppInfo.isAutoRenew;

                                // First Opp
                                if(lastOpp == NULL) {

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','First Opp',opp);

                                    opp.Order_Summary_Membership_Business_Type__c = 'New';
                                    opp.Order_Summary_Membership_Start_Date__c = oppPaidDate;
                                    opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_Start_Date__c.AddMonths(oppInfo.membershipDuration);
                                    opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_End_Date__c.addDays(-1);
                                    isGap = False;

                                    if(opp.Order_Summary_Membership_Type__c == 'Affiliate') {
                                        firstAffiliateOpp = opp;
                                    }

                                } else {

                                    String membershipType = oppInfo.membershipType.Replace(' Membership','');

                                    // Not an Upgrade
                                    if(lastOpp.Order_Summary_Membership_Type__c == membershipType) {

                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Renew Opp',opp);

                                        opp.Order_Summary_Membership_Business_Type__c = 'Renew';

                                        if(mp.Membership_Number_of_Renewals__c == NULL) {
                                            mp.Membership_Number_of_Renewals__c = 1;
                                        } else {
                                            mp.Membership_Number_of_Renewals__c++;
                                        }
                                        // Do all to get most recent
                                        mp.Membership_Last_Renewal_Date__c = opp.Purchase_Date__c;


                                        Date closeDate = Date.newInstance(opp.Closed_Date__c.year(), opp.Closed_Date__c.month(), opp.Closed_Date__c.day());

                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Opp Close Date',closeDate);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Last Opp End Date',lastOpp.Order_Summary_Membership_End_Date__c);


                                        Date lastOppEndDate = lastOpp.Order_Summary_Membership_End_Date__c.addDays(1);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lastOppEndDate adjusted',lastOppEndDate);


                                        // Overlapping Renewal, start after last ends
                                        if(closeDate <= lastOppEndDate) {

                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Overlap Opp',opp);

                                            opp.Order_Summary_Membership_Start_Date__c = lastOpp.Order_Summary_Membership_End_Date__c.AddDays(1);
                                            opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_Start_Date__c.AddMonths(oppInfo.membershipDuration);
                                            opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_End_Date__c.addDays(-1);
                                            isGap = False;
                                        } else {

                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Not Overlap Opp',opp);

                                            // Not Overlapping, was a gap
                                            opp.Order_Summary_Membership_Start_Date__c = oppPaidDate;
                                            opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_Start_Date__c.AddMonths(oppInfo.membershipDuration);
                                            opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_End_Date__c.addDays(-1);
                                            isGap = True;
                                        }

                                    } else {

                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Upgrade Opp',opp);

                                        // Upgrade
                                        opp.Order_Summary_Membership_Business_Type__c = 'Upgrade';

                                        opp.Order_Summary_Membership_Start_Date__c = oppPaidDate;
                                        opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_Start_Date__c.AddMonths(oppInfo.membershipDuration);
                                        opp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_End_Date__c.addDays(-1);
                                        isGap = False;

                                    }
                                }

                                if(lastOpp != NULL && debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Computed info Bus Type',opp.Order_Summary_Membership_Business_Type__c);
                                if(lastOpp != NULL && debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Computed info Start Date',opp.Order_Summary_Membership_Start_Date__c);
                                if(lastOpp != NULL && debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Computed info End Date',opp.Order_Summary_Membership_End_Date__c);

                                if(fndContract != NULL && fndContract.contract != NULL && fndContract.isOnlyOpp) {
                                    opp.Order_Summary_Membership_Start_Date__c = fndContract.contract.StartDate;
                                    opp.Order_Summary_Membership_End_Date__c = fndContract.contract.EndDate;

                                    if(lastOpp != NULL && debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Adjust OnlyOpp','');

                                } else {
                                    if(fndContract != NULL && fndContract.contract != NULL && fndContract.isNearStart && (lastContract == NULL || fndContract.contract.Id != lastContract.Id)) {
                                        opp.Order_Summary_Membership_Start_Date__c = fndContract.contract.StartDate;

                                        if(lastOpp != NULL && debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Adjust Near Start','');

                                    }
                                    if(fndContract != NULL && fndContract != NULL && (fndContract.isNearEnd || opp.Order_Summary_Membership_End_Date__c > fndContract.contract.EndDate) && fndContract.contract.EndDate > opp.Order_Summary_Membership_Start_Date__c) {
                                        opp.Order_Summary_Membership_End_Date__c = fndContract.contract.EndDate;

                                        if(lastOpp != NULL && debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Adjust Near End','');
                                    }
                                }

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','isGap',isGap);


                                if(lastOpp != NULL && isGap) {
                                    lastOpp.Order_Summary_Membership_Lapsed__c = True;
                                    updateOpps.put(lastOpp.Id, lastOpp);

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Set as Lapsed',lastOpp);

                                }

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final Business_Type',opp.Order_Summary_Membership_Business_Type__c);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final Start_Date',opp.Order_Summary_Membership_Start_Date__c);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Final End_Date',opp.Order_Summary_Membership_End_Date__c);

                                // Adjust Affiliate Opp
                                if(firstAffiliateOpp != NULL && lastOpp != NULL) {
                                    firstAffiliateOpp.Order_Summary_Membership_End_Date__c = opp.Order_Summary_Membership_Start_Date__c.addDays(-1);

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Adjust First Affiliate Opp End Date',firstAffiliateOpp.Order_Summary_Membership_End_Date__c);

                                    updateOpps.put(firstAffiliateOpp.Id, firstAffiliateOpp);

                                    firstAffiliateOpp = NULL;
                                }


                                lastOpp = opp;
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Set Last Opp',lastOpp);


                                if(fndContract != NULL) {
                                    lastContract = fndContract.contract;
                                } else {
                                    lastContract = NULL;
                                }

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Set Last Contract',lastContract);


                                // Orginal Membership Source Logic

                                // Free Orders Only Affiliate
                                if(oppInfo != NULL && oppInfo.hasAFREE && mp.Membership_Affiliate_Original_Source__c == NULL) {

                                    oppInfo oppInfoSis;
                                    if(oppInfo.hasOnlyAFREE) {
                                        Opportunity sisOpp = sisterOpps.get(opp.Id);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fnd sisOpp',sisOpp);

                                        if(sisOpp != NULL) {
                                            oppInfoSis = getOppTypeInformation(sisOpp, mapOppEventRegs, debug);
                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','oppInfoSis',oppInfoSis);
                                        }
                                    }

                                    if(oppInfoSis != NULL && (oppInfoSis.membershipType == NULL || oppInfoSis.membershipType != 'Affiliate Membership')) {
                                        mp.Membership_Affiliate_Original_Source__c = oppInfoSis.oppType;
                                        mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                        if(oppInfoSis.hasAMP || oppInfoSis.oppType == 'FRM' || oppInfoSis.oppType == 'ERP') {
                                            mp.Membership_Affiliate_Original_AMP__c = True;
                                        }
                                    } else {
                                        mp.Membership_Affiliate_Original_Source__c = oppInfo.oppType;
                                        mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                    }
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Membership_Affiliate_Original_Source__c',mp.Membership_Affiliate_Original_Source__c);
                                      if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Membership_Affiliate_Original_AMP__c',mp.Membership_Affiliate_Original_AMP__c);
                                }

                                // Individual or Student
                                if(oppInfo != NULL && oppInfo.hasMembership && (oppInfo.membershipType == 'Individual Membership' || oppInfo.membershipType == 'Student Membership')) {
                                    mp.Membership_Individual_Original_Source__c = oppInfo.oppType;
                                    mp.Membership_Individual_Original_Date__c = opp.Purchase_Date__c;
                                } else if(oppInfo != NULL && oppInfo.hasAFREE) {

                                    oppInfo oppInfoSis;
                                    if(oppInfo.hasOnlyAFREE) {
                                        Opportunity sisOpp = sisterOpps.get(opp.Id);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fnd sisOpp',sisOpp);

                                        if(sisOpp != NULL) {
                                            oppInfoSis = getOppTypeInformation(sisOpp, mapOppEventRegs, debug);
                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','oppInfoSis',oppInfoSis);
                                        }
                                    }

                                    if(oppInfoSis != NULL && (oppInfoSis.membershipType == NULL || oppInfoSis.membershipType != 'Affiliate Membership')) {
                                        mp.Membership_Affiliate_Original_Source__c = oppInfoSis.oppType;
                                        mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                        if(oppInfoSis.hasAMP || oppInfoSis.oppType == 'FRM' || oppInfoSis.oppType == 'ERP') {
                                            mp.Membership_Affiliate_Original_AMP__c = True;
                                        }
                                    } else {
                                        mp.Membership_Affiliate_Original_Source__c = oppInfo.oppType;
                                        mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                    }
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Membership_Affiliate_Original_Source__c',mp.Membership_Affiliate_Original_Source__c);
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Membership_Affiliate_Original_AMP__c',mp.Membership_Affiliate_Original_AMP__c);
                                }

                            }
                            updateOpps.put(opp.Id, opp);

                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','updateOpps add',opp);
                        }

                        // Compute lapsed on last Opp
                        if(lastOpp != NULL && lastOpp.Order_Summary_Membership_End_Date__c < Date.Today()) {
                            lastOpp.Order_Summary_Membership_Lapsed__c = True;
                            updateOpps.put(lastOpp.Id, lastOpp);

                            if(lastOpp != NULL && debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','Set as Lapsed',lastOpp);

                        }

                        // If only 1 order only keep first
                        if(mp.Orders_Placed__c == 1) {
                            mp.Orders_Last_Amount__c = NULL;
                            mp.Orders_Last_Date__c = NULL;
                            mp.Orders_Last_Type__c = NULL;
                        }

                        // If no member source try closed lost orders
                        if(mp.Membership_Individual_Original_Source__c == NULL && mp.Membership_Affiliate_Original_Source__c == NULL) {
                            for(Opportunity opp :lstMemberOpps) {
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL Loop opp',opp);

                                //oppInfo oppInfo = getOppTypeInformation(opp, mapOppEventRegs, debug);
                                // Use cached version
                                oppInfo oppInfo = mapOppInfo.get(opp.Id);

                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL oppInfo',oppInfo);

                                if(opp.Amount > 0) {
                                    if(oppInfo != NULL && oppInfo.hasMembership && (oppInfo.membershipType == 'Individual Membership' || oppInfo.membershipType == 'Student Membership')) {
                                        mp.Membership_Individual_Original_Source__c = oppInfo.oppType;
                                        mp.Membership_Individual_Original_Date__c = opp.Purchase_Date__c;
                                    } else if(oppInfo != NULL && oppInfo.hasAFREE) {

                                        oppInfo oppInfoSis;
                                        if(oppInfo.hasOnlyAFREE) {
                                            Opportunity sisOpp = sisterOpps.get(opp.Id);
                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL fnd sisOpp',sisOpp);

                                            if(sisOpp != NULL) {
                                                oppInfoSis = getOppTypeInformation(sisOpp, mapOppEventRegs, debug);
                                                if(debug=='fine')
                                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL oppInfoSis',oppInfoSis);
                                            }
                                        }

                                        if(oppInfoSis != NULL && (oppInfoSis.membershipType == NULL || oppInfoSis.membershipType != 'Affiliate Membership')) {
                                            mp.Membership_Affiliate_Original_Source__c = oppInfoSis.oppType;
                                            mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                            if(oppInfoSis.hasAMP || oppInfoSis.oppType == 'FRM' || oppInfoSis.oppType == 'ERP') {
                                                mp.Membership_Affiliate_Original_AMP__c = True;
                                            }
                                        } else {
                                            mp.Membership_Affiliate_Original_Source__c = oppInfo.oppType;
                                            mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                        }
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL Membership_Affiliate_Original_Source__c',mp.Membership_Affiliate_Original_Source__c);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL Membership_Affiliate_Original_AMP__c',mp.Membership_Affiliate_Original_AMP__c);
                                    }

                                } else {

                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL free opp',opp);

                                    // Free Orders Only Affiliate
                                    if(oppInfo != NULL && oppInfo.hasAFREE && mp.Membership_Affiliate_Original_Source__c == NULL) {

                                        oppInfo oppInfoSis;
                                        if(oppInfo.hasOnlyAFREE) {
                                            Opportunity sisOpp = sisterOpps.get(opp.Id);
                                            if(debug=='fine')
                                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL fnd sisOpp',sisOpp);

                                            if(sisOpp != NULL) {
                                                oppInfoSis = getOppTypeInformation(sisOpp, mapOppEventRegs, debug);
                                                if(debug=='fine')
                                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL oppInfoSis',oppInfoSis);
                                            }
                                        }

                                        if(oppInfoSis != NULL && (oppInfoSis.membershipType == NULL || oppInfoSis.membershipType != 'Affiliate Membership')) {
                                            mp.Membership_Affiliate_Original_Source__c = oppInfoSis.oppType;
                                            mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                            if(oppInfoSis.hasAMP || oppInfoSis.oppType == 'FRM' || oppInfoSis.oppType == 'ERP') {
                                                mp.Membership_Affiliate_Original_AMP__c = True;
                                            }
                                        } else {
                                            mp.Membership_Affiliate_Original_Source__c = oppInfo.oppType;
                                            mp.Membership_Affiliate_Original_Date__c = opp.Purchase_Date__c;
                                        }
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL Membership_Affiliate_Original_Source__c',mp.Membership_Affiliate_Original_Source__c);
                                        if(debug=='fine')
                                            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','CL Membership_Affiliate_Original_AMP__c',mp.Membership_Affiliate_Original_AMP__c);
                                    }
                                }
                            }
                        }
                    }

                    List<Event_Registration__c> lstEventRegs = mapContactEventRegs.get(cont.Id);
                    Integer lstEventLastIndex;
                    if(lstEventRegs != NULL && lstEventRegs.size() > 0) {
                        lstEventLastIndex = lstEventRegs.size()-1;

                        // Get oldest Event Reg
                        Event_Registration__c eventRegistration = lstEventRegs[0];
                        mp.Event_Registrations__c = lstEventRegs.size();
                        mp.Event_First_Registration_Date__c = Date.ValueOf(eventRegistration.CreatedDate);

                        // Find opp original source datetime
                        DateTime firstSourceDateTime = mapAccountOriginalSourceDateTime.get(cont.AccountId);

                        // If no opp original source or Event Reg is before Opp, use Event Reg as original source
                        if(firstSourceDateTime == NULL ||  eventRegistration.CreatedDate < firstSourceDateTime) {
                            mapAccountOriginalSourceDateTime.put(cont.AccountId, eventRegistration.CreatedDate);

                            mp.Source_First_Date__c = mp.Event_First_Registration_Date__c;
                            mp.Source_First_Type__c = 'Event';
                            mp.Source_First_Paid__c = (eventRegistration.Opportunity__r != NULL && eventRegistration.Opportunity__r.Amount > 0);

                            Form_Data__c fndFormData = mapOppIdFormData.get(eventRegistration.Opportunity__c);
                            if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);
                            if(fndFormData == NULL) {
                                if(eventRegistration.Event__r != NULL && eventRegistration.Event__r.Content__r != NULL && eventRegistration.Event__r.Content__r.Form__r != NULL) {
                                    String dt = eventRegistration.CreatedDate.format('yyyy-MM-dd');
                                    String key = eventRegistration.Contact__c + ':' + eventRegistration.Event__r.Content__r.Form__r.Form_Name__c + ':' + dt;
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData key',key);

                                    fndFormData = mapContFormNameDateFormData.get(key);
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);
                                }
                            }
                            if(fndFormData == NULL) {
                                fndFormData = mapContFirstFormData.get(cont.Id);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData by contact',fndFormData);
                            }
                            if(fndFormData != NULL) {
                                mp.Source_UTM_Campaign__c = fndFormData.UTM_Campaign__c;
                                mp.Source_UTM_Content__c = fndFormData.UTM_Content__c;
                                mp.Source_UTM_Medium__c = fndFormData.UTM_Medium__c;
                                mp.Source_UTM_Source__c = fndFormData.UTM_Source__c;
                                mp.Source_UTM_Term__c = fndFormData.UTM_Term__c;
                            }
                        }
                    }

                    // Get Newest Event Reg
                    if(lstEventLastIndex != NULL) {
                        Event_Registration__c eventRegistration = lstEventRegs[lstEventLastIndex];
                        DateTime eventRegistrationDate = eventRegistration.CreatedDate;
                        DateTime lastSourceDateTime = mapAccountLastSourceDateTime.get(cont.AccountId);

                        // Set Last Source
                        if(mp.Source_Last_Date__c == NULL || eventRegistrationDate > lastSourceDateTime) {
                            mapAccountLastSourceDateTime.put(cont.AccountId, eventRegistrationDate);
                            mp.Source_Last_Date__c = Date.ValueOf(eventRegistrationDate);
                            mp.Source_Last_Type__c = 'Event';
                        }
                    }

                    List<Webcast_Registration__c> lstWebcastRegs = mapContactWebcastRegs.get(cont.Id);
                    Integer lstWebcastLastIndex;
                    if(lstWebcastRegs != NULL && lstWebcastRegs.size() > 0) {
                        lstWebcastLastIndex = lstWebcastRegs.size()-1;

                        Webcast_Registration__c webcastRegistration = lstWebcastRegs[0];
                        mp.Webcast_Registrations__c = lstWebcastRegs.size();
                        mp.Webcast_First_Registration_Date__c = Date.ValueOf(webcastRegistration.CreatedDate);

                        // Find opp original source datetime
                        DateTime firstSourceDateTime = mapAccountOriginalSourceDateTime.get(cont.AccountId);

                        // If no opp original source or Event Reg is before Opp, use Event Reg as original source
                        if(firstSourceDateTime == NULL ||  webcastRegistration.CreatedDate < firstSourceDateTime) {
                            mapAccountOriginalSourceDateTime.put(cont.AccountId, webcastRegistration.CreatedDate);

                            mp.Source_First_Date__c = mp.Webcast_First_Registration_Date__c;
                            mp.Source_First_Type__c = 'Webcast';
                            if(webcastRegistration.Webcast__r != NULL && webcastRegistration.Webcast__r.Content__r != NULL && webcastRegistration.Webcast__r.Content__r.Form__r != NULL) {
                                String dt = webcastRegistration.CreatedDate.format('yyyy-MM-dd');
                                String key = webcastRegistration.Contact__c + ':' + webcastRegistration.Webcast__r.Content__r.Form__r.Form_Name__c + ':' + dt;
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData key',key);
                                Form_Data__c fndFormData = mapContFormNameDateFormData.get(key);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);
                                if(fndFormData != NULL) {
                                    mp.Source_UTM_Campaign__c = fndFormData.UTM_Campaign__c;
                                    mp.Source_UTM_Content__c = fndFormData.UTM_Content__c;
                                    mp.Source_UTM_Medium__c = fndFormData.UTM_Medium__c;
                                    mp.Source_UTM_Source__c = fndFormData.UTM_Source__c;
                                    mp.Source_UTM_Term__c = fndFormData.UTM_Term__c;
                                }
                            }
                        }
                    }
                    // Get Newest Webcast Reg
                    if(lstWebcastLastIndex != NULL) {
                        Webcast_Registration__c webcastRegistration = lstWebcastRegs[lstWebcastLastIndex];
                        DateTime webcastRegistrationDate = webcastRegistration.CreatedDate;
                        DateTime lastSourceDateTime = mapAccountLastSourceDateTime.get(cont.AccountId);

                        // Set Last Source
                        if(mp.Source_Last_Date__c == NULL || webcastRegistrationDate > lastSourceDateTime) {
                            mapAccountLastSourceDateTime.put(cont.AccountId, webcastRegistrationDate);
                            mp.Source_Last_Date__c = Date.ValueOf(webcastRegistrationDate);
                            mp.Source_Last_Type__c = 'Webcast';
                        }
                    }

                    List<Chapter_Meeting_Registration__c> lstChapterMeetingRegs = mapContactChapterMeetingRegs.get(cont.Id);
                    Integer lstChapterMeetingLastIndex;
                    if(lstChapterMeetingRegs != NULL && lstChapterMeetingRegs.size() > 0) {
                        lstChapterMeetingLastIndex = lstChapterMeetingRegs.size()-1;

                        Chapter_Meeting_Registration__c chapterMeetingRegistration = lstChapterMeetingRegs[0];
                        mp.Chapter_Meeting_Registrations__c = lstChapterMeetingRegs.size();
                        mp.Chapter_Meeting_First_Registration_Date__c = Date.ValueOf(chapterMeetingRegistration.CreatedDate);

                        // Find opp original source datetime
                        DateTime firstSourceDateTime = mapAccountOriginalSourceDateTime.get(cont.AccountId);

                        // If no opp original source or Event Reg is before Opp, use Event Reg as original source
                        if(firstSourceDateTime == NULL ||  chapterMeetingRegistration.CreatedDate < firstSourceDateTime) {
                            mapAccountOriginalSourceDateTime.put(cont.AccountId, chapterMeetingRegistration.CreatedDate);

                            mp.Source_First_Date__c = mp.Chapter_Meeting_First_Registration_Date__c;
                            mp.Source_First_Type__c = 'Chapter Meeting';
                            Form_Data__c fndFormData = mapOppIdFormData.get(chapterMeetingRegistration.Opportunity__c);
                            if(debug=='fine')
                                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);
                            if(fndFormData == NULL) {
                                if(chapterMeetingRegistration.Chapter_Meeting__r != NULL && chapterMeetingRegistration.Chapter_Meeting__r.Content__r != NULL && chapterMeetingRegistration.Chapter_Meeting__r.Content__r.Form__r != NULL) {
                                    String dt = chapterMeetingRegistration.CreatedDate.format('yyyy-MM-dd');
                                    String key = chapterMeetingRegistration.Contact__c + ':' + chapterMeetingRegistration.Chapter_Meeting__r.Content__r.Form__r.Form_Name__c + ':' + dt;
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData key',key);
                                    fndFormData = mapContFormNameDateFormData.get(key);
                                    if(debug=='fine')
                                        GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData',fndFormData);
                                }
                            }
                            if(fndFormData == NULL) {
                                fndFormData = mapContFirstFormData.get(cont.Id);
                                if(debug=='fine')
                                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','fndFormData by contact',fndFormData);
                            }
                            if(fndFormData != NULL) {
                                mp.Source_UTM_Campaign__c = fndFormData.UTM_Campaign__c;
                                mp.Source_UTM_Content__c = fndFormData.UTM_Content__c;
                                mp.Source_UTM_Medium__c = fndFormData.UTM_Medium__c;
                                mp.Source_UTM_Source__c = fndFormData.UTM_Source__c;
                                mp.Source_UTM_Term__c = fndFormData.UTM_Term__c;
                            }
                        }
                    }

                    // Get Newest ChapterMeeting Reg
                    if(lstChapterMeetingLastIndex != NULL) {
                        Chapter_Meeting_Registration__c chapterMeetingRegistration = lstChapterMeetingRegs[lstChapterMeetingLastIndex];
                        DateTime chapterMeetingRegistrationDate = chapterMeetingRegistration.CreatedDate;
                        DateTime lastSourceDateTime = mapAccountLastSourceDateTime.get(cont.AccountId);

                        // Set Last Source
                        if(mp.Source_Last_Date__c == NULL || chapterMeetingRegistrationDate > lastSourceDateTime) {
                            mapAccountLastSourceDateTime.put(cont.AccountId, chapterMeetingRegistrationDate);
                            mp.Source_Last_Date__c = Date.ValueOf(chapterMeetingRegistrationDate);
                            mp.Source_Last_Type__c = 'Chapter Meeting';
                        }
                    }

                }

                // If First and Last Source the same, just keep first
                if(mp != NULL && mp.Source_First_Date__c != NULL && mp.Source_Last_Date__c != NULL && mp.Source_First_Type__c != NULL && mp.Source_Last_Type__c != NULL &&
                   mp.Source_First_Date__c == mp.Source_Last_Date__c && mp.Source_First_Type__c == mp.Source_Last_Type__c) {
                       mp.Source_Last_Date__c = NULL;
                       mp.Source_Last_Type__c = NULL;
                   }

                // Fix renewal fields, if none, clear them out
                if(mp != NULL && mp.Membership_Number_of_Renewals__c == 0) {
                    mp.Membership_Number_of_Renewals__c = NULL;
                    mp.Membership_Last_Renewal_Date__c = NULL;
                }
            }

            // Set New / Update Profile Summaries
            List<Member_Profile_Summary__c> newProfileSummaries = new List<Member_Profile_Summary__c>();
            Set<String> newContactIDs = new Set<String>();
            Set<String> existingContactIDs = new Set<String>();
            List<Member_Profile_Summary__c> updateProfileSummaries = new List<Member_Profile_Summary__c>();

            for(Member_Profile_Summary__c mps :mapContactMemProfiles.values()) {
                if(mps.CreatedDate == NULL) {
                    newProfileSummaries.add(mps);
                    newContactIDs.add(mps.ContactId__c);
                } else {
                    updateProfileSummaries.add(mps);
                    existingContactIDs.add(mps.ContactId__c);
                }
            }
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','newProfileSummaries',newProfileSummaries);
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','newContactIDs',newContactIDs);
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','existingContactIDs',existingContactIDs);
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','updateProfileSummaries',updateProfileSummaries);

            // Insert New Member Profile Summaries
            If(!newProfileSummaries.IsEmpty()) {
                if(doUpdates)
                    insert newProfileSummaries;
            }
            If(!updateProfileSummaries.IsEmpty()) {
                if(doUpdates)
                    update updateProfileSummaries;
            }

            // Select them back out
            DateTime now = DateTime.now();
            List<Contact> lstUpdateContacts = new List<Contact>();

            List<Member_Profile_Summary__c> lstNewProfileSummaries = [select Id, ContactId__c, LastModifiedDate from Member_Profile_Summary__c where ContactId__c in :newContactIDs OR ContactId__c in :existingContactIDs];
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstNewProfileSummaries',lstNewProfileSummaries);

            MAP<String,Member_Profile_Summary__c> mapNewSumaries = new MAP<String,Member_Profile_Summary__c>();
            for(Member_Profile_Summary__c mps :lstNewProfileSummaries) {
                mapNewSumaries.put(mps.ContactId__c, mps);
            }
            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','mapNewSumaries',mapNewSumaries);

            if(!newContactIDs.IsEmpty()) {
                // Set Contact lookup to summaries
                for(Contact c :lstNewContacts) {
                    Member_Profile_Summary__c summary = mapNewSumaries.get(c.Id);
                    if(summary != NULL) {
                        c.Member_Profile_Summary__c = summary.Id;
                        c.Member_Profile_Last_Updated__c = summary.LastModifiedDate;
                        lstUpdateContacts.add(c);
                    }
                }
                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstUpdateContacts',lstUpdateContacts);
            }

            GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','lstExsitingContacts',lstExsitingContacts);
            if(!lstExsitingContacts.IsEmpty()) {
                for(Contact c :lstExsitingContacts) {
                    Member_Profile_Summary__c summary = mapNewSumaries.get(c.Id);
                    if(summary != NULL) {
                        c.Member_Profile_Last_Updated__c = summary.LastModifiedDate;
                        lstUpdateContacts.add(c);
                    }
                }
                GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','more lstUpdateContacts',lstUpdateContacts);
            }

            if(!lstUpdateContacts.IsEmpty()) {
                if(doUpdates)
                    update lstUpdateContacts;
            }


            if(!updateOpps.IsEmpty()) {
                if(doUpdates) {
                    for(Opportunity opp :updateOpps.values()) {
                        opp.Order_Summary_Last_Updated_Date__c = DateTime.Now().AddSeconds(5);
                    }

                    GARP_Common.debugLog('GARP_BC_MemberProfile','calcMemberProfileSummary','updateOpps',updateOpps);
                    update updateOpps.values();
                }
            }


        }catch(Exception e){

            AppError__c appErr = new AppError__c(
                Error__c = e.getMessage() + ':Line:' + e.getLineNumber() + ':' + lastContact,
                Method__c = 'GARP_BC_MemberProfile'
            );
            System.Debug('!!!!Catch:' + appErr);
            insert appErr;
        }

        return ret;
    }

    public static String getExamResult(String examResultIn) {
        String normalizedExamResult;
        if(examResultIn != NULL) {
            String examResultLow = examResultIn.ToLowerCase();
            if(examResultLow.IndexOf('show') > -1) {
                normalizedExamResult = 'No Show';
            } else if(examResultLow.IndexOf('graded') > -1) {
                normalizedExamResult = 'Not Graded';
            } else {
                normalizedExamResult = examResultIn;
            }
        }

        return normalizedExamResult;
    }

    public static Decimal getExamScore(Exam_Attempt__c examAttempt, String debug) {
        // Calc Score
        Decimal score = 0;
        Integer count = 0;
        if(examAttempt.Quartile_1__c != NULL) {
            score += examAttempt.Quartile_1__c;
            count++;
        }
        if(examAttempt.Quartile_2__c != NULL) {
            score += examAttempt.Quartile_2__c;
            count++;
        }
        if(examAttempt.Quartile_3__c != NULL) {
            score += examAttempt.Quartile_3__c;
            count++;
        }
        if(examAttempt.Quartile_4__c != NULL) {
            score += examAttempt.Quartile_4__c;
            count++;
        }
        if(examAttempt.Quartile_5__c != NULL) {
            score += examAttempt.Quartile_5__c;
            count++;
        }
        if(examAttempt.Quartile_6__c != NULL) {
            score += examAttempt.Quartile_6__c;
            count++;
        }
        if(examAttempt.Quartile_7__c != NULL) {
            score += examAttempt.Quartile_7__c;
            count++;
        }
        if(examAttempt.Quartile_8__c != NULL) {
            score += examAttempt.Quartile_8__c;
            count++;
        }
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getExamScore','score',score);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getExamScore','count',count);

        Decimal ratio;
        if(count > 0 && score > 0) {
            ratio = score / count;
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getExamScore','ratio',ratio);
        }
        return ratio;
    }

    public static Date getExamAdminDate(Exam_Attempt__c examAttempt) {
        map<String, String> monthMap = new map<String, String> {
            'January' => '1',
                'February' => '2',
                'March' => '3',
                'April' => '4',
                'May' => '5',
                'June' => '6',
                'July' => '7',
                'August' => '8',
                'September' => '9',
                'October' => '10',
                'November' => '11',
                'December' => '12'
                };

        Date dt;
        String m = monthMap.get(examAttempt.RPT_Administration_Month__c);
        if(m != NULL) {
            dt = Date.ValueOf(examAttempt.RPT_Administration_Year__c + '-' + m + '-1');
        }
        return dt;
    }


    public class oppInfo {
        public String oppType;
        public Boolean hasStudyMaterials;
        public Boolean hasMembership;
        public Boolean hasMembershipRefund;
        public String membershipType;
        public Boolean hasCompMembership;
        public Boolean hasAMP;
        public Boolean hasAFREE;
        public Boolean hasOnlyAFREE;
        public Decimal membershipAmount;
        public Integer membershipDuration;
        public String products;
        public String orderSummaryProductLine;
        public Boolean IsAutoRenew;
        public Boolean IsB2B;
        public Boolean IsScholarship;
    }

    public static oppInfo getOppTypeInformation(Opportunity opp, MAP<String, String> mapOppEventRegs, String debug) {
        oppInfo oppInfo = new oppInfo();
        oppInfo.oppType = 'Unknown';
        oppInfo.hasStudyMaterials=False;
        oppInfo.hasMembership=False;
        oppInfo.hasMembershipRefund=False;
        oppInfo.membershipType=Null;
        oppInfo.hasCompMembership=False;
        oppInfo.hasAMP = False;
        oppInfo.hasAFREE = False;
        oppInfo.hasOnlyAFREE = True;
        oppInfo.membershipAmount=0;
        oppInfo.membershipDuration=0;
        oppInfo.orderSummaryProductLine = 'Unknown';
        oppInfo.IsAutoRenew = False;
        oppInfo.IsB2B = FALSE;
        oppInfo.IsScholarship = FALSE;

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','opp',opp);
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','mapOppEventRegs',mapOppEventRegs);

        Set<String> alternateCompMembershipNames = new Set<String>{'Complimentary Individual Membership'};

        MAP<String,String> mapProdLineOppType = new MAP<String,String>();
        mapProdLineOppType.put('ERP','ERP');
        mapProdLineOppType.put('Events','Event');
        mapProdLineOppType.put('FFR','FFR');
        mapProdLineOppType.put('FRM','FRM');
        mapProdLineOppType.put('FRR','FRR');
        mapProdLineOppType.put('FRR25','FRR25');
        mapProdLineOppType.put('Micro Course','Micro Course');
        mapProdLineOppType.put('GARP','GARP Miscellaneous');
        mapProdLineOppType.put('GARP Content','GARP Content');
        mapProdLineOppType.put('Membership','Membership');
        mapProdLineOppType.put('SCR','SCR');
        mapProdLineOppType.put('RAI','RAI');
        mapProdLineOppType.put('Unknown','Unknown');

        if(!opp.OpportunityLineItems.IsEmpty()) {
            String mainProductName;
            oppInfo.products='';
            OpportunityLineItem studyLineItem;
            OpportunityLineItem memberLineItem;
            OpportunityLineItem contentLineItem;
            OpportunityLineItem coreLineItem;
            OpportunityLineItem garpLineItem;

            //String productLine;

            for(OpportunityLineItem oli :opp.OpportunityLineItems) {

                if(oli.Order_Summary_Is_B2B__c) {
                    oppInfo.IsB2B = TRUE;
                }
                if(oli.Order_Summary_Is_Scholarship__c) {
                    oppInfo.IsScholarship = TRUE;
                }

                // Replace Product Line, if not one of the core ones
                //if(productLine == NULL || productLine == 'GARP' || productLine == 'Unknown') {
                //    productLine = oli.Order_Summary_Product_Line__c;
                //}

                if(oli.Order_Summary_Product_Line__c == 'GARP') {
                    garpLineItem = oli;
                } else if(oli.Order_Summary_Product_Line__c == 'Membership') {

                    oppInfo.hasMembership = TRUE;
                    oppInfo.membershipAmount = oli.TotalPrice;
                    memberLineItem = oli;

                    if(oli.Order_Summary_Product_Name__c == 'Affiliate Membership') {
                        oppInfo.membershipType = 'Affiliate Membership';
                    } else if(oli.Order_Summary_Product_Name__c == 'Student Membership') {
                        oppInfo.membershipType = 'Student Membership';
                    } else {
                        oppInfo.membershipType = 'Individual Membership';
                    }

                    if(opp.Auto_Renew__c) {
                        oppInfo.IsAutoRenew = True;
                    }

                    if(oli.ProductCode == 'MEMFX') {
                        oppInfo.membershipDuration = 6;
                    } else if(oli.ProductCode == 'AFREE') {
                        oppInfo.membershipDuration = 999;
                    } else {
                        oppInfo.membershipDuration = 12;
                    }

                } else if(oli.Order_Summary_Product_Category__c == 'GARP Content') {
                      contentLineItem = oli;
                } else if(oli.Order_Summary_Product_Category__c == 'Study Material') {
                    oppInfo.hasStudyMaterials = TRUE;
                    studyLineItem = oli;
                } else {
                    coreLineItem = oli;
                }

                oppInfo.products+=oli.Product2.Name+':'+oli.ProductCode+':' + oli.Product2.Product_ID__c +'~';

                if(oli.ProductCode == 'MEMF' || oli.ProductCode == 'MEMFX' || productContains(oli, alternateCompMembershipNames, debug)) {
                    oppInfo.hasCompMembership = TRUE;
                }

                if(oli.ProductCode == 'PRFEE') {
                    oppInfo.hasAMP = True;
                }

                if(oli.ProductCode == 'AFREE') {
                    oppInfo.hasAFREE = True;
                } else {
                    oppInfo.hasOnlyAFREE = False;
                }
            }

            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','hasMembership',oppInfo.hasMembership);
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','hasCompMembership',oppInfo.hasCompMembership);
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','hasStudyMaterials',oppInfo.hasStudyMaterials);
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','products',oppInfo.products);

            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','garpLineItem',garpLineItem);
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','memberLineItem',memberLineItem);
            if(debug=='fine')
                GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','coreLineItem',coreLineItem);


            System.Debug('****coreLineItem:' + coreLineItem);

            if(coreLineItem != NULL) {
                oppInfo.orderSummaryProductLine = coreLineItem.Order_Summary_Product_Line__c;

                System.Debug('****orderSummaryProductLine:' + oppInfo.orderSummaryProductLine);

                String oppType = mapProdLineOppType.get(oppInfo.orderSummaryProductLine);
                System.Debug('****oppType:' + oppType);


                if(oppType != NULL) {
                    oppInfo.oppType = oppType;
                } else {
                    oppInfo.oppType = 'Unknown';
                }

                System.Debug('****oppInfo.oppType:' + oppInfo.oppType);

            } else if(memberLineItem != NULL) {
                oppInfo.oppType = oppInfo.membershipType;
                oppInfo.orderSummaryProductLine = memberLineItem.Order_Summary_Product_Line__c;

                // If Opp is Chapter Reg
                if(opp.Name == 'Chapter Meeting Registration') {
                    oppInfo.oppType = 'Chapter Meeting';
                    oppInfo.orderSummaryProductLine = 'Events';
                }
            } else if(contentLineItem != NULL) {
                oppInfo.oppType = 'GARP Content';
            } else if(studyLineItem != NULL) {
                oppInfo.oppType = 'Study Materials';
                oppInfo.orderSummaryProductLine = studyLineItem.Order_Summary_Product_Line__c;
            } else if(garpLineItem != NULL) {
                oppInfo.orderSummaryProductLine = garpLineItem.Order_Summary_Product_Line__c;

                String oppType = mapProdLineOppType.get(oppInfo.orderSummaryProductLine);
                if(oppType != NULL) {
                    oppInfo.oppType = oppType;
                } else {
                    oppInfo.oppType = 'Unknown';
                }
            } else {
                oppInfo.orderSummaryProductLine = 'Unknown';
                oppInfo.oppType = 'Unknown';
            }

            if(!oppInfo.hasAMP && !oppInfo.hasAFREE && opp.Amount > 0 && (opp.Alternate_Method_of_Payment__c == NULL || (opp.Alternate_Method_of_Payment__c.ToLowerCase() != 'cc' && opp.Alternate_Method_of_Payment__c.ToLowerCase() != 'credit card'))) {
                oppInfo.hasAMP = TRUE;
            }


            /*
            if(coreLineItem == NULL && garpLineItem == NULL && oppInfo.hasStudyMaterials) {
                oppInfo.oppType = 'Study Materials';
                oppInfo.orderSummaryProductLine = studyLineItem.Order_Summary_Product_Line__c;
            } else if(coreLineItem == NULL && garpLineItem == NULL && oppInfo.hasMembership) {
                oppInfo.oppType = 'Membership';
                oppInfo.orderSummaryProductLine = memberLineItem.Order_Summary_Product_Line__c;
            } else {
                if(coreLineItem != NULL) {
                  oppInfo.orderSummaryProductLine = coreLineItem.Order_Summary_Product_Line__c;
                } else if(garpLineItem != NULL) {
                    oppInfo.orderSummaryProductLine = garpLineItem.Order_Summary_Product_Line__c;
                } else {
                    oppInfo.orderSummaryProductLine = 'Unknown';
                }

                String oppType = mapProdLineOppType.get(oppInfo.orderSummaryProductLine);
                if(oppType != NULL) {
                    oppInfo.oppType = oppType;
                } else {
                    oppInfo.oppType = 'Unknown';
                }
            }
      */
        } else {
            oppInfo.hasOnlyAFREE = False;
        }

        for(Product_Refunds__c pr :opp.Product_Refunds__r) {
            if(pr.Refund_amount__c != NULL && pr.Refund_amount__c > 0) {
                if(pr.Product_Code__c == 'MEMF' || pr.Product_Code__c == 'MEMI' || pr.Product_Code__c == 'MEMC' || pr.Product_Code__c == 'MEMX') {
                    oppInfo.hasMembershipRefund=True;
                }
            }
        }
        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','hasMembershipRefund',oppInfo.hasMembershipRefund);

        if(debug=='fine')
            GARP_Common.debugLog('GARP_BC_MemberProfile','getOppTypeInformation','final oppInfo',oppInfo);

        return oppInfo;
    }

    public static Boolean productContains(OpportunityLineItem oli, Set<String> alternateNames, String debug) {
        Boolean ret = False;

        //if(debug=='fine')
            //GARP_Common.debugLog('GARP_BC_MemberProfile','productContains','oli',oli);
        //if(debug=='fine')
            //GARP_Common.debugLog('GARP_BC_MemberProfile','productContains','alternateNames',alternateNames);

        if(oli != NULL && oli.Product2 != NULL && oli.Product2.Name != NULL) {

            //if(debug=='fine')
                //GARP_Common.debugLog('GARP_BC_MemberProfile','productContains','oli prod name',oli.Product2.Name);


            for(String s :alternateNames) {

                //if(debug=='fine')
                    //GARP_Common.debugLog('GARP_BC_MemberProfile','productContains','Loop Alt Names',s);

                s = s.ToLowerCase();
                if(oli.Product2.Name.ToLowerCase().IndexOf(s) > -1) {

                    //if(debug=='fine')
                        //GARP_Common.debugLog('GARP_BC_MemberProfile','productContains','FOUND!',s);

                    return TRUE;
                }
            }
        }

        return ret;
    }


    public static GARP_Common.returnInfo submitCustomerCase(Contact contact, String userId, String title, String description) {
        GARP_Common.returnInfo ret = new GARP_Common.returnInfo();

        String cutomerCaseRecordTypeId = RecordTypeHelper.GetRecordTypeId('Case', 'Customer');

        Case newCase = new Case();
        newCase.RecordTypeId = cutomerCaseRecordTypeId;
        newCase.Subject = title;
        newCase.Description = description;
        newCase.Origin = 'Web';
        newCase.ContactId = contact.Id;
        newCase.OwnerId = Label.Case_Owner_For_MS;
        if(!Test.isRunningTest()) {
            insert newCase;
        }

        /*EmailMessage email = new EmailMessage();
        email.ParentId = newCase.Id; // Link the email to the Case
        email.Subject = title;
        email.TextBody = description;
        email.ToAddress = 'memberservices@garp.com';
        email.FromAddress = contact.Email;
        insert email; */
        List<Case_Email_Message_Event__e> inkEvents = new List<Case_Email_Message_Event__e>();
        inkEvents.add(new Case_Email_Message_Event__e(Case_Record__c=newCase.Id, Description__c=description,
                                          Subject__c=title,From_Email__c=contact.Email));

        if(!Test.isRunningTest()) {
            EventBus.publish(inkEvents);
        }
        ret.status = 'Success';
        ret.errorCode = 200;
        return ret;

    }

}