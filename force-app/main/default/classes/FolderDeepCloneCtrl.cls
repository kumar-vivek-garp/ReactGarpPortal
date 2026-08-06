public class FolderDeepCloneCtrl {

    public FolderDeepCloneCtrl(ApexPages.StandardController ctrl){}
    
    public PageReference doDeepClone(){      
        
        Map<Id, Folder__c> clonedFolderMap =  new Map<Id, Folder__c>(); 
        Map<Id, Content_Folders__c> clonedContentFolderMap =  new Map<Id, Content_Folders__c>(); 
        
        Savepoint sp = Database.setSavepoint();

        try{
        
            for(Folder__c f: [
                SELECT 
                Id, 
                Name 
                FROM Folder__c 
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                Folder__c cloned = f.clone(false);
                cloned.Name = f.Name + ' - copy';
                clonedFolderMap.put(f.Id, cloned);
            }
            
            INSERT clonedFolderMap.values();
            
            for(Content_Folders__c cf: [
                SELECT 
                Id, 
                Name, 
                Folder__c,
                Content__c,
                Sort_Number__c
                FROM Content_Folders__c 
                WHERE Folder__c = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                Content_Folders__c cloned = cf.clone(false);
                cloned.Folder__c = (cf.Folder__c != null) ? clonedFolderMap.get(cf.Folder__c).Id : null;
                clonedContentFolderMap.put(cf.Id, cloned);
            }
                
            INSERT clonedContentFolderMap.values();
            
        }catch(Exception e){

            Database.rollback(sp);
            
            ApexPages.addMessages(e);
            
            return null;
            
        }
        
        Id clonedFolderId = clonedFolderMap.get(ApexPages.currentPage().getParameters().get('Id')).Id;
        
        PageReference ref = new PageReference('/' + clonedFolderId + '/e');
        
        ref.getParameters().put('retURL','/' + clonedFolderId);
        
        ref.setRedirect(true);
        
        return ref;   
        
    }
    
}