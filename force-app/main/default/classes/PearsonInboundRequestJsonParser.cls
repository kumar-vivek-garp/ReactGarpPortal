public class PearsonInboundRequestJsonParser {

    public Envelope Envelope {get;set;} 

    public PearsonInboundRequestJsonParser(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'Envelope') {
                        Envelope = new Envelope(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'JSON2Apex consuming unrecognized property: '+text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }
    
    public class UsernameToken {
        public String Username {get;set;} 
        public Password Password {get;set;} 
        public String Id {get;set;} 

        public UsernameToken(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Username') {
                            Username = parser.getText();
                        } else if (text == 'Password') {
                            Password = new Password(parser);
                        } else if (text == 'Id') {
                            Id = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'UsernameToken consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Security {
        public UsernameToken UsernameToken {get;set;} 
        public String mustUnderstand {get;set;} 

        public Security(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'UsernameToken') {
                            UsernameToken = new UsernameToken(parser);
                        } else if (text == 'mustUnderstand') {
                            mustUnderstand = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Security consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Envelope {
        public Header Header {get;set;} 
        public Body Body {get;set;} 

        public Envelope(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Header') {
                            Header = new Header(parser);
                        } else if (text == 'Body') {
                            Body = new Body(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Envelope consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TestCenter {
        public String testCenterName {get;set;} 
        public TestCenterAddress testCenterAddress {get;set;} 
        public String vueTestCenterID {get;set;} 

        public TestCenter(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'testCenterName') {
                            testCenterName = parser.getText();
                        } else if (text == 'testCenterAddress') {
                            testCenterAddress = new TestCenterAddress(parser);
                        } else if (text == 'vueTestCenterID') {
                            vueTestCenterID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'TestCenter consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Exams {
        public Exam exam {get;set;} 

        public Exams(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'exam') {
                            exam = new Exam(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Exams consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Authorization {
        public String clientAuthorizationID {get;set;} 
        public String vueAuthorizationID {get;set;} 

        public Authorization(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'clientAuthorizationID') {
                            clientAuthorizationID = parser.getText();
                        } else if (text == 'vueAuthorizationID') {
                            vueAuthorizationID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Authorization consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class TestCenterAddress {
        public String address1 {get;set;} 
        public String address2 {get;set;}
        public String city {get;set;} 
        public String state {get;set;} 
        public String postalCode {get;set;} 
        public String country {get;set;} 
        public String currentUtcOffset {get;set;} 
        public String timeZoneName {get;set;} 

        public TestCenterAddress(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'address1') {
                            address1 = parser.getText();
                        } else if (text == 'address2') {
                            address2 = parser.getText();
                        }else if (text == 'city') {
                            city = parser.getText();
                        } else if (text == 'state') {
                            state = parser.getText();
                        } else if (text == 'postalCode') {
                            postalCode = parser.getText();
                        } else if (text == 'country') {
                            country = parser.getText();
                        } else if (text == 'currentUtcOffset') {
                            currentUtcOffset = parser.getText();
                        } else if (text == 'timeZoneName') {
                            timeZoneName = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'TestCenterAddress consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ModifyAppointmentRequest {
        public String eventType {get;set;} 
        public String eventTime {get;set;} 
        public String eventNotificationID {get;set;} 
        public Exams exams {get;set;} 
        public String appointmentStartDateTime {get;set;} 
        public String appointmentDuration {get;set;} 
        public String appointmentTimeExtension {get;set;} 
        public String appointmentSource {get;set;} 
        public String appointmentDisplayTimeZone {get;set;} 
        public String appointmentDisplayTimeZoneUtcOffset {get;set;} 
        public String appointmentDisplayTimeZoneSource {get;set;} 
        public TestCenter testCenter {get;set;} 
        public Authorization authorization {get;set;} 
        public String vueOrderNo {get;set;} 
        public String clientCandidateID {get;set;} 
        public String clientCode {get;set;} 
        public String vueAppointmentID {get;set;} 
        public String vueCandidateID {get;set;} 

        public ModifyAppointmentRequest(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'eventType') {
                            eventType = parser.getText();
                        } else if (text == 'eventTime') {
                            eventTime = parser.getText();
                        } else if (text == 'eventNotificationID') {
                            eventNotificationID = parser.getText();
                        } else if (text == 'exams') {
                            exams = new Exams(parser);
                        } else if (text == 'appointmentStartDateTime') {
                            appointmentStartDateTime = parser.getText();
                        } else if (text == 'appointmentDuration') {
                            appointmentDuration = parser.getText();
                        } else if (text == 'appointmentTimeExtension') {
                            appointmentTimeExtension = parser.getText();
                        } else if (text == 'appointmentSource') {
                            appointmentSource = parser.getText();
                        } else if (text == 'appointmentDisplayTimeZone') {
                            appointmentDisplayTimeZone = parser.getText();
                        } else if (text == 'appointmentDisplayTimeZoneUtcOffset') {
                            appointmentDisplayTimeZoneUtcOffset = parser.getText();
                        } else if (text == 'appointmentDisplayTimeZoneSource') {
                            appointmentDisplayTimeZoneSource = parser.getText();
                        } else if (text == 'testCenter') {
                            testCenter = new TestCenter(parser);
                        } else if (text == 'authorization') {
                            authorization = new Authorization(parser);
                        } else if (text == 'vueOrderNo') {
                            vueOrderNo = parser.getText();
                        } else if (text == 'clientCandidateID') {
                            clientCandidateID = parser.getText();
                        } else if (text == 'clientCode') {
                            clientCode = parser.getText();
                        } else if (text == 'vueAppointmentID') {
                            vueAppointmentID = parser.getText();
                        } else if (text == 'vueCandidateID') {
                            vueCandidateID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ModifyAppointmentRequest consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Header {
        public Security Security {get;set;} 

        public Header(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Security') {
                            Security = new Security(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Header consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Body {
        public ModifyAppointmentRequest modifyAppointmentRequest {get;set;} 
        public CancelAppointmentRequest cancelAppointmentRequest {get;set;} 
        public ResultNotificationRequest resultNotificationRequest {get;set;} 
        public Body(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'modifyAppointmentRequest') {
                            modifyAppointmentRequest = new ModifyAppointmentRequest(parser);
                        }else if (text == 'cancelAppointmentRequest') {
                            cancelAppointmentRequest = new CancelAppointmentRequest(parser);
                        }else if (text == 'resultNotificationRequest') {
                            resultNotificationRequest = new ResultNotificationRequest(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Body consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ResultNotificationRequest {
        public String eventType {get;set;} 
        public String eventTime {get;set;} 
        public String eventNotificationID {get;set;} 
        public String attempt {get;set;} 
        public Exams exams {get;set;} 
        public TestCenter testCenter {get;set;} 
        public Authorization authorization {get;set;} 
        public String vueOrderNo {get;set;} 
        public String proctor_id {get;set;} // in json: proctor-id
        public String vueAppointmentID {get;set;} 
        public String vueCandidateID {get;set;} 
        public String clientCandidateID {get;set;} 
        public String clientCode {get;set;} 

        public ResultNotificationRequest(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'eventType') {
                            eventType = parser.getText();
                        } else if (text == 'eventTime') {
                            eventTime = parser.getText();
                        } else if (text == 'eventNotificationID') {
                            eventNotificationID = parser.getText();
                        } else if (text == 'attempt') {
                            attempt = parser.getText();
                        } else if (text == 'exams') {
                            exams = new Exams(parser);
                        } else if (text == 'testCenter') {
                            testCenter = new TestCenter(parser);
                        } else if (text == 'authorization') {
                            authorization = new Authorization(parser);
                        } else if (text == 'vueOrderNo') {
                            vueOrderNo = parser.getText();
                        } else if (text == 'proctor-id') {
                            proctor_id = parser.getText();
                        } else if (text == 'vueAppointmentID') {
                            vueAppointmentID = parser.getText();
                        } else if (text == 'vueCandidateID') {
                            vueCandidateID = parser.getText();
                        } else if (text == 'clientCandidateID') {
                            clientCandidateID = parser.getText();
                        } else if (text == 'clientCode') {
                            clientCode = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ResultNotificationRequest consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class CancelAppointmentRequest {
        public String eventTime {get;set;} 
        public String eventNotificationID {get;set;} 
        public String clientCode {get;set;} 
        public String vueAppointmentID {get;set;} 

        public CancelAppointmentRequest(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'eventTime') {
                            eventTime = parser.getText();
                        } else if (text == 'eventNotificationID') {
                            eventNotificationID = parser.getText();
                        } else if (text == 'clientCode') {
                            clientCode = parser.getText();
                        } else if (text == 'vueAppointmentID') {
                            vueAppointmentID = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'CancelAppointmentRequest consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Exam {
        public String examSeriesCode {get;set;} 
        public String examLanguageCode {get;set;} 
        public String examName {get;set;} 
        public String deliveryModel {get;set;} 
        public String vueExamVersionId {get;set;} 
        public String clientExamVersionId {get;set;} 
        public String vueExamRevisionId {get;set;} 
        public ExamDefinition examDefinition {get;set;}
        public ExamResult examResult {get;set;} 
        public String noShow {get;set;}
        public String deliveryMode {get;set;} 
        public String expired {get;set;} 
        public String ndaRefused {get;set;}         
        public Exam(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'examDefinition') {
                            examDefinition = new ExamDefinition(parser);
                        } else if (text == 'deliveryMode') {
                            deliveryMode = parser.getText();
                        }else if (text == 'examSeriesCode') {
                            examSeriesCode = parser.getText();
                        } else if (text == 'examLanguageCode') {
                            examLanguageCode = parser.getText();
                        } else if (text == 'examName') {
                            examName = parser.getText();
                        } else if (text == 'deliveryModel') {
                            deliveryModel = parser.getText();
                        } else if (text == 'vueExamVersionId') {
                            vueExamVersionId = parser.getText();
                        } else if (text == 'clientExamVersionId') {
                            clientExamVersionId = parser.getText();
                        } else if (text == 'vueExamRevisionId') {
                            vueExamRevisionId = parser.getText();
                        } else if (text == 'examResult') {
                            examResult = new ExamResult(parser);
                        } else if (text == 'noShow') {
                            noShow = parser.getText();
                        } else if (text == 'expired') {
                            expired = parser.getText();
                        } else if (text == 'ndaRefused') {
                            ndaRefused = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Exam consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ExamDefinition {
        public String examSeriesCode {get;set;} 
        public String examLanguageCode {get;set;} 
        public String examName {get;set;} 
        public String deliveryModel {get;set;} 
        public String vueExamVersionId {get;set;} 
        public String vueExamRevisionID {get;set;} 
        public String clientExamVersionId {get;set;} 
        public String examForm {get;set;} 
        public String isBetaVersion {get;set;} 

        public ExamDefinition(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'examSeriesCode') {
                            examSeriesCode = parser.getText();
                        } else if (text == 'examLanguageCode') {
                            examLanguageCode = parser.getText();
                        } else if (text == 'examName') {
                            examName = parser.getText();
                        } else if (text == 'deliveryModel') {
                            deliveryModel = parser.getText();
                        } else if (text == 'vueExamVersionId') {
                            vueExamVersionId = parser.getText();
                        } else if (text == 'vueExamRevisionID') {
                            vueExamRevisionID = parser.getText();
                        } else if (text == 'clientExamVersionId') {
                            clientExamVersionId = parser.getText();
                        } else if (text == 'examForm') {
                            examForm = parser.getText();
                        } else if (text == 'isBetaVersion') {
                            isBetaVersion = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'ExamDefinition consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ExamResult {
        public String outcomeType {get;set;} 
        public String startTime {get;set;} 
        public String timeUsed {get;set;} 
        public String passingScore {get;set;} 
        public String score {get;set;} 
        public String rawScore {get;set;} 
        public String grade {get;set;} 
        public String correct {get;set;} 
        public String incorrect {get;set;} 
        public String skipped {get;set;} 
        public String unscored {get;set;} 
        public List<Variables> variables {get;set;} 
        public List<ReportingGroups> reportingGroups {get;set;} 

        public ExamResult(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'outcomeType') {
                            outcomeType = parser.getText();
                        } else if (text == 'startTime') {
                            startTime = parser.getText();
                        } else if (text == 'timeUsed') {
                            timeUsed = parser.getText();
                        } else if (text == 'passingScore') {
                            passingScore = parser.getText();
                        } else if (text == 'score') {
                            score = parser.getText();
                        } else if (text == 'rawScore') {
                            rawScore = parser.getText();
                        } else if (text == 'grade') {
                            grade = parser.getText();
                        } else if (text == 'correct') {
                            correct = parser.getText();
                        } else if (text == 'incorrect') {
                            incorrect = parser.getText();
                        } else if (text == 'skipped') {
                            skipped = parser.getText();
                        } else if (text == 'unscored') {
                            unscored = parser.getText();
                        } else if (text == 'variables') {
                            variables = arrayOfVariables(parser);
                        } else if (text == 'reportingGroups') {
                            reportingGroups = arrayOfReportingGroups(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ExamResult consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class ReportingGroups {
        public String id {get;set;} 
        public List<Variables> variables {get;set;} 

        public ReportingGroups(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'id') {
                            id = parser.getText();
                        } else if (text == 'variables') {
                            variables = arrayOfVariables(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ReportingGroups consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Variables {
        public String name {get;set;} 
        public String value {get;set;} 

        public Variables(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'value') {
                            value = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Variables consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    public class Password {
        public String Type_Z {get;set;} // in json: Type
        public String ele_text {get;set;} 

        public Password(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'Type') {
                            Type_Z = parser.getText();
                        } else if (text == 'ele_text') {
                            ele_text = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Password consuming unrecognized property: '+text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }
    
    
    public static PearsonInboundRequestJsonParser parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new PearsonInboundRequestJsonParser(parser);
    }
    
     private static List<ReportingGroups> arrayOfReportingGroups(System.JSONParser p) {
        List<ReportingGroups> res = new List<ReportingGroups>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new ReportingGroups(p));
        }
        return res;
    }
    
     private static List<Variables> arrayOfVariables(System.JSONParser p) {
        List<Variables> res = new List<Variables>();
        if (p.getCurrentToken() == null) p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Variables(p));
        }
        return res;
    }


    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || 
                curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT ||
                curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    } 
}