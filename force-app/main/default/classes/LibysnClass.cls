global class LibysnClass {
    
    public static String xml{get; set;}
    
    global LibysnClass() {
        
    }
    
    @future(callout = true)
    static global void getLibsynRSSFeed(string URL) {
        xml = getRSSFeed(URL);   
        system.debug('xml:'+xml.Left(25));
        
        List<Content__c> blogEntries = getXMLPosts(xml);   
        system.debug('blogEntries:' + blogEntries);
        
        Set<String> SKU = new Set<String>();
        List<Content__c> entriesToAdd = new List<Content__c>();        
        // Collect unique identifiers in a list
        for(Content__c bp : blogEntries) {
            SKU.add(bp.SKU__c);
        }
        system.debug('SKU:'+SKU);
        
        // Get all the records from content object in salesforce to check the duplicates
        Map<String, Content__c> blogs = new Map<String, Content__c>(); 
        for(Content__c objCS : [SELECT Id, Content_Name__c,SKU__c, Author__c,Description__c,Third_Party_URL__c,Published_Date__c  from Content__c WHERE SKU__c IN :SKU]){
            blogs.put(objCS.SKU__c, objCS);
        }
        system.debug('blogs:'+blogs);

        for(Content__c blogEntry : blogEntries) {
            
            system.debug('blogEntry:'+blogEntry);
            
            Boolean added = false;
            if(blogs.containsKey(blogEntry.SKU__c)){
                added = true;
            }
            if(!added){
                entriesToAdd.add(blogEntry); 
            }
        }
        system.debug('entriesToAdd=======>'+entriesToAdd);
        insert entriesToAdd;
    }
    
    // Checking the RSSfeed endpoint
    static global String getRSSFeed(string URL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        // url that returns the XML in the response body  
        req.setEndpoint(url);
        req.setMethod('GET');
        
        String xml;
        if(test.isRunningTest()){ 
            xml = '<?xml version="1.0" encoding="UTF-8"?>'+
                '<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:cc="http://web.resource.org/cc/" '+
                'xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:media="http://search.yahoo.com/mrss/"'+
                ' xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'+
                ' xmlns:libsyn="http://libsyn.com/libsyn-rss-spec">'+
                '<channel>'+
                '<item>'+
                '<title>An ERM Pioneer Looks Back...and Ahead </title>'+
                '<pubDate>Wed, 12 Sep 2018 18:16:04 +0000</pubDate>'+
                '<link>http://garpcast.libsyn.com/an-erm-pioneer-looks-backand-ahead</link>'+
                '<itunes:image href="http://static.libsyn.com/p/assets/a/5/e/a/a5ea3ed3efd61263/1400x1400Thumb.png" />'+
                '<description>At Citibank, David X Martin prehensive enterprise risk management processes. While with </description>'+
                '<content:encoded> profession, changes in the risk landscape, and his current work on cyber risk and board governance as managing partner of </content:encoded>'+
                '<libsyn:itemId>6934138</libsyn:itemId>'+
                '<itunes:subtitle>At Citibank, David X Martin</itunes:subtitle>'+
                '<itunes:author>GARP </itunes:author>'+
                '<itunes:summary>Our global chapter network is a core benefit of our community.</itunes:summary>'+
                '</item>'+
                '</channel>'+
                '</rss>';
        } else {     
        	HttpResponse res = h.send(req);
            xml = res.getBody();
        }
        return xml;
    }
    
    static global List<Content__c> getXMLPosts(string xml) {
        //system.debug('reader:' + xml);
        
        //xml = xml.replaceAll('itunes:', 'itunes-');
        //xml = xml.replaceAll('libsyn:', 'libsyn-');

        XmlStreamReader reader = new XmlStreamReader(xml);
        
        boolean isSafeToGetNextXmlElement = true;
        Boolean isStart = false;
        List<Content__c> podCasts = new List<Content__c>();
        Content__c bp = new Content__c ();
        
        while(isSafeToGetNextXmlElement) {
            if (reader.getEventType() == XmlTag.START_ELEMENT) {
                String tag = reader.getLocalName();
                //system.debug('Tag:' + tag);
                if(tag == 'item' && !isStart) {
                    isStart = True;
                    system.debug('isStart:' + isStart);
                }
                if(isStart) {
                    if(tag == 'description') {
                        String val = getTagContent(reader);
                        bp.Story__c = val;
                    } else if(tag == 'title') {
                        if(bp.Content_Name__c != NULL) {
                            bp.Name = bp.Content_Name__c.Left(80);
                            bp.Media_Type__c = 'Audio';
                            bp.RecordTypeId = Schema.SObjectType.Content__c.getRecordTypeInfosByName().get('Podcast').getRecordTypeId();
                            bp.Status__c = 'Active';
                            
                            system.debug('Add Podcast:' + bp);
                            
                            podCasts.add(bp);
                            bp = new Content__c ();
                        }
                        bp.Content_Name__c = getTagContent(reader);
                    } else if(tag == 'pubDate') {
                        String val = getTagContent(reader);
                        String year = val.substring(12, 16);
                        String day = val.substring(5, 7);
                        String month = val.substring(8, 11);
                        if(month.equals('Jan')) { month = '01'; }
                        if(month.equals('Feb')) { month = '02'; }
                        if(month.equals('Mar')) { month = '03'; }
                        if(month.equals('Apr')) { month = '04'; }
                        if(month.equals('May')) { month = '05'; }
                        if(month.equals('Jun')) { month = '06'; }
                        if(month.equals('Jul')) { month = '07'; }
                        if(month.equals('Aug')) { month = '08'; }
                        if(month.equals('Sep')) { month = '09'; }
                        if(month.equals('Oct')) { month = '10'; }
                        if(month.equals('Nov')) { month = '11'; }
                        if(month.equals('Dec')){ month = '12'; }
                        String finalDate = month + '/' +day + '/' +year ;
                        bp.Published_Date__c = date.parse(finalDate);
                    } else if(tag == 'link') {
                        bp.Third_Party_URL__c = getTagContent(reader);
                        if(bp.Third_Party_URL__c != null)
                    	bp.Vanity_URL__c = getPathFromURL(bp.Third_Party_URL__c);
                    } else if(tag == 'image') {
                        String val = getTagContent(reader);
                        bp.Image__c = val;
                    
                    } else if(tag == 'summary') {
                        bp.Description__c = getTagContent(reader);
                        
					} else if(tag == 'itemId') {
                        bp.SKU__c = getTagContent(reader);
                    }
                }
            }
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                
                if(bp.Content_Name__c != NULL) {
                    bp.Name = bp.Content_Name__c.Left(80);
                    bp.Media_Type__c = 'Audio';
                    bp.RecordTypeId = Schema.SObjectType.Content__c.getRecordTypeInfosByName().get('Podcast').getRecordTypeId();
                    bp.Status__c = 'Active';
                    
                    system.debug('Add Podcast:' + bp);
                    
                    podCasts.add(bp);
                    bp = new Content__c ();
                }                
                
                break;
            }
        }
        system.debug('podCasts:' + podCasts);
        return podCasts;
    }

    static global String getTagContent(XmlStreamReader reader) {
        boolean isSafeToGetNextXmlElement = True;
        String val;
        
        while(isSafeToGetNextXmlElement) {
            //system.debug('Event:'+ reader.getEventType());
            
            if (reader.getEventType() == XmlTag.END_ELEMENT) {
                break;
            } else if (reader.getEventType() == XmlTag.CHARACTERS) {
                //system.debug('Text:' + reader.getText());
                val = reader.getText();
            }
            if (reader.hasNext()) {
                reader.next();
            } else {
                isSafeToGetNextXmlElement = false;
                break;
            }
        }
        return val;
    }
        
    static global void updateAllFeeds() {
        // GARP Risk
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/96199/rss/?include-libsyn-metadata=true');
        
        // Climate Risk
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/284498/rss/?include-libsyn-metadata=true');
        
        // New Age
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/176627/rss/?include-libsyn-metadata=true');
                                      
    }
    
    @InvocableMethod(label='LibysnClass' description='Call LibysnClass Methods')
    public static void LibysnClassInvocable(List<List<String>> inputParams) {  
        
        System.debug('inputParams:' + inputParams);
        
        String method;
        String param1;
        String param2;
        String param3;
        String param4;
        String param5;
        List<String> ids = inputParams[0];
        
        if(!ids.isEmpty()){
            Integer cnt=0;
            for(String idVal :ids) {
                if(cnt==0)
                    method = idVal;
                else if(cnt==1)
                    param1 = idVal;
                else if(cnt==2)
                    param2 = idVal;
                else if(cnt==3)
                    param3 = idVal;
                else if(cnt==4)
                    param4 = idVal;
                else if(cnt==5)
                    param5 = idVal;
                cnt++;
            }
            System.debug('method:' + method);
            System.debug('param1:' + param1);
            System.debug('param2:' + param2);
            System.debug('param3:' + param3);
            System.debug('param4:' + param4);
            System.debug('param5:' + param5);
            
            if(method == 'updateAllFeeds') {
                updateAllFeeds();
            }
        }
    }
    
    public static String getPathFromURL(String url) {
        // Define a regex pattern to extract the path after the domain
        Pattern pattern = Pattern.compile('https?://[^/]+/(.+)');
        Matcher matcher = pattern.matcher(url);

        if (matcher.find()) {
            // Group 1 contains the path after the domain
            return matcher.group(1);
        }
        return null; // Return null if no match is found
    }
    
}