public class BenchPrepClass {
	public class benchPrepAttr{
        public string course_slug;
        public string expiration_date;
        public List<eventAttr> unlock_events;
    }
    
    public class eventAttr{
        public string event_slug;
        public string external_id;
    }
    
    public static Map<String,BenchPrep_Config__mdt> getBenchPrepConfig() {
        GARP_Common.debugLog('BenchPrepClass','getBenchPrepConfig','getBenchPrepConfig',NULL);
        
        Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
        GARP_Common.debugLog('BenchPrepClass','getBenchPrepConfig','courseMap',courseMap);
        
        Map<String,BenchPrep_Config__mdt> retMapBPConfig = new Map<String,BenchPrep_Config__mdt>();
        for(BenchPrep_Config__mdt bpmd :courseMap.Values()) {
            String key;
            if(bpmd.Type__c == 'Program Benchprep') {
            	key = bpmd.Program__c + ':' + bpmd.Program_Part__c;
            } else {
                key = bpmd.MasterLabel;
            }
            retMapBPConfig.put(key, bpmd);
        }
        GARP_Common.debugLog('BenchPrepClass','getBenchPrepConfig','retMapBPConfig',retMapBPConfig);
        return retMapBPConfig;
    }
    
    public static Map<String,benchPrepAttr> removeAccess(User u,Set<String> prodCodes){
        Map<String,benchPrepAttr> courseList = new Map<String,benchPrepAttr>();
        if(String.isNotBlank(u.Bench_Prep_SSO_Attribute__c)){
            List<benchPrepAttr> attrList = (List<benchPrepAttr>)JSON.deserialize(u.Bench_Prep_SSO_Attribute__c,List<benchPrepAttr>.class);
            for(benchPrepAttr attr : attrList){
                courseList.put(attr.course_slug,attr);
            }
        }
        
        Map<String,BenchPrep_Config__mdt> courseMap = BenchPrep_Config__mdt.getAll();
        for(string prodCode : prodCodes){
            BenchPrep_Config__mdt course = courseMap.containskey(prodCode) ? courseMap.get(prodCode) : null;
            if(course != null){
                if(courseList.containskey(course.Course_Slug__c)){
                    //system.debug('Check here');
                    courseList.remove(course.Course_Slug__c);
                }else if(String.isnotblank(course.Parent_Product_Code__c) && courseList.containskey(courseMap.get(course.Parent_Product_Code__c).course_slug__c)){
                    //system.debug('Check here 2');
                    benchPrepAttr attr = courseList.get(courseMap.get(course.Parent_Product_Code__c).course_slug__c);
                    attr.unlock_events = null;
                    courseList.put(courseMap.get(course.Parent_Product_Code__c).course_slug__c,attr);
                }
            }
        }
        return courseList;
    }
}