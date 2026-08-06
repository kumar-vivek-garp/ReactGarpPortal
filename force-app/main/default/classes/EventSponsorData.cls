global class EventSponsorData {
    
    public List <Event_Sponsor__c> eventSponsors { get; set; }
    public List <cdrive__Cloud_Files__c> eventSponsorFiles { get; set; }
    
    public EventSponsorData(sfdcAppRemoter ctrl){}
    public EventSponsorData(String eventId){
        eventSponsors = getSponsorsForEventId(eventId);
        List<Id> sponsorIds = pluckSponsorIds(eventSponsors);
        eventSponsorFiles = getSponsorCdriveFilesForIds(sponsorIds);
    }
    
    @RemoteAction
    public static EventSponsorData getAllSponsorInfoForEventId (String eventId){
        return new EventSponsorData(eventId);
    }
    
    public static List <cdrive__Cloud_Files__c> getSponsorCdriveFilesForIds(List <Id> sponsorIds){
        return [
            select 
                Id, 
                cdrive__contextID__c, 
                cdrive__File_Name__c 
            from cdrive__Cloud_Files__c 
            where cdrive__contextID__c = :sponsorIds 
        ];
    }
    
    public static List <Event_Sponsor__c> getSponsorsForEventId(String eventId){
        return [
            select 
                Id, 
                Name,
                Description__c,
                Group_Rank__c,
                Level__c,
                Logo__c,
                Website__c 
            from Event_Sponsor__c 
            where Event__c = :eventId and Status__c = 'Active'
        ];
    }
    
    public static List <String> pluckSponsorIds(List <Event_Sponsor__c> sponsors){
        List<Id> sponsorIds = new List<Id>();
        for(Event_Sponsor__c sponsor : sponsors) {
            sponsorIds.add(sponsor.Id);
        }
        return sponsorIds;
    }
    
}