public class GARP_WebToCase {

    public GARP_WebToCase() {
    }
    
    public Boolean isValidString(String inStr) {
        if(inStr != NULL && !String.IsEmpty(inStr)) {
            return True;
        } else {
            return False;
        }
    }

    /** Case owner from Label.Case_Owner_For_MS when set and valid; otherwise running user (e.g. test or orgs where label is blank). */
    private static Id getCaseOwnerId() {
        if (Test.isRunningTest()) {
            return UserInfo.getUserId();
        }
        String labelVal = Label.Case_Owner_For_MS;
        if (String.isBlank(labelVal)) {
            return UserInfo.getUserId();
        }
        try {
            return (Id) labelVal;
        } catch (Exception e) {
            return UserInfo.getUserId();
        }
    }

    public PageReference initialize() {

        String retURL = ApexPages.currentPage().getParameters().get('ret_url');
        
        if(isValidString(retURL)) {
        	retURL = EncodingUtil.urlDecode(retURL, 'UTF-8');    
        }
        
        String webOrigin = ApexPages.currentPage().getParameters().get('web_origin');
        String firstName = ApexPages.currentPage().getParameters().get('first_name');
        String lastName = ApexPages.currentPage().getParameters().get('last_name');
        String email = ApexPages.currentPage().getParameters().get('email');
        String garpID = ApexPages.currentPage().getParameters().get('garp_id');
        String subject = ApexPages.currentPage().getParameters().get('subject');
        String request = ApexPages.currentPage().getParameters().get('description');
        String captcha = ApexPages.currentPage().getParameters().get('recaptcha_token');
        
        GARP_Common.debugLog('GARP_WebToCase','initialize','retURL',retURL);
        GARP_Common.debugLog('GARP_WebToCase','initialize','webOrigin',webOrigin);
        GARP_Common.debugLog('GARP_WebToCase','initialize','firstName',firstName);
        GARP_Common.debugLog('GARP_WebToCase','initialize','lastName',lastName);
        GARP_Common.debugLog('GARP_WebToCase','initialize','email',email);
        GARP_Common.debugLog('GARP_WebToCase','initialize','garpID',garpID);
        GARP_Common.debugLog('GARP_WebToCase','initialize','subject',subject);
        GARP_Common.debugLog('GARP_WebToCase','initialize','request',request);
        GARP_Common.debugLog('GARP_WebToCase','initialize','captcha',captcha);

        
        Boolean isValidEmail = False;
        if(isValidString(email) && email.IndexOf('@') > -1 && email.IndexOf('.') > -1) {
            isValidEmail = True;
        }
        GARP_Common.debugLog('GARP_WebToCase','initialize','isValidEmail',isValidEmail);
        
        Map<String, WebToCaseBlackList__c> blackListSettings = WebToCaseBlackList__c.getAll();
        GARP_Common.debugLog('GARP_WebToCase','initialize','blackListSettings',blackListSettings);
        
        if(!blackListSettings.IsEmpty()) {
            for(WebToCaseBlackList__c bl :blackListSettings.values()) {
                System.Debug('**BL:' + bl.Name);
                
                if(bl.Name.IndexOf('@') == 0) {
                    if(email.IndexOf(bl.Name) > -1) {
                        GARP_Common.debugLog('GARP_WebToCase','initialize','Block email domain',email);
                        return new PageReference('https://www.garp.org');
                    }
                } else if(email == bl.Name) {
                    GARP_Common.debugLog('GARP_WebToCase','initialize','Block exact email',email);
                    return new PageReference('https://www.garp.org');
                }
            }
        }
        
        if(isValidString(captcha) && isValidString(firstName) && isValidString(lastName) && isValidString(email) && isValidEmail && isValidString(subject) && isValidString(request)) {
            
            ID customerRecordType = RecordTypeHelper.getRecordTypeId('Case', 'Customer');
            
            String description = 'Submitted By: ' + firstName + ' ' + lastName + '\n\n';
            if(isValidString(garpID)) {
                description += 'GARP ID: ' + garpID + '\n\n';
            }
            description += 'Request: ' + request;
            GARP_Common.debugLog('GARP_WebToCase','initialize','description',description);
        
            Case newCase = new Case(
                First_Name__c = firstName,
                Last_Name__c = lastName,
                SuppliedEmail = email,
                Subject = subject,
                Description = description,
                Web_Origin__c = webOrigin,
                RecordTypeId = customerRecordType,
                OwnerId = getCaseOwnerId(),
                Origin = 'Web',
                captcha__c = captcha
            );
            GARP_Common.debugLog('GARP_WebToCase','initialize','newCase',newCase);
            insert newCase;
        }
        
        if(retURL != NULL) {
        	return new PageReference('https://www.garp.org' + retURL);    
        } else {
            return new PageReference('https://www.garp.org');    
        }
    }
}