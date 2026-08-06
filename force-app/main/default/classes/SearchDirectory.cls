global without sharing class SearchDirectory {

    global class searchResults {
        public List<Contact> lstContact { get; set; }
        public List<User> lstUser { get; set; }
        public Integer pages  { get; set; }
    }

    public static searchResults searchcontacts(Boolean FRMOnly, Boolean ERPOnly, Boolean SCROnly, String searchText, String industries, String jobFunctions, String riskSpecialties, String corporateTitles, String company, String sortField, String sortOrder, Integer pageSize, Integer pageCurrent) {

        String querystr = '';
        String likeClause = '%'+searchText+'%';
        String filterClause='';
        String fieldsClause = 'Id, Name, FirstName, LastName, Middle_Initial__c, MailingCity, MailingCountry, KPI_CPE_Current_Cycle__c, KPI_CPE_Last_Completed_Cycle__c, Job_Function__c, Risk_Specialty__c, AccountId, GARP_ID__c, Membership_Type__c, Area_of_Concentration__c, GARP_Directory_Opt_In__c, GARP_Directory_Invite_Opt_Out__c, GARP_Dir_Privacy_Additional_Detail__c, GARP_Dir_Privacy_Job_Information__c, GARP_Dir_Privacy_Prof_Background__c, GARP_Directory_Connect_Feature__c, KPI_Membership_Payment_Status__c, KPI_FRM_Certified__c, KPI_FRM_Certified_Year__c, KPI_ERP_Certified__c, KPI_ERP_Certified_Year__c, KPI_SCR_Holder__c, KPI_SCR_Completion_Date__c, KPI_Membership_Since__c, KPI_CPE_Requirement_Status__c, Professional_Designation_CA__c, Professional_Designation_CFA__c, Professional_Designation_CMA__c, Professional_Designation_CPA__c, Professional_Designation_Other__c, Professional_Designation_PMP__c, Professional_Designation_ACCA__c, Other_Qualifications__c, Company_Type__c, Corporate_Title__c, Company__c, Photo_URL__c';
        
        Boolean canAccessMembers = False;

        String userId = UserInfo.getUserId();
        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {
            List<Contact> lstContact = [select Id, Name, KPI_Membership_Payment_Status__c, Membership_Type__c from Contact where Id = :lstUser[0].ContactId];
            if(lstContact != NULL && lstContact.size() > 0) {
                if((lstContact[0].Membership_Type__c == 'Individual' || lstContact[0].Membership_Type__c == 'Student') && lstContact[0].KPI_Membership_Payment_Status__c == 'In Good Standing') {
                    canAccessMembers = True;
                }
            }
        }

        system.debug('* * * canAccessMembers ...'+ canAccessMembers);

        if(FRMOnly == True || ERPOnly == True || SCROnly == True) {
            if(FRMOnly == True)
            	filterClause = ' and (KPI_FRM_Certified__c = true';
            if(ERPOnly == True)
            	filterClause += filterClause == '' ? ' and (KPI_ERP_Certified__c = true' : ' or KPI_ERP_Certified__c = true';
            if(SCROnly == True)
            	filterClause += filterClause == '' ? ' and (KPI_SCR_Holder__c = true' : ' or KPI_SCR_Holder__c = true';
            filterClause += ')';
        }
        else {
            if(canAccessMembers == False) {
                filterClause = ' and (KPI_FRM_Certified__c = true or KPI_ERP_Certified__c = true or KPI_SCR_Holder__c = true)';
            } else {
                filterClause = ' and KPI_Membership_Payment_Status__c = \'In Good Standing\'';
            }
        }

        system.debug('* * * filterClause ...'+ filterClause);

        String query = 'SELECT ' + fieldsClause + ' FROM Contact';
        String sortClause = ' ORDER BY ' + sortField + ' ' + sortOrder + ' NULLS LAST ';

        String whereClause;
        if(company == '' && industries == '' && jobFunctions == '' && corporateTitles == '' && riskSpecialties == '') {
            whereClause = ' WHERE GARP_Directory_Opt_In__c = true and (Name like :likeClause OR MailingCity like :likeClause OR MailingCountry like :likeClause)';

            system.debug('* * * whereClause ...'+ whereClause);

        } else {

            String industriesInClause = '';
            String[] arrText;
            if(industries != '') {
                arrText = industries.split('; ');
                for(String s :arrText) {
                    if(industriesInClause == '') {
                        industriesInClause = '\'' + s + '\'';
                    } else {
                        industriesInClause = industriesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String jobFunctionsInClause = '';
            if(jobFunctions != '') {
                arrText = jobFunctions.split('; ');
                for(String s :arrText) {
                    if(jobFunctionsInClause == '') {
                        jobFunctionsInClause = '\'' + s + '\'';
                    } else {
                        jobFunctionsInClause = jobFunctionsInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String riskSpecialtiesInClause = '';
            if(riskSpecialties != '') {
                arrText = riskSpecialties.split('; ');
                for(String s :arrText) {
                    if(riskSpecialtiesInClause == '') {
                        riskSpecialtiesInClause = '\'' + s + '\'';
                    } else {
                        riskSpecialtiesInClause = riskSpecialtiesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            String corporateTitlesInClause = '';
            if(corporateTitles != '') {
                arrText = corporateTitles.split('; ');
                for(String s :arrText) {
                    if(corporateTitlesInClause == '') {
                        corporateTitlesInClause = '\'' + s + '\'';
                    } else {
                        corporateTitlesInClause = corporateTitlesInClause + ',' + '\'' + s + '\'';
                    }
                }
            }

            //String likeClause = searchText;
            whereClause = ' WHERE GARP_Directory_Opt_In__c = true ';
            if(industries != '') {
                whereClause +=  ' and Area_of_Concentration__c in (' + industriesInClause + ')';
            }
            if(jobFunctions != '') {
                whereClause +=  ' and Job_Function__c in (' + jobFunctionsInClause + ')';
            }
            if(riskSpecialties != '') {
                whereClause +=  ' and Risk_Specialty__c in (' + riskSpecialtiesInClause + ')';
            }
            if(corporateTitles != '') {
                whereClause +=  ' and Corporate_Title__c in (' + corporateTitlesInClause + ')';
            }
            if(company != '') {
                String companyLikeClause = '%'+company+'%';
                whereClause +=  ' and Company__c like :companyLikeClause';
            }
            whereClause +=  ' and (Name like :likeClause OR MailingCity like :likeClause OR MailingCountry like :likeClause)';

            system.debug('* * * whereClause ...'+ whereClause);

        }

        querystr = query + whereClause + filterClause + sortClause + ' LIMIT ' + pageSize + ' offset ' + (pageCurrent-1)*pageSize;
        system.debug('* * * query ...'+ querystr);

        List<Id> ids = new List<Id>();
        List<Contact> lstContact = database.query(querystr);
        for(Contact con :lstContact){
            ids.add(con.Id);
        }

        String cntQuery = 'SELECT Count() FROM Contact ' + whereClause + filterClause;

        integer count= database.countQuery(cntQuery);
        system.debug('* * * count ...'+ count);

        /*
        List<Contact> returnListContact = new List<Contact>();
        List<Id> ids = new List<Id>();
        if(lstContact.size() > pageSize) {
            Integer count = 1;
            Integer page = 1;
            for(Contact con :lstContact){
                if(page == pageCurrent) {
                    returnListContact.add(con);
                    ids.add(con.Id);
                }
                count++;
                if(count > pageSize) {
                    count=1;
                    page++;
                }
            }
        } else {
            returnListContact = lstContact;
        }
        */

        searchResults results = new searchResults();
        results.lstUser = [select Id, Name, FullPhotoUrl, ContactId from User where ContactId in :ids];


        Decimal myDecimal = count;
        Decimal divDec = myDecimal.divide(pageSize, 0, System.RoundingMode.UP);
        system.debug('* * * divDec ...'+ divDec);

        results.lstContact = lstContact;
        results.pages = divDec.intValue();

        for(Contact contact_result :results.lstContact){
            // 2. If they would like the CPD status displayed <<<<<< GARP_Dir_Privacy_Additional_Detail__c <<<<<<<< return null for CPD status
            if(contact_result.GARP_Dir_Privacy_Additional_Detail__c == false || canAccessMembers == False){
                contact_result.KPI_CPE_Current_Cycle__c = null;
                contact_result.KPI_CPE_Last_Completed_Cycle__c = null;
                contact_result.KPI_CPE_Requirement_Status__c = null;
            }
            // 3. Show my Organization type and expertise <<<<<<< GARP_Dir_Privacy_Job_Information__c <<<<<<<< return null for job and expertise
            if(contact_result.GARP_Dir_Privacy_Job_Information__c == false || canAccessMembers == False){
                contact_result.Area_of_Concentration__c = null;
                contact_result.Professional_Designation_CA__c = null;
                contact_result.Professional_Designation_CFA__c = null;
                contact_result.Professional_Designation_CMA__c = null;
                contact_result.Professional_Designation_CPA__c = null;
                contact_result.Professional_Designation_Other__c = null;
                contact_result.Professional_Designation_PMP__c = null;
                contact_result.Professional_Designation_ACCA__c = null;
            }
            // 4. show my job title and company <<<<<<< GARP_Dir_Privacy_Prof_Background__c  <<<<<<<< return null for job title and company
            if(contact_result.GARP_Dir_Privacy_Prof_Background__c == false || canAccessMembers == False){
                contact_result.Job_Function__c = null;
                contact_result.Risk_Specialty__c = null;
                contact_result.Corporate_Title__c = null;
                contact_result.Company__c = null;
            }
        }
        return results;
    }

}