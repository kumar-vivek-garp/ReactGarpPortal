global without sharing class reportsGARP {
    
    public reportsGARP() { 
    }
    
    @RemoteAction
    public static List<Deployment__c> getDeploymentData(Integer month, Integer year) {
        
        List<Deployment__c> lstDeployments;
        
        lstDeployments = [select Id, Name, Target_Deployment_Date__c, Target_Deployment_Time__c, Type__c, Email_Recipient_Size__c from Deployment__c where 
                          CALENDAR_YEAR(Target_Deployment_Date__c) = :year and CALENDAR_MONTH(Target_Deployment_Date__c) = :month];
        
        return lstDeployments;
    }
       
    
    
    
}