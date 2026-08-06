@isTest
public class FolderDeepCloneCtrlTest {

    @testSetup
    public static void setup(){

		Content__c c = new Content__c();
        
        c.Name = 'TESTCONTENT';
        
        INSERT c;
        
        Folder__c f = new Folder__c();
		
		f.Name = 'TESTFOLDER';
	        
        INSERT f;
        
        Content_Folders__c cf = new Content_Folders__c();
        
        cf.Name = 'TESTCONTENTFOLDER';
        cf.Folder__c = f.Id;
        cf.Content__c = c.Id;
        
        INSERT cf;
        
    }
    
    @isTest
    public static void pass(){
        
        PageReference currentPageRef = Page.FolderDeepClone;
        
        Test.setCurrentPage(currentPageRef);  
        
        currentPageRef.getParameters().put('id', [SELECT Id, Name FROM Folder__c WHERE Name = 'TESTFOLDER' LIMIT 1].Id);
               
        FolderDeepCloneCtrl ctrl = new FolderDeepCloneCtrl(new ApexPages.StandardController([SELECT Id, Name FROM Folder__c WHERE Name = 'TESTFOLDER' LIMIT 1]));    
        
        PageReference nextPageReference = ctrl.doDeepClone();
        
        Test.setCurrentPage(nextPageReference);
                
    }
      
}