@isTest
public class searchDirectory_Test {
    
    static User user1;
    static Profile profile;
    
    static void testData() {
        
        Account account = new Account(Name = 'test');
        INSERT account;
        
        List<Contact> contacts = new List<Contact>();
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = true,
            GARP_Dir_Privacy_Job_Information__c = true,
            GARP_Dir_Privacy_Prof_Background__c = false,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTONE',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = true,
            GARP_Dir_Privacy_Job_Information__c = false,
            GARP_Dir_Privacy_Prof_Background__c = true,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTTWO',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        contacts.add(new Contact(
            GARP_Dir_Privacy_Additional_Detail__c = false,
            GARP_Dir_Privacy_Job_Information__c = true,
            GARP_Dir_Privacy_Prof_Background__c = true,
            KPI_ERP_Certified__c = true,
            Corporate_Title__c='garp',
            KPI_FRM_Certified__c = true,
            GARP_Directory_Opt_In__c = true,
            lastname = 'CONTACTTHREE',
            AccountId = account.id,
            email='daghtes12t@test.com',
            KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
            Name_As_it_Appears_On_ID__c = 'testtest',
            ID_Number__c = 'dasf123l',
            ID_Type__c = 'Passport',
            Area_of_Concentration__c = 'Individual',
            Professional_Designation_CA__c = true,
            Professional_Designation_CFA__c = true,
            Professional_Designation_CMA__c = true,
            Professional_Designation_CPA__c = true,
            Professional_Designation_Other__c = true,
            Professional_Designation_PMP__c = true,
            Professional_Designation_ACCA__c = true,
            KPI_CPE_Current_Cycle__c = 'test',
            KPI_CPE_Last_Completed_Cycle__c = 'test',
            KPI_CPE_Requirement_Status__c = 'test'
        ));
        
        /*
        for(Integer i = 0; i < 200; i++){
            contacts.add(new Contact(
                GARP_Dir_Privacy_Additional_Detail__c = false,
                GARP_Dir_Privacy_Job_Information__c = true,
                GARP_Dir_Privacy_Prof_Background__c = true,
                KPI_ERP_Certified__c = true,
                Corporate_Title__c='garp',
                KPI_FRM_Certified__c = true,
                GARP_Directory_Opt_In__c = true,
                lastname = 'OTHER',
                AccountId = account.id,
                email='daghtes12t@test.com',
                KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17),
                Name_As_it_Appears_On_ID__c = 'testtest',
                ID_Number__c = 'dasf123l',
                ID_Type__c = 'Passport',
                Area_of_Concentration__c = 'test',
                Professional_Designation_CA__c = true,
                Professional_Designation_CFA__c = true,
                Professional_Designation_CMA__c = true,
                Professional_Designation_CPA__c = true,
                Professional_Designation_Other__c = true,
                Professional_Designation_PMP__c = true,
                Professional_Designation_ACCA__c = true,
                KPI_CPE_Current_Cycle__c = 'test',
                KPI_CPE_Last_Completed_Cycle__c = 'test',
                KPI_CPE_Requirement_Status__c = 'test'
            )); 
        }
        */
        
        INSERT contacts;
        
        profile = [SELECT Id FROM Profile WHERE usertype = 'CspLitePortal' limit 1]; 

    }  
    
    
    static testMethod void unitTest_6(){
        
        testData();
        test.startTest();

        /**
         * @params
         * String searchText 
         * String searchType 
         * String industries 
         * String jobFunctions
         * String corporateTitles
         * String company
         * String sortField
         * String sortOrder
         * Integer pageSize
         * Integer pageCurrent
         */
        
        SearchDirectory.searchcontacts(FALSE,FALSE,FALSE,'CONTACT', '', '','', '', '', 'lastname', 'DESC', 1, 1);

        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTONE', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'CONTACTTWO', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTTHREE', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'OTHER', '', '','Credit Risk', '', '', 'lastname', 'DESC', 10, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'UNKNOWN', '', '','Credit Risk', '', '', 'lastname', 'DESC', 1, 1);
        /*
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'CONTACTONE', 'Other', '','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTTWO', 'Other', '','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'CONTACTTHREE', 'Other', '','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'OTHER', 'Other', '','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 10, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,TRUE,'UNKNOWN', 'Other', '','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTONE', 'Other', 'Random','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'CONTACTTWO', 'Other', 'Random','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTTHREE', 'Other', 'Random','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'OTHER', 'Other', 'Random','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 10, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'UNKNOWN','Other', 'Random','Credit Risk', '', 'Bank of America', 'lastname', 'DESC', 1, 1);
        
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTONE','Other', 'Random', 'Credit Risk','Random', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'CONTACTTWO','Other', 'Random','Credit Risk', 'Random', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'CONTACTTHREE','Other', 'Random','Credit Risk', 'Random', 'Bank of America', 'lastname', 'DESC', 1, 1);
        SearchDirectory.searchcontacts(TRUE,FALSE,FALSE,'OTHER','Other', 'Random','Credit Risk', 'Random', 'Bank of America', 'lastname', 'DESC', 10, 1);
        SearchDirectory.searchcontacts(TRUE,TRUE,FALSE,'UNKNOWN','Other', 'Random','Credit Risk', 'Random', 'Bank of America', 'lastname', 'DESC', 1, 1);
*/
        test.stopTest();  
        
    }
    
}