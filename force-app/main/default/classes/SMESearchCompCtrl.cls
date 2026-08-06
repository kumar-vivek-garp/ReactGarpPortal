public without sharing class SMESearchCompCtrl {
    /* All SME Search Fields
        'Credit_Risk__c', 'Credit_Risk_Sys__c', 'Credit_Risk_GARP__c', 'Culture_Governance__c', 'Culture_Governance_Sys__c', 'Culture_Governance_GARP__c', 
        'Energy__c', 'Energy_Sys__c', 'Energy_GARP__c', 'Expert_Participation__c', 'Expert_Participation_Sys__c', 'Expert_Participation_GARP__c', 
        'Market_Risk__c', 'Market_Risk_Sys__c', 'Market_Risk_GARP__c', 'Operational__c', 'Operational_Sys__c', 'Operational_GARP__c', 
        'Publishing_Experience__c', 'Publishing_Experience_Sys__c', 'Publishing_Experience_GARP__c', 
        'Teaching_Experience__c', 'Teaching_Experience_Sys__c', 'Teaching_Experience_GARP__c', 'Technology__c', 'Technology_Sys__c', 'Technology_GARP__c'        
    */
    
    private static List<String> garpCateFields = new List<String> {'Credit_Risk_GARP__c', 'Culture_Governance_GARP__c', 'Energy_GARP__c', 'Expert_Participation_GARP__c', 'Market_Risk_GARP__c', 'Operational_GARP__c', 'Publishing_Experience_GARP__c', 'Teaching_Experience_GARP__c', 'Technology_GARP__c'};
    private static List<String> systemCateFields = new List<String> {'Credit_Risk_Sys__c', 'Culture_Governance_Sys__c', 'Energy_Sys__c', 'Expert_Participation_Sys__c', 'Market_Risk_Sys__c', 'Operational_Sys__c', 'Publishing_Experience_Sys__c', 'Teaching_Experience_Sys__c', 'Technology_Sys__c'};
    private static List<String> selfCateFields = new List<String> {'Credit_Risk__c', 'Culture_Governance__c', 'Energy__c', 'Expert_Participation__c', 'Market_Risk__c', 'Operational__c', 'Publishing_Experience__c', 'Teaching_Experience__c', 'Technology__c'};
    
    private static void setupFilterAndCateFlds(List<String> identifyType, List<String> filterFlds, List<String> categoryFlds) {
        for(String idType : identifyType) {
            switch on idType {
                when 'garp' {
                    filterFlds.addAll(garpCateFields);
                }
                when 'system' {
                    filterFlds.addAll(systemCateFields);
                }
                when 'self' {
                    filterFlds.addAll(selfCateFields);
                }
            }
        }
    }
        
    @AuraEnabled
    public static List<SME_Registration__c> searchSMEProfile(String searchWord, String searchType, String country, List<String> identifyType) {
        System.debug(String.format('SMESearchCompCtrl.searchSMEProfile({0}, {1}, {2}, [{3}])', new String[] {searchWord, searchType, country, String.join(identifyType, ', ')}));
        
        List<SME_Registration__c> smeProfiles;
        
        if(searchType == 'category') {
            List<String> filterFlds = new List<String>();
            List<String> categoryFlds = new List<String>();
            setupFilterAndCateFlds(identifyType, filterFlds, categoryFlds);

            String query = 'SELECT Id, Contact__c, Contact__r.Name, Contact_Email__c, GARP_Member_ID__c, Contact__r.MailingCountry, Article_Author_Count__c, Chapter_Speaker_Count__c, Event_Speaker_Count__c, Podcast_Presenter_Count__c, Webcast_Presenter_Count__c, Credit_Risk__c, Credit_Risk_Sys__c, Credit_Risk_GARP__c, Culture_Governance__c, Culture_Governance_Sys__c, Culture_Governance_GARP__c, Energy__c, Energy_Sys__c, Energy_GARP__c, Expert_Participation__c, Expert_Participation_Sys__c, Expert_Participation_GARP__c, Market_Risk__c, Market_Risk_Sys__c, Market_Risk_GARP__c, Operational__c, Operational_Sys__c, Operational_GARP__c, Publishing_Experience__c, Publishing_Experience_Sys__c, Publishing_Experience_GARP__c, Teaching_Experience__c, Teaching_Experience_Sys__c, Teaching_Experience_GARP__c, Technology__c, Technology_Sys__c, Technology_GARP__c FROM SME_Registration__c WHERE ';
            String filterQuery = '(';
            
            if(searchWord.contains(',')) {
                String[] orWords = searchWord.split(',');
                String searchQry = String.join(orWords, '\',\'');
                
                for(String oneFld : filterFlds) {
                    filterQuery += oneFld + ' INCLUDES (\'' + searchQry + '\') OR ';
                }
                for(String oneFld : categoryFlds) {
                    filterQuery += oneFld + ' LIKE \'%' + searchQry + '%\' OR ';
                }
            }else {
                for(String oneFld : filterFlds) {
                    filterQuery += oneFld + ' INCLUDES (\'' + searchWord + '\') OR ';
                }
                for(String oneFld : categoryFlds) {
                    filterQuery += oneFld + ' LIKE \'%' + searchWord + '%\' OR ';
                }
            }
            
            filterQuery = filterQuery.removeEnd(' OR ');
            filterQuery += ') ' + getCountryQuery(country) + ' ORDER BY Contact__r.Name ASC';
            System.debug(filterQuery);
            
            query += filterQuery;
            smeProfiles = (List<SME_Registration__c>)Database.query(query);
        }else if(searchType == 'name') {
            String query = 'SELECT Id, Contact__c, Contact__r.Name, Contact_Email__c, GARP_Member_ID__c, Contact__r.MailingCountry, Article_Author_Count__c, Chapter_Speaker_Count__c, Event_Speaker_Count__c, Podcast_Presenter_Count__c, Webcast_Presenter_Count__c FROM SME_Registration__c WHERE ';
            query += 'Contact__r.Name LIKE \'%' + String.escapeSingleQuotes(searchWord) + '%\' ' + getCountryQuery(country)  + ' ORDER BY Contact__r.Name ASC';
            
            System.debug('query: ' + query);
            smeProfiles = (List<SME_Registration__c>)Database.query(query);
        }
        
        return smeProfiles;
    }
    
    private static String getCountryQuery(String country) {
        String countryQry = '';
        
        if(!('Worldwide' == country || String.isEmpty(country))) {
            String countryNames = String.join(getCountryNames(country), '\',\'');
            
            countryQry += 'AND Contact__r.MailingCountry IN (\'' + countryNames + '\')';
        }
        
        return countryQry;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<SME_Registration__c> filterSearchSME(String industry,List<String> raikAreaList, String contactName, String country, List<String> identifyTypes,Date StartDate,Date EndDate,List<String> selectedDates) {
        List<SME_Registration__c> smeProfiles;
        
        //System.debug('categoryList:' + categoryList);
        System.debug('contactName:' + contactName);
        System.debug('country:' + country);
        System.debug('identifyTypes:' + identifyTypes);
        System.debug('StartDate:' + StartDate);
        System.debug('EndDate:' + EndDate);
        
        String query = 'SELECT Id, Contact__c, Contact__r.Name, Contact_Email__c, GARP_Member_ID__c, Contact__r.MailingCountry, Article_Author_Count__c, Chapter_Speaker_Count__c, Event_Speaker_Count__c, Podcast_Presenter_Count__c, Webcast_Presenter_Count__c, Credit_Risk__c, Credit_Risk_Sys__c, Credit_Risk_GARP__c, Culture_Governance__c, Culture_Governance_Sys__c, Culture_Governance_GARP__c, Energy__c, Energy_Sys__c, Energy_GARP__c, Expert_Participation__c, Expert_Participation_Sys__c, Expert_Participation_GARP__c, Market_Risk__c, Market_Risk_Sys__c, Market_Risk_GARP__c, Operational__c, Operational_Sys__c, Operational_GARP__c, Publishing_Experience__c, Publishing_Experience_Sys__c, Publishing_Experience_GARP__c, Teaching_Experience__c, Teaching_Experience_Sys__c, Teaching_Experience_GARP__c, Technology__c, Technology_Sys__c, Technology_GARP__c FROM SME_Registration__c WHERE ';
        String filterQry = ''; 
        if(raikAreaList.size()>0){
            String riskAreaString = '(\'' + String.join(raikAreaList, '\', \'') + '\')';
            
            System.debug('riskAreaString:' + riskAreaString);
            
            String riskQuery = '(';
            for(String idType :identifyTypes) {
                if(riskQuery != '(') {
                    riskQuery += ' OR ';
                }
                if(idType == 'garp') {
                    riskQuery += 'GARP_Identification_Risk_Content_Areas__c includes ' + riskAreaString;
                } else if(idType == 'system') {
                    riskQuery += 'System_Identification_Risk_Content_Areas__c includes ' + riskAreaString;
                } else if(idType == 'self') {
                    riskQuery += 'Self_Identification_Risk_Content_Areas__c includes ' + riskAreaString;
                }
            }
            riskQuery += ')';
            System.debug('riskQuery:' + riskQuery);
            
            if(riskQuery != '') {
                filterQry += riskQuery +' AND ';
            }
        }
        if(String.isEmpty(contactName)) {
            filterQry = filterQry.removeEnd(' AND ');
        }else {
            filterQry += ' Contact__r.Name LIKE \'%' + String.escapeSingleQuotes(contactName) + '%\'';
        }
        
        filterQry += ' ' + getCountryQuery(country);
        if(StartDate != null && EndDate != null && selectedDates.size() > 0){
            String queryDate = ' AND (';
            List<String> conditions = new List<String>(); 
            for (String dateField : selectedDates) {
                conditions.add('(' + dateField + ' >=: StartDate AND ' + dateField + ' <=: EndDate)');
            } 
            queryDate += String.join(conditions, ' OR ');
            queryDate += ')'; 
            filterQry += queryDate;
        }
       
        if(industry != null && industry != ''){
            filterQry += ' AND Contact__r.Area_of_Concentration__c =:industry';
        }
        
        System.debug('filterSearchSME query: ' + filterQry);
        
        smeProfiles = (List<SME_Registration__c>)Database.query(query + filterQry + ' limit 999');
        return smeProfiles;
    }
    
    private static List<String> getSearchFieldsWithinIdentify(String fieldName, List<String> identifyTypes) {
        List<String> results = new List<String>();
        
        List<String> fldSet = fieldNameToAPIMap.get(fieldName);
        for(String oneIdentify: identifyTypes) {
            switch on oneIdentify {
                when 'garp' {
                    for(String oneFld : fldSet) {
                        if(oneFld.endsWith('_GARP__c')) {
                            results.add(oneFld);
                        }
                    }
                }
                when 'system' {
                    for(String oneFld : fldSet) {
                        if(oneFld.endsWith('_Sys__c')) {
                            results.add(oneFld);
                        }
                    }
                }
                when 'self' {
                    for(String oneFld : fldSet) {
                        if(!oneFld.endsWith('_GARP__c') && !oneFld.endsWith('_Sys__c')) {
                            results.add(oneFld);
                        }
                    }
                }
            }
        }
        
        return results;
    }
    
    private static Map<String, List<String>> fieldNameToAPIMap = new Map<String, List<String>> {
        'Credit Risk' => new String[] {'Credit_Risk__c', 'Credit_Risk_Sys__c', 'Credit_Risk_GARP__c'},
        'Culture Governance' => new String[] {'Culture_Governance__c', 'Culture_Governance_Sys__c', 'Culture_Governance_GARP__c'},
        'Energy' => new String[] {'Energy__c', 'Energy_Sys__c', 'Energy_GARP__c'},
        'Expert Participation' => new String[] {'Expert_Participation__c', 'Expert_Participation_Sys__c', 'Expert_Participation_GARP__c'},
        'Market Risk' => new String[] {'Market_Risk__c', 'Market_Risk_Sys__c', 'Market_Risk_GARP__c'},
        'Operational' => new String[] {'Operational__c', 'Operational_Sys__c', 'Operational_GARP__c'},
        'Publishing Experience' => new String[] {'Publishing_Experience__c', 'Publishing_Experience_Sys__c', 'Publishing_Experience_GARP__c'},
        'Teaching Experience' => new String[] {'Teaching_Experience__c', 'Teaching_Experience_Sys__c', 'Teaching_Experience_GARP__c'},
        'Technology' => new String[] {'Technology__c', 'Technology_Sys__c', 'Technology_GARP__c'},
        'Regulation and Compliance' => new String[] {'Regulation_and_Compliance_GARP__c'},
        'Liquidity and Treasury' => new String[] {'Liquidity_and_Treasury_GARP__c'},
        'Non Financial Risk' => new String[] {'Non_Financial_Risk_GARP__c'},
        'Sales and Trading' => new String[] {'Sales_and_Trading_GARP__c'}
    };
    
    @AuraEnabled
    public static List<String> fetchPicklistValues(String fieldLabel, List<String> identifyTypes) {
        String[] fieldAPI = fieldNameToAPIMap.get(fieldLabel);
        Set<String> idTypesSet = new Set<String>(identifyTypes);
        
        String[] targetAPIs;
        if(fieldAPI.size() > 1) {
            targetAPIs = idTypesSet.contains('garp') ? new String[]{fieldAPI[2], fieldAPI[0]} : new String[]{fieldAPI[0]};
        }else {
            targetAPIs = new String[]{fieldAPI[0]};
        }
  
        Set<String> dupValChk = new Set<String>();
        List<String> pickVals = new List<String>();
        
        Schema.DescribeSObjectResult dsr = SME_Registration__c.sObjectType.getDescribe();
        
        for(String oneAPI : targetAPIs) {
            Schema.SObjectField fld = dsr.fields.getMap().get(oneAPI);
        
            if(null != fld) {
                Schema.DescribeFieldResult dfr = fld.getDescribe();
                for(Schema.PicklistEntry onePick : dfr.getPicklistValues()) {
                    if(onePick.isActive() && dupValChk.add(onePick.getValue())) pickVals.add(onePick.getValue());
                }
            }
        }
        
        
        return pickVals;
    }
    
    @AuraEnabled
    public static List<String> fetchCountries() {
        List<String> countryList = new List<String>();
        
        List<Country_Code__c> countries = [SELECT Country__c FROM Country_Code__c ORDER BY Country__c ASC];
        
        for(Country_Code__c coun : countries) {
            countryList.add(coun.Country__c);
        }
        
        return countryList;
    }
    
    @AuraEnabled
    public static SME_Registration__c fetchSMEDetail(String rowId) {
        SME_Registration__c smeProfile;
        
        if(String.isNotEmpty(rowId)) {
            String qry = 'SELECT Id, Contact__c, Contact__r.Name, Contact_Email__c, GARP_Member_ID__c, Article_Author_Count__c, Chapter_Speaker_Count__c, Event_Speaker_Count__c, Podcast_Presenter_Count__c, Webcast_Presenter_Count__c, ';
            qry += 'Last_Article_Author_Date__c, Last_Chapter_Speaker_Date__c, Last_Event_Speaker_Date__c, Last_Podcast_Presenter_Date__c, Last_Webcast_Presenter_Date__c, ';
            qry += 'Credit_Risk__c, Credit_Risk_Sys__c, Credit_Risk_GARP__c, Culture_Governance__c, Culture_Governance_Sys__c, Culture_Governance_GARP__c, ';
            qry += 'Energy__c, Energy_Sys__c, Energy_GARP__c, Expert_Participation__c, Expert_Participation_Sys__c, Expert_Participation_GARP__c, ';
            qry += 'Market_Risk__c, Market_Risk_Sys__c, Market_Risk_GARP__c, Operational__c, Operational_Sys__c, Operational_GARP__c, ';
            qry += 'Publishing_Experience__c, Publishing_Experience_Sys__c, Publishing_Experience_GARP__c, Teaching_Experience__c, Teaching_Experience_Sys__c, Teaching_Experience_GARP__c, ';
            qry += 'Technology__c, Technology_Sys__c, Technology_GARP__c, Regulation_and_Compliance_GARP__c, Liquidity_and_Treasury_GARP__c, Non_Financial_Risk_GARP__c, Sales_and_Trading_GARP__c ';
            qry += 'FROM SME_Registration__c WHERE Id = :rowId';
            
            List<SME_Registration__c> profiles = (List<SME_Registration__c>)Database.query(qry);
            if(profiles.size() > 0) {
                smeProfile = profiles[0];
            }
        }
        
        return smeProfile;
    }
    
    public static List<String> getCountryNames(String validInput) {
        List<String> sameNames; 
        switch on validInput {
            when 'United States' {
                sameNames = new List<String> {'US', 'USA', 'United States', 'United States of America'};
            }
            when 'United Kingdom' {
                sameNames = new List<String> {'UK', 'United Kingdom'};
            }
            when else {
                sameNames = new List<String> {validInput};
            }
        }
        return sameNames;
    }
    
    public class SearchFilter {
        @AuraEnabled public String field {get;set;}
        @AuraEnabled public String filter {get;set;}
        @AuraEnabled public List<String> value {get;set;}
    }
    
    // Moved from SMEProfileTriggerHelper (Deleted Apex Class)
    /* public static void populateCategoryFields(List<SME_Registration__c> smeList) {
        for(SME_Registration__c sme : smeList) {
            List<String> selfCateRes = new List<String>();
            List<String> garpCateRes = new List<String>();
            List<String> systemCateRes = new List<String>();
            
            for(String aFld : selfCateFields) {
                if(String.isNotEmpty((String)sme.get(aFld))) {
                    String cateName = aFld.replace('__c', '');
                    selfCateRes.add(cateName.replaceAll('_', ' '));
                }
            }
            
            for(String aFld : garpCateFields) {
                if(String.isNotEmpty((String)sme.get(aFld))) {
                    String cateName = aFld.replace('_GARP__c', '');
                    garpCateRes.add(cateName.replaceAll('_', ' '));
                }
            }
            
            for(String aFld : systemCateFields) {
                if(String.isNotEmpty((String)sme.get(aFld))) {
                    String cateName = aFld.replace('_Sys__c', '');
                    systemCateRes.add(cateName.replaceAll('_', ' '));
                }
            }
            
            sme.Self_Categories__c = String.join(selfCateRes, ';');
            sme.GARP_Categories__c = String.join(garpCateRes, ';');
            sme.System_Categories__c = String.join(systemCateRes, ';');
        }    
    } */
    
    @AuraEnabled(cacheable=false)
    public static Map<String,List<selectoption>> getPickListMapValues(){
        Map<String,List<selectoption>> returnPistlListMap = new Map<String,List<selectoption>>(); 
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get('SME_Registration__c');
        Schema.DescribeFieldResult fieldResult = sObjType.getDescribe().fields.getMap().get('GARP_Identification_Risk_Content_Areas__c').getDescribe();
        List<selectoption> picklistItem = new List<selectoption>();
        for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
            selectoption opt = new selectoption();
            opt.label = entry.getLabel();
            opt.value = entry.getValue();
            picklistItem.add(opt);
        }  
        returnPistlListMap.put('RiskAreas',picklistItem);
        picklistItem = new List<selectoption>(); 
        sObjType = Schema.getGlobalDescribe().get('Contact');
        Schema.DescribeFieldResult industryResult = sObjType.getDescribe().fields.getMap().get('Area_of_Concentration__c').getDescribe();
        for (Schema.PicklistEntry entry : industryResult.getPicklistValues()) {
            selectoption opt = new selectoption();
            opt.label = entry.getLabel();
            opt.value = entry.getValue();
            picklistItem.add(opt);
        }  
        returnPistlListMap.put('Industry',picklistItem);
        return returnPistlListMap;
    }
    
    public class selectoption{
        @AuraEnabled
        public String label{get;set;}
        @AuraEnabled
        public String value{get;set;}
    }
}