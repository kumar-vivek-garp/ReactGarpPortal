global class HubspotSyncUpdate implements Schedulable, Database.AllowsCallouts {
    
    // Schedule every 15 min
    //System.schedule('HubspotSyncUpdate 1', '0 0 * * * ?', new HubspotSyncUpdate());
    //System.schedule('HubspotSyncUpdate 2', '0 15 * * * ?', new HubspotSyncUpdate());
    //System.schedule('HubspotSyncUpdate 3', '0 30 * * * ?', new HubspotSyncUpdate());
    //System.schedule('HubspotSyncUpdate 4', '0 45 * * * ?', new HubspotSyncUpdate());
    global void execute(SchedulableContext sc) {
        syncIfNeeded();
    }
    
    @future(callout=true)
    public static void syncIfNeeded() {
    
        DateTime lastRun = DateTime.now().AddDays(-1);
    
        AggregateResult[] result = [SELECT MAX(PreviousFireTime)LastRun FROM CronTrigger WHERE CronJobDetail.Name LIKE 'HubspotSyncUpdate'];
        System.Debug('result:' + result);
        
        if(!result.IsEmpty() && result[0].get('LastRun') != NULL) {
            lastRun  = DateTime.valueOf(result[0].get('LastRun'));
        }
        System.debug('lastRun: '+ lastRun);        
    
        String podCastRecTypeId = RecordTypeHelper.GetRecordTypeId('Content__c', 'Podcast');
        List<Content__c> newPodCastAddUpdates = [select id from Content__c where RecordTypeID = :podCastRecTypeId AND SystemModStamp > :lastRun];
        System.Debug('newPodCastAddUpdates: ' + newPodCastAddUpdates);
        
        if(!newPodCastAddUpdates.IsEmpty()) {
            System.Debug('Call Sync');
            syncMethod();    
        }
    }
    
    
    @InvocableMethod(label='HubSpotSync' description='Sync HubSpot')
    public static List<string> syncMethod(){
       String result;
        
        Map<String, GARP_Rivery_Settings__c> riverSettings = GARP_Rivery_Settings__c.getAll();
        GARP_Common.debugLog('HubspotSyncUpdate','InvocableMethod','riverSettings',riverSettings);
        if(!riverSettings.IsEmpty()) {
            GARP_Rivery_Settings__c riverSetting = riverSettings.get('Podcast');
            if(riverSetting != NULL && riverSetting.RiverID__c != NULL) {
                GARP_Common.apiReturnInfo ret = GARP_RiveryClass.runRiver('6258527619694a1d01995e39');
                if(ret != NULL) {
                    if(ret.statusCode == 200) {
                        result = 'Sync Request Succeeded';
                    } else{
                        result = 'Sync Request Failed with Error:' + ret.statusCode + ':' + ret.message;
                    }                
                } else {
                    result = 'Sync Request Failed with Error: No API information returned';
                }
            }
        }        
        return new List<String>{result}; 
        /*
        Hubspot_Auth__mdt hb = [SELECT Id,MasterLabel,Authorization__c,EndPoint__c, River_Id__c from Hubspot_Auth__mdt WHERE MasterLabel ='Hubspot API'];
        System.debug('hb'+hb);

        System.Debug('hb.EndPoint__c:' + hb.EndPoint__c);
        System.Debug('hb.River_Id__c:' + hb.River_Id__c);
        System.Debug('hb.Authorization__c:' + hb.Authorization__c);    
        System.Debug('hb.Authorization__c len:' + hb.Authorization__c.length());             


        HubSpotRequest request = new HubSpotRequest();
        request.river_id = hb.River_Id__c;
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(hb.EndPoint__c);        
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        
        //req.setHeader('accept', 'application/json');
        
        req.setBody(JSON.serialize(request));
        
        System.Debug('Body:' + req.getBody()); 
        
        //String auth = 'eyJhbGciOiJIUzI1NiIsImV4cCI6MTk2ODY3MjgxMiwiaWF0IjoxNjUzMzEyODEyfQ.eyJhY2MiOiI1ZmI4MTQyZWY1NjgyYzY1NDgyM2MxMTMiLCJzY29wZXMiOnsiNjAxYzM4ZmRmNTY4MmMyYWZlZTU0OWViIjpbInJpdmVyOmV4ZWN1dGUiXX0sInRva2VuX25hbWUiOiJSaXZlcnlFeGVjIiwiaXNzIjoiNjBhZmMyYzNmNTY4MmMzNWIzMmNjNmI2IiwianRpIjoiYTc1M2I2ZTlkYWQ1NDQzYWI1NzBjZTc5NjNkZDNlNzciLCJlbnYiOiI2MDFjMzhmZGY1NjgyYzJhZmVlNTQ5ZWIiLCJzdWIiOiJSaXZlcnkgQVBJIn0.s1g-iFdOAncC-uf56_rosVi0WqJsPUCuFSZJp7HSrO8';
        
        //req.setHeader('Authorization','Bearer '+auth);
         req.setHeader('Authorization','Bearer '+hb.Authorization__c);
        system.debug(request);
        HttpResponse response = http.send(req);
        
        system.debug('response == '+response);
        String result = '';
        
        
        if (response.getStatusCode() == 200 || response.getStatusCode() == 201) // 200 or 201
        {
            result = 'Sync Request Succeeded';
        } else{
            result = 'Sync Request Failed with Error:' + response.getStatusCode() + ':' + response.getStatus();
        }
        return new List<String>{result}; 
		*/
    }
    
    public class HubSpotRequest{
        public string river_id;
    }

}