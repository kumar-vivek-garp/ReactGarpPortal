public class CPDNewsletterGeneratorCtrl {
    
    public String applicationReference = 'CPD Newsletter Generator';
    
    public Integer groupIndex           { get; set; }
    public Integer selectedGroupIndex   { get; set; }
    
    public String cpeActivityId                                         { get; set; }
    public CPE_Activity__c selectedCpeActivity                          { get; set; }
    public List<CPE_Activity__c> cpeActivities                          { get; set; }
    public List<CPE_Activity__c> selectedCpeActivities                  { get; set; }
    public List<List<CPE_Activity__c>> groupedByActivityTypeList        { get; set; }
    public Map<String, List<CPE_Activity__c>> groupedByActivityTypeMap  { get; set; }
    
    public Integer offset                       { get; set; }
    public Integer pageNumber                   { get; set; }
    public Integer pages                        { get; set; }
    public Integer limitTo                      { get; set; }
    public String  searchString                 { get; set; }
    
    public Content_Selector__c contentSelector  { get; set; }
 
    public CPE_Activity__c SObjectStartDate     { get; set; }
    public Date startDate                       { get; set; }
    
    public String activityType                  { get; set; }
    public List<SelectOption> activityTypes     { get; set; }
    
    public String areaOfStudy                   { get; set; }
    public List<SelectOption> areasOfStudy      { get; set; }
    
    public List<SelectOption> metadataLists     { get; set; }
    public String metadataListName              { get; set; }
    public String metadataListId                { get; set; }
    
    public String htmlTemplate                  { get; set; }
    
    
    public List<Id> pluckIds(List<CPE_Activity__c> argsv){
        
        List<Id> selectedIds = new List<Id>();
        
        for(CPE_Activity__c cpea: argsv){
            selectedIds.add(cpea.Id);
        }
        
        return selectedIds;
        
    }
    
    public Content_Selector__c updateContentIds(List<Id> ids){
        
        groupedByActivityTypeList = getSelectedCpeActivitiesByIds(ids); 
        selectedCpeActivities = flatten(groupedByActivityTypeList);
        
        contentSelector.Content_IDs__c = convertListToCommaDelimitedList(ids);                                   
        cpeActivities = filterBy(convertCommaDelimitedListToList(contentSelector.Content_IDs__c), limitTo, offset);
        
        return contentSelector;
        
    }
    
    public Map<String, Integer> getItemAndGroupIndices(){
        
        Map<String, Integer> indexMap = new Map<String, Integer>();
        
        for(Integer g = 0; g < groupedByActivityTypeList.size(); g++){
            for(Integer i = 0; i < groupedByActivityTypeList[g].size(); i++){
                if(groupedByActivityTypeList[g][i].Id != cpeActivityId) continue;
                indexMap.put('groupIndex', g);
                indexMap.put('itemsIndex', i);
            }
        }     
        
        return indexMap;
        
    }
    
    public List<Id> convertCommaDelimitedListToList(String commaDelimitedList){
        List<Id> cpeActivityIds = new List<Id>();
        if(commaDelimitedList != null && commaDelimitedList != ''){
            for(String cdl: commaDelimitedList.split(',')){
                cpeActivityIds.add(cdl.trim());
            }
            return cpeActivityIds;
        }else{
            return null;
        }
    }
    
    public Integer getPageCount(Integer count){
        return (math.mod(count, limitTo) == 0) ? (count / limitTo) : (count / limitTo) + 1;
    }
    
    public String convertListToCommaDelimitedList(List<Id> ids){ 
        return String.join(ids, ', ');
    }
    
    public List<CPE_Activity__c> flatten (List<List<CPE_Activity__c>> groups){
        List<CPE_Activity__c> output = new List<CPE_Activity__c>();
        for(List<CPE_Activity__c> g: groups){
            for(CPE_Activity__c cpea: g){
                output.add(cpea);
            }
        }    
        return output;
    }
    
    public List<List<CPE_Activity__c>> getSelectedCpeActivitiesByIds(List<Id> ids){        
        
        List<List<CPE_Activity__c>> ordered = new List<List<CPE_Activity__c>>();
        
        if(ids != null && !ids.isEmpty()){
            
            Map<Id, CPE_Activity__c> cpeActivities = new Map<Id, CPE_Activity__c>([
                SELECT 
                Id, 
                Name, 
                Title__c, 
                Description__c, 
                Sequence__c, 
                CPE_Activity_Type__c, 
                Location__c, 
                CPE_Activity_Type__r.Name, 
                Activity_Type_Description__c, 
                Area_of_Study__c, 
                Credit__c, 
                Date_Description__c, 
                Organization__c, 
                Provider__c, 
                Publication__c, 
                URL__c, 
                Outreach_Start_Date__c, 
                Outreach_End_Date__c, 
                Activity_Date__c
                FROM CPE_Activity__c 
                WHERE Id IN :ids
            ]);
            
            groupedByActivityTypeMap = new Map<String, List<CPE_Activity__c>>();
            
            for(Id id: ids){
                if(cpeActivities.containsKey(id)){                                       
                    CPE_Activity__c cpeActivity = cpeActivities.get(id);
                    if(groupedByActivityTypeMap.containsKey(cpeActivity.CPE_Activity_Type__r.Name)){
                        groupedByActivityTypeMap.get(cpeActivity.CPE_Activity_Type__r.Name).add(cpeActivity);
                    }else{
                        groupedByActivityTypeMap.put(cpeActivity.CPE_Activity_Type__r.Name, new List<CPE_Activity__c>{cpeActivity});
                    }
                }
            }
       
            for(String key: groupedByActivityTypeMap.keySet()){
                ordered.add(groupedByActivityTypeMap.get(key));
            }
                       
        }
        
        return ordered;
        
    }
    
    public Integer getSOQLRecordCount(List<Id> selectedCpeActivities){
        
        String query = 'SELECT COUNT() FROM CPE_Activity__c';
        
        if(startDate != null || (areaOfStudy != null && areaOfStudy != '') || (activityType != null && activityType != '') || (selectedCpeActivities != null && !selectedCpeActivities.isEmpty())){
            
            query += ' WHERE ';
            
            List<String> criteria = new List<String>();
            
            if(activityType != null) criteria.add('CPE_Activity_Type__r.Name    =   :activityType');
            if(areaOfStudy  != null) criteria.add('Area_of_Study__c             =   :areaOfStudy');
            if(startDate    != null) criteria.add('Outreach_Start_Date__c       <=  :startDate');
            if(startDate    != null) criteria.add('Outreach_End_Date__c         >=  :startDate');

            if(selectedCpeActivities != null && !selectedCpeActivities.isEmpty()) criteria.add('Id NOT IN :selectedCpeActivities');
            
            query += String.join(criteria, ' AND ');
            
        }
        
        return Database.countQuery(query);
        
    }
    
    public List<CPE_Activity__c> filterBy(List<Id> selectedCpeActivities, Integer limitTo, Integer offset){
        
        String query = 'SELECT Id, Name, Title__c, Description__c, Sequence__c, CPE_Activity_Type__c, Location__c, CPE_Activity_Type__r.Name, Activity_Type_Description__c, Area_of_Study__c, Credit__c, Date_Description__c, Organization__c, Provider__c, Publication__c, URL__c, Outreach_Start_Date__c, Outreach_End_Date__c, Activity_Date__c';
        
        query += ' FROM CPE_Activity__c';
        
        if(startDate != null || (areaOfStudy != null && areaOfStudy != '') || (activityType != null && activityType != '') || (selectedCpeActivities != null && !selectedCpeActivities.isEmpty())){
            
            query += ' WHERE ';
            
            List<String> criteria = new List<String>();
            
            if(activityType != null) criteria.add('CPE_Activity_Type__r.Name    =   :activityType');
            if(areaOfStudy  != null) criteria.add('Area_of_Study__c             =   :areaOfStudy');
            if(startDate    != null) criteria.add('Outreach_Start_Date__c       <=  :startDate');
            if(startDate    != null) criteria.add('Outreach_End_Date__c         >=  :startDate');

            if(selectedCpeActivities != null && !selectedCpeActivities.isEmpty()) criteria.add('Id NOT IN :selectedCpeActivities');
            
            query += String.join(criteria, ' AND ');
            
        }

        query += ' ORDER BY CPE_Activity_Type__r.Name DESC';
        
        if(limitTo  != null) query += ' LIMIT ' + limitTo;
        if(offset   != null) query += ' OFFSET ' + offset;
        
        pages = getPageCount(getSOQLRecordCount(selectedCpeActivities));
        
        return Database.query(query);
        
    }
    
    public void next(){
        
        if(pageNumber < pages){
            this.pageNumber++;
            this.offset = (this.pageNumber - 1) * this.limitTo;
            this.cpeActivities = query(); 
        }
        
    }
    
    public void prev(){
        
        if(pageNumber > 1){
            this.pageNumber--;
            this.offset = (this.pageNumber - 1) * this.limitTo;
            this.cpeActivities = query(); 
        }
        
    }
    
    public void doFilter(){
        
        startDate = sObjectStartDate.Outreach_Start_Date__c;
        
        offset = 0;

        cpeActivities = query();       

        pageNumber = (pages == 0) ? 0 : 1;   
        
    }
    
    public List<CPE_Activity__c> query(){

        return filterBy(convertCommaDelimitedListToList(contentSelector.Content_IDs__c), limitTo, offset);           
        
    }
    
    public void moveGroupDn(){
        
        if(selectedGroupIndex < groupedByActivityTypeList.size() - 1){
            
            List<CPE_Activity__c> adj = groupedByActivityTypeList[selectedGroupIndex + 1];
            groupedByActivityTypeList[selectedGroupIndex + 1] = groupedByActivityTypeList[selectedGroupIndex];
            groupedByActivityTypeList[selectedGroupIndex] = adj; 
            
        }
        
        UPDATE updateContentIds(pluckIds(flatten(groupedByActivityTypeList)));
        
    }
    
    public void moveGroupUp(){
        
        if(selectedGroupIndex > 0){
            
            List<CPE_Activity__c> adj = groupedByActivityTypeList[selectedGroupIndex - 1];
            groupedByActivityTypeList[selectedGroupIndex - 1] = groupedByActivityTypeList[selectedGroupIndex];
            groupedByActivityTypeList[selectedGroupIndex] = adj;
            
        }      
        
        UPDATE updateContentIds(pluckIds(flatten(groupedByActivityTypeList)));
        
    }
    
    public void moveItemDn(){
        
        Map<String, Integer> indices = getItemAndGroupIndices();
        
        Integer groupIndex = indices.get('groupIndex');
        Integer itemsIndex = indices.get('itemsIndex');
        
        if(itemsIndex < groupedByActivityTypeList[groupIndex].size() - 1){
            
            CPE_Activity__c adj = groupedByActivityTypeList[groupIndex][itemsIndex + 1];
            groupedByActivityTypeList[groupIndex][itemsIndex + 1] = groupedByActivityTypeList[groupIndex][itemsIndex];
            groupedByActivityTypeList[groupIndex][itemsIndex] = adj;
            
        }
        
        UPDATE updateContentIds(pluckIds(flatten(groupedByActivityTypeList)));
        
    }
    
    public void moveItemUp(){
        
        Map<String, Integer> indices = getItemAndGroupIndices();
        
        Integer groupIndex = indices.get('groupIndex');
        Integer itemsIndex = indices.get('itemsIndex');
                
        if(itemsIndex > 0){
            
            CPE_Activity__c adj = groupedByActivityTypeList[groupIndex][itemsIndex - 1];
            groupedByActivityTypeList[groupIndex][itemsIndex - 1] = groupedByActivityTypeList[groupIndex][itemsIndex];
            groupedByActivityTypeList[groupIndex][itemsIndex] = adj;
            
        }
        
        UPDATE updateContentIds(pluckIds(flatten(groupedByActivityTypeList)));
        
    }
    
    public void doSelect(){
        
        if(cpeActivityId != null && cpeActivityId != ''){
            
            List<Id> selectedIds = new List<Id>();
            
            if(contentSelector.Content_IDs__c != null && contentSelector.Content_IDs__c != '') selectedIds.addAll(convertCommaDelimitedListToList(contentSelector.Content_IDs__c));
            
            selectedIds.add(cpeActivityId);
            
            UPDATE updateContentIds(selectedIds); 
            
        }
        
    }
    
    public void doRemove(){
        
        if(cpeActivityId != null && cpeActivityId != ''){
            
            List<Id> selectedIds = new List<Id>();
            
            if(contentSelector.Content_IDs__c != null) selectedIds.addAll(convertCommaDelimitedListToList(contentSelector.Content_IDs__c));
            
            for(Integer i = 0; i < selectedIds.size(); i++){
                if(selectedIds[i] == cpeActivityId) selectedIds.remove(i);
            }
            
            UPDATE updateContentIds(selectedIds);  
                       
        }
        
    } 

    public PageReference doOpen(){
        
        PageReference ref = ApexPages.currentPage();
        ref.setRedirect(true);
        ref.getParameters().put('metadataListId', this.metadataListId);
        
        return ref;
        
    }
    
    public PageReference doSaveAs(){
        
        if(this.metadataListName != '' && this.metadataListName != null){
            
            List<Content_Selector__c> existingMetadataLists = [SELECT Name FROM Content_Selector__c WHERE Name = :this.metadataListName];
            
            if(existingMetadataLists.isEmpty()){
                
                Content_Selector__c cs = new Content_Selector__c(
                    Name = this.metadataListName,
                    Application_Reference__c = this.applicationReference
                );
                
                INSERT cs;
                
                PageReference ref = ApexPages.currentPage();
                ref.setRedirect(true);
                ref.getParameters().put('metadataListId', cs.Id);
                
                return ref;
                
            }else{
                
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'This CPE Activity list name already exists, please select a different name.'));
                return null;
                
            }
            
            
        }else{
            
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'You must provide a name for this CPE Activity list.'));
            return null;
            
        }
        
    }
    
    public PageReference doNew(){
        
        PageReference ref = new PageReference('/apex/CPDNewsletterGenerator');
        ref.setRedirect(true);
        return ref;     
        
    }
    
    public void doGenerateHTML(){
        
        String html = '<table colspan="4" width="100%">';
        
        for(String key: groupedByActivityTypeMap.keySet()){      
            
            //Setting up UTM date in valid format
            DateTime utmd = DateTime.now();
            String monthName = utmd.format('MMMMM');
            String dayOfMonth = utmd.format('d');
            String year = utmd.format('yyyy');
            String dateString = monthName + '_' + dayOfMonth + '_' + year;
            
            html+= '<tr>';
            html+= '  <td>';
            html+= '     <table cellspacing="0" cellpadding="0">';
            html+= '        <tr>';
            html+= '           <td>';
            html+= '              <h2 style="font-family: Arial; font-size:20px; margin: 0px; margin-top: 30px; color: #222;">' + key + '</h2>';
            html+= '           </td>';
            html+= '        </tr>';
            html+= '     </table>';
            html+= '  </td>';
            html+= '</tr>';
            html+= '<tr>';
            html+= '    <td colspan="4" style="border-bottom: solid 1px #dee7ee; font-size: 0px;">&nbsp;</td>';
            html+= '<tr/>';
            
            for(CPE_Activity__c cpea: groupedByActivityTypeMap.get(key)){
                
                //Defining provider
                String provider = '';
                if(cpea.Provider__c != null) {
                    provider = cpea.Provider__c;
                } else if(cpea.Organization__c!= null) {
                    provider = cpea.Organization__c;
                } else if(cpea.Publication__c!= null) {
                    provider = cpea.Publication__c;
                } else if(cpea.Description__c!= null) {
                    if(cpea.Description__c.length() > 30)
                        provider = cpea.Description__c.subString(0,30);
                    else if(cpea.Description__c.length() > 0)
                        provider = cpea.Description__c;
                }
                
                //Defining location
                String location = '';
                if(cpea.Location__c != null){
                    location = cpea.Location__c;
                }

                String utmTracking = '&utm_content=' + dateString + '&utm_source=GA_Source{url}&utm_medium=email&utm_campaign=cpdnewsletter&utm_term=submitbutton';
                
                String submitLink = 'https://my.garp.org/Login?start=cpe_activity/' + cpea.Id + utmTracking;
                                              
                html += '<tr>';
                html += '  <td valign="middle">';
                html += '    <table align="left" cellspacing="0" cellpadding="0" style="max-width:370px">';
                html += '       <tr valign="center">';
                html += '          <td valign="center">';
                html += '             <h4 style="font-size: 12px; font-family: arial; margin-top: 10px; margin-bottom: 0px; color: #222;">' + cpea.Area_of_Study__c.replaceAll('\\;', ' | ') + '</h4>';
                html += '             <h3 style="font-size: 16px; font-family: arial; margin-top: 5px;  margin-bottom: 5px;"><a href="' + cpea.URL__c + '" target="_blank" style="text-decoration: none; color: #35b4e3;">'+cpea.Name+'</a></h3>';
                html += '             <h5 style="font-size: 12px; font-family: arial; margin-top: 0px;  margin-bottom: 10px; font-weight: 400; color: #888;">' + provider + ' - ' + cpea.Date_Description__c + '</h5>';
                html += '          </td>';
                html += '       </tr>';
                html += '    </table>';
                html += '  </td>';
                html += '  <td valign="middle" style="min-width:60px;">';
                html += '    <right>';
                html += '       <h2 style="font-family: arial; margin: 0px; text-align: center; font-size: 16px;">' + String.valueOf(cpea.Credit__c) + '</h2>';
                html += '       <h4 style="font-family: arial; margin: 0px; text-align: center; font-size: 12px;">Credits</h4>';
                html += '    </right>';
                html += '  </td>';
                html += '  <td align="right" valign="middle">';
                html += '    <table cellspacing="0" cellpadding="10" style="background: #00a2dd; min-width: 60px; border-bottom: 2px solid #178eb6">';
                html += '       <tr>';
                html += '          <td nowrap><a href="' + submitLink + '" target="_blank" style="font-size: 12px; font-family: Arial; color: #ffffff; text-decoration: none;">Submit</a></td>';
                html += '       </tr>';
                html += '    </table>';
                html += '  </td>';
                html += '</tr>';
                html += '<tr>';
                html += '    <td colspan="4" style="border-bottom: solid 1px #dee7ee;"></td>';
                html += '<tr/>';
                
                             
            }
            
        }
        
        html+= '</table>';
        
        htmlTemplate = html;
        
    }
    
    public void doSave(){
        
        List<Id> selectedIds =  new List<Id>();
        
        for(CPE_Activity__c cpeActivity: selectedCpeActivities){
            selectedIds.add(cpeActivity.Id);
        }
        
        contentSelector.Content_IDs__c = String.join(selectedIds, ', ');
        
        UPDATE contentSelector;
        
    }
    
    public PageReference doDelete(){
        
        DELETE contentSelector;
        
        PageReference ref = new PageReference('/apex/CPDNewsletterGenerator');
        metadataListId = null;
        metadataListName = null;
        ref.setRedirect(true);
        return ref;
        
    }
    
    public void saveContentSelector(){
        UPDATE contentSelector;
    }
    
    public CPDNewsletterGeneratorCtrl(){
        
        PageReference ref = ApexPages.currentPage();
        
        this.offset = 0;
        this.pageNumber = 1;
        this.limitTo = 10;
        
        this.sObjectStartDate = new CPE_Activity__c();
        
        if(ref.getParameters().get('metadataListId') != null){
            
            this.metadataListId = ref.getParameters().get('metadataListId');
            
            this.contentSelector = [SELECT Id, Name, Custom_Copy__c, Content_IDs__c FROM Content_Selector__c WHERE Id = :this.metadataListId LIMIT 1];
            
            if(this.contentSelector != null){
                this.metadataListName = this.contentSelector.Name;
                this.cpeActivities = filterBy(convertCommaDelimitedListToList(this.contentSelector.Content_IDs__c), limitTo, offset);
                this.groupedByActivityTypeList = getSelectedCpeActivitiesByIds(convertCommaDelimitedListToList(this.contentSelector.Content_IDs__c)); 
                this.selectedCpeActivities = flatten(groupedByActivityTypeList);                
            }
            
        }
        
        this.activityTypes = new List<SelectOption>();
        this.activityTypes.add(new SelectOption('', '- Please Select -'));
        Set<String> activityTypesUnqiue = new Set<String>();
        for(CPE_Activity_Type__c cpeat: [SELECT Id, Name FROM CPE_Activity_Type__c]){
            activityTypesUnqiue.add(cpeat.Name);
        }
        for(String activityType : activityTypesUnqiue){
            activityTypes.add(new SelectOption(activityType, activityType));
        }   
        
        this.areasOfStudy = new List<SelectOption>();
        this.areasOfStudy.add(new SelectOption('', '- Please Select -'));
        Schema.DescribeFieldResult fieldResult = CPE_Activity__c.Area_of_Study__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();     
        for(Schema.PicklistEntry f : ple){
            areasOfStudy.add(new SelectOption(f.getLabel(), f.getValue()));
        }             
        
        this.metadataLists = new List<SelectOption>();
        this.metadataLists.add(new SelectOption('', '- Please Select -'));
        for(Content_Selector__c cs: [SELECT Id, Name, Custom_Copy__c, Application_Reference__c, Content_IDs__c FROM Content_Selector__c WHERE Application_Reference__c = :this.applicationReference order by CreatedDate DESC]){
            this.metadataLists.add(new SelectOption(cs.Id, cs.Name));
        }
        
    }
    
}