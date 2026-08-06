@isTest
public class updateRapidCourseBatch_test {
    @TestSetup
    static void createTestData() {
        Integer totalCount = 1;
        datetime yesterday = Datetime.now().addDays(-1);
        
        List<Opportunity> OppResults =TestDataFactory.createOpportunity(totalCount);
        insert OppResults;
        
        List<Contact> ContactResults =TestDataFactory.createContacts(totalCount);
        for(Integer counter=0; counter < totalCount; counter++) {
            ContactResults[counter].AccountId = OppResults[counter].AccountId;
        }
        insert ContactResults;
        
        List<Contract> ContractResults = TestDataFactory.createContract(totalCount,OppResults,ContactResults);
        ContractResults[0].RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'ICBRR_Program');
        ContractResults[0].Member_Email__c = 'testcontract@test.com';
        ContractResults[0].ContractTerm = 12;
        ContractResults[0].Membership_type__C = 'Individual';
        ContractResults[0].KPI_Last_Updated__c = yesterday;
        insert ContractResults;
        
        ContractResults[0].Status = 'Activated';
        update ContractResults;
    }
	/*@isTest
    static void testUserUpdate(){
        test.startTest();
        database.executeBatch(new updateRapidCourseBatch());
        test.stopTest();
    } */
    
    @isTest
    static void testUserUpdate2(){
        
        String finalRapidCourseVal;
        List<RapidCourseJSON> courseList = new List<RapidCourseJSON>();
        RapidCourseJSON.input courses = new RapidCourseJSON.input();
        courses.course_id = 2560;
        courses.idempotency_key = 'garp-'+2560;
        
        RapidCourseJSON addCourse = new RapidCourseJSON();
        addCourse.automation_script_id = 311;
        addCourse.input = courses;
        courseList.add(addCourse);
        
        finalRapidCourseVal = JSON.serialize(courseList);
        
        Contract program = [Select Id,AccountId from Contract limit 1];
        
        
        test.startTest();
        User u = [Select Id from User where Contact.AccountId =: program.AccountId Limit 1];
        u.Rapid_Courses__c = finalRapidCourseVal;
        WKTRapidCourseJSONBuilder.updateUser(u,2737,'W1234');
        
        test.stopTest();
    }
}