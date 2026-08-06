@isTest
public class TestDataFactory {
    public static Boolean oneActive = True;
    
    public static List<Account> createAccounts(Integer numRecords) {
        List<Account> results = new List<Account>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            String randomString = String.valueof(randomNumber);
            Account record = new Account();
            record.Name = 'Test Account '+counter+randomString;
            //record.GARP_ID__c='1845'+counter+randomString;
            record.Member_Email__c='testme'+counter+randomString+'@test.com';
            //record.RecordTypeID = RecordTypeHelper.GetRecordTypeId('Individual','Manual');
            record.Member_Type__c='Affiliate';
            record.Member_First_Name__c='Test me'+counter+randomString;
            record.Member_Last_Name__c = 'Test '+counter+randomString;
            record.Membership_Expiration_date__c=Date.newInstance(2011, 2, 17).addDays(randomNumber);
            results.add(record);
        }
        return results;
    }
    
    public static List<Contact> createContacts(Integer numRecords) {
        //List<Account> AccountResults = createAccounts(numRecords);
        //insert AccountResults;
        List<Contact> results = new List<Contact>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            String randomString = String.valueof(randomNumber);
            Contact record = new Contact();
            record.Lastname = 'Test Contact '+counter+randomString;
            record.FirstName='Test'+counter+randomString;
            //record.AccountId = AccountResults[counter].id;
            record.Email='test'+counter+randomString+'@test.com';
            record.KPI_ERP_Enrollment_Date__c = Date.newInstance(2009, 2, 17);
            record.KPI_Membership_Auto_Renew_Status__c = true;
            //record.RecordTypeID=RecordTypeHelper.getRecordTypeIdFromSchema('Opportunity','Manual');
            record.KPI_CPE_Participation__c = true;
            record.CPD_User_Type__c = 'Lapsed Active';
            //record.KPI_Membership_Payment_Status__c = 'Lapsed';
            record.KPI_Membership_Payment_Status__c ='In Good Standing';
            record.GARP_Member_ID__c = '234234'+counter+randomString;
            record.KPI_CPE_Last_Cycle_Credits__c =0;
            record.Membership_Type__c = 'Individual';
            record.KPI_Membership_Expiration_Date__c=Date.newInstance(2010, 2, 17);
            record.RPT_First_ERP_Part_II_Registration_Exam__c=null;
            record.KPI_SCR_Attempts__c = null;
            record.KPI_SCR_Last_Integration_Data_Status__c = null;  
            record.KPI_ICBRR_Exam_Date__c = null;
            record.KPI_ICBRR_Result__c = 'Pass';
            record.KPI_Current_Exam_Registration__c = null;
            record.KPI_Current_Exam_Registration_Type__c = null;
            record.KPI_Current_Exam_Registration_II_Type__c = null;
            record.KPI_Current_Exam_Registration_I_Status__c = null;
            record.KPI_Current_Exam_Registration_II_Status__c = null;
            record.KPI_Current_Exam_Location__c = null;
            record.KPI_Current_Exam_Reg_Business_Type__c = null;
            record.KPI_Current_Exam_Registration_ADA__c = false;
            record.KPI_Current_Exam_Registration_RA__c = false;
            record.KPI_Current_Exam_Reg_Scholarship__c = false;
            record.Scholarship_Status__c = null;
            record.KPI_Current_Exam_Registration_Date__c = null;
            record.KPI_Current_Exam_Date__c = null;
            record.KPI_Exam_Deferral_Status__c = null;
            record.KPI_Exam_Attempt_ID_2__c = null;
            record.KPI_CPE_Last_Completed_Cycle__c=null;
            record.Email_Events__c = false;
            record.Currently_in_School_Status__c = null;
            record.Exam_Prep_Provider_Outreach__c = false;
            record.Currently_in_School__c = false;
            record.Bloomberg_Profile_Opt_In__c = false;
            record.Other_Qualifications__c = null;
            
            results.add(record);
        }
        system.debug('Contact  results::>>   '+results);
        return results;
    }
    
    public static List<Site__c> createSites(Integer numRecords) {
        List<Site__c> results = new List<Site__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Site__c record = new Site__c();
            record.name = 'Test Site '+counter;
            record.Display_Address__c = 'Test Display_Address__c '+counter;
            record.active__c = true;
            record.Non_selectable__c = false;
            record.Exam_Date__c = System.today().addDays(13+counter);
            record.ATA_region_name__c=null;
            record.ATA_region_code__c=null;
            results.add(record);
        }
        return results;
    }
    
    public static List<Exam_Group__c> createExamGroup(Integer numRecords) {
        List<Exam_Group__c> results = new List<Exam_Group__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Exam_Group__c record = new Exam_Group__c();
            record.Active__c = oneActive;
            oneActive = False;
            /*if(Math.mod(counter,2)==0)
record.Active__c = true;
else
record.Active__c = false;*/
            record.RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Exam_Group__c', 'FRM_ERP');
            record.Exam_Date__c = System.today().addDays(13+counter);
            record.Registration_Start_Date__c = System.today().addDays(4+counter);
            record.Last_Date_For_Early_Registration__c = System.today().addDays(1+counter);
            record.Last_Date_For_Standard_Registration__c = System.today().addDays(9+counter);
            record.Last_Date_For_Late_Registration__c = System.today().addDays(10+counter);
            record.unique_exam_active__c = String.valueOf(math.random()+counter+1);
            system.debug(counter+1  + '    <<::Exam_Group__c  results::>>   '+record.unique_exam_active__c);
            results.add(record);
        }
        system.debug('Exam_Group__c  results::>>   '+results);
        return results;
    }   
    
    public static List<Exam__c> createExam(Integer numRecords) {
        List<Exam_Group__c> ExamGroupResults = createExamGroup(numRecords);
        insert ExamGroupResults;
        List<Exam__c> results = new List<Exam__c>();
        Integer part=1;
        //String[] exams=new String[]{'ICBRR','ERP','FRM Part 1','FRM Part 2','FRM Full Program','Icbrr Part I','Icbrr Part II','ERP Exam Part I','ERP Exam Part II','SCR'};        
        String[] exams=new String[]{'SCR','ERP Part I','ERP Part II','FRM Part 2','SCR','SCR','SCR','SCR','SCR','SCR','FRM Part 1'};        
            for (Integer counter = 0; counter < numRecords; counter++) {
                Integer randomNumber = Integer.valueof((Math.random() * 100));
                String randomString = String.valueof(randomNumber);
                Exam__c record = new Exam__c();
                record.RecordTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Exam__c', 'SCR');
                record.Exam_Group__c = ExamGroupResults[counter].id;
                record.Exam_Date__c = system.today() + 30+counter;
                //record.exam__c = 'FRM Part '+part;    // pick list value
                record.Exam__c = exams[counter];
                record.Name = exams[counter]+randomString;
                System.debug('EXAM_ACTU'+ record.Exam__c);
                results.add(record);
                if(part==2)
                    part=1;
                else
                    part++;
                
            }
        return results;
    }
    
    public static List<Exam_Sites__c> createExamSite(Integer numRecords,List<Exam_Part__c> examPartResults,List<Exam__c> ExamResults) {
        List<Site__c> SiteResults = createSites(numRecords);
        insert SiteResults;
        //List<Exam_Part__c> examPartResults=createExamPart(numRecords);
        //insert examPartResults;
        List<Exam_Sites__c> results = new List<Exam_Sites__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Exam_Sites__c record = new Exam_Sites__c();
            record.Site__c = SiteResults[counter].id;
            record.Exam__c = ExamResults[counter].id;   //here exam__c relation is lookup
            record.Exam_Part__c = examPartResults[counter].id;
            record.Exam_Date__c = system.today().addDays(30+counter);
            System.debug('Exam_name'+record.exam__c);
            results.add(record);
        }
        return results;
    }
    
    // This Opportunity function has chargentBase Gateway dependency
    public static List<Opportunity> createOpportunity(Integer numRecords) {
        List<Account>  AccountResults=createAccounts(numRecords);
        insert AccountResults;
        system.debug(AccountResults.size()+'    <<::AccountResults::>>    '+AccountResults);
        List<ChargentBase__Gateway__c> chargentBaseGateResults=createChargentBaseGateway(numRecords);
        insert chargentBaseGateResults;
        system.debug(chargentBaseGateResults.size()+'    <<::chargentBaseGateResults::>>    '+chargentBaseGateResults);
        List<Opportunity> results=new List<Opportunity>();
        for(Integer counter=0; counter < numRecords; counter++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            String randomString = String.valueof(randomNumber);
            Opportunity record=new Opportunity();
            record.amount = 123;	
            record.Name = 'Test'+counter+randomString;           
            record.Billing_First_Name__c='sdfsdfsdgsfgsf'+randomString; 
            record.Billing_Last_Name__c ='svsvfvvfsf'+randomString;
            record.Shipping_Street__c = 'test shipping street';
            record.Gateway__c =chargentBaseGateResults[counter].id;
            record.RecordTypeID = RecordTypeHelper.GetRecordTypeId('Opportunity','Manual');
            //record.Inst_Sale_Service_End_Date__c=system.today()+ 15;
            record.Eligible_for_Membership_Extension__c = false;
            record.company__c = 'Payment'; 
            record.accountId = AccountResults[counter].id;
            //record.StageName = 'New Lead';
            //record.StageName = 'Closed Won';
            record.StageName = 'Closed';
            record.Program__c = 'Print';
            record.Inst_Sale_Code__c = 'Promocode'+counter+randomString;
            record.Has_Books__c = true;
            record.Institutional_Sale_Stage__c = 'Approved';
            record.closedate = system.today()+ 15; 
            record.Wiley__c =false;
            record.Auto_Renew__c=false;
            record.Billing_Email__c=randomString+'test@test.com';
            record.Renew_Membership__c=false;
            //record.Institutional_Sale_Stage__c='Draft';
            record.Institutional_Sale__c=false;
            record.Frm1__c=false;
            record.Erp1__c=true;
            //record.Exam_Registration_Modification__c='test';
            results.add(record);                                   
        }
        system.debug(results.size()+'    <<::results::>>    '+results);
        return results;
    }
    public static List<Contract> createContract(Integer numRecords,List<Opportunity> OppResults,List<Contact> contactresults) {
        List<Contract> results=new List<Contract>();
        String[] Mem_ship=new String[]{'Individual','Student','Affiliate'};
            //String[] status=new String[]{'In Approval Process','Activated','Draft','Activated ( Auto-Renew )','Canceled','Expired','Renewed','Completed'};
            String[] recordtype = new String[]{'Membership','FRM Program','SCR Program','ERP Program','ICBRR Program','OSTA Program','Risk.Net','FBR Program','FBRA Program',
                'Membership','FRM Program','SCR Program','ERP Program','ICBRR Program','OSTA Program','Risk.Net','FBR Program','FBRA Program',
                'Membership','FRM Program','SCR Program','ERP Program','ICBRR Program','OSTA Program','Risk.Net','FBR Program','FBRA Program',
                'Membership','FRM Program','SCR Program','ERP Program','ICBRR Program','OSTA Program','Risk.Net','FBR Program','FBRA Program'};
                    Integer ms=0,st=0;
        for (Integer counter=0; counter < numRecords; counter++) {
            Contract record=new Contract();
            record.ContractTerm =2;
            record.StartDate = system.today().addDays(counter-25);
            //record.EndDate = system.today().addDays(counter+5);
            //record.Membership_Type__c='Individual';
            record.Membership_Type__c = Mem_ship[ms];
            ms++;
            if(ms==3)
                ms=0;
            //record.recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract','SCR Program');
            record.recordtypeId = RecordTypeHelper.GetRecordTypeId('Contract',recordtype[counter]);
            record.Opportunity__c = OppResults[0].id;
            record.accountId = OppResults[0].AccountId;
            record.Status='Draft';
            //record.Status='Activated';
            record.Enrollment_paid_for_2009__c=false;
            record.Second_Attempt_FRR__c=false;
            record.CustomerSignedId=contactresults[counter].id;
            record.Eligible_For_Scr_Discount_Date__c = System.Today().addMonths(12);
            record.Eligible_For_Scr_Discount__c = True;
            record.StartDate = system.today();
            //record.Status = 'Expired';
            results.add(record);
        }
        return results;
    }
    
    public static List<Exam_Administration__c> createExamAdmin(Integer numRecords,List<Exam__c> ExamResults) {
        //List<Exam_Group__c> ExamGroupResults=createExamGroup(numRecords);
        //insert ExamGroupResults;
        List<Exam_Administration__c> results=new List<Exam_Administration__c>();
        Integer days=0;
        for(Integer counter=0; counter < numRecords ; counter++) {
            Exam_Administration__c record=new Exam_Administration__c();
            record.Exam_Group__c = ExamResults[counter].Exam_Group__c;
            record.Exam_Date__c = system.today().addDays(days)+counter;
            results.add(record);
            if(days==30)
                days=0;
            else
                days=30;
        }
        return results;
    }
    
    public static List<Exam_Part__c> createExamPart(Integer numRecords,List<Exam__c> ExamResults) {
        //List<Exam__c> ExamResults=createExam(numRecords);
        //insert ExamResults;
        List<Exam_Administration__c> ExamAdminResults= createExamAdmin(numRecords,ExamResults);
        insert ExamAdminResults;
        List<Exam_Part__c> results=new List<Exam_Part__c>();
        Integer days=0;
        for( Integer counter=0;counter < numRecords ; counter ++) {
            Exam_Part__c record=new Exam_Part__c();
            record.Exam__c = ExamResults[counter].id;     //here exam__c relation is Master-Detail
            record.Exam_Administration__c = ExamAdminResults[counter].id;
            record.Exam_Date__c = system.today().addDays(days);
            record.Delivery_Method__c = 'CBT';
            //record.ATA_Batch_Code__c = '12345';
            results.add(record);
            if(days==30)
                days=0;
            else
                days=30;
        }
        return results;
    }
    
    
    public static List<Exam_Attempt__c> createExamAttempt(Integer numRecords,List<Opportunity> OppResults,List<Contract> contractResults) {
        //List<Opportunity> oppResults=createOpportunity(numRecords);
        //insert oppresults;
        List<Exam__c> ExamResults = createExam(numRecords);
        insert ExamResults;
        List<Exam_Part__c> examPartResults=createExamPart(numRecords,ExamResults);
        insert examPartResults;
        //List<Exam_Administration__c> examAdminResults=createExamAdmin(numRecords);
        //insert examAdminResults;
        List<Exam_Sites__c> examSiteResults=createExamSite(numRecords,examPartResults,ExamResults);
        insert examSiteResults;
        //String[] sec=new String[]{'ERP Part II','ERP','FRM Part II','FRM Full','FRM Part I','ERP Part I','SCR'};
        List<Exam_Attempt__c> results=new List<Exam_Attempt__c> ();
        String[] recordtype = new String[]{'ERP','FRM','ICBRR','SCR'};
            Integer flag=0;
        for(Integer counter=0 ; counter < numRecords ; counter ++) {
            Exam_Attempt__c record=new Exam_Attempt__c();
            record.Opportunity__c = OppResults[0].id; 
            record.Exam_Site__c = examSiteResults[counter].id;
            record.Member__c = contractResults[counter].CustomerSignedId;//contact id
            record.cancelled__c = false;
            record.Candidate_Commitment__c = contractResults[counter].id;
            record.ATA_Cert_id__c = 'Test'+counter;
            record.ATA_Cert_Type__c = 'TestType'+counter;
            record.ATA_Name_as_it_appears_on_ID__c = 'Test User';
            //record.Other_Exam_Registrations__c=NULL;
            //record.ATA_region_name__c = 'null';
            //record.Exam_Administration__c = examAdminResults[counter].id;
            record.Exam_Administration__c = examPartResults[counter].Exam_Administration__c;
            record.Exam_Part__c = examPartResults[counter].id;
            record.Switch_Date__c = System.Today();
            record.Result__c='Pass';
            record.Defered__c = 'Approved';
            record.Legacy_Unpaid_Registration_Date__c=system.today()+ 60;
            if(flag==4)
                flag=0;
            record.RecordTypeId = RecordTypeHelper.GetRecordTypeId('Exam_Attempt__c',recordtype[flag]);     
            flag++;
            //record.Section__c=sec[counter];
            //record.Section__c=null;
            System.debug('section'+counter+record.Section__c);
            System.debug('Opportunity_StageName__c'+counter+record.Opportunity_StageName__c);
            results.add(record);
            
        }
        return results;
    }
    
    
    
    
    //    --------------------FRR exam------------------
    public static List<Integration_Data__c> createIntegrationDataFRR(Integer numRecords,List<Opportunity> OppResults,List<Contract> contractResults) {
        List<Exam_Attempt__c> attemptResults=createExamAttempt(numRecords,OppResults,contractResults);
        insert attemptResults;
        List<Integration_Data__c> results = new List<Integration_Data__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Integration_Data__c record = new Integration_Data__c();
            record.Contract__c = attemptResults[counter].Candidate_Commitment__c;
            record.Exam_Registrations__c = attemptResults[counter].id;
            record.Version_Number__c = 1;
            record.Name ='Test'+counter;
            record.Is_Active__c =true;
            record.Garp_Id__c ='01404258';
            record.Exam_Type__c = 'FRR';
            record.Outbound_Event_Types__c = 'ATA';
            record.Integration_Type__c = 'Import Registration New';
            record.RecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('ATA').getRecordTypeId();
            record.ATA_Cert_id__c = 'Test'+counter;
            record.ATA_Cert_type__c = 'Others';
            record.ATA_Name_as_it_appears_on_ID__c = 'Test User'+counter;
            record.ATA_Batch_Code__c = '1234';
            record.Is_Active__c = true;
            record.ATA_Outbound_Batch_Code__c = '2020090713';
            record.ATA_subject_code__c = 'ERP01';
            results.add(record);
        }
        return results;
    }
    //    --------------------SCR exam------------------
    public static List<Integration_Data__c> createIntegrationDataSCR(Integer numRecords,List<Opportunity> OppResults,List<Contract> contractResults) {
        List<Exam_Attempt__c> attemptResults=createExamAttempt(numRecords,OppResults,contractResults);
        insert attemptResults;        
        //List<Contract> contractResults=createContract(numRecords,OppResults);
        //insert contractResults;
        List<Integration_Data__c> results = new List<Integration_Data__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Integration_Data__c record = new Integration_Data__c();
            //record.Contract__c = contractResults[counter].Id;
            record.Contract__c =attemptResults[counter].Candidate_Commitment__c;
            record.Exam_Registrations__c = attemptResults[counter].id;
            record.Version_Number__c = 1;
            record.Name ='test'+counter;
            record.Is_Active__c =true;
            record.Garp_Id__c ='01404258';
            record.Exam_Type__c = 'SCR';
            record.Pearson_Event_Type__c ='ExamDelivered';
            record.Pearson_Vue_Appointment_ID__c = '210378726';
            record.PSI_Test_code__c = 'test123'+counter;
            record.Integration_Type__c = 'Eligibility Lifecycle';
            record.PSI_schedule_start_date__c = date.today().format();
            record.PSI_eligibility_end_date__c = date.today().format();
            record.RecordTypeId = Schema.SObjectType.Integration_Data__c.getRecordTypeInfosByDeveloperName().get('PSI').getRecordTypeId();
            record.PSI_client_eligibility_id__c = 'PSI-0000000';
            results.add(record);
        }
        return results;
    }
    
    
    public static List<Product2> createProduct2(){
        Integer numRecords=[Select count() from Opportunity_Product_Mapping__mdt];
        List<Opportunity_Product_Mapping__mdt> prodCodeResults=[Select DeveloperName,MasterLabel,Map_Key__c,Price_Check__c from Opportunity_Product_Mapping__mdt];
        List<Product2> results = new List<Product2>();
        for(Integer counter=0 ; counter < numRecords ; counter++){
            Product2 record = new Product2();
            record.Name = 'enrollment1';
            record.productCode = prodCodeResults[counter].DeveloperName;
            record.GL_Code__c = '4002';
            record.Family = 'Exams';
            record.isActive = true;
            record.Is_Shippable__c=false;
            record.Weight__c=0.0;
            record.Product_ID__c='21FRMNOV1E test';
            record.Bookstore__c=false;
            results.add(record);
        }
        return results;
    }
    
    
    public static List<PricebookEntry> createPricebookEntry(Id pricebookId,List<Product2> Product2Results){
        //List<Product2> Product2Results = createProduct2();
        //insert Product2Results;
        Integer numRecords=Product2Results.size();
        List<PricebookEntry> results = new List<PricebookEntry>();
        for(Integer counter=0 ; counter < numRecords ; counter++){
            PricebookEntry record = new PricebookEntry();
            record.Pricebook2Id = pricebookId;
            record.Product2Id = Product2Results[counter].Id;
            record.UnitPrice = 10000+counter;
            record.IsActive = true;
            results.add(record);
        }
        return results;
    }
    
    
    
    public static List<OpportunityLineItem> createOpportunityLineItem(Id pricebookId){
        
        List<Product2> ProductResults=createProduct2();
        insert ProductResults;
        List<PricebookEntry> PricebookEntryResults = createPricebookEntry(pricebookId,ProductResults);
        insert PricebookEntryResults;
        Integer numRecords=PricebookEntryResults.size(); 
        numRecords=9;
        //System.debug('Test_check_number::'+numRecords); 
        List<Opportunity>  OppResults=createOpportunity(numRecords);
        insert OppResults;
        List<Contact> contactresults= createContacts(numRecords);
        insert contactresults;
        List<Contract> contractResults=createContract(numRecords,OppResults,contactresults);
        insert contractResults;
        List<Exam_Attempt__c> attemptResults=createExamAttempt(numRecords,OppResults,contractResults);
        insert attemptResults;
        List<Scholarship_Application__c> SchAppResults=createScholarshipApplication(numRecords,attemptResults);
        insert SchAppResults;
        List<OpportunityLineItem> results = new List<OpportunityLineItem>();
        for(Integer counter=0 ; counter < numRecords ; counter++){
            OpportunityLineItem record = new OpportunityLineItem();
            record.Quantity=1;
            record.OpportunityId=OppResults[counter].Id;
            record.TotalPrice=25*counter;
            record.PriceBookEntryId = PricebookEntryResults[counter].Id;
            //record.Name='Exam Registration Sales Tax';
            //record.ProductCode='SLSTX';
            //record.Exam_Registration__r.Member__c= attemptResults[counter].Member__c;
            record.Product2Id=ProductResults[counter].id;
            //record.Opportunity.Exam_Registration_Modification__c=OppResults[counter].Exam_Registration_Modification__c';
            //record.Product2.Family='Exams';
            //record.Event__c='';
            //record.Exam_Site__r.Id= attemptResults[counter].Exam_Site__c;
            record.Exam_Registration__c= attemptResults[counter].id;
            
            //record.UnitPrice= 0.0;
            //record.Opportunity.AccountId=OppResults[counter].AccountId;
            record.Scholarship_Application__c=SchAppResults[counter].id;
            record.Description='test desc';
            //record.Product2.Is_Shippable__c= ProductResults[counter].Is_Shippable__c;
            //record.Product2.Weight__c= ProductResults[counter].Weight__c;
            //record.Product2.Product_ID__c=ProductResults[counter].Product_ID__c;
            //record.Product2.Bookstore__c=ProductResults[counter].Bookstore__c;
            //record.Product2.Name= ProductResults[counter].Name;
            //record.Product2.Customs_Cost__c  =ProductResults[counter].Customs_Cost__c;     	                            		
            
            results.add(record);
        }
        return results;
    }                            
    
    public static List<ChargentOrders__Transaction__c> createChargentSFATransaction(Integer numRecords,List<Opportunity>  OppResults){
        
        List<ChargentOrders__Transaction__c> results=new List<ChargentOrders__Transaction__c>();
        for(Integer counter=0; counter < numRecords; counter++){
            ChargentOrders__Transaction__c record=new ChargentOrders__Transaction__c();
            record.Opportunity__c =OppResults[counter].id;
            record.ChargentOrders__Response__c ='0';
            record.ChargentOrders__Response_Status__c ='Approved';
            record.ChargentOrders__Type__c  ='Charge';
            record.ChargentOrders__Amount__c=950.0;
            record.ChargentOrders__Card_Last_4__c='1111';
            record.ChargentOrders__Payment_Method__c = 'Credit Card';
            record.ChargentOrders__Recurring__c = false;
            results.add(record);
        }
        return results;
    }  
    
    
    public static List<ChargentBase__Gateway__c> createChargentBaseGateway(Integer numRecords) {
        List<ChargentBase__Gateway__c> results = new List<ChargentBase__Gateway__c>();
        for (Integer counter = 0; counter < numRecords; counter++) {
            Integer randomNumber = Integer.valueof((Math.random() * 100));
            String randomString = String.valueof(randomNumber);
            ChargentBase__Gateway__c record = new ChargentBase__Gateway__c();
            record.Name = 'Test'+counter+randomString;
            record.ChargentBase__Active__c = true;
            results.add(record);
        }
        return results;
    } 
    
    public static List<UpdateIds__c> createUpdateIds(Integer numRecords) {
        List<ChargentBase__Gateway__c> chargentBaseGateResults=createChargentBaseGateway(numRecords);
        insert chargentBaseGateResults;
        List<UpdateIds__c> results=new List<UpdateIds__c>();
        for(Integer counter=0; counter < numRecords; counter++) {
            UpdateIds__c record=new UpdateIds__c();
            record.Name= 'GARP Test'+counter;
            record.Record_Id__c=chargentBaseGateResults[counter].id;
            results.add(record);
        }
        return results;
    }
    
    public static List<eBook_Key__c> createEbookKey(Integer numRecords,List<Opportunity>  OppResults){
        List<eBook_Key__c> results=new List<eBook_Key__c>();
        for(Integer counter=0; counter < numRecords; counter++){
            eBook_Key__c record=new eBook_Key__c();
            record.Name= 'Test Key'+counter;
            record.Opportunity__c = OppResults[0].id;
            record.Key__c='23424refef1'+counter;
            record.Type__c = 'ERP Exam Part I';
            record.Access_Duration_in_Months__c=36;
            results.add(record);       
        }                          
        return results;            
    }
    
    public static List<Candidate_Requirement__c> createCandidateCommitment(Integer numRecords,List<Opportunity> OppResults,List<Contract> contractResults){
        
        String[] recordtype = new String[]{'Exam','Job Experience','Attest','CPE'};
        String[] exam = new String[]{'ERP','FRM Part I','FRM Part II','FRM Full','ICBRR Part I',
            'ICBRR Part II','ICBRR,FBR','ERP Part I','ERP Part II'};
            List<Candidate_Requirement__c> results=new List<Candidate_Requirement__c>();
        Integer recordtypecounter = 0;
        Integer examcounter=0;
        for(Integer counter=0; counter < numRecords ; counter ++){
            Candidate_Requirement__c record=new Candidate_Requirement__c();
            record.Candidate_Commitment__c = contractResults[counter].id;
            record.name = 'ERP1 test'+counter;   	
            record.Date_of_Completion__c = system.today() + 30+counter;
            record.Status__c = 'completed'; 
             if(examcounter == 8){
                examcounter = 0;
            }
            record.Exam__c=exam[examcounter];
            record.Certificate_Sent_Date__c=  system.today() ;
            
            if(recordtypecounter == 4){
                recordtypecounter = 0;
            }
            record.RecordTypeId=RecordTypeHelper.GetRecordTypeId('Candidate_Requirement__c',recordtype[recordtypecounter]);
            recordtypecounter ++;
            examcounter ++;
            results.add(record);
        }
        return results;	
    }
    
    
    public static List<API_Transaction__c> createAPITransaction(Integer numRecords){
        List<Opportunity> oppResults=createOpportunity(numRecords);
        insert oppResults;
        List<API_Transaction__c> results=new List<API_Transaction__c>();
        for(Integer counter=0; counter < numRecords ; counter ++){
            API_Transaction__c record=new API_Transaction__c();
            record.Request__c='RecordPurchase';
            record.Opportunity__c=oppResults[0].id;
            record.Ignore_for_Retry__c=false;
            results.add(record);
        }
        return results;
    }
    public static List<Mobius_Products__c> createMobiusProducts( ){
        List<Mobius_Products__c> results = new List<Mobius_Products__c>();
        Integer numRecords=[Select count() from Opportunity_Product_Mapping__mdt];
        List<Opportunity_Product_Mapping__mdt> prodCodeResults=[Select MasterLabel from Opportunity_Product_Mapping__mdt];
        for(Integer counter=0;counter< numRecords; counter++){
            Mobius_Products__c record = new Mobius_Products__c();
            record.name = '2020 FRM Exam Part I Book 1'+counter;
            record.Year__c = '2020';
            record.Exam__c = 'FRM';
            record.Part__c = 'I';
            record.Product_Id__c = 52;
            record.Salesforce_Product_Code__c = prodCodeResults[counter].MasterLabel;
            record.Access_Duration_in_Months__c = 36;
            results.add(record);
        }
        return results; 
    }
    
    
    public static List<Event__c> createEvents(Integer numRecords){
        List<Event__c> results = new List<Event__c>();
        for(Integer counter=0;counter< numRecords; counter++){
            Event__c record = new Event__c();		
            record.Name = 'TEST event'+counter;
            record.Last_Date_For_Registration__c = Date.today().addDays(30);
            results.add(record);
        }
        return results; 
    }
    
    public static List<Event_Registration__c> createEventRegistration(Integer numRecords,List<Opportunity> oppResults) {
        List<Event__c> eventResults=createEvents(numRecords);
        insert eventResults;
        List<Event_Registration__c> results=new List<Event_Registration__c>();
        for(Integer counter=0; counter < numRecords; counter ++){
            Event_Registration__c record=new Event_Registration__c();	
            record.Name = 'Event';
            record.Opportunity__c = oppResults[0].id;
            record.event__C = eventResults[counter].id;
			//record.Opportunity_Method_of_payment__c='test';
			record.Status__c='Registered';
            results.add(record);
        }
        return results;
    }
    
    public static List<Chapter_Meeting__c> createChapterMeeting(Integer numRecords) {
        List<Chapter_Meeting__c> results=new List<Chapter_Meeting__c>();
        for(Integer counter=0; counter < numRecords; counter ++){
            Chapter_Meeting__c record=new Chapter_Meeting__c();	
            record.Name='Test Chapter Meeting'+counter;
            record.Start__c=System.now().addDays(15);
            record.End__c=System.now().addDays(15).addHours(2);
            results.add(record);
        }
        return results;
    }
    
    public static List<Chapter_Meeting_Registration__c> createChapterMeetRegistration(Integer numRecords){
        List<Chapter_Meeting__c> chapMeetResults=createChapterMeeting(numRecords);
        insert chapMeetResults;
        List<Opportunity> oppResults=createOpportunity(numRecords);
        insert oppResults;
        List<Chapter_Meeting_Registration__c> results=new List<Chapter_Meeting_Registration__c>();
        for(Integer counter=0;counter < numRecords ; counter ++){
            Chapter_Meeting_Registration__c record=new Chapter_Meeting_Registration__c();
            record.Name = 'Test Event'+counter;
            record.Opportunity__c = oppResults[0].id;
            record.Chapter_Meeting__c = chapMeetResults[counter].id;
            results.add(record);
        }
        return results;
    }
    
    
    public static List<Scholarship_Application__c> createScholarshipApplication(Integer numRecords,List<Exam_attempt__c> applicantResults){
        
        //List<Contact> applicantResults=createContacts(numRecords);
        //insert applicantResults;	
        List<Exam_Group__c> examGrpResults=createExamGroup(numRecords);
        insert examGrpResults;
        List<Scholarship_Application__c> results=new List<Scholarship_Application__c>();
        for(Integer counter=0;counter < numRecords ; counter ++){
            Scholarship_Application__c record=new Scholarship_Application__c();
            record.status__c='Submitted';
            record.Applicant__c=applicantResults[counter].Member__c;
            record.Exam_Group__c=examGrpResults[counter].id;
            record.Exam_Type__c='ERP';
            results.add(record);
        }
        return results;
    }
    
    public static List<certificate_shipping__c> createCertShipping(Integer numRecords){
        List<Contact> contactResults=createContacts(numRecords);
        insert contactResults;	
        String[] recordtype = new String[]{'Duplicate Certificate','Original Certificate','Reissue Certificate'};
            List<certificate_shipping__c> results = new List<certificate_shipping__c>();
        for(Integer counter=0;counter < numRecords ; counter ++){     
            certificate_shipping__c record = new certificate_shipping__c();
            record.Member__c = contactResults[counter].id;
            record.RecordTypeid = RecordTypeHelper.GetRecordTypeId('certificate_shipping__c',recordtype[counter]);
            record.Garp_id__c = contactResults[counter].GARP_Member_ID__c;
            record.Certificate_Type__c = 'FRM';
            record.Run_Now__c = true;
            results.add(record);
        }
        return results;
    }
    
    public static List<Integration_Stream_Event__e> createIntegraStream(Integer numRecords){
        List<Integration_Stream_Event__e> results=new  List<Integration_Stream_Event__e>();
        String[] Obj_name = new String[]{'Opportunity','Contract','Exam_Attempt__c'};
            String[] inte_type = new String[]{'PearsonVue','PSI','RiskDotNet','ATA','provisionEvents','ChapterMeeting','FRM1EBook','FRM2EBook','SCREBook','ERP2EBook','FRREBook','FRREBookANDYardStick','FFREBook'};
                Integer i=0;
        for(Integer counter=0;counter < numRecords ; counter ++){  
            Integration_Stream_Event__e record=new Integration_Stream_Event__e();
            record.Integration_Type__c=inte_type[counter];
            record.Object_Name__c = Obj_name[i];
            i++;
            if(i==3)
                i=0;
            results.add(record);
        }
        return results;    
    }
    
    
    
}