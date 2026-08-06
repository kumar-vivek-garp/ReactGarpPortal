public class LWC_StreamingApiController {
 @AuraEnabled(cacheable = false)
    public static string getSessionId() {
        return UserInfo.getSessionId();
    }
}