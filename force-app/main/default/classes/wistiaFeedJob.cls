global class wistiaFeedJob implements Schedulable, Database.AllowsCallouts {
    
	public class thumbnailClass
    {
        public String url;
        public Integer width;
        public Integer height;
    }

   	public class projectClass
    {
        public Integer id;
        public String name;
        public String hashed_id;
    }

   	public class assetsClass
    {
        public String url;
        public Integer width;
        public Integer height;
        public Long fileSize;
        public String contentType;
        public String type;
    }

    public class wistiaClass
    {
        public Integer id;
        public String name;
        public String type;
        public DateTime created;
        public DateTime updated;
        public Double duration;
        public String hashed_id;
        public String description;
        public Double progress;
        public String status;
        public thumbnailClass thumbnail;
        public projectClass poject;
        public List<assetsClass> assets;
    }    
    
	@future(callout=true)
    public static Void getWistiaVideosInternal(Integer page) {
        
        HttpResponse res;
        HttpRequest req = new HttpRequest();      
        List<Content__c> updateContent = new List<Content__c>();
        List<Content__c> insertContent = new List<Content__c>();
        map<Integer,Content__c> mapCont = new map<Integer,Content__c>();
        String response;
        
        if ( !Test.isRunningTest() ) {
            req.setEndpoint('https://api.wistia.com/v1/medias.json?api_password=e3799e5757e935546bb68ddd768a1323ea4bb830a3019df150642f658e620ec9&page=' + page);
            req.setMethod('GET');
            Http h=new Http();
            res = h.send(req);
            response = res.getBody();
            system.debug('res == '+ response);
        } else {
			response = '[{"id":15612270,"name":"Intro to Resumes: A Vital Piece of Your Career Advancement","type":"Video","created":"2015-08-31T18:34:37+00:00","updated":"2016-10-27T21:28:33+00:00","duration":253.738,"hashed_id":"578noudyjw","description":"Dennis Grady, Lead Trainer, Career","progress":1.0,"status":"ready","thumbnail":{"url":"https://embed-ssl.wistia.com/deliveries/38e48e8379df846649ca05ec9aa649f4379dc8ac.jpg?image_crop_resized=1280x720","width":1280,"height":720},"project":{"id":2567611,"name":"Career Center","hashed_id":"3ey2y1ira0"},"assets":[{"url":"http://embed.wistia.com/deliveries/8da67925372463f9c0c51ada6198e3cff7471704.bin","width":1280,"height":720,"fileSize":164910586,"contentType":"video/x-ms-wmv","type":"OriginalFile"}],"embedCode":""}]';
        }        
        JSONParser parser = JSON.createParser(response);
        Map<String,wistiaClass> mapVid = new Map<String,wistiaClass>();
        List<String> lstIDs = new List<String>();
        List<wistiaClass> lstVids = new List<wistiaClass>();
        while (parser.nextToken() != null) {
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        wistiaClass vid = (wistiaClass)parser.readValueAs(wistiaClass.class);
                        //system.debug('vid.name: ' + vid.name);
                        //system.debug('vid.hashed_id: ' + vid.hashed_id);
                        String id = String.valueOf(vid.id);
                        mapVid.put(id, vid);
                        lstIDs.add(id);
                        lstVids.add(vid);
                    }
                }
            }
        }
        if(lstIDs.size() > 0) {            
            List<Content__c> lstContent = [select id, name, View_Count__c, Share_Count__c, Content_Name__c, Duration_in_Minutes__c, External_ID__c, Description__c, Image__c, RecordTypeId, SKU__c from Content__c where SKU__c in :lstIDs];
            for(Content__c cont :lstContent) {
                wistiaClass fnd = mapVid.get(cont.SKU__c);
                if(fnd != null) {
                    if(fnd.name.length() > 80)
                        cont.Name = fnd.name.subString(0,80);
                    else cont.name = fnd.name;
                    
                    if(fnd.name.length() > 255)
                        cont.Content_Name__c = fnd.name.subString(0,255);
                    else cont.Content_Name__c = fnd.name;
                    
                    cont.Duration_in_Minutes__c = fnd.duration / 60;
                    cont.External_ID__c = fnd.hashed_id;
                    cont.Description__c = fnd.description;
                    cont.Image__c = fnd.thumbnail.url;
                    cont.Published_Date__c = date.newinstance(fnd.created.year(), fnd.created.month(), fnd.created.day());
                    
                    cont.RecordTypeId = recordtypehelper.getRecordtypeID('Content__c','Video');                         
                    updateContent.add(cont);
                    mapCont.put(fnd.id, cont);
                    
                }
            }
        } else {
            return;
        }

        for(wistiaClass wc :lstVids) {
            Content__c fnd = mapCont.get(wc.id);
            if(fnd == null) {
                Content__c newCont = new Content__c();
                
                if(wc.name.length() > 80)
  		            newCont.Name = wc.name.subString(0,80);
                else newCont.name = wc.name;
                
                if(wc.name.length() > 255)
  		            newCont.Content_Name__c = wc.name.subString(0,255);
                else newCont.Content_Name__c = wc.name;
                
                newCont.Duration_in_Minutes__c = wc.duration / 60;
                newCont.External_ID__c = wc.hashed_id;
                newCont.Description__c = wc.description;
                newCont.Image__c = wc.thumbnail.url;
                newCont.RecordTypeId = recordtypehelper.getRecordtypeID('Content__c','Video');
                newCont.SKU__c = String.valueOf(wc.id);
                newCont.Published_Date__c = date.newinstance(wc.created.year(), wc.created.month(), wc.created.day());
                newCont.Media_Type__c = 'Wistia';
                insertContent.add(newCont);                
            }
        }
        system.debug('updateContent:' + updateContent.size());
        update updateContent;
        
        system.debug('insertContent:' + insertContent.size());
        insert insertContent;
        return;        
    }
    
	
    public static Void getWistiaVideos() {
        
        getWistiaVideosInternal(1);
        getWistiaVideosInternal(2);
        getWistiaVideosInternal(3);
        getWistiaVideosInternal(4);
        getWistiaVideosInternal(5);
        
    }	
	
    global void execute(SchedulableContext SC) {
		getWistiaVideos();
    }
    
    global void finish(Database.BatchableContext SC){
         
       
    }
}