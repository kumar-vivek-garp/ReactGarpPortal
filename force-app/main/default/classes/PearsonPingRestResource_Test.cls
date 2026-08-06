@istest
public class PearsonPingRestResource_Test {
    public static void createtestdate(){
        Account account = new Account(Name = 'test');
        insert account;
        Contact contact = new Contact(lastname = 'Test',AccountId = account.id,email='test@test.com',KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17));
        insert contact;
        Site__c site = new Site__c(name = 'test',Display_Address__c = 'test',active__c = true,Non_selectable__c = false);
        insert site; 
        
        Exam_Group__c objExamGrp = new Exam_Group__c();
        objExamGrp.Active__c = true;
        Date dt1 = system.today();
        objExamGrp.Registration_Start_Date__c = dt1.addDays(4);
        objExamGrp.Last_Date_For_Early_Registration__c = system.today()+1;
        objExamGrp.Last_Date_For_Standard_Registration__c = system.today() +9 ;
        objExamGrp.Last_Date_For_Late_Registration__c = system.today() +10 ;    
        insert objExamGrp;
        
        Exam__c exam = new Exam__c();
        exam.Exam_Group__c = objExamGrp.id;
        exam.Exam_Date__c = system.today() + 30;
        exam.exam__c = 'FRM Part 1'; 
        insert exam;
        
        Exam_Sites__c exmSite = new Exam_Sites__c(Site__c = site.id,exam__c = exam.id);
        insert exmSite;
        Opportunity opportunity = new Opportunity(amount = 123,Name = 'Test',company__c = 'Payment', accountId = account.id,stageName = 'Closed Won',Eligible_for_Membership_Extension__c = true,Program__c = 'Print' ,closedate = system.today()+ 15);        
        insert opportunity; 
        Contract contract  = new Contract(ContractTerm =2,startDate = system.today()- 5,Membership_Type__c = 'Individual',recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program'),Opportunity__c = opportunity.id,accountId = opportunity.AccountId); 
        insert contract;
        contract.Status ='Activated';
        Update contract;
        Exam_Attempt__c attempt = new Exam_Attempt__c(Opportunity__c = opportunity.id, Exam_Site__c = exmSite.id,Member__c = contact.id,cancelled__c = false,Candidate_Commitment__c = contract.id);
        insert attempt; 
        
        Pearson_Ping_Setting__c cs = new Pearson_Ping_Setting__c();
        cs.SetupOwnerId = UserInfo.getOrganizationId();
        cs.User_Name__c ='TestUserName';
        cs.Password__c = 'TestPassword';
        insert cs;
         
        Integration_Data__c intdate = new Integration_Data__c();
        intdate.Contract__c = contract.Id;
        intdate.Exam_Registrations__c = attempt.id;
        intdate.Version_Number__c = 1;
        intdate.Name ='test';
        intdate.Is_Active__c =true;
        intdate.Garp_Id__c ='01404258';
        intdate.Exam_Type__c = 'SCR';
        intdate.Pearson_Event_Type__c ='ExamDelivered';
        intdate.Pearson_Vue_Appointment_ID__c = '210378726';
        insert intdate;
    }
    static testMethod void doPostappointmentNotification(){
        createtestdate();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/api/pearsonvue/';       
        String postData = '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" soap:mustUnderstand="1"><wsse:UsernameToken wsu:Id="UsernameToken-90deb346-7ec0-4bbe-bea9-35c2ab7e0bcf"><wsse:Username>TestUserName</wsse:Username><wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">TestPassword</wsse:Password></wsse:UsernameToken></wsse:Security></soap:Header><soap:Body><sch:modifyAppointmentRequest xmlns:sch="http://ws.pearsonvue.com/rteAppointment/schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" clientCandidateID="01404258" clientCode="GARP" vueAppointmentID="210378726" vueCandidateID="204095551">'+
            '<eventType>ApptCreated</eventType>'+
            '<eventTime>2020-03-13T09:33:26.390-05:00</eventTime>'+
            '<eventNotificationID>192686</eventNotificationID>'+
            '<exams>'+
            '<exam>'+
            '<examSeriesCode>SCR</examSeriesCode>'+
            '<examLanguageCode>ENU</examLanguageCode>'+
            '<examName>GARP CTT Exam</examName>'+
            '<deliveryModel>Standard Test Center</deliveryModel>'+
            '<vueExamVersionId>27350</vueExamVersionId>'+
            '<clientExamVersionId>1.0</clientExamVersionId>'+
            '<vueExamRevisionId>1</vueExamRevisionId>'+
            '</exam>'+
            '</exams>'+
            '<appointmentStartDateTime>2020-03-14T04:00:00-05:00</appointmentStartDateTime>'+
            '<appointmentDuration>110</appointmentDuration>'+
            '<appointmentTimeExtension>0</appointmentTimeExtension>'+
            '<appointmentSource>VWEB</appointmentSource>'+
            '<appointmentDisplayTimeZone>America/New_York</appointmentDisplayTimeZone>'+
            '<appointmentDisplayTimeZoneUtcOffset>-0400</appointmentDisplayTimeZoneUtcOffset>'+
            '<appointmentDisplayTimeZoneSource>testCenter</appointmentDisplayTimeZoneSource>'+
            '<testCenter vueTestCenterID="44118">'+
            '<testCenterName>Testworld- Config 43 - Craig CTT</testCenterName>'+
            '<testCenterAddress>'+
            '<address1>1697 Broadway</address1><city>New York</city><state>NY</state>'+
            '<postalCode>10019</postalCode><country>USA</country><currentUtcOffset>-0400</currentUtcOffset><timeZoneName>America/New_York</timeZoneName>'+
            '</testCenterAddress>'+
            '</testCenter>'+
            '<accommodations></accommodations>'+
            '<authorization clientAuthorizationID="" vueAuthorizationID="2084084"/>'+
            '<vueOrderNo>0000-1037-0291</vueOrderNo>'+
            '<customFields></customFields>'+
            '</sch:modifyAppointmentRequest></soap:Body></soap:Envelope>'; 
        req.requestBody = Blob.valueof(postData);
        req.addHeader('Content-Type', 'application/xml');
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        PearsonPingRestResource.doPost();
        Test.stopTest();
    }
    
    
    static testMethod void doPostCancelNotification(){
        createtestdate();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/api/pearsonvue/';       
        String postData ='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<soap:Header><wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" soap:mustUnderstand="1">'+
            '<wsse:UsernameToken wsu:Id="UsernameToken-17f380f7-fcd6-4b97-a336-e771d8cdbc88">'+
            '<wsse:Username>TestUserName</wsse:Username>'+
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">TestPassword</wsse:Password>'+
            '</wsse:UsernameToken>'+
            '</wsse:Security>'+
            '</soap:Header>'+
            '<soap:Body>'+
            '<sch:cancelAppointmentRequest xmlns:sch="http://ws.pearsonvue.com/rteAppointment/schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" clientCode="GARP" vueAppointmentID="210378726">'+
            '<eventTime>2020-03-13T09:41:05.090-05:00</eventTime>'+
            '<eventNotificationID>192691</eventNotificationID>'+
            '</sch:cancelAppointmentRequest>'+
            '</soap:Body>'+
            '</soap:Envelope>'; 
        req.requestBody = Blob.valueof(postData);
        req.addHeader('Content-Type', 'application/xml');
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        PearsonPingRestResource.doPost();
        Test.stopTest();
    }
    
    static testMethod void doPostresultNotification(){
        createtestdate();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.addHeader('httpMethod', 'POST');
        req.requestUri = '/services/apexrest/api/pearsonvue/';       
        String postData ='<?xml version="1.0" encoding="UTF-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'+
            '<soap:Header>'+
            '<wsse:Security xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd" soap:mustUnderstand="1">'+
            '<wsse:UsernameToken wsu:Id="UsernameToken-17f380f7-fcd6-4b97-a336-e771d8cdbc88">'+
            '<wsse:Username>TestUserName</wsse:Username>'+
            '<wsse:Password Type="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-username-token-profile-1.0#PasswordText">TestPassword</wsse:Password></wsse:UsernameToken>'+
            '</wsse:Security></soap:Header>'+
            '<soap:Body>'+
            '<sch:resultNotificationRequest xmlns:sch = "http://ws.pearsonvue.com/rteResult/schema" vueAppointmentID="210378909" vueCandidateID="204079268" clientCandidateID="01404258" clientCode="GARP">'+
            '<eventType>ResultAvailable</eventType>'+
            '<eventTime>2020-03-16T10:35:49.463-05:00</eventTime><eventNotificationID>193039</eventNotificationID>'+
            '<attempt>1</attempt><exams><exam ><examDefinition>'+
            '<examSeriesCode>SCR</examSeriesCode>'+
            '<examLanguageCode>ENU</examLanguageCode>'+
            '<examName>SCR</examName>'+
            '<deliveryModel>Standard Test Center</deliveryModel>'+
            '<vueExamVersionId>24470</vueExamVersionId>'+
            '<vueExamRevisionID>1</vueExamRevisionID>'+
            '<clientExamVersionId>1</clientExamVersionId>'+
            '<examForm>A</examForm>'+
            '<isBetaVersion>false</isBetaVersion>'+
            '</examDefinition>'+
            '<examResult>'+
            '<outcomeType>original</outcomeType><startTime>2020-03-16T09:23:02-05:00</startTime>'+
            '<timeUsed>252000</timeUsed><passingScore>54</passingScore><score>25</score>'+
            '<rawScore>25</rawScore><grade>Fail</grade><correct>25</correct>'+
            '<incorrect>54</incorrect><skipped>1</skipped><unscored>0</unscored>'+
            '<variables><variable><name>RAWSCORE.MAX</name><value>80</value>'+
            '</variable><variable><name>RAWSCORE.MIN</name><value>0</value>'+
            '</variable><variable><name>RAWSCORE.NORMALIZED</name><value>0.3125</value>'+
            '</variable><variable><name>SCORE.SCALE_MAX</name><value>80</value>'+
            '</variable><variable><name>SCORE.SCALE_MIN</name><value>0</value></variable>'+
            '</variables><reportingGroups><reportingGroup><id >MR-1</id>'+
            '<variables><variable><name>score</name><value>25</value>'+
            '</variable><variable><name>rawscore.normalized</name><value>0.25</value>'+
            '</variable><variable><name>rawscore</name><value>5</value></variable>'+
            '<variable><name>rawscore.min</name><value>0</value></variable>'+
            '<variable><name>rawscore.max</name><value>20</value></variable>'+
            '<variable><name>passingscore</name><value>67</value></variable>'+
            '<variable><name>score.scale_min</name><value>0</value></variable>'+
            '<variable><name>grade</name><value>fail</value></variable>'+
            '<variable><name>score.scale_max</name><value>100</value></variable>'+
            '</variables></reportingGroup><reportingGroup>'+
            '<id >CR-2</id><variables><variable><name>score</name>'+
            '<value>35</value> </variable> <variable> <name>rawscore.normalized</name>'+
            '<value>0.35</value> </variable> <variable><name>rawscore</name>'+
            '<value>7</value></variable><variable><name>rawscore.min</name>'+
            '<value>0</value></variable><variable><name>rawscore.max</name>'+
            '<value>20</value></variable><variable><name>passingscore</name>'+
            '<value>67</value></variable><variable>'+
            '<name>score.scale_min</name><value>0</value></variable>'+
            '<variable><name>grade</name><value>fail</value></variable><variable>'+
            '<name>score.scale_max</name><value>100</value></variable></variables>'+
            '</reportingGroup><reportingGroup><id >ALM-3</id>'+
            '<variables><variable><name>score</name><value>35</value>'+
            '</variable><variable><name>rawscore.normalized</name>'+
            '<value>0.35</value></variable><variable><name>rawscore</name>'+
            '<value>7</value></variable><variable><name>rawscore.min</name>'+
            '<value>0</value></variable><variable><name>rawscore.max</name>'+
            '<value>20</value></variable><variable><name>passingscore</name>'+
            '<value>67</value></variable><variable><name>score.scale_min</name>'+
            '<value>0</value></variable><variable><name>grade</name><value>fail</value>'+
            '</variable><variable><name>score.scale_max</name><value>100</value>'+
            '</variable></variables></reportingGroup><reportingGroup><id >OPR-4</id>'+
            '<variables><variable><name>score</name><value>30</value></variable><variable>'+
            '<name>rawscore.normalized</name><value>0.3</value></variable>'+
            '<variable><name>rawscore</name><value>6</value></variable>'+
            '<variable><name>rawscore.min</name><value>0</value></variable>'+
            '<variable><name>rawscore.max</name><value>20</value></variable>'+
            '<variable><name>passingscore</name><value>67</value></variable><variable>'+
            '<name>score.scale_min</name><value>0</value>'+
            '</variable><variable><name>grade</name><value>fail</value>'+
            '</variable><variable><name>score.scale_max</name><value>100</value>'+
            '</variable></variables></reportingGroup></reportingGroups></examResult>'+
            '<noShow>false</noShow>'+
            '<expired>false</expired><ndaRefused>false</ndaRefused></exam></exams>'+
            '<testCenter vueTestCenterID="200050265"><testCenterName>zTest Lab - Config 214 - Brian Hodges</testCenterName>'+
            '<testCenterAddress><address1>720 South Colorado Blvd</address1><city>Denver</city>'+
            '<state>CO</state><postalCode>80222</postalCode><country>USA</country>'+
            '<currentUtcOffset>-0600</currentUtcOffset>'+
            '<timeZoneName>America/Denver</timeZoneName>'+
            '</testCenterAddress></testCenter>'+
            '<accommodations></accommodations>'+
            '<authorization vueAuthorizationID="2051593" clientAuthorizationID="2182732"></authorization>'+
            '<vueOrderNo>0000-1037-3810</vueOrderNo><customFields>'+
            '</customFields><proctor-id>200694382</proctor-id>'+
            '</sch:resultNotificationRequest></soap:Body></soap:Envelope>'; 
        req.requestBody = Blob.valueof(postData);
        req.addHeader('Content-Type', 'application/xml');
        RestContext.request = req; 
        RestContext.response= res;
        Test.startTest();
        PearsonPingRestResource.doPost();
        Test.stopTest();
    }
}