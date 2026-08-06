global class addThisFeedJob implements Schedulable {
    
    global void execute(SchedulableContext SC) {
        addThisFeed.getFeedMethod();  
    }
}