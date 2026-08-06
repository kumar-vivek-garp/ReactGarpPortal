public class ON24EngagementHubEmployeeSSO {

    Pagereference page = new pagereference('https://www.garp.org/#!/404');

    public pagereference ON24EngagementHubEmployeeSSO() {
    
        List<User> users = [SELECT Id,Email, Name,Access_On24__c,Profile.UserLicense.Name,IsActive  FROM User WHERE Id = :UserInfo.getUserId()];
        System.Debug('users:' + users);
        
        if(!users.isEmpty() && users[0].Profile.UserLicense.Name == 'Salesforce'
            && users[0].IsActive == true) { 
               // String userId 
               system.debug('Entered to call On24API');
               String response = on24API.createON24EngagementHubRegistrationForEmployee(users[0].Id); 
                if(response == '200'){
                    String accountEmail = users[0].Email;
                    String sredir = 'https://gateway.on24.com/wcc/login?eventId=2960348&sessionid=1&key=67B583B1ACBD79DE9C7AC600CA57A098&email=' + accountEmail + '&targetUrl=';
                    System.Debug('sredir:' + sredir);
                    page = new pagereference(sredir);
                }
        }    
        return page;
    }
    
}