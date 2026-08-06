public class GARP_BC_Orders {

    // Wappers
    public class returnOrderOperation {
        public String status;
        public String message;
        public String orderId;
    }
    
    public class setOrderReturnInfo {
        public String status;
        public String message;
        public String contactId;
        public String accountId;
        public String orderId;
        public String formDataId;
        public String orderNumber;
        public String company;
        public Decimal total;
        public Decimal tax;
        public Decimal shipping;
        public String clientSecret;
    }
    
    public class productInfo {
        public String productId;
        public String priceId;
        public String productName;
        public String productAlternateName;
        public String productCode;
        public String glCode;
        public String accountingId;
        public String stripeTaxCode;
        public String referenceId;        
        public String productFamily;
        public Integer quantity;
        public Decimal amount;
        public String invoiceName;
        public String customerDescription;
        public Boolean needsShipping;
        public Boolean isStudyMaterialProduct;
        public Boolean isCompWithRegistration;
        public Boolean isMainProduct;
        public Boolean isMembershipProduct;
        public Boolean isTaxable;
        public Boolean doNotChargeVAT;
        public String doNotChargeVATCountries;
        public Boolean isVATTax;
        public Boolean isNJSalesTax;
        public Boolean isEnrollment;
        
        // For Deferrals
        public String examRegId;
        public String examSiteId;
        public String description;
        
        public Decimal discountAmount;
        
        public productInfo() {
        }
        
        public productInfo(productInfo prodInfoIn) {
            productId = prodInfoIn.productId;
            priceId = prodInfoIn.priceId;
            productName = prodInfoIn.productName;
            productName = productName.replace(' (Complimentary)','');
            productAlternateName = prodInfoIn.productAlternateName;
            productCode = prodInfoIn.productCode;
            glCode = prodInfoIn.glCode;
            accountingId = prodInfoIn.accountingId;
            stripeTaxCode = prodInfoIn.stripeTaxCode;
            productFamily = prodInfoIn.productFamily;
            quantity = prodInfoIn.quantity;
            amount = prodInfoIn.amount;
            invoiceName = prodInfoIn.invoiceName;
            customerDescription = prodInfoIn.customerDescription;
            needsShipping = prodInfoIn.needsShipping;
            isStudyMaterialProduct = prodInfoIn.isStudyMaterialProduct;
            isCompWithRegistration = prodInfoIn.isCompWithRegistration;
            isTaxable = prodInfoIn.isTaxable;
            isMainProduct = prodInfoIn.isMainProduct;
            isMembershipProduct = prodInfoIn.isMembershipProduct;
            doNotChargeVAT = prodInfoIn.doNotChargeVAT;
            doNotChargeVATCountries = prodInfoIn.doNotChargeVATCountries;
            isVATTax = prodInfoIn.isVATTax;
            isNJSalesTax = prodInfoIn.isNJSalesTax;
            isEnrollment = prodInfoIn.isEnrollment;
        }
        
        public productInfo(PricebookEntry pbe) {
            if(pbe != NULL) {
                priceId = pbe.Id;
                productId = pbe.Product2.Id;
                accountingId = pbe.Product2.Product_ID__c;
                productFamily = pbe.Product2.Order_Summary_Product_Category__c;
                stripeTaxCode = pbe.Product2.Stripe_Tax_Code__c;
                amount = pbe.UnitPrice;
                quantity = 1;
                gLCode = pbe.Product2.GL_Code__c;
                productCode = pbe.Product2.ProductCode;
                productName = pbe.Product2.Name;
                productName = productName.replace(' (Complimentary)','');
                productAlternateName = pbe.Product2.Alternate_Name__c;
                invoiceName = pbe.Product2.Invoice_Name__c;
                customerDescription = pbe.Product2.Customer_Description__c;
                needsShipping = pbe.Product2.Is_Shippable__c;
                isMainProduct = False;
                isMembershipProduct = False;   
                isStudyMaterialProduct = False;
                isCompWithRegistration = pbe.Product2.Is_Comped_Registration__c;
                isTaxable = pbe.Product2.Taxable__c;
                doNotChargeVAT = pbe.Product2.Do_Not_Charge_VAT__c;
                doNotChargeVATCountries = pbe.Product2.Do_Not_Charge_VAT_Countries__c;
                isVATTax = pbe.Product2.Is_VAT_Tax__c;
                isNJSalesTax = False;
                isEnrollment = False;
            }
            if(productCode == 'MEMI' || productCode == 'MEMC' || productCode == 'MEMF' || productCode == 'MEMFX' || productCode == 'AFREE') {
                isMembershipProduct = True;
            }
            if(productCode == 'MEMF' || productCode == 'MEMFX' || productCode == 'AFREE') {
                isCompWithRegistration = True;
            }
            if(productCode == 'SLSTX') {
                isNJSalesTax = True;
            }
            if(productCode == 'FRM1') {
                isEnrollment = True;
            }
        }
        
        public productInfo(PricebookEntry pbe, checkoutProduct checkProd) {
            if(pbe != NULL) {
                priceId = pbe.Id;
                productId = pbe.Product2.Id;
                accountingId = pbe.Product2.Product_ID__c;
                productFamily = pbe.Product2.Order_Summary_Product_Category__c;
                stripeTaxCode = pbe.Product2.Stripe_Tax_Code__c;
                amount = pbe.UnitPrice;
                quantity = 1;
                gLCode = pbe.Product2.GL_Code__c;
                productCode = pbe.Product2.ProductCode;
                productName = pbe.Product2.Name;
                productName = productName.replace(' (Complimentary)','');
                productAlternateName = pbe.Product2.Alternate_Name__c;
                invoiceName = pbe.Product2.Invoice_Name__c;
                customerDescription = pbe.Product2.Customer_Description__c;
                needsShipping = pbe.Product2.Is_Shippable__c;
                isMainProduct = False;
                isMembershipProduct = False;   
                isStudyMaterialProduct = False;
                isCompWithRegistration = pbe.Product2.Is_Comped_Registration__c;
                isTaxable = pbe.Product2.Taxable__c;
                doNotChargeVAT = pbe.Product2.Do_Not_Charge_VAT__c;
                doNotChargeVATCountries = pbe.Product2.Do_Not_Charge_VAT_Countries__c;
                isVATTax = pbe.Product2.Is_VAT_Tax__c;
                isNJSalesTax = False;
                isEnrollment = False;
                
                // For Deferrals
                referenceId = checkProd.referenceId;
                examRegId = checkProd.examRegId;
                examSiteId = checkProd.examSiteId;
                description = checkProd.description;
            }
            if(productCode == 'MEMI' || productCode == 'MEMC' || productCode == 'MEMF' || productCode == 'MEMFX' || productCode == 'AFREE') {
                isMembershipProduct = True;
            }
            if(productCode == 'MEMF' || productCode == 'MEMFX' || productCode == 'AFREE') {
                isCompWithRegistration = True;
            }
            if(productCode == 'SLSTX') {
                isNJSalesTax = True;
            }
            if(productCode == 'FRM1') {
                isEnrollment = True;
            }
        }
    }
    
    public class orderCustomerInfo {
        public String firstName;
        public String lastName;
        public String email;
        public String leadId;
        public String contactId;
        public String accountId;        
        public String phone;
    }
    
    public class orderPaymentInfo {
        public String paymentType;  // cc,wire,check
        public String cardNumber;
        public String cardName;
        public String ccv;
        public Integer expireMonth;
        public Integer expireYear;
        public GARP_Common.address billingAddress;
        public String existingOrderId;
        public String existingRegistrationId;
    }
        
    public class setOrderInfo {
        public GARP_BC_Registration.orderCustomerInfo customerInfo;
        public GARP_BC_Registration.orderPersonalInfo personalInfo;
        public GARP_BC_Registration.addressInfo addressInfo;
        public orderPaymentInfo paymentInfo;
        public GARP_BC_Registration.membershipOptions membershipOptions;
        public GARP_BC_Events.eventOptions eventOptions;
        public List<productInfo> selectedProducts;
        public Boolean hasBilling; 
        public GARP_BC_Registration.teamRegInfo teamRegInfo;
        public affiliateProgramInfo affiliateProgramInfo;
        public String formName;
        public Boolean allowMemberPublicRegistration;
        public Boolean doNotCreateAffiliateMember;
        public checkoutCart checkoutCart;
        public Boolean isNetNew;
        public GARP_StripeClass.orderTaxInfo orderTaxInfo;
    }
    
    public class affiliateProgramInfo {
        public String affiliateVendorCode;
        public String affiliateCode;
        public String affiliateProgramId;
        public Boolean affiliateEligable;
        public Integer affiliateCredits;
        public String EPPDealId;
    }
    
    public class checkoutProduct {
        public String productCode;
        public String glCode;        
        public Decimal unitPrice;        
        public Integer quantity;     
        public String description; 
        public Boolean isStudyMaterial;
        
        // For Deferrals
        public String referenceId;
        public String examRegId;
        public String examSiteId;
    }
    
    public class checkoutCart {
        public String category;
        public Boolean hasMembership;
        public Boolean hasRiskNet;
        public List<checkoutProduct> checkoutProducts;
        public String regCode;
        
        // For Deferrals
        public String examRegistrationModificationId;
        public String examEmailParts;
        public String deferralSubType;
        public String transactionType;
    }
    
    public class orderInfo {
        public String name;
        public String orderId;
        public Decimal amount;
        public String orderNumber;
        public Date orderDate;
        public Boolean isClosed;
        public Boolean canPay;
        public Boolean canCancel;
        public Boolean isAliPay;
        public Boolean canCancelAliPay;
    }
    
    // Service Methods
    public static GARP_BC_Registration.programRegistrationInfo getCheckoutRegistrationSettings(checkoutCart checkoutCart) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'checkout';
        programRegistrationInfo.mainProductCodes = new List<String>{};
        programRegistrationInfo.mainMemberProductCode = NULL;
        programRegistrationInfo.mainNonMemberProductCode = NULL;
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{'MEMR'};    
        programRegistrationInfo.regCode = checkoutCart.regCode;
        programRegistrationInfo.formName = 'checkout';
        programRegistrationInfo.contractRecTypeName = NULL;
        programRegistrationInfo.eventId = null;
        programRegistrationInfo.eventType = null;
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;
        programRegistrationInfo.checkoutCart = checkoutCart;
        
        for(checkoutProduct prod :checkoutCart.checkoutProducts) {
            
            GARP_Common.debugLog('GARP_BC_Orders','getCheckoutRegistrationInfo','Loop checkout prod',prod);
            
            if(prod.isStudyMaterial) {
                programRegistrationInfo.studyMatProductCodes.add(prod.productCode);
                if(prod.productCode == 'SCRH') {
                    programRegistrationInfo.studyMaterialDiscountProductCode = 'SCRCANDISC';
                } else if(prod.productCode == 'RAIH') {
                    programRegistrationInfo.studyMaterialDiscountProductCode = 'RAICANDISC';
                }
            } else {
                programRegistrationInfo.addOnsProductCodes.add(prod.productCode);    
            }
            programRegistrationInfo.mainProductCodes.add(prod.productCode);
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','getCheckoutRegistrationInfo','checkoutCart',checkoutCart);
        
         GARP_Common.debugLog('GARP_BC_Orders','getCheckoutRegistrationInfo','final programRegistrationInfo',programRegistrationInfo);
        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo getCheckoutRegistrationInfo(checkoutCart checkoutCart) {        
        return GARP_BC_Registration.getRegistrationInfo(getCheckoutRegistrationSettings(checkoutCart));
    }
        
    public static returnOrderOperation removePendingPaymentOrder(String OrderId) {
        GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','OrderId',OrderId);
        
        returnOrderOperation ret = new returnOrderOperation();
        
        GARP_Common.checkAuthentication checkAuth = GARP_Common.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','checkAuth',checkAuth);
        
        if(checkAuth.IsAuthenticated) {
            GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(checkAuth.user.contactId);    
            GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','membershipInfo',membershipInfo);
            
            if(membershipInfo != NULL && membershipInfo.accountRecord != NULL) {
                List<Opportunity> lstOpp  = [select Id, Name from Opportunity where id = :OrderId and AccountId =:membershipInfo.accountRecord.Id and StageName = 'New Lead'];
                GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','lstOpp',lstOpp);
                
                if(!lstOpp.IsEmpty()) {
                    List<Contract> lstContract = [select Id, Name, Opportunity__c from contract where Opportunity__c in : lstOpp];
                    GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','lstContract',lstContract);
                    
                    if(!lstContract.IsEmpty()) {
                        for(Contract cont :lstContract) {
                            cont.Status = 'Canceled';
                        }
                        GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','update lstContract',lstContract);
                        update lstContract;
                    }
                    List<Exam_Attempt__c> lstEA = [select Id, Name, Canceled_Reason_Type__c from Exam_Attempt__c where Opportunity__c in : lstOpp];
                    GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','lstEA',lstContract);
                    
                    if(!lstEA.IsEmpty()) {
                        for(Exam_Attempt__c ea :lstEA) {
                            ea.Cancelled__c = true;
                            ea.Canceled_Reason_Type__c = 'Remove Order';
                        }
                        GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','update lstEA',lstEA);
                        update lstEA;
                    }
                    for(Opportunity opp :lstOpp) {
                        opp.StageName = 'Closed Lost';
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','update lstOpp',lstOpp);
                    update lstOpp;
                    
                    ret.status = 'Success';
                    ret.message = 'Order and related items removed';
                }
            }
            
        } else {
            ret.status = 'Failed';
            ret.message = 'User is not authenticated';
        }
        
        
        GARP_Common.debugLog('GARP_BC_Orders','removePendingPaymentOrder','Final ret',ret);
        return ret;
    }
    
    public static List<orderInfo> getOrderHistory(String accountId) {
        GARP_Common.debugLog('GARP_BC_Orders','getOrderHistory','accountId',accountId);
        
        List<orderInfo> orderHistory = new List<orderInfo>();
        
        List<Opportunity> lstOpp = [select Id, Name, StageName, CreatedDate, Amount, Display_Invoice_Number__c 
                                    from Opportunity 
                                    where StageName in ('Closed','NewLead') AND AccountId = :accountId];
        GARP_Common.debugLog('GARP_BC_Orders','getOrderHistory','lstOpp',lstOpp);
        
        if(!lstOpp.IsEmpty()) {
            for(Opportunity opp :lstOpp) {
                orderInfo orderInfo = new orderInfo();
                orderInfo.name = opp.Name;
                orderInfo.orderId = opp.Id;
                orderInfo.orderNumber = opp.Display_Invoice_Number__c;
                orderInfo.orderDate = Date.newInstance( opp.CreatedDate.year(),  opp.CreatedDate.month(),  opp.CreatedDate.day());
                orderInfo.isClosed = (opp.StageName == 'Closed');
                orderInfo.amount = opp.Amount;
                
                GARP_Common.debugLog('GARP_BC_Orders','getOrderHistory','Add orderInfo',orderInfo);
                orderHistory.add(orderInfo);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','getOrderHistory','orderHistory',orderHistory);
        return orderHistory;
    }
    
    // Helpers
    
    public static setOrderReturnInfo setOrder(setOrderInfo setOrderInfo) {
        setOrderReturnInfo regInfo = new setOrderReturnInfo();
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','setOrderInfo',setOrderInfo);
        
        // Setup Allow Public Member Registration       
        setOrderInfo.membershipOptions = GARP_BC_Registration.setAllMembershipOptions(setOrderInfo.membershipOptions);
        
        // Validations
        if(setOrderInfo.customerInfo == NULL || setOrderInfo.customerInfo.email == NULL ||
           setOrderInfo.paymentInfo == NULL || setOrderInfo.paymentInfo.billingAddress == NULL || setOrderInfo.selectedProducts == NULL) {
               regInfo.message = 'Required Information Missing';
               regInfo.status = 'Failed';
               return regInfo;
        }
                
        GARP_BC_Registration.checkExistingContact checkRet = GARP_BC_Registration.checkExistingContact(setOrderInfo.customerInfo.email);
        Contact existingContact = checkRet.contact;
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','checkRet',checkRet);
        
        GARP_BC_Registration.checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        Boolean isAuthenticated = checkAuth.isAuthenticated;
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','checkAuth',checkAuth);
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','isAuthenticated',isAuthenticated);
        
        if(!isAuthenticated && existingContact != NULL && checkRet.isMember && !setOrderInfo.allowMemberPublicRegistration) {
            regInfo.message = 'Contact exists, must login';
            regInfo.status = 'Failed';
            return regInfo;
        }
        
        if(isAuthenticated && existingContact == NULL) {
            regInfo.message = 'Contact not found';
            regInfo.status = 'Failed';
            return regInfo;
        }
        
        // Contact & Account
        String contactId;
        String accountId;
        String opportunityId;
        String invoiceNumber;
        
        Contact memberContact;
        
        // AG 2/13/2026 -- New Logic if no Lead will be used
        if(isAuthenticated || existingContact != NULL) {
            
            contactId = existingContact.Id;
            accountId = existingContact.AccountId;
            memberContact = existingContact;
            
             // If Order wanted
             if(!setOrderInfo.doNotCreateAffiliateMember) {
                
                // Create new Membership Account if Needed
                if(existingContact.RecordType.Name == 'Business Relationship' || existingContact.Account.RecordType.Name != 'Individual') {
                    GARP_Common.debugLog('GARP_BC_Orders','setOrder','Create new Membership Account',existingContact);
                    
                    Id userId = [SELECT Id, Name, Record_Id__c FROM UpdateIds__c WHERE Name = 'User'].Record_Id__c;
                    GARP_Common.debugLog('GARP_BC_Orders','setOrder','userId',userId);
                    
                    //Create Individual Account
                    User u = [select Id from User where id = :userId];
                    
                    Account account = GARP_BC_Membership.createMembershipAccount(u, existingContact, setOrderInfo.customerInfo, setOrderInfo.paymentInfo.billingAddress);
                    GARP_Common.debugLog('GARP_BC_Orders','setOrder','insert account',account);
                    insert account;
                    
                    accountId = account.Id;
                    
                    
                    // Convert Business Relationship Contact to Member
                    if(existingContact.RecordType.Name == 'Business Relationship') {
                        
                        GARP_Common.debugLog('GARP_BC_Orders','setOrder','Convert Business Relationship Contact to Member',existingContact.RecordType.Name);
                        
                        existingContact.LastName = setOrderInfo.customerInfo.lastName;
                        existingContact.FirstName = setOrderInfo.customerInfo.firstName;
                        existingContact.OwnerId = userId;
                        existingContact.AccountId = accountId;
                        existingContact.Original_Business_Account_ID__c = existingContact.AccountId;
                        existingContact.Original_Business_Contact_Owner_ID__c = existingContact.OwnerId;
                        existingContact.RecordTypeId = RecordTypeHelper.GetRecordTypeIdFromSchema('Contact', 'Member');
                        existingContact.do_not_fire__c = true;
                        GARP_Common.debugLog('GARP_BC_Orders','setOrder','UPDATE existingContact',existingContact);
                        
                        UPDATE existingContact;
                    }
                }
                 
                 // Create Order
                 // Since we no longer convert a Lead need to create one
                 Opportunity opp = new Opportunity();
                 opp.Name = 'GARP Order';
                 opp.Accountid = accountId;
                 opp.StageName = 'New Lead';
                 opp.Billing_First_Name__c = existingContact.FirstName;
                 opp.Billing_Last_Name__c = existingContact.LastName;
                 opp.Billing_Email__c = existingContact.Email;
                 opp.CloseDate = system.today();                 
                 
                 GARP_Common.debugLog('GARP_BC_Orders','setOrder','create opp',opp);
                 insert opp;
                 
                 opportunityId = opp.id;
            }
            
        } else if(!isAuthenticated) {
            
            Form_Data__c formData;
            
            // Find Form Session
            List<Form_Data__c> lstFormData = [SELECT Id, CreatedDate, Status__c, Email__c, First_Name__c, Last_Name__c, Company__c, 
                                              UTM_Campaign__c, UTM_Content__c, UTM_Medium__c, UTM_Source__c, UTM_Term__c, Track_CTA__c
                                              FROM Form_Data__c 
                                              WHERE id = :setOrderInfo.customerInfo.sessionId];
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','lstFormData',lstFormData);
            
            if(lstFormData.IsEmpty()) {
                regInfo.message = 'Form Session not found';
                regInfo.status = 'Failed';
                return regInfo;
            } else {
                formData = lstFormData[0];
            }
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','formData',formData);
            
            // Create Account
            Account memberAccount = new Account(
                Name = formData.First_Name__c + ' ' + formData.Last_Name__c,
                Member_First_Name__c = formData.First_Name__c,
                Member_Last_Name__c = formData.Last_Name__c,
                Member_Email__c = formData.Email__c,
                RecordTypeId = RecordTypeHelper.GetRecordTypeId('Account','Individual'),
                Type = 'Customer'
            );
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','insert memberAccount',memberAccount);
            insert memberAccount;
            
            memberContact = new Contact(
            	FirstName = formData.First_Name__c,
                LastName = formData.Last_Name__c,
                AccountId = memberAccount.Id,
                Email = formData.Email__c,
                RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact','Member'),
                do_not_fire__c = True
            );
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','insert memberContact',memberContact);
            insert memberContact;
            
            contactId = memberContact.Id;
            accountId = memberAccount.Id; 
            
            if(!setOrderInfo.doNotCreateAffiliateMember) {
                Opportunity opp = new Opportunity();
                opp.Name = 'GARP Order';
                opp.Accountid = accountId;
                opp.StageName = 'New Lead';
                opp.Billing_First_Name__c = memberContact.FirstName;
                opp.Billing_Last_Name__c = memberContact.LastName;
                opp.Billing_Email__c = memberContact.Email;
                opp.CloseDate = system.today();                 
                
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','create opp',opp);
                insert opp;
                
                opportunityId = opp.id;
            }
            
            // Find Lead
            /*
            List<Lead> leads = [
                SELECT Id, Email, FirstName, LastName, Order_Type__c, IsConverted, IsDeleted, ConvertedAccountId, ConvertedContactId, ConvertedOpportunityId, DO_NOT_FIRE__c
                FROM Lead 
                WHERE Id = :setOrderInfo.customerInfo.LeadId AND IsDeleted = FALSE
            ];
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','fetch leads',leads);
            
            // Set Lead to not fire community user, for rollback
            Lead registrationRequestLead;
            if(!leads.isEmpty()) {
                registrationRequestLead = leads[0];  
                registrationRequestLead.DO_NOT_FIRE__c = True;
                registrationRequestLead.Order_Type__c = getOrderType(setOrderInfo.selectedProducts);
            } else {
                regInfo.message = 'Lead not found';
                regInfo.status = 'Failed';
                return regInfo;
            }
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','registrationRequestLead',registrationRequestLead);
            
            // Update Lead
            registrationRequestLead.Email = setOrderInfo.customerInfo.email; 
            registrationRequestLead.Unique_Email__c = setOrderInfo.customerInfo.email; 
            registrationRequestLead.LastName = setOrderInfo.customerInfo.lastName;
            registrationRequestLead.FirstName = setOrderInfo.customerInfo.firstName;
            registrationRequestLead.Company = setOrderInfo.customerInfo.firstName + ', ' + setOrderInfo.customerInfo.lastName;
            
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','UPDATE registrationRequestLead',registrationRequestLead);
            UPDATE registrationRequestLead;
            
            // Convert Lead
            Database.LeadConvert convertLead = new Database.LeadConvert(); 
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','convertLead',convertLead);
            
            convertLead.setLeadId(registrationRequestLead.Id);
            
            // Set Opp Creation or Not
            if(setOrderInfo.doNotCreateAffiliateMember) {
                convertLead.setDoNotCreateOpportunity(true);
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','No Opp convertLead',convertLead);
            }
            
            LeadStatus leadStatus = [
                SELECT Id, MasterLabel 
                FROM LeadStatus 
                WHERE IsConverted = TRUE LIMIT 1
            ];
            
            convertLead.setConvertedStatus(leadStatus.MasterLabel);
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','Final convertLead',convertLead);
            
            Database.LeadConvertResult leadConvertResult = Database.convertLead(convertLead);
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','leadConvertResult',leadConvertResult);
            
            Lead convertedLead;
            if (leadConvertResult.isSuccess()) {
                convertedLead = [SELECT ConvertedaccountId, ConvertedcontactId, ConvertedDate, ConvertedOpportunityId, Marketing_email_Creation__c, email_Career_Center_Job_Board__c, email_Chapter_Meetings__c, email_CPE_News__c, email_Daily_News__c, email_GARP_Updates__c, email_Information_Exchange__c, email_Member_Update__c, email_The_Week_in_Risk__c FROM Lead where id = : setOrderInfo.customerInfo.LeadId];
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','convertLead',convertLead);
            } else {
                regInfo.message = 'Lead Conversion Failed';
                regInfo.status = 'Failed';
                return regInfo;
            }            
            
            // Setup Account and Order Info
            contactId = convertedLead.ConvertedcontactId;
            accountId = convertedLead.ConvertedaccountId;
            opportunityId = convertedLead.ConvertedOpportunityId;
			*/
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','memberContact',memberContact);
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','opportunityId',opportunityId);
        
        
        // Is there membership?
        Boolean hasMembershipProduct=false;
        Boolean hasShippingProduct=false;
        for(productInfo prod :setOrderInfo.selectedProducts) {
            if(prod.isMembershipProduct) {
                hasMembershipProduct = true;
            }
            if(prod.needsShipping) {
                hasShippingProduct=true;
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','hasMembershipProduct',hasMembershipProduct);
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','paymentType',setOrderInfo.paymentInfo.paymentType);
        
        // If no Membership Product is passed
        Boolean addedAffiliate=false;
        if(!checkRet.isMember && !hasMembershipProduct && !setOrderInfo.doNotCreateAffiliateMember) {
            
            List<String> productCodes = new List<String>();
            productCodes.addAll(new List<String>{'AFREE'});
            List<String> priceIds = new List<String>();        
            MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds); 
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','mapProdByCodes',mapProdByCodes);
            
            // If paying via Credit Card/Online, OR free product and no Membership Selected or Exists then Add Affiliate
            if(!setOrderInfo.hasBilling || setOrderInfo.paymentInfo.paymentType == 'Stripe' || setOrderInfo.paymentInfo.paymentType == 'Credit Card' || setOrderInfo.paymentInfo.paymentType == 'alipay' || setOrderInfo.paymentInfo.paymentType == 'wechat_pay') {
                PricebookEntry fndAff = getPricebookEntryByCode(mapProdByCodes, 'AFREE', '4999');
                productInfo productAff = new productInfo(fndAff);
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','productAff',productAff);
                
                setOrderInfo.selectedProducts.add(productAff);                
                addedAffiliate=true;
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','selectedProducts',setOrderInfo.selectedProducts);
        
        //GARP_Common.debugLog('GARP_BC_Orders','setOrder','migrateLeadFormDataToContact',contactId);
        //Form_Data__c fd = GARP_BC_Registration.migrateLeadFormDataToContact(setOrderInfo.customerInfo.LeadId, contactId, opportunityId, setOrderInfo.formName);
        
        Form_Data__c fd =  GARP_BC_Registration.migrateFormDataToContact(setOrderInfo.customerInfo.sessionId, memberContact.Email, contactId, opportunityId, 'Abandoned');
        
        if(fd != NULL) {
            regInfo.formDataId = fd.Id;    
        }
        
        if(!setOrderInfo.doNotCreateAffiliateMember) {
            Opportunity updateOpp = updateOpportunity(opportunityId, checkAuth.user, accountId, setOrderInfo, (addedAffiliate || hasMembershipProduct), hasShippingProduct);
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','updateOpp',updateOpp);
            if(updateOpp != NULL) {
                update updateOpp;
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','set ret values 1',regInfo);
            }
            
            List<OpportunityLineItem> opportunityLineItems = createOppLineItems(opportunityId, setOrderInfo.selectedProducts, setOrderInfo.paymentInfo, setOrderInfo.affiliateProgramInfo, setOrderInfo.orderTaxInfo);
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','insert opportunityLineItems',opportunityLineItems);
            
            insert opportunityLineItems;
            
            // Compute Return Values
            List<Opportunity> lstOpp = [select Id, Display_Invoice_Number__c, Company__c, Amount,
                                        (SELECT Id, ProductCode, Product2.Is_VAT_Tax__c, TotalPrice FROM OpportunityLineItems)
                                        from Opportunity where id = :opportunityId];
            if(!lstOpp.IsEmpty()) {
                Opportunity opp = lstOpp[0];
                regInfo.orderNumber = opp.Display_Invoice_Number__c;
                regInfo.company = opp.Company__c;
                regInfo.total = opp.Amount;                
                
                if(!opp.OpportunityLineItems.IsEmpty()) {
                    regInfo.shipping = 0;
                    regInfo.tax = 0;
                    for(OpportunityLineItem li :opp.OpportunityLineItems) {
                        GARP_Common.debugLog('GARP_BC_Orders','setOrder','Loop lineItems',li);
                        GARP_Common.debugLog('GARP_BC_Orders','setOrder','Loop lineItems ProductCode',li.Product2.Is_VAT_Tax__c);
                        
                        if(li.ProductCode.IndexOf('SHIP') > -1) {
                            regInfo.shipping += li.TotalPrice;
                        }
                        if(li.ProductCode == 'SLSTX' || li.Product2.Is_VAT_Tax__c) {
                            regInfo.tax += li.TotalPrice;
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','setOrder','set ret values 2',regInfo);
                }
            }
        }
        
        // Update Contact Record Type to Business if needed
        if(setOrderInfo.doNotCreateAffiliateMember && existingContact == NULL) {
            List<Contact> lstCont = [select Id, RecordTypeId from Contact where Id = :contactId];
            if(!lstCont.isEmpty()) {
                lstCont[0].RecordTypeId = RecordTypeHelper.GetRecordTypeIdFromSchema('Contact', 'Business_Relationship');
                GARP_Common.debugLog('GARP_BC_Orders','setOrder','Update Contact Record Type',lstCont);
                update lstCont;
            }
        }
        
        // Add Contact Role
        if(opportunityId != NULL && contactId != NULL) {
            OpportunityContactRole contactRole = new OpportunityContactRole(OpportunityId=opportunityId, 
                                                                            ContactId=contactId, 
                                                                            Role='Decision Maker');
            GARP_Common.debugLog('GARP_BC_Orders','setOrder','insert contactRole',contactRole);
            insert contactRole;            
        } 
        
        regInfo.contactId = contactId;
        regInfo.accountId = accountId;
        regInfo.orderId = opportunityId;
        regInfo.message = 'Set Order Completed';
        regInfo.status = 'Success';
        
        
        GARP_Common.debugLog('GARP_BC_Orders','setOrder','final regInfo',regInfo);
        
        return regInfo;
    }

    public static Opportunity createAffiliateMemberOrder(GARP_BC_Registration.orderCustomerInfo customerInfo, User user, orderPaymentInfo paymentInfo) {
                
        List<productInfo> selectedProducts = new List<productInfo>();
        
        List<String> productCodes = new List<String>();
        productCodes.addAll(new List<String>{'AFREE'});
        List<String> priceIds = new List<String>();
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds); 
        GARP_Common.debugLog('GARP_BC_Orders','createAffiliateMemberOrder','mapProdByCodes',mapProdByCodes);
        
        PricebookEntry fndAff = getPricebookEntryByCode(mapProdByCodes, 'AFREE', '4999');
        productInfo productAff = new productInfo(fndAff);
        productAff.isMainProduct = True;
        selectedProducts.add(productAff);
        GARP_Common.debugLog('GARP_BC_Orders','createAffiliateMemberOrder','selectedProducts',selectedProducts);
        
        Opportunity opp = createOpportunity(user, customerInfo.accountId, customerInfo, paymentInfo, null, selectedProducts, null);
        GARP_Common.debugLog('GARP_BC_Orders','createAffiliateMemberOrder','opp',opp);
        insert opp;        
        
        List<OpportunityLineItem> opportunityLineItems = createOppLineItems(opp.Id, selectedProducts, paymentInfo, NULL, NULL);
        GARP_Common.debugLog('GARP_BC_Orders','createAffiliateMemberOrder','opportunityLineItems',opportunityLineItems);
        insert opportunityLineItems;
        
        opp.StageName = 'Closed';
        update opp;

        GARP_Common.debugLog('GARP_BC_Orders','createAffiliateMemberOrder','opp',opp);
        return opp;
    }
    
    public static setOrderReturnInfo payOrder(GARP_BC_Registration.orderCustomerInfo customerInfo, orderPaymentInfo paymentInfo, GARP_BC_Registration.teamRegInfo teamRegInfo, GARP_BC_Registration.programRegistrationInfo programRegistrationInfo, Opportunity purchaseOpp) {
        setOrderReturnInfo regInfo = new setOrderReturnInfo();
        
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','paymentInfo',paymentInfo);
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','purchaseOpp',purchaseOpp);
                
        // Validations
        if(customerInfo == NULL || customerInfo.accountId == NULL ||
           paymentInfo == NULL || purchaseOpp == NULL) { 
               regInfo.message = 'Required Information Missing';
               regInfo.status = 'Failed';
               return regInfo;
        }
                
        GARP_BC_Registration.checkExistingContact checkRet = GARP_BC_Registration.checkExistingContact(customerInfo.email);
        Contact contact = checkRet.contact;
        
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','checkRet',checkRet);
        
        GARP_BC_Registration.checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        Boolean isAuthenticated = checkAuth.isAuthenticated;
        
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','checkAuth',checkAuth);
        
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','paymentType',paymentInfo.paymentType);
        
        // Not Full Team Reg AND Not $0
        if((teamRegInfo == NULL || teamRegInfo.isComplimentary == NULL || (teamRegInfo.isComplimentary != NULL && teamRegInfo.isComplimentary == False)) && purchaseOpp.Amount > 0 && paymentInfo.paymentType != NULL) {
            if(paymentInfo.paymentType != 'Credit Card') {
                // Activate Free Memberhip Contract, if not already
                if(!checkRet.isMember) {
                    Opportunity opp = createAffiliateMemberOrder(customerInfo, checkAuth.user, paymentInfo);
                    if(opp != NULL || opp.StageName != 'Closed'){
                        regInfo.message = 'Completed Success';
                        regInfo.status = 'Success';
                    } else {
                        regInfo.message = 'Completed Failed';
                        regInfo.status = 'Failed';            
                    }   
                } else {
                    regInfo.message = 'Completed Success';
                    regInfo.status = 'Success';    
                }
            } else {
                
                Payment payment = new Payment(
                    paymentInfo.CardNumber, 
                    paymentInfo.CCV, 
                    String.valueOf(paymentInfo.ExpireMonth), 
                    String.valueOf(paymentInfo.ExpireYear)                 
                );
                GARP_Common.debugLog('GARP_BC_Orders','payOrder','payment',payment);
                
                if(!Test.isRunningTest()) {
                    ChargentOrders.TChargentOperations.TChargentResult chargentResult = payment.charge(paymentInfo.existingOrderId);
                    //ChargentSFA.TChargentOperations.TChargentResult chargentResult = payment.charge(paymentInfo.existingOrderId);
                    GARP_Common.debugLog('GARP_BC_Orders','payOrder','chargentResult',chargentResult);
                    
                    if(!chargentResult.message.contains('Approved')){
                        regInfo.message = 'Charge Failed';
                        regInfo.status = 'Failed';
                        
                        // Rollback
                        GARP_Common.debugLog('GARP_BC_Orders','payOrder','manualRollback',chargentResult.message);           
                        manualRollback(customerInfo, checkRet.contact, purchaseOpp, isAuthenticated, 'Chargent Failed Payment');
                        
                    } else {
                        regInfo.message = 'Charge Success';
                        regInfo.status = 'Success';            
                    }
                } else {
                    regInfo.message = 'Charge Success';
                    regInfo.status = 'Success';            
                }
            }
            
        } else {
            
            GARP_Common.debugLog('GARP_BC_Orders','payOrder','Is Team Reg',teamRegInfo);
            
            // Confirm Full Team Reg OR $0
            if((teamRegInfo != NULL && teamRegInfo.isComplimentary != NULL && teamRegInfo.isComplimentary && teamRegInfo.teamRegCode != NULL && !String.IsEmpty(teamRegInfo.teamRegCode)) || purchaseOpp.Amount == 0) {
                if((purchaseOpp.B2B_Deal_Item__c != NULL && purchaseOpp.B2B_Deal_Item__r.Access_Code__c == teamRegInfo.teamRegCode) || purchaseOpp.Amount == 0) {
                    ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: paymentInfo.existingOrderId];
                    ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();        
                    trans.Opportunity__c = paymentInfo.existingOrderId;
                    trans.ChargentOrders__Order__c = order.id;
                    trans.ChargentOrders__Amount__c = 0.00;
                    trans.ChargentOrders__Response_Message__c = 'Approved';
                    trans.ChargentOrders__Response_Status__c = 'Approved';
                    trans.ChargentOrders__Type__c = 'Charge';
                    trans.ChargentOrders__Gateway_Date__c =system.now();
                    
                    // For Full Team Registration
                    if(teamRegInfo != NULL && teamRegInfo.isComplimentary != NULL && teamRegInfo.isComplimentary && !teamRegInfo.isScholarship) {
                        trans.ChargentOrders__Payment_Method__c = 'Bulk Order';
                        //if(purchaseOpp != NULL) {
                        //    isTeamRegBulkOrder = True;
                        //}   
                    } else {
                        // For other $0 things
                        trans.ChargentOrders__Payment_Method__c = 'Free';
                    }
                      
                    GARP_Common.debugLog('GARP_BC_Orders','payOrder','Insert Free Trans',trans);           
                    insert trans;       
                    
                    regInfo.message = 'Completed Success';
                    regInfo.status = 'Success';    
                } else {
                    regInfo.message = 'This order is not related to a valid Team Registration';
                    regInfo.status = 'Failed';
                }
            } else {
                regInfo.message = 'This order is not related to a valid Team Registration';
                regInfo.status = 'Failed';
            }
        }
        
        // Finish Account Setup
        GARP_Common.debugLog('GARP_BC_Orders','payOrder','Finish Setup',regInfo.status);  
        if(regInfo.status == 'Success') {
            
            contact.DO_NOT_FIRE__c = false;
            UPDATE contact;
            
            Form_Data__c returnFormData = GARP_BC_Registration.closeFormData(NULL, purchaseOpp); 
            GARP_Common.debugLog('GARP_BC_Orders','payOrder','returnFormData',returnFormData);
                        
            // Move to updateOpportunity() or OpportunityHandler trigger
            //if(purchaseOpp != NULL) { 
                //if(isTeamRegBulkOrder) {
                //    purchaseOpp.ia_crm__Intacct_Transaction__c = 'Salesforce - Bulk Order';  
                //}
                
                //String CTA;
                //if(returnFormData != NULL && returnFormData.Track_CTA__c != NULL) {
                //    CTA = returnFormData.Track_CTA__c;
                //}
                
                //purchaseOpp.Email_Purchase_Complete__c = True; -- moved to OpportunityHandler
                //purchaseOpp.Order_Summary_CTA__c = CTA;
                
                //GARP_Common.debugLog('GARP_BC_Orders','closeFormData','update purchaseOpp',purchaseOpp);
                //update purchaseOpp;
            //}
        }
        
        return regInfo;
    }
    
    public static MAP<String,PricebookEntry> getPriceBooksEntries(List<String> productCodes, List<String> priceIds) {
        MAP<String,PricebookEntry> mapProdByCodes = new MAP<String,PricebookEntry>();
               
        if(productCodes == NULL) {
            productCodes = new List<String>();
        }
        if(priceIds == NULL) {
            priceIds = new List<String>();
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','productCodes',productCodes);
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','priceIds',priceIds);

        for(String prod :productCodes) {
            GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','get prod',prod);
        }
        
        List<PricebookEntry> lstPricebookEntry = [
            SELECT ID, Pricebook2Id, Pricebook2.Name, Product2.Id, Product2.Family, Product2.Order_Summary_Product_Category__c,
            Product2.Product_ID__c, Product2.FRM_Exam__c, Product2.ERP_Exam__c, Product2.Name, Product2.ProductCode, Product2.Stripe_Tax_Code__c,
            Product2.Content__c, Product2.Content__r.Content_Name__c, Product2.Content__r.Description__c, 
            Product2.Content__r.Image__c,  Product2.Content__r.Story__c,  
            Product2.Content__r.Start_Date__c, Product2.Content__r.Lead_Gen_URL__c, 
            Product2.Content__r.Third_Party_URL__c,
            Product2.Inventory__c,
            Product2.Pre_Order_Shipping_Date__c,Product2.Pre_Order_Date__c,
            Product2.Invoice_Name__c, Product2.Customer_Description__c,
            Product2.GL_Code__c, Product2.IsActive, Product2.Is_Shippable__c, Product2.Taxable__c, 
            Product2.Electronic_Delivery__c, Product2.Do_Not_Charge_VAT__c, Product2.Do_Not_Charge_VAT_Countries__c, Product2.Is_VAT_Tax__c,
            Product2.Is_Comped_Registration__c,
            Product2.Weight__c, Pricebook2.IsActive, Product2.Tax_Rate__c, Product2.Alternate_Name__c, UnitPrice, UseStandardPrice 
            FROM PriceBookEntry 
            WHERE Product2.IsActive = TRUE AND Product2.ProductCode != NULL AND
            (Product2.ProductCode in :productCodes OR Id in :priceIds)
        ];
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','lstPricebookEntry',lstPricebookEntry);
        
        for(PricebookEntry pbe :lstPricebookEntry) {
            if(Test.isRunningTest() || pbe.Pricebook2.Name == 'GARP 2015/2016') {
                mapProdByCodes.put(pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c, pbe);
                
                GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','Add mapProdByCodes',pbe.Product2.ProductCode+':'+pbe.Product2.GL_Code__c);
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','getPriceBooksEntries','mapProdByCodes',mapProdByCodes);
        
        return mapProdByCodes;
    }

    /**
     * Fetch a PricebookEntry from the map by product code and GL code.
     * Checks for nulls, logs the key being fetched, and returns the entry (or null).
     */
    public static PricebookEntry getPricebookEntryByCode(MAP<String,PricebookEntry> mapProdByCodes, String productCode, String glCode) {
        if (mapProdByCodes == null) {
            return null;
        }
        if (String.isBlank(productCode) || String.isBlank(glCode)) {
            GARP_Common.debugLog('GARP_BC_Orders', 'getPricebookEntryByCode', 'product code', '(blank productCode or glCode)');
            return null;
        }
        String key = productCode + ':' + glCode;
        GARP_Common.debugLog('GARP_BC_Orders', 'getPricebookEntryByCode', 'product code', key);
        
        PricebookEntry pbe = mapProdByCodes.get(key);
        
        if(pbe == NULL) {
            GARP_Common.debugLog('GARP_BC_Orders', 'getPricebookEntryByCode', 'price book entry not found:', key);
        }
        
        return pbe;
    }

    public static PricebookEntry getPricebookEntryByCode(MAP<String,PricebookEntry> mapProd, String productCode) {
        if (mapProd == null) {
            return null;
        }
        if (String.isBlank(productCode)) {
            GARP_Common.debugLog('GARP_BC_Orders', 'getPricebookEntryByCode', 'product code', '(blank productCode)');
            return null;
        }
        
        PricebookEntry pbe = mapProd.get(productCode);
        if(pbe == NULL) {
            GARP_Common.debugLog('GARP_BC_Orders', 'getPricebookEntryByCode', 'price book entry not found:', productCode);
        }
        
        return pbe;
    }
    
    public static List <OpportunityLineItem> createOppLineItems(Id oppId, List<productInfo> selectedProducts, orderPaymentInfo paymentInfo, affiliateProgramInfo affiliateProgramInfo, GARP_StripeClass.orderTaxInfo orderTaxInfo) {
        
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','oppId',oppId);
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','selectedProducts',selectedProducts);
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','paymentInfo',paymentInfo);
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','affiliateProgramInfo',affiliateProgramInfo);
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','orderTaxInfo',orderTaxInfo);
        
        List <OpportunityLineItem> retLineItems = new List <OpportunityLineItem>();
        
        List<String> missingPrices = new List<String>();
        for(productInfo pi :selectedProducts) {
            if(pi.priceId == NULL) {
                missingPrices.add(pi.productCode);
            }   
        }
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','missingPrices',missingPrices);
        
        MAP<String,PricebookEntry> mapProdByCodes;
        if(!missingPrices.isEmpty()) {
            mapProdByCodes = getPriceBooksEntries(missingPrices, NULL);        
            GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','mapProdByCodes',mapProdByCodes);
        }
        
        MAP<String, GARP_StripeClass.retGetCheckoutTaxLineItemsData> mapTaxLineItems = new MAP<String,GARP_StripeClass.retGetCheckoutTaxLineItemsData>();
        if(orderTaxInfo != NULL && orderTaxInfo.lineItems != NULL && !orderTaxInfo.lineItems.IsEmpty()) {
            for(GARP_StripeClass.retGetCheckoutTaxLineItemsData tli :orderTaxInfo.lineItems) {
                   mapTaxLineItems.put(tli.reference, tli);
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','mapTaxLineItems',mapTaxLineItems);
        
        for(productInfo pi :selectedProducts) {

            GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','pi',pi);      

            String priceId = pi.priceId;
            if(priceId == NULL) {
                PricebookEntry fndPrice = getPricebookEntryByCode(mapProdByCodes, pi.productCode, pi.gLCode);
                if(fndPrice != NULL) {
                    priceId = fndPrice.Id;
                }
            }
            GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','priceId',priceId);
            
            if(priceId != NULL) {
                
                OpportunityLineItem oppLineItem = new OpportunityLineItem(
                    OpportunityId = oppId,
                    PricebookEntryId = priceId,
                    Quantity = 1,
                    UnitPrice = pi.amount,
                    Product_ID__c = pi.accountingId,
                    Product_Family__c = pi.productFamily,
                    Reference_Id__c = pi.referenceId,
                    Exam_Site__c = pi.examSiteId,
                    Exam_Registration__c = pi.examRegId,
                    Description = pi.description
                );
                
                // Add EPP Vendor Code to Line Items
                if(affiliateProgramInfo != NULL && affiliateProgramInfo.affiliateVendorCode != NULL && oppLineItem.Reference_Id__c == NULL) {
                    oppLineItem.Reference_Id__c = affiliateProgramInfo.affiliateVendorCode;
                }
                
                // Add Tax Info
                GARP_StripeClass.retGetCheckoutTaxLineItemsData fndTaxInfo = mapTaxLineItems.get(pi.productName);
                GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','fndTaxInfo',fndTaxInfo); 
                
                if(fndTaxInfo != NULL && fndTaxInfo.amount_tax > 0) {
                    oppLineItem.Stripe_Tax_Code__c = fndTaxInfo.tax_code;
                    oppLineItem.Stripe_Tax_Amount__c = ((Decimal)fndTaxInfo.amount_tax / 100).setScale(2);
                }
                
                GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','oppLineItem',oppLineItem);             
                retLineItems.add(oppLineItem);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','createOppLineItems','retLineItems',retLineItems);     
        return retLineItems;
    }
    
    public static String getOrderType(List<productInfo> selectedProducts) {
        
        GARP_Common.debugLog('GARP_BC_Orders','getOrderType','selectedProducts',selectedProducts);
        
        String orderType = 'GARP Order';
        String mainProductName;
        if(selectedProducts != NULL) {
            for(productInfo pi :selectedProducts) {                    
                GARP_Common.debugLog('GARP_BC_Orders','getOrderType','Loop sel prod',pi);
                
                if(pi.isMainProduct) {
                    if(pi.invoiceName != NULL) {
                        mainProductName = pi.invoiceName;
                        break;
                    }
                }
            }
            if(mainProductName != NULL) {
                orderType = mainProductName + ' Order';
            }      
        }
        return orderType;
    }
    
    public static Opportunity updateOpportunity(String oppId, User user, String accountId, setOrderInfo setOrderInfo, Boolean hasMembership, Boolean hasShippingProduct) {
        
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','oppId',oppId);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','user',user);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','customerInfo',setOrderInfo.customerInfo);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','paymentInfo',setOrderInfo.paymentInfo);     
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','checkoutCart',setOrderInfo.checkoutCart);     
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','hasMembership',hasMembership);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','hasShippingProduct',hasShippingProduct);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','selectedProducts',setOrderInfo.selectedProducts);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','teamRegInfo',setOrderInfo.teamRegInfo);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','affiliateProgramInfo',setOrderInfo.affiliateProgramInfo);
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','orderTaxInfo',setOrderInfo.orderTaxInfo);
        
        List<Opportunity> lstOpp = [select id, Accountid, Account.GARP_ID__c, StageName, CloseDate, recordTypeID, Billing_email__c, 
                                    Team_Registration__c, B2B_Deal_Item__c, Affiliate_Program__c, Affiliate_Program_Code__c,
                                    Billing_First_Name__c, Billing_Last_Name__c, Billing_Phone__c, 
                                    Billing_Company__c, Billing_Address__c, Billing_City__c,
                                    Billing_State_text__c, Billing_Zip_Postal__c, Billing_Country__c, ownerid,
                                    Exam_Registration_Modification__c, Exam_Emails__c, Deferral_SubType__c, ia_crm__Intacct_Transaction__c,
                                    Stripe_Tax_Taxable_Amount__c, Stripe_Tax_Country__c, Stripe_Tax_Percent__c
                                    FROM Opportunity where Id = :oppId];

        
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','lstOpp',lstOpp);
        
        Opportunity opp;
        if(!lstOpp.isEmpty()) {
            opp = lstOpp[0];            
            String oppName = 'GARP Order';
            
            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','oppName start',oppName);
            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','selectedProducts',setOrderInfo.selectedProducts);
            if(setOrderInfo.selectedProducts != NULL) {
                oppName = getOrderType(setOrderInfo.selectedProducts);
            }
            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','oppName',oppName);
            
            String paytype;
            if(setOrderInfo.paymentInfo.paymentType == 'Credit Card') {
                paytype = 'cc';
            } else if(setOrderInfo.paymentInfo.paymentType == 'Wire Transfer') {
                paytype = 'wire';
                opp.Calc_Taxes__c = True;
            } else if(setOrderInfo.paymentInfo.paymentType == 'Check') {
                paytype = 'check';
                opp.Calc_Taxes__c = True;
            } else if(setOrderInfo.paymentInfo.paymentType == 'ACH') {
                paytype = 'ach';
                opp.Calc_Taxes__c = True;
            } else if(setOrderInfo.paymentInfo.paymentType == 'alipay') {
                paytype = 'alipay';
            } else if(setOrderInfo.paymentInfo.paymentType == 'wechat_pay') {
                paytype = 'wechatpay';
            }
            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','paytype',paytype);
            
            Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated');
            opp.Name = oppName;
            opp.Accountid = accountId;
            opp.StageName = 'New Lead';
            opp.Alternate_Method_of_Payment__c = paytype;
            //opp.Payment_Method_new__c = paymentInfo.paymentType;
            opp.CloseDate = system.today();
            opp.recordTypeID = recordTypeID;
            opp.Billing_email__c = setOrderInfo.customerInfo.email;
            opp.Billing_First_Name__c = setOrderInfo.customerInfo.firstName;
            opp.Billing_Last_Name__c = setOrderInfo.customerInfo.lastName;
            opp.Billing_Phone__c = setOrderInfo.customerInfo.phone;
            opp.Original_Garp_ID__c = opp.Account.GARP_ID__c;

            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','Update Opp1',opp);
            
            if(setOrderInfo.checkoutCart != NULL) {
                opp.Exam_Registration_Modification__c = setOrderInfo.checkoutCart.examRegistrationModificationId;
                opp.Exam_Emails__c = setOrderInfo.checkoutCart.examEmailParts;
                opp.Deferral_SubType__c = setOrderInfo.checkoutCart.deferralSubType;
                opp.ia_crm__Intacct_Transaction__c = setOrderInfo.checkoutCart.transactionType;
            }
            
            if(setOrderInfo.paymentInfo.billingAddress != NULL) {
                opp.Billing_Company__c = setOrderInfo.paymentInfo.billingAddress.Company;
                opp.Billing_Address__c = GARP_Common.formatAddressTextArea(setOrderInfo.paymentInfo.billingAddress.street1, setOrderInfo.paymentInfo.billingAddress.street2, null);
                opp.Billing_City__c = setOrderInfo.paymentInfo.billingAddress.city;
                opp.Billing_State_Text__c = setOrderInfo.paymentInfo.billingAddress.province;
                opp.Billing_Zip_Postal__c  = setOrderInfo.paymentInfo.billingAddress.postalCode;
                opp.Billing_Country__c = setOrderInfo.paymentInfo.billingAddress.country;
            }
            
            if(setOrderInfo.addressInfo != NULL && setOrderInfo.addressInfo.billingAndShippingSame) {
                opp.Shipping_E_mail__c = opp.Billing_email__c;
                opp.Shipping_First_Name__c = opp.Billing_First_Name__c;
                opp.Shipping_Last_Name__c = opp.Billing_Last_Name__c ;
                opp.Shipping_Phone_No__c = opp.Billing_Phone__c;
                opp.Shipping_Company_Name__c = opp.Billing_Company__c;
                opp.Shipping_Street__c = opp.Billing_Address__c;
                opp.Shipping_City__c = opp.Billing_City__c;
                opp.Shipping_State__c = opp.Billing_State_Text__c;
                opp.Shipping_Postal_Code__c  = opp.Billing_Zip_Postal__c;
                opp.Shipping_Country__c = opp.Billing_Country__c;
            } else if(setOrderInfo.addressInfo != NULL && !setOrderInfo.addressInfo.billingAndShippingSame) {
                opp.Shipping_E_mail__c = opp.Billing_email__c;
                opp.Shipping_First_Name__c = opp.Billing_First_Name__c;
                opp.Shipping_Last_Name__c = opp.Billing_Last_Name__c ;
                opp.Shipping_Phone_No__c = opp.Billing_Phone__c;                
                opp.Shipping_Company_Name__c = setOrderInfo.addressInfo.shippingAddress.Company;
                opp.Shipping_Street__c = GARP_Common.formatAddressTextArea(setOrderInfo.addressInfo.shippingAddress.street1, setOrderInfo.addressInfo.shippingAddress.street2, null);
                opp.Shipping_City__c = setOrderInfo.addressInfo.shippingAddress.city;
                opp.Shipping_State__c = setOrderInfo.addressInfo.shippingAddress.province;
                opp.Shipping_Postal_Code__c  = setOrderInfo.addressInfo.shippingAddress.postalCode;
                opp.Shipping_Country__c = setOrderInfo.addressInfo.shippingAddress.country;               
            }
            
            // Apprantly this is required to Activate all Program Contracts
            if(!setOrderInfo.doNotCreateAffiliateMember) {
                opp.Eligible_for_Membership_Extension__c = true;
            }
            
            GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','membershipOptions',setOrderInfo.membershipOptions);
            if(hasMembership && setOrderInfo.membershipOptions != NULL && setOrderInfo.membershipOptions.autoRenew != NULL && setOrderInfo.membershipOptions.autoRenew) {
                opp.Auto_Renew__c = True;
            }        
            
            if(setOrderInfo.teamRegInfo != NULL && setOrderInfo.teamRegInfo.teamRegId != NULL) {
                opp.B2B_Deal_Item__c = setOrderInfo.teamRegInfo.teamRegId;
                if(setOrderInfo.teamRegInfo.EPPDealId != NULL) {
                    opp.EPP_Deal__c = setOrderInfo.teamRegInfo.EPPDealId;
                }
            }
            if(setOrderInfo.teamRegInfo != NULL && setOrderInfo.teamRegInfo.teamRegParentId != NULL) {
                opp.Team_Registration__c = setOrderInfo.teamRegInfo.teamRegParentId;
            }

            // Is Bulk Order
            if(setOrderInfo.teamRegInfo != NULL && setOrderInfo.teamRegInfo.isComplimentary != NULL && setOrderInfo.teamRegInfo.isComplimentary && !setOrderInfo.teamRegInfo.isScholarship) {
                opp.ia_crm__Intacct_Transaction__c = 'Salesforce - Bulk Order'; 
            }
            
            // CTA Tracking
            Form_Data__c returnFormData = GARP_BC_Registration.getFormData(NULL, opp);
            String CTA;
            if(returnFormData != NULL && returnFormData.Track_CTA__c != NULL) {
                CTA = returnFormData.Track_CTA__c;
            }
            opp.Order_Summary_CTA__c = CTA;

            if(setOrderInfo.affiliateProgramInfo != NULL) {
                
                opp.Affiliate_Program_Code__c = setOrderInfo.affiliateProgramInfo.affiliateCode;
                
                if(setOrderInfo.affiliateProgramInfo.affiliateEligable) {
                    opp.Affiliate_Program__c = setOrderInfo.affiliateProgramInfo.affiliateProgramId;    
                    opp.Affiliate_Program_Credits__c = setOrderInfo.affiliateProgramInfo.affiliateCredits;
                }
                
                if(setOrderInfo.affiliateProgramInfo.EPPDealId != NULL) {
                    opp.EPP_Deal__c = setOrderInfo.affiliateProgramInfo.EPPDealId;
                }
            }
            
            opp.Has_Books__c = hasShippingProduct;
            
            if(setOrderInfo.isNetNew) {
                opp.Is_Exam_Net_New__c = True;
            }
            
            if(setOrderInfo.orderTaxInfo != NULL) {
                opp.Stripe_Tax_Taxable_Amount__c = ((Decimal)setOrderInfo.orderTaxInfo.taxableAmount / 100).setScale(2);
                opp.Stripe_Tax_Country__c = setOrderInfo.orderTaxInfo.country;
                opp.Stripe_Tax_Percent__c = setOrderInfo.orderTaxInfo.percentageDecimal;
                opp.Stripe_Tax_Type__c = setOrderInfo.orderTaxInfo.taxType;
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','updateOpportunity','updated opp',opp);
        return opp;
    }
    
    public static Opportunity createOpportunity(User user, String accountId, GARP_BC_Registration.orderCustomerInfo customerInfo, orderPaymentInfo paymentInfo, GARP_BC_Registration.membershipOptions membershipOptions, List<productInfo> productInfo, GARP_BC_Registration.teamRegInfo teamRegInfo) {
        Id recordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity', 'Automated');
        
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','customerInfo',customerInfo);
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','paymentInfo',paymentInfo);
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','membershipOptions',membershipOptions);
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','productInfo',productInfo);
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','productInfo',teamRegInfo);
        
        String mainProductName;
        String oppName = 'GARP Order';
                
        if(productInfo != NULL) {
            oppName = getOrderType(productInfo);
        }
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','oppName',oppName);
                
        Opportunity newOpp = new Opportunity(
            Name = oppName,
            Accountid = accountId,
            StageName = 'New Lead',
            Alternate_Method_of_Payment__c = paymentInfo.paymentType,
            CloseDate = system.today(),
            recordTypeID = recordTypeID,
            Billing_email__c = customerInfo.email,
            Billing_First_Name__c = customerInfo.firstName,
            Billing_Last_Name__c = customerInfo.lastName,
            Billing_Phone__c = customerInfo.phone,
            Billing_Company__c = paymentInfo.billingAddress.company,
            Billing_Address__c = GARP_Common.formatAddressTextArea(paymentInfo.billingAddress.street1, paymentInfo.billingAddress.street2, paymentInfo.billingAddress.street3),
            Billing_City__c = paymentInfo.billingAddress.city,
            Billing_Country__c = paymentInfo.billingAddress.country,
            Billing_State_text__c = paymentInfo.billingAddress.province,
            Billing_Zip_Postal__c = paymentInfo.billingAddress.postalCode
        );
        
        if(user != NULL) {
            newOpp.ownerid = user.Id;    
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','membershipOptions',membershipOptions);
        if(membershipOptions != NULL && membershipOptions.autoRenew != NULL && membershipOptions.autoRenew) {
            newOpp.Auto_Renew__c = True;
        }        
        newOpp.Eligible_for_Membership_Extension__c = true;
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','newOpp1',newOpp);
        
        if(teamRegInfo != NULL && teamRegInfo.teamRegId != NULL) {
            newOpp.B2B_Deal_Item__c = teamRegInfo.teamRegId;
        }
        if(teamRegInfo != NULL && teamRegInfo.teamRegParentId != NULL) {
            newOpp.Team_Registration__c = teamRegInfo.teamRegParentId;
        }
        GARP_Common.debugLog('GARP_BC_Orders','createOpportunity','Final newOpp',newOpp);
        
        return newOpp;
    }
   
    public static Boolean removeOpenOrders(String accountId) {
        GARP_Common.debugLog('GARP_BC_Orders','removeOpenOrdersString','accountId',accountId);
        
        List<Opportunity> lstOpp = [select Id, Name, StageName, Alternate_Method_of_Payment__c, CreatedDate, 
                                    (SELECT Id, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c from Transactions__r ORDER BY CreatedDate DESC)
                                    from Opportunity where AccountId = :accountId and StageName = 'New Lead'];
        GARP_Common.debugLog('GARP_BC_Orders','removeOpenOrdersString','lstOpp',lstOpp);
        
        if(!lstOpp.isEmpty()) {
            
            for(Opportunity opp :lstOpp) {
                
                GARP_Common.debugLog('GARP_BC_Orders','removeOpenOrdersString','Loop opp',opp);
                
                if(opp.Alternate_Method_of_Payment__c == 'alipay') {
                    Long hourDiff; // = (DateTime.now().getTime() - opportunity.CreatedDate.getTime()) /(1000*60*60);
                    Boolean isAnHourOld = FALSE;
                    Boolean hasFailedTransaction = FALSE;
                    
                    if(hourDiff >= 1) {
                        isAnHourOld = TRUE;
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','isAnHourOld',isAnHourOld);
                    
                    if(!opp.Transactions__r.IsEmpty() && opp.Transactions__r[0].ChargentOrders__Payment_Method__c == 'Alipay' && opp.Transactions__r[0].ChargentOrders__Response_Status__c == 'Failure') {
                        hasFailedTransaction = TRUE;
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','hasFailedTransaction',hasFailedTransaction);
                    
                    GARP_Common.debugLog('GARP_BC_Orders','removeOpenOrdersString','isAnHourOld',isAnHourOld);
                    GARP_Common.debugLog('GARP_BC_Orders','removeOpenOrdersString','hasFailedTransaction',hasFailedTransaction);
                    
                    if(hasFailedTransaction || isAnHourOld) {
                        opp.StageName = 'Closed Lost';
                    } else {
                        // Alipay Pending Order
                        return True;
                    }
                } else {
                    opp.StageName = 'Closed Lost';
                }
            }
            
            update lstOpp;
        }
        
        return False;
    }
    
    
    public static void removeOrder(String orderId) {
        List<Opportunity> lstOpp = [select Id, Name, StageName from Opportunity where id = :orderId and StageName = 'New Lead'];
        if(!lstOpp.isEmpty()) {
            lstOpp[0].StageName = 'Closed Lost';
            update lstOpp;
        }
    }
    
    public static Boolean manualRollback(GARP_BC_Registration.orderCustomerInfo customerInfo, Contact purchaseContact, Opportunity purchaseOpp, Boolean isAuthenticated, String rollbackReason){
        
        try{
        
            Boolean ret = FALSE;
            Opportunity opportunity;
            if(rollbackReason == NULL) {
                rollbackReason = 'manualRollback';
            }
            
            Boolean isExistAccount = False;
            List<Contract> programs;
            List<Opportunity> lstOpp = [select Id, AccountId, Amount, StageName, Alternate_Method_of_Payment__c, Rollback_Reason__c, CreatedDate, (SELECT Id, ChargentOrders__Response_Status__c, ChargentOrders__Payment_Method__c from Transactions__r ORDER BY CreatedDate DESC) from Opportunity where Id = :purchaseOpp.Id];
            GARP_Common.debugLog('GARP_BC_Registration','manualRollback','lstOpp',lstOpp);
            if(!lstOpp.IsEmpty()) {
                opportunity = lstOpp[0];
                
                programs = [select Id, Status from Contract where AccountId = :opportunity.AccountId];
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','programs',programs);  
                
                for(Contract prog :programs) {
                    if(prog.Status != 'Draft') {
                        isExistAccount = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','isExistAccount',isExistAccount);
                
                // Check if AliPay has sent transactions before rolling back
                if(opportunity.Alternate_Method_of_Payment__c == 'alipay') {
                    
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','Is AliPay',opportunity.Alternate_Method_of_Payment__c);
                    
                    Long hourDiff = (DateTime.now().getTime() - opportunity.CreatedDate.getTime()) /(1000*60*60);
                    Boolean isAnHourOld = FALSE;
                    Boolean hasFailedTransaction = FALSE;
                    
                    if(hourDiff >= 1) {
                        isAnHourOld = TRUE;
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','isAnHourOld',isAnHourOld);
                    
                    if(!opportunity.Transactions__r.IsEmpty() && opportunity.Transactions__r[0].ChargentOrders__Payment_Method__c == 'Alipay' && opportunity.Transactions__r[0].ChargentOrders__Response_Status__c == 'Failure') {
                        hasFailedTransaction = TRUE;
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','hasFailedTransaction',hasFailedTransaction);
                    
                    if(hasFailedTransaction) {
                        // OK to continue
                        rollbackReason = rollbackReason + ':AliPay failed transaction found';
                    }
                    
                    if(!hasFailedTransaction && isAnHourOld) {
                        // OK to continue
                        rollbackReason = rollbackReason + ':AliPay over an hour';
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','rollbackReason',opportunity.Rollback_Reason__c);

                    if(!hasFailedTransaction && !isAnHourOld) {
                        //opportunity.Rollback_Reason__c = rollbackReason + ':AliPay Rollback Failure, not an hour old';
                        //UPDATE opportunity;
                        GARP_Common.debugLog('GARP_BC_Orders','manualRollback','cancel rollback','');
                        return FALSE;
                    }
                }
            } else {
                // Opp not found
                return FALSE;
            }
            
            List<Lead> lead;
            if(customerInfo.leadId != NULL) {
                lead = [select Id from Lead where Id = :customerInfo.leadId];    
            }
            
            Contact contact = purchaseContact;
            List<Account> account = [select Id from Account where Id = :customerInfo.accountId];
                        
            System.debug('opportunity:' + opportunity);
            System.debug('account:' + account);
            System.debug('contact:' + contact);
            System.debug('lead:' + lead);
            
            //List<Exam_Attempt__c> examRegistrations = opportunity.Exam_Registrations__r;
            
            List<Exam_Attempt__c> examRegistrations = [select Id, Cancelled__c, Cancel_Reason__c from Exam_Attempt__c where Opportunity__c = :purchaseOpp.Id];
            GARP_Common.debugLog('GARP_BC_Orders','manualRollback','examRegistrations',examRegistrations);
            
            List<Event_Registration__c> eventRegistrations = [SELECT Id FROM Event_Registration__c WHERE Opportunity__c = :purchaseOpp.Id];
            GARP_Common.debugLog('GARP_BC_Orders','manualRollback','eventRegistrations',eventRegistrations);
    
            if(!isExistAccount){
                opportunity.AccountId = Label.Failed_Exam_Registrations_Account_ID;
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','set AccountId',opportunity.AccountId);
            }
    
            opportunity.StageName = 'Closed Lost';
            opportunity.Rollback_Reason__c = rollbackReason;
            UPDATE opportunity;
            
            if(!isExistAccount && contact.Original_Business_Account_ID__c != null && contact.Original_Business_Contact_Owner_ID__c != null){      
                    
                    
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','public business contact',contact.Original_Business_Account_ID__c);
                
                      
                /* *
                * Revert AccountId to original parent Account.
                * Revert OwnerId to original Owner.
                * Revert Record Type to 'Business Relationship'.
                * */
                contact.AccountId = contact.Original_Business_Account_ID__c;
                contact.OwnerId = contact.Original_Business_Contact_Owner_ID__c;
                contact.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contact', 'Business Relationship');
    
                /* *
                * Clear Original_Business_Account_ID__c as it no longer needs to be referenced.
                * Clear Original_Business_Contact_Owner_ID__c as it no longer needs to be referenced.
                * */      
                contact.Original_Business_Account_ID__c = null;
                contact.Original_Business_Contact_Owner_ID__c = null;
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','update contact',contact);
                UPDATE contact;
    
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete programs',programs);
                if(programs != null && !programs.isEmpty()) DELETE programs;
                
                // find any programs
                //List<Contract> lstContract = [select Id, RecordType.Name from Contract where CustomerSignedId = :contact.Id OR AccountId = :account.Id];
                //System.debug('lstContract:' + lstContract);
                //if(lstContract != NULL && lstContract.size() > 0) {
                //    DELETE lstContract;
                //}
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete examRegistrations',examRegistrations);
                if(examRegistrations != null && !examRegistrations.isEmpty()) DELETE examRegistrations;
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete eventRegistrations',eventRegistrations);
                if(eventRegistrations != null && !eventRegistrations.isEmpty()) DELETE eventRegistrations;
                
                // Deleting Lead as we cannot update an existing converted Lead unless we modify the permissions.
                 
                // AG 2/16/2026 - Now Allow Existing Contacts and Leads
                //GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete lead',lead);
                //GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete account',account);
                
                //if(lead != NULL)
                //    DELETE lead; 
                //DELETE account;
                
            }else if(!isExistAccount){  
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','public contact',contact);
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete programs',programs);
                if(programs != null && !programs.isEmpty()) DELETE programs;
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete examRegistrations',examRegistrations);
                if(examRegistrations != null && !examRegistrations.isEmpty()) DELETE examRegistrations;
                
                GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete eventRegistrations',eventRegistrations);
                if(eventRegistrations != null && !eventRegistrations.isEmpty()) DELETE eventRegistrations;
                
                // AG 2/16/2026 - Now Allow Existing Contacts and Leads
                // Deleting Lead as we cannot update an existing converted Lead unless we modify the permissions.
                //GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete lead',lead);
                //GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete contact',contact);
                //GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete account',account);
                
                //if(lead != NULL)
                //    DELETE lead;
                
                //DELETE contact;
                //DELETE account;
                
            }else if(isExistAccount){
    
                if(programs != null && !programs.isEmpty()) {
                    List<Contract> delContracts = new List<Contract>();
                    for(Contract cont :programs) {
                        if(cont.Status == 'Draft') {
                            delContracts.add(cont);
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','delete delContracts',delContracts);
                    
                    if(!delContracts.IsEmpty()) {
                        DELETE delContracts;
                    }
                }
                
                
                if(examRegistrations != null && !examRegistrations.isEmpty()) {
                    for(Exam_Attempt__c er :examRegistrations) {
                        er.Cancelled__c = TRUE;
                        er.Cancel_Reason__c = 'manualRollback';
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','manualRollback','update examRegistrations',examRegistrations);
                    UPDATE examRegistrations;
                }
    
                // AG 2/16/2026 - Now Allow Existing Contacts and Leads
                // Deleting Lead as we cannot update an existing converted Lead unless we modify the permissions.
                //if(lead != NULL)
                //    DELETE lead;
    
            }
            
            return TRUE;
        
        }catch(Exception e){
            System.debug('Error--'+e.getMessage());
            return FALSE;
        }
    }
    
    // V2 Portal
    
    // Get Latest Opp
    public static Opportunity getLatestOppWithGivenProducts(String accountID, Set<String> productCodes, String stageName, List<Opportunity> lstOpp) {
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','accountID',accountID);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','productCodes',productCodes);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','stageName',stageName);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','lstOpp',lstOpp);
        
        if(lstOpp == NULL) {
            lstOpp = [select Id, StageName, Display_Invoice_Number__c, Amount, Stripe_Outbound_Type__c,
                      (SELECT Id, ProductCode, Product2.GL_Code__c, TotalPrice FROM OpportunityLineItems)
                      from Opportunity where AccountId = :accountID AND StageName = :stageName Order By CreatedDate DESC];
        }
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','lstOpp',lstOpp);
        
        if(!lstOpp.IsEmpty()) {
            for(Opportunity opp :lstOpp) {
                if(opp.StageName == stageName && !opp.OpportunityLineItems.IsEmpty()) {
                    for(OpportunityLineItem li :opp.OpportunityLineItems) {
                        if(productCodes.contains(li.ProductCode)) {
                            
                            if(opp.StageName == 'New Lead' && opp.Stripe_Outbound_Type__c == 'Create') {
                                continue;
                            }
                            
                            GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProducts','found opp',opp);
                            return opp;
                        }
                    }
                }
            }
        }
        
        return NULL;
    }
 
    public static List<Opportunity> getAllOpps(String accountID) {
        return [select Id, Name, StageName, Display_Invoice_Number__c, Amount, CreatedDate, Stripe_Outbound_Type__c,
                Billing_Country__c, Alternate_Method_of_Payment__c,
                Exam_Registration_Modification__c, B2B_Deal_Item__r.Discounted_Price__c,
                Exam_Registration_Modification__r.RPT_Exam_Program__c,
                Exam_Registration_Modification__r.Deferral_SubType__c,
                Exam_Registration_Modification__r.Part_I_Exam_Registration__c,
                Exam_Registration_Modification__r.Part_I_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c,
                Exam_Registration_Modification__r.Part_II_Exam_Registration__c,
                Exam_Registration_Modification__r.Part_II_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c,
                (SELECT Id, ProductCode, Product2.GL_Code__c, TotalPrice FROM OpportunityLineItems),
                (SELECT Id, ChargentOrders__Type__c, ChargentOrders__Response_Status__c from Transactions__r),
                (SELECT Id from Email_Notifications__r)
                FROM Opportunity where AccountId = :accountID AND
                StageName in ('Closed','New Lead') AND Late_EA_Id__c = NULL AND OSTA_Check__c = FALSE
                Order By CreatedDate DESC];
    }
    
    public static Opportunity getLatestOppWithExamModification(String accountID, List<Opportunity> lstOpp, String programType) {
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithExamModification','accountID',accountID);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithExamModification','lstOpp',lstOpp);

        if(lstOpp == NULL) {
            lstOpp = getAllOpps(accountID);
        }
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithExamModification','lstOpp',lstOpp);
        
        if(!lstOpp.IsEmpty()) {
            for(Opportunity opp :lstOpp) {
                if(opp.Exam_Registration_Modification__c != NULL && opp.Exam_Registration_Modification__r.RPT_Exam_Program__c == programType && opp.StageName == 'New Lead' && (
                    (opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__c != NULL && 
                     (opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c == True || opp.Exam_Registration_Modification__r.Deferral_SubType__c == 'Deferral LDR')) ||
                    (opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__c != NULL &&
                     (opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c == True || opp.Exam_Registration_Modification__r.Deferral_SubType__c == 'Deferral LDR'))
                )
                  ) {
                        return opp;
                    }
            }
        }
        return NULL;        
    }
     
    public static Opportunity getLatestOppWithGivenProductAndGLCodes(String accountID, Set<String> productCodes, String stageName, List<Opportunity> lstOpp) {
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','accountID',accountID);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','productCodes',productCodes);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','stageName',stageName);
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','lstOpp',lstOpp);
        
        if(lstOpp == NULL) {
            lstOpp = [select Id, StageName, Display_Invoice_Number__c, Amount,
                      (SELECT Id, ProductCode, Product2.GL_Code__c, TotalPrice FROM OpportunityLineItems)
                      from Opportunity where AccountId = :accountID AND StageName = :stageName Order By CreatedDate DESC];
        }
        GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','lstOpp',lstOpp);
        
        if(!lstOpp.IsEmpty()) {
            for(Opportunity opp :lstOpp) {
                if(opp.StageName == stageName && !opp.OpportunityLineItems.IsEmpty()) {
                    for(OpportunityLineItem li :opp.OpportunityLineItems) {
                        if(productCodes.contains(li.ProductCode + ':' + li.Product2.GL_Code__c)) {
                            GARP_Common.debugLog('GARP_BC_Orders','getLatestOppWithGivenProductAndGLCodes','found opp',opp);
                            return opp;
                        }
                    }
                }
            }
        }
        
        return NULL;
    }
    
    public static MAP<String, Opportunity> getAllLatestOppWithGivenProductAndGLCodes(String accountID, Set<String> productCodes, String stageName) {
        GARP_Common.debugLog('GARP_BC_Orders','getAllLatestOppWithGivenProductAndGLCodes','accountID',accountID);
        GARP_Common.debugLog('GARP_BC_Orders','getAllLatestOppWithGivenProductAndGLCodes','productCodes',productCodes);
        GARP_Common.debugLog('GARP_BC_Orders','getAllLatestOppWithGivenProductAndGLCodes','stageName',stageName);
        
        MAP<String, Opportunity> mapReturnOpps = new MAP<String, Opportunity>();
        List<Opportunity> lstOpp = [select Id, StageName, Display_Invoice_Number__c, Amount,
                                    (SELECT Id, ProductCode, Product2.GL_Code__c, TotalPrice FROM OpportunityLineItems)
                                    from Opportunity where AccountId = :accountID AND StageName = :stageName Order By CreatedDate DESC];
        GARP_Common.debugLog('GARP_BC_Orders','getAllLatestOppWithGivenProductAndGLCodes','lstOpp',lstOpp);
        
        Set<String> usedCodes = new Set<String>();
        
        if(!lstOpp.IsEmpty()) {
            for(Opportunity opp :lstOpp) {
                if(!opp.OpportunityLineItems.IsEmpty()) {
                    for(OpportunityLineItem li :opp.OpportunityLineItems) {
                        String key = li.ProductCode + ':' + li.Product2.GL_Code__c;
                        if(productCodes.contains(key) && !usedCodes.contains(key)) {
                            mapReturnOpps.put(key, opp);
                            usedCodes.add(key);
                            break;
                        }
                    }
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','getAllLatestOppWithGivenProductAndGLCodes','mapReturnOpps',mapReturnOpps);
        
        return mapReturnOpps;
    }
    
    public static GARP_Common.returnInfo cancelUnpaidOrder(String accountId, String orderId) {
        GARP_Common.debugLog('GARP_BC_Orders','cancelUnpaidOrder','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Orders','cancelUnpaidOrder','orderId',orderId);
        
        GARP_Common.returnInfo returnInfo = new GARP_Common.returnInfo();
        
        List<Opportunity> lstOpp = [SELECT Id, Name, StageName, Exam_Registration_Modification__c from Opportunity where id = :orderId AND AccountId = :accountId AND StageName = 'New Lead'];
        GARP_Common.debugLog('GARP_BC_Orders','cancelUnpaidOrder','lstOpp',lstOpp);
        
        if(!lstOpp.IsEmpty()) {
            Opportunity opp = lstOpp[0];
            
            opp.StageName = 'Closed Lost';
            update opp;
            
            List<Exam_Attempt__c> lstExamAttempts = [select Id, Cancelled__c, Canceled_Reason_Type__c from Exam_Attempt__c where Opportunity__c = :orderId AND Cancelled__c = False];
            if(!lstExamAttempts.IsEmpty()) {
                lstExamAttempts[0].Cancelled__c = True;
                lstExamAttempts[0].Canceled_Reason_Type__c = 'Remove Order';
                update lstExamAttempts;
            }
            
            List<Event_Registration__c> lstEventRegistrations = [select Id, Status__c from Event_Registration__c where Opportunity__c = :orderId AND Status__c != 'Cancelled'];
            if(!lstEventRegistrations.IsEmpty()) {
                lstEventRegistrations[0].Status__c = 'Cancelled';
                update lstEventRegistrations;
            }
            
            if(opp.Exam_Registration_Modification__c != NULL) {
                List<Exam_Registration_Modification__c> lstExamMods = [select Id, Status__c from Exam_Registration_Modification__c where id = :opp.Exam_Registration_Modification__c];
                GARP_Common.debugLog('GARP_BC_Orders','cancelUnpaidOrder','lstExamMods',lstExamMods);
                
                if(!lstExamMods.IsEmpty()) {
                    lstExamMods[0].Status__c = 'Canceled';
                    update lstExamMods;
                }
            }            
            
            returnInfo.status = 'Success';
        } else {
            returnInfo.status = 'Failed';
            returnInfo.msg = 'Open Order not found';
            return returnInfo;
        }
        
        return returnInfo;
    }
    
    public static MAP<String, orderInfo> getMemberOrders(String accountId, List<Opportunity> lstOpp) {
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','accountId',accountId);
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','lstOpp',lstOpp);
        
        MAP<String, orderInfo> orders = new MAP<String, orderInfo>();
        
        Set<String> excludedProductCodes = new Set<String>{'FRMRET1','FRMRET2','ERPRET1','ERPRET2','ENC'}; 
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','excludedProductCodes',excludedProductCodes);
                    
        MAP<String, Country_Code__c> mapCountryCodes = GARP_BC_Shipping.getCountryCodesMap();
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','mapCountryCodes',mapCountryCodes);
        
        if(lstOpp == NULL) {
            lstOpp = [SELECT Id, Name, StageName, Display_Invoice_Number__c, Amount, CreatedDate, Billing_Country__c, Alternate_Method_of_Payment__c,
                      Exam_Registration_Modification__c, B2B_Deal_Item__r.Discounted_Price__c, Stripe_Outbound_Type__c,
                      Exam_Registration_Modification__r.Deferral_SubType__c,
                      Exam_Registration_Modification__r.Part_I_Exam_Registration__c,
                      Exam_Registration_Modification__r.Part_I_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c,
                      Exam_Registration_Modification__r.Part_II_Exam_Registration__c,
                      Exam_Registration_Modification__r.Part_II_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c,
                                        (SELECT Id, ProductCode, TotalPrice FROM OpportunityLineItems),
                                        (SELECT Id, ChargentOrders__Type__c, ChargentOrders__Response_Status__c from Transactions__r),
                                        (SELECT Id from Email_Notifications__r)
                                        FROM Opportunity
                                        WHERE AccountId = :accountId AND
                                        StageName in ('Closed','New Lead') AND
                                        Late_EA_Id__c = NULL AND OSTA_Check__c = FALSE AND ia_crm__Intacct_Transaction__c NOT in ('Salesforce - Internal Refund')
                                        ORDER BY CreatedDate desc];            
        }
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','lstOpp',lstOpp);
        
        for(Opportunity opp :lstOpp) {
            
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','Loop opp',opp);
            
            // Skipe Auto-Renewal abandoned orders
            if(opp.StageName == 'New Lead' && opp.Stripe_Outbound_Type__c == 'Created') {
                continue;
            }
            
            Integer excludeCnt=0;
            for(OpportunityLineItem li :opp.OpportunityLineItems) {
                if(excludedProductCodes.contains(li.ProductCode) || li.ProductCode == 'PRFEE') {
                    excludeCnt++;
                }
            }
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','excludeCnt',excludeCnt);
            
            Boolean allProductsExcluded = FALSE;
            if(excludeCnt == opp.OpportunityLineItems.size()) {
                allProductsExcluded = TRUE;
            }
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','excludeCnt',excludeCnt);
            
            Boolean hasSuccess = FALSE;
            Boolean hasFailure = FALSE;
            for(ChargentOrders__Transaction__c ct :opp.Transactions__r) {
                if(ct.ChargentOrders__Type__c == 'Charge' || ct.ChargentOrders__Type__c == 'Credit') {
                    if(ct.ChargentOrders__Response_Status__c == 'Approved') {
                        hasSuccess = TRUE;
                    } else {
                        hasFailure = TRUE;
                    }
                }
            }
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','hasSuccess',hasSuccess);
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','hasFailure',hasFailure);
            
            Country_Code__c cc = mapCountryCodes.get(opp.Billing_Country__c);
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','cc',cc);
            
            Boolean isAlipay = FALSE;
            Boolean canCancelAlipay = FALSE;
            if(opp.Alternate_Method_of_Payment__c == 'alipay') {
                isAliPay = TRUE;
                
                Long minSinceCreated = (DateTime.Now().getTime() - opp.CreatedDate.getTime()) / (1000 * 60);
                
                if((opp.Transactions__r.IsEmpty() && minSinceCreated > 60) || hasFailure) {
                    canCancelAlipay = TRUE;
                }
            }
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','isAlipay',isAlipay);
            GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','canCancelAlipay',canCancelAlipay);
            
            // Hide Deferrals
            if(opp.Exam_Registration_Modification__c != NULL && opp.StageName == 'New Lead' && (
                    (opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__c != NULL && 
                     (opp.Exam_Registration_Modification__r.Part_I_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c == False && 
                      opp.Exam_Registration_Modification__r.Deferral_SubType__c != 'Deferral LDR')) ||
                    (opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__c != NULL &&
                     (opp.Exam_Registration_Modification__r.Part_II_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c == False && 
                      opp.Exam_Registration_Modification__r.Deferral_SubType__c != 'Deferral LDR'))
                )
                  ) {
                      allProductsExcluded = True;
                  }
            
            if(!allProductsExcluded) {
                orderInfo orderInfo = new orderInfo();
                orderInfo.orderId = opp.Id;
                orderInfo.name = opp.Name;
                // Do not return amount for PrePaid Team Orders
                if(opp.B2B_Deal_Item__r == NULL && opp.B2B_Deal_Item__r.Discounted_Price__c == NULL) {
                    orderInfo.amount = opp.Amount;    
                }
                orderInfo.orderNumber = opp.Display_Invoice_Number__c;
                orderInfo.orderDate =  Date.NewInstance(opp.CreatedDate.Year(), opp.CreatedDate.Month(), opp.CreatedDate.Day());   
                orderInfo.isClosed = (opp.StageName == 'Closed');
                orderInfo.isAliPay = isAliPay;
                orderInfo.canCancelAliPay = canCancelAlipay;
                GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','orderInfo',orderInfo);
                
                orderInfo.canPay = FALSE;
                orderInfo.canCancel = FALSE;
                if(!orderInfo.isClosed && !hasSuccess && opp.Email_Notifications__r.IsEmpty()) {
                    
                    if(!isAlipay || canCancelAlipay) {
                        orderInfo.canCancel = TRUE;    
                    }
                    
                    if(cc != NULL && cc.Is_Credit_Card_Allowed__c && cc.Is_Billing_Allowed__c && !isAlipay) {
                        orderInfo.canPay = TRUE;
                    }
                    
                }
                GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','canCancel',orderInfo.canCancel);
                GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','canPay',orderInfo.canPay);
                
                orders.put(orderInfo.orderId, orderInfo);
            }
        }
        GARP_Common.debugLog('GARP_BC_Orders','getMemberOrders','final orders',orders);
        return orders;
    }
    
    public static GARP_Common.returnInfo abandonPayPendingOrder(String accountID, String oppId){
        GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','oppId',oppId);
        GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','accountID',accountID);
        
        GARP_Common.returnInfo retInfo = new GARP_Common.returnInfo();
        
        if(oppId == null || accountID == null || accountID == ''){
            retInfo.status = 'Failure';
            retInfo.msg = 'Required paramaters are missing';
            retInfo.errorCode = 501;
            GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','Final retInfo',retInfo);
            return retInfo;
        }
        
        GARP_StripeClass.retSetupStripe stripeInitInfo = GARP_StripeClass.isStripeEnabled();
        GARP_Common.debugLog('GARP_BC_Registration','abandonPayPendingOrder','isStripeEnabled stripeInitInfo',stripeInitInfo);
        
        Opportunity opp = getOppAdjustOrder(oppId);
        GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','opp',opp);
        
        if(opp != NULL) {
            
            List<OpportunityLineItem> updateLineItems = new List<OpportunityLineItem>();
            OpportunityLineItem feeLineItem;
            OpportunityLineItem gstLineItem;
            Decimal total=0;
            
            for(OpportunityLineItem ol :opp.OpportunityLineItems){
                if(ol.Product2.ProductCode == 'PRFEE') {
                    feeLineItem = ol;
                    feeLineItem.TotalPrice = 50;
                    GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','Update feeLineItem',feeLineItem);
                    updateLineItems.add(feeLineItem);
                }
                
                if(ol.Product2.ProductCode == 'GSTTAX') {
                    gstLineItem = ol;
                } else if(ol.Product2.ProductCode == 'IGSTTAX') {
                    gstLineItem = ol;
                }
            }
            GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','gstLineItem',gstLineItem);
            
            if(!stripeInitInfo.useStripeTax && gstLineItem != NULL) {
                
                String GSTCountryCode;
                if(gstLineItem.Product2.ProductCode == 'GSTTAX') {
                    GSTCountryCode = 'SGP';
                } else if(gstLineItem.Product2.ProductCode == 'IGSTTAX') {
                    GSTCountryCode = 'IND';
                }
                GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','GSTCountryCode',GSTCountryCode);
                
                // Get Total for this type of VAT
                for(OpportunityLineItem ol :opp.OpportunityLineItems){
                    if(ol.Product2.Do_Not_Charge_VAT_Countries__c != NULL && ol.Product2.Do_Not_Charge_VAT_Countries__c.IndexOf(GSTCountryCode) > -1) {
                        //Skip
                    } else {
                        total+=ol.TotalPrice;
                    }                    
                }
                GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','VAT Total',total);
                
                Decimal gstAmount = (gstLineItem.Product2.Tax_Rate__c * .01);
                gstLineItem.TotalPrice = total * gstAmount;
                GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','Update gstLineItem',gstLineItem);
                updateLineItems.add(gstLineItem);
            } else if(stripeInitInfo.useStripeTax) {

                /* ===== LEGACY (retained for reference) -- hardcoded product codes + ALWAYS insert (caused duplicate tax line items) =====
                List<String> productCodes = new List<String>();
                productCodes.addAll(new List<String>{'PRFEE','SLSTX','IGSTTAX','GSTTAX'});
                List<String> priceIds = new List<String>();
                MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds);
                GARP_StripeClass.retGetCheckoutTax retTax = GARP_StripeClass.getCheckoutTax(NULL, opp);
                if(retTax.status == 'Success' && retTax.orderTaxInfo.amount != NULL) {
                    if(retTax.orderTaxInfo.taxType == 'sales_tax' && retTax.orderTaxInfo.state == 'NJ') {
                        PricebookEntry fndPbe = getPricebookEntryByCode(mapProdByCodes, 'SLSTX', '2819');
                        if (fndPbe == null) { retInfo.status='Failure'; retInfo.msg='Product not found'; retInfo.errorCode=401; return retInfo; }
                        Decimal amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=fndPbe.Id, Product2Id=fndPbe.Product2Id, UnitPrice=amount, Quantity=1, Description='Sales Tax');
                        insert taxLineItem;
                    } else if(retTax.orderTaxInfo.taxType == 'igst') {
                        PricebookEntry fndPbe = getPricebookEntryByCode(mapProdByCodes, 'IGSTTAX', '2819');
                        if (fndPbe == null) { retInfo.status='Failure'; retInfo.msg='Product not found'; retInfo.errorCode=401; return retInfo; }
                        Decimal amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=fndPbe.Id, Product2Id=fndPbe.Product2Id, UnitPrice=amount, Quantity=1, Description='IGST');
                        insert taxLineItem;
                    } else if(retTax.orderTaxInfo.taxType == 'sgst') {
                        PricebookEntry fndPbe = getPricebookEntryByCode(mapProdByCodes, 'SGST', '2819');
                        if (fndPbe == null) { retInfo.status='Failure'; retInfo.msg='Product not found'; retInfo.errorCode=401; return retInfo; }
                        Decimal amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                        OpportunityLineItem taxLineItem = new OpportunityLineItem(OpportunityId=opp.Id, PricebookEntryId=fndPbe.Id, Product2Id=fndPbe.Product2Id, UnitPrice=amount, Quantity=1, Description='Sales Tax');
                        insert taxLineItem;
                    }
                }
                ===== END LEGACY ===== */

                // NEW: dynamic tax-type -> product-code mapping from custom metadata
                // (Stripe_Auth_Configuration__mdt.Stripe_Product_Code__c) via StripeTaxCalUtil
                // helpers, and UPSERT -- update the existing tax line instead of always inserting
                // (fixes duplicate tax OpportunityLineItems on repeat calls).
                Stripe_Auth_Configuration__mdt stripeCfg = StripeTaxCalUtil.getStripeAuthConfig();
                Map<String, String> taxTypeToProductCode = StripeTaxCalUtil.parseTaxTypeToProductCode(
                    stripeCfg == null ? null : stripeCfg.Stripe_Product_Code__c);
                Set<String> taxProductCodes = new Set<String>(taxTypeToProductCode.values());

                List<String> productCodes = new List<String>{ 'PRFEE' };
                productCodes.addAll(taxProductCodes);
                MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, new List<String>());
                GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','mapProdByCodes',mapProdByCodes);

                // Existing tax line items keyed by product code -> UPDATE these, don't insert new.
                Map<String, OpportunityLineItem> existingTaxOliByCode = new Map<String, OpportunityLineItem>();
                for(OpportunityLineItem exOl :opp.OpportunityLineItems) {
                    if(taxProductCodes.contains(exOl.Product2.ProductCode)) {
                        existingTaxOliByCode.put(exOl.Product2.ProductCode, exOl);
                    }
                }

                // Add / Update Tax
                GARP_StripeClass.retGetCheckoutTax retTax = GARP_StripeClass.getCheckoutTax(NULL, opp);
                if(retTax.status == 'Success' && retTax.orderTaxInfo != NULL && retTax.orderTaxInfo.amount != NULL) {
                    GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','taxType',retTax.orderTaxInfo.taxType);
                    GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','state',retTax.orderTaxInfo.state);

                    String taxTypeKey = retTax.orderTaxInfo.taxType == null ? null : retTax.orderTaxInfo.taxType.toLowerCase();
                    String taxPrCode = taxTypeKey == null ? null : taxTypeToProductCode.get(taxTypeKey);
                    // Legacy parity: US sales tax is only applied for New Jersey.
                    if(taxTypeKey == 'sales_tax' && retTax.orderTaxInfo.state != 'NJ') { taxPrCode = null; }

                    if(String.isNotBlank(taxPrCode)) {
                        PricebookEntry fndPbe = getPricebookEntryByCode(mapProdByCodes, taxPrCode, '2819');
                        if (fndPbe == null) {
                            retInfo.status = 'Failure';
                            retInfo.msg = 'Product not found';
                            retInfo.errorCode = 401;
                            return retInfo;
                        }
                        Decimal amount = ((Decimal)retTax.orderTaxInfo.amount / 100).setScale(2);
                         
                        OpportunityLineItem existingTaxOli = existingTaxOliByCode.get(taxPrCode);
                        if(existingTaxOli != NULL) {
                            existingTaxOli.UnitPrice = amount;
                            existingTaxOli.Description = taxTypeKey;
                            updateLineItems.add(existingTaxOli);
                            GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','update existing taxLineItem',existingTaxOli);
                        } else {
                            OpportunityLineItem taxLineItem = new OpportunityLineItem(
                                OpportunityId    = opp.Id,
                                PricebookEntryId = fndPbe.Id,
                                Product2Id       = fndPbe.Product2Id,
                                UnitPrice        = amount,
                                Quantity         = 1,
                                Description      = taxTypeKey
                            );
                            GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','insert taxLineItem',taxLineItem);
                            insert taxLineItem;
                        }
                    }
                }
            }

            if(!updateLineItems.IsEmpty()) {
                update updateLineItems;
            }

        } else {
            retInfo.status = 'Failure';
            retInfo.msg = 'Order not found';
            retInfo.errorCode = 401;
            GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','Final retInfo',retInfo);
            return retInfo;
        }
        
        retInfo.status = 'Success';
        retInfo.msg = 'Order is reverted';
        retInfo.errorCode = 200;
        
        GARP_Common.debugLog('GARP_BC_Orders','abandonPayPendingOrder','Final retInfo',retInfo);
        return retInfo;
    }
    
    
    public static Opportunity getOppAdjustOrder(String oppId) {
        List<Opportunity> lstOpp = [select Id, AccountId, Account.Member_First_Name__c, Account.Member_Last_Name__c, Name, StageName, Display_Invoice_Number__c, Amount, Billing_Email__c, Auto_Renew__c, B2B_Deal_Item__r.Access_Code__c,
                                    Shipping_Street__c, Shipping_City__c, Shipping_State__c, Shipping_Postal_Code__c, Shipping_Country__c, Shipping_Phone_No__c,
                                    Billing_Address__c, Billing_City__c, Billing_State_Text__c, Billing_Zip_Postal__c, Billing_Country__c, Billing_Phone__c,
                                    (select Id, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Product2.Name, Product2.Stripe_Tax_Code__c, Product2.ProductCode, Product2.Tax_Rate__c, Product2.Do_Not_Charge_VAT__c, Product2.Do_Not_Charge_VAT_Countries__c FROM OpportunityLineItems),
                                    (select id, ChargentOrders__Gateway__c, ChargentOrders__Subtotal__c, ChargentOrders__Charge_Amount__c,
                                     ChargentOrders__Tokenization__c, ChargentOrders__Order_Information__c
                                     from Chargent_Orders__r)
                                    from Opportunity where id = :oppId];
        GARP_Common.debugLog('GARP_BC_Orders','getOppAdjustOrder','lstOpp','lstOpp');
        
        if(!lstOpp.IsEmpty()) {
            return lstOpp[0];
        } else {
        	return NULL;    
        }
    }
    
    public class returnRecalculateTaxOnOrder {
        public String status;
        public String message;
        public Opportunity adjustedOpp;
    }
    
    public static GARP_Common.returnInfo recalculateTaxOnOrder(String oppId, Opportunity opp) {
        
        GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','oppId','oppId');
        GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','opp','opp');
        
        GARP_Common.returnInfo retInfo = new GARP_Common.returnInfo();
        
        if(oppId == NULL && opp == NULL) {
            retInfo.status = 'Failure';
            retInfo.msg = 'Required paramaters are missing';
            retInfo.errorCode = 501;
            GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','Final retInfo',retInfo);
            return retInfo;
        }
        
        if(opp == NULL) {
            opp = getOppAdjustOrder(oppId);
            if(opp == NULL) {
                retInfo.status = 'Failure';
                retInfo.msg = 'Order not found';
                retInfo.errorCode = 401;
                GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','Final retInfo',retInfo);
                return retInfo;
            }
        }
        
        List<String> productCodes = new List<String>();
        Set<String> taxProducts = new Set<String>{'SLSTX','IGSTTAX','SGST'};
        productCodes.addAll(taxProducts);
        List<String> priceIds = new List<String>();
        MAP<String,PricebookEntry> mapProdByCodes = GARP_BC_Orders.getPriceBooksEntries(productCodes, priceIds); 
        GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','mapProdByCodes',mapProdByCodes);
        
        // Remove existing taxes
        opp.Stripe_Tax_Type__c = NULL;
        opp.Stripe_Tax_Country__c = NULL;
        opp.Stripe_Tax_Taxable_Amount__c = NULL;
        
        List<OpportunityLineItem> removeTaxLineItems = new List<OpportunityLineItem>();
        List<OpportunityLineItem> addTaxLineItems = new List<OpportunityLineItem>();
        MAP<String, OpportunityLineItem> updateLineItems = new MAP<String, OpportunityLineItem>();
        for(OpportunityLineItem li :opp.OpportunityLineItems) {
            if(taxProducts.contains(li.Product2.ProductCode)) {
                removeTaxLineItems.add(li);
            } else {
                li.Stripe_Tax_Amount__c = NULL;
                li.Stripe_Tax_Code__c = NULL;
                updateLineItems.put(li.Product2.ProductCode, li);
            }
        }

		GARP_StripeClass.retGetCheckoutTax retTax = GARP_StripeClass.getCheckoutTax(NULL, opp);
    
        if(retTax.status == 'Success') {
            
            opp.Stripe_Tax_Type__c = retTax.orderTaxInfo.taxType;
            opp.Stripe_Tax_Country__c = retTax.orderTaxInfo.country;
            opp.Stripe_Tax_Taxable_Amount__c = retTax.orderTaxInfo.taxableAmount;
            
            for(OpportunityLineItem li :opp.OpportunityLineItems) {
                GARP_Common.debugLog('GARP_StripeClass','recalculateTaxOnOrder','loop opp line items',li);
                
                GARP_StripeClass.retGetCheckoutTaxLineItemsData fndLineItem = retTax.orderTaxInfo.mapTaxLineItems.get(li.Product2.Name);
                GARP_Common.debugLog('GARP_StripeClass','recalculateTaxOnOrder','fndLineItem',fndLineItem);
                
                if(fndLineItem != NULL && fndLineItem.amount_tax > 0) {
                    li.Stripe_Tax_Amount__c = ((Decimal)fndLineItem.amount_tax / 100).setScale(2);
                    li.Stripe_Tax_Code__c = li.Product2.Stripe_Tax_Code__c;
                    GARP_Common.debugLog('GARP_StripeClass','recalculateTaxOnOrder','updateLineItem',li);
                    updateLineItems.put(li.Product2.ProductCode, li);
                }
            }
            
            PricebookEntry pbeTax;
            if(retTax.orderTaxInfo.taxType == 'sales_tax' && retTax.orderTaxInfo.state == 'NJ') {
                pbeTax = mapProdByCodes.get('SLSTX:2819');
            } else if(retTax.orderTaxInfo.taxType == 'igst') {
                pbeTax = mapProdByCodes.get('IGSTTAX:2819');
            } else if(retTax.orderTaxInfo.taxType == 'sgst') {
                pbeTax = mapProdByCodes.get('GSTTAX:2819');
            }
            
            if(pbeTax != NULL) {
                Decimal amount = Decimal.ValueOf(retTax.orderTaxInfo.amount);
                amount = ((Decimal)amount / 100).setScale(2);
                
                OpportunityLineItem taxLineItem = new OpportunityLineItem( 
                    OpportunityId       = opp.Id,                          
                    PricebookEntryId    = pbeTax.Id,
                    Product2Id          = pbeTax.Product2Id,
                    UnitPrice           = amount,
                    Quantity            = 1,
                    Description         = 'Sales Tax'
                );
                
                GARP_Common.debugLog('GARP_StripeClass','processWebhook','taxLineItem',taxLineItem);
                addTaxLineItems.add(taxLineItem);
            }

            GARP_Common.debugLog('GARP_StripeClass','processWebhook','removeTaxLineItems',removeTaxLineItems);
            GARP_Common.debugLog('GARP_StripeClass','processWebhook','updateLineItems',updateLineItems.Values());
            GARP_Common.debugLog('GARP_StripeClass','processWebhook','addTaxLineItems',addTaxLineItems);
            
            delete removeTaxLineItems;
            update updateLineItems.Values();
            insert addTaxLineItems;
            
        } else {
            retInfo.status = 'Failure';
            retInfo.msg = 'Failed to compute taxes';
            retInfo.errorCode = 401;
        }
        
        GARP_Common.debugLog('GARP_BC_Orders','recalculateTaxOnOrder','Final retInfo',retInfo);
        return retInfo;
        
    }
    
    public static GARP_Common.returnInfo payPendingOrder(String accountID, String oppId){
        
        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','oppId',oppId);
        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','accountID',accountID);
        
        GARP_Common.returnInfo retInfo = new GARP_Common.returnInfo();
        
        if(oppId == null || accountID == null || accountID == ''){
            retInfo.status = 'Failure';
            retInfo.msg = 'Required paramaters are missing';
            retInfo.errorCode = 501;
            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Final retInfo',retInfo);
            return retInfo;
        }
        
        GARP_StripeClass.retSetupStripe stripeInitInfo = GARP_StripeClass.isStripeEnabled();
        GARP_Common.debugLog('GARP_BC_Registration','abandonPayPendingOrder','isStripeEnabled stripeInitInfo',stripeInitInfo);
        
        Opportunity opp = [
            SELECT Id, Name, Amount, Token__c, Manual_Charge__c, Charge_Amount__c, Payment_Method_New__c,
            (
                SELECT Id, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice, Product2.ProductCode, Product2.Tax_Rate__c, Product2.Do_Not_Charge_VAT__c, Product2.Do_Not_Charge_VAT_Countries__c FROM OpportunityLineItems
            ) ,
            (Select Id,ChargentOrders__Transaction_Total__c, ChargentOrders__Payment_Method__c from Chargent_Orders__r) 
            FROM Opportunity 
            WHERE 
            Id = :oppId AND 
            StageName != 'Closed' AND 
            AccountId = :accountID
        ];
        
        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','opp',opp);
        
        if(opp != null) {
        
            List<ChargentOrders__ChargentOrder__c > lstChrgOrders = [select Id, ChargentOrders__Transaction_Total__c, ChargentOrders__Payment_Method__c from ChargentOrders__ChargentOrder__c where Opportunity__c = :oppId];
            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','lstChrgOrders',lstChrgOrders);
                    
            if(opp.Amount == 0) {
                
                opp.StageName = 'Closed';
                UPDATE opp;
                
                GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Zero Dollar Opp Closed',opp);
                
                retInfo.status = 'Success';
                retInfo.msg = 'Order is closed';
                retInfo.errorCode = 201;
                return retInfo;
                
            } else if(!lstChrgOrders.IsEmpty()) {
                
                 List<ChargentOrders__Transaction__c> lstTrans = [
                    Select id ,Name, ChargentOrders__Amount__c, Opportunity__r.CloseDate , Opportunity__c,Opportunity__r.GARP_Member_ID__c, Opportunity__r.StageName , ChargentOrders__Type__c, ChargentOrders__Payment_Method__c, ChargentOrders__Response_Status__c, ChargentOrders__Gateway_Date__c
                    FROM ChargentOrders__Transaction__c
                    where 
                    ChargentOrders__Amount__c!= NULL and 
                    Opportunity__c = :oppId and 
                    Opportunity__r.StageName != 'Recurring Intent' AND 
                    ChargentOrders__Type__c = 'Credit' AND 
                    (
                        ChargentOrders__Response_Status__c = 'Approved' OR 
                        ChargentOrders__Response_Status__c = '' OR 
                        ChargentOrders__Response_Status__c = NULL
                    ) 
                    ORDER BY ChargentOrders__Gateway_Date__c ASC
                ];             
                GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','lstChrgOrders',lstChrgOrders);
                
                if(lstTrans != null && lstTrans.size() > 0) {
                    
                    Decimal amt = opp.Amount;
                    
                    system.debug('amt:' + amt);
                    
                    for(ChargentOrders__Transaction__c ct :lstTrans) {
                        amt-= ct.ChargentOrders__Amount__c;
                        system.debug('amt:' + amt + ':' + ct.ChargentOrders__Amount__c);
                    }
                    
                    opp.Manual_Charge__c = true;
                    opp.Charge_Amount__c = amt;
                    
                } else {
                     opp.Manual_Charge__c = false;
                }
                
                // AG 12/4 We dont know this??
                //opp.Payment_Method_New__c = 'Credit Card';
                opp.Token__c = null;

                GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Update Opp fields based on transacions',opp);
                
                UPDATE opp;
                
                // AG 12/4 We dont know this??
                //lstChrgOrders[0].ChargentOrders__Payment_Method__c = 'Credit Card';
                //update lstChrgOrders;
                //System.Debug('~~update lstChrgOrders:' + lstChrgOrders);
                
                List<PricebookEntry> prfeePbes = [
                    SELECT Id, UnitPrice, Product2.ProductCode, Product2.Gl_Code__c
                    FROM PricebookEntry
                    WHERE Pricebook2.IsActive = true
                    AND Product2.ProductCode = 'PRFEE'
                    AND Product2.Gl_Code__c = '6110'
                    AND IsActive = true
                    LIMIT 1
                ];
                PricebookEntry pricebookEntry = prfeePbes.isEmpty() ? null : prfeePbes[0];
                GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','pricebookEntry',pricebookEntry);

                if(pricebookEntry != null) {
                    
                    List<OpportunityLineItem> updateLineItems = new List<OpportunityLineItem>();
                    List<OpportunityLineItem> removeLinetItems = new List<OpportunityLineItem>();
                    
                    Decimal total=0;
                    OpportunityLineItem gstOli;
                    OpportunityLineItem njslstxOli;
                    OpportunityLineItem pfeeOli;
                    
                    for(OpportunityLineItem ol :opp.OpportunityLineItems){
                        if(ol.PricebookEntryId == pricebookEntry.Id) {
                            ol.TotalPrice = 0;
                            pfeeOli = ol;
                        }
                       
                        // Adjust GST
                        if(ol.Product2.ProductCode == 'GSTTAX') {
                            gstOli = ol;
                        } else if(ol.Product2.ProductCode == 'IGSTTAX') {
                            gstOli = ol;
                        } else if(ol.Product2.ProductCode == 'SLSTX') {
                            njslstxOli = ol;
                        }
                    }
                    GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','pfeeOli',pfeeOli);
                    GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','gstOli',gstOli);
                    GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','njslstxOli',njslstxOli);
                    
                    // else if(!ol.Product2.Do_Not_Charge_VAT__c) {
                    //        total+=ol.TotalPrice;
                    //    }
                    
                    if(!stripeInitInfo.useStripeTax && gstOli != NULL) {
                        
                        if(pfeeOli != NULL) {
                            updateLineItems.add(pfeeOli);
                        }
                        
                        String GSTCountryCode;
                        if(gstOli.Product2.ProductCode == 'GSTTAX') {
                            GSTCountryCode = 'SGP';
                        } else if(gstOli.Product2.ProductCode == 'IGSTTAX') {
                            GSTCountryCode = 'IND';
                        }
                        
                        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','GSTCountryCode',GSTCountryCode);
                        
                        // Get Total Amount
                        for(OpportunityLineItem ol :opp.OpportunityLineItems){
                            if(ol.Product2.Do_Not_Charge_VAT_Countries__c != NULL && ol.Product2.Do_Not_Charge_VAT_Countries__c.IndexOf(GSTCountryCode) > -1) {
                                //Skip
                            } else {
                                total+=ol.TotalPrice;
                            }                            
                        }
                        
                        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','VAT total',total);
                        
                        Decimal gstAmount = (gstOli.Product2.Tax_Rate__c * .01);
                        gstOli.TotalPrice = total * gstAmount;
                        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Update GST',gstOli);
                        updateLineItems.add(gstOli);
                        
                        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','updateLineItems',updateLineItems);
                        UPDATE updateLineItems;
                    } else if(stripeInitInfo.useStripeTax) {
                        if(pfeeOli != NULL) {
                            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','UPDATE pfeeOli',pfeeOli);
                            UPDATE pfeeOli;
                        }
                        
                        if(gstOli != NULL) {
                            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','remove gstOli',gstOli);
                            removeLinetItems.add(gstOli);
                        }
                        if(njslstxOli != NULL) {
                            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','remove njslstxOli',njslstxOli);
                            removeLinetItems.add(njslstxOli);
                        }
                        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','removeLinetItems',removeLinetItems);
                        if(!removeLinetItems.IsEmpty()) {
                            DELETE removeLinetItems;
                        }
                    } 
                }                   
            }
        } else {
            retInfo.status = 'Failure';
            retInfo.msg = 'Order not found';
            retInfo.errorCode = 401;
            GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Final retInfo',retInfo);
            return retInfo;
        }
        
        retInfo.status = 'Success';
        retInfo.msg = 'Order is ready to pay';
        retInfo.errorCode = 200;
        
        GARP_Common.debugLog('GARP_BC_Orders','payPendingOrder','Final retInfo',retInfo);
        return retInfo;        
    }
    // Chargent Helpers
    
    public static String PrepareJsonParametersForPayment(Id oppId, GARP_BC_Orders.orderPaymentInfo paymentInfo, Decimal amount)
    {
        boolean atuhorize = false;
        String jsonInput = '{\n' +
        ' "ObjectId" : "'+ oppId +'",\n' +
        ' "CardMonth" : "'+ paymentInfo.expireMonth +'",\n' +
        ' "CardYear" :"'+ paymentInfo.expireYear +'",\n' +
        ' "PaymentMethod" : "'+ paymentInfo.paymentType +'",\n' +
        ' "CardType" : "Visa",\n' +
        ' "CardSecurity" : "'+ paymentInfo.ccv +'",\n' +
        ' "CardNumber" : "'+ paymentInfo.cardNumber +'",\n' +
        ' "ChargeAmount" : "'+ amount +'"' +
        '}';
        
        return jsonInput;
    
    }
    
    public static String PrepareVoidJsonParameters(Id oppId,Decimal amount)
    {
        String jsonInput = '{\n' +
        ' "ObjectId" : "'+ oppId +'",\n' +
        ' "ChargeAmount" : "'+ amount +'"\n' +
        '}';
        
        return jsonInput;
    
    }
    
}