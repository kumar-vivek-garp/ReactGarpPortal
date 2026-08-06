/**
 * An apex page controller that supports self registration of users in communities that allow self registration
 */
public with sharing class CommunitiesSelfRegController {

    public String firstName {get; set;}
    public String lastName {get; set;}
    public String email {get; set;}
    public String password {get; set {password = value == null ? value : value.trim(); } }
    public String confirmPassword {get; set { confirmPassword = value == null ? value : value.trim(); } }
    public String communityNickname {get; set { communityNickname = value == null ? value : value.trim(); } }
    
    public CommunitiesSelfRegController() {}
    
    private boolean isValidPassword() {
        return password == confirmPassword;
    }

    public PageReference registerUser() {
        return null;    
    }
}