global class BatchFaliures implements Database.Batchable<sObject>,Database.StateFul{
    
   global string messageBody;
   
   global BatchFaliures()
   {
     messageBody = '';
   }
    
   global Database.QueryLocator start(Database.BatchableContext BC){
    Date dt = Date.today();
    //and NumberOfErrors >0 
      return Database.getQueryLocator('select ApexClassID,ApexClass.Name,ExtendedStatus,JobType,MethodName,NumberOfErrors,Status,TotalJobItems from AsyncApexJob where ExtendedStatus !=null and DAY_ONLY(CompletedDate)=:dt and NumberOfErrors >0 ');
     //return Database.getQueryLocator('select ApexClassID,ApexClass.Name,ExtendedStatus,JobType,MethodName,NumberOfErrors,Status,TotalJobItems from AsyncApexJob where ExtendedStatus !=null  and CompletedDate = today');
   
   }

   global void execute(Database.BatchableContext BC, List<AsyncApexJob> scope){
        
     for(AsyncApexJob rec : scope){
     //system.debug('&&&&&&:'+rec);
        messageBody += 'ApexClass.Name' + ' : ' + rec.ApexClass.Name + '\n';
        messageBody += 'Error Message' + ' : ' + rec.ExtendedStatus + '\n';
        messageBody += 'Method Name' + ' : ' + rec.MethodName + '\n';
        messageBody += 'NumberOfErrors ' + ' : ' + rec.NumberOfErrors + '\n';
        messageBody += 'Status' + ' : ' + rec.Status + '\n';
        messageBody += '\n';
        messageBody += '***************************************************'+ '\n';
        
     }
        
    }

   global void finish(Database.BatchableContext BC){
       
       if(messageBody  == '') return;
       //system.debug('messageBody ==='+messageBody);
       Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
       List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
       String receipientList = system.label.Exception_Recipient_List;
       List<String> toAddresses = new list<string>();
       toAddresses.addall(receipientList.split(','));
       message.setToAddresses(toAddresses);
       message.setSubject('Failed Jobs');
       message.setPlainTextBody(messageBody);
       mails.add(message);
      // system.debug('message ==='+message);
       Messaging.sendEmail(mails);
        
   }
}