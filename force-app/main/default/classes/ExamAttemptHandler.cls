/**
* Class ExamAttemptHandler
*
* Trigger Handler for the 'Exam Registrations'(Exam_Attempt__c) SObject. This class implements the TriggerAbstract
* interface to help ensure the trigger code is bulkified and all in one place.
*/
public without sharing class ExamAttemptHandler implements TriggerAbstract {
    
    static Map<Id,Exam_Attempt__c> mapEA = new Map<Id,Exam_Attempt__c>();
    static Map<Id,Exam_Attempt__c> contactExamAttemptMap = new Map<Id,Exam_Attempt__c>();
    static List<Contact> ContactList = new List<Contact>();
    static List<String> ExamSiteIdList = new List<String>();
    static Map<Id,Exam_Sites__c> ExamSitesMap = new Map<Id,Exam_Sites__c>();
    static List<Exam_Attempt__c> lstExamAttempt = new List<Exam_Attempt__c>();
    static List<Exam_Attempt__c> resultChangedList = new List<Exam_Attempt__c>();
    static List<Contact_Update_Event__e> contUpdEvts = new List<Contact_Update_Event__e>();
    static List<Contract> ContractList = new List<Contract>();
    static Map<Id,Contact> contactMap = new Map<Id,Contact>();
    static Map<Id,Exam_Attempt__c> part1ContactExamMap = new Map<Id,Exam_Attempt__c>();
    public static boolean stopRecurssion = true;
    
    // Constructor
    public ExamAttemptHandler(){}
    
    /**
* bulkBefore
* This method is called prior to execution of a BEFORE trigger. Use this to cache
* any data required into maps prior execution of the trigger.
*/
    public void bulkBefore() {
        if(stopRecurssion){
            if(!trigger.isDelete){
                Set<Id> contactIds = new Set<Id>();
                Set<Id> examresultIds = new Set<Id>();
                for(Exam_Attempt__c newExamAttempt : (List<Exam_Attempt__c>)trigger.New){
                    ExamSiteIdList.add(newExamAttempt.Exam_Site__c);
                    if(newExamAttempt.Member__c != null){
                        contactIds.add(newExamAttempt.Member__c);
                    } 
                    
                    if(newExamAttempt.Result__c == 'Pass' && (newExamAttempt.Exam_Type__c == 'FRM Part II' || newExamAttempt.Exam_Type__c == 'FRM Part 2')){
                        examresultIds.add(newExamAttempt.Member__c);
                    }
                    
                }
                
                for(Exam_Sites__c es : [SELECT Id,Name FROM Exam_Sites__c WHERE ID IN:ExamSiteIdList]){
                    ExamSitesMap.put(es.Id,es);
                }
                
                if(!contactIds.isEmpty() && trigger.isInsert){
                    List<Contact> contactList = [Select Id,Email,First_Name_as_it_Appears_on_ID__c,Middle_Name_as_it_Appears_on_ID__c,Last_Name_as_it_Appears_on_ID__c,Phone,
                                                  Account.BillingStreet,Account.BillingCity,Account.BillingState,Account.BillingCountry,Account.BillingPostalCode,Name_as_it_Appears_on_ID__c,
                                                 ID_Type__c,ID_Number__c
                                                  from Contact where Id IN: contactIds];
                    for(Contact con : contactList){
                        contactMap.put(con.Id,con);
                    }
                }
                
                if(examresultIds.size() > 0){
                    for(Exam_Attempt__c ea:[Select Id,Member__c From Exam_Attempt__c Where Member__c In:examresultIds And (Exam_Type__c = 'FRM Part I' OR Exam_Type__c = 'FRM Part 1')  And Result__c = 'Pass']){
                        part1ContactExamMap.put(ea.Member__c,ea);
                    }
                }
            }
        }
    }
    
    public void bulkAfter(){
        //system.debug('**********In ExamAttemptHandler bulkAfter*******  ');
        Set<String> ContractIdSet = new Set<String>(); 
        if(stopRecurssion){
            if(!trigger.isDelete){
                //system.debug('     <<::  bulkAfter  trigger.oldMap ::>>   '+trigger.oldMap);
                if(trigger.oldMap != null){
                    for(Exam_Attempt__c newExamAttempt : (List<Exam_Attempt__c>)trigger.New){
                        Exam_Attempt__c oldExamAttempt = (Exam_Attempt__c)trigger.oldMap.get(newExamAttempt.Id);
                        //system.debug('bulkAfter  newExamAttempt 1::>>   '+newExamAttempt.Candidate_Commitment__c+'  ==  '+newExamAttempt.Section__c+'   ++   '+newExamAttempt.Result__c);
                        //system.debug('bulkAfter  newExamAttempt 2::>>   '+oldExamAttempt.Candidate_Commitment__c+'  ==  '+oldExamAttempt.Section__c+'   ++   '+oldExamAttempt.Result__c);
                        if(newExamAttempt.Candidate_Commitment__c != null && newExamAttempt.Section__c == 'ICBRR' && newExamAttempt.Result__c != Null && newExamAttempt.Result__c != 'Pass' && String.isBlank(oldExamAttempt.Result__c)){
                            ContractIdSet.add(newExamAttempt.Candidate_Commitment__c);
                        }
            
                    }
                }
                //system.debug(ContractIdSet.size()+'     <<::  bulkAfter  ContractIdSet ::>>   '+ContractIdSet);
                if(ContractIdSet.size() > 0){
                    ContractList = [SELECT Id,Status FROM Contract WHERE Id IN: ContractIdSet LIMIT 40000];
                }
                 
                //system.debug(ContractList.size()+'     <<::  bulkAfter  ContractList ::>>   '+ContractList);
            }
        }
    }
    public void beforeInsert(SObject so){
        //system.debug('**********In ExamAttemptHandler beforeInsert*******  ');
        Exam_Attempt__c newExamAttempt = (Exam_Attempt__c)so;
        if(stopRecurssion){
            newExamAttempt.Outbound_Status__c = '';
            //Switch Date WF
            if(String.isNotBlank(newExamAttempt.Cancel_Reason__c) && newExamAttempt.Cancel_Reason__c.contains('switch,Switch')){
                newExamAttempt.Switch_Date__c = System.Today();
            }
            
            //Update Nov2015 Result Field WF
            if(newExamAttempt.Result_Test__c ){
                newExamAttempt.Nov2015_Result__c = newExamAttempt.Exam_Results_Unique__c;
            }
            
            //Last Time ICBRR Auth Status Changed WF
            if(String.isNotBlank(newExamAttempt.ICBRR_Authorization_Status__c )){
                newExamAttempt.ICBRR_Authorization_Status_Changed_Date__c = System.Now();
            }
            
            //Last Time ICBRR Status Changed WF
            if(String.isNotBlank(newExamAttempt.ICBRR_Submission_Status__c )){
                newExamAttempt.ICBRR_Submission_Status_Changed_Date__c = System.Now();
            }
            
            //Set Orig Site WF
            if(String.isNotBlank(newExamAttempt.Exam_Name__c) && String.isBlank(newExamAttempt.Original_Exam_Site__c)){
                newExamAttempt.Original_Exam_Site__c = ExamSitesMap.get(newExamAttempt.Exam_Site__c).Name;
            }
            processBeforeInsertAndUpdate(newExamAttempt);
            updatePearsonFields(newExamAttempt); 
            updateATAFields(newExamAttempt); //Update ATA Values
        }
    }
    
    public void beforeUpdate(SObject oldSo, SObject so){
        //system.debug('**********In ExamAttemptHandler beforeUpdate*******  ');
        Exam_Attempt__c newExamAttempt = (Exam_Attempt__c)so;
        Exam_Attempt__c oldExamAttempt = (Exam_Attempt__c)oldSo;
        //Part 2 can’t be “Pass” unless Part 1 is already “Pass.”
        if(!Test.isRunningTest() && (newExamAttempt.Exam_Type__c == 'FRM Part II' || newExamAttempt.Exam_Type__c == 'FRM Part 2') && oldExamAttempt.Result__c != newExamAttempt.Result__c && newExamAttempt.Result__c == 'Pass' && !part1ContactExamMap.containsKey(newExamAttempt.Member__c)){
            newExamAttempt.addError('Part 2 can’t be “Pass” unless Part 1 is already “Pass.”');
        }
        if(stopRecurssion){
            //Switch Date WF
            if(String.isNotBlank(newExamAttempt.Cancel_Reason__c) && newExamAttempt.Cancel_Reason__c.contains('switch,Switch') && newExamAttempt.Cancel_Reason__c != oldExamAttempt.Cancel_Reason__c){
                newExamAttempt.Switch_Date__c = System.Today();
            }
            
            //Update Nov2015 Result Field WF
            if(newExamAttempt.Result_Test__c && newExamAttempt.Result_Test__c != oldExamAttempt.Result_Test__c){
                newExamAttempt.Nov2015_Result__c = newExamAttempt.Exam_Results_Unique__c;
            }
            
            //Last Time ICBRR Auth Status Changed WF
            if(newExamAttempt.ICBRR_Authorization_Status__c != oldExamAttempt.ICBRR_Authorization_Status__c){
                newExamAttempt.ICBRR_Authorization_Status_Changed_Date__c = System.Now();
            }
            
            //Last Time ICBRR Status Changed WF
            if(newExamAttempt.ICBRR_Submission_Status__c != oldExamAttempt.ICBRR_Submission_Status__c){
                newExamAttempt.ICBRR_Submission_Status_Changed_Date__c = System.Now();
            }
            
            //Set Orig Site WF
            if(String.isNotBlank(newExamAttempt.Exam_Name__c) && String.isBlank(newExamAttempt.Original_Exam_Site__c)){
                newExamAttempt.Original_Exam_Site__c = ExamSitesMap.get(newExamAttempt.Exam_Site__c).Name;
            }
            
            if(newExamAttempt.Result__c != oldExamAttempt.Result__c){
                resultChangedList.add(newExamAttempt);
            }
            processBeforeInsertAndUpdate(newExamAttempt);
        }
    }
    
    public void beforeDelete(SObject so){
        // Cast the SObject to an Exam_Attempt__c
        //system.debug('**********In ExamAttemptHandler beforeDelete*******  ');
        
    }
    
    public void afterInsert(SObject so){
        //system.debug('**********In ExamAttemptHandler afterInsert*******  ');
    }
    
    public void afterUpdate(SObject oldSo, SObject so){
        //system.debug('**********In ExamAttemptHandler afterUpdate*******  ');
        Exam_Attempt__c newExamAttempt = (Exam_Attempt__c)so;
        Exam_Attempt__c oldExamAttempt = (Exam_Attempt__c)oldSo;
        if(stopRecurssion){
            onUpdate(newExamAttempt,oldExamAttempt);
        }
    }
    
    public void afterDelete(SObject so){
        //system.debug('**********In ExamAttemptHandler afterDelete*******  ');
    }
    
    /**
* andFinally
*
* This method is called once all records have been processed by the trigger. Use this
* method to accomplish any final operations such as creation or updates of other records.
*/
    public void andFinally(){
        if(!trigger.isDelete && stopRecurssion){
            if(trigger.isAfter && trigger.isUpdate){
                stopRecurssion = false;
                system.debug(mapEA);
                if(!mapEA.isEmpty()){
                    ExamAttemptHandlerHelper.updateCandidateRequirement(mapEA,(List<Exam_Attempt__c>)trigger.new,(Map<Id,Exam_Attempt__c>)trigger.oldMap);
                }
                ExamAttemptHandlerHelper.callExamRegistrationHandlerClass((List<Exam_Attempt__c>)trigger.new,(Map<Id,Exam_Attempt__c>)trigger.oldMap);
                PearsonRegHandlerClass.createPearsonVueRequests((List<Exam_Attempt__c>)trigger.new,(Map<Id,Exam_Attempt__c>)trigger.oldMap);
                
                if(!resultChangedList.isEmpty() && !ExamRegistrationHandlerClass.isCreateRateRecursive){
                    ExamRegistrationHandlerClass.createRateOffering(resultChangedList,(Map<Id,Exam_Attempt__c>)trigger.oldMap);
                }
                
                //Publish platform events to update contacts
                if(!contUpdEvts.isEmpty()){
                    Eventbus.publish(contUpdEvts);
                }
                
                //system.debug(ContractList.size()+'     <<::  andFinally  ContractList ::>>   '+ContractList);
                if(ContractList.size() > 0){
                    updateContractStatus(ContractList);
                }
            }
        }
    }
    
    public void processBeforeInsertAndUpdate(Exam_Attempt__c newExamAttempt){
        if(!string.isBlank(newExamAttempt.Additional_Accommodations__c)){
            newExamAttempt.HasAccommodations__c = true;
        }else if(string.isBlank(newExamAttempt.Additional_Accommodations__c)){
            newExamAttempt.HasAccommodations__c = false;
        }
    }
     public static Map<String,Pearson_Exam_Series_Configuration__mdt> PearsonSectionTypeConfigMap = IntegrationsMtdUtil.getBySectionConfiguration();
    public void updatePearsonFields(Exam_Attempt__c ea){ //Chinnapa
        //if(ea.Member__c != null && (ea.Section__c == 'SCR' || ea.Section__c == 'RiskAI' || ea.Section__c == 'ICBRR') && contactMap.containskey(ea.Member__c)){
        if(ea.Member__c != null && PearsonSectionTypeConfigMap.containskey(ea.Section__c) && contactMap.containskey(ea.Member__c)){
            Contact con = contactMap.get(ea.Member__c);
            ea.Pearson_Email__c = con.Email;
            if(String.isNotBlank(con.First_Name_as_it_Appears_on_ID__c)){
                ea.Pearson_Member_First_Name__c = con.First_Name_as_it_Appears_on_ID__c;
            }
            if(String.isNotBlank(con.Middle_Name_as_it_Appears_on_ID__c)){
                ea.Pearson_Member_Middle_Name__c = con.Middle_Name_as_it_Appears_on_ID__c;
            }
            if(String.isNotBlank(con.Last_Name_as_it_Appears_on_ID__c)){
                ea.Pearson_Member_Last_Name__c = con.Last_Name_as_it_Appears_on_ID__c;
            }
            ea.Pearson_Phone_No__c = con.Phone;
            ea.Billing_Street__c = con.Account.BillingStreet;
            ea.Billing_City__c = con.Account.BillingCity;
            ea.Billing_State__c = con.Account.BillingState;
            ea.Billing_Country__c = con.Account.BillingCountry;
            ea.Billing_Postal_Code__c = con.Account.BillingPostalCode;
        }
    }
    
     public void updateATAFields(Exam_Attempt__c ea){ //Chinnapa 
        if(ea.Member__c != null && contactMap.containskey(ea.Member__c)){            
            Contact con = contactMap.get(ea.Member__c);
            if(con.Name_as_it_Appears_on_ID__c != null){
                if(ea.ATA_region_code__c != null){
                    ea.ATA_Cert_Type__c = con.ID_Type__c;
                    ea.ATA_Cert_id__c = con.ID_Number__c;
                } 
                ea.ATA_Name_as_it_appears_on_ID__c = con.Name_as_it_Appears_on_ID__c;
            }
        }
    }
    
    public void onUpdate(Exam_Attempt__c newExamAttempt, Exam_Attempt__c oldExamAttempt){
        //system.debug('**********In ExamAttemptHandler andFinally*******   ');
        //system.debug(oldExamAttempt.Result__c+'       **********In ExamAttemptHandler andFinally*******   '+newExamAttempt.Result__c);
        if(oldExamAttempt.Result__c != newExamAttempt.Result__c || newExamAttempt.Defered__c != oldExamAttempt.Defered__c ){
            mapEA.put(newExamAttempt.Candidate_Requirement__c,newExamAttempt);
        }else
            //Creating platform events to update contacts
            contUpdEvts.add(triggerutilities.getContactEvents(newExamAttempt.Member__c,'Exam_Attempt__c',JSON.serialize(newExamAttempt),JSON.serialize(oldExamAttempt),newExamAttempt.Id));
    }
    
    public void updateContractStatus(List<Contract> contList){
        //system.debug(contList.size()+'     <<::  updateContractStatus  contList ::>>   '+contList);
        Map<Id,Contract> contMapToUpdate = new Map<Id,Contract>();
        List<String> contIdList = new List<String>();
        
        for(Exam_Attempt__c ea : [SELECT Id,Candidate_Commitment__c FROM Exam_Attempt__c WHERE Candidate_Commitment__c IN: contList AND Id NOT IN : trigger.newMap.keySet() AND Result__c != null]){
            contIdList.add(ea.Candidate_Commitment__c);
        }
        //system.debug(contIdList.size()+'     <<::  updateContractStatus  contIdList ::>>   '+contIdList);
        
        for(Contract cont : contList){
            if(contIdList.contains(cont.Id)){
                cont.Status = 'Expired';
                contMapToUpdate.put(cont.Id,cont);
            }
        }
       // system.debug(contMapToUpdate.size()+'     <<::  updateContractStatus  contMapToUpdate ::>>   '+contMapToUpdate);
        
        if(contMapToUpdate.size() > 0){
            update contMapToUpdate.values();
        }
    }
}