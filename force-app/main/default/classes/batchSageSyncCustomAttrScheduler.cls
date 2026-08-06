global class batchSageSyncCustomAttrScheduler implements Schedulable{
     string recordId;
     string whereClause;
     global void execute(SchedulableContext sc) {
     	String inputWhereClause = whereClause;
        String inputRecordId = recordId;
         
		Database.executeBatch(new batchSageSyncCustomAttr(inputWhereClause),100);  
        Database.executeBatch(new batchSageSyncCustomAttr(inputWhereClause,inputRecordId),100);  
        
     }
}