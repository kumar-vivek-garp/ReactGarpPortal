global class scheduleAppReport implements Schedulable {
    global void execute(SchedulableContext sc) {
       
        DateTime d = DateTime.now();
        system.debug('dateStr:' + d.month() + ':' + d.day() + ':' +d.year());
        DateTime yd = DateTime.now().addHours(-24);
        
        Integer cnt;
        MAP<String,Integer> errMap = new MAP<String,Integer>();
        
        List<AppError__c> updateARList = new List<AppError__c>();
        
        List<AppError__c> lstAppErr = [select Id, Message__c, Message_Short__c, Error__c, Method__c from AppError__c where Error_Date_Time__c > :yd];
        for(AppError__c aerr :lstAppErr) {
            
            //String clean = aerr.Error__c.replace('"','');
            //clean = clean.replace('{','');
            //clean = clean.replace('}','');
            String clean;
            
            if(string.isBlank(aerr.Error__c)){
              clean = 'Error message not available';
            }else if(aerr.Error__c.indexOf('Aborting!') > -1) {
              clean = 'Watchers fired in the last 5 iterations: iterations reached. Aborting!';  
            }else {
              clean = aerr.Error__c;  
            }
            
                
            system.debug('aerr.Error__c:' + clean);
            
            String regex = '^.*"message":"([^"]*)".*$';
            Pattern p = Pattern.compile(regex);
            Matcher pm = p.matcher( clean );
            
            system.debug('matches:' + pm.matches());
            if(pm.matches()) {
                system.debug('group:' +  pm.group(1));
            }
        
            Boolean updateAR = false;
            if(aerr.Message__c == Null) {
                if(aerr.Message_Short__c != NULL) {
                    aerr.Message__c = aerr.Message_Short__c;
                    updateAR = True;
                } else if(pm.matches()) {
                    aerr.Message__c = pm.group(1);
                    updateAR = True;
                }
            }
            
            if(aerr.Message__c != Null) {
                cnt = errMap.get(aerr.Message__c);
                if(cnt == null) {
                    cnt = 1;
                } else {
                    cnt++;
                }
                errMap.put(aerr.Message__c, cnt);
                system.debug('errMap.put:' + aerr.Message__c + ':' + cnt);
            }
            
            String regex1 = '^.*"method":"([^"]*)".*$';
            Pattern p1 = Pattern.compile(regex1);
            Matcher pm1 = p1.matcher( clean );     
            
            if(aerr.Method__c == Null && pm1.matches()) {
                aerr.Method__c = pm1.group(1);
                updateAR = true;
            }
            
            if(updateAR == True)
                updateARList.add(aerr);
        }
        
        update updateARList;
        
        MAP<String,String> usedKeys = new MAP<String,String>();
        String rpt='';
        
        Integer max;
        String maxKey;
        for (Integer i = 0; i < errMap.size(); i++) {
            max=0;
            maxKey='';
            for(String key :errMap.keySet()) {
                cnt = errMap.get(key);
                system.debug('**' + key + ':' +  cnt);
                if(cnt > max && usedKeys.get(key)==null) {
                    maxKey = key;
                    max = cnt;
                }
            }
            usedKeys.put(maxKey,maxKey);
            if(rpt=='') {
                rpt = maxKey + ': ' + max + '<BR>\n';
            } else {
                rpt = rpt + maxKey + ': ' + max + '<BR>\n';
            }
        }
        system.debug('Report:' + rpt);
        string emails = system.label.AppErrorReportEmails;
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = emails.split(',');
        mail.setToAddresses(toAddresses);
        mail.setSubject('App Errors Report : ' + d.month() + ':' + d.day() + ':' +d.year());
        mail.setHtmlBody('Error Report:<p>'+rpt);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
        
        
    }
}