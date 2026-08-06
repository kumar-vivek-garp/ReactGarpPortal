public class IntegrationsMtdUtil { 
   //Benchprep Configureation
	public static List<String> BPProductcodes = new List<String>{'SCRBP','RAIBP','RAIJBP','FRRSBP','FRRMC1BP','FRRMC2BP','FRRMC3BP','FRRMC4BP','FRMBP2'}; 
    //Used for Based on Exam Results Contract Status Change
	public static List<String> contractExamSeacionCodes = new List<String>{'FRRMC1','FRRMC2','FRRMC3','FRRMC4','FRR25'};
    public static Map<String,Pearson_Exam_Series_Configuration__mdt> getBySectionConfiguration(){
        Map<String,Pearson_Exam_Series_Configuration__mdt> configMap = new Map<String,Pearson_Exam_Series_Configuration__mdt>();
        for(Pearson_Exam_Series_Configuration__mdt mtd:[Select Id,Exam_Type__c,ExamLanguage__c,Program_Type_Name__c,Section__c,Exam_Series_Code__c From Pearson_Exam_Series_Configuration__mdt]){
            configMap.put(mtd.Section__c,mtd);
        } 
        return configMap;
    }
    public static Map<String,Pearson_Exam_Series_Configuration__mdt> getByExamTypeConfiguration(){
        Map<String,Pearson_Exam_Series_Configuration__mdt> configMap = new Map<String,Pearson_Exam_Series_Configuration__mdt>();
        for(Pearson_Exam_Series_Configuration__mdt mtd:[Select Id,Exam_Type__c,Program_Type_Name__c,Section__c,Exam_Series_Code__c From Pearson_Exam_Series_Configuration__mdt]){
            configMap.put(mtd.Exam_Type__c,mtd);
        } 
        return configMap;
    } 
    
    public static Map<String,Pearson_Exam_Series_Configuration__mdt> getByProgramTypeConfiguration(){
        Map<String,Pearson_Exam_Series_Configuration__mdt> configMap = new Map<String,Pearson_Exam_Series_Configuration__mdt>();
        for(Pearson_Exam_Series_Configuration__mdt mtd:[Select Id,Exam_Type__c,Program_Type_Name__c,Section__c,Exam_Series_Code__c From Pearson_Exam_Series_Configuration__mdt]){
            configMap.put(mtd.Program_Type_Name__c,mtd);
           Id rectypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(mtd.Program_Type_Name__c).getRecordTypeId();
            configMap.put(rectypeId,mtd);
        } 
        return configMap;
    }  
    
    public static Map<String,Pearson_Exam_Series_Configuration__mdt> getIsFRRSeriesProgramType(){ 
        Map<String,Pearson_Exam_Series_Configuration__mdt> configMap = new Map<String,Pearson_Exam_Series_Configuration__mdt>();
       for(Pearson_Exam_Series_Configuration__mdt mtd:[Select Id,Exam_Type__c,Program_Type_Name__c,Section__c,Event_Title__c,Area_of_Study__c,Exam_Series_Code__c From Pearson_Exam_Series_Configuration__mdt Where Is_FRR_Series__c = true]){
            Id rectypeId = Schema.SObjectType.Contract.getRecordTypeInfosByDeveloperName().get(mtd.Program_Type_Name__c).getRecordTypeId();
            configMap.put(rectypeId,mtd);
        } 
        return configMap;
    } 
    
}