/**
* Class ExamRegistrationsStatusCls
* 
* recordid: 'Exam Registrations'(Exam_Attempt__c) Record Id
* firstname: Pearson_Member_First_Name__c if no change null value
* lastname:Pearson_Member_Last_Name__c if no change null value
* middlename:Pearson_Member_Middle_Name__c if no change null value
* reTryError:revalidate when Status is "Error: then reTryError is true 
*/

public class ExamRegistrationsStatusCls {
     
    public static string updateRegistration(String recordid,Boolean reTry){
        try{
            List<Exam_Attempt__c> examList = [Select Id,Member__r.Name_as_it_Appears_on_ID__c,Member__r.ID_Number__c,Member__r.ID_Type__c,Active_Integration_Data__c,Member__r.First_Name_as_it_Appears_on_ID__c,Member__r.Last_Name_as_it_Appears_on_ID__c,
                                              Outbound_Status__c,Outbound_Type__c,Member__r.Middle_Name_as_it_Appears_on_ID__c,
                                              Integration_Type__c,RPT_Exam_Provider__c,Pearson_Member_First_Name__c,Pearson_Member_Last_Name__c,
                                              Pearson_Member_Middle_Name__c From Exam_Attempt__c Where Id =:recordid];
            System.Debug('ExamRegistrationsStatusCls:updateRegistration:examList'+examList);
            
            if(examList.size() > 0){
                Exam_Attempt__c ea = new Exam_Attempt__c();
                ea = examList[0]; 
                
                System.Debug('ExamRegistrationsStatusCls:updateRegistration:reTryError'+reTry);
                System.Debug('ExamRegistrationsStatusCls:updateRegistration:Outbound_Status__c'+ea.Outbound_Status__c);
                
                if(ea.Active_Integration_Data__c != null && (ea.Outbound_Status__c == null || ea.Outbound_Status__c != 'Processed')) {
                    ea.Outbound_Status__c = 'Processed';
                    ExamAttemptHandler.stopRecurssion = false;
                    System.Debug('ExamRegistrationsStatusCls:update EA Status:'+ea);
                    update ea;
                }else{
                    
                    System.Debug('No Active_Integration_Data and Outbound_Status:'+ea);
                    
                    if(ea.Integration_Type__c != null && ea.Outbound_Status__c == 'Initiated' && reTry == true){
                        ea.Integration_Type__c ='';
                        ea.Outbound_Type__c = '';
                        ExamAttemptHandler.stopRecurssion = false;
                        update ea;
                        
                        if(ea.RPT_Exam_Provider__c == 'PSI') {
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Eligibility Lifecycle'; 
                        } else if(ea.RPT_Exam_Provider__c == 'ATA') {
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Import Registration New'; 
                        } else if(ea.RPT_Exam_Provider__c == 'Pearson') {
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Ping Database;CDD;EAD'; 
                        } 
                        ExamAttemptHandler.stopRecurssion = true;
                        update ea;
                    }
                    if((reTry == true && ea.Outbound_Status__c == 'Error') || ea.Outbound_Status__c == null){
                        if(ea.RPT_Exam_Provider__c == 'PSI') {
                            ea.ATA_Cert_Type__c = ea.Member__r.ID_Type__c;
                            ea.ATA_Cert_id__c = ea.Member__r.ID_Number__c;
                            ea.ATA_Name_as_it_appears_on_ID__c = ea.Member__r.Name_as_it_Appears_on_ID__c;
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Eligibility Lifecycle'; 
                        } else if(ea.RPT_Exam_Provider__c == 'ATA') {
                            ea.ATA_Cert_Type__c = ea.Member__r.ID_Type__c;
                            ea.ATA_Cert_id__c = ea.Member__r.ID_Number__c;
                            ea.ATA_Name_as_it_appears_on_ID__c = ea.Member__r.Name_as_it_Appears_on_ID__c;
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Import Registration New'; 
                        } else if(ea.RPT_Exam_Provider__c == 'Pearson') {
                            ea.Pearson_Member_First_Name__c = ea.Member__r.First_Name_as_it_Appears_on_ID__c;
                            ea.Pearson_Member_Last_Name__c = ea.Member__r.Last_Name_as_it_Appears_on_ID__c != null?ea.Member__r.Last_Name_as_it_Appears_on_ID__c:'.';
                            ea.Pearson_Member_Middle_Name__c = ea.Member__r.Middle_Name_as_it_Appears_on_ID__c;
                            ea.Outbound_Type__c = ea.RPT_Exam_Provider__c;
                            ea.Integration_Type__c = 'Ping Database;CDD;EAD'; 
                        } 
                        System.Debug('ExamRegistrationsStatusCls:updateRegistration:Set Outbound_Type__c'+ea.Outbound_Type__c);
                        System.Debug('ExamRegistrationsStatusCls:updateRegistration:Set Integration_Type__c'+ea.Integration_Type__c);
                        
                        
                        ea.Outbound_Status__c = 'Initiated';
                        update ea;   
                    } 
                }
                return ea.Outbound_Status__c;
            } 
            return 'Exam Attempt Not Found';
        }Catch(Exception e){
            system.debug(e.getmessage());
            return 'Exception';
        }
    }
}