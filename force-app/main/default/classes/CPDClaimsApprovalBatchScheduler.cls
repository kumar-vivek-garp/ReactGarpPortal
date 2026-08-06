global class CPDClaimsApprovalBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
        
          Database.executeBatch(new CPDClaimsApprovalBatchClass(), 5);
    }
        
}