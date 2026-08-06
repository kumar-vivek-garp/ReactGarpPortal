global without sharing class TRRPrintAsPDFController{
    private static final String SYS_DATE_FORMAT = 'MM/dd/yyyy h:mm a';
    global List<Tuition_Reimbursement_Request__c> trrList {get; set;}
    global String TermStartDate {get; set;}
    global String TermEndDate {get; set;}
    global String HRApprovedDate {get; set;}
    global String JobStartDate {get; set;}
    global String DepartmentHeadApprovedDate {get; set;}
    global String ManagerApprovedDate {get; set;}
    
    global TRRPrintAsPDFController(ApexPages.StandardController controller) {}
    
    global PageReference fetchData() {
        
        Id currentObjId = ApexPages.currentPage().getParameters().get('id');
       // String currentObjId = 'a5278000000E3sd'; // a5278000000E3sd    a5278000000H71p
        trrList = [SELECT Id,Employee_Name__r.Name,Job_Title__c,Department__c,Academic_Calendar__c,Term__c,Term_Start_Date__c,Term_End_Date__c,
                   Name_of_Institution__c,Institution_City__c,Institution_State__c,Institution_Zip_Code__c,Division_Head_Name__r.Name,
                   Job_Start_Date__c,Am_I_Receiving_Financial_Aid__c,Degree_Tier__c,Course_Timing__c,Brief_Job_Description__c,Status__c,
                   Are_Courses_Required_For_Job__c,Do_Courses_Qualify_for_Trade_Business__c,Department_Head_Approved_Date__c, Manager__c,
                   Chief_HR_Officer_Approval__c,Division_Head_Approval__c,Education_Required_to_keep_salary_job__c,Maintain_Improve_Skills_for_job__c,
                   Tuition_Acknowledgement__c,Taxation_Acknowledgement__c, Information_Subject_to_Tax__c,HR_Approved_Date__c,Employee_Location__c,Approval_Validity__c,Manager_Approved_Date__c,
                   (SELECT Id,Name,Fees__c,Units__c,Course_Number__c,Course_Completed_Date__c,Course_Completion_Acknowledgement__c  FROM Tuition_reimbursement_Courses__r)
                   FROM Tuition_Reimbursement_Request__c WHERE Id=:currentObjId];

        TermStartDate = trrList[0].Term_Start_Date__c != null ? trrList[0].Term_Start_Date__c.month() + '/' + trrList[0].Term_Start_Date__c.day() + '/' + trrList[0].Term_Start_Date__c.year(): '';
        TermEndDate = trrList[0].Term_End_Date__c != null ? trrList[0].Term_End_Date__c.month() + '/' + trrList[0].Term_End_Date__c.day() + '/' + trrList[0].Term_End_Date__c.year(): '';
        HRApprovedDate = trrList[0].HR_Approved_Date__c != null ? trrList[0].HR_Approved_Date__c.month() + '/' + trrList[0].HR_Approved_Date__c.day() + '/' + trrList[0].HR_Approved_Date__c.year(): '';
        DepartmentHeadApprovedDate = trrList[0].Department_Head_Approved_Date__c != null ? trrList[0].Department_Head_Approved_Date__c.month() + '/' + trrList[0].Department_Head_Approved_Date__c.day() + '/' + trrList[0].Department_Head_Approved_Date__c.year(): '';
        JobStartDate = trrList[0].Job_Start_Date__c != null ? trrList[0].Job_Start_Date__c.month() + '/' + trrList[0].Job_Start_Date__c.day() + '/' + trrList[0].Job_Start_Date__c.year(): '';
        ManagerApprovedDate = trrList[0].Manager_Approved_Date__c != null ? trrList[0].Manager_Approved_Date__c.month() + '/' + trrList[0].Manager_Approved_Date__c.day() + '/' + trrList[0].Manager_Approved_Date__c.year(): '';
        
        return null;
    }
    
    global String getNow() {
        return System.now().format(SYS_DATE_FORMAT);
    }
}