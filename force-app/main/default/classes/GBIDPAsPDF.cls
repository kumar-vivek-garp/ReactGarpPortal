public class GBIDPAsPDF {
    public DPSubmissionWrapper dpSubmissionWrapper {get; set;}

    public GBIDPAsPDF() {
        Id studyId = ApexPages.currentPage().getParameters().get('studyId');
        Id submissionId = ApexPages.currentPage().getParameters().get('submissionId');
        Id studyAccountId = ApexPages.currentPage().getParameters().get('studyAccountId');
        fetchData(studyId, submissionId,studyAccountId);
    }

    public void fetchData(Id studyId, Id submissionId,Id studyAccountId) {

        List<Disclosure_Protocol__c> disclosureProtocols = [
            SELECT Id, Name, Study__c, Disclosure_Protocol__c, Consent_By_Date__c
            FROM Disclosure_Protocol__c
            WHERE Study__c = :studyId AND DP_Status__c = 'Active'
        ];

        if(!disclosureProtocols.isEmpty()){

            Disclosure_Protocol__c disclosureProtocol = disclosureProtocols[0];

            System.debug('disclosureProtocol' + disclosureProtocol);

            List<Study__c> studies = [
                SELECT Id, Name, Disclosure_Protocol__c
                 FROM Study__c
                 WHERE Id = :studyId
            ];

            if(studies != null && !studies.isEmpty()) {
                if(submissionId == null){
                    String userId = UserInfo.getUserId();
                    String contactId;
                    List<User> lstUser = [Select u.Id,u.ContactId, FullPhotoUrl from User u where u.Id = :userId];
                    if( lstUser != null && lstUser.size() > 0 ) {
                        contactId = lstUser[0].ContactId;
                        List<Contact> lstContact = [SELECT Id, Name, AccountId FROM Contact WHERE Id = :contactId];
                        if( lstContact != null && lstContact.size() > 0 ) {

                            List<Study_Contact__c> lstStudyContact = [select Id, Study_Disclose_Protocol_Submission__c,Name, Role__c, Status__c, Study__c, Contact__c, Study_Account__c from Study_Contact__c
                                                                      where Contact__c = :contactId and Study__c =: studyId and Study_Account__c =: studyAccountId];
                            if(!lstStudyContact.isEmpty()){
                                submissionId = lstStudyContact[0].Study_Disclose_Protocol_Submission__c;
                            }
                        }
                    }
                }

                List<Study_Disclose_Protocol_Submission__c> submissions = [
                    SELECT Id, Disclosure_Protocol__c, Contact_Name__c, Signed_Date_Time__c, Payment_Agreed_Amount__c,
                    Study_Account__r.Invoice_Email__c, Study_Account__r.Account__r.Name, Study__r.End_Date__c, Study__r.Name,
                    Study__r.Study_Fee__c, Study__r.Payment_Required__c, Study__r.CurrencyIsoCode,
                    Study_Account__r.Study_Fee_Type__c, Study_Account__r.Study_Fee__c, Study_Account__r.CurrencyIsoCode,
                    Study_Account__r.Account__r.BillingStreet, Study_Account__r.Account__r.BillingCity,
                    Study_Account__r.Account__r.BillingState, Study_Account__r.Account__r.BillingPostalCode,
                    Study_Account__r.Account__r.BillingCountry, Study_Account__r.Payment_Agreed_Amount__c, CurrencyIsoCode
                    FROM Study_Disclose_Protocol_Submission__c
                    WHERE Id = :submissionId
                    ORDER BY CreatedDate DESC
                    LIMIT 1
                ];


                Profile profile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId() LIMIT 1];

                // Adding protection by profile to hide signee information from non-approved profiles (to prevent URL hacking).
                if(!submissions.isEmpty() && (profile.Name == 'GBI' || profile.Name == 'GARP GBI' || profile.Name == 'GARP Technology/Admin' || profile.Name == 'System Administrator' || profile.Name == 'Customer Community')){
                    this.dpSubmissionWrapper = new DPSubmissionWrapper(submissions[0], disclosureProtocol.Disclosure_Protocol__c, disclosureProtocol.Consent_By_Date__c);
                }else{
                    this.dpSubmissionWrapper = new DPSubmissionWrapper(disclosureProtocol.Disclosure_Protocol__c);
                }

            }

        }

    }

    public class DPSubmissionWrapper {

        public String dpHtml {get; set;}
        public String signee {get; set;}
        public DateTime signDateTime {get; set;}
        public Decimal paymentAgreedAmount {get; set;}
        public String email {get; set;}
        public String studyAccountName {get; set;}
        public String billingAddress {get; set;}
        public Date studyEndDate {get; set;}
        public String studyName {get; set;}
        public Date consentByDate {get; set;}
        public String configuredCurrencyCode {get; set;}

        public DPSubmissionWrapper(String html) {
            dpHtml = html;
        }

        public DPSubmissionWrapper(Study_Disclose_Protocol_Submission__c dpSubmission, String html, Date consentByDateInput ) {
            dpHtml = html;
            signee = dpSubmission.Contact_Name__c;
            signDateTime = dpSubmission.Signed_Date_Time__c;

            paymentAgreedAmount = dpSubmission.Payment_Agreed_Amount__c;

            // For reverse compatability
            if(dpSubmission.Payment_Agreed_Amount__c == NULL && dpSubmission.Study_Account__r.Payment_Agreed_Amount__c != NULL) {
                paymentAgreedAmount = dpSubmission.Study_Account__r.Payment_Agreed_Amount__c;
            }

            // Always calculate currency using current hierarchy logic (don't rely solely on stored value)
            // This ensures legacy submissions and updated Study/Study Account currencies are handled correctly

            // Check if payment is required
            Boolean studyPaymentRequired = dpSubmission.Study__r.Payment_Required__c == true;
            Boolean studyAccountPaymentRequired = String.isNotBlank(dpSubmission.Study_Account__r.Study_Fee_Type__c) &&
                                                  dpSubmission.Study_Account__r.Study_Fee_Type__c == 'Required';

            // Check if there's a study fee
            Boolean studyHasFee = studyPaymentRequired && dpSubmission.Study__r.Study_Fee__c != null && dpSubmission.Study__r.Study_Fee__c > 0;
            Boolean studyAccountHasFee = studyAccountPaymentRequired && dpSubmission.Study_Account__r.Study_Fee__c != null &&
                                        dpSubmission.Study_Account__r.Study_Fee__c > 0;

            if((studyPaymentRequired || studyAccountPaymentRequired) && (studyHasFee || studyAccountHasFee)) {
                // Apply hierarchy: Study Account > Study > USD (only use currencies when payment is required at that level)
                String studyAccountCurrency = studyAccountPaymentRequired ? dpSubmission.Study_Account__r.CurrencyIsoCode : null;
                String studyCurrency = studyPaymentRequired ? dpSubmission.Study__r.CurrencyIsoCode : null;

                if(String.isNotBlank(studyAccountCurrency)) {
                    configuredCurrencyCode = studyAccountCurrency;
                } else if(String.isNotBlank(studyCurrency)) {
                    configuredCurrencyCode = studyCurrency;
                } else {
                    // Fallback: use stored value from submission, or default to USD
                    configuredCurrencyCode = String.isNotBlank(dpSubmission.CurrencyIsoCode) ? dpSubmission.CurrencyIsoCode : 'USD';
                }
            } else {
                configuredCurrencyCode = null; // No payment required or no fee
            }

            email = dpSubmission.Study_Account__r.Invoice_Email__c;
            studyAccountName = dpSubmission.Study_Account__r.Account__r.Name;
            billingAddress = dpSubmission.Study_Account__r.Account__r.BillingStreet + ' ' + dpSubmission.Study_Account__r.Account__r.BillingCity + ' ' + dpSubmission.Study_Account__r.Account__r.BillingState + ' ' + dpSubmission.Study_Account__r.Account__r.BillingPostalCode + ' ' + dpSubmission.Study_Account__r.Account__r.BillingCountry;
            studyEndDate = dpSubmission.Study__r.End_Date__c;
            studyName = dpSubmission.Study__r.Name;
            consentByDate = consentByDateInput;

            System.debug(consentByDate);
        }
    }
}