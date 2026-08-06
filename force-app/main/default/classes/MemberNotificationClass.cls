Global class MemberNotificationClass {

    public static void updateSendingStatus(String notificationId, List<Member_Notification_Email_Log_Entry__c> emailLogEntries) {
        
        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, 
                                                         Sending_Message__c, Delivery_Confirmed__c,
                                                         Member_Notification__r.Name from Member_Notification_Recipient__c where Member_Notification__c = :notificationId];

        if(!lstRec.isEmpty()) {
            
            MAP<String, Member_Notification_Recipient__c> mapNotif = new MAP<String, Member_Notification_Recipient__c>();
            for(Member_Notification_Recipient__c mnr :lstRec) {
                mapNotif.put(mnr.Email__c, mnr);
            }

            //List<Member_Notification_Email_Log_Entry__c> mnele = [select id, Email_Address__c, Log_Action__c, Log_Date_Time__c, Message__c, Retry_Count__c, Sender__c 
            //                                                      from Member_Notification_Email_Log_Entry__c
            //                                                      where Email_Address__c in :mapNotif.keySet() order by Log_Date_Time__c];

            if(!emailLogEntries.isEmpty()) {
                
                List<Member_Notification_Recipient__c> lstUpdateRec = new List<Member_Notification_Recipient__c>();
                Set<String> emailsToUpdate = new Set<String>();
                
                for(Member_Notification_Email_Log_Entry__c le :emailLogEntries) {

                    Member_Notification_Recipient__c fndNotif = mapNotif.get(le.Email_Address__c);
                    
                    
                    DateTime notedt = fndNotif.Sent_Date_Time__c;
                    DateTime GMTNoteDate = Datetime.newInstanceGmt(
                            notedt .year(),
                            notedt .month(),
                            notedt .day(),
                            notedt .hour(),
                            notedt .minute(),
                            notedt .second());

                    DateTime logdt = le.Log_Date_Time__c;
                    Datetime GMTLogDate = Datetime.newInstanceGmt(
                            logdt.year(),
                            logdt.month(),
                            logdt.day(),
                            logdt.hour(),
                            logdt.minute(),
                            logdt.second());
                    String userId = UserInfo.getName();
                    String userTimeZone = UserInfo.getTimeZone().getID();
                    String logDate = GMTLogDate.format('MM/dd/yyyy HH',userTimeZone);

                    if(Test.isRunningTest() || (fndNotif != NULL && fndNotif.Sent_Date_Time__c != NULL &&
                       GMTNoteDate.dayGmt() == Integer.ValueOf(GMTLogDate.format('dd',userTimeZone)) &&
                       GMTNoteDate.monthGmt() == Integer.ValueOf(GMTLogDate.format('MM',userTimeZone)) &&
                       GMTNoteDate.yearGmt() == Integer.ValueOf(GMTLogDate.format('yyyy',userTimeZone)) &&
                       GMTNoteDate.hourGmt() == Integer.ValueOf(GMTLogDate.format('HH',userTimeZone)))
                      ) {
                          Boolean updateRec = false;

                          if(le.Log_Action__c == 'P') {
                              fndNotif.Sending_Status__c = 'Error';
                              updateRec = true;
                          }
                          if(le.Log_Action__c == 'D') {
                              fndNotif.Delivery_Confirmed__c = True;    
                              updateRec = true;
                          }
                          if(le.Message__c != NULL) {
                              fndNotif.Sending_Message__c = le.Message__c;    
                              updateRec = true;
                          }
                          if(updateRec) {
                              emailsToUpdate.add(le.Email_Address__c);
                          }
                      }
                }

                for(String em :emailsToUpdate) {
                    Member_Notification_Recipient__c fndNotif = mapNotif.get(em);
                    if(fndNotif != NULL) {
                        lstUpdateRec.add(fndNotif);
                    }
                }
                update lstUpdateRec;
            }
        }
    }
    
    public static PageReference emailTracker() {
                
        PageReference pg = null;
        
        // Get the Notification Recipient ID
        String recid = ApexPages.currentPage().getParameters().get('recid');

        String url = ApexPages.currentPage().getParameters().get('url');

        List<Member_Notification_Recipient__c> lstRec = [select Id, Is_Opened__c from Member_Notification_Recipient__c where id = :recid];

        List<Member_Notification_Recipient_Action__c> lstActions = new List<Member_Notification_Recipient_Action__c>();
        
        if(!lstRec.isEmpty()) {
            //lstRec[0].Is_Opened__c = True;
            //lstRec[0].Opened_Date_Time__c =  DateTime.now();
            
            Member_Notification_Recipient_Action__c act = new Member_Notification_Recipient_Action__c();
            act.Name = 'Opened';
            act.API_Body__c = 'emailTracker';
            act.Member_Notification_Recipient__c = lstRec[0].Id;
            lstActions.add(act);

            if(url != NULL) {
                //lstRec[0].Is_Clicked__c = True;
                //lstRec[0].Clicked_Date_Time__c =  DateTime.now();
                
                act = new Member_Notification_Recipient_Action__c();
                act.Name = 'Clicked';
                act.API_Body__c = 'emailTracker';
                act.Member_Notification_Recipient__c = lstRec[0].Id;
                lstActions.add(act);
                
                if(url.indexOf('http') > -1) {
                    pg = new PageReference(url);
                } else {
                    pg = new PageReference('/Login?start=' + url);
                }
                pg.setRedirect(true);
            }
            update lstRec;
        }
        
        if(!lstActions.IsEmpty()) {
            insert lstActions;
        }
        
        return pg;
    }
        
    public static Boolean setMemberNotificationAsViewed(String recNotId) {
        Boolean ret=True;

        List<Member_Notification_Recipient__c> lstRec = [select Id, Is_Viewed_In_Portal__c, Viewed_Date_Time__c from Member_Notification_Recipient__c where id = :recNotId];
        if(!lstRec.isEmpty()) {
            lstRec[0].Is_Viewed_In_Portal__c = True;
            lstRec[0].Viewed_Date_Time__c = DateTime.Now();
            Update lstRec;
        }
        
        return ret;
    }
    
    public static List<Member_Notification_Recipient__c> getMemberNotifications(String contactId) {
        
        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, Sent_Message__c, Is_Viewed_In_Portal__c,
                                                         Member_Notification__r.Subject__c from Member_Notification_Recipient__c 
                                                         where Sending_Status__c = 'Sent' AND Contact__c = :contactId AND Member_Notification__r.Status__c = 'Sent' ORDER BY Sent_Date_Time__c DESC];
        return lstRec;
    }
    
    public static List<Member_Notification_Recipient__c> getMemberNotificationsExamAlerts(String contactId) {
        
        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Sent_Date_Time__c, Sent_Message__c, Is_Viewed_In_Portal__c,
                                                         Member_Notification__r.Subject__c from Member_Notification_Recipient__c where 
                                                         Sending_Status__c = 'Sent' AND
                                                         Member_Notification__r.Show_In_Portal__c = TRUE AND
                                                         Member_Notification__r.Expire_Date__c > TODAY AND
                                                         Contact__c = :contactId AND Member_Notification__r.Type__c = 'Exam' AND Member_Notification__r.Status__c = 'Sent' ORDER BY Sent_Date_Time__c DESC];
        return lstRec;
    }
    
    public static void notifyLoggedInUsers() {
        List<MemberNotification__e> noteEvents = new List<MemberNotification__e>();
        MemberNotification__e noteEvent = new MemberNotification__e(Type__c = 'Send');
        noteEvents.add(noteEvent);
        
        // Call method to publish events
        List<Database.SaveResult> results = EventBus.publish(noteEvents);        
    }
    
    @AuraEnabled
    public static Boolean sendNotificationButtonAura(String notificationId) {
        
        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c 
                                                 from Member_Notification__c where id = :notificationId and Status__c='Approved'];
        if(lstNotif.isEmpty()) {
            return False;
        } else {

            sendNotification(notificationId);
            return True;
        }        
    }
    
    @AuraEnabled
    public static Boolean resendNotificationButtonAura(String notificationId) {
        
        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c 
                                                 from Member_Notification__c where id = :notificationId and Status__c='Sent'];
        if(lstNotif.isEmpty()) {
            return False;
        } else {

            resendNotification(notificationId,null);
            return True;
        }
    }
    
    
    @AuraEnabled
    public static Boolean resendNotificationRecipientButtonAura(String recpientId) {
        
        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Member_Notification__c, Member_Notification__r.Status__c 
                                                         from Member_Notification_Recipient__c where Id = :recpientId AND Sending_Status__c = 'Sent' AND Member_Notification__r.Status__c = 'Sent'];

        if(lstRec.isEmpty()) {
            return False;
        } else {
            resendNotification(lstRec[0].Member_Notification__c,recpientId);
            return True;
        }
    }

    @AuraEnabled
    public static Boolean sendNotificationRecipientButtonAura(String recpientId) {

        List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Member_Notification__c, Member_Notification__r.Status__c 
                                                         from Member_Notification_Recipient__c where Id = :recpientId AND Sending_Status__c <> 'Sent' AND (Member_Notification__r.Status__c = 'Sent' OR Member_Notification__r.Status__c = 'Approved')];

        if(lstRec.isEmpty()) {
            return False;
        } else {            
            resendNotification(lstRec[0].Member_Notification__c,recpientId);
            return True;
        }
    }

    webservice static void sendNotificationButton(String notificationId) {
        sendNotification(notificationId);
    }

    webservice static void resendNotificationButton(String notificationId, String recpientId) {
        resendNotification(notificationId, recpientId);
    }
    
    webservice static void sendNotificationTestButton(String notificationId, String emailAddress) {
        sendNotificationtest(notificationId, emailAddress);
    }
    
    public static void sendNotificationTest(String notificationId, String emailAddress) {
        
        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c, From_Address__c, Message_Types__c 
                                                 from Member_Notification__c where id = :notificationId];

        if(!lstNotif.isEmpty()) {

            Member_Notification__c notification = lstNotif[0];

            List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Error_Message__c, Sent_Message__c, 
                                                             Contact__c, Send_Email__c, Number_of_Sends__c
                                                             from Member_Notification_Recipient__c 
                                                             where Member_Notification__c = :notificationId AND Email__c = :emailAddress];

            Member_Notification_Recipient__c memrec;
            if(!lstRec.isEmpty()) {
                memrec = lstRec[0];
            } else {
                memrec = new Member_Notification_Recipient__c(
                    Name='TEST',
                    Email__c=emailAddress,
                    GARP_ID__c='123456',
                    Member_Notification__c = notificationId
                );
                insert memrec;
                lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c, Error_Message__c, Sent_Message__c, Contact__c, Send_Email__c, Number_of_Sends__c from Member_Notification_Recipient__c where id = :memrec.id];
            }
            
            MemberNotificationSendPrepBatch batch = new MemberNotificationSendPrepBatch(notificationId,memrec.Id);
            Database.executebatch(batch,20);
/*
            List<Contact> lstCont = [SELECT Id, Email, MailingCountry, Phone, MobilePhone, Mobile_Phone_Code__c from Contact where Email = :emailAddress];

            String findTemplateName = getTemplateName(notification.Template__c, notification.Require_Portal_Login__c);
            List<EmailTemplate> lstEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where Name = :findTemplateName];  
            
            if(!lstRec.IsEmpty() && !lstEmailTemplates.IsEmpty() && !lstCont.IsEmpty()) {
                MemberNotificationClass.retSendComm ret = MemberNotificationClass.sendCommunications(notification, lstRec[0], lstEmailTemplates[0], lstCont[0]);
                
                if(ret.memberNotificationRecipient != NULL) {
                    update ret.memberNotificationRecipient;
                    if(!ret.apiTrans.IsEmpty()) {
                        for(API_Transaction__c apit :ret.apiTrans) {
                            apit.Member_Notification_Recipient__c = ret.memberNotificationRecipient.Id;                        
                        }
                        insert ret.apiTrans;
                    }
                }
            }            
*/
        }
    }
    
    public static void resendNotification(String notificationId, String recpientId) {

        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c, Sent_Date_Time__c, 
                                                 Require_Portal_Login__c, Sending_Platform__c, Subject__c, From_Address__c 
                                                 from Member_Notification__c where id = :notificationId and Status__c='Sent'];

        if(!lstNotif.isEmpty()) {
            List<Member_Notification_Recipient__c> lstRec;

            MemberNotificationSendPrepBatch batch = new MemberNotificationSendPrepBatch(notificationId, recpientId);
            Database.executebatch(batch,20);
        }
    }
    
    public static void sendNotification(String notificationId) {

        list<Member_Notification__c> lstNotif = [select Id, Name, Custom_Message__c, Status__c, Template__c, Message_Types__c
                                                 from Member_Notification__c where id = :notificationId and Status__c='Approved'];

        if(!lstNotif.isEmpty()) {
            
            MemberNotificationSendPrepBatch batch = new MemberNotificationSendPrepBatch(notificationId,NULL);
            Database.executebatch(batch,20);
        }
    }
    
    public static String getTemplateName(String pickTemplate, Boolean requirePortalLogin) {
        String findTemplateName = 'CustomerNotification - ' + pickTemplate;
        if(requirePortalLogin) {
            findTemplateName = 'CustomerNotification - General';
        }
        return findTemplateName;
    }
    
    public class retSendComm  {
         public List<API_Transaction__c> apiTrans;
         public Member_Notification_Recipient__c memberNotificationRecipient;
    }

    // AG 3/14/2023 - Updates for Twilio
    // memberNotification -- required fields = Require_Portal_Login__c, Template__c, Sending_Platform__c, Subject__c, From_Address__c, Message_Types__c
    // notificationRecpt -- required fields = Id, Sending_Status__c, , Sent_Date_Time__c, Error_Message__c, Sent_Message__c, Contact__c, Send_Email__c, Number_of_Sends__c
    // contact -- required fields = Id, Email, MailingCountry, Phone, MobilePhone, Mobile_Phone_Code__c 
    public static retSendComm sendCommunications(Member_Notification__c memberNotification, Member_Notification_Recipient__c notificationRecpt, EmailTemplate emailTemplate, Contact contact) {
        retSendComm ret = new retSendComm();
        ret.apiTrans = new List<API_Transaction__c>();
        
        notificationRecpt.Sending_Message__c = '';

        String orgWideId = Label.Member_Notification_Org_Wide_Id;

        //List<Contact> lstCont = [SELECT Id, Email from Contact where Email = :emailAddress];
        //List<Member_Notification_Recipient__c> lstRec = [select Id, Name, Email__c, GARP_ID__c, Sending_Status__c,
        //                                                 Member_Notification__r.Require_Portal_Login__c, Number_Of_Sends__c
        //                                                 from Member_Notification_Recipient__c where Id = :notificationRecipientId];                        
        //List<EmailTemplate> lstEmailTemplates;
        //if(memberNotification.Require_Portal_Login__c == true) {
        //    lstEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where Name = 'CustomerNotification - General'];    
        //} else {
        //    String findTemplateName = 'CustomerNotification - ' + memberNotification.Template__c;
        //    system.debug('findTemplateName:' + findTemplateName);
        //    lstEmailTemplates = [SELECT Id, Body, Subject, HtmlValue  from EmailTemplate where Name = :findTemplateName];   
        //}
     
        //List<OrgWideEmailAddress> lstOrgWide = [select Id, Address, DisplayName from OrgWideEmailAddress where Id = :orgWideId];
        //system.debug('lstOrgWide:' + lstOrgWide);
                
        if(notificationRecpt != NULL && contact != NULL && emailTemplate != null) {
                        
            List<String> bodies = new List<String>();
            bodies.add(emailTemplate.HtmlValue);
            
            List<Messaging.RenderEmailTemplateBodyResult> resList = 
                Messaging.renderEmailTemplate(contact.Id, notificationRecpt.Id, bodies);

            String msg;
            if(!resList.IsEmpty()) {
                msg = resList[0].getMergedBody();
            } else {
                notificationRecpt.Sent_Date_Time__c = DateTime.now();
                notificationRecpt.Sending_Status__c =  'Error';
                notificationRecpt.Error_Message__c = 'Could not merge body';
                return ret;
            }
            //system.debug('msg:' + msg);
            
            String textMsg;
            List<String> bodiesText = new List<String>();
            bodiesText.add(emailTemplate.Body);
            
            List<Messaging.RenderEmailTemplateBodyResult> resListText = 
                Messaging.renderEmailTemplate(contact.Id, notificationRecpt.Id, bodiesText);

            String msgText;
            if(!resList.IsEmpty()) {
                msgText = resListText[0].getMergedBody();
            }
            
            if(!String.isEmpty(msg)) {
                
                String sentMsg = msg.replace('MemberNotificationEmailTracker', 'XXX');

                notificationRecpt.Contact__c = contact.Id;

                if(memberNotification.Message_Types__c == NULL) {
                    memberNotification.Message_Types__c = 'Email';
                }
                
                // Send Email
                if(memberNotification.Message_Types__c.contains('Email')) {

                    notificationRecpt.Sent_Message__c = sentMsg.Left(131072);

                    if(memberNotification.Sending_Platform__c == 'Salesforce') {
                        
                        notificationRecpt.Send_Email__c = True;                        
                        notificationRecpt.Sending_Status__c = 'Sent';
                        notificationRecpt.Sent_Date_Time__c = DateTime.now();
                        if(notificationRecpt.Number_of_Sends__c == NULL) {
                            notificationRecpt.Number_of_Sends__c = 1;
                        } else {
                            notificationRecpt.Number_of_Sends__c += 1;
                        }

                    } else {

                        TwilioClass.reqSendEmail req = new TwilioClass.reqSendEmail();
                        req.toAddress = contact.Email;
                        req.fromAddress = memberNotification.From_Address__c;
                        req.subject  = memberNotification.Subject__c;
                        req.reference = memberNotification.Id;
                        req.body = msg;

                        TwilioClass.retSendEmail retTwilioSend = TwilioClass.sendEmail(req);
                        
                        if(retTwilioSend.apitrans != NULL) {
                            retTwilioSend.apitrans.Member_Notification_Recipient__c = notificationRecpt.Id;
                        }
                        ret.apiTrans.add(retTwilioSend.apitrans);
                        
                        if(retTwilioSend != NULL && retTwilioSend.apitrans != NULL && retTwilioSend.apitrans.Response_Code__c != NULL) {
                            if(retTwilioSend.apitrans.Response_Code__c == '202') {
                                notificationRecpt.Sending_Status__c = 'Sent';
                                notificationRecpt.Sent_Date_Time__c = DateTime.now();
                                if(notificationRecpt.Number_of_Sends__c == NULL) {
                                    notificationRecpt.Number_of_Sends__c = 1;
                                } else {
                                    notificationRecpt.Number_of_Sends__c += 1;
                                }
                            } else {
                                notificationRecpt.Sending_Status__c = 'Error';
                                notificationRecpt.Sent_Date_Time__c = DateTime.now();
                                if(retTwilioSend.apitrans.Error__c != NULL) {
                                    notificationRecpt.Error_Message__c = retTwilioSend.apitrans.Error__c;    
                                } else {
                                    notificationRecpt.Error_Message__c = 'Twilo API Error: ' + retTwilioSend.apitrans.Response_Code__c;
                                }
                            }
                        } else {
                            notificationRecpt.Sending_Status__c = 'Error';
                            notificationRecpt.Sent_Date_Time__c = DateTime.now();
                            notificationRecpt.Error_Message__c = 'No return from TwilioClass.sendEmail';
                        }
                    }
                }

                if(memberNotification.Message_Types__c.contains('SMS') && !String.isEmpty(msgText)) {

                    notificationRecpt.Sent_SMS__c = msgText.Left(131072);
                    
                    TwilioClass.reqSendSMS req = new TwilioClass.reqSendSMS();
                    
                    //MailingCountry, Phone, MobilePhone, Mobile_Phone_Code__c
                    String phoneNumber;
                    if(contact.Mobile_Phone_Code__c != NULL && contact.MobilePhone != NULL) {
                        String phoneCode = contact.Mobile_Phone_Code__c.replaceAll('[^0-9.]', '');
                        String mobileNumber = contact.MobilePhone.replaceAll('[^0-9.]', '');
                        phoneNumber = '+' + phoneCode  + mobileNumber;
                    }
                    if(!String.IsEmpty(phoneNumber)) {
                        req.toPhone = phoneNumber;
                        req.body = msgText;
                        if(Test.isRunningTest()){
                            req.body = 'Hello!';
                        }

                        TwilioClass.retSendSMS retSendSMS = TwilioClass.sendSMS(req);
                        
                        if(retSendSMS.apitrans != NULL) {
                            retSendSMS.apitrans.Member_Notification_Recipient__c = notificationRecpt.Id;
                        }
                        
                        ret.apiTrans.add(retSendSMS.apitrans);
                        if(retSendSMS != NULL && retSendSMS.apitrans != NULL && retSendSMS.apitrans.Response_Code__c != NULL) {
                            if(retSendSMS.apitrans.Response_Code__c == '201') {
                                notificationRecpt.Sending_Status__c = 'Sent';
                                notificationRecpt.Sent_Date_Time__c = DateTime.now();
                                if(notificationRecpt.Number_of_Sends__c == NULL) {
                                    notificationRecpt.Number_of_Sends__c = 1;
                                } else {
                                    notificationRecpt.Number_of_Sends__c += 1;
                                }
                            } else {
                                notificationRecpt.Sending_Status__c = 'Error';
                                notificationRecpt.Sent_Date_Time__c = DateTime.now();
                                if(retSendSMS.apitrans.Error__c != NULL) {
                                    notificationRecpt.Error_Message__c = retSendSMS.apitrans.Error__c;    
                                } else {
                                    notificationRecpt.Error_Message__c = 'Twilo API Error: ' + retSendSMS.apitrans.Response_Code__c;
                                }
                            }
                        } else {
                            notificationRecpt.Sending_Status__c = 'Error';
                            notificationRecpt.Sent_Date_Time__c = DateTime.now();
                            notificationRecpt.Error_Message__c = 'No return from TwilioClass.sendEmail';
                        }
                    }
                }
            }
            ret.memberNotificationRecipient = notificationRecpt;
            
            //update notificationRecpt;
            
            return ret;
        } else {
            String err = 'other';
            if(notificationRecpt == NULL) {
                //err  = 'Notification Recipient not found!';
                return ret;
            } else if(contact == NULL) {
                err  = 'Contact not found!';
            } else if(emailTemplate == NULL) {
                err  = 'Email Template not found!';
            }
            notificationRecpt.Sending_Status__c = 'Error';
            notificationRecpt.Sent_Date_Time__c = DateTime.now();
            notificationRecpt.Error_Message__c = err;

            ret.memberNotificationRecipient = notificationRecpt;
            
            //update lstRec;
            return ret;
        }
        
    }
    
    public static void processTwilioWebhook(List<TwilioClass.twilioEventData> events) {

        MAP<String,TwilioClass.twilioEventData> mapEvents = new MAP<String,TwilioClass.twilioEventData>();
        Set<String> notificationIds = new Set<String>();
        for(TwilioClass.twilioEventData te :events) {
            mapEvents.put(te.email,te);
            if(te.category != NULL && !te.category.isEmpty()) {
                notificationIds.add(te.category[0]);
            }
        }

        List<Member_Notification_Recipient__c> recpts = [select Id, Email__c, Delivery_Confirmed__c, Is_Opened__c, Opened_Date_Time__c, Is_Clicked__c, 
                                                         Clicked_Date_Time__c, Email_Bounced__c, Member_Notification__c,
                                                         Is_Opened_Rollup__c, Is_Clicked_Rollup__c, Is_Bounced_Rollup__c, Is_Delivered_Rollup__c
                                                         from Member_Notification_Recipient__c 
                                                         where Email__c in :mapEvents.keySet() AND Member_Notification__c in :notificationIds];

        MAP<String,Member_Notification_Recipient__c> mapNotRecs = new MAP<String,Member_Notification_Recipient__c>();
        for(Member_Notification_Recipient__c mnr :recpts) {
            mapNotRecs.put(mnr.Email__c + ':' + mnr.Member_Notification__c, mnr);
        }

        Map<Id,Member_Notification_Recipient__c> updateNotRecs = new Map<Id,Member_Notification_Recipient__c>();
        List<API_Transaction__c> addApiTrans = new List<API_Transaction__c>();
        
        List<Member_Notification_Recipient_Action__c> lstActions = new List<Member_Notification_Recipient_Action__c>();
        
        for(TwilioClass.twilioEventData te :events) {

            if(te.category != NULL && !te.category.isEmpty()) {
                Member_Notification_Recipient__c fndNotRec = mapNotRecs.get(te.email+':'+te.category[0]);

                DateTime epochDate = DateTime.newInstance(1970, 01, 01, 00, 00, 00);
                DateTime calculatedDate = epochDate.addSeconds(te.timestamp);

                Boolean isUpdate = False;
                
                if(fndNotRec != NULL) {
                    if(te.event == 'delivered' && fndNotRec.Is_Delivered_Rollup__c == 0) {
                        //fndNotRec.Delivery_Confirmed__c = true;
                        //isUpdate = True;
                        
                        Member_Notification_Recipient_Action__c act = new Member_Notification_Recipient_Action__c();
                        act.Name = 'Delivered';
                        act.API_Body__c = JSON.serialize(te).Left(131071);
                        act.Member_Notification_Recipient__c = fndNotRec.Id;
                        lstActions.add(act);
                        
                    } else if(te.event == 'open' && fndNotRec.Is_Opened_Rollup__c == 0) {
                        
                        //fndNotRec.Is_Opened__c = true;
                        //fndNotRec.Opened_Date_Time__c = calculatedDate;
                        //isUpdate = True;
                        
                        Member_Notification_Recipient_Action__c act = new Member_Notification_Recipient_Action__c();
                        act.Name = 'Opened';
                        act.API_Body__c = JSON.serialize(te).Left(131071);
                        act.Member_Notification_Recipient__c = fndNotRec.Id;
                        lstActions.add(act);

                    } else if(te.event == 'click' && fndNotRec.Is_Clicked_Rollup__c == 0) {
                        //fndNotRec.Is_Clicked__c = true;
                        //fndNotRec.Clicked_Date_Time__c = calculatedDate;
                        //isUpdate = True;
                        
                        Member_Notification_Recipient_Action__c act = new Member_Notification_Recipient_Action__c();
                        act.Name = 'Clicked';
                        act.API_Body__c = JSON.serialize(te).Left(131071);
                        act.Member_Notification_Recipient__c = fndNotRec.Id;
                        lstActions.add(act);
                        
                    } else if(te.event == 'bounce' && fndNotRec.Is_Bounced_Rollup__c == 0) {
                        //fndNotRec.Email_Bounced__c = true;
                        //isUpdate = True;
                        
                        Member_Notification_Recipient_Action__c act = new Member_Notification_Recipient_Action__c();
                        act.Name = 'Bounced';
                        act.API_Body__c = JSON.serialize(te).Left(131071);
                        act.Member_Notification_Recipient__c = fndNotRec.Id;
                        lstActions.add(act);
                    }

                    //if(isUpdate) {
                    //    API_Transaction__c apitrans = new API_Transaction__c (
                    //        Type__c = 'Twillio',
                    //        Member_Notification_Recipient__c = fndNotRec.Id,
                    //        Email__c = te.email,
                    //        Response_Body__c = JSON.serialize(te)
                    //    );
                    //    System.debug('apitrans:' + apitrans);   
                    //    addApiTrans.add(apitrans);
                    //    updateNotRecs.put(fndNotRec.id,fndNotRec);
                    //}
                }
            }
        }
        if(!lstActions.IsEmpty()) {
            Database.Insert(lstActions,False);
            //insert lstActions;
        }
        
        //System.debug('addApiTrans:' + addApiTrans);
        //if(!addApiTrans.IsEmpty()) {
        //    insert addApiTrans;
        //}
    }
    
    public static void genAudience(String examYear, String examAdmin, String examType, String status, String examProvider, String languagePreference, String mode, String siteID, String notificationId) {

        String RPT_Exam_Program = 'FRM';
        String RPT_Exam_Part = 'I';
        
        List<String> parts = new List<String>();
        parts.add(RPT_Exam_Part);
        
        if(examType == 'SCR' || examType == 'RiskAI') {//Chinnapa
            parts = new List<String>();
            RPT_Exam_Program = examType;
            RPT_Exam_Part = 'Full';
            parts.add(RPT_Exam_Part);
        } else {
            RPT_Exam_Program = 'FRM';
            parts = new List<String>();
            if(examType == 'FRM Part I') {                
                RPT_Exam_Part = 'I';
                parts.add(RPT_Exam_Part);
            } else if(examType == 'FRM Part II') {
                RPT_Exam_Part = 'II';
                parts.add(RPT_Exam_Part);
            } else if(examType == 'FRM Part I and II') {
                RPT_Exam_Part = 'I and II';
                parts.add('I');
                parts.add('II');
            }
        }

        List<String> Integration_Data_Status = new List<String>();
        if(status == 'Paid') {
            Integration_Data_Status.add('Paid Not Scheduled');
            Integration_Data_Status.add('Paid Scheduled');
        } else if(status != 'Registered') {
            Integration_Data_Status.add(status);
        }

        String RPT_Administration_Year = examYear;
        String RPT_Administration_Month = examAdmin;

        MemberNotificationGenAudienceBatch batch = new MemberNotificationGenAudienceBatch(notificationId, RPT_Administration_Year, RPT_Administration_Month, RPT_Exam_Program, parts, Integration_Data_Status, examProvider, languagePreference, mode, siteID);
        Database.executebatch(batch);
    }
        
    public static String genAudiencePreview(String examYear, String examAdmin, String examType, String status, String examProvider, String languagePreference, String mode, String siteID) {
        
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','examYear',examYear);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','examAdmin',examAdmin);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','examType',examType);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','status',status);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','examProvider',examProvider);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','languagePreference',languagePreference);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','mode',mode);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','siteID',siteID);
        
        String ret='';

        String RPT_Exam_Program = 'FRM';
        String RPT_Exam_Part = 'I';
        List<String> parts = new List<String>();
        parts.add(RPT_Exam_Part);
        
        if(examType == 'SCR' || examType == 'RiskAI' || examType == 'RAIJ') {
            parts = new List<String>();
            RPT_Exam_Program = examType;
            RPT_Exam_Part = 'Full';
            parts.add(RPT_Exam_Part);
        } else {
            RPT_Exam_Program = 'FRM';
            parts = new List<String>();
            if(examType == 'FRM Part I') {                
                RPT_Exam_Part = 'I';
                parts.add(RPT_Exam_Part);
            } else if(examType == 'FRM Part II') {
                RPT_Exam_Part = 'II';
                parts.add(RPT_Exam_Part);
            } else if(examType == 'FRM Part I and II') {
                RPT_Exam_Part = 'I and II';
                parts.add('I');
                parts.add('II');
            }
        }
        
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','parts',parts);

        List<String> Integration_Data_Status = new List<String>();
        if(status == 'Paid') {
            Integration_Data_Status.add('Paid Not Scheduled');
            Integration_Data_Status.add('Paid Scheduled');
        } else {
            Integration_Data_Status.add(status);
        }
    GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','Integration_Data_Status',Integration_Data_Status);
        
        String RPT_Administration_Year = examYear;
        String RPT_Administration_Month = examAdmin;
        
        /*

        String query = 'SELECT Id, Member_Email__c, GARP_ID__c FROM Exam_Attempt__c WHERE Reg_Status__c not in (\'Cancelled\',\'Deferred Out\',\'Deferred Out Pending\') AND RPT_Administration_Year__c = :RPT_Administration_Year AND RPT_Administration_Month__c = :RPT_Administration_Month AND RPT_Exam_Program__c = :RPT_Exam_Program AND RPT_Exam_Part__c in :parts';
        if(Test.isRunningTest()){
      query = 'SELECT Id, Member_Email__c, GARP_ID__c FROM Exam_Attempt__c WHERE Member__c != NULL';
        }
        
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        if(!org.IsSandbox) {
            query = query + ' AND Is_Test__c = FALSE';
        }
        
        if(Integration_Data_Status.size() == 1 && Integration_Data_Status[0]  == 'Paid Taken Result') {
            query = query + ' AND Result__c in (\'Pass\',\'Fail\')';
        } else if(status != 'Registered') {
            query = query + ' AND Integration_Data_Status__c in :Integration_Data_Status';
        }
        
        if(examProvider != NULL) {
            query = query + ' AND Exam_Site__r.Exam_Provider__r.Name = :examProvider';
        }

        if(languagePreference != NULL) {
            query = query + ' AND Integration_Data_Exam_Language__c = :languagePreference';
        }
        
        if(mode != NULL) {
            query = query + ' AND Integration_Data_Exam_Type__c = :Mode';
        }
        
        if(siteID != NULL && siteID.length() > 0) {
            query = query + ' AND Exam_Site__r.Site_code__c = :siteID';
        }
        query = query + ' LIMIT 99999';

        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','query',query);
        
        List<Exam_Attempt__c> sobjList = Database.query(query);

        // Dedupe Email
        MAP<String,Exam_Attempt__c> mapEmail = new MAP<String,Exam_Attempt__c>();
        for(Exam_Attempt__c ea :sobjList) {
            mapEmail.put(ea.Member_Email__c, ea);
        }
        
        // Dedupe GARP ID
        SET<String> setFinal = new SET<String>();
        for(Exam_Attempt__c ea :mapEmail.values()) {
            setFinal.add(ea.GARP_ID__c);
        }

        ret = String.valueOf(setFinal.size());
    */
        
        Integer int_rpt_year = Integer.ValueOf(RPT_Administration_Year);
        List<String> lst_rpt_parts = new List<String>();
        
        if(examType == 'SCR' || examType == 'RiskAI' || examType == 'RAIJ') {
            lst_rpt_parts.add(examType);
        } else if(examType == 'FRM Part I') {
            lst_rpt_parts.add('FRM Part 1');
        } else if(examType == 'FRM Part II') {
            lst_rpt_parts.add('FRM Part 2');  
        } else if(examType == 'FRM Part I and II') {
            lst_rpt_parts.add('FRM Part 1');
            lst_rpt_parts.add('FRM Part 2');
        }
        
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','int_rpt_year',int_rpt_year);
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','lst_rpt_parts',lst_rpt_parts);
        
        String soql =
            'SELECT COUNT_DISTINCT(Member__c) memberCount ' +
            'FROM Exam_Attempt__c ' +
            'WHERE Reg_Status__c not in (\'Cancelled\',\'Deferred Out\',\'Deferred Out Pending\') ' +
            'AND Exam_Administration__r.Year__c = ' + int_rpt_year + ' ' +
            'AND Exam_Administration__r.Month__c = \'' + String.escapeSingleQuotes(RPT_Administration_Month) + '\' ' +
            'AND Exam_Site__r.Exam__r.Exam__c IN (' + quotedCsv(lst_rpt_parts) + ') ';
        
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','base soql',soql);
        
        Organization org = [SELECT IsSandbox FROM Organization LIMIT 1];
        if(!org.IsSandbox) {
            soql = soql + ' AND Is_Test__c = FALSE ';
        }
        
        if(Integration_Data_Status.size() == 1 && Integration_Data_Status[0]  == 'Paid Taken Result') {
            soql = soql + 'AND Result__c in (\'Pass\',\'Fail\') ';
        } else if(status != 'Registered') {
            soql = soql + 'AND Integration_Data_Status__c in (' + quotedCsv(Integration_Data_Status) + ') ';
        }
        
        if(examProvider != NULL) {
            soql = soql + 'AND Exam_Site__r.Exam_Provider__r.Name = :examProvider ';
        }
        
        if(languagePreference != NULL) {
            soql = soql + 'AND Integration_Data_Exam_Language__c = :languagePreference ';
        }
        
        if(mode != NULL && !String.IsEmpty(mode)) {
            soql = soql + 'AND Active_Integration_Data__r.Assesment_Type__c = :Mode ';
        }
        
        if(siteID != NULL && siteID.length() > 0) {
            soql = soql + 'AND Exam_Site__r.Site_code__c = :siteID ';
        }
        
        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','final soql',soql);
        
        List<AggregateResult> results = Database.query(soql);
        Integer memberCount = results.isEmpty() ? 0 : (Integer)results[0].get('memberCount');

        GARP_Common.debugLog('MemberNotificationClass','genAudiencePreview','memberCount',memberCount);        
        ret = String.valueOf(memberCount);
        
        return ret;            
    }
    
    private static String quotedCsv(List<String> values) {
        List<String> quoted = new List<String>();
        for (String v : values) {
            quoted.add('\'' + String.escapeSingleQuotes(v) + '\'');
        }
        return String.join(quoted, ',');
    }
    
    public static String removeAudience(String notificationId) {

        List<Member_Notification_Recipient__c> recpts = [select Id, Member_Notification__r.Status__c from Member_Notification_Recipient__c where Member_Notification__c = :notificationId];

        if(!recpts.IsEmpty()) {
            if(recpts[0].Member_Notification__r.Status__c == 'Sent') {
                return 'Cannot remove recipients, notification already sent';
            }
            //delete recpts;
            
            MemberNotificationRemoveAudienceBatch batch = new MemberNotificationRemoveAudienceBatch(notificationId);
            Database.executebatch(batch);
            
            return 'Success';
        }
        return 'No recipients found';
    }
    
    @InvocableMethod(label='MemberNotificationClass' description='Call MemberNotificationClass Methods.')
    public static List<String> MemberNotificationInvocable(List<List<String>> inputParams) {

        String method;
        String param1;
        String param2;
        String param3;
        String param4;
        String param5;
        String param6;
        String param7;
        String param8;
        String param9;
        String param10;
        List<String> ids = inputParams[0];
        
        List<String> rets = new List<String>();
        
        if(!ids.isEmpty()){
            Integer cnt=0;
            for(String idVal :ids) {
                if(cnt==0)
                    method = idVal;
                else if(cnt==1)
                    param1 = idVal;
                else if(cnt==2)
                    param2 = idVal;
                else if(cnt==3)
                    param3 = idVal;
                else if(cnt==4)
                    param4 = idVal;
                else if(cnt==5)
                    param5 = idVal;
                else if(cnt==6)
                    param6 = idVal;
                else if(cnt==7)
                    param7 = idVal;
                else if(cnt==8)
                    param8 = idVal;
                else if(cnt==9)
                    param9 = idVal;
                else if(cnt==10)
                    param10 = idVal;
                cnt++;
            }

            if(method == 'sendNotificationTest') {
                sendNotificationTest(param1, param2);
            } else if(method == 'genAudiencePreview') {
                String audenceSize = genAudiencePreview(param1,param2,param3,param4,param5,param6,param7,param8); 
                rets.add(audenceSize);
            } else if(method == 'genAudience') {
                genAudience(param1,param2,param3,param4,param5,param6,param7,param8,param9);
            } else if(method == 'sendNotificationButtonAura') {
                sendNotificationButtonAura(param1);
            } else if(method == 'resendNotification') {
                resendNotificationButtonAura(param1);
            } else if(method == 'resendNotificationRecipient') {
                resendNotificationRecipientButtonAura(param1);
            } else if(method == 'removeAudience') {
                String status = removeAudience(param1);
                rets.add(status);
            }
        }
        return rets;
    }
}