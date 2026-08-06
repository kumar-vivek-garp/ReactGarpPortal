/*	Batch Class for setStudy method in shareFileClass
 * 	Invoked with Database.executeBatch(batchable, batchSize) in shareFileClass.setStudy()
 * 	[12/07/2018 Xiang] - Created.
 */
public without sharing class ShareFileSetStudy_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    private List<Study_Account__c> studyAccts {get;set;}
    
    public ShareFileSetStudy_Batch(List<Study_Account__c> inptStudyAccts) {
        this.studyAccts = inptStudyAccts;
    }
    
    // Step 1: Gather records
    public Iterable<sObject> start(Database.BatchableContext info) {
    	System.debug('Starting Batch setStudyAccount()');
    	System.debug('studyAccts: ' + studyAccts);
		return studyAccts;
    }
    
    // Step 2: Process records in batches, size of scope is decided when executing batch
    public void execute(Database.BatchableContext info, List<Study_Account__c> scope) {
        for(Study_Account__c oneStudyAcct : scope) {
            shareFileClass.setStudyAccountSync(oneStudyAcct.Id);
        }
    }
    
    // Step 3: Post batch process upon all batches finished
    public void finish(Database.BatchableContext info) {
    	System.debug('Finishing Batch setStudyAccount()');
    }
}