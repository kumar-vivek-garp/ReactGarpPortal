public class GARP_BC_MemberContent {

    // Wrappers
    public class contentData {
        public Content__c content { get; set; }
        public Attachment attachment { get; set; }
        public List<Related_Content__c> related_content { get; set; }
        public String memberTypeRequiredForAccess { get; set; }
        Integer rank { get; set; }
    }    
    
    public static  List<contentData> getContentDocs(String name){
        List<Content__c> lstDocs;
        List<contentData> lstContentData = new List<contentData>();
        
        List<Folder__c> lstfolder = [Select Id from Folder__c where Name = :name];
        if( lstfolder != null && lstfolder.size() > 0 ) {
            lstDocs = [SELECT Id,Name,Tagline__c,Content_Name__c,RecordTypeId,Description__c,SKU__c, Is_advertisement__c, Image__c,Third_Party_Author__c, Author__r.Name,Content_Type__c,Featured__c, Published_Date__c,Story__c,Start_Date__c,Lead_Gen_URL__c,
                       Topic__c, 
                       End_Date__c, 
                       Third_Party_URL__c, 
                       Third_Party_Portal_URL__c, 
                       Duration_in_Minutes__c, 
                       Event_Start_Date_Time__c, 
                       Is_On_Demand__c, 
                       Moderators__c, 
                       Presenters__c, 
                       Visibility_ERP__c, 
                       Visibility_FRM__c, 
                       Visibility_SCR__c, 
                       Visibility_Membership__c, 
                       Location__c, 
                       Display_Sort_Order__c,
                       Next_Version__c,
                       Next_Version__r.Content_Name__c,
                       Next_Version__r.Lead_Gen_URL__c
                       FROM Content__c 
                       WHERE Status__c = 'Active' AND Id in (SELECT Content__c FROM Content_Folders__c WHERE Folder__c = :lstfolder[0].Id) ORDER BY Display_Sort_Order__c
                      ];
            
            if( lstDocs != null && lstDocs.size() > 0 ) {
                
                GARP_BC_MemberContent sr = new GARP_BC_MemberContent();        
                lstContentData = sr.filterContentDocs(lstDocs, null); 
                List<ID> ids = new List<ID>();
                for(contentData cont :lstContentData) {
                    ids.add(cont.content.Id);
                }
                List<cdrive__Cloud_Files__c> lstCloudFiles = [select Id, cdrive__contextID__c, cdrive__File_Name__c from cdrive__Cloud_Files__c where cdrive__contextID__c in :ids];
                MAP<String,cdrive__Cloud_Files__c> mapCloudFiles = new MAP<String,cdrive__Cloud_Files__c>();
                if(lstCloudFiles != null && lstCloudFiles.size() > 0) {
                    for(cdrive__Cloud_Files__c cf :lstCloudFiles) {
                        mapCloudFiles.put(cf.cdrive__contextID__c + '~' + cf.cdrive__File_Name__c, cf);
                    }                    
                    for(contentData cont :lstContentData) {
                        cdrive__Cloud_Files__c fnd = mapCloudFiles.get(cont.content.id + '~' + cont.content.Image__c);
                        if(fnd != null) {
                            cont.content.Image__c = 'https://s3-us-west-2.amazonaws.com/garpsalesforcepublic/Content__c/' + cont.content.Id + '/' + fnd.Id + '_' + cont.content.Image__c;
                        }
                    }
                }
            }
        }        
        return lstContentData;
    }
    
    public List<contentData> filterContentDocs(List<Content__c> lstDocs, Integer maxReturn) {
        
        List<User> users = [SELECT Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId()];
        if(Test.isRunningTest()) {
            users = [SELECT Id, ContactId, AccountId FROM User where Email = 'test.user.1234@garpqa.com'];
        }
        
        List<Attachment> lstAttachments;
        List<Related_Content__c> lstRelated;
        List<contentData> lstContentData = new List<contentData>();
        
        Map<String, List<Contract>> contractsByRecordTypeName = new Map<String, List<Contract>>();
        
        Boolean bFRMCandidate = false;
        Boolean bFRMHolder = false;
        Boolean bFRMCertified = false;
        
        Boolean bERPCandidate = false;
        Boolean bERPHolder = false;
        Boolean bERPCertified = false;
        
        Boolean bSCRCandidate = false;
        Boolean bSCRHolder = false;
        Boolean bSCRCertified = false;
        
        String memberType = '';
        String frmStatus;
        String erpStatus;
        String memStatus;
        
        Integer cnt = 0;
        
        if(!users.isEmpty()) {
            
            User user = users[0];
            
            List<Contact> lstContact = [
                SELECT Id, Name, KPI_FRM_Candidate_Payment_Status__c, KPI_ERP_Candidate_Payment_Status__c, KPI_Membership_Payment_Status__c, KPI_FRM_Candidate__c, KPI_FRM_Holder__c, KPI_FRM_Certified__c, KPI_ERP_Candidate__c, KPI_ERP_Holder__c, KPI_ERP_Certified__c,Membership_Type__c  
                FROM Contact 
                WHERE Id = :user.ContactId
            ];
            
            List<Contract> contracts = [
                SELECT Id, AccountId, RecordType.Name, Status, All_Requirements_Completed_Date__c
                FROM Contract
                WHERE AccountId = :user.AccountId
            ];
            
            // Group Contracts by Record Type Name
            for(Contract contract: contracts){
                String recordTypeName = contract.RecordType.Name;
                if(contractsByRecordTypeName.containsKey(recordTypeName)){
                    // Add a Contract element to the map array for a given Contract Record Type
                    contractsByRecordTypeName.get(recordTypeName).add(contract);
                }else{
                    // Initialize a list and add a Contract element for a given Contract Record Type
                    contractsByRecordTypeName.put(recordTypeName, new List<Contract>{contract});
                }
            }
            
            if( lstContact != null && lstContact.size() > 0 ) {
                Contact cont = lstContact[0];
                bFRMCandidate = cont.KPI_FRM_Candidate__c;
                bFRMHolder = cont.KPI_FRM_Holder__c;
                bFRMCertified = cont.KPI_FRM_Certified__c;
                
                bERPCandidate = cont.KPI_ERP_Candidate__c;
                bERPHolder = cont.KPI_ERP_Holder__c;
                bERPCertified = cont.KPI_ERP_Certified__c;
                
                bSCRCandidate = false;
                bSCRHolder = false;
                bSCRCertified = false;
                
                memberType = cont.Membership_Type__c;
                frmStatus = cont.KPI_FRM_Candidate_Payment_Status__c;
                erpStatus = cont.KPI_ERP_Candidate_Payment_Status__c;
                memStatus = cont.KPI_membership_Payment_Status__c;
                
                // Data mine SCR Contract
                if(contractsByRecordTypeName.containsKey('SCR Program')){
                    for(Contract scrContract: contractsByRecordTypeName.get('SCR Program')){
                        if(scrContract.Status == 'Activated'){
                            bSCRCandidate = true;
                        }
                    }
                }
                
            }
        }
        
        if( lstDocs != null && lstDocs.size() > 0 ) {           
            lstAttachments = [Select Id, Name, ParentId from Attachment where ParentId in :lstDocs order by LastModifiedDate];
            
            for(Content__c doc :lstDocs){    
                contentData contentData = new contentData();
                contentData.content = doc;
                datetime nowDateTime = datetime.now();
                Boolean addContent = true;
                if(doc.End_Date__c == null && doc.Start_Date__c != null && nowDateTime >= doc.Start_Date__c) {
                    addContent = true;
                } else if(doc.Start_Date__c == null && doc.End_Date__c != null && nowDateTime < doc.End_Date__c) {
                    addContent = true;
                } else if(doc.Start_Date__c != null && doc.End_Date__c != null && nowDateTime >= doc.Start_Date__c && nowDateTime < doc.End_Date__c) {
                    addContent = true;
                } else if(doc.Start_Date__c == null && doc.End_Date__c == null){
                    addContent = true;
                }
                
                Boolean addVisContent = false;
                if(doc.Visibility_FRM__c != null) {
                    if(
                        (doc.Visibility_FRM__c == 'Certified' && bFRMCertified) ||
                        (doc.Visibility_FRM__c == 'Holder' && (bFRMCertified || bFRMHolder)) ||
                        (doc.Visibility_FRM__c == 'Candidate' && bFRMCandidate)
                    ) {
                        if(frmStatus != null && frmStatus == 'In Good Standing') {
                            addVisContent = true;    
                        }
                    }
                }
                if(doc.Visibility_ERP__c != null) {
                    if(
                        (doc.Visibility_ERP__c == 'Certified' && bERPCertified) ||
                        (doc.Visibility_ERP__c == 'Holder' && (bERPCertified || bERPHolder)) ||
                        (doc.Visibility_ERP__c == 'Candidate' && bERPCandidate)
                    ) {
                        if(erpStatus != null && erpStatus == 'In Good Standing') {
                            addVisContent = true;
                        }
                    }
                }
                if(doc.Visibility_SCR__c != null) {
                    if(
                        (doc.Visibility_SCR__c == 'Certified' && bSCRCertified) ||
                        (doc.Visibility_SCR__c == 'Holder' && (bSCRCertified || bSCRHolder)) ||
                        (doc.Visibility_SCR__c == 'Candidate' && bSCRCandidate)
                    ) {
                        addVisContent = true;
                    }
                }
                if(doc.Visibility_Membership__c != null) {
                    if(doc.Visibility_Membership__c == 'Paid' && (memberType == 'Individual' || memberType == 'Student')) {
                        //Membership has lapsed 
                        if(memStatus != null && memStatus == 'In Good Standing') {
                            contentData.memberTypeRequiredForAccess = 'N/A';   
                        }
                        else {
                            contentData.memberTypeRequiredForAccess = doc.Visibility_Membership__c;    
                        }
                    }  
                    else {
                        //Does not have the Requisite permissions to view the article
                        contentData.memberTypeRequiredForAccess = doc.Visibility_Membership__c;   
                    }  
                }
                if(doc.Visibility_FRM__c == null && doc.Visibility_ERP__c == null && doc.Visibility_SCR__c == null && doc.Visibility_Membership__c == null) {
                    contentData.memberTypeRequiredForAccess = 'N/A'; 
                }
                
                if(addContent == true && ((doc.Visibility_FRM__c == null && doc.Visibility_ERP__c == null && doc.Visibility_SCR__c == null) || addVisContent == true)) {
                    for(Attachment att :lstAttachments){
                        if(att.ParentId == doc.Id) {
                            contentData.attachment = att;
                            break;
                        }
                    }
                    
                    lstContentData.add(contentData);
                    cnt++;
                    if(maxReturn != null && cnt >= maxReturn)
                        break;
                }    
            }                
        }                
        return lstContentData;
        
    }
    
}