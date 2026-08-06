global class CalculateExperienceBatch_Scheduler implements Schedulable{
    global void execute(SchedulableContext sc) { 
        Database.executeBatch(new CalculateExperience_Batch());        
    }
}