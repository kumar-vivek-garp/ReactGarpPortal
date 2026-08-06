public without sharing class MicroCourseCertificateCtrl {
    
    public String errorMessage { get; set; }
    public String displayDay { get; set; }
    public String displayMonth { get; set; }
    public String displayYear { get; set; }
    
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String garpId { get; set; }
    public Date allCompleteDate { get; set; }
    
    public String programName { get; set; }

    public Contract contract { get; set; }
    
    public MicroCourseCertificateCtrl (){

        //try{
        
            String contactId = ApexPages.currentPage().getParameters().get('id');
        	System.Debug('contactId:' + contactId);
        
            String courseType = ApexPages.currentPage().getParameters().get('type');
        	System.Debug('courseType:' + courseType);
            
            User user = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
            System.Debug('user:' + user);
            
            Contact contact;            
            if(!Test.isRunningTest()) {
                if(user.ContactId != contactId){
                    this.errorMessage = 'Your session has expired.';
                    return;
                }
            }
            
            List<Contact> lstContact = [select Id, AccountId, FirstName, LastName, GARP_Member_ID__c from Contact where id = :contactId];
            System.Debug('lstContact:' + lstContact);
            
            if(lstContact.IsEmpty()) {
                this.errorMessage = 'Contact not found.';
                return;                
            } else {
                contact = lstContact[0];
            }
            
            this.firstName = contact.FirstName;
            this.lastName = contact.LastName;
            this.garpId = contact.GARP_Member_ID__c;
            
            String programRecordTypeName;
            if(courseType == 'FRRMC1') {
                programRecordTypeName = 'FRR MC1 Program';
                programName = 'Credit Risk Management';
            } else if(courseType == 'FRRMC2') {
                programRecordTypeName = 'FRR MC2 Program';
                programName = 'Market Risk Management';
            } else if(courseType == 'FRRMC3') {
                programRecordTypeName = 'FRR MC3 Program';
                programName = 'Operational Risk Management';
            } else if(courseType == 'FRRMC4') {
                programRecordTypeName = 'FRR MC4 Program';
                programName = 'Asset and Liability Management';
            }
            System.Debug('programRecordTypeName:' + programRecordTypeName);
        	System.Debug('programName:' + programName);
            
            List<Contract> frrContracts = [
                SELECT Id, All_Requirements_Completed_Date__c 
                FROM Contract 
                WHERE AccountId = :contact.AccountId AND RecordType.Name = :programRecordTypeName AND
                All_Requirements_Completed_Date__c != NULL
            ];
            System.Debug('frrContracts:' + frrContracts);
            
            // Throw a page exceptions
            if(frrContracts.isEmpty()){
                this.errorMessage = 'No Micro Course Program found.';
                return;
            }
            
            contract = frrContracts[0];
            System.Debug('contract:' + contract);
            
            Map<Integer, String>dayOfMonthInWordsMap  = new Map<Integer, String>{
                1 => 'FIRST',
                2 => 'SECOND', 
                3 => 'THIRD',
                4 => 'FOURTH',
                5 => 'FIFTH',
                6 => 'SIXTH',
                7 => 'SEVENTH',
                8 => 'EIGHTH',
                9 => 'NINTH',
                10 => 'TENTH',
                11 => 'ELEVENTH',
                12 => 'TWELFTH',
                13 => 'THIRTEENTH',
                14 => 'FOURTEENTH',
                15 => 'FIFTEENTH',
                16 => 'SIXTEENTH',
                17 => 'SEVENTEENTH',
                18 => 'EIGHTEENTH',
                19 => 'NINETEENTH',
                20 => 'TWENTIETH',
                21 => 'TWENTY-FIRST',
                22 => 'TWENTY-SECOND',
                23 => 'TWENTY-THIRD',
                24 => 'TWENTY-FOURTH',
                25 => 'TWENTY-FIFTH',
                26 => 'TWENTY-SIXTH',
                27 => 'TWENTY-SEVENTH',
                28 => 'TWENTY-EIGHTH',
                29 => 'TWENTY-NINTH',
                30 => 'THIRTIETH',
                31 => 'THIRTY-FIRST'
            };
                
            Map<Integer, String>yearInWordsMap = new Map<Integer, String>{
                2000 => 'TWO THOUSAND',
                2001 => 'TWO THOUSAND AND ONE',
                2002 => 'TWO THOUSAND AND TWO',
                2003 => 'TWO THOUSAND AND THREE',
                2004 => 'TWO THOUSAND AND FOUR',
                2005 => 'TWO THOUSAND AND FIVE',
                2006 => 'TWO THOUSAND AND SIX',
                2007 => 'TWO THOUSAND AND SEVEN',
                2008 => 'TWO THOUSAND AND EIGHT',
                2009 => 'TWO THOUSAND AND NINE',
                2010 => 'TWO THOUSAND AND TEN',
                2011 => 'TWO THOUSAND AND ELEVEN',
                2013 => 'TWO THOUSAND AND TWELVE',
                2013 => 'TWO THOUSAND AND THIRTEEN',
                2014 => 'TWO THOUSAND AND FOURTEEN',
                2015 => 'TWO THOUSAND AND FIFTEEN',
                2016 => 'TWO THOUSAND AND SIXTEEN',
                2017 => 'TWO THOUSAND AND SEVENTEEN',
                2018 => 'TWO THOUSAND AND EIGHTEEN',
                2019 => 'TWO THOUSAND AND NINETEEN',
                2020 => 'TWO THOUSAND AND TWENTY',
                2021 => 'TWO THOUSAND AND TWENTY ONE',
                2022 => 'TWO THOUSAND AND TWENTY TWO',
                2023 => 'TWO THOUSAND AND TWENTY THREE',
                2024 => 'TWO THOUSAND AND TWENTY FOUR',
                2025 => 'TWO THOUSAND AND TWENTY FIVE',
                2026 => 'TWO THOUSAND AND TWENTY SIX',
                2027 => 'TWO THOUSAND AND TWENTY SEVEN',
                2028 => 'TWO THOUSAND AND TWENTY EIGHT',
                2029 => 'TWO THOUSAND AND TWENTY NINE',
                2030 => 'TWO THOUSAND AND THIRTY',
                2031 => 'TWO THOUSAND AND THIRTY ONE',
                2032 => 'TWO THOUSAND AND THIRTY TWO',
                2033 => 'TWO THOUSAND AND THIRTY THREE',
                2034 => 'TWO THOUSAND AND THIRTY FOUR',
                2035 => 'TWO THOUSAND AND THIRTY FIVE',
                2036 => 'TWO THOUSAND AND THIRTY SIX',
                2037 => 'TWO THOUSAND AND THIRTY SEVEN',
                2038 => 'TWO THOUSAND AND THIRTY EIGHT',
                2039 => 'TWO THOUSAND AND THIRTY NINE',
                2040 => 'TWO THOUSAND AND FORTY',
                2041 => 'TWO THOUSAND AND FORTY ONE',
                2042 => 'TWO THOUSAND AND FORTY TWO',
                2043 => 'TWO THOUSAND AND FORTY THREE',
                2044 => 'TWO THOUSAND AND FORTY FOUR',
                2045 => 'TWO THOUSAND AND FORTY FIVE',
                2046 => 'TWO THOUSAND AND FORTY SIX',
                2047 => 'TWO THOUSAND AND FORTY SEVEN',
                2048 => 'TWO THOUSAND AND FORTY EIGHT',
                2049 => 'TWO THOUSAND AND FORTY NINE',
                2050 => 'TWO THOUSAND AND FIFTY'
            };
                
            Integer dayCompleted = contract.All_Requirements_Completed_Date__c.day();
            Integer yearCompleted = contract.All_Requirements_Completed_Date__c.year();

            if(contract.All_Requirements_Completed_Date__c != null){
                
                this.allCompleteDate = contract.All_Requirements_Completed_Date__c;
                    
                dayCompleted = contract.All_Requirements_Completed_Date__c.day();
                yearCompleted = contract.All_Requirements_Completed_Date__c.year(); 
                
                this.displayDay = dayOfMonthInWordsMap.get(dayCompleted);
                this.displayYear = yearInWordsMap.get(yearCompleted);
            }
            
    
        //} catch (Exception e) {
        //    this.errorMessage = e.getMessage();
        //}

    }


}