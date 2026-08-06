public class ReusableLookupController {
    @AuraEnabled
    public static List<ResultWrapper> fetchRecords(SearchWrapper inobj) {
        try { 
            if(inobj != null){                 
                Set<String> uniqueFields = new Set<String>{'Id'};
                List<String> mainFields = inobj.fieldApiName.split(',');
                 
                for(String f : mainFields) {
                    uniqueFields.add(f.trim());
                } 
                if(String.isNotBlank(inobj.otherFieldApiName)){
                    for(String f : inobj.otherFieldApiName.split(',')) {
                        uniqueFields.add(f.trim());
                    }
                } 
                String fieldSelection = String.join(new List<String>(uniqueFields), ', ');
                String query = 'SELECT ' + fieldSelection + ' FROM ' + inobj.objectApiName;
                
 
                List<String> orConditions = new List<String>();
                String escapedSearch = '%' + String.escapeSingleQuotes(inobj.searchString.trim()) + '%';
                
                for(String f : mainFields) {
                    orConditions.add(f.trim() + ' LIKE \'' + escapedSearch + '\'');
                }
                 
                String searchFilter = '(' + String.join(orConditions, ' OR ') + ')';
                 
                if(String.isNotBlank(inobj.additionalFilter)){
                    searchFilter += ' AND (' + inobj.additionalFilter + ')';
                }
                 
                if(String.isNotBlank(inobj.selectedRecordId)) {
                    query += ' WHERE Id = \'' + inobj.selectedRecordId + '\'';
                } else if(String.isNotBlank(inobj.parentFieldApiName) && String.isNotBlank(inobj.parentRecordId)) {
                    query += ' WHERE ' + inobj.parentFieldApiName + ' = \'' + inobj.parentRecordId + '\'';
                    query += ' AND ' + searchFilter;
                } else {
                    query += ' WHERE ' + searchFilter;
                }
                
                query += ' LIMIT 30';
                 
                List<ResultWrapper> returnWrapperList = new List<ResultWrapper>();
                for(SObject s : Database.query(query)) {
                    ResultWrapper wrap = new ResultWrapper();
                    wrap.mainField = (String)s.get(mainFields[0]);
                    String sibfields = '';
                    if(string.isNotBlank(inobj.otherFieldApiName)){
                        List<String> fields = inobj.otherFieldApiName.split(',');
                       
                        for (integer i = 0; i < fields.size(); i++) {
                            if(string.isNotBlank(inobj.subFieldLabel)){
                                 String label = inobj.subFieldLabel.split(',')[i];
                                 sibfields += '<b>'+label+'</b>: ';
                            }
                            if(string.isNotBlank(inobj.subFieldLabel)){
                                sibfields += (String)s.get(fields[i])+'<br/>';
                            }else{
                                 sibfields += (String)s.get(fields[i]);
                            }
                        }
                    }
                    wrap.subField = sibfields;
                    wrap.id = (String)s.get('id');
                    returnWrapperList.add(wrap);
                }
                //system.debug(returnWrapperList);
                return returnWrapperList;
            }
            return null;
        } catch (Exception err) {
            system.debug(err.getMessage());
            throw new AuraHandledException(err.getMessage());
        }
    }

    public class ResultWrapper{
        @AuraEnabled public String mainField{get;set;}
        @AuraEnabled public String subField{get;set;}
        @AuraEnabled public String id{get;set;}
    }

    public class SearchWrapper {
        @AuraEnabled public String objectApiName{get;set;}
        @AuraEnabled public String fieldApiName{get;set;}
        @AuraEnabled public String otherFieldApiName{get;set;}
        @AuraEnabled public String searchString{get;set;}
        @AuraEnabled public String selectedRecordId{get;set;}
        @AuraEnabled public String parentRecordId{get;set;}
        @AuraEnabled public String parentFieldApiName{get;set;}
        @AuraEnabled public String additionalFilter{get;set;}
        @AuraEnabled public String subFieldLabel{get;set;}
        
        
    }
}