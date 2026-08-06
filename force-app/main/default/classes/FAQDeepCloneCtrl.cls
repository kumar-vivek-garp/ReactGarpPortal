public class FAQDeepCloneCtrl {
    
    public FAQDeepCloneCtrl(ApexPages.StandardController ctrl){}
    
    public PageReference doDeepClone(){      
        
        Map<Id, FAQ_Category__c> clonedFAQCategoryMap                               = new Map<Id, FAQ_Category__c>();       
        Map<Id, FAQ_Section__c> clonedFAQSectionMap                                 = new Map<Id, FAQ_Section__c>(); 
        Map<Id, FAQ_Subsection__c> clonedFAQSubsectionMap                           = new Map<Id, FAQ_Subsection__c>(); 
        Map<Id, Frequently_Asked_Questions__c> clonedFrequentlyAskedQuestionsMap    = new Map<Id, Frequently_Asked_Questions__c>(); 
        
        Savepoint sp = Database.setSavepoint();

        try{
        
            for(FAQ_Category__c faqc: [
                SELECT 
                Id, 
                Name 
                FROM FAQ_Category__c 
                WHERE Id = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                FAQ_Category__c cloned = faqc.clone(false);
                cloned.Name = faqc.Name + ' - copy';
                clonedFAQCategoryMap.put(faqc.Id, cloned);
            }
            
            INSERT clonedFAQCategoryMap.values();
            
            for(FAQ_Section__c faqs: [
                SELECT 
                Id, 
                Name, 
                FAQ_Category__c,
                Section_Order_Number__c
                FROM FAQ_Section__c 
                WHERE FAQ_Category__c = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                
                System.debug('faqs:' + faqs);
                
                FAQ_Section__c cloned = faqs.clone(false);
                cloned.FAQ_Category__c = (faqs.FAQ_Category__c != null) ? clonedFAQCategoryMap.get(faqs.FAQ_Category__c).Id : null;
                clonedFAQSectionMap.put(faqs.Id, cloned);
            }
                
            INSERT clonedFAQSectionMap.values();
            
            for(FAQ_Subsection__c faqss: [
                SELECT 
                Id, 
                Name, 
                FAQ_Category__c,
                FAQ_Section__c,
                Related_Section_Order_Number__c,
                Subsection_Order_Number__c
                FROM FAQ_Subsection__c 
                WHERE FAQ_Category__c = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                FAQ_Subsection__c cloned = faqss.clone(false);
                cloned.FAQ_Category__c  = (faqss.FAQ_Category__c != null) ? clonedFAQCategoryMap.get(faqss.FAQ_Category__c).Id : null;
                cloned.FAQ_Section__c   = (faqss.FAQ_Section__c != null) ? clonedFAQSectionMap.get(faqss.FAQ_Section__c).Id : null;
                clonedFAQSubsectionMap.put(faqss.Id, cloned);
            }
            
            INSERT clonedFAQSubsectionMap.values();
            
            for(Frequently_Asked_Questions__c faqs: [
                SELECT 
                Id, 
                Name, 
                FAQ_Category__c, 
                FAQ_Section__c, 
                FAQ_Subsection__c,
                FAQ_Answer__c,
                FAQ_Question__c,
                FAQ_Rank__c,
                FAQ_Section_Order__c,
                FAQ_Subsection_Order__c,
                Related_Subsection__c
                FROM Frequently_Asked_Questions__c 
                WHERE FAQ_Category__c = :ApexPages.currentPage().getParameters().get('Id')
            ]){
                Frequently_Asked_Questions__c cloned = faqs.clone(false);
                cloned.FAQ_Category__c      = (faqs.FAQ_Category__c != null) ? clonedFAQCategoryMap.get(faqs.FAQ_Category__c).Id : null;
                
                if(faqs.FAQ_Section__c != null) {
                    FAQ_Section__c fndSec = clonedFAQSectionMap.get(faqs.FAQ_Section__c);
                    if(fndSec != NULL) {
                        cloned.FAQ_Section__c = fndSec.Id;
                    }
                } else {
                    cloned.FAQ_Section__c = NULL;
                }
                
                //cloned.FAQ_Section__c       = (faqs.FAQ_Section__c != null) ? clonedFAQSectionMap.get(faqs.FAQ_Section__c).Id : null;
                
                
                if(faqs.FAQ_Subsection__c != null) {
                    FAQ_Subsection__c fndSec = clonedFAQSubsectionMap.get(faqs.FAQ_Subsection__c);
                    if(fndSec != NULL) {
                        cloned.FAQ_Subsection__c = fndSec.Id;
                    }
                } else {
                    cloned.FAQ_Subsection__c = NULL;
                }
                
                //cloned.FAQ_Subsection__c    = (faqs.FAQ_Subsection__c != null) ? clonedFAQSubsectionMap.get(faqs.FAQ_Subsection__c).Id : null;
                
                clonedFrequentlyAskedQuestionsMap.put(faqs.Id, cloned);                        
            }
            
            INSERT clonedFrequentlyAskedQuestionsMap.values();
            
        }catch(Exception e){
            
            Database.rollback(sp);
            
            System.debug(e.getStackTraceString());
            
            ApexPages.addMessages(e);
            
            return null;
            
        }
        
        Id clonedFaqCategoryId = clonedFAQCategoryMap.get(ApexPages.currentPage().getParameters().get('Id')).Id;
        
        PageReference ref = new PageReference('/' + clonedFaqCategoryId + '/e');
        
        ref.getParameters().put('retURL','/' + clonedFaqCategoryId);
        
        ref.setRedirect(true);
        
        return ref;    
        
    }
    
}