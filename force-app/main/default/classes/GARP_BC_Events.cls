public class GARP_BC_Events {

    public class eventRegistrationInfo {
        public eventInfo eventInfo;
        public String eventId;
        public String formKey;
        public Boolean isPayForEvent;
        public Boolean foundRates;
        public Boolean hasPromoCodes;
        public Boolean maxCapacityMet;
        public Boolean wireAllowed;
        public String rsvpCopy;
        public String rsvpWaitingListCopy;
        public Boolean rsvpActivityAsk;
        public Boolean rsvpActivityAskDiet;
        public Boolean rsvpActivityAskQuestion;
        public String rsvpActivityQuestion;
        public String eventQuestionTitle;
        public String eventQuestionDetail;
        public String vatProductCode;
		public List<eventRate> eventRates;
        public List<eventDiscount> eventPromos;
        
        public Boolean isMembersOnly;
        public Boolean isSCRHolderRequired;
        public Boolean isRAIHolderRequired;
        public Boolean isFRMCertifiedRequired;
        public Boolean isERPCertifiedRequired;
        public Boolean isMembershipPurchaseRequired;
        public Boolean isAuthenticationRequired;
        
        public Boolean isProfessionDetailsTitleRequested;
        public Boolean isProfessionDetailsRequired;
        
        public Boolean isBundledEvent;
        public String bundledEventId;    
        public eventRegistrationInfo bundledEventRegistrationInfo;
        public Boolean isBundledEventEligible;
        
        public eventRegistrationInfo(Chapter_Meeting__c meeting, eventInfo eventInfoIn) {
            eventId = meeting.Id;
            formKey = meeting.Content__r.Form__r.Form_Name__c;
            
            isPayForEvent = False;
            hasPromoCodes = False;
            maxCapacityMet = False;
            if(meeting.Registered__c > meeting.Maximum_Capacity__c) {
                maxCapacityMet = True;
            }
            wireAllowed = False;
            rsvpCopy = NULL;
            rsvpWaitingListCopy = NULL;

            rsvpActivityAsk = FALSE;
            rsvpActivityAskDiet = FALSE;
            rsvpActivityAskQuestion = FALSE;
            rsvpActivityQuestion = NULL;
            
            eventQuestionTitle = NULL;
            eventQuestionDetail = NULL;
            
            eventRates = NULL;
            
            isProfessionDetailsTitleRequested = meeting.Professional_Details_Request_Title__c;
            isProfessionDetailsRequired = meeting.Professional_Details_Required__c;

        	isBundledEvent = False;
            
            retChapterMeetingRates retChapterMeetingRates = getChapterMeetingRates(meeting.Id);
            GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','retChapterMeetingRates',retChapterMeetingRates);
            
            // Find last rate end date to adjust last day to register
            // Also set isPayForEvent
            isPayForEvent = False;
            foundRates = False;
            if(retChapterMeetingRates.hasRates && !retChapterMeetingRates.mapRates.isEmpty()) {
                foundRates = True;
                Date lastEndDate = Date.newInstance(1970, 1, 1);
                for(eventRate er :retChapterMeetingRates.mapRates.Values()) {
                    if(er.memberRate > 0 || er.nonMemberRate > 0) {
                        if(er.endDate > lastEndDate) {
                            lastEndDate = er.endDate;
                        }                        
                        isPayForEvent = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','lastDateToRegister',eventInfoIn.lastDateToRegister);
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','lastEndDate',lastEndDate);
                
                if(isPayForEvent && (lastEndDate < eventInfoIn.lastDateToRegister || eventInfoIn.lastDateToRegister == NULL)) {
                    eventInfoIn.lastDateToRegister = lastEndDate;
                    GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','Adjust lastDateToRegister',eventInfoIn.lastDateToRegister);
                }
            } else if(retChapterMeetingRates.hasRates && retChapterMeetingRates.mapRates.isEmpty()) {
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','Has Rates but none for today','');
                isPayForEvent = True;
            }
            
            List<Chapter_Meeting_Discount__c> chapterMeetingPromos = getChapterMeetingPromoCodes(meeting.Id);
            hasPromoCodes = False;
            eventPromos = new List<eventDiscount>();
            if(!chapterMeetingPromos.isEmpty()) {
                hasPromoCodes = True;
                for(Chapter_Meeting_Discount__c cmd :chapterMeetingPromos) {
                    eventDiscount eventDiscount = new eventDiscount(cmd);
                    eventPromos.add(eventDiscount);
                }
            }            
            GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','chapterMeetingPromos',chapterMeetingPromos);
            
            vatProductCode = NULL;
            eventInfo = eventInfoIn;
            
            isMembersOnly = False;
            isFRMCertifiedRequired = False;
            isERPCertifiedRequired = False;
			isSCRHolderRequired = False;
            isRAIHolderRequired = False;
            isMembershipPurchaseRequired = False;
            isAuthenticationRequired = False;
        }
        
        public eventRegistrationInfo(Event__c event, eventInfo eventInfoIn) {
            
            GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','eventInfoIn',eventInfoIn);
            Date tdy = Date.Today();
            
            eventId = event.Id;
            formKey = event.Content__r.Form__r.Form_Name__c;
            // This can be set manually
            maxCapacityMet = event.Max_Capacity_Met__c;
            // Also here is the check
            if(event.Maximum_number_of_Event_Registrations__c != NULL && event.Total_Event_Registration__c >= event.Maximum_number_of_Event_Registrations__c) {
                maxCapacityMet = True;
            }
            
            wireAllowed = True;
            if(event.Can_Pay_By_wire__c == FALSE || (event.Last_Date_for_Wire_Check_Registration__c != NULL && tdy > event.Last_Date_for_Wire_Check_Registration__c)) {
                wireAllowed = False;
            }
            
            rsvpCopy = event.RSVP_Copy__c;
            rsvpWaitingListCopy = event.RSVP_Waitlist_Copy__c;
            if(event.RSVP_Activity_Name__c != NULL || event.RSVP_Activity_Ask_Diet_Restrictions__c) {
                rsvpActivityAsk = TRUE;
                rsvpActivityAskDiet = event.RSVP_Activity_Ask_Diet_Restrictions__c;
                rsvpActivityAskQuestion = (event.RSVP_Activity_Question__c != NULL);
                rsvpActivityQuestion = event.RSVP_Activity_Question__c;
            }
            
            eventQuestionTitle = event.Event_Question_Title__c;
            eventQuestionDetail = event.Event_Question_Detail__c;

            isProfessionDetailsTitleRequested = event.Professional_Details_Request_Title__c;
            isProfessionDetailsRequired = event.Professional_Details_Required__c;
            
            Event__c bundleEvent;
            isBundledEvent = False;
            if(event.Parent_Event__c != NULL) {
                bundleEvent = event.Parent_Event__r;
            } else if(event.Events__r != NULL && !event.Events__r.IsEmpty()) {
                bundleEvent = event.Events__r[0];
            }
            
            if(bundleEvent != NULL) {
                bundledEventId = bundleEvent.Id;
                isBundledEvent = True;
            }
        	
            retEventRates retEventRates = getEventRates(event.Id);
            GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','retEventRates',retEventRates);
          
            // Find last rate end date to adjust last day to register
            // Also set isPayForEvent
            isPayForEvent = False;
            foundRates = False;
            if(retEventRates.hasRates && !retEventRates.mapRates.isEmpty()) {
                foundRates = True;
                Date lastEndDate = Date.newInstance(1970, 1, 1);
                for(eventRate er :retEventRates.mapRates.Values()) {
                    if(er.memberRate > 0 || er.nonMemberRate > 0) {
                        if(er.endDate > lastEndDate) {
                            lastEndDate = er.endDate;
                        }                        
                        isPayForEvent = True;
                    }
                }
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','lastDateToRegister',eventInfoIn.lastDateToRegister);
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','lastEndDate',lastEndDate);
                
                if(isPayForEvent && (lastEndDate < eventInfoIn.lastDateToRegister || eventInfoIn.lastDateToRegister == NULL)) {
                    eventInfoIn.lastDateToRegister = lastEndDate;
                    GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','Adjust lastDateToRegister',eventInfoIn.lastDateToRegister);
                }
            } else if(retEventRates.hasRates && retEventRates.mapRates.isEmpty()) {
                GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','Has Rates but none for today','');
                isPayForEvent = True;
            }
            
            List<Event_Discount__c> eventDiscs = getEventPromoCodes(event.Id);
            eventPromos = new List<eventDiscount>();
            hasPromoCodes = False;
            if(!eventDiscs.isEmpty()) {
                hasPromoCodes = True;
                for(Event_Discount__c ed :eventDiscs) {
                    eventDiscount eventDiscount = new eventDiscount(ed);
                    eventPromos.add(eventDiscount);
                }
            }
            GARP_Common.debugLog('GARP_BC_Events','eventRegistrationInfo','eventPromos',eventPromos);
            
            vatProductCode = event.VAT_Product_Code__c;
            eventInfo = eventInfoIn;
            
            isMembersOnly = False;
            isFRMCertifiedRequired = False;
            isERPCertifiedRequired = False;
            isSCRHolderRequired = False;
            isRAIHolderRequired = False;
            isMembershipPurchaseRequired = False;
            isAuthenticationRequired = False;

        }
    
        public eventRegistrationInfo(Webcast__c webcast, eventInfo eventInfoIn) {
            eventId = webcast.Id;
            formKey = webcast.Content__r.Form__r.Form_Name__c;
            
            isPayForEvent = False;
            hasPromoCodes = False;
            maxCapacityMet = False;           
            wireAllowed = True;
            vatProductCode = NULL;
            eventInfo = eventInfoIn;
            
            isMembersOnly = webcast.Members_Only__c;
            isSCRHolderRequired = webcast.SCR_Holder__c;
            isRAIHolderRequired = webcast.RAI_Holder__c;
            isFRMCertifiedRequired = webcast.FRM_Certified__c;
            isERPCertifiedRequired = webcast.ERP_Certified__c;
            isMembershipPurchaseRequired = False;
            isAuthenticationRequired = False;
            
            isProfessionDetailsTitleRequested = False;
            isProfessionDetailsRequired = webcast.Professional_Details_Required__c;
            
            isBundledEvent = False;
        }
        
    }

    public class eventInfo {
        public String eventId;       
        public String eventType;
        public String title;
        public String description;
        public String chapterName;
        public String deliveryMode;
        public String deliveryModeDescription;
        public DateTime startDateTime;
        public DateTime endDateTime;
        public Date lastDateToRegister;        
        public String timeZone;        
        public String locationDescription;
        public Boolean isOnDemand;
        public String ON24APIKey;
        public String ON24URL;
        public String ON24Id;
        public String onlineMeetingURL;
        public String virtualEventTitle;
        public DateTime virtualEventStartDateTime;
        public DateTime virtualEventEndDateTime;
        public String inPersonEventTitle;   
        public String inPersonEventLocation;
        public String sponsorName;
        public String sponsorPolicyURL;
        public Boolean isSponsored;
        public Boolean isInviteOnly;
        
        // Event Description and Add to Cal
        Public String startDate;
        Public String startTime;
        Public String endDate;
        Public String endTime;
        Public String addToCalDescription;
        Public String addToCalStartDateTime;
        Public String addToCalEndDateTime;
        Public String dateDescription;
        Public String timeDescription;
        Public String virtualStartDate;
        Public String virtualStartTime;
        Public String virtualEndDate;
        Public String virtualEndTime;
        Public String addToCalVirtualStartDateTime;
        Public String addToCalVirtualEndDateTime;
        Public String virtualDateDescription;
        Public String virtualTimeDescription;
        
        // RSVP Activity Info
        public String rsvpActivityName;
        public String rsvpActivityDetail;
        public DateTime rsvpActivityStartDateTime;
        public DateTime rsvpActivityEndDateTime;
        public String rsvpActivityMode; // In Person, Online, Hybrid
        public String rsvpActivityLocation;
        public String rsvpActivityMeetingURL;        
        Public String rsvpActivityDateDescription;
        Public String rsvpActivityTimeDescription;
        Public String rsvpActivityAddToCalDescription;
        Public String rsvpActivityAddToCalStartDateTime;
        Public String rsvpActivityAddToCalEndDateTime;
        
        public eventInfo(Chapter_Meeting__c meeting) {
            eventId = meeting.Id;
            eventType = 'chaptermeeting';
            title = meeting.Chapter_Meeting_Name__c;
            
            if(meeting.Synopsis__c != NULL) {
                addToCalDescription = meeting.Synopsis__c;
                if(meeting.ON24_URL__c != NULL) {
                    addToCalDescription += '<br/>' + meeting.ON24_URL__c;
                }
            } else {
                addToCalDescription = '';
                if(meeting.ON24_URL__c != NULL) {
                    addToCalDescription = meeting.ON24_URL__c;
                }
            }            
            
            chapterName = meeting.Chapter__r.Name;
            startDateTime = meeting.Start__c;
            endDateTime = meeting.End__c;
            startDate = startDateTime.format('MMMM d, yyyy');
            startTime = startDateTime.format('hh:mm a');
            endDate = endDateTime.format('MMMM d, yyyy');
            endTime = endDateTime.format('hh:mm a');
            addToCalStartDateTime = startDateTime.format('yyyy-MM-dd hh:mm a');
            addToCalEndDateTime = endDateTime.format('yyyy-MM-dd hh:mm a');
            
            isOnDemand = (DateTime.now() > meeting.End__c && meeting.ON24_Event_Id__c != NULL);
            if(isOnDemand) {
                deliveryMode = 'Online Only';    
            } else {
                deliveryMode = meeting.Delivery_Method__c;
            }
            
            deliveryModeDescription = formatDeliveryMode(deliveryMode);                

            // If is One Day event
            if(startDate == endDate) {
                dateDescription = startDate;
                timeDescription = startTime + ' - ' + endTime;
            } else {
                dateDescription = startDateTime.format('MMMM d') + ', ' + startTime + ' - ' + endDateTime.format('MMMM d') + ', ' + endTime;
                timeDescription = '';
            }
            
            if(!isOnDemand) {   
                if(meeting.Last_Day_of_Registration__c != NULL) {
                    lastDateToRegister = meeting.Last_Day_of_Registration__c;
                } else {
                    lastDateToRegister = Date.newInstance(endDateTime.year(), endDateTime.month(), endDateTime.day());    
                }
            }
            
            timeZone = meeting.Time_Zone__r.Name;
            locationDescription =  GARP_Common.newLineToBR(meeting.Content__r.Location__c);
            
            ON24URL = meeting.ON24_URL__c;
            ON24Id = meeting.ON24_Event_Id__c;
            ON24APIKey = meeting.ON24_API_Key__c;
            
            virtualEventTitle = meeting.Virtual_Title__c;
            if(meeting.Virtual_Start_DateTime__c != NULL && meeting.Virtual_End_DateTime__c != NULL) {
                virtualEventStartDateTime = meeting.Virtual_Start_DateTime__c;
                virtualEventEndDateTime = meeting.Virtual_End_DateTime__c;

                virtualStartDate = virtualEventStartDateTime.format('MMMM d, yyyy');
                virtualStartTime = virtualEventStartDateTime.format('h:mm a');
                virtualEndDate = virtualEventEndDateTime.format('MMMM d, yyyy');
                virtualEndTime = virtualEventEndDateTime.format('h:mm a');
                
                addToCalVirtualStartDateTime = virtualEventStartDateTime.format('yyyy-MM-dd h:mm a');
                addToCalVirtualEndDateTime = virtualEventEndDateTime.format('yyyy-MM-dd h:mm a');
                
                // If is One Day event
                if(virtualStartDate == virtualEndDate) {
                    virtualDateDescription = virtualStartDate;
                    virtualTimeDescription = virtualStartTime + ' - ' + virtualEndTime;
                } else {
                    virtualDateDescription = virtualEventStartDateTime.format('MMMM d') + ' - ' + virtualEndTime;
                    virtualTimeDescription = '';
                }                
            }
            inPersonEventTitle = meeting.In_Person_Title__c;
            inPersonEventLocation = formatInPersonEventLocation(meeting);
            isSponsored = meeting.Is_Sponsored__c;
        }
        
        public eventInfo(Event__c event) {
            eventId = event.Id;
            eventType = 'event';
            title = event.Title__c;            
            startDateTime = event.Start_Date__c;
            endDateTime = event.End_Date__c;
            timeZone = event.Time_Zone__r.Name;
            
            isOnDemand = (DateTime.now() > event.End_Date__c && event.ON24_Event_Id__c != NULL);
            if(isOnDemand) {
                deliveryMode = 'Online Only';    
            } else {
                deliveryMode = event.Delivery_Method__c;
            }
            
            deliveryModeDescription = formatDeliveryMode(deliveryMode);
            
            
            if(event.Custom_Location__c != NULL) {
                locationDescription =  event.Custom_Location__c;
            } else {
                locationDescription = '';
                if(event.VenueName__c != NULL) {
                	locationDescription = event.VenueName__c;    
                }
                if(locationDescription != '') {
                    locationDescription += ', ';
                }
                locationDescription += event.Address__c;
                
            }
            lastDateToRegister = event.Last_Date_For_Registration__c;
            
            ON24URL = event.ON24_URL__c;
            ON24Id = event.ON24_Event_Id__c;
            ON24APIKey = event.ON24_API_Key__c;
            
            isSponsored = event.Is_Sponsored_Event__c;
            sponsorName = event.Event_Sponsor__c;
            sponsorPolicyURL = event.Event_Sponsor_Policy_URL__c;
            
            isInviteOnly = event.Invite_Only__c;
            description = event.Description__c;
            
            if(event.Description__c != NULL) {
                addToCalDescription = event.Description__c;
                if(event.ON24_URL__c != NULL) {
                    addToCalDescription += '<br/>' + event.ON24_URL__c;
                }
            } else {
                addToCalDescription = '';
                if(event.ON24_URL__c != NULL) {
                    addToCalDescription = event.Title__c;
                }
            }
            
            startDate = startDateTime.format('MMMM d, yyyy');
            startTime = startDateTime.format('h:mm a');
            endDate = endDateTime.format('MMMM d, yyyy');
            endTime = endDateTime.format('h:mm a');
            addToCalStartDateTime = startDateTime.format('yyyy-MM-dd h:mm a');
            addToCalEndDateTime = endDateTime.format('yyyy-MM-dd h:mm a');

            // If is One Day event
            if(startDate == endDate) {
                dateDescription = startDate;
                timeDescription = startTime + ' - ' + endTime;
            } else {
                dateDescription = startDateTime.format('MMMM d') + ', ' + startTime + ' - ' + endDateTime.format('MMMM d') + ', ' + endTime;
                timeDescription = '';
            }
            
            rsvpActivityName = event.RSVP_Activity_Name__c;
            rsvpActivityDetail = event.RSVP_Activity_Details__c;
            rsvpActivityStartDateTime = event.RSVP_Activity_Start_Date_Time__c;
            rsvpActivityEndDateTime = event.RSVP_Activity_End_Date_Time__c;
            rsvpActivityLocation = event.RSVP_Activity_Location__c;
            rsvpActivityMeetingURL = event.RSVP_Activity_Online_Meeting_URL__c;
            
            if(rsvpActivityLocation != NULL && rsvpActivityMeetingURL == NULL) {
                rsvpActivityMode = 'In-Person';
            } else if(rsvpActivityLocation == NULL && rsvpActivityMeetingURL != NULL) {
                rsvpActivityMode = 'Online';
            } else if(rsvpActivityLocation != NULL && rsvpActivityMeetingURL != NULL) {
                rsvpActivityMode = 'Hybrid';
            } else {
                rsvpActivityMode = NULL;
            }
            
            rsvpActivityAddToCalDescription = rsvpActivityDetail;
            if(rsvpActivityMeetingURL != NULL) {
                if(rsvpActivityAddToCalDescription == NULL) {
                    rsvpActivityAddToCalDescription = rsvpActivityMeetingURL;
                } else {
                    rsvpActivityAddToCalDescription += '<br/>' + rsvpActivityMeetingURL;    
                }
            }
    
            if(rsvpActivityStartDateTime != NULL && rsvpActivityEndDateTime != NULL) {
                rsvpActivityDateDescription = rsvpActivityStartDateTime.format('MMMM d, yyyy');
                rsvpActivityTimeDescription = rsvpActivityStartDateTime.format('h:mm a') + ' - ' + rsvpActivityEndDateTime.format('h:mm a');
                rsvpActivityAddToCalStartDateTime = rsvpActivityStartDateTime.format('yyyy-MM-dd h:mm a');
                rsvpActivityAddToCalEndDateTime = rsvpActivityEndDateTime.format('yyyy-MM-dd h:mm a');
            }
        }
        
        public eventInfo(Webcast__c webcast) {
            eventId = webcast.Id;
            eventType = eventType;
            title = webcast.Title__c;
            deliveryMode = 'Online Only';
            deliveryModeDescription = formatDeliveryMode(deliveryMode);
            startDateTime = webcast.Start_Date__c;
            endDateTime = webcast.End_Date__c;                
            timeZone = webcast.Time_Zone__r.Name;
            locationDescription = NULL;
            lastDateToRegister = NULL;
            isOnDemand = (DateTime.now() > webcast.End_Date__c);
            ON24URL = webcast.On_Demand_URL__c;
            ON24Id = webcast.EventId__c;
            ON24APIKey = webcast.X0n24_API_Key__c;
            isSponsored = webcast.Is_Sponsored__c;
            sponsorName = webcast.Sponsor_Name__c;
            sponsorPolicyURL = webcast.Sponsor_Policy_URL__c;
            
            if(webcast.Short_Description__c != NULL) {
                addToCalDescription = webcast.Short_Description__c + '<br/><p>' + webcast.On_Demand_URL__c + '</p>';
            } else {
                addToCalDescription = webcast.Title__c + '<br/><p>' + webcast.On_Demand_URL__c + '</p>';
            }
            
            startDate = startDateTime.format('MMMM d, yyyy');
            startTime = startDateTime.format('h:mm a');
            endDate = endDateTime.format('MMMM d, yyyy');
            endTime = endDateTime.format('h:mm a');
            addToCalStartDateTime = startDateTime.format('yyyy-MM-dd h:mm a');
            addToCalEndDateTime = endDateTime.format('yyyy-MM-dd h:mm a');
            
            // If is One Day event
            dateDescription = startDate;
            timeDescription = startTime + ' - ' + endTime;
            
        }
     
        public Integer compareTo(Object compareTo) {
            eventInfo compareItem = (eventInfo)compareTo;
            if (startDateTime == compareItem.startDateTime) return 0;
            if (startDateTime > compareItem.startDateTime) return 1;
            return -1;   
        }
    }

    public class eventOptions {
        public String attendanceMethod;
        public Boolean willAttendRSVPActivity;
        public String dietaryRestrictionDetails;
        public String activityQuestionResponse;
        public String eventQuestionResponse;
    }

    // Registration Methods
    public static GARP_BC_Registration.programRegistrationInfo getEventRegistrationSettings(String eventId, String regCode) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'event';
        programRegistrationInfo.mainMemberProductCode = 'CRTM';
        programRegistrationInfo.mainNonMemberProductCode = 'CRTNM';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{'MEMI','MEMC'}; 
        programRegistrationInfo.regCode = regCode;
        programRegistrationInfo.formName = null;
        programRegistrationInfo.contractRecTypeName = NULL;
        programRegistrationInfo.eventId = eventId;
        programRegistrationInfo.eventType = 'event';
        programRegistrationInfo.eventDiscountProductCode = 'EVTDSC';
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;
        
        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo updateEventRegInfo(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo, GARP_BC_Registration.getRegistrationInfo regInfo) {
        if(regInfo != NULL && regInfo.eventRegistrationInfo != NULL) {    
            
            if(regInfo.eventRegistrationInfo.formKey != NULL) {
                programRegistrationInfo.formName = regInfo.eventRegistrationInfo.formKey;    
            }
            
            regInfo.programRegistrationInfo.eventId = regInfo.eventRegistrationInfo.eventId;
            if(regInfo.eventRegistrationInfo.eventInfo.isInviteOnly != NULL && regInfo.eventRegistrationInfo.eventInfo.isInviteOnly) {
                regInfo.programRegistrationInfo.allowMemberPublicRegistration = True;
                regInfo.programRegistrationInfo.addressVerificationDisabled = True;
            }            
        }        
        return regInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo getEventRegistrationInfo(String eventId, String regCode) {        
       
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = getEventRegistrationSettings(eventId, regCode);
        GARP_Common.debugLog('GARP_BC_Events','getEventRegistrationInfo','Set programRegistrationInfo',programRegistrationInfo);
        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Events','getEventRegistrationInfo','Return regInfo', regInfo);
        
        regInfo = updateEventRegInfo(programRegistrationInfo, regInfo);
        GARP_Common.debugLog('GARP_BC_Events','getEventRegistrationInfo','Return regInfo final', regInfo);
        
        return regInfo;
    }
    
    public static GARP_BC_Registration.programRegistrationInfo getChapterMeetingRegistrationSettings(String eventId) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'event';
        programRegistrationInfo.mainMemberProductCode = 'CRTM';
        programRegistrationInfo.mainNonMemberProductCode = 'CRTNM';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{'MEMI','MEMC'};    
        programRegistrationInfo.formName = null;
        programRegistrationInfo.contractRecTypeName = NULL;
        programRegistrationInfo.eventId = eventId;
        programRegistrationInfo.eventType = 'chaptermeeting';
        programRegistrationInfo.eventDiscountProductCode = 'EVTDSC';
        programRegistrationInfo.allowMemberPublicRegistration = False;
        programRegistrationInfo.addressVerificationDisabled = False;
        
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingRegistrationSettings','programRegistrationInfo',programRegistrationInfo);
        
        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo updateChapterMeetingRegInfo(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo, GARP_BC_Registration.getRegistrationInfo regInfo) {
        if(regInfo != NULL && regInfo.eventRegistrationInfo != NULL) { 
            if(regInfo.eventRegistrationInfo.formKey != NULL) {
                programRegistrationInfo.formName = regInfo.eventRegistrationInfo.formKey;    
            }
            regInfo.programRegistrationInfo.eventId = regInfo.eventRegistrationInfo.eventId;
            GARP_Common.debugLog('GARP_BC_Events','updateChapterMeetingRegInfo','Return regInfo final', regInfo);
        }
        return regInfo;
    }

    
    public static GARP_BC_Registration.getRegistrationInfo getChapterMeetingRegistrationInfo(String eventId) {        
       
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = getChapterMeetingRegistrationSettings(eventId);
        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        
        regInfo = updateChapterMeetingRegInfo(programRegistrationInfo, regInfo);
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingRegistrationInfo','Return regInfo final', regInfo);
        
        return regInfo;
    }
    
    public static GARP_BC_Registration.programRegistrationInfo getWebcastRegistrationSettings(String eventId) {
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = new GARP_BC_Registration.programRegistrationInfo();
        programRegistrationInfo.registrationType = 'event';
        programRegistrationInfo.mainMemberProductCode = 'CRTM';
        programRegistrationInfo.mainNonMemberProductCode = 'CRTNM';
        programRegistrationInfo.retakeProductCode  = NULL;
        programRegistrationInfo.studyMatProductCodes = new List<String>{};
        programRegistrationInfo.addOnsProductCodes = new List<String>{'MEMI','MEMC'};    
        programRegistrationInfo.formName = null;
        programRegistrationInfo.contractRecTypeName = NULL;
        programRegistrationInfo.eventId = eventId;
        programRegistrationInfo.eventType = 'webcast';
        programRegistrationInfo.allowMemberPublicRegistration = True;
        programRegistrationInfo.addressVerificationDisabled = True;   
        
        GARP_Common.debugLog('GARP_BC_Events','getWebcastRegistrationSettings','programRegistrationInfo',programRegistrationInfo);
        
        return programRegistrationInfo;
    }
    
    public static GARP_BC_Registration.getRegistrationInfo updateWebcastRegInfo(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo, GARP_BC_Registration.getRegistrationInfo regInfo) {
        if(regInfo != NULL && regInfo.eventRegistrationInfo != NULL) { 
            if(regInfo.eventRegistrationInfo.formKey != NULL) {
                programRegistrationInfo.formName = regInfo.eventRegistrationInfo.formKey;    
            }
            regInfo.programRegistrationInfo.eventId = regInfo.eventRegistrationInfo.eventId;
            
            GARP_Common.debugLog('GARP_BC_Events','updateWebcastRegInfo','eventRegistrationInfo',regInfo.eventRegistrationInfo);
            GARP_Common.debugLog('GARP_BC_Events','updateWebcastRegInfo','membershipInfo',regInfo.membershipInfo);
            
            if(regInfo.eventRegistrationInfo.isMembersOnly && (regInfo.membershipInfo == NULL || !regInfo.membershipInfo.isInGoodStanding)) {
                regInfo.eventRegistrationInfo.isMembershipPurchaseRequired = True;
            }
            if(regInfo.eventRegistrationInfo.isSCRHolderRequired || regInfo.eventRegistrationInfo.isRAIHolderRequired || regInfo.eventRegistrationInfo.isFRMCertifiedRequired || regInfo.eventRegistrationInfo.isERPCertifiedRequired) {
                regInfo.eventRegistrationInfo.isAuthenticationRequired = True;
            }
            
            GARP_Common.debugLog('GARP_BC_Events','updateWebcastRegInfo','Return regInfo final', regInfo);
        }
        return regInfo;
    }

    
    public static GARP_BC_Registration.getRegistrationInfo getWebcastRegistrationInfo(String eventId) {        
       
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = getWebcastRegistrationSettings(eventId);
        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        
        regInfo = updateWebcastRegInfo(programRegistrationInfo, regInfo);
        GARP_Common.debugLog('GARP_BC_Events','getWebcastRegistrationInfo','Return regInfo final', regInfo);
        
        return regInfo;
    }
    
    public class eventMainProdInfo {
        public PricebookEntry eventPbe;
        public PricebookEntry discountPbe;
        public List<GARP_BC_Registration.promoCodeVerify> promoCodes;
    }
    
    public static eventMainProdInfo getEventMainProduct(MAP<String,PricebookEntry> mapProdByCodes, GARP_BC_Membership.membershipInfo membershipInfo, MAP<String,eventRate> mapEventRates, MAP<String,eventDiscount> mapEventDiscounts, GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo, GARP_BC_Registration.teamRegInfo teamRegInfo) {
        eventMainProdInfo eventMainProdInfo = new eventMainProdInfo();
        
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','mapProdByCodes',mapProdByCodes);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','mapEventRates',mapEventRates);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','mapEventDiscounts',mapEventDiscounts);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','getRegistrationFeesInfo',getRegistrationFeesInfo);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','teamRegInfo',teamRegInfo);
        
        PricebookEntry eventPbe;
        String eventRateProductCode;
        String eventRateGLCode;
        Decimal eventRateAmount;
        Decimal eventTeamRateAmount; // Whats configure on Event Rate
        
        PricebookEntry eventDiscPbe = mapProdByCodes.get(getRegistrationFeesInfo.programRegistrationInfo.eventDiscountProductCode+':4999');
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Find eventDiscPbe',eventDiscPbe);
        
        eventRate eventRate;
        
        if(getRegistrationFeesInfo.programRegistrationInfo.eventId != NULL) {
                        
            if(!mapEventRates.IsEmpty()) {
                
                //String memberEventRateProductCode;
                //String memberEventRateGLCode;
                //Decimal memberEventRateAmount;
                
                //String nonMemberEventRateProductCode;
                //String nonMemberEventRateGLCode;
                //Decimal nonMemberEventRateAmount;
                
                for(eventRate er :mapEventRates.values()) { 
                    
                    GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Loop rates',er);
                    
                    eventRate = er;
                    
                    /*
                    if(teamRegInfo != NULL && teamRegInfo.isEvent && teamRegInfo.isComplimentary) {
                        
                        Decimal eventTeamRate = er.teamRate;
                        eventTeamRate = 0;
                        
                        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventTeamRate',eventTeamRate);
                        
                        memberEventRateProductCode = er.teamProductCode;
                        memberEventRateGLCode = er.teamGLCode;
                        memberEventRateAmount = eventTeamRate;
                        nonMemberEventRateProductCode = er.teamProductCode;
                        nonMemberEventRateGLCode = er.teamGLCode;
                        nonMemberEventRateAmount = eventTeamRate;
                    } else {
                        if(er.memberRate != NULL && er.memberProductCode != NULL) {
                            memberEventRateProductCode = er.memberProductCode;
                            memberEventRateGLCode = er.memberGLCode;
                            memberEventRateAmount = er.memberRate;
                        }
                        if(er.nonMemberRate != NULL && er.nonMemberProductCode != NULL) {
                            nonMemberEventRateProductCode = er.nonMemberProductCode;
                            nonMemberEventRateGLCode = er.nonMemberGLCode;
                            nonMemberEventRateAmount = er.nonMemberRate;
                        }
                    } 
					*/
                }
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRate',eventRate);
                
                /*
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','memberEventRateProductCode',memberEventRateProductCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','memberEventRateGLCode',memberEventRateGLCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','memberEventRateAmount',memberEventRateAmount);
                
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','nonMemberEventRateProductCode',nonMemberEventRateProductCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','nonMemberEventRateGLCode',nonMemberEventRateGLCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','nonMemberEventRateAmount',nonMemberEventRateAmount);
                */
                
                if((getRegistrationFeesInfo.membershipOptions != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedMembership != NULL && getRegistrationFeesInfo.membershipOptions.hasSelectedMembership) || (membershipInfo != NULL && membershipInfo.isInGoodStanding)) {
                    if(getRegistrationFeesInfo.isEventBundleSelected) {
                        eventRateProductCode = eventRate.memberBundleProductCode;
                        eventRateGLCode = eventRate.memberBundleGLCode;
                        eventRateAmount = eventRate.memberBundleRate;                        
                    } else {
                        eventRateProductCode = eventRate.memberProductCode;
                        eventRateGLCode = eventRate.memberGLCode;
                        eventRateAmount = eventRate.memberRate;
                    }
                } else if(eventRate.nonMemberProductCode != NULL) {
                    if(getRegistrationFeesInfo.isEventBundleSelected) {
                        eventRateProductCode = eventRate.nonMemberBundleProductCode;
                        eventRateGLCode = eventRate.nonMemberBundleGLCode;
                        eventRateAmount = eventRate.nonMemberBundleRate;                        
                    } else {
                        eventRateProductCode = eventRate.nonMemberProductCode;
                        eventRateGLCode = eventRate.nonMemberGLCode;
                        eventRateAmount = eventRate.nonMemberRate;
                    }
                }
                
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateProductCode1',eventRateProductCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateGLCode1',eventRateGLCode);
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateAmount1',eventRateAmount);
                
                // Use Team Product and Rate Info
                if(teamRegInfo != NULL && teamRegInfo.isEvent) {
                    if(teamRegInfo.isBundle) {
                        if(teamRegInfo.rateType == NULL || teamRegInfo.rateType == 'Non-Member') {
                            eventRateProductCode = eventRate.teamNonMemberBundleProductCode;
                            eventRateGLCode = eventRate.teamNonMemberBundleGLCode;
                            eventRateAmount = eventRate.teamNonMemberBundleRate;
                        } else {
                            eventRateProductCode = eventRate.teamMemberBundleProductCode;
                            eventRateGLCode = eventRate.teamMemberBundleGLCode;
                            eventRateAmount = eventRate.teamMemberBundleRate;                            
                        }
                    } else {
                        if(teamRegInfo.rateType == NULL || teamRegInfo.rateType == 'Non-Member') {
                            eventRateProductCode = eventRate.teamNonMemberProductCode;
                            eventRateGLCode = eventRate.teamNonMemberGLCode;
                            eventRateAmount = eventRate.teamNonMemberBaseRate;                            
                        } else {
                            eventRateProductCode = eventRate.teamMemberProductCode;
                            eventRateGLCode = eventRate.teamMemberGLCode;
                            eventRateAmount = eventRate.teamMemberBaseRate;
                        }
                    }
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateProductCode',eventRateProductCode);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateGLCode',eventRateGLCode);
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','eventRateAmount',eventRateAmount);
                
        // Promo Code Map, removes duplicates
        MAP<String,GARP_BC_Registration.promoCodeVerify> mapPromoCodes = new MAP<String,GARP_BC_Registration.promoCodeVerify>();

        if(eventRateProductCode != NULL) {
                                    
            GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','promoCodes',getRegistrationFeesInfo.promoCodes);
            if(getRegistrationFeesInfo.promoCodes != NULL) {
                                
                // Set All Promo Codes sent in as Invalid
                // When used (below) set them to Valid
                for(GARP_BC_Registration.promoCodeVerify pv :getRegistrationFeesInfo.promoCodes) {
                    pv.isValid = False;
                    pv.message = 'This code is not applicable';
                    mapPromoCodes.put(pv.promoCode, pv);
                }
            }
            GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','mapPromoCodes',mapPromoCodes);
            
            // Find Event Rate & Set Rate
            eventPbe = mapProdByCodes.get(eventRateProductCode + ':' + eventRateGLCode);
            GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Find eventPbe',eventPbe);

            eventPbe.UnitPrice = eventRateAmount;
            
            if(eventPbe != NULL && (teamRegInfo == NULL || !teamRegInfo.isEvent)) {
                
                // Apply Discount
                if(!mapPromoCodes.values().isEmpty()) {    
                                        
                    if(eventDiscPbe != NULL) {
                        eventDiscPbe.UnitPrice = 0;                 
                        
                        // Allow loop for now, but wll only take the last one for now
                        for(GARP_BC_Registration.promoCodeVerify pv :mapPromoCodes.values()) {
                            
                            GARP_BC_Events.verifyDiscount verifyDiscount = computeEventDiscount(pv.promoCode, eventPbe, mapEventDiscounts);
                            GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','verifyDiscount',verifyDiscount);
                            
                            if(verifyDiscount.isValid) {
                                eventDiscPbe.UnitPrice += verifyDiscount.amount;
                                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','update price',eventPbe);
                                pv.isValid = True;
                                pv.message = 'This code is applicable';
                            } else {
                                pv.isValid = False;
                                pv.message = 'This code is not applicable';
                            }
                        }
                        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Final promoCodes',mapPromoCodes.values());
                        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Final eventDiscPbe',eventDiscPbe);
                        
                        if(eventDiscPbe.UnitPrice != 0) {
                            eventMainProdInfo.discountPbe = eventDiscPbe;
                        }
                    }
                }
            }
        }
        eventMainProdInfo.eventPbe = eventPbe;
        eventMainProdInfo.promoCodes = mapPromoCodes.values();
        
        if(teamRegInfo != NULL && teamRegInfo.isEvent) {
                        
			if(!teamRegInfo.isComplimentary) {
            
                if(teamRegInfo.eventDiscountPrice != NULL) {
                    eventDiscPbe.UnitPrice = (eventRateAmount - teamRegInfo.eventDiscountPrice) * -1;
                } else {
                    // Error is now required
                }
                eventMainProdInfo.discountPbe = eventDiscPbe;
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Add Team Discount',eventDiscPbe);
                
            } else if(teamRegInfo.prePaidDiscountPercent != NULL) {
                eventDiscPbe.UnitPrice = (eventRateAmount * (teamRegInfo.prePaidDiscountPercent * .01)) * -1;
                eventMainProdInfo.discountPbe = eventDiscPbe;
                GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Add Team Prepaid DiscPbe',eventDiscPbe);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getEventMainProduct','Final eventMainProdInfo',eventMainProdInfo);
        
        return eventMainProdInfo;
    }
    
    public static Event_Registration__c setRSVPInviteOnlyDecline(String eventId, String userEmail){
        
        Event_Registration__c eventRegistration;
        Event__c event = null;
        
        List<Event__c> events = [SELECT Id, Name, Invite_Only__c,Hide_Address_fields__c, Event_Participant_Login__c, Content__r.Custom_Header__c, Content__r.Custom_Footer__c FROM Event__c WHERE Id = :eventId LIMIT 1];
        
        //Ensure the event exists and is $0.00/Invite Only
        if(events.isEmpty()){          
            return NULL;
        }else if(!events[0].Invite_Only__c){
            return NULL;     
        }
        
        event = events[0];
        
        List<Event_Registration__c> existingEventRegistrations = [SELECT Id, Contact__c, Event__c, Member_Email__c, Status__c FROM Event_Registration__c WHERE Member_Email__c = :userEmail AND Event__c = :event.Id];
        if(existingEventRegistrations.isEmpty()){    
            
            eventRegistration = new Event_Registration__c();
            
            //eventRegistration.Contact__c = contact.Id;
            eventRegistration.Event__c   = event.Id;     
            eventRegistration.Member_Email__c  = userEmail;  
            eventRegistration.Status__c = 'RSVP Decline';
            
            INSERT eventRegistration;     
            
        } else {
            
            eventRegistration = existingEventRegistrations[0];
            eventRegistration.Status__c = 'RSVP Decline';
            
            UPDATE eventRegistration;
        }            
        
        return eventRegistration;          
    }
 
    // Helpers
    
    public static eventRegistrationInfo getEventInfo(String eventId, String eventType) {
        eventRegistrationInfo eventRegistrationInfo;
        
        GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventId',eventId);
        GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventType',eventType);
        
        if(eventType == 'chaptermeeting') {
            List<Chapter_Meeting__c> lstChapterMeeting = [SELECT Id, Chapter_Meeting_Name__c, Last_Day_of_Registration__c, Maximum_Capacity__c, Registered__c, VAT_Product_Code__c,
                                                          Professional_Details_Request_Title__c, Professional_Details_Required__c,
                                                          Start__c, End__c, Is_Sponsored__c, Sponsor_Name__c, Chapter__r.Name, Synopsis__c,
                                                          Time_Zone__r.Name, Content__r.Form__r.Form_Name__c, ON24_URL__c, ON24_Event_Id__c, ON24_API_Key__c,        
                                                          Virtual_Start_DateTime__c, Virtual_End_DateTime__c, Virtual_Meeting_URL__c, Virtual_Meeting_Instructions__c,
                                                          In_Person_Title__c, Virtual_Title__c, Delivery_Method__c, Content__r.Location__c,
                                                          Chapter_Meeting_Location__r.Name, Chapter_Meeting_Location__r.Building_Name__c, Chapter_Meeting_Location__r.Address_Street_1__c, Chapter_Meeting_Location__r.Address_Street_2__c,
                                                          Chapter_Meeting_Location__r.Address_City__c, Chapter_Meeting_Location__r.Address_Postal_Code__c,Chapter_Meeting_Location__r.Address_Country__c                                   
                                                          FROM Chapter_Meeting__c 
                                                          WHERE (Id = :eventId or Vanity_URL__c = :eventId) AND Status__c = 'Active'
                                                         ];    
            GARP_Common.debugLog('GARP_BC_Events','getEventInfo','lstChapterMeeting',lstChapterMeeting);
            
            if(!lstChapterMeeting.IsEmpty()) {
                Chapter_Meeting__c meeting = lstChapterMeeting[0];
                
                eventInfo eventInfo = new eventInfo(meeting);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventInfo',eventInfo);
                    
                eventRegistrationInfo = new eventRegistrationInfo(meeting, eventInfo);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventRegistrationInfo',eventRegistrationInfo);
            }
        } else if(eventType == 'event') {
            
            List < Event__c > lstEvents = [
                SELECT Id, Delivery_Method__c, ON24_Event_Id__c, ON24_URL__c, ON24_API_Key__c, VenueName__c, Address__c, Custom_Location__c, Invite_Only__c, Online_Meeting_URL__c,
                Professional_Details_Request_Title__c, Professional_Details_Required__c,                
                Start_Date__c, End_Date__c, Content__r.Form__r.Form_Name__c, Title__c, Description__c,
                Is_Sponsored_Event__c, Event_Sponsor__c, Event_Sponsor_Policy_URL__c, Can_Pay_By_wire__c, Last_Date_for_Wire_Check_Registration__c,  /// TO DO!!
                Last_Date_For_Registration__c, RSVP_Copy__c, Max_Capacity_Met__c, Maximum_number_of_Event_Registrations__c, Total_Event_Registration__c,
                RSVP_Waitlist_Copy__c, Time_Zone__r.Name, VAT_Product_Code__c, RSVP_Activity_Ask_Diet_Restrictions__c, RSVP_Activity_Details__c, RSVP_Activity_Name__c,
                RSVP_Activity_Question__c, RSVP_Activity_Start_Date_Time__c, RSVP_Activity_End_Date_Time__c, RSVP_Activity_Location__c, RSVP_Activity_Online_Meeting_URL__c,
                Event_Question_Title__c, Event_Question_Detail__c, Parent_Event__c, Parent_Event__r.Id,
                (SELECT Id, Name, Start_Date__c, End_Date__c, Member_Rate__c, Non_Member_Rate__c from Event_Rates__r WHERE (Start_Date__c <= TODAY and End_Date__c >= TODAY)),
                (SELECT Id from Events__r where Status__c = 'Active')
                FROM Event__c 
                WHERE (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active' 
            ];    
            GARP_Common.debugLog('GARP_BC_Events','getEventInfo','lstEvents',lstEvents);
            
            if(!lstEvents.IsEmpty()) {
                Event__c meeting = lstEvents[0];
                
                eventInfo eventInfo = new eventInfo(meeting);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventInfo',eventInfo);
                
                eventRegistrationInfo = new eventRegistrationInfo(meeting, eventInfo);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventRegistrationInfo',eventRegistrationInfo);

            }
        } else if(eventType == 'webcast') {
            List <Webcast__c> lstWebcasts = [SELECT Name, Id, Description__c, Short_Description__c, Duration__c, Start_Time__c, End_Time__c, 
                							 Professional_Details_Required__c,                                                             
                                             Start_Date__c, End_Date__c, Image__c, Status__c, Title__c, Is_Sponsored__c, Sponsor_Name__c, Sponsor_Policy_URL__c,
                                             EventId__c, On_Demand_URL__c, X0n24_API_Key__c, Content__r.Form__r.Form_Name__c, Time_Zone__r.Name, 
                                             Time_Zone__r.Abbreviation__c, Members_Only__c, SCR_Holder__c, RAI_Holder__c, FRM_Certified__c, ERP_Certified__c
                                             FROM Webcast__c 
                                             where (Id = :eventId OR Vanity_URL__c = :eventId) AND Status__c = 'Active'];
            GARP_Common.debugLog('GARP_BC_Events','getEventInfo','lstWebcasts',lstWebcasts);
            
            if(!lstWebcasts.IsEmpty()) {
                Webcast__c meeting = lstWebcasts[0];
                
                eventInfo eventInfo = new eventInfo(meeting);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventInfo',eventInfo);
                
                eventRegistrationInfo = new eventRegistrationInfo(meeting, eventInfo);
                GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventRegistrationInfo',eventRegistrationInfo);
            }
        }
        GARP_Common.debugLog('GARP_BC_Events','getEventInfo','eventRegistrationInfo',eventRegistrationInfo);
        return eventRegistrationInfo;
    }
        
    public static List<Event_Discount__c> getEventPromoCodes(String eventId) {
        List<Event_Discount__c> lstEventDiscounts = [Select Id, Name, Discount_Code__c, Discount_To_Fixed_Price__c, 
                                                         Fixed_Amount_Discount__c, Fixed_Percentage_Discount__c, Max_Allowed_Usage__c,
                                                         (Select Id, Name, Product__r.ProductCode, Product__r.GL_Code__c from Product_Discounts__r)
                                                         FROM Event_Discount__c WHERE Event__c = :eventId];
        GARP_Common.debugLog('GARP_BC_Events','getEventPromoCodes','lstEventDiscounts',lstEventDiscounts);
        return lstEventDiscounts;
    }
    
    public static List<Chapter_Meeting_Discount__c> getChapterMeetingPromoCodes(String eventId) {
        List<Chapter_Meeting_Discount__c> lstChapterMeetingDiscounts = [Select Id, Name, Discount_Code__c, Discount_To_Fixed_Price__c, 
                                                         Fixed_Amount_Discount__c, Fixed_Percentage_Discount__c, Max_Allowed_Usage__c,
                                                         (Select Id, Name, Product__r.ProductCode, Product__r.GL_Code__c from Product_Discounts__r)
                                                         FROM Chapter_Meeting_Discount__c WHERE Chapter_Meeting__c = :eventId];
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingPromoCodes','lstChapterMeetingDiscounts',lstChapterMeetingDiscounts);
        return lstChapterMeetingDiscounts;
    }
    
    public static GARP_BC_Registration.RegistrationEligibility isEligibleEvent(GARP_BC_Registration.programRegistrationInfo programRegistrationInfo, eventRegistrationInfo eventRegistrationInfo, GARP_BC_Membership.membershipInfo membershipInfo, Boolean isAuthenticated, GARP_BC_Registration.teamRegInfo teamRegInfo) {
        
        // DateTime endDateTime, Boolean isOnDemand, Boolean isPayForEvent, Boolean foundRates, Date lastDateToRegister, Boolean maxCapacityMet, 
        // eventRegistrationInfo.isSCRHolderRequired || eventRegistrationInfo.isRAIHolderRequired || eventRegistrationInfo.isFRMCertifiedRequired || eventRegistrationInfo.isERPCertifiedRequired
        
        GARP_BC_Registration.RegistrationEligibility regElig = new GARP_BC_Registration.RegistrationEligibility();
        
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','programRegistrationInfo',programRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','eventRegistrationInfo',eventRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','membershipInfo',membershipInfo);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','isAuthenticated',isAuthenticated);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','teamRegInfo',teamRegInfo);

        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','eventRegistrationInfo.eventInfo',eventRegistrationInfo.eventInfo);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','eventRegistrationInfo.eventInfo.endDateTime',eventRegistrationInfo.eventInfo.endDateTime);

        
        regElig.isEligible = True;
        Date tdy = Date.today();
        Date eventEndDate = Date.newInstance(eventRegistrationInfo.eventInfo.endDateTime.year(), eventRegistrationInfo.eventInfo.endDateTime.month(), eventRegistrationInfo.eventInfo.endDateTime.day());
        DateTime now = DateTime.now();
        
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','eventEndDate',eventEndDate);
        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','isOnDemand',eventRegistrationInfo.eventInfo.isOnDemand);
        
        if(programRegistrationInfo.eventType == 'event') {
            
            if(eventRegistrationInfo.eventInfo.isOnDemand) {
                // for now allow all registrations
            } else if((eventRegistrationInfo.isPayForEvent && !eventRegistrationInfo.foundRates) || (tdy > eventRegistrationInfo.eventInfo.lastDateToRegister)) {
                // If Payfor and no Rates available Or if past last register date, registration not available
                regElig.isEligible = False;
                regElig.eligibleError = 'Registration is currently not available';
            } else if(eventRegistrationInfo.maxCapacityMet) {
                regElig.isEligible = False;
                regElig.eligibleError = 'Maximum capacity has been met';                
            } else if(eventRegistrationInfo.isPayForEvent && isAuthenticated) {
                
                // check if already registered for this event
                List<Event_Registration__c> existingEventRegistrations = [SELECT Id, Status__c FROM Event_Registration__c WHERE Event__c = :eventRegistrationInfo.eventInfo.eventId AND Contact__c = :membershipInfo.contactRecord.Id AND Status__c = 'Registered and Paid'];
                GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','existingEventRegistrations', existingEventRegistrations); 
                if(!existingEventRegistrations.IsEmpty()) {
                    regElig.isEligible = False;
                    regElig.eligibleError = 'Already registered and paid for this event';  
                }

            } else if(teamRegInfo != NULL && teamRegInfo.isBundle && !eventRegistrationInfo.isBundledEvent) {
                regElig.isEligible = False;
                regElig.eligibleError = 'The team registration given is for a bundle but none was found';  
            }
            
        } else if(programRegistrationInfo.eventType == 'chaptermeeting') {
            
            if(eventRegistrationInfo.eventInfo.isOnDemand) {
                // for now allow all registrations
            } else if(tdy > eventRegistrationInfo.eventInfo.lastDateToRegister) {
                regElig.isEligible = False;    
                regElig.eligibleError = 'Registration period has ended';
            } else if(eventRegistrationInfo.maxCapacityMet) {
                regElig.isEligible = False;
                regElig.eligibleError = 'Maximum capacity has been met';                
            }
            
        } else if(programRegistrationInfo.eventType == 'webcast') {
            
            Boolean anyCertFound = False;
            if(membershipInfo != NULL && eventRegistrationInfo.isSCRHolderRequired && membershipInfo.isSCRHolder) {
                anyCertFound = TRUE;
            }
            if(membershipInfo != NULL && eventRegistrationInfo.isRAIHolderRequired && membershipInfo.isRAIHolder) {
                anyCertFound = TRUE;
            }
            if(membershipInfo != NULL && eventRegistrationInfo.isFRMCertifiedRequired && membershipInfo.isFRMCertified) {
                anyCertFound = TRUE;
            }
            if(membershipInfo != NULL && eventRegistrationInfo.isERPCertifiedRequired && membershipInfo.isERPCertified) {
                anyCertFound = TRUE;
            }
            
            if(eventRegistrationInfo.isSCRHolderRequired || eventRegistrationInfo.isRAIHolderRequired || eventRegistrationInfo.isFRMCertifiedRequired || eventRegistrationInfo.isERPCertifiedRequired) {
                if(!anyCertFound) {
                    regElig.isEligible = False;
                    
                    String examTypes = '';
                    if(eventRegistrationInfo.isFRMCertifiedRequired) { 
                        examTypes = 'FRM Certified';
                    }
                    if(eventRegistrationInfo.isERPCertifiedRequired) { 
                        if(examTypes != '') {
                            examTypes +=  ' or ';
                        }
                        examTypes += 'ERP Certified';
                    }
                    if(eventRegistrationInfo.isSCRHolderRequired) { 
                        if(examTypes != '') {
                            examTypes += ' or ';
                        }
                        examTypes += 'SCR holders';
                    }
                    if(eventRegistrationInfo.isRAIHolderRequired) { 
                        if(examTypes != '') {
                            examTypes += ' or ';
                        }
                        examTypes += 'RAI holders';
                    }
                    
                    regElig.eligibleError = 'This webcast is for ' + examTypes + ' only. If you are not one you can visit garp.org to explore our programs and register.';
                }
            }
        }

        GARP_Common.debugLog('GARP_BC_Events','isEligibleEvent','regElig',regElig);        
        return regElig;
    }
    
    public static List<SObject> createRegistrations(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo) {
        List<SObject> createdRegistrations = new List<SObject>();
        
        GARP_Common.debugLog('GARP_BC_Events','createRegistrations','setRegistrationInfo',setRegistrationInfo);        
        GARP_Common.debugLog('GARP_BC_Events','createRegistrations','setRegistrationReturnInfo',setRegistrationReturnInfo);        
        GARP_Common.debugLog('GARP_BC_Events','createRegistrations','eventRegistrationInfo',eventRegistrationInfo);        
        
        if(setRegistrationInfo.programRegistrationInfo.eventType == 'chaptermeeting') {
            SObject ret = createChapterMeetingRegistrations(setRegistrationInfo, setRegistrationReturnInfo);
            createdRegistrations.add(ret);
        } else if(setRegistrationInfo.programRegistrationInfo.eventType == 'webcast') {
            SObject ret = createWebcastRegistrations(setRegistrationInfo, setRegistrationReturnInfo);
            createdRegistrations.add(ret);
        } else if(setRegistrationInfo.programRegistrationInfo.eventType == 'event') {
            Boolean isBundle = False;
            if(eventRegistrationInfo.isBundledEvent && setRegistrationInfo.isEventBundleSelected) {
				isBundle = True;
            }
            SObject ret = createEventRegistrations(setRegistrationInfo, setRegistrationReturnInfo, eventRegistrationInfo);
            createdRegistrations.add(ret);
            if(isBundle) {
                SObject retBundle = createEventRegistrations(setRegistrationInfo, setRegistrationReturnInfo, eventRegistrationInfo.bundledEventRegistrationInfo);
                createdRegistrations.add(ret);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Return create',createdRegistrations);  
        
        // Send ON24 API call if has ON24 and is not paid for
        // Paid for events API call is made in provEventAndChptMtngs_Queueable.cls
        if(eventRegistrationInfo.eventInfo.ON24Id != NULL && !eventRegistrationInfo.isPayForEvent) {
            GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Main Event Has ON24',eventRegistrationInfo.eventInfo.ON24Id);  
            
            String mainEventRegId = createdRegistrations[0].Id;
                        
            API_Transaction__c trans = on24API.createAPITransactionRecord(setRegistrationInfo.programRegistrationInfo.eventType, mainEventRegId, setRegistrationReturnInfo.contactId, eventRegistrationInfo.eventInfo.ON24Id, eventRegistrationInfo.eventInfo.ON24APIKey);
            GARP_Common.debugLog('GARP_BC_Events','createRegistrations','APITrans',trans);  
            
            if(trans != null) {
                GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Send to ON24',trans.Id);  
                on24API.SendRequest(null, trans.Id);    
            }  
        }
        
        // ON24 for Bundle
        if(eventRegistrationInfo.isBundledEvent && setRegistrationInfo.isEventBundleSelected && createdRegistrations.size() > 1) {
            
            if(eventRegistrationInfo.bundledEventRegistrationInfo.eventInfo.ON24Id != NULL && !eventRegistrationInfo.isPayForEvent) {        
                String bundleEventRegId = createdRegistrations[1].Id;
                
                GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Bundle Event Has ON24',eventRegistrationInfo.bundledEventRegistrationInfo.eventInfo.ON24Id);  
                
                API_Transaction__c trans = on24API.createAPITransactionRecord(setRegistrationInfo.programRegistrationInfo.eventType, bundleEventRegId, setRegistrationReturnInfo.contactId, eventRegistrationInfo.bundledEventRegistrationInfo.eventInfo.ON24Id, eventRegistrationInfo.bundledEventRegistrationInfo.eventInfo.ON24APIKey);
                GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Bundle APITrans',trans);  
                
                if(trans != null) {
                    GARP_Common.debugLog('GARP_BC_Events','createRegistrations','Bundle Send to ON24',trans.Id);  
                    on24API.SendRequest(null, trans.Id);    
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','createRegistrations','createdRegistrations',createdRegistrations);        
        return createdRegistrations;
    }

    public static SObject createEventRegistrations(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo, GARP_BC_Events.eventRegistrationInfo eventRegistrationInfo) {
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','setRegistrationInfo',setRegistrationInfo);        
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','setRegistrationReturnInfo',setRegistrationReturnInfo);
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','eventRegistrationInfo',eventRegistrationInfo);        
        
        String eventId = eventRegistrationInfo.eventInfo.eventId;
        Boolean isPayForEvent = eventRegistrationInfo.isPayForEvent;
		Boolean isInviteOnly = eventRegistrationInfo.eventInfo.isInviteOnly;
        Boolean isBundle = setRegistrationInfo.isEventBundleSelected;

        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','eventId',eventId);
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','isPayForEvent',isPayForEvent);
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','isInviteOnly',isInviteOnly);
        GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','isBundle',isBundle);

        Event_Registration__c eventRegistration = new Event_Registration__c();
        
        //List<Event__c> lstEvents = [select Id, Invite_Only__c, Max_Capacity_Met__c, Is_Pay_For_Event__c from Event__c where Id = :eventId];
        //GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','lstEvents',lstEvents);  
        
        //if(!lstEvents.IsEmpty()) {
            //Event__c event = lstEvents[0];
            
            List<Event_Registration__c> existingEventRegistrations = [SELECT Id, Contact__c, Event__c, Member_Email__c, Status__c, Opportunity__c, Discount_Code_Used__c,
                                                                      Attendance_Method__c, RSVP_Activity_Attending__c,Dietary_Restriction__c, Dietary_Restriction_Description__c, 
                                                                      RSVP_Activity_Question_Response__c, Privacy_Policy_Attestation__c, Sponsor_Information_Exchange_Attestation__c, 
                                                                      Event_Question_Response__c, GARP_Information_Exchange_Attestation__c
                                                                      FROM Event_Registration__c WHERE Member_Email__c = :setRegistrationInfo.customerInfo.email AND Event__c = :eventId];
            GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','existingEventRegistrations',existingEventRegistrations);  
            
            if(!existingEventRegistrations.isEmpty()){  
                eventRegistration = existingEventRegistrations[0];
            } else {
                eventRegistration.Event__c = eventId;         
            }
            eventRegistration.Contact__c = setRegistrationReturnInfo.contactId;  
            eventRegistration.Member_Email__c = setRegistrationInfo.customerInfo.email;   
            
            if(setRegistrationReturnInfo.orderId != NULL) {
                eventRegistration.Opportunity__c = setRegistrationReturnInfo.orderId;                
            }
            
            if(setRegistrationInfo.promoCodes != NULL && setRegistrationInfo.promoCodes.size() > 0) {
                eventRegistration.Discount_Code_Used__c = setRegistrationInfo.promoCodes[0].promoCode;
            }
            
            eventRegistration.Event_Registration_Date__c = DateTime.now();
            eventRegistration.Attendee_Type__c = 'Participant';
            
            eventRegistration.Member_Email__c = setRegistrationInfo.customerInfo.email;  
            
            if(isInviteOnly) {
                eventRegistration.Status__c = 'RSVP Accept';    
            } else {
                if(!isPayForEvent) {
                  eventRegistration.Status__c = 'Registered';  
                }
            }
            //if(event.Max_Capacity_Met__c){
            //    eventRegistration.Status__c = 'Waitlisted';
            //}
            
            if(setRegistrationInfo.eventOptions != NULL) {
                
                if(setRegistrationInfo.eventOptions.attendanceMethod != null){
                    eventRegistration.Attendance_Method__c = setRegistrationInfo.eventOptions.attendanceMethod;
                }
                if(setRegistrationInfo.eventOptions.willAttendRSVPActivity != null){
                    eventRegistration.RSVP_Activity_Attending__c = setRegistrationInfo.eventOptions.willAttendRSVPActivity;
                }
                if(setRegistrationInfo.eventOptions.dietaryRestrictionDetails != null){
                    eventRegistration.Dietary_Restriction__c = TRUE;
                    eventRegistration.Dietary_Restriction_Description__c = setRegistrationInfo.eventOptions.dietaryRestrictionDetails;
                }
                if(setRegistrationInfo.eventOptions.activityQuestionResponse != null){
                    eventRegistration.RSVP_Activity_Question_Response__c = setRegistrationInfo.eventOptions.activityQuestionResponse;
                }
                if(setRegistrationInfo.eventOptions.eventQuestionResponse != null){
                    eventRegistration.Event_Question_Response__c = setRegistrationInfo.eventOptions.eventQuestionResponse;
                } 
            } 
    
            if(setRegistrationInfo.consentInfo.privacyPolicyAttestation != null && setRegistrationInfo.consentInfo.privacyPolicyAttestation){ 
                eventRegistration.Privacy_Policy_Attestation__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.sponsorContentAttestation != null && setRegistrationInfo.consentInfo.sponsorContentAttestation){ 
                eventRegistration.Sponsor_Information_Exchange_Attestation__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.valuableContentAttestation != null && setRegistrationInfo.consentInfo.valuableContentAttestation){ 
                eventRegistration.GARP_Information_Exchange_Attestation__c = System.now();
            }
	        eventRegistration.Event_Bundle_Registration__c  = isBundle;
            
            GARP_Common.debugLog('GARP_BC_Events','createEventRegistrations','upsert eventRegistration',eventRegistration);  
            upsert eventRegistration;
        //}
        return eventRegistration;
    }
    
    public static SObject createWebcastRegistrations(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo) {
        GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistrations','setRegistrationInfo',setRegistrationInfo);        
        GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistrations','setRegistrationReturnInfo',setRegistrationReturnInfo);        
        
        String eventId = setRegistrationInfo.programRegistrationInfo.eventId;
        Webcast_Registration__c webcastRegistration = new Webcast_Registration__c();
        
        List<Webcast_Registration__c> lstWebcastRegs = [select Id, Name, Contact__c, Status__c, Webcast__c, Webcast_Registration_Date__c, Email__c,
                                                        Privacy_Policy_Attestation__c, Agree_To_Sponsor_Contact__c, Agree_To_GARP_Content__c 
                                                        from Webcast_Registration__c where Webcast__c = :eventId and Contact__c = :setRegistrationReturnInfo.contactId];
        GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistrations','lstChaptMeetRegs',lstWebcastRegs);        
                
        if(!lstWebcastRegs.IsEmpty()) {
            webcastRegistration = lstWebcastRegs[0];
        }
        GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistrations','chapterMeetingRegistration',webcastRegistration);
        
        List<Webcast__c> lstWebcast = [select Id, Name from Webcast__c where Id = :eventId];
        if(!lstWebcast.isEmpty()) {
            Webcast__c webcast = lstWebcast[0];
            
            String objName = setRegistrationInfo.customerInfo.firstName + ' ' + setRegistrationInfo.customerInfo.lastName + '/' + webcast.Name;
            
            webcastRegistration.Name = objName.left(80);
            webcastRegistration.Contact__c = setRegistrationReturnInfo.contactId;
            webcastRegistration.Status__c = 'Registered';
            webcastRegistration.Webcast__c = eventId;
            
            webcastRegistration.Webcast_Registration_Date__c = Date.Today();
            webcastRegistration.Email__c = setRegistrationInfo.customerInfo.email;
            
            if(setRegistrationInfo.consentInfo.privacyPolicyAttestation != null && setRegistrationInfo.consentInfo.privacyPolicyAttestation){ 
                webcastRegistration.Privacy_Policy_Attestation__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.sponsorContentAttestation != null && setRegistrationInfo.consentInfo.sponsorContentAttestation){ 
                webcastRegistration.Agree_To_Sponsor_Contact__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.valuableContentAttestation != null && setRegistrationInfo.consentInfo.valuableContentAttestation){ 
                webcastRegistration.Agree_To_GARP_Content__c = System.now();
            }
            
            GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistrations','upsert webcastRegistration',webcastRegistration);        
            upsert webcastRegistration;
            
            //if(lstWebcastRegs.IsEmpty()) {
            //    Utilities.migrateLeadFormDataToContact(null, setRegistrationReturnInfo.contactId, setRegistrationInfo.programRegistrationInfo.formName, null);
            //}    
            
        }
        
        return webcastRegistration;
    }
    
    public static SObject createChapterMeetingRegistrations(GARP_BC_Registration.setRegistrationInfo setRegistrationInfo, GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo) {
        
        GARP_Common.debugLog('GARP_BC_Events','createChapterMeetingRegistrations','setRegistrationInfo',setRegistrationInfo);        
        GARP_Common.debugLog('GARP_BC_Events','createChapterMeetingRegistrations','setRegistrationReturnInfo',setRegistrationReturnInfo);        
        
        String eventId = setRegistrationInfo.programRegistrationInfo.eventId;
        Chapter_Meeting_Registration__c chapterMeetingRegistration = new Chapter_Meeting_Registration__c();
        
        List<Chapter_Meeting_Registration__c> lstChaptMeetRegs = [select Id, Name, Status__c, Role__c, Chapter_Meeting__c, Contact__c, Opportunity__c, Opportunity__r.StageName, Attendance_Method__c from Chapter_Meeting_Registration__c where Chapter_Meeting__c = :eventId and Contact__c = :setRegistrationReturnInfo.contactId];
        GARP_Common.debugLog('GARP_BC_Events','createChapterMeetingRegistrations','lstChaptMeetRegs',lstChaptMeetRegs);        
        
        if(lstChaptMeetRegs.IsEmpty()) {
            chapterMeetingRegistration.Status__c = 'Registered';
            chapterMeetingRegistration.Chapter_Meeting__c = eventId;
            chapterMeetingRegistration.Contact__c = setRegistrationReturnInfo.contactId;
            chapterMeetingRegistration.Opportunity__c = setRegistrationReturnInfo.orderId;
            
            chapterMeetingRegistration.Attendance_Method__c = setRegistrationInfo.eventOptions.attendanceMethod;
            
            if(setRegistrationInfo.consentInfo.privacyPolicyAttestation != null && setRegistrationInfo.consentInfo.privacyPolicyAttestation){ 
                chapterMeetingRegistration.Privacy_Policy_Attestation__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.sponsorContentAttestation != null && setRegistrationInfo.consentInfo.sponsorContentAttestation){ 
                chapterMeetingRegistration.Sponsor_Information_Exchange_Attestation__c = System.now();
            }
            if(setRegistrationInfo.consentInfo.valuableContentAttestation != null && setRegistrationInfo.consentInfo.valuableContentAttestation){ 
                chapterMeetingRegistration.GARP_Information_Exchange_Attestation__c = System.now();
            }            

            if(setRegistrationReturnInfo.orderId != NULL) {
                chapterMeetingRegistration.Opportunity__c = setRegistrationReturnInfo.orderId;    
                if(chapterMeetingRegistration.Opportunity__r.StageName == 'Closed') {
                    chapterMeetingRegistration.Status__c = 'Registered and Paid';
                }
            }
            
            if(setRegistrationInfo.promoCodes != NULL && setRegistrationInfo.promoCodes.size() > 0) {
                chapterMeetingRegistration.Discount_Code_Used__c = setRegistrationInfo.promoCodes[0].promoCode;
            }
            
	        insert chapterMeetingRegistration;

            //Utilities.migrateLeadFormDataToContact(null, setRegistrationReturnInfo.contactId, setRegistrationInfo.programRegistrationInfo.formName, null);
        }
        GARP_Common.debugLog('GARP_BC_Events','createChapterMeetingRegistrations','chapterMeetingRegistration',chapterMeetingRegistration);        
            
        return chapterMeetingRegistration;
    }

    public class returnCreateChapterMeetingRegistrationInfo {
        public Id contactId;
        public String webcastRegistrationId;
        public Boolean isExistingContact;        
    }
    
    // AG 5/3/2024 - Use new GARP_ classes
    // Only for use by logged in member portal users
    public static returnCreateChapterMeetingRegistrationInfo createOnDemandAuthenticatedUserChapterMeetingRegistration(String chapterMeetingId) {
        GARP_Common.debugLog('GARP_BC_Events','createOnDemandAuthenticatedUserChapterMeetingRegistration','chapterMeetingId',chapterMeetingId);
        
        returnCreateChapterMeetingRegistrationInfo returnChapterMeetingRegistrationInfo = new returnCreateChapterMeetingRegistrationInfo();
        
        // Prep reg info
        GARP_BC_Registration.programRegistrationInfo programRegistrationInfo = GARP_BC_Events.getChapterMeetingRegistrationSettings(chapterMeetingId);
        GARP_Common.debugLog('GARP_BC_Events','createOnDemandAuthenticatedUserChapterMeetingRegistration','Set programRegistrationInfo',programRegistrationInfo);
        
        GARP_BC_Registration.getRegistrationInfo regInfo = GARP_BC_Registration.getRegistrationInfo(programRegistrationInfo);
        GARP_Common.debugLog('GARP_BC_Events','createOnDemandAuthenticatedUserChapterMeetingRegistration','Return regInfo', regInfo);
        
        regInfo = GARP_BC_Events.updateChapterMeetingRegInfo(programRegistrationInfo, regInfo);
        
        GARP_BC_Registration.checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
        GARP_Common.debugLog('GARP_BC_Events','createOnDemandAuthenticatedUserChapterMeetingRegistration','checkAuth', checkAuth);
        
        if(checkAuth != NULL && checkAuth.contactId != NULL) {
            
            returnChapterMeetingRegistrationInfo.contactId = checkAuth.contactId;
            
            GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = new GARP_BC_Registration.setRegistrationInfo();
            setRegistrationInfo.programRegistrationInfo = programRegistrationInfo;
            setRegistrationInfo.consentInfo = new GARP_BC_Registration.consentInfo();
            setRegistrationInfo.programRegistrationInfo.formName = regInfo.eventRegistrationInfo.formKey;
            
            GARP_BC_Registration.setRegistrationReturnInfo setRegistrationReturnInfo = new GARP_BC_Registration.setRegistrationReturnInfo();
            setRegistrationReturnInfo.contactId = checkAuth.contactId;
            setRegistrationReturnInfo.orderId = NULL;
            setRegistrationInfo.eventOptions = new eventOptions();
            setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
                
            createRegistrations(setRegistrationInfo, setRegistrationReturnInfo, regInfo.eventRegistrationInfo);
            
            /*
            Contact contact = GARP_BC_Registration.getContactForFeesAndSetReg(checkAuth.contactId);
            GARP_Common.debugLog('GARP_BC_Events','createOnDemandAuthenticatedUserChapterMeetingRegistration','contact', contact);
            
            if(contact != NULL) {
                
                // Get Fees
                GARP_BC_Registration.getRegistrationFeesInfo getRegistrationFeesInfo = GARP_BC_Registration.getRegistrationFeesInfoFromAuthedContact(contact, programRegistrationInfo, False, 'Credit Card');
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','getRegistrationFeesInfo', getRegistrationFeesInfo);
                
                GARP_BC_Registration.registrationFees regFees = GARP_BC_Registration.getRegistrationFees(getRegistrationFeesInfo);
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','regFees', regFees);
                
                // Create Lead                
                GARP_BC_Registration.verifyExistingCustomerInfo verifyExistingCustomerInfo = new GARP_BC_Registration.verifyExistingCustomerInfo();
                verifyExistingCustomerInfo.firstName = contact.FirstName;
                verifyExistingCustomerInfo.lastName = contact.LastName;
                verifyExistingCustomerInfo.email = contact.Email;
                verifyExistingCustomerInfo.leadId = NULL;
                verifyExistingCustomerInfo.formKey = regInfo.programRegistrationInfo.formName;
                verifyExistingCustomerInfo.cta = NULL;
                verifyExistingCustomerInfo.allowMemberPublicRegistration = FALSE;
                
                GARP_BC_Registration.verifyExistingCustomerReturnInfo verifyExistingCustomerReturnInfo = GARP_MS_Registration.verifyExistingCustomer(verifyExistingCustomerInfo);
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','verifyExistingCustomerReturnInfo', verifyExistingCustomerReturnInfo);
                
                // Set Registration
                GARP_BC_Registration.setRegistrationInfo setRegistrationInfo = GARP_BC_Registration.setRegistrationInfoFromAuthedContact(contact, programRegistrationInfo, verifyExistingCustomerReturnInfo.leadId);
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','setRegistrationInfo', setRegistrationInfo);
                
                setRegistrationInfo.eventOptions.attendanceMethod = 'Virtual';
                GARP_BC_Registration.setRegistrationReturnInfo setRegRet = GARP_BC_Registration.setRegistration(setRegistrationInfo);
                
                // Close Order
                GARP_BC_Registration.createOrderInfo createOrderInfo = GARP_BC_Registration.createOrderFromAuthedContact(setRegistrationInfo, regFees, setRegRet);    
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','createOrderInfo', createOrderInfo);
                
                GARP_BC_Orders.setOrderReturnInfo payRegInfo = GARP_BC_Registration.payOrder(createOrderInfo);
                GARP_Common.debugLog('GARP_BC_Events','createWebcastRegistration','payRegInfo', payRegInfo);
            }
            */
        }
        
        return returnChapterMeetingRegistrationInfo;
    }
    
    public static String formatInPersonEventLocation(Chapter_Meeting__c cm) {
        String ret='';
        
        if(cm != NULL && cm.Chapter_Meeting_Location__r != NULL) {
            
            if(cm.Chapter_Meeting_Location__r.Name != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Name + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Building_Name__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Building_Name__c + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Address_Street_1__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Address_Street_1__c + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Address_Street_2__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Address_Street_2__c + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Address_City__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Address_City__c + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Address_Postal_Code__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Address_Postal_Code__c + '\n';
            }
            if(cm.Chapter_Meeting_Location__r.Address_Country__c != NULL) {
                ret += cm.Chapter_Meeting_Location__r.Address_Country__c;
            }
            
        }
        
        return ret;        
    }
    
    public static String formatDeliveryMode(String deliveryMode) {
        
        if(deliveryMode == NULL) {
            return 'Online';
        }
        
        if(deliveryMode == 'Online Only') {
            return 'Online';
        } else if(deliveryMode == 'In-Person Only') {
            return 'In-Person';
        } else {
            return deliveryMode;
        }
    }
 
    public class eventRate {
        public Date startDate;
        public Date endDate;
        public Decimal memberRate;
        public Decimal nonMemberRate;
        
        public Decimal memberBundleRate;
        public Decimal nonMemberBundleRate;
        
        public Decimal teamNonMemberBaseRate;
        public Decimal teamMemberBaseRate;
        
        public Decimal teamNonMemberBundleRate;
        public Decimal teamMemberBundleRate;
        
        public String memberProductCode;
        public String memberGLCode;
        public String nonMemberProductCode;
        public String nonMemberGLCode;

        public String memberBundleProductCode;
        public String memberBundleGLCode;
        public String nonMemberBundleProductCode;
        public String nonMemberBundleGLCode;

        public String teamMemberProductCode;
        public String teamMemberGLCode;
        public String teamNonMemberProductCode;
        public String teamNonMemberGLCode;

        public String teamNonMemberBundleProductCode;
        public String teamNonMemberBundleGLCode;
        public String teamMemberBundleProductCode;
        public String teamMemberBundleGLCode;

        public String vatProductCode;
        
         public eventRate(Event_Rate__c eventRate) {
             startDate = eventRate.Start_Date__c;
             endDate = eventRate.End_Date__c;
             
             memberRate = eventRate.Member_Rate__c;
             memberProductCode = eventRate.Product_Member_Code__r.ProductCode;
             memberGLCode = eventRate.Product_Member_Code__r.GL_Code__c;
             
             nonMemberRate = eventRate.Non_Member_Rate__c;
             nonMemberProductCode = eventRate.Product_Non_Member_Code__r.ProductCode;
             nonMemberGLCode = eventRate.Product_Non_Member_Code__r.GL_Code__c;
            
             memberBundleRate = eventRate.Bundle_Member_Rate__c ;
             memberBundleProductCode = eventRate.Product_Bundle_Member__r.ProductCode;
             memberBundleGLCode = eventRate.Product_Bundle_Member__r.GL_Code__c;
             
             nonMemberBundleRate = eventRate.Bundle_Non_Member_Rate__c ;
             nonMemberBundleProductCode = eventRate.Product_Bundle_Non_Member__r.ProductCode;
             nonMemberBundleGLCode = eventRate.Product_Bundle_Non_Member__r.GL_Code__c;

             teamMemberBaseRate = eventRate.Team_Member_Base_Rate__c;
             teamMemberProductCode = eventRate.Product_Team_Member__r.ProductCode;
             teamMemberGLCode = eventRate.Product_Team_Member__r.GL_Code__c;
             
             teamNonMemberBaseRate = eventRate.Team_Non_Member_Base_Rate__c;
             teamNonMemberProductCode = eventRate.Product_Team_Non_Member__r.ProductCode;
             teamNonMemberGLCode = eventRate.Product_Team_Non_Member__r.GL_Code__c;
             
             teamMemberBundleRate = eventRate.Team_Bundle_Member_Base_Rate__c;
             teamMemberBundleProductCode = eventRate.Product_Team_Bundle_Member__r.ProductCode;
             teamMemberBundleGLCode = eventRate.Product_Team_Bundle_Member__r.GL_Code__c;
             
             teamNonMemberBundleRate = eventRate.Team_Bundle_Non_Member_Base_Rate__c;             
             teamNonMemberBundleProductCode = eventRate.Product_Team_Bundle_Non_Member__r.ProductCode;  
             teamNonMemberBundleGLCode = eventRate.Product_Team_Bundle_Non_Member__r.GL_Code__c;

             vatProductCode = eventRate.Event__r.VAT_Product_Code__c;
         }
        
        public eventRate(Chapter_Meeting_Rate__c meetingRate) {
            startDate = meetingRate.Start_Date__c;
            endDate = meetingRate.End_Date__c;
            memberRate = meetingRate.Member_Rate__c;
            nonMemberRate = meetingRate.Non_Member_Rate__c;
            //teamNonMemberRate = meetingRate.Team_Rate__c;
            //teamMemberRate = meetingRate.Team_Member_Base_Rate__c;
            memberProductCode = meetingRate.Product_Member__r.ProductCode;
            memberGLCode = meetingRate.Product_Member__r.GL_Code__c;
            nonMemberProductCode = meetingRate.Product_Non_Member__r.ProductCode;
            nonMemberGLCode = meetingRate.Product_Non_Member__r.GL_Code__c;
            teamNonMemberProductCode = meetingRate.Product_Team__r.ProductCode;
            teamNonMemberGLCode = meetingRate.Product_Team__r.GL_Code__c;
            vatProductCode = meetingRate.Chapter_Meeting__r.VAT_Product_Code__c;
        }
    }
    
    public class retEventRates {
        public Boolean hasRates;
        public MAP<String,eventRate> mapRates;
    }
    
    public static retEventRates getEventRates(String eventId) {        
        GARP_Common.debugLog('GARP_BC_Events','getEventRates','eventId',eventId);
        
        retEventRates retEventRates = new retEventRates();
        
        retEventRates.mapRates = new MAP<String,eventRate>();
        
        List<Event_Rate__c> lstEventRates = [select Id, Name, Start_Date__c, End_Date__c, Member_Rate__c, Non_Member_Rate__c, 
                                             Team_Non_Member_Base_Rate__c, Team_Member_Base_Rate__c,
                                             Product_Member_Code__r.ProductCode, Product_Member_Code__r.GL_Code__c,
                                             Product_Non_Member_Code__r.ProductCode, Product_Non_Member_Code__r.GL_Code__c,
                                             Product_Bundle_Member__r.ProductCode, Product_Bundle_Member__r.GL_Code__c, 
                                             Product_Bundle_Non_Member__r.ProductCode, Product_Bundle_Non_Member__r.GL_Code__c,
                                             Bundle_Member_Rate__c, Bundle_Non_Member_Rate__c, 
                                             Team_Bundle_Member_Base_Rate__c, Team_Bundle_Non_Member_Base_Rate__c,
                                             Product_Team_Bundle_Member__r.ProductCode, Product_Team_Bundle_Member__r.GL_Code__c, 
                                             Product_Team_Bundle_Non_Member__r.ProductCode, Product_Team_Bundle_Non_Member__r.GL_Code__c, 
                                             Product_Team_Member__r.ProductCode, Product_Team_Member__r.GL_Code__c, 
                                             Product_Team_Non_Member__r.ProductCode, Product_Team_Non_Member__r.GL_Code__c,
                                             Event__r.VAT_Product_Code__c
                                             FROM Event_Rate__c WHERE Event__c = :eventId AND 
                                             ((Member_Rate__c != NULL AND Member_Rate__c > 0) OR (Non_Member_Rate__c != NULL AND Non_Member_Rate__c > 0))];
        GARP_Common.debugLog('GARP_BC_Events','getEventRates','lstEventRates',lstEventRates);
        
        if(!lstEventRates.IsEmpty()) {
            retEventRates.hasRates = True;
            Date tdy = Date.today();
            for(Event_Rate__c er :lstEventRates) {                    
                if(er.Start_Date__c<=tdy && er.End_Date__c>=tdy) {
                    eventRate eventRate = new eventRate(er);
                    retEventRates.mapRates.put(eventRate.nonMemberProductCode + ':' + eventRate.nonMemberGLCode, eventRate);                                                  
                }
            }
        } else {
            retEventRates.hasRates = False;
        }
        return retEventRates;
    }
    
	public class eventDiscount {
        public String discountCode;
        public Decimal discountToFixedPrice;
        public Decimal fixedAmountDiscount;
        public Decimal fixedPercentageDiscount;
        
        public eventDiscount(Event_Discount__c eventDisc) {
            discountCode = eventDisc.Discount_Code__c;
            discountToFixedPrice = eventDisc.Discount_To_Fixed_Price__c;
            fixedAmountDiscount = eventDisc.Fixed_Amount_Discount__c;
            fixedPercentageDiscount = eventDisc.Fixed_Percentage_Discount__c;
        }
        
        public eventDiscount(Chapter_Meeting_Discount__c meetingDisc) {
            discountCode = meetingDisc.Discount_Code__c;
            discountToFixedPrice = meetingDisc.Discount_To_Fixed_Price__c;
            fixedAmountDiscount = meetingDisc.Fixed_Amount_Discount__c;
            fixedPercentageDiscount = meetingDisc.Fixed_Percentage_Discount__c;            
        }
    }
    
    public static MAP<String,eventDiscount> getEventDiscounts(String eventId) {
        MAP<String,eventDiscount> mapEventDiscounts = new MAP<String,eventDiscount>();
        
        List<Event_Discount__c> lstEventDiscounts = [Select Id, Name, Discount_Code__c, Discount_To_Fixed_Price__c, 
                                                     Fixed_Amount_Discount__c, Fixed_Percentage_Discount__c, Max_Allowed_Usage__c,
                                                     (Select Id, Name, Product__r.ProductCode, Product__r.GL_Code__c from Product_Discounts__r)
                                                     FROM Event_Discount__c where Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Event__c = :eventId];
        GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','lstEventDiscounts',lstEventDiscounts);
        
        if(!lstEventDiscounts.IsEmpty()) {
            
            List<Event_Registration__c> lstEventRegWithDiscounts = [select id, Discount_Code_Used__c 
                                                                    from Event_Registration__c 
                                                                    where Event__c = :eventId 
                                                                    AND Discount_Code_Used__c != NULL AND Status__c in ('Registered','Registered and Paid')];
            GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','lstEventDiscounts',lstEventDiscounts);
            
            MAP<String,Integer> mapDiscountsUsed = new MAP<String,Integer>();
            for(Event_Registration__c er :lstEventRegWithDiscounts) {
                Integer discountsUsed = mapDiscountsUsed.get(er.Discount_Code_Used__c);
                if(discountsUsed == NULL) {
                    discountsUsed = 0;
                }
                discountsUsed++;
                mapDiscountsUsed.put(er.Discount_Code_Used__c, discountsUsed);
            }
            GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','mapDiscountsUsed',mapDiscountsUsed);
            
            for(Event_Discount__c edisc :lstEventDiscounts) {
                
                Integer discountsUsed = mapDiscountsUsed.get(edisc.Discount_Code__c);
                
                GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','discountsUsed',discountsUsed);
                GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','Max_Allowed_Usage__c',edisc.Max_Allowed_Usage__c);
                
                if(edisc.Max_Allowed_Usage__c == NULL || discountsUsed == NULL || discountsUsed < edisc.Max_Allowed_Usage__c) {
                    eventDiscount eventDiscount = new eventDiscount(edisc);
                    
                    for(Product_Discount__c pd :edisc.Product_Discounts__r) {
                        mapEventDiscounts.put(edisc.Discount_Code__c + ':' + pd.Product__r.ProductCode + ':' + pd.Product__r.GL_Code__c, eventDiscount);
                    }
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','mapEventDiscounts',mapEventDiscounts);
        return mapEventDiscounts;
    }
    
    public static MAP<String,eventDiscount> getChapterMeetingDiscounts(String metingId) {
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingDiscounts','metingId',metingId);
        
        MAP<String,eventDiscount> mapChapterMeetingDiscounts = new MAP<String,eventDiscount>();
        
        List<Chapter_Meeting_Discount__c> lstMeetingDiscountsDiscounts = [Select Id, Name, Discount_Code__c, Discount_To_Fixed_Price__c, 
                                                     Fixed_Amount_Discount__c, Fixed_Percentage_Discount__c, Max_Allowed_Usage__c,
                                                     (Select Id, Name, Product__r.ProductCode, Product__r.GL_Code__c from Product_Discounts__r)
                                                     FROM Chapter_Meeting_Discount__c where Start_Date__c <= TODAY AND End_Date__c >= TODAY AND Chapter_Meeting__c = :metingId];
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingDiscounts','lstMeetingDiscountsDiscounts',lstMeetingDiscountsDiscounts);
        
        if(!lstMeetingDiscountsDiscounts.IsEmpty()) {
            
            List<Chapter_Meeting_Registration__c> lstChaptMeetingRegWithDiscounts = [select id, Discount_Code_Used__c 
                                                                                     from Chapter_Meeting_Registration__c 
                                                                                     where Chapter_Meeting__c  = :metingId AND 
                                                                                     Discount_Code_Used__c != NULL AND Status__c in ('Registered','Registered and Paid')];
            GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingDiscounts','lstChaptMeetingRegWithDiscounts',lstChaptMeetingRegWithDiscounts);
            
            MAP<String,Integer> mapDiscountsUsed = new MAP<String,Integer>();
            for(Chapter_Meeting_Registration__c er :lstChaptMeetingRegWithDiscounts) {
                Integer discountsUsed = mapDiscountsUsed.get(er.Discount_Code_Used__c);
                if(discountsUsed == NULL) {
                    discountsUsed = 0;
                }
                discountsUsed++;
                mapDiscountsUsed.put(er.Discount_Code_Used__c, discountsUsed);
            }
            GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingDiscounts','mapDiscountsUsed',mapDiscountsUsed);
            
            for(Chapter_Meeting_Discount__c edisc :lstMeetingDiscountsDiscounts) {
                
                Integer discountsUsed = mapDiscountsUsed.get(edisc.Discount_Code__c);
                
                GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','discountsUsed',discountsUsed);
                GARP_Common.debugLog('GARP_BC_Events','getEventDiscounts','Max_Allowed_Usage__c',edisc.Max_Allowed_Usage__c);
                
                if(edisc.Max_Allowed_Usage__c == NULL || discountsUsed == NULL || discountsUsed < edisc.Max_Allowed_Usage__c) {
                    eventDiscount eventDiscount = new eventDiscount(edisc);
                    
                    for(Product_Discount__c pd :edisc.Product_Discounts__r) {
                        mapChapterMeetingDiscounts.put(edisc.Discount_Code__c + ':' + pd.Product__r.ProductCode + ':' + pd.Product__r.GL_Code__c, eventDiscount);
                    }
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingDiscounts','mapChapterMeetingDiscounts',mapChapterMeetingDiscounts);
        
        return mapChapterMeetingDiscounts;
    }
    
    public class verifyDiscount {
        public Boolean isValid;
        public Decimal amount;
    }
    
    public static verifyDiscount computeEventDiscount(String promoCode, PricebookEntry pbe, MAP<String,eventDiscount> mapEventDiscounts) {
        
        GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','promoCode',promoCode);
        GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','pbe',pbe);
        GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','mapEventDiscounts',mapEventDiscounts);
        
        verifyDiscount verifyDiscount = new verifyDiscount();
        verifyDiscount.isValid = False;
        if(promoCode != NULL && pbe != NULL && pbe.UnitPrice != NULL && mapEventDiscounts != NULL) {
            Decimal amount = pbe.UnitPrice;
            GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','amount In',amount);
            
            eventDiscount fndEventDisc = mapEventDiscounts.get(promoCode+':'+pbe.Product2.ProductCode + ':' + pbe.Product2.GL_Code__c);
            GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','fndEventDisc',fndEventDisc);
            
            if(fndEventDisc != NULL) {
                if(fndEventDisc.discountToFixedPrice != NULL) {
                    verifyDiscount.isValid = True;
                    verifyDiscount.amount = (amount - fndEventDisc.DiscountToFixedPrice) * -1;
                } else if(fndEventDisc.fixedAmountDiscount != NULL) {
                    verifyDiscount.isValid = True;
                    verifyDiscount.amount = (fndEventDisc.fixedAmountDiscount * -1);
                } else if(fndEventDisc.fixedPercentageDiscount != NULL) {
                    verifyDiscount.isValid = True;
                    verifyDiscount.amount = (amount * (fndEventDisc.fixedPercentageDiscount * .01)) * -1;
                }
                GARP_Common.debugLog('GARP_BC_Events','computeEventDiscount','Out verifyDiscount',verifyDiscount);
            }
        }
        
        return verifyDiscount;
    }
    
    public class retChapterMeetingRates {
        public Boolean hasRates;
        public MAP<String,eventRate> mapRates;
    }
    
    public static retChapterMeetingRates getChapterMeetingRates(String chapterMeetingId) {        
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingRates','chapterMeetingId',chapterMeetingId);
        
        retChapterMeetingRates retChapterMeetingRates = new retChapterMeetingRates();
        
        retChapterMeetingRates.mapRates = new MAP<String,eventRate>();
        
        List<Chapter_Meeting_Rate__c> lstChapterMeetingRates = [select Id, Name, Start_Date__c, End_Date__c, Member_Rate__c, Non_Member_Rate__c, 
                                                                Team_Rate__c, Chapter_Meeting__r.VAT_Product_Code__c,
                                                                Product_Member__r.ProductCode, Product_Member__r.GL_Code__c,
                                                                Product_Non_Member__r.ProductCode, Product_Non_Member__r.GL_Code__c,
                                                                Product_Team__r.ProductCode, Product_Team__r.GL_Code__c //, Event__r.VAT_Product_Code__c
                                                                FROM Chapter_Meeting_Rate__c WHERE Chapter_Meeting__c = :chapterMeetingId AND 
                                                                ((Member_Rate__c != NULL AND Member_Rate__c > 0) OR (Non_Member_Rate__c != NULL AND Non_Member_Rate__c > 0))];
        GARP_Common.debugLog('GARP_BC_Events','getChapterMeetingRates','lstChapterMeetingRates',lstChapterMeetingRates);
        
        if(!lstChapterMeetingRates.IsEmpty()) {
            retChapterMeetingRates.hasRates = True;
            Date tdy = Date.today();
            for(Chapter_Meeting_Rate__c er :lstChapterMeetingRates) {                    
                if(er.Start_Date__c<=tdy && er.End_Date__c>=tdy) {
                    eventRate eventRate = new eventRate(er);
                    retChapterMeetingRates.mapRates.put(eventRate.nonMemberProductCode + ':' + eventRate.nonMemberGLCode, eventRate);
                }
            }
        } else {
            retChapterMeetingRates.hasRates = False;
        }
        return retChapterMeetingRates;
    }
    // Other Service Calls
    
    public class memberEventInfo {
        public String eventId;
        public String eventType;
        public String eventName;
        public Date eventStartDate;
        public String eventSlug;
        public String eventURL;
        public String chapterId;
        public Boolean canManageAttendance;
        
        public String addToCalTitle;
        public String addToCalDescription;
        public String addToCalStartDateTime;
        public String addToCalEndDateTime;
        public String addToCalTimeZone;
        public String addToCalLocation;        
    }
    
    // Portal V2 Methods
    
    public static List<memberEventInfo> getMemberEventRegistrationsSummary(String contactId, Boolean isUpcoming) {
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','contactId',contactId);
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','isUpcoming',isUpcoming);
        
        List<memberEventInfo> memberRegistrations = new List<memberEventInfo>();
        
        DateTime now = DateTime.Now();
        Date tdy = Date.Today();
        
        // Events
        List<Event_Registration__c> existingEventRegistrations;
        
        if(isUpcoming) {
            existingEventRegistrations = [SELECT Id, Contact__c, Event__c, Member_Email__c, Event__r.Title__c, Event__r.Start_Date__c, Event__r.End_Date__c, Event__r.Time_Zone__r.Name,
                                          Event__r.Vanity_URL__c, Event__r.VenueName__c, Event__r.Address__c, Event__r.Custom_Location__c, Event__r.Description__c, Event__r.ON24_URL__c
                                          FROM Event_Registration__c WHERE Contact__c = :contactId AND Event__r.Start_Date__c >= :now AND Event__r.Status__c = 'Active'];    
        } else {
            existingEventRegistrations = [SELECT Id, Contact__c, Event__c, Member_Email__c, Event__r.Title__c, Event__r.Start_Date__c, Event__r.End_Date__c, Event__r.Time_Zone__r.Name,
                                          Event__r.Vanity_URL__c, Event__r.VenueName__c, Event__r.Address__c, Event__r.Custom_Location__c, Event__r.Description__c, Event__r.ON24_URL__c
                                          FROM Event_Registration__c WHERE Contact__c = :contactId AND Event__r.Start_Date__c < :now AND Event__r.Status__c = 'Active'];
        }
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','existingEventRegistrations',existingEventRegistrations);
        
        if(!existingEventRegistrations.IsEmpty()) {
            for(Event_Registration__c er :existingEventRegistrations) {
                memberEventInfo memberRegistration = new memberEventInfo();
                memberRegistration.eventId = er.Event__c;
                memberRegistration.eventType = 'Event';
                memberRegistration.eventName = er.Event__r.Title__c;
                memberRegistration.eventStartDate = Date.NewInstance(er.Event__r.Start_Date__c.year(), er.Event__r.Start_Date__c.month(), er.Event__r.Start_Date__c.day());
                memberRegistration.eventURL = 'https://www.garp.org/event/' + er.Event__r.Vanity_URL__c;
                
				memberRegistration.addToCalTitle = er.Event__r.Title__c;

                if(er.Event__r.Description__c != NULL) {
                    memberRegistration.addToCalDescription = er.Event__r.Description__c;
                    if(er.Event__r.ON24_URL__c != NULL) {
                        memberRegistration.addToCalDescription += '<br/>' + er.Event__r.ON24_URL__c;
                    }
                } else {
                    memberRegistration.addToCalDescription = '';
                    if(er.Event__r.ON24_URL__c != NULL) {
                        memberRegistration.addToCalDescription = er.Event__r.ON24_URL__c;
                    }
                }
                memberRegistration.addToCalStartDateTime = er.Event__r.Start_Date__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalEndDateTime = er.Event__r.End_Date__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalTimeZone = er.Event__r.Time_Zone__r.Name;
                
                memberRegistration.addToCalLocation = '';
                if(er.Event__r.Custom_Location__c != NULL) {
                    memberRegistration.addToCalLocation = er.Event__r.Custom_Location__c;
                } else if(er.Event__r.VenueName__c != NULL) {
                    memberRegistration.addToCalLocation = er.Event__r.VenueName__c;
                    if(er.Event__r.Address__c != NULL) {
                        memberRegistration.addToCalLocation += ', ' + er.Event__r.Address__c;
                    }
                } else if(er.Event__r.Address__c != NULL) {
                    memberRegistration.addToCalLocation = er.Event__r.Address__c;
                }
                
                memberRegistrations.add(memberRegistration);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','memberRegistrations',memberRegistrations);
        
        // Webcasts
        List<Webcast_Registration__c> existingWebcastRegistrations;
        if(isUpcoming) {
           existingWebcastRegistrations = [select Id, Contact__c, Webcast__c, Email__c, Webcast__r.Title__c, Webcast__r.Start_Date__c, Webcast__r.End_Date__c, Webcast__r.Vanity_URL__c, Webcast__r.On_Demand_URL__c,
                                           Webcast__r.Time_Zone__r.Name, Webcast__r.Short_Description__c
                                           from Webcast_Registration__c WHERE Contact__c = :contactId AND Webcast__r.Start_Date__c >= :now AND Webcast__r.Status__c = 'Active'];
        } else {            
           existingWebcastRegistrations = [select Id, Contact__c, Webcast__c, Email__c, Webcast__r.Title__c, Webcast__r.Start_Date__c, Webcast__r.End_Date__c, Webcast__r.Vanity_URL__c, Webcast__r.On_Demand_URL__c,
                                           Webcast__r.Time_Zone__r.Name, Webcast__r.Short_Description__c
                                           from Webcast_Registration__c WHERE Contact__c = :contactId AND Webcast__r.Start_Date__c < :now AND Webcast__r.Status__c = 'Active'];
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','existingWebcastRegistrations',existingWebcastRegistrations);
        
        if(!existingWebcastRegistrations.IsEmpty()) {
            for(Webcast_Registration__c wc :existingWebcastRegistrations) {
                memberEventInfo memberRegistration = new memberEventInfo();
                memberRegistration.eventId = wc.Webcast__c;
                memberRegistration.eventType = 'Webcast';
                memberRegistration.eventName = wc.Webcast__r.Title__c;
                memberRegistration.eventStartDate = Date.NewInstance(wc.Webcast__r.Start_Date__c.year(), wc.Webcast__r.Start_Date__c.month(), wc.Webcast__r.Start_Date__c.day());
                memberRegistration.eventURL = 'https://www.garp.org/webcast/' + wc.Webcast__r.Vanity_URL__c;
                
                memberRegistration.addToCalStartDateTime = wc.Webcast__r.Start_Date__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalEndDateTime = wc.Webcast__r.End_Date__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalTimeZone = wc.Webcast__r.Time_Zone__r.Name;
                memberRegistration.addToCalDescription = '';
                if(wc.Webcast__r.Short_Description__c != NULL) {
                    memberRegistration.addToCalDescription = wc.Webcast__r.Short_Description__c + '<br/><p>' + wc.Webcast__r.On_Demand_URL__c + '</p>';
                } else {
                    memberRegistration.addToCalDescription = wc.Webcast__r.Title__c + '<br/><p>' + wc.Webcast__r.On_Demand_URL__c + '</p>';                    
                }
                memberRegistrations.add(memberRegistration);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','memberRegistrations',memberRegistrations);
        
        // Chapter Meetings
        List<Chapter_Meeting_Registration__c> existingChapterRegistrations;
        if(isUpcoming) {
            existingChapterRegistrations = [select Id, Contact__c, Chapter_Meeting__c, Chapter_Meeting__r.Chapter__c, Chapter_Meeting__r.Chapter_Meeting_Name__c, Chapter_Meeting__r.Start_Date__c, Chapter_Meeting__r.Vanity_URL__c, Chapter_Meeting__r.Delivery_Method__c,
                                            Chapter_Meeting__r.Start__c, Chapter_Meeting__r.End__c, Chapter_Meeting__r.Time_Zone__r.Name, Chapter_Meeting__r.ON24_URL__c, Chapter_Meeting__r.Synopsis__c, Chapter_Meeting__r.Chapter__r.Name, Chapter_Meeting__r.Content__r.Location__c
                                            from Chapter_Meeting_Registration__c WHERE Contact__c = :contactId AND Chapter_Meeting__r.Start_Date__c >= :tdy AND Chapter_Meeting__r.Status__c = 'Active'];
        } else {
            existingChapterRegistrations = [select Id, Contact__c, Chapter_Meeting__c, Chapter_Meeting__r.Chapter__c, Chapter_Meeting__r.Chapter_Meeting_Name__c, Chapter_Meeting__r.Start_Date__c, Chapter_Meeting__r.Vanity_URL__c, Chapter_Meeting__r.Delivery_Method__c,
                                            Chapter_Meeting__r.Start__c, Chapter_Meeting__r.End__c, Chapter_Meeting__r.Time_Zone__r.Name, Chapter_Meeting__r.ON24_URL__c, Chapter_Meeting__r.Synopsis__c, Chapter_Meeting__r.Chapter__r.Name, Chapter_Meeting__r.Content__r.Location__c
                                            from Chapter_Meeting_Registration__c WHERE Contact__c = :contactId AND Chapter_Meeting__r.Start_Date__c < :tdy AND Chapter_Meeting__r.Status__c = 'Active'];
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','existingChapterRegistrations',existingChapterRegistrations);
        
        if(!existingChapterRegistrations.IsEmpty()) {
            for(Chapter_Meeting_Registration__c cm :existingChapterRegistrations) {
                memberEventInfo memberRegistration = new memberEventInfo();
                memberRegistration.eventId = cm.Chapter_Meeting__c;
                memberRegistration.chapterId = cm.Chapter_Meeting__r.Chapter__c;
                memberRegistration.eventType = 'Chapter Meeting';
                memberRegistration.eventName = cm.Chapter_Meeting__r.Chapter_Meeting_Name__c;
                memberRegistration.eventStartDate = cm.Chapter_Meeting__r.Start_Date__c;
                memberRegistration.eventURL = 'https://www.garp.org/membership/chapters/meetings/' + cm.Chapter_Meeting__r.Vanity_URL__c;
             
				memberRegistration.addToCalTitle = cm.Chapter_Meeting__r.Chapter_Meeting_Name__c + '-' + cm.Chapter_Meeting__r.Chapter__r.Name;

                if(cm.Chapter_Meeting__r.Synopsis__c != NULL) {
                    memberRegistration.addToCalDescription = cm.Chapter_Meeting__r.Synopsis__c;
                    if(cm.Chapter_Meeting__r.ON24_URL__c != NULL) {
                        memberRegistration.addToCalDescription += '<br/>' + cm.Chapter_Meeting__r.ON24_URL__c;
                    }
                } else {
                    memberRegistration.addToCalDescription = '';
                    if(cm.Chapter_Meeting__r.ON24_URL__c != NULL) {
                        memberRegistration.addToCalDescription = cm.Chapter_Meeting__r.ON24_URL__c;
                    }
                }
                memberRegistration.addToCalStartDateTime = cm.Chapter_Meeting__r.Start__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalEndDateTime = cm.Chapter_Meeting__r.End__c.format('yyyy-MM-dd h:mm a');
                memberRegistration.addToCalTimeZone = cm.Chapter_Meeting__r.Time_Zone__r.Name;
                
                memberRegistration.addToCalLocation = '';
                if((cm.Chapter_Meeting__r.Delivery_Method__c == 'In-Person Only' || cm.Chapter_Meeting__r.Delivery_Method__c == 'Hybrid' || cm.Chapter_Meeting__r.Delivery_Method__c == 'Hybrid Non-Concurrent') &&
                   cm.Chapter_Meeting__r.Content__r.Location__c != NULL) {
                    memberRegistration.addToCalLocation = GARP_Common.newLineToBR(cm.Chapter_Meeting__r.Content__r.Location__c);
                }              
                
                memberRegistrations.add(memberRegistration);
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','memberRegistrations',memberRegistrations);
        
        return memberRegistrations;
    }
    
    public static List<memberEventInfo> getMemberUpcomingChapterMeetings(Contact contact, List<Chapter_Meeting__c> lstChapterMeeting, Set<String> alreadyRegisteredEventIds) {
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','contact', contact);
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','lstChapterMeeting',lstChapterMeeting);
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','alreadyRegisteredEventIds',alreadyRegisteredEventIds);
        
        List<memberEventInfo> upcomingChapterMeetings = new List<memberEventInfo>();
        
        DateTime now = DateTime.Now();
        Date tdy = Date.Today();
        
        if(!lstChapterMeeting.IsEmpty()) {
            for(Chapter_Meeting__c cm :lstChapterMeeting) {
                
                if(!alreadyRegisteredEventIds.Contains(cm.Id) && (cm.Chapter__r.Name == contact.KPI_Primary_Chapter_Name__c || 
                                                                  cm.Chapter__r.Name == contact.KPI_Secondary_Chapter_Name__c)) {
                    memberEventInfo memberEvent = new memberEventInfo();
                    memberEvent.eventId = cm.Id;
                    memberEvent.chapterId = cm.Chapter__c;
                    memberEvent.eventType = 'Chapter Meeting';
                    memberEvent.eventName = cm.Chapter_Meeting_Name__c;
                    memberEvent.eventStartDate = cm.Start_Date__c;
                    memberEvent.eventURL = 'https://www.garp.org/membership/chapters/meetings/' + cm.Vanity_URL__c;
                    upcomingChapterMeetings.add(memberEvent);
                }
            }
        }
        
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','upcomingChapterMeetings',upcomingChapterMeetings);
        
        return upcomingChapterMeetings;
    }
    
    public static List<memberEventInfo> getMemberUpcomingOtherEvents(Contact contact, List<Chapter_Meeting__c> lstChapterMeeting, Set<String> alreadyRegisteredEventIds, Set<String> upcomingChapterMeetingEventIds, MAP<String,Contract> mapContracts) {
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','contact', contact);
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','lstChapterMeeting', lstChapterMeeting);
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','alreadyRegisteredEventIds',alreadyRegisteredEventIds);
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','upcomingChapterMeetingEventIds',upcomingChapterMeetingEventIds);
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','mapContracts',mapContracts);
        
        List<memberEventInfo> upcomingOtherEvents = new List<memberEventInfo>();
        
        DateTime now = DateTime.Now();
        Date tdy = Date.Today();
        
        // Chapter Meetings
        if(!lstChapterMeeting.IsEmpty()) {
            for(Chapter_Meeting__c cm :lstChapterMeeting) {
                if(!alreadyRegisteredEventIds.Contains(cm.Id) && !upcomingChapterMeetingEventIds.Contains(cm.Id)) {
                    memberEventInfo memberEvent = new memberEventInfo();
                    memberEvent.eventId = cm.Id;
                    memberEvent.chapterId = cm.Chapter__c;
                    memberEvent.eventType = 'Chapter Meeting';
                    memberEvent.eventName = cm.Chapter_Meeting_Name__c;
                    memberEvent.eventStartDate = cm.Start_Date__c;
                    memberEvent.eventURL = 'https://www.garp.org/membership/chapters/meetings/' + cm.Vanity_URL__c;
                    upcomingOtherEvents.add(memberEvent);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','upcomingOtherEvents',upcomingOtherEvents);
        
        // Events
        List < Event__c > lstEvents = [
            SELECT Id, Name, Start_Date__c, Title__c, Vanity_URL__c
            FROM Event__c 
            WHERE Status__c = 'Active' AND Invite_Only__c = False AND Do_Not_Show_in_Listing__c = FALSE AND Start_Date__c >= :tdy
        ];    
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','lstEvents',lstEvents);
        
        if(!lstEvents.IsEmpty()) {
            for(Event__c ev :lstEvents) {
                
                if(!alreadyRegisteredEventIds.Contains(ev.Id) && !upcomingChapterMeetingEventIds.Contains(ev.Id)) {
                    memberEventInfo memberEvent = new memberEventInfo();
                    memberEvent.eventId = ev.Id;
                    memberEvent.eventType = 'Event';
                    memberEvent.eventName = ev.Title__c;
                    memberEvent.eventStartDate = Date.ValueOf(ev.Start_Date__c);
                    memberEvent.eventURL = 'https://www.garp.org/event/' + ev.Vanity_URL__c;
                    upcomingOtherEvents.add(memberEvent);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','upcomingOtherEvents',upcomingOtherEvents);
        
        // Webcasts
        List <Webcast__c> lstWebcasts = [SELECT Id, Name, Start_Date__c , Title__c, Vanity_URL__c, Members_Only__c, SCR_Holder__c, RAI_Holder__c, FRM_Certified__c, ERP_Certified__c
                                         FROM Webcast__c 
                                         WHERE Status__c = 'Active' AND Start_Date__c >= :tdy];
        GARP_Common.debugLog('GARP_BC_Events','getMemberUpcomingOtherEvents','lstWebcasts',lstWebcasts);
        
        if(!lstWebcasts.IsEmpty()) {
            
            Contract frmContract = mapContracts.get('FRM_Program');
            Contract scrContract = mapContracts.get('SCR_Program');
			Contract raiContract = mapContracts.get('Risk_AI_Program');
            Contract membershipContract = mapContracts.get('Membership');
            
            for(Webcast__c wc :lstWebcasts) {

				Boolean showWebcast = True;                
                // Allow non-members, but they must buy membership
                //if(wc.Members_Only__c && (membershipContract == NULL || membershipContract.Membership_Type__c != 'Individual' || (membershipContract.Status != 'Activated ( Auto-Renew )' && membershipContract.Status != 'Activated'))) {
                //    showWebcast = False;
                //}
                Boolean hasCert = False;
                if(wc.SCR_Holder__c && scrContract != NULL && (scrContract.Status != 'Activated ( Auto-Renew )' || scrContract.Status != 'Activated')) {
                    hasCert = True;
                }
                if(wc.RAI_Holder__c && raiContract != NULL && (raiContract.Status != 'Activated ( Auto-Renew )' || raiContract.Status != 'Activated')) {
                    hasCert = True;
                }
                if(wc.FRM_Certified__c && frmContract != NULL && (frmContract.Status != 'Activated ( Auto-Renew )' || frmContract.Status != 'Activated')) {
                    hasCert = True;
                }
                if((wc.SCR_Holder__c || wc.RAI_Holder__c || wc.FRM_Certified__c) && !hasCert) {
                    showWebcast = False;
                }
                if(!alreadyRegisteredEventIds.Contains(wc.Id) && !upcomingChapterMeetingEventIds.Contains(wc.Id) && showWebcast) {
                    memberEventInfo memberEvent = new memberEventInfo();
                    memberEvent.eventId = wc.Id;
                    memberEvent.eventType = 'Webcast';
                    memberEvent.eventName = wc.Title__c;
                    memberEvent.eventStartDate = Date.ValueOf(wc.Start_Date__c);
                    memberEvent.eventURL = 'https://www.garp.org/webcast/' + wc.Vanity_URL__c;
                    upcomingOtherEvents.add(memberEvent);
                }
            }
        }
        GARP_Common.debugLog('GARP_BC_Events','getMemberEventRegistrationsSummary','upcomingOtherEvents',upcomingOtherEvents);
        
        return upcomingOtherEvents;
    }
    
    // Portal V1 Methods
    /*
    public static List<eventInfo> getMemberEventRegistrations(String contactId, Boolean isUpcoming) {

        List<memberEventInfo> memberRegistrations = getMemberEventRegistrationsSummary(contactId, isUpcoming);
        
        Set<String> eventRegIds = new Set<String>();
        if(!memberRegistrations.IsEmpty()) {
            for(memberEventInfo mri :memberRegistrations) {
                eventRegIds.add(mri.eventId);
            }
        }
        
        List<eventInfo> allEvents = getEventListing(isUpcoming);
        if(!allEvents.isEmpty()) {
            for(eventInfo ei :allEvents) {
                if(eventRegIds.contains(ei.eventId)) {
                    allEvents.add(ei);
                }
            }
        }
        
        return allEvents;
    }
    
    public static List<eventInfo> getEventListing(Boolean isUpcoming) {
        List<eventInfo> eventListing = new List<eventInfo>(); 
        
        Date startDate;
        Date endDate;
        if(isUpcoming) {
            startDate = Date.today().addDays(1);
            endDate = Date.newInstance(2099, 1, 1);
        } else {
            startDate = Date.newInstance(1970, 1, 1);
            endDate = Date.today();            
        }
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','startDate',startDate);
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','endDate',endDate);
        
        // Chapter Meetings
        List<Chapter_Meeting__c> lstChapterMeeting = [SELECT Id, Chapter_Meeting_Name__c, Last_Day_of_Registration__c, 
                                                      Start__c, End__c, Is_Sponsored__c, Sponsor_Name__c, Chapter__r.Name, Synopsis__c,
                                                      Time_Zone__r.Name, Content__r.Form__r.Form_Name__c, ON24_URL__c, ON24_Event_Id__c,ON24_API_Key__c,          
                                                      Virtual_Start_DateTime__c, Virtual_End_DateTime__c, Virtual_Meeting_URL__c, Virtual_Meeting_Instructions__c,
                                                      In_Person_Title__c, Virtual_Title__c, Delivery_Method__c, Content__r.Location__c,
                                                      Chapter_Meeting_Location__r.Name, Chapter_Meeting_Location__r.Building_Name__c, Chapter_Meeting_Location__r.Address_Street_1__c, Chapter_Meeting_Location__r.Address_Street_2__c,
                                                      Chapter_Meeting_Location__r.Address_City__c, Chapter_Meeting_Location__r.Address_Postal_Code__c,Chapter_Meeting_Location__r.Address_Country__c                                                      
                                                      FROM Chapter_Meeting__c 
                                                      WHERE Status__c = 'Active' AND Start__c >= :startDate AND End__c <= :endDate
                                                     ];    
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','lstChapterMeeting',lstChapterMeeting);
        if(!lstChapterMeeting.IsEmpty()) {
            for(Chapter_Meeting__c cm :lstChapterMeeting) {
                eventInfo eventInfo = new eventInfo(cm);
                GARP_Common.debugLog('GARP_BC_Events','getEventListing','add eventInfo',eventInfo);
                eventListing.add(eventInfo);
            }
        }
        
        // Events
        List < Event__c > lstEvents = [
            SELECT Id, Delivery_Method__c, ON24_Event_Id__c, ON24_URL__c, VenueName__c, Custom_Location__c, Invite_Only__c, 
            Start_Date__c, End_Date__c, Content__r.Form__r.Form_Name__c, Title__c, Description__c,  
            Is_Sponsored_Event__c, Can_Pay_By_wire__c, Last_Date_for_Wire_Check_Registration__c,  /// TO DO!!
            Last_Date_For_Registration__c, RSVP_Copy__c, Max_Capacity_Met__c, Maximum_number_of_Event_Registrations__c, Total_Event_Registration__c,
            RSVP_Waitlist_Copy__c, Time_Zone__r.Name, RSVP_Activity_Ask_Diet_Restrictions__c, RSVP_Activity_Details__c, RSVP_Activity_Name__c, 
            (SELECT Id, Name, Start_Date__c, End_Date__c, Member_Rate__c, Non_Member_Rate__c from Event_Rates__r WHERE (Start_Date__c <= TODAY and End_Date__c >= TODAY))
            FROM Event__c 
            WHERE Status__c = 'Active' AND Start_Date__c >= :startDate AND End_Date__c <= :endDate
        ];    
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','lstEvents',lstEvents);
        if(!lstEvents.IsEmpty()) {
            for(Event__c ev :lstEvents) {
                eventInfo eventInfo = new eventInfo(ev);
                GARP_Common.debugLog('GARP_BC_Events','getEventListing','add eventInfo',eventInfo);
                eventListing.add(eventInfo);
            }
        }
        
        // Webcasts
        List <Webcast__c> lstWebcasts = [SELECT Name, Id, Description__c, Short_Description__c, Duration__c, Start_Time__c, End_Time__c, 
                                         Start_Date__c, End_Date__c, Image__c, Status__c, Title__c, Is_Sponsored__c,
                                         EventId__c, On_Demand_URL__c, Content__r.Form__r.Form_Name__c, Time_Zone__r.Name, 
                                         Time_Zone__r.Abbreviation__c 
                                         FROM Webcast__c 
                                         WHERE Status__c = 'Active' AND Start_Date__c >= :startDate AND End_Date__c <= :endDate];
        GARP_Common.debugLog('GARP_BC_Events','getEventListing','lstWebcasts',lstWebcasts);
        if(!lstEvents.IsEmpty()) {
            for(Webcast__c wc :lstWebcasts) {
                eventInfo eventInfo = new eventInfo(wc);
                GARP_Common.debugLog('GARP_BC_Events','getEventListing','add eventInfo',eventInfo);
                eventListing.add(eventInfo);
            }
        }
        
        eventListing.sort();
        
        return eventListing;
    }
    */  
}