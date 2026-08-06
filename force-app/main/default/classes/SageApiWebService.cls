public class SageApiWebService {
    
    
    public static String authentication(){
        String contentobject = 'SODOCUMENT';
        String fields = '*';
        String returnFormat = 'xml';
        Integer pagesize = 100;
        
        Boolean uniqueid = false;
        Decimal dtdversion = 3.0;
        Boolean includewhitespace = true;
        
        
        Sage_API__mdt sageMDt = [SELECT senderid__c, ctrlpassword__c, controlid__c, userid__c,
                                 Companyid__c, password__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
        
        string xml = '';
        xml+=  '<?xml version="1.0" encoding="UTF-8"?>';
        xml+=  '<request>';
        xml+=     '<control>';
        xml+=        '<senderid>'+ sageMDt.senderid__c +'</senderid>';
        xml+=        '<password>'+ sageMDt.ctrlpassword__c +'</password>';
        xml+=        '<controlid>'+ sageMDt.controlid__c +'</controlid>';
        xml+=        '<uniqueid>'+ uniqueid +'</uniqueid>';
        xml+=        '<dtdversion>'+ dtdversion +'</dtdversion>';
        xml+=        '<includewhitespace>'+ includewhitespace +'</includewhitespace>';
        xml+=     '</control>';
        xml+=     '<operation transaction="false">';
        xml+=        '<authentication>';
        xml+=           '<login>';
        xml+=              '<userid>'+ sageMDt.userid__c +'</userid>';
        xml+=              '<companyid>'+ sageMDt.Companyid__c +'</companyid>';
        xml+=              '<password>'+ sageMDt.password__c +'</password>';
        xml+=           '</login>';
        xml+=        '</authentication>';
        xml+= '<content>';
        xml+= '<function controlid="testControlId">';
        xml+= '<getAPISession/>';
        /*xml+= '<readByQuery>';
        xml+= '<object>'+contentobject+'</object>';
        xml+= '<fields>'+fields+'</fields>';
        xml+= '<query />';
        xml+= '<returnFormat>'+returnFormat+'</returnFormat>';
        xml+= '<pagesize>'+pagesize+'</pagesize>';
        xml+= '</readByQuery>';*/
        xml+= '</function>';
        xml+= '</content>';
        xml+= '</operation>';
        xml+= '</request>';
        
        return callOutMethod(xml);
        
    }
    
    
    public static Map<String,String> reallocation(String InvoiceNo,Date EndDate){
        
        Map<String,String> valueMap = new Map<String,String> ();
        
        if(!authentication().startsWith('Failed##')){
            
            Boolean uniqueid = false;
            Decimal dtdversion = 3.0;
            Boolean includewhitespace = true;
            
            String Recordno ;
            Integer Rev_Year;
            Integer Rev_month;
            Integer Rev_day;
            Date revStrtDate;
            
            
            Sage_API__mdt sageMDt = [SELECT senderid__c, ctrlpassword__c, controlid__c, userid__c,
                                     Companyid__c, password__c,recordno__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
            
            string xml = '';
            
            xml+=  '<?xml version="1.0" encoding="UTF-8"?>';
            xml+=  '<request>';
            xml+=  '	<control>';
            xml+=  '		<senderid>'+ sageMDt.senderid__c +'</senderid>';
            xml+=  '		<password>'+ sageMDt.ctrlpassword__c +'</password>';
            xml+=  '		<controlid>'+ sageMDt.controlid__c +'</controlid>';
            xml+=  '		<uniqueid>'+ uniqueid +'</uniqueid>';
            xml+=  '		<dtdversion>'+ dtdversion +'</dtdversion>';
            xml+=  '		<includewhitespace>'+ includewhitespace +'</includewhitespace>';
            xml+=  '	</control>';
            xml+=  '	<operation transaction="false">';
            xml+=  '		<authentication>';
            xml+=  '			<login>';
            xml+=  '				<userid>'+ sageMDt.userid__c +'</userid>';
            xml+=  '				<companyid>'+ sageMDt.Companyid__c +'</companyid>';
            xml+=  '				<password>'+ sageMDt.password__c +'</password>';
            xml+=  '			</login>';
            xml+=  '		</authentication>';
            xml+=  '		<content>';
            xml+=  '			<function controlid="testControlId">';
            xml+=  '				<readByQuery>';
            xml+=  '					<object>REVRECSCHEDULE</object>';
            xml+=  '					<fields>RECORDNO,SOREVRECSTARTDATE</fields>';
            xml+=  '					<query>DOCID=\'Salesforce - Sales Invoice-'+InvoiceNo+'\'</query>';
            xml+=  '					<returnFormat>xml</returnFormat>';
            xml+=  '					<pagesize>100</pagesize>';
            xml+=  '				</readByQuery>';
            xml+=  '			</function>';
            xml+=  '		</content>';
            xml+=  '	</operation>';
            xml+=  '</request>';
            
            String expectedResult =  callOutMethod(xml);
            System.debug('expectedResult::'+expectedResult);
            
            
            try
            {
                
                DOM.XMLNode childNode;
                DOM.XMLNode responseNode;
                
                String IsResultStatusSuccess;
                Boolean IsResultDataAvailable;
                
                DOM.Document doc = new DOM.Document();
                doc.load(expectedResult);
                
                //Retrieve the root element for this document.
                responseNode = doc.getRootElement();
                System.debug('responseNode == '+responseNode);
                
                //Is Status Success
                IsResultStatusSuccess = responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('status',null).getText();
                System.debug('IsResultStatusSuccess ='+IsResultStatusSuccess);
                
                //Is Data Tag Available
                IsResultDataAvailable = (responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('data',null)) != null;
                System.debug('IsResultDataAvailable ='+IsResultDataAvailable);
                
                //Parsing for Date and RecordNo
                if(IsResultDataAvailable && IsResultStatusSuccess == 'success'){
                    for(DOM.XMLNode Node : responseNode.getChildElements()){
                        if(Node.getName() == 'operation'){
                            childNode = Node.getChildElement('result',null).getChildElement('data',null);
                            Integer count = Integer.valueOf(childNode.getAttribute('count',null));
                            Integer Totalcount = Integer.valueOf(childNode.getAttribute('totalcount',null));
                            
                            System.debug('count'+count);
                            System.debug('total count '+Totalcount);
                            
                            if(count == Totalcount && count  == 1 ){
                                
                                Recordno = childNode.getChildElement('revrecschedule',null).getChildElement('RECORDNO',null).getText();
                                System.debug('RECORDNO'+Recordno);
                                if(childNode.getChildElement('revrecschedule',null).getChildElement('SOREVRECSTARTDATE',null).getName() == 'SOREVRECSTARTDATE'){
                                    String str = childNode.getChildElement('revrecschedule',null).getChildElement('SOREVRECSTARTDATE',null).getText();
                                    Rev_month = Integer.Valueof(str.split('/').get(0));
                                    Rev_day = Integer.Valueof(str.split('/').get(1));
                                    Rev_Year = Integer.Valueof(str.split('/').get(2));
                                    
                                    revStrtDate = date.newInstance(Rev_Year, Rev_month, Rev_day);
                                }
                                
                            }
                            else{    
                                valueMap.put('revrecscheduleNotFound','revrecschedule not found');
                                system.debug('There are zero Data Records or More than one Data Records Available');
                            }
                        }
                    }                       
                }
                else{
                    
                    System.debug('<<  ===  RECEIVED XML STATUS IS FAILURE OR NO DATA AVAILABLE ===  >>');
                    
                }            
            }
            
            catch(exception e)
            {
                System.debug('Exception Message =='+e.getMessage());
            }    
            //EndDate = Date.today();
            System.debug('Initial day'+EndDate.day());
            System.debug('Initial month'+EndDate.month());
            System.debug('Initial year'+EndDate.year());
            //if(EndDate !=Null && Rev_day !=Null && Rev_month !=Null && Rev_Year !=Null)
            if(EndDate != Null && revStrtDate != Null){
                //if(Integer.valueOf(EndDate.day()) > Rev_day && Integer.valueOf(EndDate.month()) >= Rev_month && Integer.valueOf(EndDate.year()) >= Rev_Year){
                System.debug('The Received XML after initial call to reallocation() has Date value is Less than Initial Date you sent');
                
                String RecallXml = '';
                
                RecallXml +='<?xml version="1.0" encoding="UTF-8"?>';
                RecallXml +='<request>';
                RecallXml +='	<control>';
                RecallXml +='		<senderid>'+ sageMDt.senderid__c +'</senderid>';
                RecallXml +='		<password>'+ sageMDt.ctrlpassword__c +'</password>';
                RecallXml +='		<controlid>'+ sageMDt.controlid__c +'</controlid>';
                RecallXml +='		<uniqueid>'+ uniqueid +'</uniqueid>';
                RecallXml +='		<dtdversion>'+ dtdversion +'</dtdversion>';
                RecallXml +='		<includewhitespace>'+ includewhitespace +'</includewhitespace>';
                RecallXml +='	</control>';
                RecallXml +='	<operation transaction="false">';
                RecallXml +='		<authentication>';
                RecallXml +='			<login>';                   
                RecallXml +='				<userid>'+ sageMDt.userid__c +'</userid>';
                RecallXml +='				<companyid>'+ sageMDt.Companyid__c +'</companyid>';
                RecallXml +='				<password>'+ sageMDt.password__c +'</password>';
                RecallXml +='			</login>';
                RecallXml +='		</authentication>';
                RecallXml +='		<content>';
                RecallXml +='			<function controlid="testControlId">';
                RecallXml +='				<reallocate_revrecschedule>';
                RecallXml +='					<recordno>'+Recordno+'</recordno>';
                
                if(EndDate < revStrtDate){
                    RecallXml +='					<revrecstartdate>';
                    RecallXml +='						<year>'+EndDate.Year()+'</year>';
                    RecallXml +='						<month>'+EndDate.month()+'</month>';
                    RecallXml +='						<day>'+EndDate.day()+'</day>';
                    RecallXml +='					</revrecstartdate>';
                }else{
                    date revDate = EndDate.toStartOfMonth();
                    RecallXml +='					<revrecstartdate>';
                    RecallXml +='						<year>'+revDate.Year()+'</year>';
                    RecallXml +='						<month>'+revDate.month()+'</month>';
                    RecallXml +='						<day>'+revDate.day()+'</day>';
                    RecallXml +='					</revrecstartdate>';
                }
                
                RecallXml +='					<revrecenddate>';
                RecallXml +='						<year>'+EndDate.Year()+'</year>';
                RecallXml +='						<month>'+EndDate.month()+'</month>';
                RecallXml +='						<day>'+EndDate.day()+'</day>';
                RecallXml +='					</revrecenddate>';
                RecallXml +='				</reallocate_revrecschedule>';
                RecallXml +='			</function>';
                RecallXml +='		</content>';
                RecallXml +='	</operation>';
                RecallXml +='</request>';
                
                system.debug('<<===== RecallXml Before again Reallocation call that Date value is in Past ======>>' + RecallXml);
                
                xml = '';
                xml = callOutMethod(RecallXml);
                
                System.debug('<< ==  Received  XML after again Reallocation call that Date value is in Past ==  >>' + xml);
                if(xml.startsWith('Failed##')){
                    valueMap.put('callOutFailed','Failed');
                    String reponseBody = xml.split('Failed##')[1];
                    String allErrMsg = '';
                    try{
                        allErrMsg = xmlString(reponseBody);
                        if(String.isNotBlank(allErrMsg)){
                            valueMap.put('ErrMsg',allErrMsg);
                        }
                    }
                    catch(Exception ex){
                        String msgErr = 'SageApiWebService #246:- System.XmlException: Encountered premature end of XML: input contained no data';
                        System.debug(msgErr);
                        valueMap.put('ErrMsg',msgErr);
                    }
                }else{
                    valueMap.put('callOutPassed','Success');
                }
            }
            else{
                
                System.debug('No Data Records Available or More Than one Data Records are avaialble or Initial Date is Null');
            }
            
        }
        else{
            valueMap.put('Authentication','AuthenticationFailed');
            System.debug('<< == Authentication Error == >>');
        }
        
        return valueMap;
    }
    
    
    public static string updateOppLineItems(Map<String,List<OpportunityLineItem>> OppIdOLIMap){
        
        Map<String,List<ia_crm__Sales_Order_Item__c>> soiMap = new Map<String,List<ia_crm__Sales_Order_Item__c>>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Set<Id> siteCodeSet = new Set<Id>();
        
        List<Opportunity> oppList = [SELECT Id,Display_Invoice_Number__c,ia_crm__Intacct_Transaction__c,
                                     (SELECT Id,ProductCode,Product_ID__c,UnitPrice
                                      FROM OpportunityLineItems),
                                     (SELECT id,Name,ia_crm__Sales_Order__r.Name,ia_crm__Item__c,ia_crm__Opportunity__c,ia_crm__Price__c
                                      FROM R00N40000001bdmZEAQ /*ia_crm__Sales_Order_Items__c*/) 
                                     FROM Opportunity WHERE Id IN: OppIdOLIMap.keySet()];
        
        for(Opportunity opp : oppList){
            for(ia_crm__Sales_Order_Item__c soi : opp.R00N40000001bdmZEAQ){
                if(soiMap.containskey(opp.Id+soi.ia_crm__Item__c)){
                    List<ia_crm__Sales_Order_Item__c> soiList = soiMap.get(opp.Id+soi.ia_crm__Item__c);
                    soiList.add(soi);
                    soiMap.put(opp.Id+soi.ia_crm__Item__c,soiList);
                }else{
                    soiMap.put(opp.Id+soi.ia_crm__Item__c,new List<ia_crm__Sales_Order_Item__c>{soi});
                }
            }
            oliList.addAll(OppIdOLIMap.get(opp.Id));
        }
        
        for(OpportunityLineItem oli : oliList){
            siteCodeSet.add(oli.Site_Code__c);
        }
        
        Map<Id,ia_crm__Intacct_User_Dimension__c> siteCodeMap = new Map<Id,ia_crm__Intacct_User_Dimension__c>([Select Id,ia_crm__Intacct_Id__c 
                                                                                                               from ia_crm__Intacct_User_Dimension__c 
                                                                                                               where Id IN: siteCodeSet]);
        
        Decimal dtdversion = 3.0;
        Boolean uniqueid = false;
        String authResult = authentication();
        
        if(!authResult.startsWith('Failed##')){
            DOM.Document doc = new DOM.Document();
            DOM.XMLNode responseNode;
            doc.load(authResult);
            responseNode = doc.getRootElement();
            string sessionid = responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('data',null).getChildElement('api',null).getChildElement('sessionid',null).gettext();
            
            Sage_API__mdt sageMDt = [SELECT senderid__c, ctrlpassword__c, controlid__c, userid__c,Companyid__c,
                                     password__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
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
            for (Opportunity opp : oppList){
                if(!opp.R00N40000001bdmZEAQ.isEmpty()){
                    xml+=  		'<operation transaction="false">';
                    xml+=  			'<authentication>';
                    /*xml+=  				'<login>';
xml+=  					'<userid>'+ sageMDt.userid__c +'</userid>';
xml+=  					'<companyid>'+ sageMDt.Companyid__c +'</companyid>';
xml+=  					'<password>'+ sageMDt.password__c +'</password>';
xml+=  				'</login>';*/
                    xml+=				'<sessionid>'+sessionid+'</sessionid>';
                    xml+=  			'</authentication>';
                    xml+=  			'<content>';
                    xml+=  	 	  '<function controlid="'+opp.Id+'">';
                    System.debug('opp.ChargentSFA__Invoice_Number__c::>>   '+opp.Display_Invoice_Number__c);
                    
                    xml+=		'<update_sotransaction key="'+opp.ia_crm__Intacct_Transaction__c+'-'+opp.Display_Invoice_Number__c+'">';
                    xml+= 		 '<updatesotransitems>';    
                    
                    for(OpportunityLineItem oli : OppIdOLIMap.get(opp.Id)){
                        if(soiMap.containsKey(opp.Id+oli.Product_ID__c)){
                            List<ia_crm__Sales_Order_Item__c> SalesOrderItems = soiMap.get(opp.Id+oli.Product_ID__c);
                            for(ia_crm__Sales_Order_Item__c soi : SalesOrderItems){
                                if(soi.ia_crm__Price__c == oli.UnitPrice){
                                    xml+=  			'<updatesotransitem line_num="'+soi.Name+'">';
                                    xml+=  				'<customfields>';
                                    xml+=					'<customfield>';
                                    xml+=  						    '<customfieldname>GLDIMSITE_CODE</customfieldname>';
                                    xml+= 							'<customfieldvalue>'+siteCodeMap.get(Oli.Site_Code__c).ia_crm__Intacct_Id__c+'</customfieldvalue>';
                                    xml+=  					'</customfield>';
                                    xml+=				'</customfields>';
                                    xml+=  			'</updatesotransitem>';
                                }
                            }
                        }
                    }
                    xml+= 				  '</updatesotransitems>';
                    xml+=  				'</update_sotransaction>';
                    xml+=  			'</function>';
                    xml+=  		'</content>';
                    xml+=  	'</operation>';
                }
            }
            xml+= '</request>';
            
            return callOutMethod(xml);
        }
        return '<< == Authentication Error == >>';
    }
    
    public static string updateOppFieldsLineItems(Map<String,List<OpportunityLineItem>> OppIdOLIMap,List<String> fieldsList){
        
        Map<String,List<ia_crm__Sales_Order_Item__c>> soiMap = new Map<String,List<ia_crm__Sales_Order_Item__c>>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        Set<Id> siteCodeSet = new Set<Id>();
        Map<String,String> customFieldMappingMap = new Map<String,String>();
        Map<String,Date> customFieldDateMappingMap = new Map<String,Date>();
        List<Opportunity> oppList = [SELECT Id,Display_Invoice_Number__c,ia_crm__Intacct_Transaction__c,
                                     (SELECT Id,ProductCode,Product_ID__c,UnitPrice
                                      FROM OpportunityLineItems),
                                     (SELECT id,Name,Is_Sage_Field_Updated__c,ia_crm__Sales_Order__r.Name,ia_crm__Item__c,ia_crm__Opportunity__c,ia_crm__Price__c
                                      FROM R00N40000001bdmZEAQ) 
                                     FROM Opportunity WHERE Id IN: OppIdOLIMap.keySet()];
        
        for(Opportunity opp : oppList){
            for(ia_crm__Sales_Order_Item__c soi : opp.R00N40000001bdmZEAQ){
                if(soi.Is_Sage_Field_Updated__c == false){
                if(soiMap.containskey(opp.Id+soi.ia_crm__Item__c)){
                    List<ia_crm__Sales_Order_Item__c> soiList = soiMap.get(opp.Id+soi.ia_crm__Item__c);
                    soiList.add(soi);
                    soiMap.put(opp.Id+soi.ia_crm__Item__c,soiList);
                }else{
                    soiMap.put(opp.Id+soi.ia_crm__Item__c,new List<ia_crm__Sales_Order_Item__c>{soi});
                }
                }
            }
            oliList.addAll(OppIdOLIMap.get(opp.Id));
        } 
       
        for(OpportunityLineItem oli : oliList){
            siteCodeSet.add(oli.Site_Code__c);
			 if(oli.Sage_Shipping_Country__c != null)
                customFieldMappingMap.put(oli.id+'SHIPPING_COUNTRY',oli.Sage_Shipping_Country__c);
            if(oli.Sage_Shipping_State__c != null)
                customFieldMappingMap.put(oli.id+'SHIPPING_STATE',oli.Sage_Shipping_State__c);
            if(oli.Sage_Reporting_Country__c != null)
                customFieldMappingMap.put(oli.id+'BILLING_COUNTRY',oli.Sage_Reporting_Country__c);
             if(oli.Sage_Reporting_State__c != null)
                customFieldMappingMap.put(oli.id+'BILLING_STATE',oli.Sage_Reporting_State__c);
            if(oli.Tax_Authority__c != null)
                customFieldMappingMap.put(oli.id+'TAX_AUTHORITY',oli.Tax_Authority__c);
            if(oli.ia_crm__Intacct_Location__c != null)
                customFieldMappingMap.put(oli.id+'LOCATIONId',oli.ia_crm__Intacct_Location__r.ia_crm__Intacct_Entity_ID__c);
            if(oli.ia_crm__Department__c != null)
                customFieldMappingMap.put(oli.id+'DEPARTMENTID',oli.ia_crm__Department__r.ia_crm__Department_ID__c); 
            if(oli.Quantity >0)
                customFieldMappingMap.put(oli.id+'QUANTITY',oli.Quantity+'');
            if(oli.ia_crm__Class__c != null)
                customFieldMappingMap.put(oli.id+'CLASSID',oli.ia_crm__Class__r.ia_crm__Class_ID__c);
            if(oli.Intacct_Template__c != null)
                customFieldMappingMap.put(oli.id+'revrectemplate',oli.Intacct_Template__r.Name); 
            if(oli.ia_crm__Project__c != null)
                customFieldMappingMap.put(oli.id+'projectid',oli.ia_crm__Project__r.ia_crm__Project_ID__c);
            if(oli.Vendor_ID__c != null)
                customFieldMappingMap.put(oli.id+'vendorid',oli.Vendor_ID__c);
            if(oli.Tax_Region__c != null)
                customFieldMappingMap.put(oli.id+'TAX_REGION',oli.Tax_Region__c);
            if(oli.ServiceDate != null)
                customFieldDateMappingMap.put(oli.id+'revrecstartdate',oli.ServiceDate);
            if(oli.ia_crm__Service_End_Date__c != null)
                customFieldDateMappingMap.put(oli.id+'revrecenddate',oli.ia_crm__Service_End_Date__c);
            
        }
        
        Map<Id,ia_crm__Intacct_User_Dimension__c> siteCodeMap = new Map<Id,ia_crm__Intacct_User_Dimension__c>([Select Id,ia_crm__Intacct_Id__c 
                                                                                                               from ia_crm__Intacct_User_Dimension__c 
                                                                                                               where Id IN: siteCodeSet]);
        
        Decimal dtdversion = 3.0;
        Boolean uniqueid = false;
        String authResult = authentication();
		List<ia_crm__Sales_Order_Item__c> updateSalesOrderItem = new List<ia_crm__Sales_Order_Item__c>();      
        if(!authResult.startsWith('Failed##')){
            DOM.Document doc = new DOM.Document();
            DOM.XMLNode responseNode;
            doc.load(authResult);
            responseNode = doc.getRootElement();
            string sessionid = responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('data',null).getChildElement('api',null).getChildElement('sessionid',null).gettext();
            
            Sage_API__mdt sageMDt = [SELECT senderid__c, ctrlpassword__c, controlid__c, userid__c,Companyid__c,
                                     password__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
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
            for (Opportunity opp : oppList){
                if(!opp.R00N40000001bdmZEAQ.isEmpty()){
                    xml+=  		'<operation transaction="false">';
                    xml+=  			'<authentication>'; 
                    xml+=				'<sessionid>'+sessionid+'</sessionid>';
                    xml+=  			'</authentication>';
                    xml+=  			'<content>';
                    xml+=  	 	  '<function controlid="'+opp.Id+'">';
                    System.debug('opp.ChargentSFA__Invoice_Number__c::>>   '+opp.Display_Invoice_Number__c);
                    
                    xml+=		'<update_sotransaction key="'+opp.ia_crm__Intacct_Transaction__c+'-'+opp.Display_Invoice_Number__c+'">';
                    xml+= 		 '<updatesotransitems>';    
                    
                    for(OpportunityLineItem oli : OppIdOLIMap.get(opp.Id)){
                        if(soiMap.containsKey(opp.Id+oli.Product_ID__c)){
                            List<ia_crm__Sales_Order_Item__c> SalesOrderItems = soiMap.get(opp.Id+oli.Product_ID__c);
                            for(ia_crm__Sales_Order_Item__c soi : SalesOrderItems){ 
                                if(soi.ia_crm__Price__c == oli.UnitPrice){
                                    xml+=  			'<updatesotransitem line_num="'+soi.Name+'">';
                                    xml+=  				'<customfields>';
                                    xml+=					'<customfield>';  
                                    xml+=  						    '<customfieldname>GLDIMSITE_CODE</customfieldname>';
                                    xml+= 							'<customfieldvalue>'+siteCodeMap.get(Oli.Site_Code__c).ia_crm__Intacct_Id__c+'</customfieldvalue>';
                                    xml+=  					'</customfield>';
                                    for(String fldname:fieldsList){
                                        String key = oli.Id+fldname;
                                        if(customFieldMappingMap.containsKey(key)){
                                            xml+=	'<customfield>'; 
                                            xml+= '<customfieldname>'+fldname+'</customfieldname>'; 
                                            xml+= '<customfieldvalue>'+customFieldMappingMap.get(key)+'</customfieldvalue>'; 
                                            xml+= '</customfield>';
                                        }
                                    }
                                    xml+=				'</customfields>'; 
                                    for(String fldname:fieldsList){
                                        String key = oli.Id+fldname;
                                        if(customFieldDateMappingMap.containsKey(key)){
                                            xml+= '<'+fldname+'>'; 
                                            xml+= '<year>'+customFieldDateMappingMap.get(key).year()+'</year>'; 
                                            xml+= '<month>'+customFieldDateMappingMap.get(key).month()+'</month>'; 
                                            xml+= '<day>'+customFieldDateMappingMap.get(key).day()+'</day>'; 
                                            xml+= '</'+fldname+'>';
                                        }
                                    }
                                    xml+=  			'</updatesotransitem>';
                                    soi.Is_Sage_Field_Updated__c = true;
                                    updateSalesOrderItem.add(soi);
                                    break;
                                }
                            }
                        }
                    }
                    xml+= 				  '</updatesotransitems>';
                    xml+=  				'</update_sotransaction>';
                    xml+=  			'</function>';
                    xml+=  		'</content>';
                    xml+=  	'</operation>';
                }
            }
            xml+= '</request>';
            String response = callOutMethod(xml);
            if(updateSalesOrderItem.size() > 0){
                update updateSalesOrderItem;
            }
            return response;
        }
        return '<< == Authentication Error == >>';
    }
    
    public static String callOutMethod(String reqBody) {
        
        Sage_API__mdt sageMDt = [SELECT EndPoint__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
        
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        
        req.setEndpoint(sageMDt.EndPoint__c); 
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/xml');
        req.setBody(reqBody);
        req.setTimeOut(120000);
        
        system.debug('request::>>  '+req);
        system.debug('request::>>  '+req.getBody());
        
        String XmlResponse;
        if(Test.isRunningTest()){
            //XmlResponse = '<?xml version="1.0" encoding="UTF-8"?><testing>done!!</testing>';
            XmlResponse = '<?xml version="1.0" encoding="UTF-8"?><response><operation><result><status>success</status> <controlid>testControlId</controlid><data listtype="revrecschedule" count="1" totalcount="1" numremaining="0" resultId=""><revrecschedule><RECORDNO>40</RECORDNO><SOREVRECSTARTDATE>1/1/2022</SOREVRECSTARTDATE></revrecschedule><api><sessionid>test</sessionid></api></data></result></operation></response>';
        }else{
            res = http.send(req);
            XmlResponse = (res.getStatusCode() == 200 || res.getStatusCode() == 201) ? res.getBody() : 'Failed##'+res.getBody();
        }
        system.debug('Response::>>  '+XmlResponse+'  ==>> with response status code ::  '+res.getStatusCode());
        
        return XmlResponse;
    }
    
    
    public static String xmlString(String apiResponseXMLString) {
        if(Test.isRunningTest()){
            apiResponseXMLString = '<response>      <control>            <status>success</status>            <senderid>garp</senderid>            <controlid>ControlIdHere</controlid>           <uniqueid>false</uniqueid>            <dtdversion>3.0</dtdversion>      </control>      <operation>            <authentication>                  <status>success</status>                  <userid>xmlgw-sfdc</userid>                  <companyid>garp</companyid>                  <locationid></locationid>                 <sessiontimestamp>2023-07-27T14:47:02+00:00</sessiontimestamp>                  <sessiontimeout>2023-07-27T20:47:02+00:00</sessiontimeout>            </authentication>           <result>                  <status>failure</status>                  <function>reallocate_revrecschedule</function>                  <controlid>testControlId</controlid>                  <errormessage>                        <error>                              <errorno>BL01001973</errorno>                              <description></description>                              <description2>The reallocation start date can not be before thelast posting date [Support ID: k_ZToEB038%7EZMKDZP0b2xC-qyOWFQHH_QAAAA4]</description2>                              <correction>Please enter valid reallocationdates.</correction>                        </error>                        <error>                              <errorno>BL01001973</errorno>                              <description>Invalid Schedule Key. You may be trying to access a private schedule.</description>                              <description2>0 is not valid revenue recognition schedule key</description2>                             <correction></correction>                        </error>                  </errormessage>            </result>      </operation></response>';
        }else{
            //apiResponseXMLString = '<response>      <control>            <status>success</status>            <senderid>garp</senderid>            <controlid>ControlIdHere</controlid>           <uniqueid>false</uniqueid>            <dtdversion>3.0</dtdversion>      </control>      <operation>            <authentication>                  <status>success</status>                  <userid>xmlgw-sfdc</userid>                  <companyid>garp</companyid>                  <locationid></locationid>                 <sessiontimestamp>2023-07-27T14:47:02+00:00</sessiontimestamp>                  <sessiontimeout>2023-07-27T20:47:02+00:00</sessiontimeout>            </authentication>           <result>                  <status>failure</status>                  <function>reallocate_revrecschedule</function>                  <controlid>testControlId</controlid>                  <errormessage>                        <error>                              <errorno>BL01001973</errorno>                              <description></description>                              <description2>The reallocation start date can not be before thelast posting date [Support ID: k_ZToEB038%7EZMKDZP0b2xC-qyOWFQHH_QAAAA4]</description2>                              <correction>Please enter valid reallocationdates.</correction>                        </error>                        <error>                              <errorno>BL01001973</errorno>                              <description>Invalid Schedule Key. You may be trying to access a private schedule.</description>                              <description2>0 is not valid revenue recognition schedule key</description2>                             <correction></correction>                        </error>                  </errormessage>            </result>      </operation></response>';
        }
        String finalErrMsg = '';
        DOM.Document doc=new DOM.Document();
        doc.load(apiResponseXMLString);
        DOM.XmlNode rootNode = doc.getRootElement();
        system.debug('doc::>>  '+doc);
        system.debug('rootNode::>>  '+rootNode);
        for(DOM.XMLNode Node : rootNode.getChildElements()){
            system.debug('Node.getName()::>>  '+Node.getName());
            if(Node.getName() == 'operation'){
                for(DOM.XMLNode subNode : Node.getChildElements()){
                    system.debug('subNode.getName()::>>  '+subNode.getName());
                    if(subNode.getName() == 'result'){
                        for(DOM.XMLNode subSubNode : subNode.getChildElements()){
                            system.debug('subSubNode.getName()::>>  '+subSubNode.getName());
                            if(subSubNode.getName() == 'errormessage'){
                                for(DOM.XMLNode subSubSubNode : subSubNode.getChildElements()){
                                    system.debug('subSubSubNode.getName()::>>  '+subSubSubNode.getName());
                                    for(DOM.XMLNode finalNode : subSubSubNode.getChildElements()){
                                        system.debug('finalNode.getText()::>>  '+finalNode.getText());
                                        if(String.isNotBlank(finalNode.getText())){
                                            finalErrMsg = finalErrMsg + finalNode.getText()+' ; ';
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        system.debug('finalErrMsg::>>  '+finalErrMsg);
        return finalErrMsg;
    } 
    
    public static String createOppFieldsLineItem(OpportunityLineItem oli){
         
        try{
            List<String> fieldsList = new List<String>{'GLDIMSITE_CODE','locationid','departmentid','classid','SHIPPING_COUNTRY','SHIPPING_STATE',
                'BILLING_COUNTRY','BILLING_STATE','TAX_AUTHORITY','revrectemplate','projectid',
                'vendorid','revrecstartdate','revrecenddate'};   
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
            Set<Id> siteCodeSet = new Set<Id>();
            Map<String,String> customFieldMappingMap = new Map<String,String>();
            Map<String,Date> customFieldDateMappingMap = new Map<String,Date>(); 
            if(oli.Site_Code__c != null) 
                customFieldMappingMap.put(oli.id+'GLDIMSITE_CODE',oli.Site_Code__r.ia_crm__Intacct_Id__c); 
            if(oli.Sage_Shipping_Country__c != null)
                customFieldMappingMap.put(oli.id+'SHIPPING_COUNTRY',oli.Sage_Shipping_Country__c);
            if(oli.Sage_Shipping_State__c != null)
                customFieldMappingMap.put(oli.id+'SHIPPING_STATE',oli.Sage_Shipping_State__c);
            if(oli.Sage_Reporting_Country__c != null)
                customFieldMappingMap.put(oli.id+'BILLING_COUNTRY',oli.Sage_Reporting_Country__c);
            if(oli.Sage_Reporting_State__c != null)
                customFieldMappingMap.put(oli.id+'BILLING_STATE',oli.Sage_Reporting_State__c);
            if(oli.Tax_Authority__c != null)
                customFieldMappingMap.put(oli.id+'TAX_AUTHORITY',oli.Tax_Authority__c);
            if(oli.ia_crm__Intacct_Location__c != null)
                customFieldMappingMap.put(oli.id+'locationid',oli.ia_crm__Intacct_Location__r.ia_crm__Intacct_Entity_ID__c);
            if(oli.ia_crm__Department__c != null)
                customFieldMappingMap.put(oli.id+'departmentid',oli.ia_crm__Department__r.ia_crm__Department_ID__c); 
            if(oli.ia_crm__Class__c != null)
                customFieldMappingMap.put(oli.id+'classid',oli.ia_crm__Class__r.ia_crm__Class_ID__c);
            if(oli.Intacct_Template__c != null)
                customFieldMappingMap.put(oli.id+'revrectemplate',oli.Intacct_Template__r.Name); 
            if(oli.ia_crm__Project__c != null)
                customFieldMappingMap.put(oli.id+'projectid',oli.ia_crm__Project__r.ia_crm__Project_ID__c);
            if(oli.Vendor_ID__c != null)
                customFieldMappingMap.put(oli.id+'vendorid',oli.Vendor_ID__c);
            if(oli.Tax_Region__c != null)
                customFieldMappingMap.put(oli.id+'TAX_REGION',oli.Tax_Region__c);
            if(oli.ServiceDate != null)
                customFieldDateMappingMap.put(oli.id+'revrecstartdate',oli.ServiceDate);
            if(oli.ia_crm__Service_End_Date__c != null)
                customFieldDateMappingMap.put(oli.id+'revrecenddate',oli.ia_crm__Service_End_Date__c);
            
            
            
            Decimal dtdversion = 3.0;
            Boolean uniqueid = false;
            String authResult = authentication();      
            if(!authResult.startsWith('Failed##')){
                DOM.Document doc = new DOM.Document();
                DOM.XMLNode responseNode;
                doc.load(authResult);
                responseNode = doc.getRootElement();
                string sessionid = responseNode.getChildElement('operation',null).getChildElement('result',null).getChildElement('data',null).getChildElement('api',null).getChildElement('sessionid',null).gettext();
                
                Sage_API__mdt sageMDt = [SELECT senderid__c, ctrlpassword__c, controlid__c, userid__c,Companyid__c,
                                         password__c FROM Sage_API__mdt where DeveloperName = 'Sage_API'];
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
                xml+=				'<sessionid>'+sessionid+'</sessionid>';
                xml+=  			'</authentication>';
                xml+=  			'<content>';
                xml+=  	 	  '<function controlid="'+oli.OpportunityId+'">'; 
                
                xml+=		'<update_sotransaction key="'+oli.Opportunity.ia_crm__Intacct_Transaction__c+'-'+oli.Opportunity.Display_Invoice_Number__c+'">';
                xml+= 		 '<updatesotransitems>';    
                
                
                xml+=  			'<sotransitem>';
                xml+=  		   	'<itemid>'+oli.Product_ID__c+'</itemid>';
                xml+=  		   	'<quantity>'+oli.Quantity+'</quantity>';
                xml+=  		   	'<unit>Count</unit>';
                xml+=  		   	'<price>'+oli.TotalPrice+'</price>';
                xml+=  				'<customfields>'; 
                for(String fldname:fieldsList){
                    String key = oli.Id+fldname;
                    if(customFieldMappingMap.containsKey(key)){
                        xml+=	'<customfield>'; 
                        xml+= '<customfieldname>'+fldname+'</customfieldname>'; 
                        xml+= '<customfieldvalue>'+customFieldMappingMap.get(key)+'</customfieldvalue>'; 
                        xml+= '</customfield>';
                    }
                }
                xml+=				'</customfields>'; 
                for(String fldname:fieldsList){
                    String key = oli.Id+fldname;
                    if(customFieldDateMappingMap.containsKey(key)){
                        xml+= '<'+fldname+'>'; 
                        xml+= '<year>'+customFieldDateMappingMap.get(key).year()+'</year>'; 
                        xml+= '<month>'+customFieldDateMappingMap.get(key).month()+'</month>'; 
                        xml+= '<day>'+customFieldDateMappingMap.get(key).day()+'</day>'; 
                        xml+= '</'+fldname+'>';
                    }
                }
                xml+=  			'</sotransitem>'; 
                xml+= 				  '</updatesotransitems>';
                xml+=  				'</update_sotransaction>';
                xml+=  			'</function>';
                xml+=  		'</content>';
                xml+=  	'</operation>';  
                xml+= '</request>';
                String response = callOutMethod(xml);  
                return response;
            }else{ 
                return 'Auth Error';
            } 
        }catch(Exception ex){
            system.debug(ex.getMessage());
            return 'Exception';
        }
    }
}