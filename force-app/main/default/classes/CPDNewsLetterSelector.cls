public class CPDNewsLetterSelector {
    public Boolean showRecords{get;set;}
    public List<CPE_Activity__c> cust {get;set;}
    
    public List<CPE_Activity__c> selectedReadings { get; set; } 
    public List<CPE_Activity__c> trainingCourses { get; set; } 
    public List<CPE_Activity__c> webcasts { get; set; } 
    public List<CPE_Activity__c> universityCourses { get; set; } 
    public List<CPE_Activity__c> booksAndJournals { get; set; } 
    public List<CPE_Activity__c> events { get; set; } 
    
    public List<CPE_Activity__c> garpVolunteer { get; set; }
    
    public Content__c startDate {get;set;}
    public Content__c genHTML {get;set;}
    
    //In constructor
    
    public CPDNewsLetterSelector() {
        showRecords =false; 
        startDate = new Content__c();        
        genHTML = new Content__c();
        genHTML.Story__c = '';
        cust = new List<CPE_Activity__c>();
        selectedReadings = new List<CPE_Activity__c>();
        webcasts = new List<CPE_Activity__c>();
        booksAndJournals = new List<CPE_Activity__c>();
        trainingCourses = new List<CPE_Activity__c>();
        universityCourses = new List<CPE_Activity__c>();
        events = new List<CPE_Activity__c>(); 
        
        garpVolunteer = new List<CPE_Activity__c>();
    }

    public class contWrapper { 
        public Boolean selected { get; set; }
        public CPE_Activity__c obj { get; set; }
    }    
        
    public class ContentWrapper implements Comparable {
        
        public CPE_Activity__c content;
        
        // Constructor
        public ContentWrapper(CPE_Activity__c con) {
            content = con;
            //if (content.Sequence__c == null) { 
            //    content.Sequence__c = 9999;    
            //}
        }
        
        // Compare Contents based on the Sequence.
        public Integer compareTo(Object compareTo) {
            // Cast argument to ContentWrapper
            ContentWrapper compareToContent = (ContentWrapper)compareTo;
            
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            if(content.Sequence__c == NULL && compareToContent.content.Sequence__c != null) {
                returnValue = 1;
            } else if(content.Sequence__c != NULL && compareToContent.content.Sequence__c == null) {
                returnValue = -1;
            } else if(content.Sequence__c == NULL && compareToContent.content.Sequence__c == null) {
                
                if(content.Activity_Date__c < compareToContent.content.Activity_Date__c)
                    returnValue = 1;
                else returnValue = -1;
            } else if (content.Sequence__c > compareToContent.content.Sequence__c) {
                // Set return value to a positive value.
                returnValue = 1;
            } else if (content.Sequence__c < compareToContent.content.Sequence__c) {
                // Set return value to a negative value.
                returnValue = -1;
            }
            
            return returnValue;       
        }
    }    

    public void sortRecords() {
        ContentWrapper [] wrapperList = new List<ContentWrapper>();
        for (CPE_Activity__c content : selectedReadings) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        selectedReadings.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            selectedReadings.add(content);
        }

        wrapperList.clear();
        for (CPE_Activity__c content : trainingCourses) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        trainingCourses.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            trainingCourses.add(content);
        }

        wrapperList.clear();
        for (CPE_Activity__c content : webcasts) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        webcasts.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            webcasts.add(content);
        }

        wrapperList.clear();
        for (CPE_Activity__c content : universityCourses) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        universityCourses.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            universityCourses.add(content);
        }

        wrapperList.clear();
        for (CPE_Activity__c content : booksAndJournals) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        booksAndJournals.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            booksAndJournals.add(content);
        }
        
        wrapperList.clear();
        for (CPE_Activity__c content : events) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        events.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            events.add(content);
        }
        
        
        wrapperList.clear();
        for (CPE_Activity__c content : garpVolunteer) {
            ContentWrapper wrapper = new ContentWrapper(content);
            wrapperList.add(wrapper);
        }
        wrapperList.sort();
        garpVolunteer.clear();
        
        for (ContentWrapper wrapper : wrapperList) {
            CPE_Activity__c content = wrapper.content;
            garpVolunteer.add(content);
        }
        
        
    }    
    
    public void fetchRecords(){
    
        genHTML = new Content__c();
        genHTML.Story__c = '';
        cust = new List<CPE_Activity__c>();
            
        system.debug('* * * fetch ...'+ startDate.Published_Date__c);
        List<CPE_Activity__c> cpeActs = [select Id, Name, Title__c, Description__c, Sequence__c, CPE_Activity_Type__c, Location__c, CPE_Activity_Type__r.Name, Activity_Type_Description__c, Area_of_Study__c, Credit__c, Date_Description__c, Organization__c, Provider__c, Publication__c, URL__c, Outreach_Start_Date__c, Outreach_End_Date__c, Activity_Date__c from CPE_Activity__c where Outreach_Start_Date__c <= :startDate.Published_Date__c and Outreach_End_Date__c >= :startDate.Published_Date__c order by Activity_Date__c desc, Name limit 1000];
        for(CPE_Activity__c ca :cpeActs) {
            //contWrapper c = new contWrapper();
            //c.obj = ca;
            //c.selected = false;
            cust.add(ca);
            if (ca.CPE_Activity_Type__r.Name == 'Selected Readings') {
                selectedReadings.add(ca);
            }
            if (ca.CPE_Activity_Type__r.Name == 'Webcasts/Podcasts') {
                webcasts.add(ca);
            }
            if (ca.CPE_Activity_Type__r.Name == 'Selected Readings:  Books and Journals') {
                booksAndJournals.add(ca);
            }
            if (ca.CPE_Activity_Type__r.Name == 'Conferences/Events') {
                events.add(ca);
            }
            if (ca.CPE_Activity_Type__r.Name == 'Training Courses') {
                trainingCourses.add(ca);
            }
            if (ca.CPE_Activity_Type__r.Name == 'University Courses') {
                universityCourses.add(ca);
            }
            //booksAndJournals.add(c);
            
            if (ca.CPE_Activity_Type__r.Name == 'GARP Volunteer') {
                garpVolunteer.add(ca);
            }
            
            System.debug('* * * GARP Volunteer ...'+ garpVolunteer);
        }
        showRecords = true;
        
    }    

    public void Publish(){
        List<CPE_Activity__c> selContent = new List<CPE_Activity__c>();
        DateTime d = datetime.now();

        String headerTemplateString = '<tr><td colspan="5" align="left" valign="top" bgcolor="#005c83"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#ffffff;">{0}</span></td></tr>';

        //String templateString = '<tr><td valign=top style="background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:black"><ahref="http://iz3.me/76Ap1zxV0RC1" target="_blank"><b><spanstyle="color:#111111">{0}</span></b></a><o:p></o:p></p></td><td valign=top style="background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:black">{1}</span><o:p></o:p></p></td><td valign=top style="background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:black">{2}</span><o:p></o:p></p></td><td valign=top style="background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal align=center style="text-align:center"><b><spanstyle="font-size:9.0pt;font-family:"Arial","sans-serif";color:#081A31">{3}</span></b><o:p></o:p></p></td></tr>';
        String templateString = '';

        templateString += '<tr>';
        templateString += ' <td align="left" valign="top" bgcolor="#FFFFFF"><span style="text-align:left;line-height:1.25em;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#000000;"><a href="{0}" target="_blank" style="text-decoration:underline;font-weight:bold;color:#111111;">{1}</a> <br />';
        templateString += '   <a href="#" style="color: #111111; text-decoration: none;pointer-events: none;">{6}</a><br><a href="#" style="color: #111111; text-decoration: none;pointer-events: none;">{7}</a></span></td>';
        templateString += ' <td align="left" valign="top" bgcolor="#FFFFFF"><span style="text-align:left;line-height:1.25em;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#000000;"><span style="font-weight:normal;">{2}</span></span>';
        templateString += ' </td>';
        templateString += ' <td align="left" valign="top" bgcolor="#FFFFFF"><span style="text-align:left;line-height:1.25em;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#000000;"><span style="font-weight:normal;">{3}</span></span>';
        templateString += ' </td>';
        templateString += ' <td align="center" valign="top" bgcolor="#FFFFFF"><span style="text-align:left;line-height:1.25em;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#000000;"><span style="font-weight:bold;color:#081A31;">{4}</span></span>';
        templateString += ' </td>';
        templateString += ' <td align="left" valign="top" bgcolor="#FFFFFF"><span style="text-align:left;line-height:1.25em;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#000000;"><a href="{5}" target="_blank" style="text-decoration:underline;font-weight:bold;color:#A85123;">Submit</a></span></td>';
        templateString += '</tr>';
                
        
        // 0 = URL, 1 = Name, 2 = Desc
        
        //genHTML.Story__c = '<table class=MsoNormalTable border=0 cellpadding=0 width="100%" style="width:100.0%"><tr><td colspan=4 valign=top style="background:#091B30;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal align=center style="text-align:center"><b><span style="font-size:10.5pt;font-family:"Arial","sans-serif";color:white">CPE CREDIT OPPORTUNITIES</span></b><o:p></o:p></p></td></tr><tr><td width="41%" valign=top style="width:41.0%;background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><b><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:#006C99">Title</span></b><o:p></o:p></p></td><td width="25%" valign=top style="width:25.0%;background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><b><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:#006C99">Details/Provider</span></b><o:p></o:p></p></td><td width="23%" valign=top style="width:23.0%;background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><b><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:#006C99">Area of Study</span></b><o:p></o:p></p></td><td width="11%" valign=top style="width:11.0%;background:white;padding:3.0pt 3.0pt 3.0pt 3.0pt"><p class=MsoNormal><b><span style="font-size:9.0pt;font-family:"Arial","sans-serif";color:#006C99">Credits</span></b><o:p></o:p></p></td></tr>';
        genHTML.Story__c = '';
        
        genHTML.Story__c += '<table width="100%" border="0" align="center" cellpadding="4" cellspacing="2">';
        genHTML.Story__c += '  <tr>';
        genHTML.Story__c += '   <td colspan="5" align="center" valign="top" bgcolor="#005c83"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:14px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#ffffff;">FEATURED ACTIVITIES</span></td>';
        genHTML.Story__c += '  </tr>';
        genHTML.Story__c += '  <tr>';
        genHTML.Story__c += '   <td width="46%" align="left" valign="top" bgcolor="#ffffff"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#006c99;">Title</span></td>';
        genHTML.Story__c += '   <td width="17%" align="left" valign="top" bgcolor="#ffffff"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#006c99;">Details/Provider</span></td>';
        genHTML.Story__c += '   <td width="18%" align="left" valign="top" bgcolor="#ffffff"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#006c99;">Area of Study</span></td>';
        genHTML.Story__c += '   <td align="left" valign="top" bgcolor="#ffffff"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#006c99;">Credits</span></td>';
        genHTML.Story__c += '   <td align="left" valign="top" bgcolor="#ffffff"><span style="text-align:left;line-height:1.25em;font-weight:bold;font-size:12px;font-family:Arial,Geneva,Verdana,Helvetica,sans-serif;color:#006c99;">Submit Credits</span></td>';
        genHTML.Story__c += '  </tr>';
                
        
        String lastType = '';
        String provider = '';
        String location = '';
        String submitLink = '';
        String utmTracking = '';
        
        cust.clear();
        cust.addAll(selectedReadings);
        cust.addAll(booksAndJournals);
        cust.addAll(webcasts);
        cust.addAll(events);
        cust.addAll(trainingCourses);
        cust.addAll(universityCourses);
        
        cust.addAll(garpVolunteer);
        
        for(CPE_Activity__c cont :cust){
        
            if(cont.CPE_Activity_Type__r.Name != lastType) {
                String[] arguments = new String[] {cont.CPE_Activity_Type__r.Name};
                String formattedString = String.format(headerTemplateString, arguments);
                genHTML.Story__c += formattedString;
                lastType = cont.CPE_Activity_Type__r.Name;
            }
        
            if(cont.Provider__c != null) {
                provider = cont.Provider__c;
            } else if(cont.Organization__c!= null) {
                provider = cont.Organization__c;
            } else if(cont.Publication__c!= null) {
                provider = cont.Publication__c;
            } else if(cont.Description__c!= null) {
                if(cont.Description__c.length() > 30)
                    provider = cont.Description__c.subString(0,30);
                else if(cont.Description__c.length() > 0)
                    provider = cont.Description__c;
            }
            if(cont.Location__c != null)
                location = cont.Location__c;
            
            //Generate Date String for Google Analytics in format 'May_10_2015' 
            DateTime utmd = DateTime.now();
            String monthName = utmd.format('MMMMM');
            String dayOfMonth = utmd.format('d');
            String year = utmd.format('yyyy');
            String dateString = monthName + '_' + dayOfMonth + '_' + year;
            
            utmTracking = '&utm_content=' + dateString + '&utm_source=GA_Source{url}&utm_medium=email&utm_campaign=cpdnewsletter&utm_term=submitbutton';
                
            submitLink = 'https://my.garp.org/Login?start=cpe_activity/' + cont.Id + utmTracking;
                
            String[] arguments = new String[] {cont.URL__c, cont.Title__c, provider, cont.Area_of_Study__c, String.valueOf(cont.Credit__c), submitLink, cont.Date_Description__c, location};
            String formattedString = String.format(templateString, arguments);
            genHTML.Story__c = genHTML.Story__c + formattedString;
            
        }
        genHTML.Story__c = genHTML.Story__c + '</table>';
    }    
    
    public void sendEmail() {
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       
       //Retrieve email recipient's address from Custom Setting
       List<String> toAddresses = new List<String>();
       list<News_Feed_Selector__c> selector = News_Feed_Selector__c.getall().values();
       Set<String> emailids = new Set<String>();
       //System.debug(selector.Recipient_Emil__c);
       for(News_Feed_Selector__c email : selector)
     {
       emailids.add(email.Name);
     }
      for(string s :emailids)
       if (s != null) {
           toAddresses.add(s);
       }
      else {
        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'No Email address found in Custom Settings, using default value: websiteupdates@garp.com'));
         toAddresses.add('websiteupdates@garp.com'); 
       }
       
       mail.setToAddresses(toAddresses);
       mail.setSenderDisplayName('News Feed Selector');
       mail.setSubject('Newsletter Feed');
       mail.setBccSender(false);
       //mail.setUseSignature(true); ??
       mail.setPlainTextBody('HTML copy for CPD Outreach');
       //mail.setHtmlBody('<b> This is HTML body </b>' );
        
       List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
       Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
       efa.setFileName('newsletter.html');
       Blob body = Blob.valueOf(genHTML.Story__c);
       efa.setBody(body);
       fileAttachments.add(efa);
       mail.setFileAttachments(fileAttachments);
       
       if (!Test.isRunningTest() && selector != null) {
           Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
       }
       
       ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Email sent on ' + DateTime.now().format()));
       
    }
    
       
}