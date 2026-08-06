@IsTest
public class CPDNewsletterGeneratorCtrlTest {

    public static String applicationReference = 'CPD Newsletter Generator';
    
    @TestSetup
    private static void setup(){
        
        CPE_Activity_Type__c cpeat = new CPE_Activity_Type__c();
        cpeat.Active__c = true;
        cpeat.Name = 'Activity Type Name Test';
        
        INSERT cpeat;
        
        List<CPE_Activity__c> cpeActivities = new List<CPE_Activity__c>();
            
        for(Integer i = 0; i < 100; i++){
            cpeActivities.add(new CPE_Activity__c(
                Name = 'TEST' + i, 
                Title__c = 'TEST' + i, 
                Description__c = 'TEST' + i, 
                Location__c = 'NY, New York', 
                CPE_Activity_Type__c = cpeat.Id, 
                Activity_Type_Description__c = 'TEST DESC', 
                Area_of_Study__c = 'Finance', 
                Credit__c = 2, 
                Date_Description__c = 'May 2017'
            ));                
        }
            
        INSERT cpeActivities;
        
        Content_Selector__c cs = new Content_Selector__c();
        cs.Name = 'Test List 01';
        cs.Application_Reference__c = applicationReference;
        cs.Content_IDs__c = cpeActivities[0].Id;
        
        INSERT cs;
        
    }
    
    @IsTest
    private static void doSelectRemoveSortUpSortDownSave(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();            
        
        nextPageCtrl.cpeActivityId = [SELECT Id FROM CPE_Activity__c LIMIT 1].Id;
        
        nextPageCtrl.doSelect();
        
        nextPageCtrl.doRemove();
        
        nextPageCtrl.doSelect();
        
        nextPageCtrl.moveItemDn();
        
        nextPageCtrl.moveItemUp();
        
        nextPageCtrl.moveGroupDn();
        
        nextPageCtrl.moveGroupUp();
              
        nextPageCtrl.doSave();
        
        nextPageCtrl.doGenerateHTML();
        
    }
    
    @IsTest
    private static void paginateNext(){

        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();     
        
        nextPageCtrl.doFilter();
        
        nextPageCtrl.next();
        
    }
    
    @isTest static void generateHTML(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();  
        
        nextPageCtrl.doGenerateHTML();
        
    }
    
    @IsTest
    private static void paginatePrev(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();  
        
        nextPageCtrl.doFilter();
        
        nextPageCtrl.prev();
        
    }
    
    @IsTest
    private static void doSave(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();  
        
        nextPageCtrl.doSave();
        
    }
    
    @IsTest
    private static void doDelete(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);  
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();    
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();  
        
        nextPageCtrl.doDelete();
        
    }
    
    @IsTest
    private static void openExistingList(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();        
        
        ctrl.metadataListId = [SELECT Id, Name, Application_Reference__c FROM Content_Selector__c WHERE Application_Reference__c = :applicationReference LIMIT 1].Id;
        
        PageReference nextPageReference = ctrl.doOpen();
                      
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl();     
        
    }
    
    @IsTest
    private static void createNewListWithNullName(){
        
        PageReference ref = Page.CPDNewsletterGenerator;
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();        

        ctrl.doSaveAs();
      
        System.assert(ApexPages.getMessages().size() > 0);

    }
    
    @IsTest
    private static void createNewListWithDuplicateName(){
        
        PageReference ref = Page.CPDNewsletterGenerator;
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();        
        
        ctrl.metadataListName = 'Test List 01';
        ctrl.doSaveAs();
              
        System.assert(ApexPages.getMessages().size() > 0);
        
    }
    
    @IsTest
    private static void createNewList(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();        
        
        ctrl.metadataListName = 'Test List 02';
        
        PageReference nextPageReference = ctrl.doSaveAs();
              
        System.assertEquals([SELECT Id, Name FROM Content_Selector__c WHERE Name = 'Test List 02' LIMIT 1].Name, 'Test List 02');
        
        Test.setCurrentPage(nextPageReference);
        
        CPDNewsletterGeneratorCtrl nextPageCtrl = new CPDNewsletterGeneratorCtrl(); 
        
        nextPageCtrl.doDelete();
        
    }

    @IsTest
    private static void doNew(){
        
        PageReference currentPageRef = Page.CPDNewsletterGenerator;
        
        Test.setCurrentPage(currentPageRef);
        
        CPDNewsletterGeneratorCtrl ctrl = new CPDNewsletterGeneratorCtrl();        
        
        ctrl.doNew();
        
    }
    
}