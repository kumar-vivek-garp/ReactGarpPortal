public class GBI_BC_Pillar3 {

    public static List<Pillar_3_Notification__c> getPillar3Notifications() {
        List<Pillar_3_Notification__c> notifList = [SELECT Name, Title__c, Type__c,Type_Color__c, Notification_Date__c FROM Pillar_3_Notification__c WHERE Active__c = True order by Notification_Date__c desc, Priority__c desc];
        return notifList;
    }


    public static GBI_MS_Pillar3.pillar3Filters getPillar3Filters () {
        GBI_MS_Pillar3.pillar3Filters filters = new GBI_MS_Pillar3.pillar3Filters();
        filters.lstCurrencies = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Pillar_3_Institution__c').getDescribe().fields.getMap();
        List<Schema.PicklistEntry> picklistEntries = fieldMap.get('Currency__c').getDescribe().getPicklistValues();
        for( Schema.PicklistEntry ple : picklistEntries)
        {
            filters.lstCurrencies.add(ple.getLabel());
        }
        filters.lstCurrencies.sort();
        filters.lstInstitutions = [SELECT Name, Country__c, Country_Code__c, Region__c, Alias__c, Institution_Type__c, Filter_Name__c FROM Pillar_3_Institution__c where Active__c = True ORDER BY Country__c];

        MAP<String, GBI_MS_Pillar3.pillar3Country> mapCountries = new MAP<String, GBI_MS_Pillar3.pillar3Country>();
        Set<String> institutionTypes = new Set<String>();
        for(Pillar_3_Institution__c p3i :filters.lstInstitutions) {
            if(p3i.Country__c != NULL) {
                GBI_MS_Pillar3.pillar3Country ctry = new GBI_MS_Pillar3.pillar3Country();
                ctry.country = p3i.Country__c;
                ctry.region = p3i.Region__c;
                mapCountries.put(p3i.Country__c, ctry);
            }
            if(p3i.Institution_Type__c != NULL) {
                institutionTypes.add(p3i.Institution_Type__c);
            }
        }
        filters.countryList = new List<GBI_MS_Pillar3.pillar3Country>();
        filters.institutionTypeList = new List<String>();
        if(!mapCountries.IsEmpty()) {
           filters.countryList.addAll(mapCountries.Values());
           //filters.countryList.sort();
        }
        if(!institutionTypes.IsEmpty()) {
            filters.institutionTypeList.addAll(institutionTypes);
            filters.institutionTypeList.sort();
        }

        filters.dates = Pillar_3_Dates__c.getValues('Default Dates');

        return filters;
    }

    
    public static Boolean isBlocked(Pillar_3_Report__c item, MAP<String, String> mapFolderParents, SET<String> setFolderBlocks) {
        
        System.Debug('isBlocked:' + item);
        
        if(setFolderBlocks.contains(item.Id)) {
            //System.Debug('YES 1 isBlocked:' + item);
            return TRUE;
        }
        
        String folderId;
        if(!item.Has_Submenu__c) {
            folderId = item.Parent_Menu__c;
        } else {
            folderId = item.Id;
        }
        
        //System.Debug('Start folder:' + folderId);
        
        Boolean isBlocked = FALSE;
        Integer cnt = 0;
        While(!isBlocked && folderId != NULL) {
            if(setFolderBlocks.contains(folderId)) {
                isBlocked = TRUE;
            } else {
                folderId = mapFolderParents.get(folderId);
            }
            //System.Debug('While isBlocked:' + isBlocked);
            //System.Debug('While folderId:' + folderId);
            
            if(cnt > 100) {
                System.Debug('Reached Protection!!');
                break;
            } else {
                cnt++;
            }
        }
        
        System.Debug('Final isBlocked:' + isBlocked);
        return isBlocked;
    }
    
    public static List<Pillar_3_Report__c> getPillar3Menu() {
        List<Pillar_3_Report__c> reportList = [SELECT Id, Name, Viz_URL__c, Parent_Menu__c, Has_Submenu__c, Is_Top_Menu__c, Hide_Pillar_3_Lite__c, Order__c, Tab_Color__c, Navigation_Tab__c FROM Pillar_3_Report__c order by Order__c];
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','reportList',reportList);
        
        String userId = UserInfo.getUserId();
        List<User> lstUser = [SELECT Id, ContactId, FullPhotoUrl FROM User WHERE Id = :userId];
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','lstUser',lstUser);
        User u;
        if(!lstUser.IsEmpty()) {
            u = lstUser[0];
        } else {
            return NULL;
        }
        
        // For Testing
        //List<User> lstUser = new List<User>();
        //User u = new User(ContactId = '0036u00000ixvEV');
        //lstUser.add(u);
        //GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','TEST lstUser',lstUser);
        
        Boolean isPillar3LiteUser = FALSE;
        List<Contact> lstContact = [select id, GBI_Participant__c, GBI_Analytics_Participant__c from Contact where id = :u.ContactId];
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','lstContact',lstContact);
        if(!lstContact.IsEmpty()) {
            if(!lstContact[0].GBI_Participant__c) {
                isPillar3LiteUser = TRUE;
            }
        }
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','isPillar3LiteUser',isPillar3LiteUser);
        
        if(!isPillar3LiteUser) {
            return reportList;
        }
        
		MAP<String, String> mapFolderParents = new MAP<String, String>(); // Each Folder and who the parent it
        SET<String> setFolderBlocks = new SET<String>(); // Blocking folders
        for(Pillar_3_Report__c p3r :reportList) {
        
            //System.Debug('Loop reportList:' + p3r);
            
            if(p3r.Hide_Pillar_3_Lite__c) {
                setFolderBlocks.add(p3r.Id);
                //System.Debug('set block:' + p3r.Id);
            }
            
            if(p3r.Parent_Menu__c != NULL) {
                mapFolderParents.put(p3r.Id, p3r.Parent_Menu__c);
                //System.Debug('set parent:' + p3r.Id + '>' + p3r.Parent_Menu__c);
            }
        }
        
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','setFolderBlocks',setFolderBlocks);
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','mapFolderParents',mapFolderParents);
        
        List<Pillar_3_Report__c> finalReportList = new List<Pillar_3_Report__c>();
        
        for(Pillar_3_Report__c p3r :reportList) {
            if(!isBlocked(p3r, mapFolderParents, setFolderBlocks)) {
                finalReportList.add(p3r);
                //System.Debug('add finalReportList:' + p3r);
            }
        }
        
        GBI_Common.debugLog('GBI_BC_Studies','getPillar3Menu','finalReportList',finalReportList);
        return finalReportList;
    }
	/*
    public static Boolean submitPillar3Attestation() {
        String userId = UserInfo.getUserId();

        String contactId;
        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {
            contactId = lstUser[0].ContactId;
            List<Contact> lstContact = [SELECT Id, Name, GBI_Pillar_3_Attestation__c  FROM Contact WHERE Id = :contactId];
            if( lstContact != null && lstContact.size() > 0 ) {
                lstContact[0].GBI_Pillar_3_Attestation__c = true;
                update lstContact[0];
                return true;
            }
        }
        return false;

    }
	*/

    // public static List<PillarReport> getPillar3Menu() {
    //     List<Pillar_3_Report__c> reportList = new List<Pillar_3_Report__c>();
    //     reportList = [SELECT Id,Name, Viz_URL__c, Parent_Menu__c, Has_Submenu__c, Is_Top_Menu__c, Order__c, Tab_Color__c FROM Pillar_3_Report__c WHERE Is_Top_Menu__c=true order by Order__c DESC];

    //     List<PillarReport> pillarWrapperList = new List<PillarReport>();
    //     List<MainMenu> menuWrapperList = new List<MainMenu>();
    //     List<SubMenu> subMenuWrapperList = new List<SubMenu>();

    //     if(reportList.size()>0){
    //         for(Pillar_3_Report__c pillar :  reportList){
    //             PillarReport reportObj = new PillarReport();
    //             reportObj.Id = pillar.Id;
    //             reportObj.Name = pillar.Name;
    //             pillarWrapperList.add(reportObj);
    //         }

    //         List<Pillar_3_Report__c> mainList = new List<Pillar_3_Report__c>();
    //         mainList = [SELECT Id,Name,Parent_Menu__c FROM Pillar_3_Report__c WHERE Parent_Menu__c IN: reportList order by Order__c ASC];
    //         if(mainList.size()>0){
    //             for(Pillar_3_Report__c pillar :  mainList){
    //                 for(PillarReport pillarReport : pillarWrapperList){
    //                     if(pillarReport.Id ==pillar.Parent_Menu__c){
    //                         MainMenu menuObj = new MainMenu();
    //                         menuObj.Id = pillar.Id;
    //                         menuObj.Name = pillar.Name;
    //                         menuWrapperList.add(menuObj);
    //                         pillarReport.mainMenuList = menuWrapperList;
    //                     }
    //                 }
    //             }
    //         }

    //         List<Pillar_3_Report__c> subMenuList = new List<Pillar_3_Report__c>();
    //         subMenuList = [SELECT Id,Name,Parent_Menu__c FROM Pillar_3_Report__c WHERE Parent_Menu__c IN: mainList AND Parent_Menu__c!=null order by Order__c ASC];
    //         if(subMenuList.size()>0){
    //             for(Pillar_3_Report__c pillar :  subMenuList){
    //                 for(MainMenu subMenuObj : menuWrapperList){
    //                     system.debug(subMenuObj.Id+' :menu id: '+pillar.Parent_Menu__c);
    //                     if(subMenuObj.Id ==pillar.Parent_Menu__c){
    //                         SubMenu menuObj = new SubMenu();
    //                         menuObj.Id = pillar.Id;
    //                         menuObj.Name = pillar.Name;
    //                         subMenuWrapperList.add(menuObj);
    //                         subMenuObj.subMenuList = subMenuWrapperList;
    //                     }
    //                 }
    //             }
    //         }
    //     }
    //     return pillarWrapperList;
    // }
}