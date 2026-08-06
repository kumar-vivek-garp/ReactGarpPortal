public class TableauIntegrationQueueable implements Queueable, Database.AllowsCallouts {
    public class TableauIntegrationCls{
        public String UpdateType;
        public String RecordId;
        public String ContractId;
    }
    private final List<TableauIntegrationCls> tableauIntList;
    // Constructor 
    public TableauIntegrationQueueable(List<TableauIntegrationCls> tableauList) {
         this.tableauIntList = tableauList;
    }
    
    // The execute method that runs the logic
    public void execute(QueueableContext context) {
        try{ 
            Map<String,String> lstCreateUserIdsMap = new Map<string,String>();
            Map<String,String> lstRemoveUserIdsMap = new Map<string,String>();
            Integer counter = 0;
            for(TableauIntegrationCls event : tableauIntList){ 
                counter++;    
                if (counter >  90) { break;}
                if(event.RecordId != NULL && event.UpdateType == 'CreateUser') {  
                    lstCreateUserIdsMap.put(event.RecordId,event.ContractId);
                } 
                if(event.RecordId != NULL && event.UpdateType == 'RemoveUser') { 
                    lstRemoveUserIdsMap.put(event.RecordId,event.ContractId);
                }  
            } 
            if(!lstCreateUserIdsMap.isEmpty() && !Test.isRunningTest()) {
                Tableau_IntegrationClass.tableauIntegration('CreateUser',lstCreateUserIdsMap);   
            } 
            if(!lstRemoveUserIdsMap.isEmpty() && !Test.isRunningTest()) {
                Tableau_IntegrationClass.tableauIntegration('RemoveUser',lstRemoveUserIdsMap);   
            } 
        }catch(Exception ex){  System.debug('TableauIntegrationTrigger Exception:' + ex.getMessage());  }
    }
}