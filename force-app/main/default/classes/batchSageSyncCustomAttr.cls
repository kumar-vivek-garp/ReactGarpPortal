global class batchSageSyncCustomAttr implements database.batchable<sobject>{
    private string recordId;
    private string whereClause;
    public batchSageSyncCustomAttr(string inputWhereClause){
        whereClause = inputWhereClause;
    }
    
    public batchSageSyncCustomAttr(string inputWhereClause,string inputRecordId){
        recordId = inputRecordId;
        whereClause = inputWhereClause;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        
        String syncStatus = 'OK';
        String query1 = 'Select Id from Opportunity where ia_crm__Intacct_Sync_Status_1__c =: syncStatus';
        if(whereClause != null){
            query1 += ' and '+whereClause;
        } 
        if(recordId != null){
            query1 += ' and Id =: recordId';
        }        
        
        return Database.getQueryLocator(query1);      
        
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        Map<String,ia_crm__Sales_Order_Item__c> soiMap = new Map<String,ia_crm__Sales_Order_Item__c>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Set<Id> siteCodeSet = new Set<Id>();
        
        List<Opportunity> oppList = [SELECT Id,Display_Invoice_Number__c,ia_crm__Intacct_Transaction__c,Tax_Authority__c,
                                     (SELECT Id,ProductCode,Product_ID__c,Tax_Authority__c,Site_Code__c
                                      FROM OpportunityLineItems),
                                     (SELECT id,Name,ia_crm__Sales_Order__r.Name,ia_crm__Item__c,ia_crm__Opportunity__c
                                      FROM R00N40000001bdmZEAQ /*ia_crm__Sales_Order_Items__c*/) 
                                     FROM Opportunity WHERE Id IN: scope];
        
        for(Opportunity opp : oppList){
            for(ia_crm__Sales_Order_Item__c soi : opp.R00N40000001bdmZEAQ){
                soiMap.put(opp.Id+soi.ia_crm__Item__c,soi);
            }
            for(OpportunityLineItem oli : opp.OpportunityLineItems){
                siteCodeSet.add(oli.Site_Code__c);
            }
        }
        
        
        
        Map<Id,ia_crm__Intacct_User_Dimension__c> siteCodeMap = new Map<Id,ia_crm__Intacct_User_Dimension__c>([Select Id,ia_crm__Intacct_Id__c 
                                                                                                               from ia_crm__Intacct_User_Dimension__c 
                                                                                                               where Id IN: siteCodeSet]);
        
        Decimal dtdversion = 3.0;
        Boolean uniqueid = false;
        
        if(SageApiWebService.authentication() != 'Failed'){
            Sage_API__mdt sageMDt = Sage_API__mdt.getInstance('Sage_API');
            
            List<Sage_Custom_Attribute_Mapping__mdt> sageMappings = Sage_Custom_Attribute_Mapping__mdt.getAll().values();
            List<Sage_Custom_Attribute_Mapping__mdt> headermappings = new List<Sage_Custom_Attribute_Mapping__mdt>();
            List<Sage_Custom_Attribute_Mapping__mdt> detailmappings = new List<Sage_Custom_Attribute_Mapping__mdt>();
            
            for(Sage_Custom_Attribute_Mapping__mdt mtdt : sageMappings){
                if(mtdt.Is_Active__c == true && mtdt.Object__c == 'Opportunity'){
                    headermappings.add(mtdt);
                }else if(mtdt.Is_Active__c == true && mtdt.Object__c == 'OpportunityLineItem'){
                    detailmappings.add(mtdt);
                }
            }
            
            string xml = '';
            xml+=  '<?xml version="1.0" encoding="UTF-8"?>';
            xml+=  '<request>';
            xml+=  		'<control>';
            xml+=  			'<senderid>'+ sageMDt.senderid__c +'</senderid>';
            xml+=  			'<password>'+ sageMDt.ctrlpassword__c +'</password>';
            xml+=  			'<controlid>'+ sageMDt.controlid__c +'</controlid>';
            xml+=  			'<uniqueid>'+ uniqueid +'</uniqueid>';
            xml+=  			'<dtdversion>'+ dtdversion +'</dtdversion>';
            xml+=  			'<includewhitespace>'+ true +'</includewhitespace>';
            xml+=  		'</control>';
            xml+=  		'<operation transaction="false">';
            xml+=  			'<authentication>';
            xml+=  				'<login>';
            xml+=  					'<userid>'+ sageMDt.userid__c +'</userid>';
            xml+=  					'<companyid>'+ sageMDt.Companyid__c +'</companyid>';
            xml+=  					'<password>'+ sageMDt.password__c +'</password>';
            xml+=  				'</login>';
            xml+=  			'</authentication>';
            xml+=  			'<content>';
            xml+=  	 				'<function controlid="testControlId">';
            
            
            for (Opportunity opp : oppList){
                System.debug('opp.ChargentSFA__Invoice_Number__c::>>   '+opp.Display_Invoice_Number__c);
                
                xml+=		'<update_sotransaction key="'+opp.ia_crm__Intacct_Transaction__c+'-'+opp.Display_Invoice_Number__c+'">';
                for(Sage_Custom_Attribute_Mapping__mdt hdMap : headermappings){
                    xml+=		'<customfield>';
                    xml+=  			'<customfieldname>'+hdMap.Sage_Attribute__c+'</customfieldname>';
                    xml+= 		 	'<customfieldvalue>'+opp.get(hdMap.Salesforce_Field__c)+'</customfieldvalue>';
                    xml+=  		'</customfield>';
                }
                xml+= 	       '<updatesotransitems>';    
                
                for(OpportunityLineItem oli : opp.OpportunityLineItems){
                    if(soiMap.containsKey(opp.Id+oli.Product_ID__c)){
                        ia_crm__Sales_Order_Item__c SalesOrderItems = soiMap.get(opp.Id+oli.Product_ID__c);
                        xml+=  			'<updatesotransitem line_num="'+SalesOrderItems.Name+'">';
                        xml+=  				'<customfields>';
                        for(Sage_Custom_Attribute_Mapping__mdt dtMap : detailmappings){
                            xml+=					'<customfield>';
                            xml+=  						    '<customfieldname>'+dtMap.Sage_Attribute__c+'</customfieldname>';
                            xml+= 							'<customfieldvalue>'+oli.get(dtMap.Salesforce_Field__c)+'</customfieldvalue>';
                            xml+=  					'</customfield>';
                        }
                        xml+=				'</customfields>';
                        xml+=  			'</updatesotransitem>';
                    }
                }
                xml+= 				  '</updatesotransitems>';
                xml+=  				'</update_sotransaction>';
            }
            
            xml+=  			'</function>';
            xml+=  		'</content>';
            xml+=  	'</operation>';
            xml+= '</request>';
            
            SageApiWebService.callOutMethod(xml);
        }
        
    }
    global void finish(Database.BatchableContext BC){
        
    }
}