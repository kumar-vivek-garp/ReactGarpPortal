public class GARP_BC_Membership {

    private static final Integer MEMBERSHIP_BENEFIT_RANK_NULL_SENTINEL = 2147483647;
    
    // Wrappers
    public class membershipInfo {
        public Contact contactRecord;
        public Account accountRecord;
        public String GARPId;
        public Boolean isMember;
        public String currentMemberType;
        public Boolean isInGoodStanding;
        public Integer monthsLeftInMembershipContract;
        public Boolean isAutoRenewMembershipEnabled;
        public Boolean isFRMCertified;
        public Boolean isERPCertified;
        public Boolean isCertified;
        public Boolean isSCRHolder;
        public Boolean isRAIHolder;
        public Boolean isRAIJHolder;
    } 
    
    public class applicationException extends Exception {}
    
    // Registration Methods
    public static GARP_BC_Registration.programRegistrationInfo getMembershipRegistrationSettings(String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'membership';
        programRegistrationInfo.mainMemberProductCode = 'MEMI';
        programRegistrationInfo.mainNonMemberProductCode = 'MEMI';
        programRegistrationInfo.mainCertifiedProductCode = 'MEMC';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{'MEMR'};    
        programRegistrationInfo.formName = 'membership-individual';
        programRegistrationInfo.contractRecTypeName = 'Membership';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.membershipType = 'individual';
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;     
        programRegistrationInfo.regCode = regCode;
        
        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo getMembershipRegistrationInfo(String regCode) {        
        return GARP_BC_Registration.getRegistrationInfo(getMembershipRegistrationSettings(regCode));
    }
    
    public static GARP_BC_Registration.programRegistrationInfo getAffiliateMembershipRegistrationSettings() {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'membership';
        programRegistrationInfo.mainMemberProductCode = 'AFREE';
        programRegistrationInfo.mainNonMemberProductCode = 'AFREE';
        programRegistrationInfo.mainCertifiedProductCode = 'AFREE';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{};    
        programRegistrationInfo.formName = 'membership-affiliate';
        programRegistrationInfo.contractRecTypeName = 'Membership';
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.membershipType = 'affiliate';
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;

        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo getAffiliateMembershipRegistrationInfo() {        
        return GARP_BC_Registration.getRegistrationInfo(getAffiliateMembershipRegistrationSettings());
    }
    
    // Other Service Methods
    
    public static GARP_BC_Registration.RegistrationEligibility isEligibleIndividualMembership(GARP_BC_Membership.membershipInfo membershipInfo) {
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleIndividualMembership','membershipInfo',membershipInfo);
        
        GARP_BC_Registration.RegistrationEligibility reObj = new GARP_BC_Registration.RegistrationEligibility();
        
        if(membershipInfo != NULL && membershipInfo.isAutoRenewMembershipEnabled) {
            reObj.eligibleError = 'Auto-renew is turned on';
            reObj.isEligible = False;
        } else {
            reObj.eligibleError = null;
            reObj.isEligible = True;
        }
        
        GARP_Common.debugLog('GARP_BC_Exams','isEligibleIndividualMembership','final',reObj);
        return reObj;
    }
    
    public static GARP_Common.returnInfo turnOffAutoRenewal(String accountId, Contract membershipContract) {
        GARP_Common.debugLog('GARP_BC_Membership','turnOffAutoRenewal','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Membership','turnOffAutoRenewal','membershipContract',membershipContract);
        
        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
        
        if(membershipContract == NULL || membershipContract.status != 'Activated ( Auto-Renew )' ) {
            returnInfo.status = 'Error';
            returnInfo.msg = 'Membership Contract not found';
            returnInfo.errorCode = 401;
            return returnInfo;
        }
       
        List<Opportunity> lstOpp = new List<Opportunity>();
        for(Opportunity opp : [select id,Payment_Status__c from opportunity where accountId =:accountId and Payment_Status__c =: 'Recurring'])
        {
            opp.Payment_Status__c = 'Stopped';
            opp.Stripe_Outbound_Type__c = 'Cancel';
            lstOpp.add(opp);
        }
        GARP_Common.debugLog('GARP_BC_Membership','turnOffAutoRenewal','lstOpp',lstOpp);
        if(!lstOpp.IsEmpty()) {
            update lstOpp;
        } else {
            returnInfo.status = 'Error';
            returnInfo.msg = 'Opportunity not found';
            returnInfo.errorCode = 401;
            return returnInfo;
        }
            
        membershipContract.status = 'Activated';
        GARP_Common.debugLog('GARP_BC_Membership','turnOffAutoRenewal','membershipContract',membershipContract);
        update membershipContract;
        
        returnInfo.status = 'Success';
        returnInfo.errorCode = 200;
        
        return returnInfo;
    }
    
    public class returnEnableAutoRenew {
        public String status;
        public String message;
        public Boolean needPaymentInfo;
        public String orderId;
    }
    
    public static returnEnableAutoRenew enableAutoRenew(User user, Contact contact, Contract membershipContract, Boolean isCertHolder) {
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','contact',contact);
        
        returnEnableAutoRenew ret = new returnEnableAutoRenew();
        ret.needPaymentInfo = False;
        
        GARP_Common.address billingAddress = new GARP_Common.address();
        billingAddress.company = contact.Account.Billing_Address_Company__c;
        billingAddress.city = contact.Account.BillingCity;
        billingAddress.province = contact.Account.BillingState;
        billingAddress.postalCode = contact.Account.BillingPostalCode;
        billingAddress.country = contact.Account.BillingCountry;
        billingAddress.phone = contact.HomePhone;
        
        GARP_Common.address streets = GARP_Common.parseMultiAddressLine(contact.Account.BillingStreet);
        billingAddress.street1 = streets.street1;
        billingAddress.street2 = streets.street2;
        billingAddress.street3 = streets.street3;
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','billingAddress',billingAddress);
        
        GARP_Common.address shippingAddress = new GARP_Common.address();
        shippingAddress.city = contact.MailingCity;
        shippingAddress.province = contact.MailingState;
        shippingAddress.postalCode = contact.MailingPostalCode;
        shippingAddress.country = contact.MailingCountry;
        
        GARP_Common.address streetsShip = GARP_Common.parseMultiAddressLine(contact.MailingStreet);
        shippingAddress.street1 = streetsShip.street1;
        shippingAddress.street2 = streetsShip.street2;
        shippingAddress.street3 = streetsShip.street3;
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','shippingAddress',shippingAddress);
        
        GARP_StripeClass.returnGetCustomer returnGetCustomer = GARP_StripeClass.getCustomerPaymentInfo(contact, billingAddress, shippingAddress);
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','returnGetCustomer',returnGetCustomer);
        
        if(returnGetCustomer.status == 'Failure') {
            ret.status = returnGetCustomer.status;
            ret.message = returnGetCustomer.message;
            return ret;
        }
        
        if(!returnGetCustomer.stripeIDExistsOnContact) {
            contact.Stripe_Customer_ID__c = returnGetCustomer.stripeCustomerId;
            update contact;
        }
        
        // Create Opp to enable auto-renew
        GARP_BC_Orders.orderPaymentInfo orderPaymentInfo = new GARP_BC_Orders.orderPaymentInfo();
        orderPaymentInfo.billingAddress = billingAddress;
        
        GARP_BC_Registration.orderCustomerInfo customerInfo = new GARP_BC_Registration.orderCustomerInfo();
        customerInfo.email = contact.Email;
        customerInfo.firstName = contact.FirstName;
        customerInfo.lastName = contact.LastName;
        customerInfo.phone = contact.HomePhone;
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','customerInfo',customerInfo);
        
        returnRenewalCreateOrder retTurnOnOpp = turnOnAutoRenewalCreateOrder(user, contact, membershipContract, orderPaymentInfo, customerInfo, isCertHolder);
        GARP_Common.debugLog('GARP_BC_Membership','enableAutoRenew','retTurnOnOpp',retTurnOnOpp);
        
        if(retTurnOnOpp.errorCode != 200 || retTurnOnOpp.recurringOpp == NULL) {
            ret.status = 'Failure';
            ret.message = 'Order could not be staged';
            ret.needPaymentInfo = False;
            return ret;
        }
        
        ret.orderId = retTurnOnOpp.recurringOpp.Id;
        
        // Already has default payment method
        if(returnGetCustomer.defaultPaymentMethodId != NULL) {
            
            // Close Opp to create subscription
            retTurnOnOpp.recurringOpp.StageName = 'Recurring Intent';
            update retTurnOnOpp.recurringOpp;
            
            ret.status = 'Success';
            ret.message = 'Auto-Renew Enabled';
            
        } else {
            // Default Payment not found
            ret.status = 'Success';
            ret.message = 'Payment details needed';
            ret.needPaymentInfo = True;
        }
        
        return ret;
    }
    
    public class returnRenewalCreateOrder {
        public String status;
        public String message;
        public Integer errorCode;
        public Opportunity recurringOpp;
    }
    
    public static returnRenewalCreateOrder turnOnAutoRenewalCreateOrder(User user, Contact contact, Contract membershipContract, GARP_BC_Orders.orderPaymentInfo paymentInfo, GARP_BC_Registration.orderCustomerInfo customerInfo, Boolean isCertHolder){
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','contact',contact);
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','membershipContract',membershipContract);
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','paymentInfo',paymentInfo);
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','isCertHolder',isCertHolder);
        
        returnRenewalCreateOrder returnInfo = new returnRenewalCreateOrder();
        
        if(membershipContract == NULL || membershipContract.status != 'Activated' ) {
            returnInfo.status = 'Error';
            returnInfo.message = 'Membership Contract not found';
            returnInfo.errorCode = 401;
            return returnInfo;
        }
        
        Id OppAutoRecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity','Automated');
        
        List<String> productCodes = new List<String>();
        productCodes.addAll(new List<String>{'MEMI','MEMC'});
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, NULL);

        PricebookEntry pbe;
        if(isCertHolder) {
            pbe = mapProdByCodes.get('MEMC:4040');
        } else {
            pbe = mapProdByCodes.get('MEMI:4040');
        }
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','pbe',pbe);
        
        GARP_BC_Registration.membershipOptions membershipOptions = new GARP_BC_Registration.membershipOptions();
        membershipOptions.autoRenew = False;
        
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','membershipOptions',membershipOptions);
        
        List<GARP_BC_Orders.productInfo> productInfo = new List<GARP_BC_Orders.productInfo>();
        GARP_BC_Orders.productInfo prodInfo = new GARP_BC_Orders.productInfo(pbe);
        productInfo.add(prodInfo);
        
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','productInfo',productInfo);
        
        Opportunity opp = GARP_BC_Orders.createOpportunity(user, contact.AccountId, customerInfo, paymentInfo, membershipOptions, productInfo, NULL);
        opp.Renew_Membership__c = true;
        opp.Auto_Renew__c = true;
        opp.Manual_Charge__c = true;
        opp.Charge_Amount__c = pbe.UnitPrice;
        opp.Eligible_for_Membership_Extension__c = False;
        opp.Stripe_Outbound_Type__c = 'Create';
        opp.StageName = 'New Lead';
        opp.Token__c = contact.Stripe_Customer_ID__c;
        opp.Gateway_Token__c = contact.Stripe_Customer_ID__c;
        opp.Token__c = contact.Stripe_Customer_ID__c;
        
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','opp',opp);
        
        insert opp;
        returnInfo.recurringOpp = opp;
        
        // Update Contract with this new Opp
        membershipContract.Opportunity__c = opp.id;
        update membershipContract;
        
        OpportunityContactRole contactRole = new OpportunityContactRole(OpportunityId=opp.id, ContactId=contact.Id, Role='Decision Maker');
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','contactRole',contactRole);
        insert contactRole;
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opp.Id;
        oppLineItem.PricebookEntryId = pbe.Id;
        oppLineItem.Quantity = 1;
        oppLineItem.TotalPrice = pbe.UnitPrice;
        GARP_Common.debugLog('GARP_BC_Membership','turnOnAutoRenewalCreateOrder','oppLineItem',oppLineItem);
        insert oppLineItem;

        // AG 2/23/2026 No longer caller here        
        //opp.StageName = 'Recurring Intent';
        //update opp;
        
        returnInfo.status = 'Success';
        returnInfo.message = 'Opportunity Created';
        returnInfo.errorCode = 200;
        
        return returnInfo;
    }
    
    // Member Directory

    public class searchParams {
        public Boolean FRMOnly;
        public Boolean ERPOnly;
        public Boolean SCROnly;
        public Boolean RAIOnly;
        public String searchText;
        public String industries;
        public String jobFunctions;
        public String riskSpecialties;
        public String corporateTitles;
        public String company;
        public String sortField;
        public String sortOrder;
        public Integer pageSize;
        public Integer pageCurrent;
        public String skipOptIn;
    }
    
    public class searchResults {
        public List<searchMember> members { get; set; }
        public Integer pages  { get; set; }
    }
    
    public class searchMember {
        public String id;
        public String accountId;
        public String GARPId;
        public String membershipType;        
        public String membershipPaymentStatus;
        public Date membershipSince;
        
        public String name;
        public String firstName;
        public String lastName;
        public String middleInitial;
        public String mailingCity;
        public String mailingCountry;

        public String corporateTitle;
        public String company;
        public String photoURL;        
        
        public Boolean isFRMCertified;
        public Date FRMCertifiedDate;
        public Boolean isERPCertified;
        public Date ERPCertifiedDate;
        public Boolean isSCRHolder;
        public Boolean isRAIHolder;
        public Date SCRCompletionDate;
        public Date RAICompletionDate;
        
        public String CPERequirementStatus;
        public String CPECurrentCycle;
        public String CPELastCompletedCycle;

        public String jobFunction;
        public String riskSpecialty;
        public String areaofConcentration;
        
        public Boolean professionalDesignationCA;
        public Boolean professionalDesignationCFA;
        public Boolean professionalDesignationCMA;
        public Boolean professionalDesignationCPA;
        public Boolean professionalDesignationOther;
        public Boolean professionalDesignationPMP;
        public Boolean professionalDesignationACCA;
        public String otherQualifications;
        
        // Access & Display Settings
        public Boolean directoryOptIn;
        public Boolean directoryInviteOptOut;
        public Boolean dirPrivacyAdditionalDetail;
        public Boolean dirPrivacyJobInformation;
        public Boolean dirPrivacyProfBackground;
        public Boolean directoryConnectFeature;
        
        public Boolean canSendMessage;
        public Boolean canInvite;
        
    }
    
    public static searchResults searchMembers(String contactId, searchParams searchParams, Boolean isMemberInGoodStanding) {

        String querystr = '';
        String likeClause = '%'+searchParams.searchText+'%';
        String filterClause='';
        String fieldsClause = 'Id, Name, AccountId, GARP_ID__c, FirstName, LastName, Middle_Initial__c, MailingCity, MailingCountry,';
        fieldsClause += 'KPI_CPE_Current_Cycle__c, KPI_CPE_Last_Completed_Cycle__c, KPI_CPE_Requirement_Status__c,';
        fieldsClause += 'Job_Function__c, Risk_Specialty__c, Area_of_Concentration__c, Corporate_Title__c, Company__c, Photo_URL__c,';
        fieldsClause += 'GARP_Directory_Opt_In__c, GARP_Directory_Invite_Opt_Out__c, GARP_Dir_Privacy_Additional_Detail__c, GARP_Dir_Privacy_Job_Information__c, GARP_Dir_Privacy_Prof_Background__c, GARP_Directory_Connect_Feature__c,';
        fieldsClause += 'Membership_Type__c, MPS_Membership_Status__c, MPS_Membership_Start_Date__c,';
        fieldsClause += 'MPS_FRM_Completed__c, MPS_FRM_Completed_Date__c ,MPS_ERP_Completed__c ,MPS_ERP_Completed_Date__c , MPS_SCR_Completed__c, MPS_SCR_Completed_Date__c,MPS_RAI_Completed__c,MPS_RAI_Completed_Date__c,';
        fieldsClause += 'Professional_Designation_CA__c, Professional_Designation_CFA__c, Professional_Designation_CMA__c, Professional_Designation_CPA__c, Professional_Designation_Other__c, Professional_Designation_PMP__c, Professional_Designation_ACCA__c, Other_Qualifications__c';

        if(searchParams.FRMOnly == True || searchParams.ERPOnly == True || searchParams.SCROnly == True || searchParams.RAIOnly == True) {
            if(searchParams.FRMOnly == True)
              filterClause = ' and (MPS_FRM_Completed__c = true';
            if(searchParams.ERPOnly == True)
              filterClause += filterClause == '' ? ' and (MPS_ERP_Completed__c = true' : ' or MPS_ERP_Completed__c = true';
            if(searchParams.SCROnly == True)
              filterClause += filterClause == '' ? ' and (MPS_SCR_Completed__c = true' : ' or MPS_SCR_Completed__c = true';
            if(searchParams.RAIOnly == True)
              filterClause += filterClause == '' ? ' and (MPS_RAI_Completed__c = true' : ' or MPS_RAI_Completed__c = true';
            filterClause += ')';
        }
        else {
            if(isMemberInGoodStanding == False) {
                filterClause = ' and (MPS_FRM_Completed__c = true or MPS_ERP_Completed__c = true or MPS_SCR_Completed__c = true or MPS_RAI_Completed__c = true)';
            } else {
                filterClause = ' and (MPS_Membership_Status__c = \'Active\' OR MPS_FRM_Completed__c = true OR MPS_ERP_Completed__c = true OR MPS_SCR_Completed__c = true OR MPS_RAI_Completed__c = true)';
            }
        }

        system.debug('* * * filterClause ...'+ filterClause);

        String query = 'SELECT ' + fieldsClause + ' FROM Contact';

        if(searchParams.sortField == NULL) {
            searchParams.sortField = 'LastName';
        }
        if(searchParams.sortOrder == NULL) {
            searchParams.sortOrder = 'DESC';
        }

        String sortClause = ' ORDER BY ' + searchParams.sortField + ' ' + searchParams.sortOrder + ' NULLS LAST ';

        String whereClause;
        if(searchParams.company == '' && searchParams.industries == '' && searchParams.jobFunctions == '' && searchParams.corporateTitles == '' && searchParams.riskSpecialties == '') {
            if (searchParams.skipOptIn == 'Yes') {
                whereClause = ' WHERE (Name like :likeClause OR MailingCity like :likeClause OR MailingCountry like :likeClause)';
            }else{
                whereClause = ' WHERE GARP_Directory_Opt_In__c = true and (Name like :likeClause OR MailingCity like :likeClause OR MailingCountry like :likeClause)';
            }  
            system.debug('* * * whereClause ...'+ whereClause);

        } else {

            String industriesInClause = '';
            String[] arrText;
            if(searchParams.industries != '') {
                arrText = searchParams.industries.split('; ');
                for(String s :arrText) {
                    if(industriesInClause == '') {
                        industriesInClause = '\'' + s + '\'';
                    } else {
                        industriesInClause = industriesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String jobFunctionsInClause = '';
            if(searchParams.jobFunctions != '') {
                arrText = searchParams.jobFunctions.split('; ');
                for(String s :arrText) {
                    if(jobFunctionsInClause == '') {
                        jobFunctionsInClause = '\'' + s + '\'';
                    } else {
                        jobFunctionsInClause = jobFunctionsInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String riskSpecialtiesInClause = '';
            if(searchParams.riskSpecialties != '') {
                arrText = searchParams.riskSpecialties.split('; ');
                for(String s :arrText) {
                    if(riskSpecialtiesInClause == '') {
                        riskSpecialtiesInClause = '\'' + s + '\'';
                    } else {
                        riskSpecialtiesInClause = riskSpecialtiesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String corporateTitlesInClause = '';
            if(searchParams.corporateTitles != '') {
                arrText = searchParams.corporateTitles.split('; ');
                for(String s :arrText) {
                    if(corporateTitlesInClause == '') {
                        corporateTitlesInClause = '\'' + s + '\'';
                    } else {
                        corporateTitlesInClause = corporateTitlesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            //String likeClause = searchText; 
            if (searchParams.skipOptIn == 'Yes') {               
                 whereClause = ' WHERE (GARP_Directory_Opt_In__c = true or GARP_Directory_Opt_In__c = false)';
            }else{
                 whereClause = ' WHERE GARP_Directory_Opt_In__c = true ';
            }
           
            if(searchParams.industries != '') {
                whereClause +=  ' and Area_of_Concentration__c in (' + industriesInClause + ')';
            }
            if(searchParams.jobFunctions != '') {
                whereClause +=  ' and Job_Function__c in (' + jobFunctionsInClause + ')';
            }
            if(searchParams.riskSpecialties != '') {
                whereClause +=  ' and Risk_Specialty__c in (' + riskSpecialtiesInClause + ')';
            }
            if(searchParams.corporateTitles != '') {
                whereClause +=  ' and Corporate_Title__c in (' + corporateTitlesInClause + ')';
            }
            if(searchParams.company != '') {
                String companyLikeClause = '%'+searchParams.company+'%';
                whereClause +=  ' and Company__c like :companyLikeClause';
            }
            whereClause +=  ' and (Name like :likeClause OR MailingCity like :likeClause OR MailingCountry like :likeClause)';

            system.debug('* * * whereClause ...'+ whereClause);

        }

        querystr = query + whereClause + filterClause + sortClause + ' LIMIT ' + searchParams.pageSize + ' offset ' + (searchParams.pageCurrent-1)*searchParams.pageSize;
        system.debug('* * * query ...'+ querystr);

        List<Id> ids = new List<Id>();
        List<Contact> lstContact = database.query(querystr);
        for(Contact con :lstContact){
            ids.add(con.Id);
        }

        String cntQuery = 'SELECT Count() FROM Contact ' + whereClause + filterClause;

        integer count= database.countQuery(cntQuery);
        system.debug('* * * count ...'+ count);

        /*
        List<Contact> returnListContact = new List<Contact>();
        List<Id> ids = new List<Id>();
        if(lstContact.size() > pageSize) {
            Integer count = 1;
            Integer page = 1;
            for(Contact con :lstContact){
                if(page == pageCurrent) {
                    returnListContact.add(con);
                    ids.add(con.Id);
                }
                count++;
                if(count > pageSize) {
                    count=1;
                    page++;
                }
            }
        } else {
            returnListContact = lstContact;
        }
        */

        searchResults results = new searchResults();
        //results.lstUser = [select Id, Name, FullPhotoUrl, ContactId from User where ContactId in :ids];
    results.members = new List<searchMember>();

        Decimal myDecimal = count;
        Decimal divDec = myDecimal.divide(searchParams.pageSize, 0, System.RoundingMode.UP);
        system.debug('* * * divDec ...'+ divDec);

        results.pages = divDec.intValue();

        for(Contact contact_result :lstContact){

            searchMember searchMember = new searchMember();
            searchMember.id = contact_result.Id;
            searchMember.accountId  = contact_result.AccountId;
            searchMember.GARPId = contact_result.GARP_ID__c ;
            searchMember.membershipType = contact_result.Membership_Type__c;
            searchMember.membershipPaymentStatus = contact_result.MPS_Membership_Status__c;
            searchMember.membershipSince = contact_result.MPS_Membership_Start_Date__c;
            searchMember.name = contact_result.Name;
            searchMember.firstName = contact_result.FirstName;
            searchMember.lastName = contact_result.LastName;
            searchMember.middleInitial = contact_result.Middle_Initial__c;
            searchMember.mailingCity = contact_result.MailingCity;
            searchMember.mailingCountry = contact_result.MailingCountry;

            searchMember.photoURL = contact_result.Photo_URL__c;
            searchMember.directoryOptIn = contact_result.GARP_Directory_Opt_In__c;
            searchMember.directoryInviteOptOut = contact_result.GARP_Directory_Invite_Opt_Out__c;
            searchMember.dirPrivacyAdditionalDetail = contact_result.GARP_Dir_Privacy_Additional_Detail__c;
            searchMember.dirPrivacyJobInformation = contact_result.GARP_Dir_Privacy_Job_Information__c;
            searchMember.dirPrivacyProfBackground = contact_result.GARP_Dir_Privacy_Prof_Background__c;
            searchMember.directoryConnectFeature = contact_result.GARP_Directory_Connect_Feature__c;
            searchMember.isFRMCertified = contact_result.MPS_FRM_Completed__c;
            searchMember.FRMCertifiedDate = contact_result.MPS_FRM_Completed_Date__c;
            searchMember.isERPCertified = contact_result.MPS_ERP_Completed__c;
            searchMember.ERPCertifiedDate = contact_result.MPS_ERP_Completed_Date__c;
            searchMember.isSCRHolder = contact_result.MPS_SCR_Completed__c;
            searchMember.SCRCompletionDate = contact_result.MPS_SCR_Completed_Date__c;
            searchMember.RAICompletionDate = contact_result.MPS_RAI_Completed_Date__c;
            searchMember.isRAIHolder = contact_result.MPS_RAI_Completed__c;

            // 2. If they would like the CPD status displayed <<<<<< GARP_Dir_Privacy_Additional_Detail__c <<<<<<<< return null for CPD status
            if(contact_result.GARP_Dir_Privacy_Additional_Detail__c && isMemberInGoodStanding){
                searchMember.CPERequirementStatus = contact_result.KPI_CPE_Requirement_Status__c;
                searchMember.CPECurrentCycle = contact_result.KPI_CPE_Current_Cycle__c;
                searchMember.CPELastCompletedCycle = contact_result.KPI_CPE_Last_Completed_Cycle__c;
            }
            // 3. Show my Organization type and expertise <<<<<<< GARP_Dir_Privacy_Job_Information__c <<<<<<<< return null for job and expertise
            if(contact_result.GARP_Dir_Privacy_Job_Information__c && isMemberInGoodStanding){
                searchMember.areaofConcentration = contact_result.Area_of_Concentration__c;
                searchMember.professionalDesignationCA  = contact_result.Professional_Designation_CA__c;
                searchMember.professionalDesignationCFA = contact_result.Professional_Designation_CFA__c;
                searchMember.professionalDesignationCMA = contact_result.Professional_Designation_CMA__c;
                searchMember.professionalDesignationCPA = contact_result.Professional_Designation_CPA__c;
                searchMember.professionalDesignationPMP = contact_result.Professional_Designation_PMP__c;
                searchMember.professionalDesignationACCA  = contact_result.Professional_Designation_ACCA__c;
                searchMember.professionalDesignationOther = contact_result.Professional_Designation_Other__c;
                searchMember.otherQualifications  = contact_result.Other_Qualifications__c;
                searchMember.jobFunction = contact_result.Job_Function__c;
                searchMember.riskSpecialty = contact_result.Risk_Specialty__c;
            }
            // 4. show my job title and company <<<<<<< GARP_Dir_Privacy_Prof_Background__c  <<<<<<<< return null for job title and company
            if(contact_result.GARP_Dir_Privacy_Prof_Background__c && isMemberInGoodStanding) {
                searchMember.corporateTitle = contact_result.Corporate_Title__c;
                searchMember.company = contact_result.Company__c;
            }


            // Access & Display Settings
            searchMember.canSendMessage = False;
            searchMember.canInvite = False;
            if(contactId != contact_result.Id) {
                if(isMemberInGoodStanding && contact_result.Membership_Type__c == 'Individual' && contact_result.MPS_Membership_Status__c == 'Active' && contact_result.GARP_Directory_Connect_Feature__c) {
                    searchMember.canSendMessage = True;
                } else if(isMemberInGoodStanding && !contact_result.GARP_Directory_Invite_Opt_Out__c) {
                    searchMember.canInvite = True;
                }
            }

            results.members.add(searchMember);
        }
        return results;
    }


    public class sendMemberMessageInfo {
        public String recipientContactId;
        public String messageType;
        public String message;
    }
    
    public static String sendDirectoryMessage(Contact srcContact, Boolean isMemberInGoodStanding, sendMemberMessageInfo sendMemberMessageInfo){
        String ret = 'Success';
        
        List<Contact> rcptContactlst = [SELECT Id, FirstName, LastName, Email_URL__c, Email_WebSite_URL__c, Email, GARP_Member_ID__c,Name, 
                                        GARP_Directory_Connect_Recieve_Count__c, GARP_Directory_Invite_Opt_Out__c, GARP_Directory_Connect_Feature__c 
                                        FROM Contact WHERE Id = :sendMemberMessageInfo.recipientContactId];
        
        //System.assert(false, 'BOOM!'+ srcContactlst);
        
        if( srcContact != NULL && !rcptContactlst.IsEmpty()) {
            
            Contact rcptContact = rcptContactlst[0];
            
            // New Rules 2019
            if(sendMemberMessageInfo.messageType == 'Directory_Connect_Invite') {
                
                if(!isMemberInGoodStanding || rcptContact.GARP_Directory_Invite_Opt_Out__c == true) {
                    return 'Unauthorized Access1';
                }
                
            } else if(!isMemberInGoodStanding || rcptContact.GARP_Directory_Connect_Feature__c == false) {
                return 'Unauthorized Access2';
            }
            
            // grab the email template
            EmailTemplate emailTemplate = [select Id, Subject, HtmlValue, Body from EmailTemplate where DeveloperName = :sendMemberMessageInfo.messageType];
            
            // process the merge fields
            String subject = emailTemplate.Subject;
            subject = subject.replace('{!Account.Name}', rcptContact.Name);
            
            String htmlBody = emailTemplate.HtmlValue;
            
            system.debug('* * * HtmlValue Before ...'+ htmlBody);
            
            htmlBody = htmlBody.replace('{!Contact.GARP_ID__c}', rcptContact.GARP_Member_ID__c);
            htmlBody = htmlBody.replace('{!Contact.FirstName}', rcptContact.FirstName);
            htmlBody = htmlBody.replace('{!Contact.LastName}', rcptContact.LastName);
            
            htmlBody = htmlBody.replace('{!srcContact.FirstName}', srcContact.FirstName);
            htmlBody = htmlBody.replace('{!srcContact.LastName}', srcContact.LastName);
            htmlBody = htmlBody.replace('{!srcContact.Email}', srcContact.Email);
            
            htmlBody = htmlBody.replace('{!Contact.Email_URL__c}', rcptContact.Email_URL__c);
            htmlBody = htmlBody.replace('{!Contact.Email_WebSite_URL__c}', rcptContact.Email_WebSite_URL__c);
            
            htmlBody = htmlBody.replace('{!Contact.Id}', rcptContact.Id);
            htmlBody = htmlBody.replace('{!CustomText}', sendMemberMessageInfo.message);
            
            htmlBody = htmlBody.replace('<![CDATA[', '');
            htmlBody = htmlBody.replace(']]>', '');
            
            
            system.debug('* * * HtmlValue After ...'+ htmlBody);
            
            String plainBody = emailTemplate.Body;
            
            system.debug('* * * plainBody Before ...'+ plainBody);
            
            plainBody = plainBody.replace('{!Contact.GARP_ID__c}', rcptContact.GARP_Member_ID__c);
            plainBody = plainBody.replace('{!Contact.FirstName}', rcptContact.FirstName);
            plainBody = plainBody.replace('{!Contact.LastName}', rcptContact.LastName);
            
            plainBody = plainBody.replace('{!srcContact.FirstName}', srcContact.FirstName);
            plainBody = plainBody.replace('{!srcContact.LastName}', srcContact.LastName);
            plainBody = plainBody.replace('{!srcContact.Email}', srcContact.Email);
            
            plainBody = plainBody.replace('{!Contact.Email_URL__c}', rcptContact.Email_URL__c);
            plainBody = plainBody.replace('{!Contact.Email_WebSite_URL__c}', rcptContact.Email_WebSite_URL__c);
            
            plainBody = plainBody.replace('{!Contact.Id}', sendMemberMessageInfo.recipientContactId);
            plainBody = plainBody.replace('{!CustomText}', sendMemberMessageInfo.message);
            
            system.debug('* * * plainBody After ...'+ plainBody);
            
            //build the email message
            Messaging.Singleemailmessage email = new Messaging.Singleemailmessage();
            
            email.setReplyTo(srcContact.Email);
            email.setSenderDisplayName(srcContact.FirstName + ' ' + srcContact.LastName);
            email.setTargetObjectId(rcptContact.Id);
            email.setSaveAsActivity(false);
            
            email.setSubject(subject);
            email.setHtmlBody(htmlBody);
            email.setPlainTextBody(plainBody);
            
            system.debug('email:'+ email);
            
            if(!Test.isRunningTest()) {
                Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailmessage[] {email});
                system.debug('results:'+ results);
            }
            
            if(rcptContactlst[0].GARP_Directory_Connect_Recieve_Count__c == null)
                rcptContactlst[0].GARP_Directory_Connect_Recieve_Count__c=1;
            else rcptContactlst[0].GARP_Directory_Connect_Recieve_Count__c++;
            
            update rcptContactlst;
            
            if(srcContact.GARP_Directory_Connect_Send_Count__c == null)
                srcContact.GARP_Directory_Connect_Send_Count__c=1;
            else srcContact.GARP_Directory_Connect_Send_Count__c++;
            
            update srcContact;
        } else {
            return 'Contact not found';
        }
        
        return ret;
    }
    
    // Membership Benefits
     
    public class memberBenefitsInfo {
        public List<memberBenefitsCategory> benefitCategories;
    }
    
    public class memberBenefitsCategory {
        public String name;
        public List<memberBenefit> benefits;
    }
    
    public class memberBenefit {
        public String title;
        public String key;        
        public String logoURL;
        public Boolean hasAccess;        
        public String description;
        public String accessButton;
        public String accessURL;     
        public Boolean accessURLNewWindow;     
        public String popUpDescription;
        public Integer rankOrder;
        public String category;
        public String purchaseOverrideTitle;
        public String purchaseOverrideURL;
        public String purchaseOverridePendingOrderId;
        
        public memberBenefit(String keyIn, Decimal rankOrderIn, String categoryIn, String titleIn, String logoURLIn, Boolean hasAccessIn, String noAccessDescriptionIn, String accessDescriptionIn, String popUpDescriptionIn, String accessButtonIn, String accessURLIn, Boolean accessURLNewWindowIn) {
            title = titleIn;
            key = keyIn;
            logoURL = logoURLIn;
            hasAccess = hasAccessIn;
            if(hasAccess) {
                description = accessDescriptionIn;
            } else {
                description = noAccessDescriptionIn;
                popUpDescription = popUpDescriptionIn;
            }
            rankOrder = (rankOrderIn == NULL) ? NULL : Integer.valueOf(rankOrderIn);
            accessButton = accessButtonIn;
            accessURL = accessURLIn;
            accessURLNewWindow = accessURLNewWindowIn;
            if(String.isBlank(categoryIn)) {
                category = '';
            } else {
                category = categoryIn.trim();
            }
        }
    }
    
    private static String membershipBenefitCategoryGroupingKey(String raw) {
        if(String.isBlank(raw)) {
            return '';
        }
        String t = raw.trim().replaceAll('\\s+', ' ');
        return t.toLowerCase();
    }

    private static Integer compareMemberBenefitsForSort(memberBenefit o1, memberBenefit o2) {
        Integer r1 = (o1.rankOrder == NULL) ? MEMBERSHIP_BENEFIT_RANK_NULL_SENTINEL : o1.rankOrder;
        Integer r2 = (o2.rankOrder == NULL) ? MEMBERSHIP_BENEFIT_RANK_NULL_SENTINEL : o2.rankOrder;
        if(r1 < r2) {
            return -1;
        }
        if(r1 > r2) {
            return 1;
        }
        String k1 = (o1.key == NULL) ? '' : o1.key;
        String k2 = (o2.key == NULL) ? '' : o2.key;
        return k1.compareTo(k2);
    }

    private static void sortMemberBenefitsInPlace(List<memberBenefit> benefitRows) {
        Integer n = benefitRows.size();
        for(Integer i = 0; i < n; i++) {
            for(Integer j = i + 1; j < n; j++) {
                if(compareMemberBenefitsForSort(benefitRows[i], benefitRows[j]) > 0) {
                    memberBenefit tmp = benefitRows[i];
                    benefitRows[i] = benefitRows[j];
                    benefitRows[j] = tmp;
                }
            }
        }
    }

    private static void sortCategoryKeysInPlace(List<String> keys, Map<String, Integer> minRankByCategory) {
        Integer n = keys.size();
        for(Integer i = 0; i < n; i++) {
            for(Integer j = i + 1; j < n; j++) {
                String a = keys[i];
                String b = keys[j];
                Integer ra = minRankByCategory.get(a);
                Integer rb = minRankByCategory.get(b);
                Boolean shouldSwap = False;
                if(ra > rb) {
                    shouldSwap = True;
                } else if(ra == rb) {
                    if(a != NULL && b != NULL && a.compareTo(b) > 0) {
                        shouldSwap = True;
                    } else if(a == NULL && b != NULL) {
                        shouldSwap = True;
                    } else if(a != NULL && b == NULL) {
                        shouldSwap = True;
                    }
                }
                if(shouldSwap) {
                    String tmp = keys[i];
                    keys[i] = keys[j];
                    keys[j] = tmp;
                }
            }
        }
    }
    
    public static MAP<string,string> getMemberBenefitsSlugs() {
        MAP<string,string> mapSlugs = new MAP<string,string>();
        List<BenchPrep_Config__mdt> letBenchPrepConfig = [SELECT DeveloperName, MasterLabel, Course_Slug__c FROM BenchPrep_Config__mdt where Type__c in ('Members Benchprep','Members Program Holders Benchprep')];
        GARP_Common.debugLog('GARP_BC_Membership','getMemberBenefitsSlugs','letBenchPrepConfig',letBenchPrepConfig);
        
        for(BenchPrep_Config__mdt bpc :letBenchPrepConfig) {
            mapSlugs.put(bpc.DeveloperName, bpc.Course_Slug__c);
        }
        GARP_Common.debugLog('GARP_BC_Membership','getMemberBenefitsSlugs','mapSlugs',mapSlugs);
        
        return mapSlugs;
    }
    
    public static memberBenefitsInfo getMemberBenifitsInfo(Contact contact, MAP<String,Contract> mapContracts) {
        GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','contact',contact);
        GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','mapContracts',mapContracts);

        memberBenefitsInfo memberBenefitsInfo = new memberBenefitsInfo();
        memberBenefitsInfo.benefitCategories = new List<memberBenefitsCategory>();

        // Collect Users Status

        Contract membershipContract = mapContracts.get('Membership');
        GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','membershipContract',membershipContract);

        if(membershipContract != NULL) {
            String memberType = membershipContract.Membership_Type__c;
            String memberStatus = membershipContract.Status;
            Boolean isMemberInGoodStanding = (memberType == 'Individual' && memberStatus.IndexOf('Activated') > -1);

            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','memberType',memberType);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','memberStatus',memberStatus);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isMemberInGoodStanding',isMemberInGoodStanding);

            Contract frmContract = mapContracts.get('FRM_Program');
            Contract erpContract = mapContracts.get('ERP_Program');
            Contract scrContract = mapContracts.get('SCR_Program');
            Contract raijContract = mapContracts.get('RAIJ_Program');
            Contract raiContract = mapContracts.get('Risk_AI_Program');
            Contract frrContract = mapContracts.get('ICBRR_Program');
            Contract frr25Contract = mapContracts.get('FRR25_Program');

            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','frmContract',frmContract);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','erpContract',erpContract);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','scrContract',scrContract);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','raiContract',raiContract);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','frrContract',frrContract);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','frr25Contract',frr25Contract);

            Boolean isFRMEnrolled = False;
            Boolean isFRMCertified = False;
            Boolean isFRMHolder = False;

            Boolean isERPCertified = False;

            Boolean isSCREnrolled = False;
            Boolean isSCRHolder = False;

            Boolean isRAIEnrolled = False;
            Boolean isRAIHolder = False;

            Boolean isRAIJEnrolled = False;
            Boolean isRAIJHolder = False;

            Boolean isFRRHolder = False;

            if(frmContract != NULL) {

                if(frmContract.Status == 'Completed') {
                    isFRMCertified = True;
                    isFRMHolder = True;
                } else {
                    Boolean passPart1 = False;
                    Boolean passPart2 = False;

                    for(Candidate_Requirement__c cr :frmContract.Candidate_Requirements__r) {
                        if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part I' && cr.Status__c == 'Completed') {
                            passPart1 = TRUE;
                        }
                        if(cr.recordType.DeveloperName == 'Exam' && cr.Exam__c == 'FRM Part II' && cr.Status__c == 'Completed') {
                            passPart2 = TRUE;
                        }
                    }

                    if(passPart1 && passPart2) {
                      isFRMHolder = True;
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isFRMHolder',isFRMHolder);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isFRMCertified',isFRMCertified);

            Boolean hasFRMUnpaidOrder = False;
            if(frmContract != NULL && frmContract.Status == 'Draft' && frmContract.Opportunity__r.StageName == 'New Lead') {
                hasFRMUnpaidOrder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','hasFRMUnpaidOrder',hasFRMUnpaidOrder);

            if(erpContract != NULL && erpContract.Status == 'Completed') {
                isERPCertified = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isERPCertified',isERPCertified);

            if(scrContract != NULL && scrContract.Status.IndexOf('Activated') > -1) {
                isSCREnrolled = True;
            } else if(scrContract != NULL && scrContract.Status == 'Completed') {
                isSCRHolder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isSCREnrolled',isSCREnrolled);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isSCRHolder',isSCRHolder);

            Boolean hasSCRUnpaidOrder = False;
            if(scrContract != NULL && scrContract.Status == 'Draft' && scrContract.Opportunity__r.StageName == 'New Lead') {
                hasSCRUnpaidOrder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','hasSCRUnpaidOrder',hasSCRUnpaidOrder);

            if(raiContract != NULL && raiContract.Status.IndexOf('Activated') > -1) {
                isRAIEnrolled = True;
            } else if(raiContract != NULL && raiContract.Status == 'Completed') {
                isRAIHolder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isRAIEnrolled',isRAIEnrolled);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isRAIHolder',isRAIHolder);

            Boolean hasRIAUnpaidOrder = False;
            if(raiContract != NULL && raiContract.Status == 'Draft' && raiContract.Opportunity__r.StageName == 'New Lead') {
                hasRIAUnpaidOrder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','hasRIAUnpaidOrder',hasRIAUnpaidOrder);

            if(raijContract != NULL && raijContract.Status.IndexOf('Activated') > -1) {
                isRAIJEnrolled = True;
            } else if(raijContract != NULL && raijContract.Status == 'Completed') {
                isRAIJHolder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isRAIEnrolled',isRAIJEnrolled);
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isRAIHolder',isRAIJHolder);

            Boolean hasRIAJUnpaidOrder = False;
            if(raijContract != NULL && raijContract.Status == 'Draft' && raijContract.Opportunity__r.StageName == 'New Lead') {
                hasRIAJUnpaidOrder = True;
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','hasRIAJUnpaidOrder',hasRIAJUnpaidOrder);


            if((frrContract != NULL && frrContract.Status == 'Completed') ||
               (frr25Contract != NULL && frr25Contract.Status == 'Completed')) {
                   isFRRHolder = True;
               }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','isFRRHolder',isFRRHolder);

            // Get Membership Benifit Records
            MAP<String, Membership_Exclusive_Offers__c> mapBenefits = new MAP<String, Membership_Exclusive_Offers__c>();
            List<Membership_Exclusive_Offers__c> lstBenefits = [select Id, Name, Display_Name__c, Memb_Offer_Title__c, Memb_Offer_Logo__c, Membership_Required__c,
                                                                Memb_Offer_Description__c, Member_Description__c, Non_Member_Description__c,
                                                                Memb_Offer_External_Link__c, External_Link_Name__c, Access_Link_New_Window__c, Sort_Order__c
                                                                from Membership_Exclusive_Offers__c where Memb_Offer_Status__c = 'Active'];
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','lstBenefits',lstBenefits);

            // Display_Name__c - Category
            // Memb_Offer_Title__c - Title
            // Memb_Offer_Logo__c - Logo
            // Member_Description__c - Has Access
            // Memb_Offer_Description__c - No Access Brief Description (on page)
            // Non_Member_Description__c - No Access full description (in pop-up)
            // Memb_Offer_External_Link__c - Has Access link
            // External_Link_Name__c - Access link name

            if(lstBenefits != NULL) {
                for(Membership_Exclusive_Offers__c mb :lstBenefits) {
                    mapBenefits.put(mb.name, mb);
                }
            }
            GARP_Common.debugLog('GARP_BC_Membership','getMemberBenifitsInfo','mapBenefits',mapBenefits);

            // Get Membership Benifit Tiles
            List<memberBenefit> benefits = new List<memberBenefit>();

            Membership_Exclusive_Offers__c meo;

            if((isFRMCertified || isFRMHolder)) {
              meo = mapBenefits.get('FRMReadings');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    //memberBenefit.accessURL = '/BenchPrepSSO?id=FRMReadings';
                    benefits.add(memberBenefit);
                }
            }

            if(isSCRHolder) {
                meo = mapBenefits.get('SCRReadings');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    benefits.add(memberBenefit);
                }
            }

            if(isRAIHolder) {
                meo = mapBenefits.get('RAIReadings');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    benefits.add(memberBenefit);
                }
            }

            if(isFRRHolder) {
                meo = mapBenefits.get('FRRReadings');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    benefits.add(memberBenefit);
                }
            }

            // For now this will be ON24
            on24API.createON24EngagementHubRegistration(contact.Id);
            meo = mapBenefits.get('ThoughtLeader');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                //memberBenefit.accessURL = '/ON24EngagementHubSSO';
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('SCRMasterclass25');
            if(isSCRHolder && meo != NULL) {
                Boolean memberAccess = True;
                if(meo.Membership_Required__c) {
                    memberAccess = isMemberInGoodStanding;
                }
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, memberAccess, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                //memberBenefit.accessURL = meo.Memb_Offer_External_Link__c;
                benefits.add(memberBenefit);

            }

            meo = mapBenefits.get('PillarThree');
            if(meo != NULL && !contact.GBI_Participant__c) {
                Boolean hasPillar3LiteAccess = contact.GBI_Analytics_Participant__c;
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, hasPillar3LiteAccess, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                //memberBenefit.accessURL = '/gbiapp';
                benefits.add(memberBenefit);
            }


            // If not a member - Access = Fales, Become a Member
            // If member and not have Risk.Net - Access = False, Buy Risk.Net
            // If member and have Risk.Net - Access = True, 'https://www.risk.net/garp'
            Contract riskNetContract = mapContracts.get('Risk_Net');
            Boolean hasRiskNet = False;
            if(riskNetContract != NULL && riskNetContract.Status.IndexOf('Activated') > -1) {
                hasRiskNet = True;
            }
            meo = mapBenefits.get('RiskDotNet');
            if(meo != NULL) {
                memberBenefit mbRiskNet = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, hasRiskNet, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
        //mbRiskNet.accessURL = 'https://www.risk.net/garp';

        // Add overrides
                mbRiskNet.purchaseOverrideTitle = 'Buy Risk.Net Now';
                mbRiskNet.purchaseOverrideURL = '/Login?start=checkout/MEMR/';

                // Find open order for Risk.Net
                Set<String> productCodes = new Set<String>{'MEMR'};
                    Opportunity latestOpenOpp = GARP_BC_Orders.getLatestOppWithGivenProducts(contact.accountID, productCodes, 'New Lead', NULL);
                if(latestOpenOpp != NULL) {
                    mbRiskNet.purchaseOverridePendingOrderId = latestOpenOpp.Id;
                }

                benefits.add(mbRiskNet);
            }

            meo = mapBenefits.get('GARPChaptersEvents');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, True, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('MemberDirectory');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, True, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                //memberBenefit.accessURL = '/Login?start=member-directory';
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('RiskCareerCenter');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                //memberBenefit.accessURL = 'https://jobs.garp.org/?_gl=1*jk9waw*_gcl_au*MjE0NjI1MTQwMi4xNzI2ODI3OTAy*_ga*MTc1NDE5ODc5Ny4xNzI2ODI3OTAy*_ga_Q7Z92ZWR81*MTczMDIyMDUzNy44MS4xLjE3MzAyMjMyMDQuNTEuMC4w';
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('frsymposium2026');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('cnrsymposium2026');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                benefits.add(memberBenefit);
            }

            if(!isSCREnrolled && !isSCRHolder && !hasSCRUnpaidOrder) {
                meo = mapBenefits.get('DiscountedSCR');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    //memberBenefit.accessURL = '/Login?start=registration/scr';
                    benefits.add(memberBenefit);
                }
            }

            if(!isRAIEnrolled && !isRAIHolder && !hasRIAUnpaidOrder && !isRAIJEnrolled && !isRAIJHolder && !hasRIAJUnpaidOrder) {
              meo = mapBenefits.get('DiscountedRAI');
                if(meo != NULL) {
                    memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                    //memberBenefit.accessURL = '/Login?start=registration/rai';
                    benefits.add(memberBenefit);
                }
            }

            //memberBenefit mbCredible = new memberBenefit('Membership Discounts','Credible', 'https://www.garp.org/hubfs/Portal/Membership%20Offers/credible.jpg', isMemberInGoodStanding, 11, descTile, 'Access Now', 'https://www.garp.org', descPopUp);
        //benefits.add(mbCredible);


            // No longer offered
            // meo = mapBenefits.get('fcbt');
            // if(meo != NULL) {
            //     memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c);
            //     benefits.add(memberBenefit);
            // }

            meo = mapBenefits.get('nyif');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                benefits.add(memberBenefit);
            }

            meo = mapBenefits.get('topresume');
            if(meo != NULL) {
                memberBenefit memberBenefit = new memberBenefit(meo.Name, meo.Sort_Order__c, meo.Display_Name__c, meo.Memb_Offer_Title__c, meo.Memb_Offer_Logo__c, isMemberInGoodStanding, meo.Memb_Offer_Description__c, meo.Member_Description__c, meo.Non_Member_Description__c, meo.External_Link_Name__c, meo.Memb_Offer_External_Link__c, meo.Access_Link_New_Window__c);
                benefits.add(memberBenefit);
            }

            Set<String> alreadyAdded = new Set<String>();
            for(memberBenefit mb : benefits) {
                alreadyAdded.add(mb.key);
            }
            alreadyAdded.addAll(new Set<String>{
                'FRMReadings', 'SCRReadings', 'RAIReadings', 'FRRReadings',
                'SCRMasterclass25', 'DiscountedSCR', 'DiscountedRAI'
            });
            for(String offerName : mapBenefits.keySet()) {
                if(!alreadyAdded.contains(offerName)) {
                    Membership_Exclusive_Offers__c remaining = mapBenefits.get(offerName);
                    memberBenefit memberBenefit = new memberBenefit(remaining.Name, remaining.Sort_Order__c, remaining.Display_Name__c, remaining.Memb_Offer_Title__c, remaining.Memb_Offer_Logo__c, isMemberInGoodStanding, remaining.Memb_Offer_Description__c, remaining.Member_Description__c, remaining.Non_Member_Description__c, remaining.External_Link_Name__c, remaining.Memb_Offer_External_Link__c, remaining.Access_Link_New_Window__c);
                    benefits.add(memberBenefit);
                }
            }
            
            Map<String, List<memberBenefit>> benefitsByCategory = new Map<String, List<memberBenefit>>();
            Map<String, String> categoryLabelByGroupingKey = new Map<String, String>();
            for(memberBenefit ben : benefits) {
                String grp = membershipBenefitCategoryGroupingKey(ben.category);
                if(!benefitsByCategory.containsKey(grp)) {
                    benefitsByCategory.put(grp, new List<memberBenefit>());
                    if(String.isBlank(ben.category)) {
                        categoryLabelByGroupingKey.put(grp, '');
                    } else {
                        categoryLabelByGroupingKey.put(grp, ben.category.trim().replaceAll('\\s+', ' '));
                    }
                }
                benefitsByCategory.get(grp).add(ben);
            }

            Map<String, Integer> minRankByCategory = new Map<String, Integer>();
            for(String catKey : benefitsByCategory.keySet()) {
                Integer minR = NULL;
                for(memberBenefit mb : benefitsByCategory.get(catKey)) {
                    if(mb.rankOrder != NULL && (minR == NULL || mb.rankOrder < minR)) {
                        minR = mb.rankOrder;
                    }
                }
                minRankByCategory.put(catKey, (minR == NULL) ? MEMBERSHIP_BENEFIT_RANK_NULL_SENTINEL : minR);
            }

            for(String catKey : benefitsByCategory.keySet()) {
                sortMemberBenefitsInPlace(benefitsByCategory.get(catKey));
            }

            List<String> orderedCategoryKeys = new List<String>(benefitsByCategory.keySet());
            sortCategoryKeysInPlace(orderedCategoryKeys, minRankByCategory);

            for(String catKey : orderedCategoryKeys) {
                memberBenefitsCategory cat = new memberBenefitsCategory();
                cat.name = categoryLabelByGroupingKey.get(catKey);
                cat.benefits = benefitsByCategory.get(catKey);
                memberBenefitsInfo.benefitCategories.add(cat);
            }
        }

        return memberBenefitsInfo;
    }
    
    // Registration Helper Methods
    public static membershipInfo getMembershipInfo(String ContactId) {
        GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','ContactId',ContactId);
        
        membershipInfo membershipInfo = new membershipInfo();
        membershipInfo.isInGoodStanding = False;
        membershipInfo.isCertified = False;
        membershipInfo.isFRMCertified = False;
        membershipInfo.isERPCertified = False;
        membershipInfo.isSCRHolder = False;
        membershipInfo.isRAIHolder = False;
        membershipInfo.isRAIJHolder = False;
        membershipInfo.isMember = False;
        membershipInfo.isAutoRenewMembershipEnabled = False;
        
        List<Contact> lstCont = [select Id, FirstName, LastName, GARP_ID_New__c, AccountId, Account.RecordTypeId, Title, Business_Contact_Email__c,
                                 Email, HomePhone, Company__c, MobilePhone, Mobile_Phone_Code__c, Birthdate, ID_Expiration_Date__c, 
                                 Name_as_it_Appears_on_ID__c, ID_Type__c, ID_Number__c, OSTA_ID_Location__c, OSTA_Consent__c,
                                 Full_Name_in_Chinese__c, Gender__c, Phone, Currently_Working_Status__c, Currently_in_School_Status__c, School_Name__c, Degree_Program_Name__c,
                                 Mailing_Address_Company__c, MailingStreet, MailingCity, MailingState, MailingPostalCode, MailingCountry,
                                 Job_Function__c, Risk_Specialty__c, Corporate_Title__c, SMS_Registration_Updates__c, SMS_Promotional_Updates__c,
                                 Account.Billing_Address_Company__c, Account.BillingStreet, Account.BillingCity, Account.BillingState, Account.BillingPostalCode, Account.BillingCountry
                                 from Contact where Id = :ContactId];
        GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','lstCont',lstCont);
        
        if(!lstCont.isEmpty()) {
            Contact cont = lstCont[0];
            
            List<Account> lstAcct = [select Id, Billing_Address_Company__c, BillingStreet, BillingCity, BillingState, 
                                     BillingPostalCode, BillingCountry 
                                     from Account where Id = :cont.AccountId];
            GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','lstAcct',lstAcct);
            
            if(!lstAcct.isEmpty()) {
                Account acct = lstAcct[0];
                
                membershipInfo.contactRecord = cont;
                membershipInfo.accountRecord = acct;
                membershipInfo.GARPId = cont.GARP_ID_New__c;
                
                Id memRecId = RecordTypeHelper.GetRecordTypeId('Contract','Membership');
                Id frmRecId = RecordTypeHelper.GetRecordTypeId('Contract','FRM Program');
                Id erpRecId = RecordTypeHelper.GetRecordTypeId('Contract','ERP Program');
                Id scrRecId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
                Id raiRecId = RecordTypeHelper.GetRecordTypeId('Contract','Risk AI Program');
                Id raijRecId = RecordTypeHelper.GetRecordTypeId('Contract','RAIJ Program');
                List<Contract> lstContract = [select Id, RecordTypeId, Membership_Type__c, EndDate, Status
                                              FROM Contract where  AccountId = :acct.Id AND 
                                              ((RecordTypeId = :memRecId AND Status in ('Expired','Activated','Activated ( Auto-Renew )')) OR 
                                              ((RecordTypeId = :frmRecId OR RecordTypeId = :erpRecId OR RecordTypeId = :scrRecId OR RecordTypeId = :raiRecId OR RecordTypeId = :raijRecId) AND Status = 'Completed'))
                                              Order By StartDate];
                GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','lstContract',lstContract);
                
                if(!lstContract.isEmpty()) {
                    for(Contract c :lstContract) {
                        if(c.RecordTypeId == memRecId) {
                            membershipInfo.currentMemberType = c.Membership_Type__c;
                            membershipInfo.isMember = True;
                            membershipInfo.isInGoodStanding = False;
                            membershipInfo.isAutoRenewMembershipEnabled = False;
                            if(c.Membership_Type__c == 'Individual' && (c.Status == 'Activated' || c.Status == 'Activated ( Auto-Renew )')) {
                                Date tdy = Date.today();
                                membershipInfo.isInGoodStanding = True;
                                membershipInfo.monthsLeftInMembershipContract = tdy.monthsBetween(c.EndDate);
                                if(c.Status == 'Activated ( Auto-Renew )') {
                                    membershipInfo.isAutoRenewMembershipEnabled = True;
                                }
                            }
                        } else if(c.RecordTypeId == frmRecId) {
                            membershipInfo.isCertified = True;
                            membershipInfo.isFRMCertified = True;
                        } else if(c.RecordTypeId == erpRecId) {
                            membershipInfo.isCertified = True;
                            membershipInfo.isERPCertified = True;
                        } else if(c.RecordTypeId == scrRecId) {
                            membershipInfo.isSCRHolder = True;
                        } else if(c.RecordTypeId == raiRecId) {
                            membershipInfo.isRAIHolder = True;
                        } else if(c.RecordTypeId == raijRecId) {
                            membershipInfo.isRAIJHolder = True;
                        }
                    }
                }            
            }
        }
        GARP_Common.debugLog('GARP_BC_Membership','getMembershipInfo','membershipInfo',membershipInfo);        
        return membershipInfo;
    }
    
    public static Account createMembershipAccount(User user, Contact contact, GARP_BC_Registration.orderCustomerInfo customerInfo, GARP_Common.address billingAddress) {
        
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipAccount','user',user);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipAccount','contact',contact);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipAccount','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipAccount','billingAddress',billingAddress);
        
        Id individualRecId = RecordTypeHelper.GetRecordTypeId('Account','Individual');

        Account newAcct = new Account(
            RecordTypeID = individualRecId,
            Name = customerInfo.FirstName + ' ' + customerInfo.LastName,
            GARP_ID__c = contact.GARP_ID_New__c,
            Billing_Address_Company__c = billingAddress.Company,
            BillingCity = billingAddress.city,
            BillingCountry = billingAddress.country,
            BillingStreet = GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, null),
            BillingPostalCode = billingAddress.postalCode,
            BillingState = billingAddress.province,
            ShippingCity = billingAddress.city,
            ShippingCountry = billingAddress.country,
            ShippingStreet = GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, null),
            ShippingPostalCode = billingAddress.postalCode,
            ShippingState = billingAddress.province,
            Type = 'Customer',
            ownerid = user.Id
        );
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipAccount','newAcct',newAcct);
        return newAcct;
    }
    
    public static Contact updateNonMembershipContact(String contactId, User user, GARP_BC_Registration.orderCustomerInfo customerInfo, GARP_BC_Registration.orderPersonalInfo personalInfo, GARP_Common.address address) {
        GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','personalInfo',personalInfo);
        GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','address',address);
        
        List<Contact> lstCont = [SELECT Id, GARP_Member_ID__c, Name, FirstName, LastName, email, GARP_ID_New__c, MobilePhone, Mobile_Phone_Code__c, Title, Company__c, 
                                 Business_Contact_Email__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c,
                                 Name_as_it_Appears_on_ID__c, ID_Type__c, ID_Number__c, OSTA_ID_Location__c, OSTA_Consent__c, OSTA_Full_ID__c,
                                 Full_Name_in_Chinese__c, Gender__c, Phone, Currently_Working_Status__c, Currently_in_School_Status__c, School_Name__c, Degree_Program_Name__c,
                                 Accountid, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet
                                 FROM Contact 
                                 WHERE Id = :contactId
                                ];    
        GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','lstCont',lstCont);
        
        Contact cont;
        if(!lstCont.isEmpty()) {
            cont = lstCont[0];
            cont.Title = GARP_Common.setIfNotEmpty(customerInfo.title, cont.Title);
            cont.Company__c = GARP_Common.setIfNotEmpty(personalInfo.company, cont.Company__c);
            cont.Business_Contact_Email__c = GARP_Common.setIfNotEmpty(personalInfo.businessEmail, cont.Business_Contact_Email__c);            
            cont.Corporate_Title__c = GARP_Common.setIfNotEmpty(personalInfo.professionalLevel, cont.Corporate_Title__c);            
            cont.Job_Function__c = GARP_Common.setIfNotEmpty(personalInfo.jobFunction, cont.Job_Function__c);            
            cont.Risk_Specialty__c = GARP_Common.setIfNotEmpty(personalInfo.riskSpecialty, cont.Risk_Specialty__c);            

            GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','Update contact 1',cont);
            
            if(address.country != NULL) {
                cont.MailingCity = GARP_Common.setIfNotEmpty(address.city, cont.MailingCity);
                cont.MailingCountry = GARP_Common.setIfNotEmpty(address.country, cont.MailingCountry);
                cont.MailingPostalCode = GARP_Common.setIfNotEmpty(address.postalCode, cont.MailingPostalCode);
                cont.MailingState = GARP_Common.setIfNotEmpty(address.province, cont.MailingState);
                cont.MailingStreet = GARP_Common.formatAddressTextArea(address.street1, address.street2, address.street3);
            }
            GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','Update contact 2',cont);
            
            // Set Contact Phone Number, If not given in Personal Info
            if(personalInfo != NULL && personalInfo.phone == NULL) {
                cont.Phone = GARP_Common.setIfNotEmpty(personalInfo.phone, address.phone);
            } else if(personalInfo != NULL && personalInfo.phone == NULL && address != NULL && address.phone != NULL) {
                cont.Phone = GARP_Common.setIfNotEmpty(address.phone, cont.Phone);
            }
            
            cont.do_not_fire__c = True;
        }
        GARP_Common.debugLog('GARP_BC_Membership','updateNonMembershipContact','cont',cont);
        
        return cont;
    }
    
    public static Contact updateMembershipContact(String contactId, User user, GARP_BC_Registration.orderCustomerInfo customerInfo, GARP_BC_Registration.orderPersonalInfo personalInfo, GARP_Common.address address) {
        
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','personalInfo',personalInfo);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','address',address);
        
        List<Contact> lstCont = [SELECT Id, GARP_Member_ID__c, Name, FirstName, LastName, email, GARP_ID_New__c, MobilePhone, Mobile_Phone_Code__c, Title, Company__c, 
                                 Business_Contact_Email__c, Corporate_Title__c, Job_Function__c, Risk_Specialty__c, SMS_Registration_Updates__c, SMS_Promotional_Updates__c,
                                 Name_as_it_Appears_on_ID__c, ID_Type__c, ID_Number__c, OSTA_ID_Location__c, OSTA_Consent__c, OSTA_Full_ID__c,
                                 Full_Name_in_Chinese__c, Gender__c, Phone, Currently_Working_Status__c, Currently_in_School_Status__c, School_Name__c, Degree_Program_Name__c,
                                 Accountid, MailingCity, MailingCountry, MailingPostalCode, MailingState, MailingStreet
                                 FROM Contact 
                                 WHERE Id = :contactId
                                ];    
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','lstCont',lstCont);
        
        Contact cont;
        if(!lstCont.isEmpty()) {
            cont = lstCont[0];
            //cont.GARP_Member_ID__c
            cont.FirstName = GARP_Common.setIfNotEmpty(customerInfo.firstName, cont.FirstName);
            cont.LastName = GARP_Common.setIfNotEmpty(customerInfo.lastName, cont.LastName);
            cont.email = GARP_Common.setIfNotEmpty(customerInfo.email, cont.email);
            cont.MobilePhone = GARP_Common.setIfNotEmpty(customerInfo.mobilePhone, cont.MobilePhone);
            cont.Mobile_Phone_Code__c = GARP_Common.setIfNotEmpty(customerInfo.mobilePhoneCode, cont.Mobile_Phone_Code__c);
            
            cont.SMS_Registration_Updates__c = GARP_Common.setIfNotEmpty(customerInfo.smsRegistrationUpdates, cont.SMS_Registration_Updates__c);
            cont.SMS_Promotional_Updates__c = GARP_Common.setIfNotEmpty(customerInfo.smsPromotionalUpdates, cont.SMS_Promotional_Updates__c);
            
            cont.Title = GARP_Common.setIfNotEmpty(customerInfo.title, cont.Title);
            if(personalInfo != NULL) {
                cont.Business_Contact_Email__c = GARP_Common.setIfNotEmpty(personalInfo.businessEmail, cont.Business_Contact_Email__c);
                cont.Corporate_Title__c = GARP_Common.setIfNotEmpty(personalInfo.professionalLevel, cont.Corporate_Title__c);
                cont.Job_Function__c = GARP_Common.setIfNotEmpty(personalInfo.jobFunction, cont.Job_Function__c);
                cont.Risk_Specialty__c = GARP_Common.setIfNotEmpty(personalInfo.riskSpecialty, cont.Risk_Specialty__c);                
            }            
            GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','Update contact 1',cont);
           
            if(address.street1 != NULL) {
                cont.MailingCity = address.city;
                cont.MailingCountry = address.country;
                cont.MailingPostalCode = address.postalCode;
                cont.MailingState = address.province; 
                cont.MailingStreet = GARP_Common.formatAddressTextArea(address.street1, address.street2, address.street3);
            }
            GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','Update contact 2',cont);
            
            if(personalInfo != NULL) {
                
                if(personalInfo.idNumber != NULL) {                    
                    cont.Gender__c = GARP_Common.setIfNotEmpty(personalInfo.gender, cont.Gender__c);
                    cont.ID_Type__c = GARP_Common.setIfNotEmpty(personalInfo.idType, cont.ID_Type__c);
                    cont.OSTA_ID_Location__c = GARP_Common.setIfNotEmpty(personalInfo.idLocation, cont.OSTA_ID_Location__c);
                    cont.ID_Number__c = GARP_Common.setIfNotEmpty(personalInfo.idNumber, cont.ID_Number__c);
                    cont.Name_as_it_Appears_on_ID__c = GARP_Common.setIfNotEmpty(personalInfo.nameOnID, cont.Name_as_it_Appears_on_ID__c);
                    if(personalInfo.ostaConsent != NULL && personalInfo.ostaConsent == True) {
                        cont.OSTA_Consent__c = DateTime.now();
                        if(personalInfo.idNumber != NULL && personalInfo.idNumber.length() > 0) {
                            cont.OSTA_Full_ID__c = personalInfo.idNumber;
                            cont.ID_Number__c = personalInfo.idNumber.Right(5);
                        }
                    }
                    
                    cont.Full_Name_in_Chinese__c = GARP_Common.setIfNotEmpty(personalInfo.fullNameInChinese, cont.Full_Name_in_Chinese__c);
                    if(personalInfo.dateOfBirth != NULL)
                        cont.Birthdate = Date.ValueOf(personalInfo.dateOfBirth);
                    if(personalInfo.idExpireDate != NULL)
                        cont.ID_Expiration_Date__c = Date.ValueOf(personalInfo.idExpireDate);
                    
                    cont.Phone = GARP_Common.setIfNotEmpty(personalInfo.phone, cont.Phone);
                    cont.Currently_Working_Status__c = GARP_Common.setIfNotEmpty(personalInfo.workStatus,cont.Currently_Working_Status__c);
                    cont.Company__c = GARP_Common.setIfNotEmpty(personalInfo.company, cont.Company__c);
                    cont.School_Name__c = GARP_Common.setIfNotEmpty(personalInfo.schoolName, cont.School_Name__c);
                    cont.Currently_in_School_Status__c = GARP_Common.setIfNotEmpty(personalInfo.studentStatus, cont.Currently_in_School_Status__c);
                    cont.Degree_Program_Name__c = GARP_Common.setIfNotEmpty(personalInfo.degreeName, cont.Degree_Program_Name__c);   
                } else {
                    cont.Company__c = GARP_Common.setIfNotEmpty(personalInfo.company, cont.Company__c);
                }
                GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','Update personalInfo',cont);
            }
            
            // Set Contact Phone Number, If not given in Personal Info
            if(personalInfo != NULL && personalInfo.phone == NULL && address != NULL && address.phone != NULL) {
                cont.Phone = GARP_Common.setIfNotEmpty(address.phone, cont.Phone);
            }
        }
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipContact','cont',cont);
        
        return cont;
    }
    
    public static Account updateMembershipAccount(String accountId, User user, Contact contact, GARP_BC_Registration.ordercustomerInfo customerInfo, GARP_Common.address billingAddress) {
        
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','user',user);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','contact',contact);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','billingAddress',billingAddress);

        Account acct;
        List<Account> lstAccount = [select id, RecordTypeID, Name, GARP_ID__c, Billing_Address_Company__c, BillingCity,
                                   BillingCountry, BillingStreet, BillingPostalCode, BillingState, ShippingCity, ShippingCountry,
                                    ShippingStreet, ShippingPostalCode, ShippingState, Type, ownerid
                                    FROM Account where id = :accountId];
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','lstAccount',lstAccount);
        
        if(!lstAccount.isEmpty()) {
            acct = lstAccount[0];
            Id individualRecId = RecordTypeHelper.GetRecordTypeId('Account','Individual');
                        
            acct.RecordTypeID = individualRecId;
            acct.Name = customerInfo.FirstName + ' ' + customerInfo.LastName;
            if(acct.GARP_ID__c == NULL) {
                acct.GARP_ID__c = contact.GARP_Member_ID__c;
            }
            acct.Billing_Address_Company__c = billingAddress.company;
            
            if(billingAddress.street1 != NULL) {
                acct.BillingCity = billingAddress.city;
                acct.BillingCountry = billingAddress.country;
                acct.BillingStreet = GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, null);
                acct.BillingPostalCode = billingAddress.postalCode;
                acct.BillingState = billingAddress.province;
                acct.ShippingCity = billingAddress.city;
                acct.ShippingCountry = billingAddress.country;
                acct.ShippingStreet = GARP_Common.formatAddressTextArea(billingAddress.street1, billingAddress.street2, null);
                acct.ShippingPostalCode = billingAddress.postalCode;
                acct.ShippingState = billingAddress.province;
            }
            
            acct.Type = 'Customer';
            if(user != NULL) {
                acct.ownerid = user.Id;    
            }            
        }
        GARP_Common.debugLog('GARP_BC_Membership','updateMembershipAccount','acct',acct);
        return acct;
    }

    public static Contract createMembershipContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, String productCode, GARP_BC_Membership.membershipInfo membershipInfo) {
        
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','setRegistrationInfo',setRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','setRegistrationReturnInfo',setRegistrationReturnInfo);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','productCode',productCode);
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','membershipInfo',membershipInfo);
        
        String membershipRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Membership');
        
        Integer term = 12;
        if(productCode == 'MEMFX') {
            term = 6;
        }
        
        Contract membershipContract = new Contract(
            accountId = setRegistrationReturnInfo.accountId,
            CustomerSignedId = setRegistrationReturnInfo.contactId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            StartDate = system.today(),
            Name = 'Membership',
            ContractTerm = term,
            recordTypeID = membershipRecordTypeId,
            Member_Email__c = setRegistrationInfo.customerInfo.email,
            //Pearson_Member_First_Name__c = setRegistrationInfo.customerInfo.firstName,
            //Pearson_Member_Last_Name__c = setRegistrationInfo.customerInfo.lastName,
            //Pearson_Phone_No__c = setRegistrationInfo.customerInfo.phone,
            BillingStreet = GARP_Common.formatAddressTextArea(setRegistrationInfo.paymentInfo.billingAddress.street1, setRegistrationInfo.paymentInfo.billingAddress.street2, setRegistrationInfo.paymentInfo.billingAddress.street3),
            BillingCity = setRegistrationInfo.paymentInfo.billingAddress.city,
            BillingCountry = setRegistrationInfo.paymentInfo.billingAddress.country,
            BillingState = setRegistrationInfo.paymentInfo.billingAddress.province,
            BillingPostalCode = setRegistrationInfo.paymentInfo.billingAddress.postalCode         
        );
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','membershipContract first',membershipContract);
        
        if(productCode == 'AFREE') {
            membershipContract.Membership_Type__c = 'Affiliate';
        } else if(productCode == 'MEMI' || productCode == 'MEMF' || productCode == 'MEMFX') {
            membershipContract.Membership_Type__c = 'Individual';
            membershipContract.Membership_Renewal_Price__c = 195;
        } else if(productCode == 'MEMC') {
            membershipContract.Membership_Type__c = 'Individual';
            membershipContract.Membership_Renewal_Price__c = 50;
        }
        
        GARP_Common.debugLog('GARP_BC_Membership','createMembershipContract','membershipContract final',membershipContract);
        return membershipContract;
    }
    
    public static Contract createRiskNetContract(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, String productCode, GARP_BC_Membership.membershipInfo membershipInfo) {
        String membershipRecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'Risk.Net');
        
        Contract riskNetContract = new Contract(
            accountId = setRegistrationReturnInfo.accountId,
            CustomerSignedId = setRegistrationReturnInfo.contactId,
            Opportunity__c = setRegistrationReturnInfo.orderId,
            StartDate = system.today(),
            recordTypeID = membershipRecordTypeId,
            Member_Email__c = membershipInfo.contactRecord.Email,
            //Pearson_Member_First_Name__c = membershipInfo.contactRecord.FirstName,
            //Pearson_Member_Last_Name__c = membershipInfo.contactRecord.LastName,
            //Pearson_Phone_No__c = membershipInfo.contactRecord.HomePhone,
            BillingStreet = membershipInfo.accountRecord.BillingStreet,
            BillingCity = membershipInfo.accountRecord.BillingCity,
            BillingCountry = membershipInfo.accountRecord.BillingCountry,
            BillingState = membershipInfo.accountRecord.BillingState,
            BillingPostalCode = membershipInfo.accountRecord.BillingPostalCode             
        );
        if(membershipInfo.monthsLeftInMembershipContract == NULL) {
          riskNetContract.ContractTerm = 12;  
        } else {
          riskNetContract.ContractTerm = membershipInfo.monthsLeftInMembershipContract;
        }        
        return riskNetContract;
    }
    
    public static Boolean hasCompedMembership(String accountId) {
        GARP_Common.debugLog('GARP_BC_Membership','hasCompedMembership','accountId',accountId);
        
        Boolean ret = false;
        
        List<Opportunity> lstOpportunity = [
            SELECT Id, Name, Late_EA_Id__c, StageName, Amount, CreatedDate, Alternate_Method_of_Payment__c, Institutional_Sale__c, Program_Name__c, Program_Abbrev__c, Purchase_Date__c, LEGACY_Purchase_Date__c, Company__c, Shipping_First_Name__c, Shipping_Last_Name__c, Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_E_mail__c, Shipping_Phone_No__c, Shipping_Company_Name__c,  Display_Invoice_Number__c, Renew_Membership__c, Payment_Method_New__c, Payment_Received__c, Billing_First_Name__c, Billing_Last_Name__c, Billing_Phone__c, Billing_Email__c, Billing_Company__c, Billing_Address__c, Billing_City__c, Billing_State_text__c, Billing_Zip_Postal__c, Billing_Country__c, Switch_to_erp__c, Switch_to_frm__c, Purchase_Date_Time__c,
            (SELECT Id, ProductCode, Product2.ProductCode, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice FROM OpportunityLineItems),
            (SELECT Id, Refund_amount__c from Product_Refunds__r where Status__c = 'Completed')
            FROM Opportunity 
            WHERE AccountId = :accountId AND StageName = 'Closed'
        ];
        GARP_Common.debugLog('GARP_BC_Membership','hasCompedMembership','lstOpportunity',lstOpportunity);
        
        for(Opportunity opp :lstOpportunity) {
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                if(ol.Product2.ProductCode == 'MEMF' || ol.Product2.ProductCode == 'MEMFX' || ol.Product2.ProductCode == '944') {
                    ret = true;
                    GARP_Common.debugLog('GARP_BC_Membership','hasCompedMembership','found  comp',ol.Product2.ProductCode);
                    
                    // Check Refunds
                    if(!opp.Product_Refunds__r.IsEmpty()) {
                        Decimal totalRefunded = 0;
                        for(Product_Refunds__c pr :opp.Product_Refunds__r) {
                            if(pr.Refund_amount__c != NULL)
                                totalRefunded+=pr.Refund_amount__c;
                        }
                        GARP_Common.debugLog('GARP_BC_Membership','hasCompedMembership','totalRefunded',totalRefunded);
                        if(totalRefunded >= opp.Amount) {
                            GARP_Common.debugLog('GARP_BC_Membership','calcMemberProfileSummary','Skip refunded',opp.Amount);
                            ret = false;
                        }
                    }
                    if(ret)
                        break;
                }
            }
        }
        
        return ret;
    }

    private static String buildYearCondition(String fieldName, Integer yearVal) { 
        return 'CALENDAR_YEAR(' + fieldName + ') = ' + yearVal;
    }
 
}