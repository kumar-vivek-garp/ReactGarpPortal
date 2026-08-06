public class TriggerUtil {
    public static Map<String,String> triggerConfigurations(String ObjectName){
        system.debug('TriggerUtil  triggerConfigurations  ObjectName::>>  '+ObjectName);
        Map<String,String> triggerSettings = new Map<String,String>();
        for(Trigger_Configuration__mdt tc : [SELECT Skip_for_Before_Insert__c,Skip_for_Before_Update__c,Skip_for_User__c,
                                             Skip_for_Before_Delete__c,Skip_for_After_Insert__c,Skip_for_After_Update__c,Skip_for_After_Delete__c
                                             FROM Trigger_Configuration__mdt WHERE isActive__c = true AND Object_Name__c =: ObjectName]){
                                                 
                                                 triggerSettings.put('Users_To_Skip', tc.Skip_for_User__c);
                                                 
                                                 String Skip_for_Before_Insert = tc.Skip_for_Before_Insert__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_Before_Insert', Skip_for_Before_Insert);
                                                 
                                                 String Skip_for_Before_Update = tc.Skip_for_Before_Update__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_Before_Update', Skip_for_Before_Update);
                                                 
                                                 String Skip_for_Before_Delete = tc.Skip_for_Before_Delete__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_Before_Delete', Skip_for_Before_Delete);
                                                 
                                                 String Skip_for_After_Insert = tc.Skip_for_After_Insert__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_After_Insert', Skip_for_After_Insert);
                                                 
                                                 String Skip_for_After_Update = tc.Skip_for_After_Update__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_After_Update', Skip_for_After_Update);
                                                 
                                                 String Skip_for_After_Delete = tc.Skip_for_After_Delete__c ? 'True' : 'False';
                                                 triggerSettings.put('Skip_for_After_Delete', Skip_for_After_Delete);
                                             }
        system.debug('TriggerUtil   triggerConfigurations  triggerSettings::>>  '+triggerSettings);
        return triggerSettings;
    }
}