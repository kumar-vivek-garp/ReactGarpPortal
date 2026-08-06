@isTest
public class cloudFilesRelatedList_test {
	
    public static cdrive__Cloud_Files__c  cf;
    
    @isTest
    public static void testRelatedListGARP(){
        
        Chapter_Speaker__c ev = new Chapter_Speaker__c(Name='Chapter_Speaker__c');
        insert ev;
        
        cdrive__Cloud_Files__c cf = new cdrive__Cloud_Files__c (cdrive__File_Name__c='file', cdrive__contextID__c=ev.Id);
        insert cf;
        
        cdrive__AWS_Account__c caws = new cdrive__AWS_Account__c(
            Name = 'GARP Prod',
            cdrive__Access_Key_ID__c = '123',
            cdrive__Secret_Access_Key__c = 'abc'
        );
        insert caws;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ev);
        cloudFilesRelatedListGARP cfrle = new cloudFilesRelatedListGARP(sc);
        
        cfrle.loadData();
        cfrle.uploadFile();
        cfrle.refresh();
        cfrle.editContactRole();
        cfrle.delId = cf.id;
        cfrle.deleteCloudFile();
        
        
        Test.stopTest();
    }

    
    @isTest
    public static void testEvents(){
       
        Event__c ev = new Event__c(Name='Event');
        insert ev;

        cdrive__Cloud_Files__c cf = new cdrive__Cloud_Files__c (cdrive__File_Name__c='file', cdrive__contextID__c=ev.Id);
        insert cf;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ev);
        cloudFilesRelatedListEvent cfrle = new cloudFilesRelatedListEvent(sc);
        
        cfrle.loadData();
        cfrle.uploadFile();
        cfrle.refresh();
        cfrle.editContactRole();
        cfrle.delId = cf.id;
        cfrle.deleteCloudFile();
        
        
        Test.stopTest();
    }
    
    @isTest
    public static void test2(){
        
        Content__c ct = new Content__c(Name='Content');
        insert ct;
        
        cdrive__Cloud_Files__c cf = new cdrive__Cloud_Files__c (cdrive__File_Name__c='file', cdrive__contextID__c=ct.Id);
        insert cf;
        
        Test.startTest();
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ct);
        cloudFilesRelatedList cfrl = new cloudFilesRelatedList(sc);
        
        cfrl.loadData();
        cfrl.uploadFile();
        cfrl.refresh();
        cfrl.editContactRole();
        cfrl.delId = cf.id;
        cfrl.deleteCloudFile();
        
        
        Test.stopTest();
    }    
}