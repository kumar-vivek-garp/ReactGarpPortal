public class cloudFilesRelatedList {
    
    public List<cdrive__Cloud_Files__c> Records {get; set;}
    public List<cloudFile > cfRecords {get; set;}
    public Content__c Record {get; set;}
    public String delId {get; set;}
    public String jsonFileList {get; set;}
    public String recId {get; set;}
    
    public class cloudFile
    {
        public Id cfId {get; set;}
        public String fileName {get; set;}
        public String url {get; set;}
    }
        
    public void loadData() {
        
        Records = [Select Id, cdrive__File_Name__c, Public_URL__c FROM cdrive__Cloud_Files__c where cdrive__contextID__c =:recId];
        system.debug('Records:' + Records);
        
        cfRecords = new List<cloudFile >();        
        for(cdrive__Cloud_Files__c cf :Records) {
            cloudFile crr = new cloudFile();
            crr.cfId = cf.Id;
            crr.fileName = cf.cdrive__File_Name__c;
            crr.url = cf.Public_URL__c;
            cfRecords.add(crr);
        }
        jsonFileList = JSON.serialize(cfRecords);
        system.debug('cfRecords:' + cfRecords);
    }
    
    public cloudFilesRelatedList(ApexPages.StandardController controller)
    {
        Record = (Content__c) controller.getRecord(); 
        recId = Record.Id;
        loadData();
    }      
    
    
    public PageReference deleteCloudFile()
    {
        system.debug('delId:' + delId   );
        cdrive__Cloud_Files__c cf = [Select Id, cdrive__File_Name__c, Public_URL__c FROM cdrive__Cloud_Files__c where Id =:delId];
        system.debug('cf:' + cf);
        if(cf != NULL) {
            delete cf;
        }
        return null ;
    }
    
    public PageReference uploadFile()
    {   
        return new PageReference('https://garp--cdrive.na87.visual.force.com/apex/CloudDriveUploadView?contextName=Content__c&contextID=' + Record.Id);
    }

    public PageReference refresh()
    {   
        loadData();
        return null;
    }
    
    public PageReference editContactRole()
    {
        String id1 = System.currentPageReference().getParameters().get('recordId');        
        return new PageReference('/' + id1 + '/e?retURL=%2F0014000000IxCgi');
    }
}