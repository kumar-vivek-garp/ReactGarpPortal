/*
* Class to create content records for each item in RSS feed.
**/
global class RSSHandler implements Schedulable {
    
    public static String xml{get; set;}
    public static List<Dom.XMLNode> recentPosts {get; set;}
    global RSSHandler() {
        recentPosts = new List<Dom.XMLNode>();
    }
    
    global void execute(SchedulableContext c) {
        getLibsynRSSFeed();
    }
    
    @future(callout=true)
    static global void getLibsynRSSFeed() {
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
            recentPosts = documentXml(xml);
            
        } else {     
            recentPosts = RSSHandler.getRSSFeed('https://garpcast.libsyn.com/rss/?include-libsyn-metadata=true');        
        }
        system.debug('recentPosts==========>'+recentPosts);
        List<Content__c> blogEntries = new List<Content__c>();
        Set<String> SKU = new Set<String>();
        List<Content__c> entriesToAdd = new List<Content__c>();
        List<Content_Folders__c > entriesToAddContentFolder = new List<Content_Folders__c >();
        
        Content_Folders__c BlogContentFolderEntries ;
        
        // To collect all the posts from the RSSFeed
        for(Dom.XMLNode post : recentPosts) {
            blogEntries.add(RSSHandler.convertFeedToBlogPost(post));
        }    
        
        system.debug('blogEntries======>'+blogEntries);
        // Collect unique identifiers in a list
        for(Content__c bp : blogEntries) {
            SKU.add(bp.SKU__c);
        }
        system.debug('SKU======>'+SKU);
        
        // Get all the records from content object in salesforce to check the duplicates
       Map<String, Content__c> blogs = new Map<String, Content__c>(); 
        for(Content__c objCS : [SELECT Id, Content_Name__c,SKU__c, Author__c,Description__c,Third_Party_URL__c,Published_Date__c  from Content__c WHERE SKU__c IN :SKU]){
            blogs.put(objCS.SKU__c, objCS);
        }
       // List<Content__c> blogs = [SELECT Id, Content_Name__c,SKU__c, Author__c,Description__c,Third_Party_URL__c,Published_Date__c  from Content__c WHERE SKU__c IN :SKU];
        for(Content__c blogEntry : blogEntries) {
            Boolean added = false;
         /*   for(Content__c blog : blogs) {
                if(blog.SKU__c == blogEntry.SKU__c) {
                    added = true;
                    break;
                }
            }*/
            if(blogs.containsKey(blogEntry.SKU__c)){
                added = true;
            }
            if(!added){
                entriesToAdd.add(blogEntry); 
            }
        }
        insert entriesToAdd;        
        system.debug('entriesToAdd=======>'+entriesToAdd);
        // Add the podcast items to podcast library folder in related content folder
        if(entriesToAdd.size()>0){
            for(Content__c RelatedContentFolder :entriesToAdd){
                BlogContentFolderEntries = new Content_Folders__c();
                BlogContentFolderEntries.name = RelatedContentFolder.Name ;
                BlogContentFolderEntries.Folder__c = System.Label.PodcastFolder;
                BlogContentFolderEntries.Content__c = RelatedContentFolder.id;
                entriesToAddContentFolder.add(BlogContentFolderEntries);
            }
            insert entriesToAddContentFolder;
        }
    }
    
    // Checking the RSSfeed endpoint
    static global List<Dom.XMLNode> getRSSFeed(string URL) {
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        
        // url that returns the XML in the response body  
        req.setEndpoint(url);
        req.setMethod('GET');
        HttpResponse res = h.send(req);
        String xml =res.getBody().replaceAll( '<!\\[CDATA\\[', 'XML_CDATA_START' ).replaceAll( ']]>', 'XML_CDATA_END' );
        
        // replace CDATA sections with parseable tokens
        // xml = xml.replaceAll( '<!\\[CDATA\\[', 'XML_CDATA_START' ).replaceAll( ']]>', 'XML_CDATA_END' );
        
        // we will build up a map of original text and replacement text
        Map<String, String> replacementMap = new Map<String, String>();
        
        // regular expression to match sections we want to replace
        // Pattern myPattern = Pattern.compile( '(XML_CDATA_START)(.*?)(XML_CDATA_END)' );
        Matcher myMatcher = Pattern.compile( '(XML_CDATA_START)(.*?)(XML_CDATA_END)' ).matcher( xml );
        while ( myMatcher.find() ) {
            
            // the regex was too complicated for Matcher.replaceFirst(..)
            // so have to do it manually so just put in this map the
            // original text and the replacement text, we do replacing later
            replacementMap.put( myMatcher.group(), myMatcher.group(2).escapeXML() );
        }
        
        // replace in the xml each CDATA section with the escaped XML of its inner content
        for ( String key : replacementMap.keySet() ) {
         xml = xml.replace( key, replacementMap.get( key ) );
        }
        List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
        rssList = documentXml(xml);
        return rssList;
        
    }
    
    static global List<Dom.XMLNode> documentXml(String xml){
        Dom.Document doc = new Dom.Document();
        doc.load(xml);
        Dom.XMLNode rss = doc.getRootElement();        
        List<Dom.XMLNode> rssList = new List<Dom.XMLNode>();
        for(Dom.XMLNode child : rss.getChildren()) {
            for(Dom.XMLNode channel : child.getChildren()) {
                if(channel.getName() == 'item') {
                    rssList.add(channel);
                }
            }
        }
        return rssList;
    }
    
    // Storing each post as a record in content
    static global Content__c  convertFeedToBlogPost(Dom.XMLNode post) {
        Content__c  bp = new Content__c ();
        Integer tagIndex = 0;
        DateTime dt;
        for(Dom.XMLNode child : post.getChildren()) {
        system.debug('child.getName()======>'+child.getName());
            if(child.getName() == 'title') {
                String newName = child.getText();
                bp.Content_Name__c = newName;
                if(newName.length() > 80) {
                    bp.Name = newName.left(80);
                } else {
                	bp.Name =  newName; 
                }
                
            } 
            if(child.getName() == 'pubDate') { 
                String year = child.getText().substring(12, 16);
                String day = child.getText().substring(5, 7);
                String month = child.getText().substring(8, 11);
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
            }
            if(child.getName() == 'link') { 
                bp.Third_Party_URL__c = child.getText(); 
            }
            if(child.getName() == 'image') { 
                bp.Image__c = child.getAttributeValue('href', ''); 
            }
            if(child.getName() == 'description') { 
                bp.Story__c = child.getText(); 
            }
            if(child.getName() == 'summary') { 
                bp.Description__c = child.getText(); 
            }
            if(child.getName() == 'itemId') {
                bp.SKU__c  = child.getText(); 
            }
            bp.Media_Type__c = 'Audio';
            bp.RecordTypeId = Schema.SObjectType.Content__c.getRecordTypeInfosByName().get('Podcast').getRecordTypeId();
            bp.Status__c = 'Active';
        }
        return bp;      
    }
}