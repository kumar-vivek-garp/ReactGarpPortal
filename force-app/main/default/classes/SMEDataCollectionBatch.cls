/*
[US-19775] Scheduler/Batch Class for aggregate SME data for Contact. Usage:
String cronExp = '0 0 2 ? * *';
System.debug('Job Id: ' + System.schedule('SME Data Collection Job', cronExp, new SMEDataCollectionBatch(100)));
*/
public without sharing class SMEDataCollectionBatch implements Schedulable, Database.Batchable<sObject> {
    
    // For Scheduler
    public Integer batchSize {get; set;}
    
    public SMEDataCollectionBatch(Integer batchSize) {
        this.batchSize = batchSize;
    }
    
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new SMEDataCollectionBatch(), this.batchSize);
    }
    
    // For Batch
    public Map<Id, Date> evtSpkrToLastDate  {get; private set;}
    public Map<Id, Date> chapSpkrToLastDate {get; private set;}
    public Map<Id, List<Set<String>>> evtSpkrToCat  {get; private set;}
    public Map<Id, List<Set<String>>> chapSpkrToCat {get; private set;}
    
    public SMEDataCollectionBatch() {}
    
    // Gather all target Contact records
    public Iterable<sObject> start(Database.BatchableContext BC) {
        Set<Id> conIds = new Set<Id>();
        
        // Combine Contact Ids
        for(Event_Speaker_Session_Track__c speakerSess : [SELECT Event_Speaker__r.Contact__c FROM Event_Speaker_Session_Track__c WHERE Event_Speaker__r.Contact__c != NULL AND Status__c IN ('Active')]) {
            conIds.add(speakerSess.Event_Speaker__r.Contact__c);
        }
        
        for(Chapter_Meeting_Speaker__c meetingSpeaker : [SELECT Chapter_Speaker__r.Contact__c FROM Chapter_Meeting_Speaker__c WHERE Chapter_Speaker__r.Contact__c != NULL AND Chapter_Meeting__r.Status__c IN ('Active')]) {
            conIds.add(meetingSpeaker.Chapter_Speaker__r.Contact__c);
        }
        
        for(Presenter__c presenter : [SELECT Contact__c FROM Presenter__c WHERE Contact__c != NULL AND Webcast__r.Status__c IN ('Approved', 'Active')]) {
            conIds.add(presenter.Contact__c);
        }
        
        for(Content__c content : [SELECT Contact__c FROM Content__c WHERE Contact__c != NULL AND RecordType.DeveloperName IN ('Podcast','Article') AND Status__c IN ('Approved', 'Active', 'Ready to Publish')]) {
            conIds.add(content.Contact__c);
        }
        
        // Main query for fetching data - Event and Chapter Speakers are filtered in each batch
        List<Contact> conWithSME = [SELECT Id, FirstName, LastName, Email, Phone, (SELECT Id FROM SME_Registrations__r ORDER BY Name ASC),
                                    (SELECT Id FROM Event_Speakers__r),
                                    (SELECT Id FROM Chapter_Speakers__r),
                                    (SELECT Id, Webcast__r.End_Date__c, Webcast__r.Content__r.Category__c, Webcast__r.Content__r.Subcategory__c FROM Presenters__r WHERE Webcast__r.Status__c IN ('Approved', 'Active')),
                                    (SELECT Id, RecordType.DeveloperName, Published_Date__c, Category__c, Subcategory__c FROM Contents__r WHERE RecordType.DeveloperName IN ('Podcast','Article') AND Status__c IN ('Approved', 'Active', 'Ready to Publish'))
                                    FROM Contact WHERE Id IN :conIds];
        
        return conWithSME;
    }
    
    // Roll up Taxonomy, Count and Last Date. Then Insert/Update the SME Profile associated with each Contact in batches.
    public void execute(Database.BatchableContext BC, List<sObject> scope) {
        List<Contact> conList = (List<Contact>)scope;
        
        setupSpeakerMaps(conList);
        Map<String, Schema.sObjectField> smeFldMap = SME_Registration__c.sObjectType.getDescribe().fields.getMap();
        
        List<SME_Registration__c> conSMEProfiles = new List<SME_Registration__c>();
        
        for(Contact con : conList) {
            Set<String> allCats = new Set<String>();
            Set<String> allSubcats = new Set<String>();
            
            // Check Insert/Update SME Profile.
            SME_Registration__c newSME;
            List<SME_Registration__c> conSMEs = con.SME_Registrations__r;
            if(conSMEs.size() > 0) {
                newSME = conSMEs[0];
            }else {
                String phoneStr = null != con.Phone ? con.Phone.replaceAll(' ', '').left(18) : null;
                newSME = new SME_Registration__c(First_Name__c = con.FirstName, Last_Name__c = con.LastName, Email__c = con.Email, Phone__c = phoneStr, Contact__c = con.Id);
            }
            
            // Roll up counts
            Integer validEvtSpkrCount = 0;
            for(Event_Speaker__c evtSpkr : con.Event_Speakers__r) {
                if(evtSpkrToLastDate.containsKey(evtSpkr.Id)) {
                    validEvtSpkrCount++;
                }
            }
            
            Integer validChapSpkrCount = 0;
            for(Chapter_Speaker__c chapSpkr : con.Chapter_Speakers__r) {
                if(chapSpkrToLastDate.containsKey(chapSpkr.Id)) {
                    validChapSpkrCount++;
                }
            }
            
            List<Content__c> podContents = new List<Content__c>();
            List<Content__c> artContents = new List<Content__c>();
            for(Content__c content : con.Contents__r) {
                if(content.RecordType.DeveloperName == 'Podcast') {
                    podContents.add(content);
                }else if(content.RecordType.DeveloperName == 'Article') {
                    artContents.add(content);
                }
                
                allCats.add(content.Category__c);
                allSubcats.add(content.Subcategory__c);
            }
            
            newSME.Event_Speaker_Count__c = validEvtSpkrCount;
            newSME.Chapter_Speaker_Count__c = validChapSpkrCount;
            newSME.Webcast_Presenter_Count__c = con.Presenters__r.size();
            newSME.Podcast_Presenter_Count__c = podContents.size();
            newSME.Article_Author_Count__c = artContents.size();
            
            // Roll up dates
            // Last Event Speaker Date - Compare between multiple Event Speakers
            Date lastEvtSpkrDate;
            for(Event_Speaker__c oneSpkr : con.Event_Speakers__r) {
                Date evtSpkrDate = evtSpkrToLastDate.get(oneSpkr.Id);
                if(null != evtSpkrDate && (null == lastEvtSpkrDate || lastEvtSpkrDate < evtSpkrDate)) {
                    lastEvtSpkrDate = evtSpkrDate;
                }
                
                List<Set<String>> spkrCats = evtSpkrToCat.get(oneSpkr.Id);
                if(null != spkrCats) {
                    allCats.addAll(spkrCats[0]);
                    allSubcats.addAll(spkrCats[1]);
                }
            }
            newSME.Last_Event_Speaker_Date__c = lastEvtSpkrDate;
            
            // Last Chapter Speaker Date - Compare between multiple Chapter Speakers
            Date lastChpSpkrDate;
            for(Chapter_Speaker__c chapSpeaker : con.Chapter_Speakers__r) {
                Date chapSpkrDate = chapSpkrToLastDate.get(chapSpeaker.Id);
                if(null != chapSpkrDate && (null == lastChpSpkrDate || lastChpSpkrDate < chapSpkrDate)) {
                    lastChpSpkrDate = chapSpkrDate;
                }
                
                List<Set<String>> spkrCats = chapSpkrToCat.get(chapSpeaker.Id);
                if(null != spkrCats) {
                    allCats.addAll(spkrCats[0]);
                    allSubcats.addAll(spkrCats[1]);
                }
            }
            newSME.Last_Chapter_Speaker_Date__c = lastChpSpkrDate;
            
            Date lastWebPresDate;
            for(Presenter__c webPres : con.Presenters__r) {
                if(null == lastWebPresDate || lastWebPresDate < webPres.Webcast__r.End_Date__c.date()) {
                    lastWebPresDate =  webPres.Webcast__r.End_Date__c.date();
                }
                
                if(null != webPres.Webcast__r.Content__r) {
                    allCats.add(webPres.Webcast__r.Content__r.Category__c);
                    allSubcats.add(webPres.Webcast__r.Content__r.Subcategory__c);
                }
            }
            newSME.Last_Webcast_Presenter_Date__c = lastWebPresDate;
            
            Date lastPodPresDate;
            for(Content__c podCont : podContents) {
                if(null == lastPodPresDate || lastPodPresDate < podCont.Published_Date__c) {
                    lastPodPresDate = podCont.Published_Date__c;
                }
            }
            newSME.Last_Podcast_Presenter_Date__c = lastPodPresDate;
            
            Date lastArtAuthDate;
            for(Content__c artCont : artContents) {
                if(null == lastArtAuthDate || lastArtAuthDate < artCont.Published_Date__c) {
                    lastArtAuthDate = artCont.Published_Date__c;
                }
            }
            newSME.Last_Article_Author_Date__c = lastArtAuthDate;
            
            // After gathering all Category & Subcategory, roll up to SME Profile
            rollUpTaxonomyFields(allCats, allSubcats, newSME, smeFldMap);
            
            conSMEProfiles.add(newSME);
        }
        
        if(conSMEProfiles.size() > 0) upsert conSMEProfiles;
    }
    
    // Setup maps for getting last date and maps for Category & Subcategory
    public void setupSpeakerMaps(List<Contact> conList) {
        evtSpkrToLastDate = new Map<Id, Date>();
        chapSpkrToLastDate = new Map<Id, Date>();
        
        evtSpkrToCat = new Map<Id, List<Set<String>>>();
        chapSpkrToCat = new Map<Id, List<Set<String>>>();
        
        Set<Id> eventSpeakerIds = new Set<Id>();
        Set<Id> chapterSpeakerIds = new Set<Id>();
        
        for(Contact con : conList) {
            eventSpeakerIds.addAll(new Map<Id, Event_Speaker__c>(con.Event_Speakers__r).keySet());
            chapterSpeakerIds.addAll(new Map<Id, Chapter_Speaker__c>(con.Chapter_Speakers__r).keySet());
        }
        
        // If same Event Speaker is in multiple Sessions, get the latest end date in map
        List<Event_Speaker_Session_Track__c> sessTracks = [SELECT Event_Speaker__c, Event_Session_End_Date_Time__c, Event_Session__r.Category__c, Event_Session__r.Subcategory__c
                                                           FROM Event_Speaker_Session_Track__c 
                                                           WHERE Event_Speaker__c IN :eventSpeakerIds AND Status__c IN ('Active')
                                                           ORDER BY Event_Speaker__c, Event_Session_End_Date_Time__c DESC NULLS LAST];
        
        for(Event_Speaker_Session_Track__c esst : sessTracks) {
            Id spkrId = esst.Event_Speaker__c;
            if(!evtSpkrToLastDate.containsKey(spkrId)) {
                evtSpkrToLastDate.put(spkrId, esst.Event_Session_End_Date_Time__c.date());
            }
            
            if(!evtSpkrToCat.containsKey(spkrId)) {
                evtSpkrToCat.put(spkrId, new List<Set<String>>{new Set<String>(), new Set<String>()});
            }
            
            if(null != esst.Event_Session__r.Category__c) {
                evtSpkrToCat.get(spkrId)[0].add(esst.Event_Session__r.Category__c);
                
                if(null != esst.Event_Session__r.Subcategory__c) {
                    evtSpkrToCat.get(spkrId)[1].add(esst.Event_Session__r.Subcategory__c);
                }
            }
        }
        
        // If same Chapter Speaker is in multiple Meetings, get the latest end date in map
        List<Chapter_Meeting_Speaker__c> chapMeetSpkrs = [SELECT Chapter_Speaker__c, Chapter_Meeting__r.End__c, Chapter_Meeting__r.Category__c, Chapter_Meeting__r.Subcategory__c
                                                          FROM Chapter_Meeting_Speaker__c 
                                                          WHERE Chapter_Speaker__c IN :chapterSpeakerIds AND Chapter_Meeting__r.Status__c IN ('Active')
                                                          ORDER BY Chapter_Speaker__c, Chapter_Meeting__r.End__c DESC NULLS LAST];
        
        for(Chapter_Meeting_Speaker__c cms : chapMeetSpkrs) {
            Id spkrId = cms.Chapter_Speaker__c;
            if(!chapSpkrToLastDate.containsKey(spkrId)) {
                chapSpkrToLastDate.put(spkrId, cms.Chapter_Meeting__r.End__c.date());
            }
            
            if(!chapSpkrToCat.containsKey(spkrId)) {
                chapSpkrToCat.put(spkrId, new List<Set<String>>{new Set<String>(), new Set<String>()});
            }
            
            if(null != cms.Chapter_Meeting__r.Category__c) {
                chapSpkrToCat.get(spkrId)[0].add(cms.Chapter_Meeting__r.Category__c);
            
                if(null != cms.Chapter_Meeting__r.Subcategory__c) {
                    chapSpkrToCat.get(spkrId)[1].add(cms.Chapter_Meeting__r.Subcategory__c);
                }
            }
        }
    }
    
    // Category Values to SME Field Name mapping
    public static Map<String, String> cateValToSMEFld = new Map<String, String>{
        'Technology'=>'Technology_Sys__c', 'Culture & Governance'=>'Culture_Governance_Sys__c', 'Energy'=>'Energy_Sys__c', 'Operational'=>'Operational_Sys__c', 'Credit'=>'Credit_Risk_Sys__c', 'Market'=>'Market_Risk_Sys__c'
    };
    
    // Set SME Profile Taxonomy values. Approach is value driven and is based on Field Dependency - values in Subcategory can only exist on certain Category and no duplicates.
    public void rollUpTaxonomyFields(Set<String> allCats, Set<String> allSubcats, SME_Registration__c newSME, Map<String, Schema.sObjectField> smeFldMap) {
        for(String oneCat : allCats) {
            String oneFld = cateValToSMEFld.get(oneCat);
            
            if(null != oneFld) {
                List<Schema.PicklistEntry> pleList = smeFldMap.get(oneFld).getDescribe().getPicklistValues();
            
                Set<String> selValues = new Set<String>();
                for(Schema.PicklistEntry ple : pleList) {
                    if(allSubcats.contains(ple.getValue())) {
                        selValues.add(ple.getValue());
                    }
                }
                
                if(!selValues.isEmpty()) {
                    newSME.put(oneFld, String.join(new List<String>(selValues), ';'));
                }else {
                    newSME.put(oneFld, null);
                }
            }
        }
        
        newSME.Expert_Participation_Sys__c = newSME.Webcast_Presenter_Count__c > 0 ? 'Webcasts' : null;
        newSME.Publishing_Experience_Sys__c = newSME.Article_Author_Count__c > 0 ? 'Articles' : null;
        newSME.Teaching_Experience_Sys__c = newSME.Chapter_Speaker_Count__c > 0 ? 'Chapter Meetings' : null;
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
    
}