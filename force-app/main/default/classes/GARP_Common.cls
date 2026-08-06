public class GARP_Common {
    
    // Common Wappers
    
    public class apiReturnInfo {
        public string body;
        public Integer statusCode;
        public string message;        
    }
    
    public class checkAuthentication {
        public User user;
        public String contactId;
        public Boolean isAuthenticated;
    }
    
    public class address {
        public String company;
        public String street1;
        public String street2;
        public String street3;
        public String city;
        public String province;
        public String provence;
        
        public String postalCode;
        public String country;
        public String phone;        
        
        public String district; // For OSTA
        public String town; // For OSTA
        public boolean validaddress;
    }

    public class returnInfo {
        public String status;
        public String msg;
        public Integer errorCode;
    }

    
    // Methods
    public static MAP<String,Integer> getMonthMap() {
        MAP<String,Integer> mapMonths = new MAP<String,Integer>();
        mapMonths.put('January',1);
        mapMonths.put('February',2);
        mapMonths.put('March',3);
        mapMonths.put('April',4);
        mapMonths.put('May',5);
        mapMonths.put('June',6);
        mapMonths.put('July',7);
        mapMonths.put('August',8);
        mapMonths.put('September',9);
        mapMonths.put('October',10);
        mapMonths.put('November',11);
        mapMonths.put('December',12);
        
        return mapMonths;
    }
    
    public static MAP<Integer,String> getMonthMapByNumber() {
        MAP<Integer,String> mapMonths = new MAP<Integer,String>();
        mapMonths.put(1,'January');
        mapMonths.put(2,'February');
        mapMonths.put(3,'March');
        mapMonths.put(4,'April');
        mapMonths.put(5,'May');
        mapMonths.put(6,'June');
        mapMonths.put(7,'July');
        mapMonths.put(8,'August');
        mapMonths.put(9,'September');
        mapMonths.put(10,'October');
        mapMonths.put(11,'November');
        mapMonths.put(12,'December');
        
        return mapMonths;
    }
    
    public static checkAuthentication CheckAuthentication() {
        checkAuthentication checkAuth = new checkAuthentication();
        checkAuth.isAuthenticated = False;
        
        String userId = UserInfo.getUserId();
        List<User> lstUser = [SELECT Id, ContactId, Name, profile.name FROM User WHERE Id = :userId];
        debugLog('GARP_Common','checkAuthentication','lstUser',lstUser);
        debugLog('GARP_Common','checkAuthentication','lstUser',lstUser[0].profile.name);
        
        if(!lstUser.isEmpty() && lstUser[0].profile.name == 'Customer Community') {
            checkAuth.user = lstUser[0];
            checkAuth.isAuthenticated = True;
        }
        debugLog('GARP_Common','checkAuthentication','checkAuth',checkAuth);
        return checkAuth;
    }
    
    public static void logAppError(String message, String stackTrace, String contactId) {
        AppError__c appErr = new AppError__c(Error__c = message, Message__c = stackTrace, Contact__c = contactId);
        insert appErr;
    }
    
    public static Boolean isAdminImpersonating() {
        List<AuthSession> sessions = [
            SELECT id, CreatedDate,LoginType,IsCurrent,ParentId,SessionType  
            FROM AuthSession 
            WHERE IsCurrent = true
        ];
        GARP_Common.debugLog('GARP_Common','isAdminImpersonating','sessions',sessions);
        
        for (AuthSession s : sessions) {
            if (s.LoginType == 'Chatter Communities External User') {
                return false;
            }
        }
        return true;
    }
    
    public static String limitSize(String inStr, Integer maxSize) {
        if(inStr != null) {
            if(inStr.length() > maxSize)
                return inStr.substring(0, maxSize);
            else return inStr;
        }
        return inStr;
    }
    
    public class Country {
        public String id;
        public String label;
        public String name;
        public String code;
        public String phoneCode;
        public Boolean PostalCodeRequired;
        public Boolean ProvinceRequired;
        public List<Province> provinces;
    }
    
    public class Province {
        public String id;
        public String name;
        public String code;
    }
    
    public class MobilePhoneLocations {
        public String id;
        public String label;
        public String name;
     }
    
    public static List<MobilePhoneLocations> getMobilePhoneLocations(List<Country> countries) {
        List<MobilePhoneLocations> mobilePhoneLocations = new List<MobilePhoneLocations>(); 
        for(Country c :countries) {
            MobilePhoneLocations mpl = new MobilePhoneLocations();
            mpl.id = c.Id;
            mpl.label = c.label + ' (+' + c.phoneCode + ')';
            mpl.name = c.name + ' (+' + c.phoneCode + ')';
            mobilePhoneLocations.add(mpl);
        }
        return mobilePhoneLocations;
    }
    
    public static String getMappedCountry(MAP<String,Country_Code__c> mapCC, String country) {
        Country_Code__c fndCountry = mapCC.get(country);
        if(fndCountry != NULL) {
            return fndCountry.Country__c;
        } else {
            return country;
        }        
    }

    public static String getMappedCountryCode(MAP<String,Country_Code__c> mapCC, String country) {
        Country_Code__c fndCountry = mapCC.get(country);
        if(fndCountry != NULL) {
            return fndCountry.LetterCode__c;
        } else {
            return country;
        }        
    }
    
    public static MAP<String,Country_Code__c> getCountriesMapByCountryCode(){
        MAP<String,Country_Code__c> mapCountries = new MAP<String,Country_Code__c>();
        List<Country_Code__c> lst = [select id, Country__c, LetterCode__c, PhoneCode__c, Postal_Code_Required__c, Provence_Required__c, (select id, name, code__c from Provinces__r Order by Name) from Country_Code__c Order By Country__c];        
        for(Country_Code__c ctry :lst) {
            mapCountries.put(ctry.LetterCode__c,ctry);
        }
        return mapCountries;
    }
    
    public static MAP<String,Country_Code__c> getCountriesMapByCountryName(){
        MAP<String,Country_Code__c> mapCountries = new MAP<String,Country_Code__c>();
        List<Country_Code__c> lst = [select id, Country__c, LetterCode__c, PhoneCode__c, Postal_Code_Required__c, Provence_Required__c, (select id, name, code__c from Provinces__r Order by Name) from Country_Code__c Order By Country__c];        
        for(Country_Code__c ctry :lst) {
            mapCountries.put(ctry.Country__c,ctry);
        }
        return mapCountries;
    }
    
    public static MAP<String,Province__c> getProvinceMapByCode(String countryId){
        MAP<String,Province__c> mapProvinces = new MAP<String,Province__c>();
        List<Province__c> lst = [Select id, name, code__c from Province__c where Country_Code__c = :countryId];        
        for(Province__c p :lst) {
            mapProvinces.put(p.code__c,p);
        }
        return mapProvinces;
    }
    
    public static MAP<String,Province__c> getProvinceMapByName(String countryId){
        MAP<String,Province__c> mapProvinces = new MAP<String,Province__c>();
        List<Province__c> lst = [Select id, name, code__c from Province__c where Country_Code__c = :countryId];        
        for(Province__c p :lst) {
            mapProvinces.put(p.name,p);
        }
        return mapProvinces;
    }
    
    public static List<Country> getCountries(){
        List<Country> countries = new List<Country>();
        
        List<Country_Code__c> lst = [select id, Name, Country__c, LetterCode__c, PhoneCode__c, Postal_Code_Required__c, Provence_Required__c, (select id, name, code__c from Provinces__r Order by Name) from Country_Code__c Order By Country__c];
        for(Country_Code__c ctry :lst) {
            Country newCtry = new Country();
            newCtry.id = ctry.id;
            newCtry.label = ctry.Name;
            newCtry.name = ctry.Country__c;
            newCtry.code = ctry.LetterCode__c;
            newCtry.phoneCode = ctry.PhoneCode__c;
            newCtry.PostalCodeRequired = ctry.Postal_Code_Required__c;
            newCtry.ProvinceRequired = ctry.Provence_Required__c;
            
            if(!ctry.Provinces__r.IsEmpty()) {
                newCtry.provinces = new List<Province>();
                for(Province__c prov :ctry.Provinces__r) {
                    Province newProv = new Province();
                    newProv.id = prov.id;
                    newProv.name = prov.name;
                    newProv.code = prov.code__c;
                    newCtry.provinces.add(newProv);
                }
            }
            countries.add(newCtry);
        }
        return countries;
    }
    
    public static Boolean isAddressesTheSame(address address1, address address2) {
        if(address1 != NULL && address2 != NULL) {
            if(address1.company == address2.company &&
               address1.city == address2.city &&
               address1.province == address2.province &&
               address1.postalCode == address2.postalCode &&
               address1.country == address2.country &&
               address1.street1 == address2.street1 &&
               address1.street2 == address2.street2 &&
               address1.street3 == address2.street3               
              ) {
                  return True;
              }
        }
        return False;
    }
    
    public class Institution implements Comparable {
        public String id;
        public String name;
        public String type;

        public Integer compareTo(Object obj) {
            Institution other = (Institution)obj;
            return this.name.toLowerCase().compareTo(other.name.toLowerCase());
        }
    }
    public static List<Institution> getInstitutions(){
        List<Institution> institutions = new List<Institution>();
        List<Institution__c> lst = [select id, Institution_Name__c, RecordType.Name from Institution__c Order By Institution_Name__c];
        for(Institution__c inst :lst) {
            Institution newInst = new Institution();
            newInst.id = inst.id;
            newInst.name = inst.Institution_Name__c;
            newInst.type = inst.RecordType.Name;
      institutions.add(newInst);
        }
        return institutions;
    }

    public static List<Institution> getEPPInstitutions() {
        List<Institution> eppInstitutions = new List<Institution>();

        // Query EPP Accounts with Exam Registration Status = 'Approved'
        List<EPP_Account__c> eppAccounts = [
            SELECT Id, Name
            FROM EPP_Account__c
            WHERE EPP_Registration_Status__c = 'Approved'
            ORDER BY Name
        ];

        for (EPP_Account__c epp : eppAccounts) {
            Institution inst = new Institution();
            inst.id = epp.Id;
            inst.name = epp.Name;
            inst.type = 'EPP';
            eppInstitutions.add(inst);
        }

        return eppInstitutions;
    }

    public static List<Institution> mergeInstitutionsLists() {
        // Get combined list of institutions and EPP institutions
        List<Institution> institutions = getInstitutions();
        List<Institution> eppInstitutions = getEPPInstitutions();

        // Merge the two lists
        institutions.addAll(eppInstitutions);

        institutions.sort();

        return institutions;
    }
    
    public static List<String> getPickListValues(String strObjectName, String strPicklistField) {

        List<String> retValues = new List<String>();
            
        Map<String, String> mapPickListValues = new Map<String, String>();
        Schema.SObjectType objSobjectType = Schema.getGlobalDescribe().get(strObjectName);
        Schema.DescribeSObjectResult objDescribeSobject = objSobjectType.getDescribe();
        Map<String, Schema.SObjectField> mapFields = objDescribeSobject.fields.getMap();
        List<Schema.PicklistEntry> lstPickListValues = mapFields.get(strPicklistField).getDescribe().getPickListValues();
        for (Schema.PicklistEntry objPickList : lstPickListValues) {
            retValues.add(objPickList.getLabel());
        }
        
        return retValues;
    }
    
    public static Boolean setSafeBoolean(Boolean inBool) {
        if(inBool == NULL) {
            return False;
        }
        return inBool;
    }
    
    public static void debugLog(String className, String methodName, String msg, Object values) {
        if(msg == NULL)
            return;
        
        if(Label.GARP_Debugging == 'TRUE') {
            String str='';
            if(className != NULL) {
                str+=className;
            }
            if(methodName!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=methodName;
            }
            if(msg!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=msg;
            }
            String val = String.ValueOf(values);
            if(val!=NULL) {
                if(!String.isEmpty(str))
                    str+=':';
                str+=val;
            }
            System.debug(str);
        }
    }
    
    public static void debugLog(String msg, Object values) {
        if(msg == NULL)
            return;
        if(Label.GARP_Debugging == 'TRUE') {
            String str = msg;
            if(values != NULL) {
                str += ': ' + String.ValueOf(values);
            }
            System.debug(str);
        }
    }
     
     
    public static Boolean hasNonWesternChars(String strIn) {
        List<Integer> ints = strIn.getChars();
        for(Integer i :ints) {
            if(i > 127) {
                return true;
            }
        }
        return false;
    }
     
     
    public static string addError(String error, String errorIn) {
    
        if(!String.isEmpty(error)) {
            return error + ', ' + errorIn;
        } else {
            return errorIn;
        }
    
    }
    
    public static String formatDate(Date dt, String frmt) {
        if(dt != NULL) {
            DateTime inptDt = DateTime.NewInstance(dt.year(),dt.month(),dt.day());        
            return inptDt.format(frmt);            
        } else {
            return null;
        }
    }
    
    public static String formatAddressTextArea(String street1, String street2, String street3) {
        String retAddress = '';
        if(street1 != NULL) {
            retAddress = street1;
        }
        if(street2 != NULL) {
            retAddress = retAddress + '\n' + street2;
        }
        if(street3 != NULL) {
            retAddress = retAddress + '\n' + street3;
        }
        return retAddress;
    }
    
    public static address parseMultiAddressLine(String multiAddress) {
        address address = new address();
        
        //Parsing BillingStreet off of the Account
        if (multiAddress != null) {
            String[] billingAddress = multiAddress.split('\n');
            if (billingAddress != null && !billingAddress.isEmpty()) {
                address.street1 = (billingAddress.size() > 0) ? billingAddress[0] : null;
                address.street2 = (billingAddress.size() > 1) ? billingAddress[1] : null;
                address.street3 = (billingAddress.size() > 2) ? billingAddress[2] : null;         
            }else{
                address.street1 = multiAddress;
            }
        }
        
        return address;
    }
    
    public static Map<String,String> getStateCodeMap() {
        Map<String,String> stateNameToCodeMap = new Map<String,String>();
        List<Province__c> lstProv = [select Id,Name,Code__c from Province__c Limit 2000];
        for(Province__c prov : lstProv){
            stateNameToCodeMap.put(prov.Name,prov.Code__c);
        }
        return stateNameToCodeMap;
    }
    
    public static string convertLongStateToCode(String inState) {
        if(inState != NULL && inState.length() > 2) {
            List<Province__c> lstProv = [select Code__c from Province__c where Name = :inState];
            if(!lstProv.IsEmpty()) {
                return lstProv[0].Code__c;
            }
        }
        return inState;
    }
    
    public static string convertLongStateToCode(Map<String,String> stateNameToCodeMap,String inState) {
        if(inState != NULL && inState.length() > 2) {
            if(stateNameToCodeMap.containskey(inState)) {
                return stateNameToCodeMap.get(inState);
            }
        }
        return inState;
    }
    
    public static List<String> safeList(List<String> inList) {
        if(inList == NULL) {
            return new List<String>();
        } else {
            return inList;
        }
    }

    public static List<String> safeSet(Set<String> inList) {
        if(inList == NULL) {
            return new List<String>();
        } else {
            return new List<String>(inList);
        }
    }
 
    public static Boolean isLoadingResults(Boolean isLoading, String closedKey) {
    
        if(isLoading && closedKey != 'kiujgh&^%Rrf7u') {
            return true;
        } else {
            return false;
        }
        
    }
    
    public static String setIfNotEmpty(String newValue, String oldValue) {
        if(!String.isEmpty(newValue)) {
            return newValue;
        } else {
            return oldValue;
        }
    }
    
    public static Boolean setIfNotEmpty(Boolean newValue, Boolean oldValue) {
        if(newValue != NULL) {
            return newValue;
        } else {
            return oldValue;
        }
    }
    
    public static String newLineToBR(String inValue) {
        if(!String.isEmpty(inValue)) {
            return inValue.replace('\n', '<br/>');
        } else {
            return '';
        }
    }
    
    public static Map<Object, List<String>> getDependentPicklistValues(
        Schema.SObjectField dependToken,
        Schema.SObjectField masterField
    ) {
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        
        Schema.DescribeFieldResult depend = dependToken.getDescribe();
        Schema.SObjectField controlToken = depend.getController();
        
        if (controlToken == null) {
            return null;
        }
        
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        
        List<Schema.PicklistEntry> controlEntries =
            control.getType() == Schema.DisplayType.Boolean
            ? null
            : control.getPicklistValues();
        
        Integer controlSize = controlEntries == null ? 2 : controlEntries.size();
        
        Map<Object, List<String>> results = new Map<Object, List<String>>();
        
        for (Schema.PicklistEntry depEntry : depend.getPicklistValues()) {
            if (!depEntry.isActive()) {
                continue;
            }
            
            Map<String, Object> depEntryJson =
                (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(depEntry));
            
            String validFor = String.valueOf(depEntryJson.get('validFor'));
            
            for (Integer index = 0; index < controlSize; index++) {
                Object controlValue;
                
                if (controlEntries == null) {
                    controlValue = index == 1;
                } else {
                    Schema.PicklistEntry controlEntry = controlEntries[index];
                    
                    if (!controlEntry.isActive()) {
                        continue;
                    }
                    
                    controlValue = controlEntry.getValue();
                }
                
                if (isValidFor(validFor, index, base64map)) {
                    if (!results.containsKey(controlValue)) {
                        results.put(controlValue, new List<String>());
                    }
                    
                    results.get(controlValue).add(depEntry.getValue());
                }
            }
        }
        
        return results;
    }
    
    private static Boolean isValidFor(String validFor, Integer index, String base64map) {
        Integer bitIndex = index / 6;
        Integer bitShift = 5 - Math.mod(index, 6);
        
        if (String.isBlank(validFor) || bitIndex >= validFor.length()) {
            return false;
        }
        
        String base64Char = validFor.substring(bitIndex, bitIndex + 1);
        Integer base64Value = base64map.indexOf(base64Char);
        
        return (base64Value & (1 << bitShift)) != 0;
    }
    
    public static Id uploadAttachmentToObject(Id attachmentId, String fileText, String fileName, String ObjectId) {
        debugLog('GARP_BC_Registration','uploadAttachmentToObject','attachmentId',attachmentId);
        debugLog('GARP_BC_Registration','uploadAttachmentToObject','fileText',fileText);
        debugLog('GARP_BC_Registration','uploadAttachmentToObject','fileName',fileName);
        debugLog('GARP_BC_Registration','uploadAttachmentToObject','ObjectId',ObjectId);
        
        list<Attachment> attachments;
        if(attachmentId != NULL) {
            attachments = [SELECT Id, Body FROM Attachment WHERE Id =: attachmentId];    
            debugLog('GARP_BC_Registration','uploadAttachmentToObject','attachments',attachments);            
        }
        
        if(attachments == NULL || attachments.isEmpty()) {
            Attachment att = new Attachment();
            att.Body = EncodingUtil.base64Decode(fileText);
            att.Name = fileName;
            att.parentId = ObjectId;
            insert att;
            
            return att.Id;
        } else {
            String newBody = '';
            Attachment att = attachments[0];
            if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
            }
            newBody += fileText;
            att.Body = EncodingUtil.base64Decode(newBody);
            
            //debugLog('GARP_BC_Registration','uploadAttachmentToObject','update attachment',att.Name);            
            
            update att;
            return att.Id;
        }   
    }
}