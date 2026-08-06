public class GenerateStudyImportFile {
    
    public Id studyId {get; set;}
    
    public class UserWrapper {
        public string LoginID {get; set;}
        public string PasswordEncryptMode {get; set;}
        public string PasswordUTF8{get; set;}
        public string RequirePasswordChange{get; set;}
        public string Password {get; set;}
        public string FullName{get; set;}
        public string EmailAddress {get;set;}
        public string HomeDir {get;set;}
        public string WebClientStartupMode{get;set;}
        public string DirAccess {get;set;}
        public string ExpiresOn {get;set;}
    }  
    
    public List<UserWrapper> userWrapperList {get; set;}
    
    public GenerateStudyImportFile() {
        
        // Get study ID from GET param
        studyId = ApexPages.currentPage().getParameters().get('studyId');
        
        // Create wrapp list to add values to expose to VF page
        userWrapperList = new List<UserWrapper>();
        
    }
    
    public static String generatePassword() {
        String password='';
        Integer cnt=1;
        
        MAP<Integer, Boolean> mapInvalidChars = new MAP<Integer, Boolean>();
        mapInvalidChars.put(34,False);
        mapInvalidChars.put(39,False);
        mapInvalidChars.put(40,False);
        mapInvalidChars.put(41,False);
        mapInvalidChars.put(44,False);
        mapInvalidChars.put(46,False);
        mapInvalidChars.put(47,False);
        mapInvalidChars.put(58,False);
        mapInvalidChars.put(59,False);
        mapInvalidChars.put(60,False);
        mapInvalidChars.put(61,False);
        mapInvalidChars.put(62,False);
        mapInvalidChars.put(91,False);
        mapInvalidChars.put(92,False);
        mapInvalidChars.put(93,False);
        mapInvalidChars.put(95,False);
        mapInvalidChars.put(96,False);
        
        // Loop Until we have 12 valid characters 
        While(cnt < 12) {
            
            // In case this goes forever only try so many times - make sure we do not have a closed loop
            Integer trys = 0;
            Boolean done=false;
            Double rnd;
            
            // Try 100 times to get a valid passowrd
            while(trys < 100 && done == False) {
                
                // Gen a random number for password char
                rnd = Math.floor(Math.random() * ((122-35)+1) + 35);
                
                // See if it is invalid - if so try again
                done = mapInvalidChars.get(Integer.valueOf(rnd));
                trys++;
            }
            
            // Compute char from number
            String myChar = String.fromCharArray( new List<integer> { Integer.valueOf(rnd) } );
            
            // Append to password
            password = password + myChar;
            cnt++;
        }
        return password;
    }    
    
    public void loadAccounts() {
        
        // If there was an ID passed continue
        system.debug('studyId:' + studyId);
        if(studyId != null){
            
            // Look up data from Study Accounts based on ID passed
            List<Study_Account__c> lstSA = [select Id, Name, Status__c, Secure_File_Platform__c, Study_Account_ID__c, Serv_U_Username__c, Study__r.Status__c, Study__r.Secure_File_Integration_Status__c, Study__r.Study_ID__c, Account__c from Study_Account__c where Study__c = :studyId AND Status__c = 'Active' and Study__r.Secure_File_Integration_Status__c = 'Enabled' AND Secure_File_Platform__c includes ('Serv-U')];
            
            // If Study Account found continue
            if(lstSA.size() > 0) {
                
                // Define Expire Date
                Date expDate = Date.today().addDays(90);
                DateTime expDateTime = DateTime.newInstance(expDate.Year(), expDate.Month(), expDate.Day());
                Long epochExpDate = expDateTime.getTime() / 1000;
                System.debug('epochExpDate:' + epochExpDate);
                
                // For each Study Account in the Study ID passed add a wrapper item to the list
                for(Study_Account__c sa :lstSA) {
                    userWrapper uw =new UserWrapper();
                    uw.LoginID = sa.Serv_U_Username__c;
                    uw.PasswordEncryptMode = '';
                    uw.PasswordUTF8 = '1';
                    uw.RequirePasswordChange = '1';
                    uw.Password = generatePassword();
                    uw.FullName = sa.Name;
                    uw.EmailAddress = 'ftp-notifications@garp.com';
                    uw.HomeDir = '//amznfsxoin1rtgk.GBINJ.GARP.COM/Share/Research/ServU/' + sa.Study__r.Study_ID__c + '/' + sa.Account__c;
                    uw.WebClientStartupMode = '0';
                    uw.DirAccess = '1,4,Dir,' + uw.HomeDir + ',Access,4359';   
                    uw.ExpiresOn = String.valueOf(epochExpDate);
                    userWrapperList.add(uw);
                }
            }            
        }
        
    }
    
}