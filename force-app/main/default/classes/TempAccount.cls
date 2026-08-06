public class TempAccount {
    
    public String formName { get; set; }
    
    public Boolean privacyPolicyAttestation { get; set; }
    public Boolean photographyPolicyAttestation { get; set; }
    public Boolean sponsorInformationExchangeAttestation { get; set; }
    public Boolean garpInformationExchangeAttestation { get; set; }
    
    public Boolean emailEventsSubscription { get; set; }
    public Boolean emailWebcastsSubscription { get; set; }
    public Boolean emailChapterMeetingsSubscription { get; set; }  
    public String emailSubscriptions { get; set; } 
    
    public class productDefinition {
        public string GLCode { get; set; }
        public string ProductCode { get; set; }        
        public string price { get; set; }  
        public string description { get; set; } 
        public string relatedId { get; set; } 
    }
   
    public string promoCode {get;set;}
    public list<String> promocodesUsed {get;set;}
    public string campaignId {get;set;}
    public boolean autoRenew {get;set;}
    public boolean jobTarget {get;set;} 
    public string facultyReference {get;set;}
    public string facultyReferenceEmail {get;set;}
    public string graduationDate {get;set;}
    public string ExamMaterials{get;set;}
    public string referral {get;set;}
    public boolean inSchool{get;set;}
    public boolean switchFeeEnabled{get;set;}
    public boolean isWorking{get;set;}
    public boolean enrollGarp{get;set;}
    public boolean isErpChecked{get;set;}
    public boolean isStudentChecked{get;set;}
    public boolean  idVerify {get;set;}
    public string Delivery{get;set;}
    public string OtherTitle{get;set;}
    public string TestLocation{get;set;}
    public string isBusiness{get;set;}
    public string id{get; set;}
    public string contactId{get; set;}
    public String Email {get;set;}
    public String HomePhone {get;set;}
    public String FirstName {get;set;}
    public String LastName {get;set;}
    public String AccountId {get;set;}
    public String idName {get;set;}
    public String idType {get;set;}
    public String idNumber{get;set;}    
    public String idLocation{get;set;}    
    
    public String idFirstName {get;set;}
    public String idMiddleName {get;set;}
    public String idLastName {get;set;}
    
    public String howDidYouHear   			{ get; set; } //Contact.How_Did_You_Hear_About_Us__c
    public String howDidYouHearOther   		{ get; set; } //Contact.How_Did_You_Hear_About_Us_Other__c
    public String Experience 				{ get; set; } //Contact.Experience__c
    public String Birthdate					{ get; set; } //Contact.Birthdate
    public String Gender					{ get; set; } //Contact.Gender__c
    public String ID_Expiration_Date 		{ get; set; } //Contact.ID_Expiration_Date__c
    public String Full_Name_in_Chinese 		{ get; set; } //Contact.Full_Name_in_Chinese__c    
    public String Alternate_Email_Address 	{ get; set; } //Event_Registration__r.Alternate_Email_Address__c
    
    public String MailingStreet {get;set;}
    public String MailingStreetTwo {get;set;}
    public String MailingStreetThree {get;set;}
    public String MailingCompany {get;set;}
    public String jobtitle {get;set;}
    public String MailingCity {get;set;}
    public String MailingCountry {get;set;}
    public String MailingCountryCode {get;set;}
    public String MaterialsOne{get;set;} 
    public String MaterialsTwo{get;set;}
    public String MailingPostalCode {get;set;}
    public string MailingStateForeign {get;set;}
    public String MailingState {get;set;}
    public String BillingStreet {get;set;}
    public String BillingStreetTwo {get;set;}
    public String BillingStreetThree {get;set;}    
    public String BillingCompany {get;set;}
    public String BillingCity {get;set;}
    public String BillingCountry {get;set;}
    public String BillingPostalCode {get;set;}
    public String BillingState {get;set;}
    public String BillingPhoneNumber {get;set;}
    public String Company {get;set;}
    public String EmailVerify {get;set;}
    public String JobFunction {get;set;}
    public String RiskSpecialty {get;set;}
    public String RiskManagementWorkingYear {get;set;}
    public String AttendanceMethod {get;set;}
    public String Industry {get;set;}
	public String IndustryWorkingYear {get;set;}    
    public String garpMembership_Type {get;set;}
    public String Membership_Type {get; set;}
    public Boolean MembershipEligible {get; set;}
    public String MiddleInitial {get;set;}
    public String MobilePhone {get;set;}
    public String MobilePhoneCode {get;set;}
    public String NickName {get;set;}
    public String Organization {get;set;}
    public String Salutation {get;set;}
    public String School {get;set;}
    public String Title {get;set;}
    public String Years_of_Experience {get;set;}
    public String Degree_Program_Name {get;set;}
    public String Expected_Graduation_Date { get; set; }
    public String sameShip {get;set;}
    public String promotion {get;set;}
    public String agreement {get;set;}
    public String timeStamp {get;set;}
    public String offers {get;set;}
    public String testNumber {get;set;}
    public String Wiley {get;set;}
    public String riskNet {get;set;}
    public String billingForeignState {get;set;}
    public String billingZipCode {get;set;}
    public list<String> productcode {get; set;}
    public list<productDefinition> productcode1 {get; set;}
    public String lstProdCodes {get; set;}
    public String billingAddress {get;set;}
    public String paymentMethod {get;set;}
    public String CreditCardNo {get;set;}
    public String CreditCardExp  {get;set;}
    public String CreditCardName  {get;set;}
    public String CvcCode  {get;set;}
    public boolean CFA {get; set;}
    public boolean returning {get; set;}
    public boolean CPA {get; set;}
    public boolean PMP {get; set;}
    public boolean ACCA {get; set;}
    public boolean CA {get; set;}
    public boolean CFP {get; set;}
    public boolean CIA {get; set;}
    public boolean CAIA {get; set;}
    public boolean CQF {get; set;}
    public boolean CMT {get; set;}
    public boolean CMA {get; set;}
    public boolean isFbrChecked {get; set;}
    public boolean isFbraChecked {get; set;}
    public boolean isIcbrChecked {get; set;}
    public boolean OtherDesignation {get; set;}
    public String examName {get; set;}
    public String examDate {get; set;}
    public String OtherDesignationText {get; set;}
    public String siteName {get; set;}
    public boolean isFrmChecked {get; set;}
    public String MailingStreet2 {get; set;}
    public String MailingStreet3 {get; set;}
    public String ShippingOptionsString {get; set;}
    public String ShippingOptions {get; set;}
    public Id siteId{get;set;}
    public boolean frmSwitch {get; set;}
    public boolean erpSwitch {get; set;}
    public decimal taxPrice{get;set;} 
    public boolean hasBooks {get; set;}
    public boolean infoExchange {get; set;}
    public boolean eppHelp {get; set;}
    public boolean icbrrLegacyRetry {get; set;}
    public boolean isEventChecked {get; set;}
    public boolean isWebcastChecked {get; set;}
    public string webcastId {get; set;}
    public string chapterMeetingId {get; set;}
    public string chapterMeetingRegistrationId {get; set;}
    public Id eventId{get; set;}
    public Id opportunityId{get; set;}
    public String sessionToken {get; set;}
    public String cta {get; set;}
    public String cap {get; set;}
    public String capip {get; set;}
    public String examAttemptId {get; set;}
    public String teamCode {get; set;}
    public String streetTownDetails {get; set;}
    public String nameOfRecipient {get; set;}
    public String provincesLevel {get; set;}
    public String phoneNumber {get; set;}
    public String city {get; set;}
    public String buildingVillageDetails {get; set;}
    public String mailingStateProvince {get; set;}
    public String homePhoneNumber {get; set;}
    public String mailingZipPostalCode {get; set;}
    public String districtCountry {get; set;}
}