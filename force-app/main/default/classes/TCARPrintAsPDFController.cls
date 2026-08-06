global without sharing class TCARPrintAsPDFController{
    private static final String SYS_DATE_FORMAT = 'MM/dd/yyyy h:mm a';
    global List<Training_Course_Reimbursement_Request__c> trrList {get; set;}
    global String HRApprovedDate {get; set;}
    global String DepartmentHeadApprovedDate {get; set;}
    global String CourseStartDate {get; set;}
    global String CourseCompletionDate {get; set;}
    global String ManagerApprovedDate {get; set;}
    global String CourseCompletedDate {get; set;}
    
    global TCARPrintAsPDFController(ApexPages.StandardController controller) {}
    
    global PageReference fetchData() {
        
        Id currentObjId = ApexPages.currentPage().getParameters().get('id');
       // String currentObjId = 'a5478000000L4goAAC'; // a5278000000E3sd    a5278000000H71p
        system.debug('currentObjId::>>   '+currentObjId);
        trrList = [SELECT Id,Employee_Name__r.Name,Acknowledgment__c,Chief_HR_Officer__c,Course_Amount__c,Course_Completion_Date__c,
                   Course_Description__c,Course_Name__c,Course_Start_Date__c,Department__c,Division_Head__c,Manager__c,Manager_Approved_Date__c,
                   Division_Head_Approval_Date__c,Employee_Expected_To_Return_Residence__c,Employee_Name__c,HR_Approved_Date__c,
                   Institution_City__c,Institution_State__c,Institution_Zip_Code__c,Job_Title__c,Name_of_Institution__c,Status__c,
                   Total_Amount__c,Travel_Lodging_Meals_Amount__c,Tuition_Acknowledgement__c,Employee_Location__c,Approval_Validity__c,
                   Division_Head_Name__c, Course_Completed_Date__c, Course_Completion_Acknowledgement__c
                   FROM Training_Course_Reimbursement_Request__c WHERE Id=:currentObjId];

        
        system.debug('trrList::>>   '+trrList);
        
        HRApprovedDate = trrList[0].HR_Approved_Date__c != null ? trrList[0].HR_Approved_Date__c.month() + '/' + trrList[0].HR_Approved_Date__c.day() + '/' + trrList[0].HR_Approved_Date__c.year(): '';
        DepartmentHeadApprovedDate = trrList[0].Division_Head_Approval_Date__c != null ? trrList[0].Division_Head_Approval_Date__c.month() + '/' + trrList[0].Division_Head_Approval_Date__c.day() + '/' + trrList[0].Division_Head_Approval_Date__c.year(): '';
        CourseStartDate = trrList[0].Course_Start_Date__c != null ? trrList[0].Course_Start_Date__c.month() + '/' + trrList[0].Course_Start_Date__c.day() + '/' + trrList[0].Course_Start_Date__c.year(): '';
        CourseCompletionDate = trrList[0].Course_Completion_Date__c != null ? trrList[0].Course_Completion_Date__c.month() + '/' + trrList[0].Course_Completion_Date__c.day() + '/' + trrList[0].Course_Completion_Date__c.year(): '';
        ManagerApprovedDate = trrList[0].Manager_Approved_Date__c != null ? trrList[0].Manager_Approved_Date__c.month() + '/' + trrList[0].Manager_Approved_Date__c.day() + '/' + trrList[0].Manager_Approved_Date__c.year(): '';
        CourseCompletedDate = trrList[0].Course_Completed_Date__c != null ? trrList[0].Course_Completed_Date__c.month() + '/' + trrList[0].Course_Completed_Date__c.day() + '/' + trrList[0].Course_Completed_Date__c.year(): '';
        
        return null;
    }
    
    global String getNow() {
        return System.now().format(SYS_DATE_FORMAT);
    }
}