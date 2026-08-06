public with sharing class QualtricsApiQueueable implements Queueable, Database.AllowsCallouts{

    public Integer index { get; set; }
    public Integer total { get; set; }
    public List<Study_Account__c> studyAccounts { get; set; }

    public Response.Detail sync(Study_Account__c studyAccount){

        List<Api_Transaction__c> apiTransactions = new List<Api_Transaction__c>();

        try{

            if(studyAccount.Qualtrics_Survey_Integration_Status__c != 'Enabled'){
                throw new Response.ResponseException('Your organization is not a participant in this survey.', 403, new List<String>{'Your organization is not a participant in this survey.'});
            }

            if(studyAccount.Study__r.Qualtrics_Survey_Integration_Status__c != 'Enabled'){
                throw new Response.ResponseException('This survey has been disabled.', 403, new List<String>{'This survey has been disabled.'});
            }

            FINAL Id studyAccountId = studyAccount.Id;
            FINAL Id studyId = studyAccount.Study__r.Id;
            FINAL String directoryId = Label.Qualtrics_Directory_ID;

            if(studyAccount.Qualtrics_Mailing_List_ID__c == null){
                // Create Mailing List
                QualtricsApiService.response createMailingListResponse = QualtricsApiService.createMailingList(
                    directoryId, 
                    studyId,
                    studyAccountId
                );

                if(createMailingListResponse.meta == null || createMailingListResponse.meta.httpStatus != '200 - OK'){
                    throw new Response.ResponseException(null, 404, new List<String>{JSON.serializePretty(createMailingListResponse)});
                }

                studyAccount.Qualtrics_Mailing_List_ID__c = createMailingListResponse.result.id;
            }

            if(studyAccount.Qualtrics_Contact_ID__c == null){
                // Create Contact in Mailing List
                QualtricsApiService.response createContactInMailingListResponse = QualtricsApiService.createContactInMailingList(
                    directoryId, 
                    studyAccount.Qualtrics_Mailing_List_ID__c, 
                    studyId,
                    studyAccountId
                );

                if(createContactInMailingListResponse.meta == null || createContactInMailingListResponse.meta.httpStatus != '200 - OK'){
                    throw new Response.ResponseException(null, 404, new List<String>{JSON.serializePretty(createContactInMailingListResponse)});
                }

                studyAccount.Qualtrics_Contact_ID__c = createContactInMailingListResponse.result.id;
            }

            studyAccount.Qualtrics_Survey_Sync_Study__c = false;
            studyAccount.Qualtrics_Survey_Integration_Status__c = 'Enabled';

            UPDATE studyAccount;

            return new Response.Detail('Success.', 200, new List<String>{});

        }catch(Response.ResponseException e){
            return new Response.Detail(e.getMessage(), e.status, e.errors);
        }catch(Exception e){
            return new Response.Detail(null, 400, new List<Object>{e.getMessage(),e.getLineNumber(),e.getStackTraceString()});
        }

    }

    public void execute(QueueableContext context) {

        Response.Detail res = this.sync(this.studyAccounts[this.index]);

        System.debug(res);

        if(!QualtricsApiService.apiTransactions.isEmpty()){
            INSERT QualtricsApiService.apiTransactions;
        }

        this.index++;

        if(this.index < this.total){
            if(!Test.isRunningTest()){
                System.enqueueJob(new QualtricsApiQueueable(this.studyAccounts, this.index));
            }
        }

    }

    public QualtricsApiQueueable(List<Study_Account__c> studyAccounts, Integer index) {
        this.index = index;
        this.total = studyAccounts.size();
        this.studyAccounts = studyAccounts;
    }

}