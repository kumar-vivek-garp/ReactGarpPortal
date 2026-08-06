public class B2BOpportunityAttachment { 
    
  public string opptyId {get;set;}
  public attachment doc {get;set;}
   
 /* public B2BOpportunityAttachment(){
        this.opptyId = ApexPages.currentPage().getParameters().get('opptyId');
        
    }*/

  public PageReference getFile() {

   opptyId = ApexPages.currentPage().getParameters().get('Id');
   List<attachment> lstdoc = [SELECT Id, Name, BodyLength, LastModifiedDate, parentId, Body from Attachment WHERE parentId = :opptyId order by LastModifiedDate desc];
   system.debug('Opp Id is' +lstdoc[0]);
   if(lstdoc.size()>0)
   {
    doc = lstdoc[0];
 }  
     
   return null; 
   
}
 
 }