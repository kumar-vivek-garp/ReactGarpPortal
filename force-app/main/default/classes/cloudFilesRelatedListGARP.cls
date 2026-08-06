public class cloudFilesRelatedListGARP {
    
    public List<cdrive__Cloud_Files__c> Records {get; set;}
    public List<cloudFile > cfRecords {get; set;}
    public Content__c Record {get; set;}
    public String delId {get; set;}
    public String jsonFileList {get; set;}
    public String recId {get; set;}
    public String classType {get; set;}
    
    public String awskey {get; set;}
    public String awssec {get; set;}
    
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
    
    public cloudFilesRelatedListGARP(ApexPages.StandardController controller)
    {
        List<cdrive__AWS_Account__c> lstAWSAcct = [select Id, cdrive__Access_Key_ID__c, cdrive__Secret_Access_Key__c from cdrive__AWS_Account__c where Name = 'GARP Prod'];
        if(!lstAWSAcct.isEmpty()) {
            awskey = lstAWSAcct[0].cdrive__Access_Key_ID__c;
            awssec = lstAWSAcct[0].cdrive__Secret_Access_Key__c;
        }

        recId = controller.getRecord().Id; 
        //recId = Record.Id;
        loadData();
        
        classType = controller.getRecord().getSObjectType().getDescribe().getName();
        system.debug('classType:' + classType);
               
       
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
        
        String pageURL = ApexPages.currentPage().getUrl();
        
        if(pageURL != NULL && pageURL.IndexOf('preprod') > -1) {
        	return new PageReference('https://garp--preprod--cdrive.sandbox.vf.force.com/apex/CloudDriveUploadView?contextName=' + classType + '&contextID=' + recId);    
        } else {
            return new PageReference('https://garp--cdrive.vf.force.com/apex/CloudDriveUploadView?contextName=' + classType + '&contextID=' + recId);
        }
        
        
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