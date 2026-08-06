global without sharing class LoginController {

    global String sessionID {get; set;}
        
    global String username {get; set;}
    global String password {get; set;}   
    global String firstName {get; set;}
    global String lastName {get; set;}
    global String country {get; set;}
    global String company {get; set;}
    global String industry {get; set;}
    global String jobFunction {get; set;}
    global Boolean hasMessages {get; set;}
    global String isGRA {get; set;}
    global Boolean isNewPortal {get; set;}
    
    global String emailForPasswordReset {get; set;}
    global Boolean passwordResetSuccessful {get; set;}
    global Boolean passwordResetEmailNotFound {get; set;}
    global Boolean captchaSuccessful {get; set;}
    
    
    global String action {get; set;}
    global String actionId {get; set;}
    global String start {get; set;}
    
    global String garpGatedUrl {get; set;}
    global String trackCTA {get; set;}
    
    global String gotoParam {get; set;}
    global String redirectParam {get; set;}
    global String returnUrl {get; set;}
    
    global String loginErrMsg {get; set;}
    global Boolean newUser {get; set;}   
    global String regOppId {get; set;}
    
    global List<String> COUNTRIES;
    global List<String> INDUSTRIES;
    global List<String> JOBFUNCTIONS;
    
    global LoginController() {
        action = ApexPages.currentPage().getParameters().get('action');
        actionId = ApexPages.currentPage().getParameters().get('id');

        start = ApexPages.currentPage().getParameters().get('start');
        garpGatedURL = ApexPages.currentPage().getParameters().get('garp_gated_url');
        trackCTA = ApexPages.currentPage().getParameters().get('track_cta');

        gotoParam = ApexPages.currentPage().getParameters().get('goto');
        redirectParam = ApexPages.currentPage().getParameters().get('redirectParam'); //to handle higher logic callback param
        returnUrl = ApexPages.currentPage().getParameters().get('ReturnUrl'); //to handle higher logic callback param

        List<Country_Code__c> ccs = GARP_BC_MemberProfile.getCountries();
        this.COUNTRIES = new List<String>();
        for(Country_Code__c c :ccs) {
            COUNTRIES.add(c.Country__c);
        }
        this.JOBFUNCTIONS = GARP_BC_MemberProfile.getPickListValues('Contact','Job_Function__c');
        this.INDUSTRIES = GARP_BC_MemberProfile.getPickListValues('Contact','Area_of_Concentration__c');
        
        isGRA = 'false';
        String url = ApexPages.currentPage().getUrl();
        if(url != null) {
        url = url.toLowerCase();
            if(url.indexOf('logingra') > -1 || url.indexOf('logingbi') > -1) {
                isGRA = 'true';
            }
        }

        String registerParam = ApexPages.currentPage().getParameters().get('register');
        if (registerParam != null && Boolean.valueOf(registerParam)) {
            newUser = true;
        } else {
            newUser = false; 
        }
        passwordResetSuccessful = false;
        passwordResetEmailNotFound = false;
    }
    
    global PageReference init() {
    
        Apexpages.currentPage().getHeaders().put('X-FRAME-OPTIONS', 'DENY');
    
        username =  ApexPages.currentPage().getParameters().get('username');
        password = ApexPages.currentPage().getParameters().get('password');
        start = ApexPages.currentPage().getParameters().get('start');
        garpGatedURL = ApexPages.currentPage().getParameters().get('garp_gated_url');
        trackCTA = ApexPages.currentPage().getParameters().get('track_cta');

        //debugInfo += '<h1>ALL INCOMING HEADERS</h1>';
        //for (string key: ApexPages.currentPage().getHeaders().keySet()) {
        //    debugInfo += key + ' = ' + ApexPages.currentPage().getHeaders().get(key) + '<br />';
        //}        
        //
        //HTTP_REFERER
        
        String refer = ApexPages.currentPage().getHeaders().get('Referer');
        if(refer != NULL && refer.indexOf('start=GBI') > -1) {
            return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/LoginGBI');
        }
        
        if (ApexPages.currentPage().getHeaders().get('CipherSuite') == null) {
            return new PageReference('https://' + ApexPages.currentPage().getHeaders().get('Host') + '/Login');
        }
        
        if(username != null && password != null) {
            return login();
        } else {   
            return checkIsLoggedIn();
        }
    }
        
    global void logOtherStartPage(String startPage, String flow) {
    
        Map<String,Default_Settings__c> defset = Default_Settings__c.getall();
        Default_Settings__c defsetLogin = defset.get('LogLogin');
        if(defsetLogin != NULL) {
            Boolean logActive = defsetLogin.Active__c;
        
            if(logActive == True) {
        
                AppError__c ae = new AppError__c(Name='Login Log',Message__c=startPage,Error__c=flow);
                insert ae;
            }    
        }
    }

    private Boolean checkIsNewPortal(String startIn) {

        if(startIn != NULL) {

            if(startIn.indexOf('cpd-activities-detail') > -1) {
                return True;
            }
            
            if(startIn.indexOf('registration') > -1) {
                return False;
            } else if(startIn.indexOf('checkout') > -1) {
                return False;
            } else if(startIn.indexOf('errata') > -1) {
                return False;
            } else if(startIn.indexOf('workexperience') > -1) {
                return False;
            } else if(startIn.indexOf('epp') > -1) {
                return False;
            } else if(startIn.indexOf('chapterMeetingRegistrationsAttendance') > -1) {
                return False;
            } else if(startIn.indexOf('cpe_activity') > -1) {
                return False;
            } else if(startIn.indexOf('access_content') > -1 || startIn.indexOf('register_content') > -1) {
                return False;
            }
        }

        return True;
    }
    
    global PageReference checkIsLoggedIn() {
    
        
        String redirectUrl = '';
        String flow = 'checkIsLoggedIn~';
        String username = '';
        
        flow += 'checkIsLoggedIn[' + UserInfo.getUserId() + ']~';
        
        User u = [SELECT Id, Name, IsPortalEnabled, Contact.EPP_Data_Manager__c, Contact.RecordType.Name FROM User WHERE Id = :UserInfo.getUserId()];
        flow += 'checkIsLoggedIn[' + u  + ']~';   
        
        Boolean isEPP = (u.Contact.EPP_Data_Manager__c);
        Boolean isMember = (u.Contact.RecordType.Name == 'Member');
        
        username = u.Name;

        //if(start.IndexOf('cpe_activity%2F') > -1) {
        //    System.Debug('****checkIsLoggedIn CPE Link Mess:' + start);
        //    start = start.replaceAll('%2F','/');
        //    System.Debug('****checkIsLoggedIn CPE Link Fix:' + start);
        //}
        
        // Old v. New Portal
        isNewPortal = checkIsNewPortal(start);
        //isNewPortal = False;

        flow += 'isNewPortal[' + isNewPortal  + ']~';   
        
        if (u.IsPortalEnabled || Test.isRunningTest()) {
            
            String addQueryParams = '';
            if(garpGatedURL != NULL) {
                addQueryParams += '?garp_gated_url=' + EncodingUtil.urlEncode(garpGatedURL, 'UTF-8');
            }
            if(trackCTA != NULL) {
                if(addQueryParams != '') {
                    addQueryParams += '&';
                } else {
                    addQueryParams += '?';
                }
                addQueryParams += 'track_cta=' + trackCTA;
            }

            if(isNewPortal) {
                redirectUrl += '/garpApp' + addQueryParams;
                
                if(start != null) {
                    redirectUrl += '#/' + start;
                } else {
                    redirectUrl += '#/dashboard';
                }
                
            } else {
                redirectUrl += '/sfdcApp' + addQueryParams;
                if(start != null) {
                    redirectUrl += '#!/' + start;
                } else {
                    redirectUrl += '#!/dashboard';
                }
            }

            flow += 'isGRA[' + redirectUrl  + ']~';           
            
            if(isGRA == 'true') {
                redirectUrl = '/gbiapp';
                redirectUrl += start != null ? '#/' + start : '#/studies';   
                
                flow += 'isGRA[' + redirectUrl  + ']~';           
            }
            
            if(isEPP && !isMember) {
                redirectUrl = '/garpEppPortal';
            }
            
            if (action != null) { 
                if (action == 'meeting'){
                    redirectUrl = '/apex/RegisterForMeeting?id=' + actionId;
                } else if (action == 'jobtarget') {
                    redirectUrl = '/apex/RegisterForJobTarget?goto=' + gotoParam;
                } else if (action == 'auth') {
                    redirectUrl = '/apex/redirect?userid=' + u.Id + '&route=' + gotoParam;
                } else if (action == 'eBookFRM') {
                    redirectUrl = '/mobiusRedirect?prod=' + actionId;
                } else if (action == 'benchprep') {                    
                    redirectUrl = '/' + Label.BenchBrepSSOLink;
                }
                flow += 'action != null[' + redirectUrl + ']~';           
            }
            
            if(redirectParam != null){
                redirectUrl = EncodingUtil.urlDecode(redirectParam, 'UTF-8');
                flow += 'redirectParam != null[' + redirectUrl + ']~';           
            }
            
            if(returnUrl != null && returnUrl.indexOf('https://connect.garp.com') > -1) {
                returnUrl = returnUrl.substring(24);
                redirectUrl = '/HLRedirect?ReturnUrl=' + returnUrl;
                
                flow += 'returnUrl != null[' + redirectUrl + ']~';
            }
            
            logOtherStartPage(username, flow) ;

            return new PageReference(redirectUrl);
        }

        logOtherStartPage(username, flow);

        return null;
    }
    
    global PageReference login() {
    
        String flow = 'login~';

        // Old v. New Portal
        isNewPortal = checkIsNewPortal(start);
        //isNewPortal = False;

        String redirectUrl = '';
        String addQueryParams = '';
        
        if(garpGatedURL != NULL) {
            addQueryParams += '?garp_gated_url=' + EncodingUtil.urlEncode(garpGatedURL, 'UTF-8');
        }
        if(trackCTA != NULL) {
            if(addQueryParams != '') {
                addQueryParams += '&';
            } else {
                addQueryParams += '?';
            }
            addQueryParams += 'track_cta=' + trackCTA;
        }

        if(isNewPortal) {
            redirectUrl += '/garpApp' + addQueryParams;
            
            if(start != null) {
                redirectUrl += '#/' + start;
            } else {
                redirectUrl += '#/dashboard';
            }
            
        } else {
            redirectUrl += '/sfdcApp' + addQueryParams;
            if(start != null) {
                redirectUrl += '#!/' + start;
            } else {
                redirectUrl += '#!/dashboard';
            }
        }

        flow += 'redirectUrl[' + redirectUrl  + ']~';
        
        if(isGRA == 'true') {
            redirectUrl = '/gbiapp';
            redirectUrl += start != null ? '#/' + start : '#/studies';    
            
            flow += 'isGRA[' + redirectUrl  + ']~';                   
        }
        
        if(redirectParam != null) {
            redirectUrl = EncodingUtil.urlDecode(redirectParam, 'UTF-8');
            
            flow += 'redirectParam != null[' + redirectUrl + ']~';           
        }

        flow += 'Login Action2:' + action + ':' + actionId + ':' + start + ':' + gotoParam + ':' + redirectParam + ':' + returnUrl + ':' + isGRA + ':' + redirectUrl + ':' + username + '~';   
        
        System.PageReference retLogin;

        List<User> lstUser = [Select Id, ContactId from User where username = :username];
        if( (lstUser != null && lstUser.size() > 0) || Test.isRunningTest() ) {
            //String contactId = lstUser[0].ContactId;
            
            List<Contact> lstContact;
            Boolean hasMemberContract = False;
            Boolean isValidEPP = False;
            if(Test.isRunningTest()) {
                lstContact = [SELECT Id, AccountId, Account.recordType.DeveloperName, Name, Last_Login_Start__c, Last_Login_Count__c, GBI_Participant__c, EPP_Data_Manager__c FROM Contact WHERE email = 'Test@Test.com'];    
                
            } else {
                lstContact = [SELECT Id, AccountId, Account.recordType.DeveloperName, Name, Last_Login_Start__c, Last_Login_Count__c, GBI_Participant__c, EPP_Data_Manager__c FROM Contact WHERE Id = :lstUser[0].ContactId];
            }

            flow += 'Login lstContact :' + lstContact  + '~';
             
            if( lstContact != null && lstContact.size() > 0 ) {
            
                Contact con = lstContact[0];
                
                List<Contract> lstContracts = [SELECT Id from Contract where AccountId = :con.AccountId AND recordType.DeveloperName = 'Membership' AND status in ('Activated','Activated ( Auto-Renew )','Expired')];

                if(!lstContracts.IsEmpty() && con.Account.recordType.DeveloperName == 'Individual') {
                    hasMemberContract = True;
                }

                if(con.EPP_Data_Manager__c) {
                    List<EPP_Account__c> eppList = [select id, EPP_Registration_Status__c from EPP_Account__c where Primary_EPP_Contact__c = :con.Id AND EPP_Registration_Status__c = 'Approved'];

                    if(!eppList.IsEmpty()) {
                        isValidEPP = True;
                    }
                }

                if (action != null) {
                    if (action == 'meeting') {
                        redirectUrl = '/apex/RegisterForMeeting?id=' + actionId;
                    } else if (action == 'jobtarget') {
                        redirectUrl = '/apex/RegisterForJobTarget?goto=' + gotoParam;
                    } else if (action == 'auth') {
                        redirectUrl = '/apex/redirect?userid=' + lstUser[0].Id + '&route=' + gotoParam;
                    } else if (action == 'eBookFRM') {
                        redirectUrl = '/mobiusRedirect?prod=' + actionId;
                    } else if (action == 'benchprep') {                    
                        redirectUrl = '/' + Label.BenchBrepSSOLink;
                    }
                    flow += 'action != null[' + redirectUrl + ']~';
                }

                if(returnUrl != null && returnUrl.indexOf('https://connect.garp.com') > -1) {
                    returnUrl = returnUrl.substring(24);
                    redirectUrl = '/HLRedirect?ReturnUrl=' + returnUrl;
                    
                    flow += 'returnUrl != null[' + redirectUrl + ']~';
                }

                flow += 'redirectUrl[' + redirectUrl + ']~';                                         
                                               
                Decimal cnt = con.Last_Login_Count__c;
                if(cnt == null) {
                    con.Last_Login_Count__c=0;
                }

                flow += 'Last_Login_Count__c[' + con.Last_Login_Count__c+ ']~';
                
                // For GBI Login, User Contact needs to have GBI_Participant__c checked
                if(isGRA == 'true' && !con.GBI_Participant__c) {
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You are not able to login at this time. Please contact your administrator for support.'));
                    hasMessages = true;
                    password = null;
                    
                    flow += 'GBI Login failre[' + isGRA + ']~';   
                    logOtherStartPage(username, flow);
                    return null;
                    
                } else if(!hasMemberContract && con.GBI_Participant__c) {
                    redirectUrl = '/gbiapp#/studies';
                    
                    flow += 'Redirect to GBI Login, non-member but GBI~';   
                    logOtherStartPage(username, flow);
                    
                } else if(!hasMemberContract && con.EPP_Data_Manager__c && isValidEPP) {
                    redirectUrl = '/garpEppPortal';
                
                    flow += 'Redirect to EPP Login, non-member but EPP~';   
                    logOtherStartPage(username, flow);
                    
                } else if(!hasMemberContract) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'You are not able to login at this time. Please contact your administrator for support.'));
                    hasMessages = true;
                    password = null;
                    
                    flow += 'No member Login failure~';   
                    logOtherStartPage(username, flow);
                    return null;
                }

                retLogin = Site.login(username, password, redirectUrl);
                
                flow += 'retLogin [' + retLogin + ']~';  
                
                if(retLogin != null || Test.isRunningTest()) {
                    //con.Last_Day_of_Login__c = datetime.now();
                    
                    if(con.Last_Login_Start__c == NULL) {
                        con.Last_Login_Count__c = 1;
                        con.Last_Login_Start__c = datetime.now();
                    } else {
                        DateTime nowDT = system.now();
                        DateTime loginDT = con.Last_Login_Start__c;
                        Decimal diff = ((nowDT.getTime())/1000/60/60) - ((loginDT.getTime())/1000/60/60); 
                        if(diff < 1) {
                            cnt++;
                            con.Last_Login_Count__c=cnt;
                        } else {
                            con.Last_Login_Start__c=nowDT;
                            con.Last_Login_Count__c = 1;
                        }
                    }
                    flow += 'update con[' + con + ']~';  
                    update con;
                    
                    if(con.Last_Login_Count__c > 20) {
                        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'You are not able to login at this time. You have made too many attempt in the last hour. Please try again later.');
                        ApexPages.addMessage(myMsg);
                        //lstContact[0].Last_Login_Count__c.addError('Required field.');
                        hasMessages=true;
                        password=null;
                        
                        flow += 'Last_Login_Count__ct[' + con.Last_Login_Count__c + ']~'; 
                        return null;
                    } else {

                        if(redirectParam != NULL) {
                            return new PageReference(redirectUrl);
                        }
                    }
                    
                }
            } else {
                retLogin = Site.login(username, password, redirectUrl);
                flow += 'retLogin2 [' + retLogin + ']~';
            }
        } else {
            retLogin = Site.login(username, password, redirectUrl);
            flow += 'retLogin3 [' + retLogin + ']~';
        }

        logOtherStartPage(username, flow);

        return retLogin;
    }
    
    global PageReference resetPassword() {
       // List<User> u = [SELECT Id,username, Email FROM User WHERE username = :emailForPasswordReset AND IsPortalEnabled=true];
       List<User> u = [SELECT Id, Email FROM User WHERE Username = :emailForPasswordReset AND IsPortalEnabled=true];
        if (u.isEmpty()) {
            passwordResetEmailNotFound = true;
        } else {
            passwordResetSuccessful = Site.forgotPassword(emailForPasswordReset);
            passwordResetSuccessful=true;
        }       
        return null;
    }
    
    global PageReference resetPasswordResetSuccessful() {
        passwordResetSuccessful = false;
        passwordResetEmailNotFound = false;
        return null;
    }
    
    global Boolean getHasErrors() {
        return ApexPages.hasMessages(ApexPages.Severity.Error);
    }
}