public class GARP_BC_ExamStudyMaterials {

    // Verify Access and Return SSO Link
    public static String getSCRBenchPrepSSOLink(String contactId) {
        List<eBook_Key__c> ebookKeys = [select Id from eBook_Key__c 
                                        where Type__c = 'BenchPrep' AND
                                        Status__c = 'Taken' AND
                                        Access_Expiration_Date__c >= TODAY];
        if(!ebookKeys.isEmpty()) {
            return Label.BenchBrepSSOLink;
        }
        return null;
    }
}