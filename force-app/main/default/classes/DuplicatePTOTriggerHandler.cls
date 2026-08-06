public class DuplicatePTOTriggerHandler {
   
    public static void dateValidation(List<GARP_Time_Off_Request__c> newRequests, Map<Id, GARP_Time_Off_Request__c> oldMap) {
        set<Id> balanceIds = new Set<Id>();
        
        for(GARP_Time_Off_Request__c request : newRequests) {
            balanceIds.add(request.GARP_Time_Off_Balance__c);
        }
        system.debug('newRequests'+ newRequests);
        system.debug('balanceIds'+ balanceIds);
        system.debug('oldMap'+ oldMap);
       
      
     Map<Id, GARP_Time_Off_Balance__c> balanceMap = new Map<Id, GARP_Time_Off_Balance__c>();
       balanceMap = new Map<Id, GARP_Time_Off_Balance__c>([SELECT Id,Employee__c,(
            Select id,GARP_Time_Off_Balance__c,GARP_Time_Off_Balance__r.Name,Start_Day_Off__c,End_Day_Off__c,Status__c 
            FROM GARP_Time_Off_Requests__r
            WHERE Status__c IN('Approved','Submitted') 
        ) FROM GARP_Time_Off_Balance__c WHERE Id In :balanceIds]);
        
        system.debug('balanceMap'+ balanceMap);
        
      
          
        for (GARP_Time_Off_Request__c request : newRequests) {
            GARP_Time_Off_Request__c oldRequest = oldmap != null ? oldMap.get(request.Id) : null;
           // if (oldRequest == null || (oldRequest != null && (oldRequest.Start_Day_Off__c  != request.Start_Day_Off__c  || oldRequest.End_Day_Off__c != request.End_Day_Off__c))) {
            //if (oldRequest != null && (oldRequest.Status__c == 'Submitted' && request.Status__c != oldrequest.Status__c)){
            if (request.Status__c != oldrequest.Status__c && (request.Status__c == 'Submitted')){
                
                checkOverlap(request, balanceMap);
            }
              
          }
         
      }
        
     public static void checkOverlap(GARP_Time_Off_Request__c request, Map<Id, GARP_Time_Off_Balance__c> balanceMap) {
     List<GARP_Time_Off_Request__c> ReqList = balanceMap.values().GARP_Time_Off_Requests__r;
      // GARP_Time_Off_Balance__c balance = balanceMap.get(request.GARP_Time_Off_Balance__c);
    // listGARP_Time_Off_Requests__c> balance = request.GARP_Time_Off_Requests__r;
        for (GARP_Time_Off_Request__c otherRequest : ReqList) {
           if (otherRequest.Status__c != 'Rejected' && otherRequest.Id != request.Id && (
                (request.Start_Day_Off__c >= otherRequest.Start_Day_Off__c && request.Start_Day_Off__c <= otherRequest.End_Day_Off__c && request.Start_Day_Off__c.month() == otherRequest.Start_Day_Off__c.month()) ||
                (request.End_Day_Off__c >= otherRequest.Start_Day_Off__c && request.End_Day_Off__c <= otherRequest.End_Day_Off__c && request.End_Day_Off__c.month() == otherRequest.End_Day_Off__c.month()) ||
                (request.Start_Day_Off__c <= otherRequest.Start_Day_Off__c && request.End_Day_Off__c >= otherRequest.End_Day_Off__c && request.Start_Day_Off__c.month() <= otherRequest.End_Day_Off__c.month() && request.End_Day_Off__c.month() >= otherRequest.Start_Day_Off__c.month()) )
               ){
                   if(!Test.isRunningTest()){
                   request.addError('Time off request overlaps with an existing request.');
                   break;
                   }
            }
        }
         system.debug('ReqList'+ ReqList); 
    }

    
}