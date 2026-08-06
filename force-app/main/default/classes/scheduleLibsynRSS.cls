global class scheduleLibsynRSS implements Schedulable {
        
    global void execute(SchedulableContext c) {
        
        // GARP Risk
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/96199/rss/?include-libsyn-metadata=true');
        
        // Climate Risk
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/284498/rss/?include-libsyn-metadata=true');
        
        // New Age
        LibysnClass.getLibsynRSSFeed('https://feeds.libsyn.com/176627/rss/?include-libsyn-metadata=true');
                                      
    }
}