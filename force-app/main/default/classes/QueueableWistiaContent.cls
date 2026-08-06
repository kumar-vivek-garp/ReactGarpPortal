public class QueueableWistiaContent implements Queueable, Database.AllowsCallouts{

    public Integer pageNumber;
    
    public class Thumbnail{
        public String url           { get; set; }   
    }
    
    public class WistiaContent{
        public String id            { get; set; }
        public String name          { get; set; }
        public DateTime created     { get; set; }
        public Double duration      { get; set; }
        public String hashed_id     { get; set; }
        public String description   { get; set; }
        public Thumbnail thumbnail  { get; set; }
    }    
    
    public List<WistiaContent> callout(Integer pageNumber){
        
        HttpRequest req = new HttpRequest();  
        req.setEndpoint('https://api.wistia.com/v1/medias.json?api_password=e3799e5757e935546bb68ddd768a1323ea4bb830a3019df150642f658e620ec9&page=' + pageNumber);
        req.setMethod('GET');
        
        Http h = new Http();
        HttpResponse res = h.send(req);
        
        String response = res.getBody();
        
        return (List<WistiaContent>)JSON.deserialize(response, List<WistiaContent>.class);
        
    }
    
    public void process(List<WistiaContent> wistiaContent) {
        
        List<Content__c> toUpdate = new List<Content__c>();
        List<Content__c> toInsert = new List<Content__c>();
        
        Map<String, WistiaContent> wistiaContentMap = new Map<String, WistiaContent>();
        for(WistiaContent r: wistiaContent){
            wistiaContentMap.put(r.id, r);
        }
        
        List<Content__c> contentRecords = [
            SELECT 
            Id, 
            Name, 
            View_Count__c, 
            Share_Count__c, 
            Content_Name__c, 
            Duration_in_Minutes__c, 
            External_ID__c, 
            Description__c, 
            Compute_Image__c, 
            RecordTypeId, 
            SKU__c 
            FROM 
            Content__c 
            WHERE 
            SKU__c IN :wistiaContentMap.keySet()
        ];
        
        if(!contentRecords.isEmpty()) {                   
            for(Content__c c :contentRecords){
                
                WistiaContent root = wistiaContentMap.get(c.SKU__c);
                
                if(root.name.length() > 80){
                    c.Name = root.name.subString(0,80);
                }else{
                    c.name = root.name;
                }
                
                if(root.name.length() > 255){
                    c.Content_Name__c = root.name.subString(0,255);
                }else{
                    c.Content_Name__c = root.name;
                }
                
                c.Duration_in_Minutes__c = root.duration / 60;
                c.External_ID__c = root.hashed_id;
                c.Description__c = root.description;
                c.Image__c = root.thumbnail.url;
                c.Published_Date__c = Date.newinstance(root.created.year(), root.created.month(), root.created.day());
                c.RecordTypeId = recordtypehelper.getRecordtypeID('Content__c', 'Video');   
                
                toUpdate.add(c);
                
                wistiaContentMap.remove(c.SKU__c);
                
            }
        } 
        
        for(WistiaContent r: wistiaContentMap.values()){
            
            Content__c content = new Content__c();
            
            if(r.name.length() > 80){
                content.Name = r.name.subString(0,80);
            }else{
                content.name = r.name;
            }
            
            if(r.name.length() > 255){
                content.Content_Name__c = r.name.subString(0,255);
            }else{
                content.Content_Name__c = r.name;
            }
            
            content.Duration_in_Minutes__c = r.duration / 60;
            content.External_ID__c = r.hashed_id;
            content.Description__c = r.description;
            content.Image__c = r.thumbnail.url;
            content.RecordTypeId = recordtypehelper.getRecordtypeID('Content__c','Video');
            content.SKU__c = String.valueOf(r.id);
            content.Published_Date__c = date.newinstance(r.created.year(), r.created.month(), r.created.day());
            content.Media_Type__c = 'Wistia';
            
            toInsert.add(content);                
            
        }
        
        update toUpdate;       
        insert toInsert;
        
    }
    
    public void execute(QueueableContext qc){
        
        List<WistiaContent> wistiaContents = this.callout(pageNumber);
        
        if(!wistiaContents.isEmpty()){
            this.pageNumber++;
            this.process(wistiaContents);
            if(!Test.isRunningTest()) System.enqueueJob(new queueableWistiaContent(this.pageNumber));
        }
    
    }
        
    public queueableWistiaContent(Integer pageNumber){
        this.pageNumber = pageNumber;
    }
    
}