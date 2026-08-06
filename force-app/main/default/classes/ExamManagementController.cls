public class ExamManagementController {
    
    public Enum DeferralAction { DEFER, UNDEFER }
    public static final Schema.SObjectType orderTransaction = Schema.ChargentOrders__Transaction__c.getSObjectType();
    public static final Schema.SObjectType legacyTransaction = Schema.Legacy_Transaction__c.getSObjectType();
    
    public static Exam_Attempt__c fetchExamRegistrationInContext(Id examRegistrationId){
        
        List<Exam_Attempt__c> examRegistrations = [
            SELECT
                Id, 
                Cloned_From__c,
                Cloned_From__r.Exam_Site__r.Exam__r.Exam__c,
                Cloned_From__r.Other_Exam_Registrations__r.Reg_Status__c,
                Cloned_From__r.Other_Exam_Registrations__r.Exam_Site__r.Exam__r.Exam__c,
                Opportunity__c, 
                Defered__c,
                Reg_Status__c,
                Cancelled__c,
                Member__c, 
                Exam_Type__c, 
                Exam_Site__c, 
                Exam_Site__r.Name, 
                Exam_Site__r.Exam__r.Exam__c, 
                Exam_Site__r.Site__c, 
                Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,
                Exam_Site__r.Site__r.Is_Gender_Required__c,
                Exam_Site__r.Site__r.Display_Address__c, 
                Exam_Site__r.Exam__r.Exam_Group__r.Active__c,
                (
                    SELECT 
                    Id, Name, CreatedDate, ProductCode, Product2Id, TotalPrice, Event__c, Exam_Site__c, Exam_Registration__c, OpportunityId, UnitPrice, Quantity, Opportunity.AccountId, Opportunity.Program_Name__c, Description
                    FROM Opportunity_Line_Items__r
                    WHERE ProductCode = 'CHLF' AND Opportunity.StageName = 'Closed'
                    ORDER BY CreatedDate DESC
                )  
            FROM Exam_Attempt__c 
            WHERE Id = :examRegistrationId
            LIMIT 1
        ];        
        
        return (!examRegistrations.isEmpty()) ? examRegistrations[0] : null;
        
    }
       
    public static Map<Id, Exam_Attempt__c> getExamRegistrationByContactIdAndTestSiteId(String contactId, String testSiteId){
        
        /**
         * Get all CHLF Opportunity Line Items for all child Closed Opportunities
         * associated with all retrieved Exam Registrations and place in a map by Exam Registration ID
        **/ 
        
        Map<Id, Exam_Attempt__c> examRegistrationMap = new Map<Id, Exam_Attempt__c>([
            SELECT 
                Id, 
                Cloned_From__c,
                Cloned_From__r.Exam_Site__r.Exam__r.Exam__c,
                Cloned_From__r.Other_Exam_Registrations__r.Reg_Status__c,
                Cloned_From__r.Other_Exam_Registrations__r.Exam_Site__r.Exam__r.Exam__c,
                Opportunity__c, 
                Defered__c,
                Reg_Status__c,
                Cancelled__c,
                Member__c, 
                Exam_Type__c, 
                Exam_Site__c, 
                Exam_Site__r.Name, 
                Exam_Site__r.Exam__r.Exam__c, 
                Exam_Site__r.Site__c, 
                Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,
                Exam_Site__r.Site__r.Is_Gender_Required__c,
                Exam_Site__r.Site__r.Display_Address__c, 
                Exam_Site__r.Exam__r.Exam_Group__r.Active__c,
                (
                    SELECT 
                    Id, Name, CreatedDate, ProductCode, Product2Id, TotalPrice, Event__c, Exam_Site__c, Exam_Registration__c, OpportunityId, UnitPrice, Quantity, Opportunity.AccountId, Opportunity.Program_Name__c, Description
                    FROM Opportunity_Line_Items__r
                    WHERE ProductCode = 'CHLF' AND Opportunity.StageName = 'Closed'
                    ORDER BY CreatedDate DESC
                )           
            FROM Exam_Attempt__c 
            WHERE
            Exam_Site__r.Exam__r.Exam_Group__r.Active__c = TRUE AND
            Member__c = :contactId AND 
            Cancelled__c = FALSE AND
            Opportunity__r.StageName = 'Closed'
            ORDER BY Exam_Site__r.Exam__r.Exam__c ASC
        ]);
        
        Set<Id> clonedFromIds = new Set<Id>();
        for(Exam_Attempt__c examRegistration: examRegistrationMap.values()){
            if(examRegistration.Cloned_From__c != null){
                clonedFromIds.add(examRegistration.Cloned_From__c);
            }
        }
        
        if(!clonedFromIds.isEmpty()){
            examRegistrationMap.putAll([
                SELECT 
                    Id, 
                    Cloned_From__c,
                    Cloned_From__r.Exam_Site__r.Exam__r.Exam__c,
                    Cloned_From__r.Other_Exam_Registrations__r.Reg_Status__c,
                    Cloned_From__r.Other_Exam_Registrations__r.Exam_Site__r.Exam__r.Exam__c,
                    Opportunity__c, 
                    Defered__c,
                    Reg_Status__c, 
                    Member__c,
                    Cancelled__c,
                    Exam_Type__c, 
                    Exam_Site__c, 
                    Exam_Site__r.Name, 
                    Exam_Site__r.Exam__r.Exam__c, 
                    Exam_Site__r.Site__c, 
                    Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,
                    Exam_Site__r.Site__r.Is_Gender_Required__c,
                    Exam_Site__r.Site__r.Display_Address__c, 
                    Exam_Site__r.Exam__r.Exam_Group__r.Active__c,
                    (
                        SELECT 
                        Id, Name, CreatedDate, ProductCode, Product2Id, TotalPrice, Event__c, Exam_Site__c, Exam_Registration__c, OpportunityId, UnitPrice, Quantity, Opportunity.AccountId, Opportunity.Program_Name__c, Description
                        FROM Opportunity_Line_Items__r
                        WHERE ProductCode = 'CHLF' AND Opportunity.StageName = 'Closed'
                        ORDER BY CreatedDate DESC
                    )           
                FROM Exam_Attempt__c 
                WHERE Id IN :clonedFromIds
            ]);
        }
        
        return examRegistrationMap;
       
    }
    
    public static Map<Id, List<OpportunityLineItem>> getOpportunityLineItemByOpportunityIdMap(Set<Id> opportunityIds){
        
        /**
         * Get all CHLF Opportunity Line Items for all parent or child Closed Opportunities
         * associated with all retrieved Exam Registrations and place in a map by OpportunityId
        **/  
       
        Map<Id, List<OpportunityLineItem>> opportunityLineItemByOpportunityId = new Map<Id, List<OpportunityLineItem>>();            
        for(OpportunityLineItem opportunityLineItem: [
            SELECT 
            Id, Name, CreatedDate, ProductCode, Product2Id, TotalPrice, Event__c, OpportunityId, Opportunity.StageName, UnitPrice, Quantity, Opportunity.AccountId, Opportunity.Program_Name__c, Description, Exam_Registration__r.Result__c
            FROM OpportunityLineItem
            WHERE 
                OpportunityId IN :opportunityIds AND 
                ProductCode = 'CHLF' AND 
                Opportunity.StageName = 'Closed' AND
                Exam_Registration__r.Result__c = NULL
            ORDER BY CreatedDate DESC
        ]){
            Id opportunityId = opportunityLineItem.OpportunityId;
            if(opportunityLineItemByOpportunityId.containsKey(OpportunityId)){
                opportunityLineItemByOpportunityId.get(opportunityId).add(opportunityLineItem);
            }else{               
                opportunityLineItemByOpportunityId.put(opportunityId, new List<OpportunityLineItem>{opportunityLineItem});  
            }
        } 
        
        return opportunityLineItemByOpportunityId;
        
    }
    
    public static Map<Id, List<Product_Refunds__c>> getProductRefundsByOpportunityIdMap(Set<Id> opportunityIds){
        
        /**
         * Get all CHLF Product Refunds for all parent or child Closed Opportunities
         * associated with all retrieved Exam Registrations and place in a map by OpportunityId
        **/ 
        
        Map<Id, List<Product_Refunds__c>> productRefundsByOpportunityId = new Map<Id, List<Product_Refunds__c>>();        
        for(Product_Refunds__c productRefund :[
            SELECT  Id, Reason__c, Opportunity_Product_ID__c, Name, GL_Code__c, Product_Code__c, Opportunity__c, Opportunity__r.StageName
            FROM Product_Refunds__c 
            WHERE Opportunity__c IN :opportunityIds AND Product_Code__c = 'CHLF' AND Opportunity__r.StageName = 'Closed'
        ]){            
            Id opportunityId = productRefund.Opportunity__c;
            if(productRefundsByOpportunityId.containsKey(opportunityId)){
                productRefundsByOpportunityId.get(opportunityId).add(productRefund);                    
            }else{
                productRefundsByOpportunityId.put(opportunityId, new List<Product_Refunds__c>{productRefund}); 
            }   
        }  
        
        return productRefundsByOpportunityId;
        
    }
    
    public static Exam_Sites__c getNewExamSite(Id newExamSiteId){
        
        List<Exam_Sites__c> examSites = [
            SELECT Id, Name, Exam__c, Site__r.Display_Address__c, Site__c, Exam__r.Exam__c, 
            Site__r.Is_OSTA_Information_Required__c, 
            Site__r.Is_Gender_Required__c
            FROM Exam_Sites__c 
            WHERE Id = :newExamSiteId
        ];   
        
        return (!examSites.isEmpty()) ? examSites[0] : null;
        
    }
    
    public static Map<String, Exam_Sites__c> getExamSiteByExamTypeMap(Id testSiteId){
        
        /**
         * Retrieves all Exam Sites for a specific Test Site (Site__c)
         * and creates a map by the Exam Name (i.e. FRM Part 1 or ERP Part II etc...)
        **/ 
        
        Map<String, Exam_Sites__c> examSiteByExamType = new Map<String, Exam_Sites__c>();
        for(Exam_Sites__c examSite: [
            SELECT Id, Site__c, 
            Site__r.Is_OSTA_Information_Required__c, 
            Site__r.Is_Gender_Required__c, Exam__r.Exam__c
            FROM Exam_Sites__c  
            WHERE Site__c = :testSiteId
        ]){
            examSiteByExamType.put(examSite.Exam__r.Exam__c, examSite);
        }
        
        return examSiteByExamType;
        
    }
    
    public static Set<Id> getAllOpportunityIdsByExamRegistration(Exam_Attempt__c examRegistration){
        
        /**
         * Get all Opportunity IDs that are a parent (Opportunity__c) or 
         * child (Opportunity_Line_Items__r => OpportunityId) of the Exam Registration
        **/ 
        
        Set<Id> opportunityIds = new Set<Id>();
        
        opportunityIds.add(examRegistration.Opportunity__c);
        
        if(examRegistration.Opportunity_Line_Items__r != null){
            for(OpportunityLineItem oli: examRegistration.Opportunity_Line_Items__r){
                opportunityIds.add(oli.OpportunityId);
            }
        }
        
        return opportunityIds;
        
    }
    
    public static Set<Id> getAllOpportunityIdsByExamRegistrations(List<Exam_Attempt__c> examRegistrations){
        
        /**
         * Get all Opportunity IDs that are a parent (Opportunity__c) or 
         * child (Opportunity_Line_Items__r => OpportunityId) of the Exam Registrations
        **/ 
        
        Set<Id> opportunityIds = new Set<Id>();
        
        for(Exam_Attempt__c examRegistration: examRegistrations){
            opportunityIds.add(examRegistration.Opportunity__c); 
            if(examRegistration.Opportunity_Line_Items__r != null){
                for(OpportunityLineItem oli: examRegistration.Opportunity_Line_Items__r){
                    opportunityIds.add(oli.OpportunityId);
                }
            }            
        }      
        
        
        /**
        * Excludes the Exam_Attempt__c parent Opportunity Id in the
        * below scenario.  This covers an edge case, where the 
        * Opportunity is incorrectly being included for a refund.
        **/
        for(Exam_Attempt__c examRegistration: examRegistrations){
            if(
                examRegistration.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2' &&
                examRegistration.Reg_Status__c == 'Deferred In' && 
                examRegistration.Cloned_From__r.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2' &&
                examRegistration.Cloned_From__r.Other_Exam_Registrations__r.Reg_Status__c != 'Deferred Out' && 
                examRegistration.Cloned_From__r.Other_Exam_Registrations__r.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1'
            ){
                opportunityIds.remove(examRegistration.Opportunity__c);
            }
        }
        
        return opportunityIds;
        
    }
    
     public static Map<Id, sObject> getApprovedTransactionByOpportunityIdMap(Set<Id> opportunityIds){
        
        
         System.Debug('opportunityIds:' + opportunityIds);
         
         List<ChargentOrders__Transaction__c> transactions = [
             SELECT Id, Opportunity__c, ChargentOrders__Response_Status__c, ChargentOrders__Amount__c 
             FROM ChargentOrders__Transaction__c 
             WHERE Opportunity__c IN :opportunityIds AND ChargentOrders__Response_Status__c = 'Approved'
             ORDER BY ChargentOrders__Amount__c ASC
         ];
         
         List<Legacy_Transaction__c> transactionsSfa = [
             SELECT Id, Opportunity__c, Response_Status__c, Amount__c 
             FROM Legacy_Transaction__c 
             WHERE Opportunity__c IN :opportunityIds AND Response_Status__c = 'Approved'
             ORDER BY Amount__c ASC
         ];
         
         System.Debug('transactions :' + transactions );
         
         Map<Id, sObject> approvedTransactionByOpportunityId = new Map<Id, sObject>();
         for(ChargentOrders__Transaction__c ct: transactions){
             approvedTransactionByOpportunityId.put(ct.Opportunity__c,  ct);
         }
         
         for(Legacy_Transaction__c ct: transactionsSfa){
             if(!approvedTransactionByOpportunityId.containskey(ct.Opportunity__c)){
                 approvedTransactionByOpportunityId.put(ct.Opportunity__c,  ct);
             }
         }
         
         System.Debug('approvedTransactionByOpportunityId:' + approvedTransactionByOpportunityId);
         
         return approvedTransactionByOpportunityId;
        
    }
    
    public static Integer getExamPartNumber(String examName){
        switch on examName{
            when 'FRM Part 1'{
                return 1;
            }
            when 'FRM Part 2'{
                return 2;
            }
            when 'ERP Exam Part I'{
                return 1;
            }
            when 'ERP Exam Part II'{
                return 2;
            }
            when else{
                return null;
            }
        }
    }
    
    public static Integer computeNumberOfExamRegistrationsInActiveCycle(List<Exam_Attempt__c> examRegistrations){
        
        Integer numberOfExamRegistrations = 0;
        for(Exam_Attempt__c examRegistration: examRegistrations){
            if(examRegistration.Exam_Site__r.Exam__r.Exam_Group__r.Active__c){
                numberOfExamRegistrations++;
            }
        }     
        
        return numberOfExamRegistrations;
                
    }
    
    public static Integer computeNumberOfDeferredOutExamRegistrationsInActiveCycle(List<Exam_Attempt__c> examRegistrations){
        
        Integer numberOfExamRegistrationsDeferredOut = 0;
        for(Exam_Attempt__c examRegistration: examRegistrations){
            if(
                examRegistration.Exam_Site__r.Exam__r.Exam_Group__r.Active__c && 
                (examRegistration.Reg_Status__c == 'Deferred Out Pending' || examRegistration.Reg_Status__c == 'Deferred Out')
            ){
                numberOfExamRegistrationsDeferredOut++;
            }
        }    
        
        return numberOfExamRegistrationsDeferredOut;
                
    }
    
    public static List<Product_Refunds__c> createChinaDataFeeProductRefunds(Id contactId){
        
        List<Contact> contacts = [
            SELECT Id, AccountId
            FROM Contact
            WHERE Id = :contactId
        ];
        
        List<Contract> ostaContracts = [
            SELECT Id, Name, Status, RecordType.Name, OSTA_Last_Upload_Date__c,
            (
                SELECT Id, UnitPrice, Product2Id, OpportunityId, Description, Quantity
                FROM Program_Fees__r
                WHERE ProductCode = 'CHNDF'
            )
            FROM Contract
            WHERE 
            RecordType.Name = 'OSTA Program' AND
            AccountId = :contacts[0].AccountId AND
            Status LIKE 'Activated%'
        ];
        
        List<Product_Refunds__c> toInsert = new List<Product_Refunds__c>();
        
        if(!ostaContracts.isEmpty() && ostaContracts[0].OSTA_Last_Upload_Date__c == null){
        
            Set<Id> opportunityIds = new Set<Id>();
            for(OpportunityLineItem ostaFee: ostaContracts[0].Program_Fees__r){
                opportunityIds.add(ostaFee.OpportunityId);
            }
            
            System.Debug('opportunityIds:' + opportunityIds);
            
            Map<Id, sObject> approvedTransactionByOpportunityId = getApprovedTransactionByOpportunityIdMap(opportunityIds);
            
            System.Debug('approvedTransactionByOpportunityId:' + approvedTransactionByOpportunityId );

            for(OpportunityLineItem ostaFee: ostaContracts[0].Program_Fees__r){
                
                Product_Refunds__c productRefund = new Product_Refunds__c();
                
                productRefund.Payment_Order_Transaction__c    = null;
                productRefund.Legacy_Transaction__c = null;
                productRefund.Status__c                 = 'Submitted';
                productRefund.Product__c                = ostaFee.Product2Id;
                productRefund.Opportunity__c            = ostaFee.OpportunityId;         
                productRefund.Reason__c                 = ostaFee.Description;
                productRefund.Refund_Amount__c          = (ostaFee.UnitPrice*ostaFee.Quantity).setScale(2);
                productRefund.Sales_Price__c            = (ostaFee.UnitPrice*ostaFee.Quantity).setScale(2);
                productRefund.Opportunity_Product_ID__c = ostaFee.Id;
                
                System.Debug('ostaFee:' + ostaFee);
                
                if(approvedTransactionByOpportunityId.containsKey(ostaFee.OpportunityId)){
                    sObject trans = approvedTransactionByOpportunityId.get(ostaFee.OpportunityId);
                    if(trans.getSobjectType() == orderTransaction){
                        productRefund.Payment_Order_Transaction__c = (Id)trans.get('Id');
                    }else if(trans.getSobjectType() == legacyTransaction){
                        productRefund.Legacy_Transaction__c = (Id)trans.get('Id');
                    }
                }
                
                toInsert.add(productRefund);
                
            }
            
            ostaContracts[0].Status = 'Canceled';
            
            UPDATE ostaContracts[0];
            
        }
        
        return toInsert;
        
    }
    
    public static List<Product_Refunds__c> createChinaLocationFeeProductRefunds(Map<Id, Exam_Attempt__c> examRegistrations, Set<Id> opportunityIds){

        Map<Id, List<OpportunityLineItem>> opportunityLineItemByOpportunityId   = getOpportunityLineItemByOpportunityIdMap(opportunityIds);
        Map<Id, List<Product_Refunds__c>> productRefundsByOpportunityId         = getProductRefundsByOpportunityIdMap(opportunityIds);
        Map<Id, sObject> approvedTransactionByOpportunityId = getApprovedTransactionByOpportunityIdMap(opportunityIds);
        
        Map<Id, Map<Id, Product_Refunds__c>> productRefundsByOpportunityLineItemByOpportunityId = new Map<Id, Map<Id, Product_Refunds__c>>();
        for(List<Product_Refunds__c> productRefunds: productRefundsByOpportunityId.values()){
            for(Product_Refunds__c productRefund: productRefunds){
                if(productRefundsByOpportunityLineItemByOpportunityId.containsKey(productRefund.Opportunity__c)){
                    productRefundsByOpportunityLineItemByOpportunityId.get(productRefund.Opportunity__c).put((Id)productRefund.Opportunity_Product_ID__c, productRefund);
                }else{
                    productRefundsByOpportunityLineItemByOpportunityId.put(productRefund.Opportunity__c, new Map<Id, Product_Refunds__c>{(Id)productRefund.Opportunity_Product_ID__c => productRefund});
                }                
            }
        }
        
        Map<Id, Product_Refunds__c> productRefundByUniqueOpportunityLineItem = new Map<Id, Product_Refunds__c>();
        
        for(Exam_Attempt__c examRegistration: examRegistrations.values()){
            
            Id opportunityId = examRegistration.Opportunity__c;
            
            List<OpportunityLineItem> locationFees = null;
            if(opportunityLineItemByOpportunityId.containsKey(opportunityId)){
                locationFees = opportunityLineItemByOpportunityId.get(opportunityId);
            }
            
            if(examRegistration.Opportunity_Line_Items__r != null && !examRegistration.Opportunity_Line_Items__r.isEmpty()){
                locationFees = examRegistration.Opportunity_Line_Items__r;
            }   
                        
            if(locationFees != null && !locationFees.isEmpty()){
                for(OpportunityLineItem locationFee: locationFees){
                    
                    if(!productRefundsByOpportunityLineItemByOpportunityId.containsKey(locationFee.OpportunityId)){
                        
                        /**
                         * Applying a refund before any CHLF refunds
                         * have been applied.
                         */ 
                        
                        Product_Refunds__c productRefund = new Product_Refunds__c();
                        
                        productRefund.Payment_Order_Transaction__c    = null;
                        productRefund.Legacy_Transaction__c = null;
                        productRefund.Status__c                 = 'Submitted';
                        productRefund.Product__c                = locationFee.Product2Id;
                        productRefund.Opportunity__c            = locationFee.OpportunityId;         
                        productRefund.Reason__c                 = locationFee.Description;
                        productRefund.Refund_Amount__c          = (locationFee.UnitPrice*locationFee.Quantity).setScale(2);
                        productRefund.Sales_Price__c            = (locationFee.UnitPrice*locationFee.Quantity).setScale(2);
                        productRefund.Opportunity_Product_ID__c = locationFee.Id;
                        
                        if(approvedTransactionByOpportunityId.containsKey(locationFee.OpportunityId)){
                            sObject trans = approvedTransactionByOpportunityId.get(locationFee.OpportunityId);
                            if(trans.getSobjectType() == orderTransaction){
                                productRefund.Payment_Order_Transaction__c = (Id)trans.get('Id');
                            }else if(trans.getSobjectType() == legacyTransaction){
                                productRefund.Legacy_Transaction__c = (Id)trans.get('Id');
                            }
                        }
                        
                        productRefundByUniqueOpportunityLineItem.put(locationFee.Id, productRefund);                              
                        
                    }else{
                        
                        /**
                         * Applying a refund after a partial CHLF refund
                         * has been applied to a single opportunity.
                         */                      

                        Map<Id, Product_Refunds__c> productRefundByOpportunityProductId = productRefundsByOpportunityLineItemByOpportunityId.get(locationFee.OpportunityId);
                        
                        /**
                         * Creates a map of all Product Refunds
                         * missing Opportunity_Product_ID__c, to prevent the creation of
                         * unecessary refunds because Opportunity_Product_ID__c is null
                         */ 
                        Map<Id, Product_Refunds__c> productRefundMissingOpportunityProductId = new Map<Id, Product_Refunds__c>();
                        for(Product_Refunds__c productRefund: productRefundByOpportunityProductId.values()){
                            if(productRefund.Opportunity_Product_ID__c == null){
                                productRefundMissingOpportunityProductId.put(productRefund.Id, productRefund);
                            }
                        }
                        
                        if(
                            productRefundByOpportunityProductId != null && 
                            !productRefundByOpportunityProductId.containsKey(locationFee.Id) && 
                            !productRefundMissingOpportunityProductId.containsKey(locationFee.Id)
                        ){
                            
                            Product_Refunds__c productRefund = new Product_Refunds__c();
                            
                            productRefund.Payment_Order_Transaction__c    = null;
                            productRefund.Legacy_Transaction__c = null;
                            productRefund.Status__c                 = 'Submitted';
                            productRefund.Product__c                = locationFee.Product2Id;
                            productRefund.Opportunity__c            = locationFee.OpportunityId;         
                            productRefund.Reason__c                 = locationFee.Description;
                            productRefund.Refund_Amount__c          = (locationFee.UnitPrice*locationFee.Quantity).setScale(2);
                            productRefund.Sales_Price__c            = (locationFee.UnitPrice*locationFee.Quantity).setScale(2);
                            productRefund.Opportunity_Product_ID__c = locationFee.Id;
                            
                            if(approvedTransactionByOpportunityId.containsKey(locationFee.OpportunityId)){
                                sObject trans = approvedTransactionByOpportunityId.get(locationFee.OpportunityId);
                                if(trans.getSobjectType() == orderTransaction){
                                    productRefund.Payment_Order_Transaction__c = (Id)trans.get('Id');
                                }else if(trans.getSobjectType() == legacyTransaction){
                                    productRefund.Legacy_Transaction__c = (Id)trans.get('Id');
                                }
                            }
                            
                            productRefundByUniqueOpportunityLineItem.put(locationFee.Id, productRefund); 
                            
                        }
                        
                    }
                    
                }
            }
            
        }            
        
        return productRefundByUniqueOpportunityLineItem.values();
        
    }
    
    public static void createDeferralProductRefunds(Id examRegistrationId, ExamManagementController.DeferralAction action){

        Exam_Attempt__c examRegistrationInContext = fetchExamRegistrationInContext(examRegistrationId);
        
        if(examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c.contains('FRM')){ 
            
            Id siteId = examRegistrationInContext.Exam_Site__r.Site__c;
            Id contactId = examRegistrationInContext.Member__c;
            
            Exam_Sites__c sourceExamSite = examRegistrationInContext.Exam_Site__r;
            
            String sourceExamSiteName = sourceExamSite.Name.toUpperCase();
            
            Map<Id, Exam_Attempt__c> examRegistrations = getExamRegistrationByContactIdAndTestSiteId(contactId, siteId);
            
            List<Product_Refunds__c> productRefunds = new List<Product_Refunds__c>();
            List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

            if(sourceExamSite.Site__r.Is_OSTA_Information_Required__c){  
                
                Integer numberOfExamRegistrations = computeNumberOfExamRegistrationsInActiveCycle(examRegistrations.values());
                Integer numberOfExamRegistrationsDeferredOut = computeNumberOfDeferredOutExamRegistrationsInActiveCycle(examRegistrations.values());
                Integer examRegistrationPartInContext = getExamPartNumber(examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c);
                
                if(action == DeferralAction.DEFER){
                    
                    if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 1 && examRegistrationPartInContext == 1){
                        
                        Set<Id> opportunityIds = getAllOpportunityIdsByExamRegistration(examRegistrationInContext);
                        
                        Map<Id, Exam_Attempt__c> examAttemptMap = new Map<Id, Exam_Attempt__c>{examRegistrationInContext.Id => examRegistrationInContext};
                                    
                        productRefunds = createChinaLocationFeeProductRefunds(examAttemptMap, opportunityIds);
                        
                    }
                    
                }else if(action == DeferralAction.UNDEFER){
                    
                    if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 1 && examRegistrationPartInContext == 2){
                        
                        Set<Id> opportunityIds = getAllOpportunityIdsByExamRegistration(examRegistrationInContext);
                        
                        Map<Id, Exam_Attempt__c> examAttemptMap = new Map<Id, Exam_Attempt__c>{examRegistrationInContext.Id => examRegistrationInContext};
                                    
                        productRefunds = createChinaLocationFeeProductRefunds(examAttemptMap, opportunityIds);
                        
                    }
                    
                } 
                
                if(!productRefunds.isEmpty()){
                    INSERT productRefunds;
                }
                
            }
 
        }
        
    }
        
    public static void switchExamSites(Id examRegistrationId, Id targetExamSiteId){
        
        Exam_Attempt__c examRegistrationInContext = fetchExamRegistrationInContext(examRegistrationId);
        
        Id siteId = examRegistrationInContext.Exam_Site__r.Site__c;
        Id contactId = examRegistrationInContext.Member__c;

        Exam_Sites__c sourceExamSite = examRegistrationInContext.Exam_Site__r;
        Exam_Sites__c targetExamSite = getNewExamSite(targetExamSiteId);
        
        String sourceExamSiteName = sourceExamSite.Name.toUpperCase();
        String targetExamSiteName = targetExamSite.Name.toUpperCase();
        
        System.Debug('sourceExamSiteName :' + sourceExamSiteName );
        System.Debug('targetExamSiteName :' + targetExamSiteName );
           
        Map<Id, Exam_Attempt__c> examRegistrations = getExamRegistrationByContactIdAndTestSiteId(contactId, siteId);
        
        //system.assert(false, 'BOOM!3'+ examRegistrations );

        
        Map<String, Exam_Sites__c> examSiteByExamType = getExamSiteByExamTypeMap(targetExamSite.Site__c);
        
        for(Exam_Attempt__c examRegistration: examRegistrations.values()){
            
            System.Debug('examRegistration:' + examRegistration);

            if(
                examRegistration.Cancelled__c == FALSE &&
                examRegistration.Exam_Type__c != null && 
                examSiteByExamType.containsKey(examRegistration.Exam_Type__c) &&
                examRegistration.Exam_Site__r.Exam__r.Exam_Group__r.Active__c 
            ){
                examRegistration.Exam_Site__c = examSiteByExamType.get(examRegistration.Exam_Type__c).Id;

                System.Debug('examRegistration Update:' + examRegistration);

            }

        }
               
        UPDATE examRegistrations.values();
 
    }
    
    public static Contract fetchOstaProgram(Id accountId){
        
        List<Contract> programs = [
            SELECT Id, Name, Status, RecordType.Name, Opportunity__c, CustomerSignedId, AccountId 
            FROM Contract
            WHERE                               
                AccountId = :accountId AND
                Status LIKE 'Activated%' AND 
                RecordType.Name = 'OSTA Program'                             
        ];
        
        if(programs.isEmpty()){
            return null;
        }else{
            return programs[0];
        }
        
    }

    public static Contract cancelOstaProgram(String accountID){
        
        system.debug('cancelOstaProgram: ' + accountID);
        
        Contract ostaProgram;
        LIST<Contract> ostaPrograms = [
            SELECT Id, Name, Status, RecordType.Name, AccountId, Opportunity__c
            FROM Contract
            WHERE 
            AccountId = :accountID AND
            RecordType.Name = 'OSTA Program' AND
            Status LIKE 'Activated%'
        ];        
        
        system.debug('ostaPrograms: ' + ostaPrograms);
        
        if(ostaPrograms != NULL && ostaPrograms.size() > 0) {
            ostaProgram = ostaPrograms[0];
            ostaProgram.Status = 'Canceled';
            
            system.debug('Update ostaProgram: ' + ostaProgram);
            
            update ostaProgram;
        }
        
        return ostaProgram;
    }

    
    public static Contract createOstaProgram(Opportunity opportunity, OpportunityLineItem chinaDataFee){
        
        system.debug('createOstaProgram: ' + opportunity + '~' + chinaDataFee);
        
        Map<String, Contract> frmAndOstaContractMap = new Map<String, Contract>();
        
        List<Contact> contacts = [
            SELECT Id, Name, AccountId
            FROM Contact
            WHERE AccountId = :opportunity.AccountId
            LIMIT 1
        ];
        
        /**
        * Fetch all FRM and OSTA Programs
        * that are currently being created or previously created.
        */ 
        
        List<Contract> programs = [
            SELECT Id, Name, Status, RecordType.Name, Opportunity__c, CustomerSignedId 
            FROM Contract
            WHERE 
            (
                AccountId = :opportunity.AccountId AND
                Status LIKE 'Activated%' AND 
                RecordType.Name = 'FRM Program' 
            ) OR
            (
                AccountId = :opportunity.AccountId AND
                Opportunity__c = :opportunity.Id AND
                RecordType.Name = 'FRM Program' AND
                Status = 'Draft'
            ) OR                                 
            (
                AccountId = :opportunity.AccountId AND
                Status LIKE 'Activated%' AND 
                RecordType.Name = 'OSTA Program' 
            )                                
        ];
        
        system.debug('programs: ' + programs);
        
        for(Contract program: programs){
            if(program.RecordType.Name == 'FRM Program' || program.RecordType.Name == 'OSTA Program'){
                frmAndOstaContractMap.put(program.RecordType.Name, program);
            }
        }
        
        system.debug('frmAndOstaContractMap: ' + frmAndOstaContractMap);
        
        if(!frmAndOstaContractMap.containsKey('OSTA Program')){
            
            Contract ostaContract = new Contract(
                AccountId = opportunity.AccountId,
                Opportunity__c = opportunity.Id,
                RecordTypeId = RecordTypeHelper.GetRecordTypeId('Contract', 'OSTA Program'),
                FRM_Exam_Program__c = frmAndOstaContractMap.get('FRM Program').Id,
                Status = 'Draft',
                Name = 'OSTA Program',
                StartDate = Date.today(),
                ContractTerm = 9999
            );
            
            system.debug('ostaContract: ' + ostaContract);

            
            ostaContract.CustomerSignedId = contacts[0].Id;
            
            INSERT ostaContract;
            
            ostaContract.Status = 'Activated ( Auto-Renew )';
            
            UPDATE ostaContract;
            
            if(chinaDataFee != NULL) {
                chinaDataFee.Program__c = ostaContract.Id;
                UPDATE chinaDataFee;
            }
                
            return ostaContract;
            
        }else{
            
            return frmAndOstaContractMap.get('OSTA Program');
            
        }
        
    }
    
    public static void createOrUpdateOstaExamRegistrationData(Contract ostaProgram){
        
        /**
         * Creates a single OSTA Exam Registration Data record
         * or updates the existing one for the current Active 
         * Exam Group.
         */ 
        
        Id contactId = null;
        if(ostaProgram.CustomerSignedId != null){
            contactId = ostaProgram.CustomerSignedId;
        }else{
            Account account = [
                SELECT Id, 
                (SELECT Id FROM Contacts WHERE RecordType.Name = 'Member' LIMIT 1) 
                FROM Account 
                WHERE Id = :ostaProgram.AccountId
            ];
            contactId = account.contacts[0].Id;
        }
        
        List<Exam_Attempt__c> examRegistrations = [
            SELECT Id, Opportunity__c, Opportunity__r.StageName, Exam_Site__r.Exam__r.Exam_Group__r.Active__c,
            (
                SELECT Id, OSTA_Program__c, Exam_Registration__c FROM OSTA_Exam_Registration_Data__r
            )  
            FROM Exam_Attempt__c
            WHERE 
                Opportunity__r.StageName = 'Closed' AND
                Member__c = :contactId AND 
                Exam_Site__r.Exam__r.Exam_Group__r.Active__c = TRUE             
        ];
        
        List<OSTA_Exam_Registration_Data__c> toUpdate = new List<OSTA_Exam_Registration_Data__c>();
        List<OSTA_Exam_Registration_Data__c> toInsert = new List<OSTA_Exam_Registration_Data__c>();
        
        /**
         * Defines whether or not the Exam Registration(s) have at least one
         * OSTA Exam Registration Data record for the given cycle.
         */ 
        Boolean hasOstaExamRegistrationDataRecord = FALSE;
            
        for(Exam_Attempt__c examRegistration: examRegistrations){
            if(!examRegistration.OSTA_Exam_Registration_Data__r.isEmpty()){
                hasOstaExamRegistrationDataRecord = TRUE;
            }
        }
        
        for(Exam_Attempt__c examRegistration: examRegistrations){
            if(examRegistration.OSTA_Exam_Registration_Data__r.isEmpty() && hasOstaExamRegistrationDataRecord == FALSE){
                OSTA_Exam_Registration_Data__c ostaExamRegistrationData = new OSTA_Exam_Registration_Data__c(
                    OSTA_Program__c = ostaProgram.Id,
                    Exam_Registration__c = examRegistration.Id
                );
                toInsert.add(ostaExamRegistrationData);
            }else if(!examRegistration.OSTA_Exam_Registration_Data__r.isEmpty()){
                OSTA_Exam_Registration_Data__c ostaExamRegistrationData = examRegistration.OSTA_Exam_Registration_Data__r[0];
                ostaExamRegistrationData.OSTA_Program__c = ostaProgram.Id;
                toUpdate.add(ostaExamRegistrationData);
            }
            break;
        }
        
        if(!toInsert.isEmpty()){
            INSERT toInsert;
        }
        
        if(!toUpdate.isEmpty()){
            UPDATE toUpdate;
        }
        
    }
    
    public static void setExamRegistionReScoreStatusForReview(Set<Id> retabulationRequestExamRegistrationIds, Map<Id, OpportunityLineItem> retabulationRequestFeesMapByOpportunityId){
        
        Map<Id, Exam_Attempt__c> examRegistrations = new Map<Id, Exam_Attempt__c>([
            SELECT Id, Exam_Name__c, Exam_Date__c, Re_score_Status__c
            FROM Exam_Attempt__c
            WHERE Id IN :retabulationRequestExamRegistrationIds
        ]);
        
        if(!examRegistrations.values().isEmpty()){ 
            for(Exam_Attempt__c examRegistration: examRegistrations.values()){
                examRegistration.Re_score_Status__c = 'Awaiting Review';
            }
        }
        
        if(!retabulationRequestFeesMapByOpportunityId.values().isEmpty()){
            for(OpportunityLineItem oli: retabulationRequestFeesMapByOpportunityId.values()){
                if(examRegistrations.containsKey(oli.Exam_Registration__c)){
                    Exam_Attempt__c examRegistration = examRegistrations.get(oli.Exam_Registration__c);                    
                    Datetime dt = Datetime.newInstance(examRegistration.Exam_Date__c, Time.newInstance(0, 0, 0, 0));
                    oli.Description = dt.format('MMM YYYY');                                     
                }
            }
            UPDATE retabulationRequestFeesMapByOpportunityId.values();
        }
        
        if(!examRegistrations.values().isEmpty()){
            UPDATE examRegistrations.values();
        }        
        
    }
    
    public static void setScholarshipApplicationStatusAsUsed(Set<Id> scholarshipApplicationIds){
    
        List<Scholarship_Application__c> scholarshipApplications = [
            SELECT Id, Status__c, Applicant__c, Exam_Group__c, Exam_Group__r.Next_Exam_Group__c
            FROM Scholarship_Application__c
            WHERE
            Status__c = 'Approved' AND
            Id IN :scholarshipApplicationIds
        ];
        
        for(Scholarship_Application__c sa: scholarshipApplications){
            sa.Status__c = 'Used';
        }
        
        if(!scholarshipApplications.isEmpty()){
            UPDATE scholarshipApplications;
        }
        
    }

    /**
     * @description Entry point for modifying the deferral/undeferral order to include Product Refunds or Location Fee OpportunityLineItems if applicable.
     * @param deferralOpportunityId the deferral or undeferral Opportunity Id
     * @param examRegistrationId the Exam Registration being deferred or undeferred
     * @param action the enum value which determines if the method should process this order as DEFER or UNDEFER
     * @return an sObject (OpportunityLineItem || Product_Refunds__c) 
     */
    public static sObject computeDeferralLocationFeesOrProductRefunds(Id deferralOpportunityId, Id examRegistrationId, ExamManagementController.DeferralAction action){
        
        Exam_Attempt__c examRegistrationInContext = fetchExamRegistrationInContext(examRegistrationId);
        
        if(examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c.contains('FRM')){
            
            Id siteId = examRegistrationInContext.Exam_Site__r.Site__c;
            Id contactId = examRegistrationInContext.Member__c;
            
            Exam_Sites__c sourceExamSite = examRegistrationInContext.Exam_Site__r;
            
            String sourceExamSiteName = sourceExamSite.Name.toUpperCase();
            
            Map<Id, Exam_Attempt__c> examRegistrations = getExamRegistrationByContactIdAndTestSiteId(contactId, siteId);
            
            List<Product_Refunds__c> productRefunds = new List<Product_Refunds__c>();
            List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();

            if(examRegistrationInContext.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c){  
                
                Integer numberOfExamRegistrations = computeNumberOfExamRegistrationsInActiveCycle(examRegistrations.values());
                Integer numberOfExamRegistrationsDeferredOut = computeNumberOfDeferredOutExamRegistrationsInActiveCycle(examRegistrations.values());
                Integer examRegistrationPartInContext = getExamPartNumber(examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c);
                
                System.debug('numberOfExamRegistrations: ' + numberOfExamRegistrations + ', numberOfExamRegistrationsDeferredOut: ' + numberOfExamRegistrationsDeferredOut + ', examRegistrationPartInContext: ' + examRegistrationPartInContext);
                
                if(action == DeferralAction.DEFER){
                    
                    if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 0 && examRegistrationPartInContext == 2){
                        
                        PriceBookEntry priceBookEntry = [
                            SELECT UnitPrice, ProductCode
                            FROM PriceBookEntry 
                            WHERE 
                            Pricebook2.IsActive = TRUE AND 
                            Productcode = 'CHLF' AND 
                            IsActive = TRUE
                            LIMIT 1
                        ];
                        
                        OpportunityLineItem locationFee = new OpportunityLineItem(
                            Exam_Registration__c    = examRegistrationInContext.Id,
                            Exam_Site__c            = examRegistrationInContext.Exam_Site__c,
                            Description             = examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c,                       
                            Quantity                = 1,
                            PricebookEntryId        = priceBookEntry.Id,
                            UnitPrice               = priceBookEntry.UnitPrice,
                            OpportunityId           = deferralOpportunityId
                        );
                        
                        opportunityLineItems.add(locationFee);
                        
                    }else if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 1 && examRegistrationPartInContext == 1){
                        
                        Set<Id> opportunityIds = getAllOpportunityIdsByExamRegistration(examRegistrationInContext);
                        
                        Map<Id, Exam_Attempt__c> examAttemptMap = new Map<Id, Exam_Attempt__c>{examRegistrationInContext.Id => examRegistrationInContext};
                                    
                        productRefunds = createChinaLocationFeeProductRefunds(examAttemptMap, opportunityIds);
                        
                    }
                    
                }else if(action == DeferralAction.UNDEFER){
                    
                    if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 2 && examRegistrationPartInContext == 1){
                        
                        PriceBookEntry priceBookEntry = [
                            SELECT Id, UnitPrice, ProductCode
                            FROM PriceBookEntry 
                            WHERE 
                            Pricebook2.IsActive = TRUE AND 
                            Productcode = 'CHLF' AND 
                            IsActive = TRUE
                            LIMIT 1
                        ];
                        
                        OpportunityLineItem locationFee = new OpportunityLineItem(
                            Exam_Registration__c    = examRegistrationInContext.Id,
                            Exam_Site__c            = examRegistrationInContext.Exam_Site__c,
                            Description             = examRegistrationInContext.Exam_Site__r.Exam__r.Exam__c,                       
                            Quantity                = 1,
                            PriceBookEntryId        = priceBookEntry.Id,
                            UnitPrice               = priceBookEntry.UnitPrice,
                            OpportunityId           = deferralOpportunityId
                        );
                        
                        opportunityLineItems.add(locationFee);
                        
                    }else if(numberOfExamRegistrations == 2 && numberOfExamRegistrationsDeferredOut == 1 && examRegistrationPartInContext == 2){
                        
                        Set<Id> opportunityIds = getAllOpportunityIdsByExamRegistration(examRegistrationInContext);
                        
                        Map<Id, Exam_Attempt__c> examAttemptMap = new Map<Id, Exam_Attempt__c>{ examRegistrationInContext.Id => examRegistrationInContext };
                            
                        productRefunds = createChinaLocationFeeProductRefunds(examAttemptMap, opportunityIds);
                        
                    }
                    
                }                       
                
            }
            
            if(!productRefunds.isEmpty()){
                /**
                * Product Refunds are inserted after
                * the deferral/undeferral refund is closed
                */ 
                return productRefunds[0];
            }else if(!opportunityLineItems.isEmpty()){
                INSERT opportunityLineItems[0];
                return opportunityLineItems[0];
            }
            
        }
        
        return null;
        
    }

    // AG 9/4/2020 - New My Program Logic
    
    public class allProgramData {  
        public programInfo frm { get; set; }
        public programInfo erp { get; set; }
        public programInfo scr { get; set; }
        public programInfo riskai { get; set; }
        public programInfo raij { get; set; }
    }
    
    public class programInfo {  
        String name { get; set; }
        String type { get; set; }
        Boolean isEnrolled { get; set; }
        Boolean isLapsed { get; set; }
        Boolean isAllPartsPassed { get; set; }
        Boolean isAllPartsPassedHideCard { get; set; }
        Boolean isCVAwaitingReview { get; set; }
        Boolean isCVFailedReview { get; set; }
        Boolean isCertified { get; set; }
        
        Boolean isRegistrationOpen { get; set; }
        String registrationOpenName { get; set; }
        String  currentWindow { get; set; }
        Date    currentWindowEndDate { get; set; }
        Date    nextAdminRegistrationOpenDate { get; set; }
        String  nextAdminRegistrationOpenName { get; set; }
        
        Date    nextWindowEndDate{ get; set; }
                        
        Date registrationCloseDate { get; set; }
        
        Boolean isPartIAvailableForRegistration { get; set; }
        Boolean isPartIIAvailableForRegistration { get; set; }
        
        //Boolean isAdminAvailable { get; set; }
        //Boolean isDeferralAvailable { get; set; }
        
        //DateTime adminAvailableStartDate { get; set; }
        //Date adminAvailableEndDate { get; set; }
        
        Date nextRegistrationOpenDate { get; set; }        
        Date programExpireDate  { get; set; }  

        String currentExamYear  { get; set; }
        String mostReleventPart  { get; set; }
                
        String idName { get; set; }
        String idNumber { get; set; }
        String idType { get; set; }
        String idLocation { get; set; }
        Date idExpireDate { get; set; }
        Boolean isMissingFullID { get; set; }
        
        String gender { get; set; }
        String ostaChineseName { get; set; }
        Date ostaDateOfBirth { get; set; }
        String ostaPhone { get; set; }
        String ostaWorkStatus { get; set; }
        String ostaCompany { get; set; }
        String ostaEducationStatus { get; set; }
        String ostaSchool { get; set; }
        String ostaDegree { get; set; }
        String phone { get; set; }
        
        // AG 11/2/2022 - SCR BenchPrep
        // If null does not have access
        String eLearningSSOLink { get; set; } 
        
        // AG 12/7/2022 -- Add Display States
        String programState { get; set; } 
        String examResultState { get; set; } 
        
        public partInfo part1 { get; set; }
        public partInfo part2 { get; set; }
        
        GARP_BC_Registration.RegistrationEligibility registrationEligibility { get; set; }
    }

    public class partInfo  {  
        String name { get; set; }
        Integer part { get; set; }
        String administration { get; set; }
        String deliveryMethod { get; set; }
        String provider { get; set; }
        DateTime examDateTime { get; set; }
        String examLocation { get; set; }
        Boolean isOSTA { get; set; }
        
        String oppId { get; set; }
        String examRegId { get; set; }
        
        String result { get; set; }
        Boolean hasViloation { get; set; }
        
        Boolean isPaid { get; set; }
        Boolean isScheduled { get; set; }
        Boolean isSetupComplete { get; set; }
        
        Boolean isActiveExamAdmin { get; set; }
        String activeExamGroupName { get; set; }
        
        Boolean isSchedulingLapsed { get; set; }
        Boolean isScheduleWindowAvailable { get; set; }        
        
        Date regWindowEndDate { get; set; }        
        
        Boolean isPassed { get; set; }
        Boolean isDeferred { get; set; }
        String deferredExamAdmin {get; set; }
        DateTime nextAdminOpenDate { get; set; }
        
        Boolean isTicketAvailable { get; set; }
        Boolean isAwaitingTicket { get; set; }
        DateTime ticketDownloadDate { get; set; }
        Boolean isSeatAllocated { get; set; }
        Date ticketAvailableDate  { get; set; }

        Date lastDateForADA { get; set; }
        Date lastDateForRAD { get; set; }
        Boolean showRAD { get; set; }
        
        DateTime examResultsAvailableDate { get; set; }
        String examResultsAvailableStatement { get; set; }
        Boolean isExamAwaitingResults { get; set; }
        Boolean isExamResultsAvailable { get; set; }
        Boolean showExamResults { get; set; }
        
        Boolean allowSchedulingOverride { get; set; }
        
        // AG 2/17/2022         
        // Scheduling is Choose Exam Site and visit provider to schedule    
        // Uses Exam_Administration__r.Exam_Scheduling_Start_Date__c and Exam_Scheduling_End_Date__c    
        Boolean isSchedulingOpen { get; set; }  
        DateTime schedulingStartDate { get; set; }  
        DateTime schedulingEndDate { get; set; } 
        
        // Exam Admin Modification (Deferral) is seperate, but can only happen within the Scheduling window
        // Exam Admin Modification uses Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c and Exam_Admin_Modifications_End_Date__c        
        Boolean isAdminModOpen { get; set; }
        DateTime adminModStartDate { get; set; }
        DateTime adminModEndDate { get; set; }     
        
        // AG 12/7/2022 -- Add Display States
        String programPartState { get; set; }
        
        Boolean hasBenchPrepAccess { get; set; }
        Boolean hasPracticeExamAccess { get; set; }
        
        Date examEndDate { get; set; }
    }
    
    // AG 8/23/2020 - New Exam Reschedule Logic
    public class examRescheduleData {  
        
        public Exam_Sites__c originalSitePartI { get; set; }
        public Exam_Sites__c originalSitePartII { get; set; }
        public Exam_Sites__c currentSitePartI { get; set; }
        public Exam_Sites__c currentSitePartII { get; set; }
        public Exam_Sites__c selectedSitePartI { get; set; }
        public Exam_Sites__c selectedSitePartII { get; set; }

        // AG 10-19-2022 - Exams 2023
        // If Deferred Store Deferred Admin
        public Exam_Administration__c originalAdminPartI { get; set; }
        public Exam_Administration__c originalAdminPartII { get; set; }        
        public Exam_Administration__c currentAdminPartI { get; set; }
        public Exam_Administration__c currentAdminPartII { get; set; }
        public Exam_Administration__c selectedAdminPartI { get; set; }
        public Exam_Administration__c selectedAdminPartII { get; set; }        

        public Exam_Attempt__c examRegPartI { get; set; }
        public Exam_Attempt__c examRegPartII { get; set; }

        public Exam_Attempt__c otherProgramExamRegPartI { get; set; }
        public Exam_Attempt__c otherProgramExamRegPartII { get; set; }
        
        public Boolean canDeferPartI { get; set; }
        public Boolean canDeferPartII { get; set; }
        public Exam_Group__c examGroup { get; set; }
        public Exam_Group__c nextExamGroup { get; set; } 
        public Opportunity opp { get; set; } 
        
        public List<Exam_Sites__c> examSites { get; set; }
        public List<Exam_Administration__c> examAdmins { get; set; }
        public List<Exam_Part__c> examParts { get; set; }
        
        public List<prodLine> fees { get; set; }
        public Exam_Registration_Modification__c ExamRegMod { get; set; }
        public Contact contact { get; set; }
        public Contract program { get; set; }
        public String programType { get; set; }
        
        public String errMsg { get; set; }
        public Integer statusCode { get; set; }
        public Integer errorCode { get; set; }
        
        // AG 2/17/2022 
        // These are now by Part    
        // Setup uses Exam_Administration__r.Exam_Scheduling_Start_Date__c and Exam_Scheduling_End_Date__c  
        // Deferral uses Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c and Exam_Admin_Modifications_End_Date__c 
        public Boolean allowSchedulingPartI { get; set; }   
        public Boolean allowAdminModPartI { get; set; } 
        public Boolean allowSchedulingPartII { get; set; }  
        public Boolean allowAdminModPartII { get; set; }
        
        // AG 2/15/2023
        List<Country_Code__c> locations;
        
        // AG 5/6/2024 - Pass back Deferral info for new reg flow
        public String examRegistrationModificationId;
        public String examEmailParts;
        public String deferralSubType;
        public String transactionType;
        public List<prodLine> productLineItems;
    }
    
    public class prodLine {
        public String prodCode { get; set; }
        public String glCode { get; set; }
        public String description { get; set; }
        public Decimal amount { get; set; }
        public String examRegId { get; set; }
        public String examSiteId { get; set; }
        public String referenceId { get; set; }
    }
    
    public class ostaMaps {
        public MAP<String,Exam_Part__c> mapCurrentPartOSTA { get; set; }
        public MAP<String,Exam_Part__c> mapSelectedPartOSTA  { get; set; }
    }
    
    static public Boolean isLoadingResults(Boolean isLoading, String closedKey) {
    
        if(isLoading && closedKey != 'kiujgh&^%Rrf7u') {
            return true;
        } else {
            return false;
        }
        
    }
        
    static public partInfo setProgramPartInfo(String programType, programInfo pri, Exam_Attempt__c ea, String partName, partInfo part, String closedKey) {
        
        //partInfo part = new partInfo();
        Date tdy = Date.today();
        DateTime now = DateTime.now();
        
        part.name = programType == 'frm'  ? 'FRM Exam Part ' + partName :
                    programType == 'erp'  ? 'ERP Exam Part ' + partName :
                    programType == 'scr'  ? 'SCR Exam' :
                    programType == 'raij' ? 'Risk and AI in Japanese Exam' :
                    'Risk AI Exam';
        part.part = partName == 'I' ? 1 : 2;
           
        // Is Reg still open
        Date rmdt = ea.Exam_Administration__r.Registration_Start_Date__c;
        Date rmet = ea.Exam_Administration__r.Registration_End_Date__c;
        
        if(tdy >= rmdt && tdy <= rmet) {
            part.isActiveExamAdmin = TRUE;
        }
        
        // Current Reg Window
        List<Exam_Rate__c> lstWin = [select id, Exam_Registration_Window__r.Exam_Registration_Window_Open__c, 
                                     Exam_Registration_Window__r.Exam_Registration_Window_Close__c
                                     from Exam_Rate__c where Exam_Part__c = :ea.Exam_Part__c];

        if(!lstWin.isEmpty()) {
            part.regWindowEndDate = lstWin[0].Exam_Registration_Window__r.Exam_Registration_Window_Close__c;
        }
        part.allowSchedulingOverride = ea.Allow_Scheduling_Override__c;
                
        // Old Exam Setup
        if(ea.Exam_Part__r == NULL) {
            //return null;

            DateTime dt;
            
            if(programType == 'scr' || programType == 'riskai' || programType == 'raij') {
                if(ea.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                    dt = ea.Integration_Data_Exam_Scheduled_Date__c;
                    part.examEndDate = Date.NewInstance(ea.Integration_Data_Exam_Scheduled_Date__c.year(), ea.Integration_Data_Exam_Scheduled_Date__c.month(), ea.Integration_Data_Exam_Scheduled_Date__c.day()); 
                } else {
                    dt = DateTime.newInstance(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.month(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.day(),8,0,0);
                    part.examEndDate = ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c; 
                }
            
            } else {            
                if(partName == 'I') {
                    dt = DateTime.newInstance(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.month(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.day(),8,0,0);
                } else {
                    dt = DateTime.newInstance(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.month(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.day(),14,0,0);            
                }
                part.examEndDate = ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c; 
            }    
            //DateTime dt = DateTime.newInstance(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.year(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.month(), ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.day());            
            part.administration = dt.format('MMMMM') + ' ' + dt.format('YYYY');    
            
            part.deliveryMethod = 'Pen and Paper';
            part.provider = 'GARP';
            part.examDateTime = dt;
            part.examLocation = ea.Exam_Site__r.Name;
            part.isOSTA = (ea.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == True && programType == 'frm');
            part.oppId = ea.Opportunity__c;                    
            part.examRegId = ea.Id;                    
            part.isPaid = (ea.Opportunity_StageName__c == 'Closed');
            part.isDeferred = (ea.Defered__c == 'Pending');              
            if(part.isDeferred) {
                dt = ea.Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__r.Exam_Date__c;
                part.deferredExamAdmin = dt.format('MMMMM') + ' ' + dt.format('YYYY'); 
                part.nextAdminOpenDate = ea.Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__r.Exam_Change_Start_Date_Time__c;
            } else {
                
                // If old can only be deferred or has results                    
                part.isScheduled = TRUE;
                part.isSchedulingLapsed = FALSE;
                
                part.isPassed = (!ea.Exam_Site__r.Exam__r.Exam_Group__r.Loading_Exam_Results__c && ea.Result__c != NULL && ea.Result__c == 'Pass');        
                                
                part.lastDateForADA = ea.Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_ADA__c;
                part.lastDateForRAD = ea.Exam_Site__r.Exam__r.Exam_Group__r.Religious_Alternative_Last_Date__c;

                if(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c != NULL) {
                    
                    system.debug('isAwaitingTicket:' + ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c + ':' + tdy + ':' + ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c.addDays(-30) + ':' + ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c);
                    
                    part.isAwaitingTicket = (part.isPaid && part.isScheduled && 
                                             ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c != NULL &&
                                             tdy >= ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c.addDays(-30) &&
                                             tdy < ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c);
                    
                    part.isTicketAvailable = (part.isPaid && part.isScheduled && 
                                              ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c != NULL &&
                                              tdy >= ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c &&
                                              tdy <= ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c.addDays(2));
                    
                    part.isSeatAllocated = (ea.Seat_No__c != NULL);
                    part.ticketAvailableDate = ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c;
                }
                part.ticketDownloadDate = ea.Ticket_Download_Date__c;                
                
                // Results
                //DateTime erad = ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c;
                //part.examResultsAvailableDate = Date.newInstance(erad.year(), erad.month(), erad.day());
                part.examResultsAvailableDate =  ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c;
                                
                if(tdy > ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c && (part.isScheduled || part.deliveryMethod == 'Pen and Paper')) {
                    
                    if(ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c != NULL) {
                        if(now < ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c) {
                            part.isExamAwaitingResults = True;
                        } else {
                            part.isExamResultsAvailable = True;
                            if(now <= ea.Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c.addDays(90)) {
                                part.showExamResults = True;
                            }
                                
                            if(ea.Result__c != NULL && ea.Exam_Site__r.Exam__r.Exam_Group__r.Loading_Exam_Results__c == False) {
                                part.result = ea.Result__c; 
                                part.hasViloation = ea.hasViolation__c;
                            } else {
                                part.result = NULL;  
                            }
                        }
                    }
                }                
                
            }
            part.isSetupComplete = true;

        } else { // New Setup
            
            DateTime dt;
            Date examEndDate;
            if(ea.Exam_Part__r.Exam_Date__c != NULL) {
                //dt = DateTime.newInstance(ea.Exam_Part__r.Exam_Date__c.year(), ea.Exam_Part__r.Exam_Date__c.month(), ea.Exam_Part__r.Exam_Date__c.day());
                examEndDate = ea.Exam_Part__r.Exam_Date__c;
                part.examEndDate = ea.Exam_Part__r.Exam_Date__c;
                if(ea.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                    examEndDate = Date.newInstance(ea.Integration_Data_Exam_Scheduled_Date__c.year(),ea.Integration_Data_Exam_Scheduled_Date__c.month(), ea.Integration_Data_Exam_Scheduled_Date__c.day());
                }
                                    
                if(partName == 'I') {
                    dt = DateTime.newInstance(ea.Exam_Part__r.Exam_Date__c.year(), ea.Exam_Part__r.Exam_Date__c.month(), ea.Exam_Part__r.Exam_Date__c.day(),8,0,0);
                } else {
                    dt = DateTime.newInstance(ea.Exam_Part__r.Exam_Date__c.year(), ea.Exam_Part__r.Exam_Date__c.month(), ea.Exam_Part__r.Exam_Date__c.day(),14,0,0);            
                }
                String dayOfWeek = dt.format('EEEE');
                if(dayOfWeek == 'Saturday') {
                    part.showRAD = True;
                }
                
            } else {
                dt = DateTime.newInstance(ea.Exam_Part__r.Exam_Start_Date__c.year(), ea.Exam_Part__r.Exam_Start_Date__c.month(), ea.Exam_Part__r.Exam_Start_Date__c.day());
                part.isScheduleWindowAvailable = True;
                examEndDate = ea.Exam_Part__r.Exam_End_Date__c;
                part.examEndDate = ea.Exam_Part__r.Exam_End_Date__c;
                if(ea.Integration_Data_Exam_Scheduled_Date__c != NULL) {
                    examEndDate = Date.newInstance(ea.Integration_Data_Exam_Scheduled_Date__c.year(),ea.Integration_Data_Exam_Scheduled_Date__c.month(), ea.Integration_Data_Exam_Scheduled_Date__c.day());
                }                
            }
            
            part.deliveryMethod = ea.Exam_Part__r.Delivery_Method__c;
            part.provider = ea.Exam_Site__r.Exam_Provider__r.Name;
            if(part.provider == 'GARP') {
                part.examLocation = ea.Exam_Site__r.Name;
                
                List<Venue__c> lstVenue = [select Id, Name, Institution_Name__c, Building_Name__c, Address1__c, Address2__c,City__c, State__c,Zipcode__c,Country__c from Venue__c where Site__c = :ea.Exam_Site__r.Site__c and Active__c = True];
                if(lstVenue != NULL && lstVenue.size() > 0) {
                    Venue__c v = lstVenue[0];
                    if(v.Address1__c != NULL) {
                        part.examLocation = '';                    
                        if(v.Institution_Name__c != NULL) {
                            part.examLocation += v.Institution_Name__c;
                        }
                        if(v.Building_Name__c!= NULL) {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.Building_Name__c;
                        }
                        if(v.Address1__c!= NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.Address1__c;
                        }
                        if(v.Address2__c!= NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.Address2__c;
                        }
                        if(v.City__c != NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.City__c;
                        }
                        if(v.State__c != NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.State__c;
                        }
                        if(v.Zipcode__c!= NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.Zipcode__c;
                        }
                        if(v.Country__c != NULL)  {
                            if(part.examLocation != '') { part.examLocation += ', '; }
                            part.examLocation += v.Country__c;
                        }                    
                    }
                }
                part.examDateTime = dt;
            } else {
                part.examLocation = ea.Integration_Data_Exam_Location__c;
                part.examDateTime = ea.Integration_Data_Exam_Scheduled_Date__c;
            }
            part.isOSTA = (ea.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c == True && programType == 'frm');
            part.oppId = ea.Opportunity__c;                    
            part.examRegId = ea.Id;                    
            part.isPaid = (ea.Opportunity_StageName__c == 'Closed');
            part.isDeferred = (ea.Defered__c == 'Pending');  
            
            Date amdt = ea.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c;
            Date amet = ea.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c;
            part.adminModStartDate = DateTime.newInstance(amdt.year(), amdt.month(), amdt.day(), 0, 0, 0);
            part.adminModEndDate = DateTime.newInstance(amet.year(), amet.month(), amet.day(), 23, 59, 59);
            
            if(tdy >= amdt && tdy <= amet) {
                part.isAdminModOpen = true;
            }
                        
            if(part.isDeferred) {
                part.administration = ea.Deferred_Exam_Administration__r.Month__c + ' ' + String.valueOf(ea.Deferred_Exam_Administration__r.Year__c);
                part.deferredExamAdmin = ea.Deferred_Exam_Administration__r.Month__c + ' ' + String.valueOf(ea.Deferred_Exam_Administration__r.Year__c);         
                    
                Date examChangeSt = ea.Deferred_Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c;
                DateTime dtm = DateTime.newInstance(examChangeSt.year(), examChangeSt.month(), examChangeSt.day());
                part.nextAdminOpenDate = dtm;
                
            } else {
                
                part.administration = ea.Exam_Administration__r.Month__c + ' ' + String.valueOf(ea.Exam_Administration__r.Year__c);
                
                Date esdt = ea.Exam_Administration__r.Exam_Scheduling_Start_Date__c;
                part.schedulingStartDate = DateTime.newInstance(esdt.year(), esdt.month(), esdt.day(), 00, 00, 00); 
                        
                Date eedt = ea.Exam_Administration__r.Exam_Scheduling_End_Date__c;
                part.schedulingEndDate = DateTime.newInstance(eedt.year(), eedt.month(), eedt.day(), 23, 59, 59);
                
                if(now >= part.schedulingStartDate && now <= part.schedulingEndDate) {
                    part.isSchedulingOpen = true;
                }
               
                part.isScheduled = (ea.Exam_Part__r.Delivery_Method__c == 'CBT' && ea.Integration_Data_Exam_Scheduled_Date__c != NULL);
                // AG Modify for Deadline Changes   
                part.isSchedulingLapsed = !ea.Allow_Scheduling_Override__c && ea.Integration_Data_Exam_Scheduled_Date__c == NULL && ea.Exam_Part__r.Delivery_Method__c == 'CBT'&& now > part.schedulingEndDate; 
                
                //part.isSchedulingLapsed = !ea.Allow_Scheduling_Override__c && ea.Integration_Data_Exam_Scheduled_Date__c == NULL && ea.Exam_Part__r.Delivery_Method__c == 'CBT'&& tdy > ea.Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_To_Request_Exam_Change__c;
                part.isPassed = (!isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c,closedKey) && ea.Result__c != NULL && ea.Result__c == 'Pass');        
                
                part.lastDateForADA = ea.Exam_Administration__r.Last_Date_For_ADA__c;
                part.lastDateForRAD = ea.Exam_Administration__r.Last_Date_For_RAD__c;
                
                // Results
                DateTime examResultsReleaseDate = ea.Exam_Administration__r.Exam_Results_Release_Date__c;
                if(ea.Exam_Part__r.Exam_Results_Release_Date__c != NULL) {
                    examResultsReleaseDate = ea.Exam_Part__r.Exam_Results_Release_Date__c;
                }
                String examResultsStatement = ea.Exam_Administration__r.Exam_Results_Available_Statement__c;
                if(ea.Exam_Part__r.Exam_Results_Available_Statement__c != NULL) {
                    examResultsStatement = ea.Exam_Part__r.Exam_Results_Available_Statement__c;
                }
                System.debug('examResultsReleaseDate:' + examResultsReleaseDate);
                System.debug('examResultsStatement:' + examResultsStatement);
                
                if(examResultsReleaseDate != NULL) {
                    part.examResultsAvailableDate = examResultsReleaseDate;
                    
                    if(tdy > examEndDate && (part.isScheduled || part.deliveryMethod == 'Pen and Paper')) {
                        
                        if(now < examResultsReleaseDate || ea.Hide_Exam_Result__c) {
                            part.isExamAwaitingResults = True;
                        } 
                        /* AG New Block Results -- no need for this handled below
                        else {
                            part.isExamResultsAvailable = True;
                            
                            if(ea.Result__c != NULL && !isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c,closedKey)) {
                                part.result = ea.Result__c;                                 
                                part.hasViloation = ea.hasViolation__c;
                            } else {
                                part.result = NULL;  
                            }
                        }
                        */
                    }
                }else if(examResultsStatement != NULL) {
                    part.examResultsAvailableStatement = examResultsStatement;
                    
                    if(tdy > examEndDate && (part.isScheduled || part.deliveryMethod == 'Pen and Paper')) {
                        part.isExamAwaitingResults = True;
                    }
                }
                
                // If Results are entered override awaiting results
                
                // AG New Block Results - do not use examResultsReleaseDate to block, so can preview before
                //if(ea.Result__c != NULL && !ea.Hide_Exam_Result__c && !isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c,closedKey) &&
                //    (examResultsReleaseDate == NULL || tdy > examResultsReleaseDate)
                if(ea.Result__c != NULL && !ea.Hide_Exam_Result__c && !isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c,closedKey)) {
                    part.isScheduled = True;
                    part.isExamAwaitingResults = False;
                    part.examResultsAvailableDate = NULL;
                    part.examResultsAvailableStatement = NULL;
                    
                    part.isExamResultsAvailable = True;                        
                    part.result = ea.Result__c;                                 
                    part.hasViloation = ea.hasViolation__c;  
                    
                    part.showExamResults = True;
                    if(examResultsReleaseDate != NULL && now > examResultsReleaseDate.addDays(90)) {
                        part.showExamResults = False;
                    }                  
                } 
            }
            
            System.debug('part:' + part);
            
            // Is Setup Completed?
            // Need ID info, Gender id Saudi and Paper, Exam Auth if CBT, and Scheduled
            part.isSetupComplete = true;
            if(!part.isDeferred) {
                if(pri.idName == NULL ||
                   (programType == 'frm' && (pri.idNumber == NULL ||
                   pri.idType == NULL))) {
                       part.isSetupComplete = false;
                       System.debug('isSetupComplete fail1:' + part.isSetupComplete);
                   }
                
                if(part.isOSTA) {
                    if(pri.ostaChineseName == NULL ||
                       pri.ostaDateOfBirth == NULL ||
                       pri.ostaPhone == NULL ||
                       pri.ostaWorkStatus == NULL ||
                       pri.ostaCompany == NULL ||
                       pri.ostaEducationStatus == NULL ||
                       pri.ostaSchool == NULL ||
                       pri.ostaDegree == NULL) {
                           part.isSetupComplete = false;
                           System.debug('isSetupComplete fail2:' + part.isSetupComplete);
                       }
                    
                }                
                if(part.deliveryMethod == 'CBT') {
                    // No Scheduled Time on record, they need to schedule with provider still
                    if(ea.Active_Integration_Data__c == NULL || ea.Integration_Data_Exam_Scheduled_Date__c == NULL || ea.Integration_Data_Exam_Location__c == NULL) {
                        part.isSetupComplete = false;
                        System.debug('isSetupComplete fail3:' + part.isSetupComplete);
                    }                    
                }
            }
            
            if(ea.Allow_Scheduling_Override__c) {
                part.isSetupComplete = true;
            }
            System.debug('isSetupComplete final:' + part.isSetupComplete);
            
        }
        
        // AG 12/7/2022 - Set Display State
        if(part.oppId != NULL) {
            if(!part.isPaid) {
                part.programPartState = 'UNPAID';
            } else if(part.isSchedulingLapsed)  {
                part.programPartState = 'REGISTRATION_EXPIRED';
            } else if(part.isDeferred) {
                part.programPartState = 'DEFERRED';
            } else if(part.isExamAwaitingResults) {
                part.programPartState = 'AWAITING_RESULTS';
            } else if(part.isExamResultsAvailable) {
                part.programPartState = 'RESULTS_AVAILABLE';                
            } else if(part.isPaid) {
                if(part.isSetupComplete) {
                    part.programPartState = 'SETUP_COMPLETE';
                } else {
                    part.programPartState = 'SETUP_INCOMPLETE';
                }
            }
        }
        
        // Set BenhPrep Access
        part.hasBenchPrepAccess = False;
        part.hasPracticeExamAccess = False;
        if(part.programPartState == 'SETUP_COMPLETE' || part.programPartState == 'SETUP_INCOMPLETE' || part.programPartState == 'DEFERRED') {
            part.hasBenchPrepAccess = True;
            part.hasPracticeExamAccess = True;
        }
        
        System.debug('part:' + part);
        return part;
    }    
    
    static public boolean validateIDFormat(String idNumber, String idLocation, String idType) {
        
        System.debug('idNumber:' + idNumber);
        System.debug('idType:' + idType);
        
        String LettersAndNumbersRegex = '^[A-Za-z0-9]+$';
        Pattern PLettersAndNumbersRegex = Pattern.compile(LettersAndNumbersRegex);
        
        if(idLocation == 'China') {
        
            if(idType == 'Passport') {
                if(idNumber.length() != 9) {
                    System.debug('Not 9 chars');
                    return false;
                }
                
                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    System.debug('Not letter and numbers');
                    return false;
                }
                
                if(idNumber.toUpperCase().indexOf('I') > -1 || idNumber.toUpperCase().indexOf('O') > -1) {
                    System.debug('Contains I or O,');
                    return false;
                }
                
            } else {
                if(idNumber.length() != 18) {
                    return false;
                }
            }
            
        } else {
            if(idType == 'Passport') {
                if(idNumber.length() < 5 || idNumber.length() > 10) {
                    System.debug('Not between 5 and 10 chars');
                    return false;
                }
                
                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    System.debug('Not letter and numbers');
                    return false;
                }
            } else {
                if(idNumber.length() < 5 || idNumber.length() > 25) {
                    System.debug('Not between 5 and 25 chars');
                    return false;
                }
                
                Matcher MyMatcher = PLettersAndNumbersRegex.matcher(idNumber);
                Boolean result = MyMatcher.matches();
                if(!result) {
                    System.debug('Not letter and numbers');
                    return false;
                }
            }
        }
           
        return true;
    }
    
    static public programInfo getProgramInfo(String programType) {
        return getProgramData(programType,'');
    }
    
    static public allProgramData getAllProgramInfo(String closedKey) {
        allProgramData apd = new allProgramData();
        apd.frm = ExamManagementController.getProgramData('frm', closedKey);
        apd.erp = ExamManagementController.getProgramData('erp', closedKey);
        apd.scr = ExamManagementController.getProgramData('scr', closedKey);
        apd.riskai = ExamManagementController.getProgramData('riskai', closedKey);
        apd.raij = ExamManagementController.getProgramData('raij', closedKey);
        return apd;
    }
    
    static public programInfo getProgramData(String programType, String closedKey) {
        programInfo pri = new programInfo();
        
        // Set Default Values
        pri.name = programType == 'frm'  ? 'Financial Risk Manager' :
                    programType == 'erp'  ? 'Energy Risk Professional' :
                    programType == 'scr'  ? 'Sustainability and Climate Risk' :
                    programType == 'raij' ? 'Risk and AI in Japanese' :
                    'Risk and Artificial Intelligence';
        pri.type = programType;
        pri.isEnrolled = False;
        pri.isLapsed = False;
        pri.isAllPartsPassed = False;
        pri.isAllPartsPassedHideCard = False;
        pri.isCVAwaitingReview = False;
        pri.isCertified = False;
        pri.isRegistrationOpen = False;
        pri.isPartIAvailableForRegistration = False;
        pri.isPartIIAvailableForRegistration = False;
        //pri.isAdminAvailable = False;
        //pri.isDeferralAvailable = False;
        pri.isMissingFullID = False;
        
        Date tdy = Date.today();
        DateTime now = DateTime.now();
        pri.currentExamYear = (tdy.Month() > 11) ? String.valueOf(tdy.year() + 1) :  String.valueOf(tdy.year());
        pri.mostReleventPart = null;
        
        if(programType == 'frm' || programType == 'erp') {
            partInfo pi1 = new partInfo();
            
            pi1.name = programType == 'frm' ? 'FRM Exam Part I' : 'ERP Exam Part I';
            pi1.isOSTA = False;
            pi1.isPaid = False;
            pi1.isScheduled = False;                
            pi1.isSetupComplete = False;                
            pi1.isSchedulingLapsed = False;                
            pi1.isPassed = False;                
            pi1.isDeferred = False;                
            pi1.isExamAwaitingResults = False;
            pi1.isExamResultsAvailable = False;
            pi1.showExamResults = False;
            pi1.isScheduleWindowAvailable = False;
            pi1.isActiveExamAdmin = False;
            pi1.hasViloation = False;
            pi1.allowSchedulingOverride = False;
            pi1.isSchedulingOpen = False;
            pi1.isAdminModOpen = False;
            pi1.showRAD = False;
            
            partInfo pi2 = new partInfo();
            pi2.name = programType == 'frm' ? 'FRM Exam Part II' : 'ERP Exam Part II';
            pi2.isOSTA = False;
            pi2.isPaid = False;
            pi2.isScheduled = False;                
            pi2.isSetupComplete = False;                
            pi2.isSchedulingLapsed = False;                
            pi2.isPassed = False;                
            pi2.isDeferred = False;     
            pi2.isExamAwaitingResults = False;
            pi2.isExamResultsAvailable = False;
            pi2.showExamResults = False;
            pi2.isScheduleWindowAvailable = False;
            pi2.isActiveExamAdmin = False;
            pi2.hasViloation = False;
            pi2.allowSchedulingOverride = False;    
            pi2.isSchedulingOpen = False;
            pi2.isAdminModOpen = False;
            pi2.showRAD = False;
            
            pri.part1 = pi1;
            pri.part2 = pi2;
        } else {
            partInfo pi1 = new partInfo();
            
            pi1.name = programType == 'scr'    ? 'SCR Exam' :
            programType == 'raij'   ? 'Risk and AI in Japanese Exam' :
            programType == 'riskai' ? 'Risk AI Exam' :
            null;
            
            pi1.isOSTA = false;
            pi1.isPaid = false;
            pi1.isScheduled = false;                
            pi1.isSetupComplete = false;                
            pi1.isSchedulingLapsed = false;                
            pi1.isPassed = false;                
            pi1.isDeferred = false;    
            pi1.isExamAwaitingResults = false;
            pi1.isExamResultsAvailable = false;
            pi1.isActiveExamAdmin = false;
            
            pri.part1 = pi1;
        }/*else if(programType == 'scr') {
            partInfo pi1 = new partInfo();
            
            pi1.name = 'SCR Exam';
            pi1.isOSTA = False;
            pi1.isPaid = False;
            pi1.isScheduled = False;                
            pi1.isSetupComplete = False;                
            pi1.isSchedulingLapsed = False;                
            pi1.isPassed = False;                
            pi1.isDeferred = False;    
            pi1.isExamAwaitingResults = False;
            pi1.isExamResultsAvailable = False;
            pi1.isActiveExamAdmin = False;
            
            pri.part1 = pi1;
        } else {
            partInfo pi1 = new partInfo();
            
            pi1.name = 'Risk AI Exam';
            pi1.isOSTA = False;
            pi1.isPaid = False;
            pi1.isScheduled = False;                
            pi1.isSetupComplete = False;                
            pi1.isSchedulingLapsed = False;                
            pi1.isPassed = False;                
            pi1.isDeferred = False;    
            pi1.isExamAwaitingResults = False;
            pi1.isExamResultsAvailable = False;
            pi1.isActiveExamAdmin = False;
            
            pri.part1 = pi1;
        } */
        
        //System.debug('pri:' + pri);
        
        //system.assert(false, 'BOOM!3'+ pri );
        
        // User and Contact
        String userId ;
        if(test.isRunningTest()){
           User u = [Select id from user LIMIT 1];  
           userId = u.Id; 
        } else {
            userId = UserInfo.getUserId(); 
        }
        Contact contact;
        List<User> lstUser = [Select u.Id,u.ContactId, FullPhotoUrl from User u where u.Id = :userId];
        /*system.debug('userId======>'+userId);
        system.debug('lstUser.id==========>'+lstUser[0].id);
        system.debug('lstUser.ContactId==========>'+lstUser[0].ContactId);*/
        if( lstUser != null && lstUser.size() > 0 ) {   
            List<Contact> lstCont = new List<Contact>();
            if(test.isRunningTest()){
                lstCont = [Select Id, Name, AccountId, Name_as_it_Appears_on_ID__c, 
                           ID_Type__c,First_Name_as_it_Appears_on_ID__c,Phone,
                           Middle_Name_as_it_Appears_on_ID__c,Last_Name_as_it_Appears_on_ID__c,
                           ID_Number__c, ID_Expiration_Date__c,Full_Name_in_Chinese__c,
                           Gender__c, Birthdate, Currently_Working_Status__c, Company__c,
                           Currently_in_School_Status__c,School_Name__c, 
                           Degree_Program_Name__c, HomePhone, OSTA_Full_ID__c, OSTA_ID_Location__c  from Contact LIMIT 1];
            
            } else {
            lstCont = [Select Id, Name, AccountId, Name_as_it_Appears_on_ID__c, First_Name_as_it_Appears_on_ID__c, Middle_Name_as_it_Appears_on_ID__c, 
                       Last_Name_as_it_Appears_on_ID__c, ID_Type__c, ID_Number__c, ID_Expiration_Date__c, 
                       Full_Name_in_Chinese__c, Gender__c, Birthdate, Currently_Working_Status__c, Company__c, Currently_in_School_Status__c,
                       School_Name__c, Degree_Program_Name__c, HomePhone, Phone, OSTA_Full_ID__c, OSTA_ID_Location__c 
                       from Contact where Id = :lstUser[0].ContactId];
                
            }
                        
            if(lstCont != NULL && lstCont.size() > 0) {
                contact = lstCont[0];
                
                LIST<Contract> OSTAPrograms = [
                    SELECT Id, Name, Status, RecordType.Name, AccountId, EndDate
                    FROM Contract
                    WHERE 
                    AccountId = :contact.AccountId AND
                    RecordType.Name = 'OSTA Program' AND
                    Status LIKE 'Activated%'
                    Order by StartDate DESC
                ];
                
                if(programType == 'scr' || programType == 'riskai' || programType == 'raij') {
                    if(contact.First_Name_as_it_Appears_on_ID__c != NULL) {
                        pri.idName = contact.First_Name_as_it_Appears_on_ID__c;
                    }
                    if(contact.Middle_Name_as_it_Appears_on_ID__c != NULL) {
                        if(pri.idName != NULL) {
                            pri.idName = pri.idName + ' ';
                        }
                        pri.idName += contact.Middle_Name_as_it_Appears_on_ID__c;
                    }
                    if(contact.Last_Name_as_it_Appears_on_ID__c != NULL) {
                        if(pri.idName != NULL) {
                            pri.idName = pri.idName + ' ';
                        }
                        pri.idName += contact.Last_Name_as_it_Appears_on_ID__c;
                    }
                    
                } else {
                    pri.idName = contact.Name_as_it_Appears_on_ID__c;                
                }
                pri.idNumber = contact.ID_Number__c;
                pri.idType = contact.ID_Type__c;
                pri.idLocation = contact.OSTA_ID_Location__c;
                pri.idExpireDate = contact.ID_Expiration_Date__c;
                pri.gender = contact.Gender__c;
                pri.ostaChineseName = contact.Full_Name_in_Chinese__c;
                pri.ostaDateOfBirth = contact.Birthdate;
                if(contact.HomePhone != NULL) {
                    pri.ostaPhone = contact.HomePhone;
                } else {
                    pri.ostaPhone = contact.Phone;
                }
                
                pri.ostaWorkStatus = contact.Currently_Working_Status__c;
                pri.ostaCompany = contact.Company__c;
                pri.ostaEducationStatus = contact.Currently_in_School_Status__c;
                pri.ostaSchool = contact.School_Name__c;
                pri.ostaDegree = contact.Degree_Program_Name__c;
                
                if(!OSTAPrograms.isEmpty() && (contact.OSTA_Full_ID__c == NULL ||
                   validateIDFormat(contact.OSTA_Full_ID__c, contact.OSTA_ID_Location__c, pri.idType) == False)) {
                    pri.isMissingFullID = TRUE;
                }
                
            } else {
                return null;
            }
            
            /*System.debug('contact:' + contact);
            System.debug('pri:' + pri); */           
           
            // Contract
            String recordTypeName = programType.toUpperCase() + ' Program';
            if(programType == 'riskai') {
                recordTypeName = 'Risk AI Program';
            }
            LIST<Contract> programs = [
                SELECT Id, Name, Status, RecordType.Name, AccountId, EndDate
                FROM Contract
                WHERE 
                AccountId = :contact.AccountId AND
                RecordType.Name = :recordTypeName AND
                (Status LIKE 'Activated%' OR Status = 'Expired' OR Status = 'Completed')
                Order by StartDate DESC
            ];
            
           // System.debug('programs:' + programs);
            
            // New Exam Results Block - move getting exam attempts
            Exam_Attempt__c p1;
            Exam_Attempt__c p2;

            // Exam Registrations
            List<String> examName;
            if(programType == 'frm') {
                examName = new list<String> { 'FRM Part 1', 'FRM Part 2', 'FRM Full Program' };
            } else if(programType == 'erp') {
                examName = new list<String> { 'ERP Exam Part I', 'ERP Exam Part II', 'ERP' };
            } else if(programType == 'scr') {
                examName = new list<String> { 'SCR' };                        
            } else if(programType == 'riskai') {
                examName = new list<String> { 'RiskAI' };                        
            }else if(programType == 'raij') {
                examName = new list<String> { 'RAIJ' };                        
            }
            
            //System.debug('examName:' + examName);
            
            List<Exam_Attempt__c> lstExamReg = [select Id, Exam_Site__c, Defered__c, Deferral_Status__c, Deferred_Exam_Administration__c,
                                                Deferred_Exam_Administration__r.Exam_Scheduling_Start_Date__c,  
                                                Deferred_Exam_Administration__r.Exam_Scheduling_End_Date__c,
                                                Deferred_Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
                                                Deferred_Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
                                                Deferred_Exam_Administration__r.Month__c,
                                                Deferred_Exam_Administration__r.Year__c,
                                                Hide_Exam_Result__c,
                                                Result__c,hasViolation__c,Allow_Scheduling_Override__c,
                                                Exam_Site__r.Name,
                                                Exam_Site__r.Exam__r.Exam__c, 
                                                Exam_Site__r.Exam__r.Exam_Group__c, 
                                                Member__c, Member__r.AccountId, 
                                                Opportunity_StageName__c,
                                                Opportunity__c, Opportunity__r.AccountId, Integration_Data_Status__c, Seat_No__c,
                                                Active_Integration_Data__c, Active_Integration_Data__r.Call_out_Status__c, Ticket_Download_Date__c,
                                                Integration_Data_Exam_Location__c, 
                                                Integration_Data_Exam_Scheduled_Date__c,
                                                Exam_Part__r.Delivery_Method__c,
                                                Exam_Administration__c,
                                                Exam_Administration__r.Name,
                                                Exam_Administration__r.Exam_Results_Loading__c,
                                                Exam_Administration__r.Exam_Results_Release_Date__c,
                                                Exam_Administration__r.Exam_Results_Available_Statement__c,
                                                Exam_Administration__r.Registration_Start_Date__c,  
                                                Exam_Administration__r.Registration_End_Date__c,
                                                Exam_Administration__r.Exam_Scheduling_Start_Date__c,   
                                                Exam_Administration__r.Exam_Scheduling_End_Date__c,
                                                Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
                                                Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
                                                Exam_Administration__r.Month__c,
                                                Exam_Administration__r.Year__c,
                                                Exam_Administration__r.Last_Date_For_ADA__c,
                                                Exam_Administration__r.Last_Date_For_RAD__c,
                                                Original_Exam_Administration__c,
                                                Exam_Part__r.Exam_Date__c,
                                                Exam_Part__r.Exam_Start_Date__c,                                                
                                                Exam_Part__r.Exam_End_Date__c,
                                                Exam_Part__r.Exam_Results_Release_Date__c,Exam_Part__r.Exam_Results_Available_Statement__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Exam_Change_Start_Date_Time__c,                                                
                                                Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_To_Request_Exam_Change__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_To_Apply_For_Deferral__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Exam_Ticket_Available_Date__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Exam_Date__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Loading_Exam_Results__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Last_Date_For_ADA__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Religious_Alternative_Last_Date__c,
                                                Exam_Site__r.Exam_Provider__r.Name,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Active__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.SCR_Active__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__r.Registration_Start_Date__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__r.Exam_Change_Start_Date_Time__c,
                                                Exam_Site__r.Exam__r.Exam_Group__r.Next_Exam_Group__r.Exam_Date__c,
                                                Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,
                                                Exam_Site__r.Site__r.Is_Gender_Required__c
                                                from Exam_Attempt__c where 
                                                Member__c = :contact.Id AND Cancelled__c = False AND
                                                Exam_Site__r.Exam__r.Exam__c in :examName ORDER BY RPT_Exam_Date__c DESC];         
            
            //System.debug('lstExamReg:' + lstExamReg);
            
            // Get Exam Registrations By Part
            if(lstExamReg != NULL && lstExamReg.size() > 0) {
                for(Exam_Attempt__c ea: lstExamReg) {
                    
                   /* System.debug('ea:' + ea);
                    System.debug('ea.Exam_Site__r.Exam__r.Exam__c:' + ea.Exam_Site__r.Exam__r.Exam__c); */
                    
                    if((programType == 'scr' || programType == 'riskai' || programType == 'raij') && p1 == null) {
                        p1 = ea;
                    } else if(p1 == NULL && (ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 1' || ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Full Program' || ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part I' || ea.Exam_Site__r.Exam__r.Exam__c == 'ERP')) {
                        p1 = ea;
                    } else if(p2 == NULL && (ea.Exam_Site__r.Exam__r.Exam__c == 'FRM Part 2' || ea.Exam_Site__r.Exam__r.Exam__c == 'ERP Exam Part II')) {
                        p2 = ea;
                    }
                  /*  System.debug('set p1:' + p1);
                    System.debug('set p2:' + p2); */
                }                
            }

           /* System.debug('p1:' + p1);
            System.debug('p2:' + p2);   */         
            
            // New Results Block -- Setup Boolean for use below            
            Boolean isLoadingResults = False;  // Loading any results
            Boolean isLoadingPart1Results = False;
            Boolean isLoadingPart2Results = False;
            
            if(p1 != NULL && isLoadingResults(p1.Exam_Administration__r.Exam_Results_Loading__c,closedKey)) {
                isLoadingResults = True;
                isLoadingPart1Results = True;
            }
            
            if(p2 != NULL && isLoadingResults(p2.Exam_Administration__r.Exam_Results_Loading__c,closedKey)) {
                isLoadingResults = True;
                isLoadingPart2Results = True;
            }
            
            // New Results Block -- does not seem to be in use
            //MAP<String,Boolean> mapExamPartPass = new MAP<String,Boolean>();
            if(programs != NULL && programs.size() > 0) {
                Contract program = programs[0];
                
                if(program.Status == 'Expired' && programType != 'scr' && programType != 'riskai' && programType != 'raij') {
                    pri.isLapsed = True;
                } else if(program.Status == 'Completed') {
                    pri.isCertified = True;   
                } else {
                    pri.isEnrolled = True;    
                }
                pri.programExpireDate = program.EndDate;
                
               // System.debug('pri:' + pri);

                // Check Program Parts
                // New Results Block -- Update logic to check isLoading
                if(programType == 'frm') {
                    
                    List<Candidate_Requirement__c> lstCanReq = [select Id, Name, Status__c, Exam__c, Date_of_Completion__c from Candidate_Requirement__c where Candidate_Commitment__c = :program.Id];                    
                   // System.debug('lstCanReq:' + lstCanReq);

                    Integer partCnt=0;
                    Date mostRecentPass= Date.newInstance(1970, 1, 1);
                    if(lstCanReq != NULL && lstCanReq.size() > 0) {
                        for(Candidate_Requirement__c cr:lstCanReq) {
                            
                            Boolean isLoading = False;
                            if(cr.Exam__c != NULL && cr.Exam__c == 'FRM Part I' && isLoadingPart1Results) {
                                isLoading = True;
                            } else if(cr.Exam__c != NULL && cr.Exam__c == 'FRM Part II' && isLoadingPart2Results) {
                                isLoading = True;
                            }
                            
                            if(cr.Status__c == 'Completed' && cr.Exam__c != NULL && !isLoading) {
                                //mapExamPartPass.put(cr.Exam__c,TRUE);  
                                partCnt++;
                                if(cr.Exam__c == 'FRM Full' || cr.Exam__c == 'ERP') {
                                    partCnt++;
                                }
                                if(cr.Date_of_Completion__c > mostRecentPass) {
                                    mostRecentPass = cr.Date_of_Completion__c;
                                }
                            //} else if(cr.Exam__c != NULL) {
                            //    mapExamPartPass.put(cr.Exam__c,FALSE);
                            } else if(cr.Status__c == 'Ready For Review' && !isLoadingResults) {
                                // Job Awaiting Review
                                pri.isCVAwaitingReview = True;
                            } else if(cr.Status__c == 'Failed Review' && !isLoadingResults) {
                                // Job Awaiting Review
                                pri.isCVFailedReview = True;
                            }
                        }
                    }
                    
                   // System.debug('partCnt:' + lstCanReq);
                    //System.debug('mapExamPartPass:' + mapExamPartPass);
                    
                    if(partCnt == 2) {
                        pri.isAllPartsPassed = True; 
                        if(tdy > mostRecentPass.addDays(60)) {
                            pri.isAllPartsPassedHideCard = True;
                        }
                    }   
                    
                   // System.debug('pri:' + pri);
                    
                }
            }
            
            // Get Active Exam Admin Info
            String examType = programType.toUpperCase();
            if(programType == 'riskai') {
                examType = 'RiskAI';
            }
            List<Exam_Administration__c> lstAdmins = [select Id, Name, Registration_Start_Date__c, Registration_End_Date__c,  
                                                      Exam_Admin_Modifications_Start_Date__c, Exam_Admin_Modifications_End_Date__c,
                                                      Exam_Scheduling_Start_Date__c, Exam_Scheduling_End_Date__c,
                                                      Exam_Type__c, Month__c, Year__c
                                                      from Exam_Administration__c
                                                      where Exam_Type__c = :examType AND 
                                                      ((Registration_Start_Date__c <= TODAY AND 
                                                      Registration_End_Date__c >= TODAY) OR Registration_Start_Date__c > TODAY) AND
                                                      Contingency_Administration__c = False
                                                      ORDER BY Registration_Start_Date__c
                                                     ];
            //System.debug('lstAdmins:' + lstAdmins);
            
            String currentExamAdmin;
            if(!lstAdmins.isEmpty()) {
                for(Exam_Administration__c ea :lstAdmins) {
                    
                    if(ea.Registration_Start_Date__c <= tdy && ea.Registration_End_Date__c >= tdy) {
                        pri.isRegistrationOpen = True;
                        pri.registrationOpenName = ea.Month__c + ' ' + String.valueOf(ea.Year__c);
                        currentExamAdmin = ea.id;
                    } else if(pri.nextAdminRegistrationOpenDate == NULL && ea.Registration_Start_Date__c > tdy) {
                        pri.nextAdminRegistrationOpenDate = ea.Registration_Start_Date__c;
                        pri.nextAdminRegistrationOpenName = ea.Month__c + ' ' + String.valueOf(ea.Year__c);
                    }
                }
            }
            /*System.debug('pri.isRegistrationOpen:' + pri.isRegistrationOpen);
            System.debug('lstAdmins:' + lstAdmins);
            System.debug('pri.registrationOpenName:' + pri.registrationOpenName); */
            
            if(currentExamAdmin != NULL) {
                List<Exam_Registration_Window__c> lstWindows = [select id, Type__c, Exam_Registration_Window_Open__c, 
                                                                Exam_Registration_Window_Close__c 
                                                                from Exam_Registration_Window__c 
                                                                where Exam_Administration__c = :currentExamAdmin AND
                                                                Exam_Registration_Window_Open__c <= TODAY AND
                                                                Exam_Registration_Window_Close__c >= TODAY];
                if(!lstWindows.isEmpty()) {
                    pri.currentWindow = lstWindows[0].Type__c;
                    pri.currentWindowEndDate = lstWindows[0].Exam_Registration_Window_Close__c;
                }
            }
            /*System.debug('pri.currentWindow:' + pri.currentWindow);
            System.debug('pri.currentWindowEndDate:' + pri.currentWindowEndDate);*/
            
            
            // AG - Need to add this back!
            //if(tdy >= examGroup.Registration_Start_Date__c && tdy <= examGroup.Last_Date_For_Early_Registration__c) {
            //    pri.currentWindow = 'Early';
            //    pri.currentWindowEndDate = examGroup.Last_Date_For_Early_Registration__c;
            //} else {
            //    pri.currentWindow = 'Standard';
            //    pri.currentWindowEndDate = examGroup.Last_Date_For_Standard_Registration__c;                        
            //}
            
            //System.debug('priX:' + pri);
            
            if(programType == 'frm') {
                
                GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(contact.Id);
                GARP_Common.debugLog('ExamManagementController','getProgramData','membershipInfo',membershipInfo);
                
                // New Exam Results Block - No exam is eligable while loading
                //if(membershipInfo != NULL) {
                String programPart = 'Full';
                if(membershipInfo != NULL && !isLoadingResults) {
                    GARP_BC_Registration.RegistrationEligibility regElig = GARP_BC_Exams.isEligibleFRM(membershipInfo,closedKey);
                    GARP_Common.debugLog('ExamManagementController','getProgramData','regElig',regElig);
                    if(regElig != NULL) {
                        pri.registrationEligibility = regElig;
                        if(regElig.eligibleExams.contains('FRM Part 1')) {
                            pri.isPartIAvailableForRegistration = True;
                            programPart = '1';
                        }
                        if(regElig.eligibleExams.contains('FRM Part 2')) {
                            pri.isPartIIAvailableForRegistration = True;
                            programPart = '2';
                        }
                    }   
                }
                
                // AG 11/2/2022 - BenchPrep
                pri.eLearningSSOLink = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id, 'FRM', programPart);
                
                //FrmRegistrationForm form = new FrmRegistrationForm();
                //ExamRegistrationForm.RegistrationEligibility ee = form.getExamEligibility(contact.Id, closedKey);
                //System.debug('ee:' + ee);      
                //pri.registrationEligibility = ee;
                
                //if(ee != NULL && ee.eligibleExams != NULL && ee.eligibleExams.contains('FRM Part 1')) {
                //    pri.isPartIAvailableForRegistration = True;
                //}
                
                //if(ee != NULL && ee.eligibleExams != NULL && ee.eligibleExams.contains('FRM Part 2')) {
                //    pri.isPartIIAvailableForRegistration = True;
                //}

            } else if(programType == 'erp') {
                
                //ErpRegistrationForm form = new ErpRegistrationForm();
                //ExamRegistrationForm.RegistrationEligibility ee = form.getEligibileExams(contact.Id);
                //System.debug('ee:' + ee);                
                //pri.registrationEligibility = ee;
                    
                //if(ee != NULL && ee.eligibleExams != NULL && ee.eligibleExams.contains('ERP Exam Part I')) {
                //    pri.isPartIAvailableForRegistration = True;
                //}

                //if(ee != NULL && ee.eligibleExams != NULL && ee.eligibleExams.contains('ERP Exam Part II')) {
                //    pri.isPartIIAvailableForRegistration = True;
                //}
                
            } else if(programType == 'scr') {
                
                //ScrExamRegistrationForm form = new ScrExamRegistrationForm();
                //ExamRegistrationForm.RegistrationEligibility ee = form.getExamEligibility(contact.Id, closedKey);
                //System.debug('ee:' + ee);                
                //pri.registrationEligibility = ee;

                //if(ee != NULL && ee.eligibleExams != NULL && ee.eligibleExams.contains('SCR')) {
                //    pri.isPartIAvailableForRegistration = True;
                //}
                
                GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(contact.Id);
                GARP_Common.debugLog('ExamManagementController','getProgramData','membershipInfo',membershipInfo);
                
                Boolean isLoading = False;
                if(p1 != NULL) {
                    isLoading = isLoadingResults(p1.Exam_Administration__r.Exam_Results_Loading__c,closedKey);
                }
                
                // New Exam Results Block - No exam is eligable while loading
                //if(membershipInfo != NULL) {
                if(membershipInfo != NULL && !isLoading) {
                    GARP_BC_Registration.RegistrationEligibility regElig; //= GARP_BC_Courses.isEligibleSCR(membershipInfo);
                    GARP_Common.debugLog('ExamManagementController','getProgramData','regElig',regElig);
                    if(regElig != NULL) {
                        pri.registrationEligibility = regElig;
                        if(regElig.eligibleExams.contains('SCR')) {
                            pri.isPartIAvailableForRegistration = True;
                        }
                    }   
                }
                
                // AG 11/2/2022 - BenchPrep
                pri.eLearningSSOLink = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id, 'SCR','Full');
                
            } else if(programType == 'riskai') {
                
                GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(contact.Id);
                GARP_Common.debugLog('ExamManagementController','getProgramData','membershipInfo',membershipInfo);
                
                if(membershipInfo != NULL) {
                    GARP_BC_Registration.RegistrationEligibility regElig; // = GARP_BC_Courses.isEligibleRiskAI(membershipInfo);
                    GARP_Common.debugLog('ExamManagementController','getProgramData','regElig',regElig);
                    if(regElig != NULL) {
                        pri.registrationEligibility = regElig;
                        if(regElig.eligibleExams.contains('RiskAI')) {
                            pri.isPartIAvailableForRegistration = True;
                        }
                    }   
                }
                
                // AG 11/2/2022 - BenchPrep
                pri.eLearningSSOLink = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id,'RAI','Full');
            } else if(programType == 'raij') {                
                GARP_BC_Membership.membershipInfo membershipInfo = GARP_BC_Membership.getMembershipInfo(contact.Id);                 
                if(membershipInfo != NULL) {
                    GARP_BC_Registration.RegistrationEligibility regElig;  
                    if(regElig != NULL) {
                        pri.registrationEligibility = regElig;
                        if(regElig.eligibleExams.contains('RAIJ')) {
                            pri.isPartIAvailableForRegistration = True;
                        }
                    }   
                }                
                // AG 11/2/2022 - BenchPrep
                pri.eLearningSSOLink = GARP_BC_StudyMaterials.getBenchPrepSSOLink(contact.Id,'RAIJ','Full');
            }
            
            //System.debug('pri:' + pri);
            
            // AG 12/7/2022 - Set Display State
            pri.programState = 'IN_PROGRESS';
            if(pri.isLapsed) {
                pri.programState = 'LAPSED_PROGRAM';
            } else if(pri.isCertified) {
                pri.programState = 'CERTIFIED';
            } else if(pri.isAllPartsPassed) {
                pri.programState = 'WORK_EXPERIENCE';
            }
            
            // Get Exam Registrations By Part
            if(lstExamReg != NULL && lstExamReg.size() > 0) {
                
                // Compute Part 1 Data
                if(p2 != null) {
                    pri.part2 = setProgramPartInfo(programType, pri, p2, 'II', pri.part2, closedKey);
                    pri.mostReleventPart = '2';
                    //System.debug('pri.part2:' + pri.part2);
                }

                if(p1 != null) {
                    pri.part1 = setProgramPartInfo(programType, pri, p1, 'I', pri.part1, closedKey);
                    pri.mostReleventPart = '1';
                    //System.debug('pri.part1:' + pri.part1);   
                }
                
                // Set BenchPrep Access
                if(pri.part1 != NULL && pri.part1.examEndDate != NULL) {
                                            
                    pri.part1.hasBenchPrepAccess = False;
                    pri.part1.hasPracticeExamAccess = False;
                    Boolean isDeferred = (pri.part1.programPartState == 'DEFERRED');
                    
                    /*System.debug('examEndDate:' + pri.part1.examEndDate);
                    System.debug('isDeferred:' + isDeferred);*/
                    
                    if(tdy <= pri.part1.examEndDate || isDeferred) {
                        pri.part1.hasBenchPrepAccess = True;
                        pri.part1.hasPracticeExamAccess = True;
                    }                    
                    /*System.debug('hasBenchPrepAccess:' + pri.part1.hasBenchPrepAccess);
                    System.debug('hasPracticeExamAccess:' + pri.part1.hasPracticeExamAccess); */
                }
                
                if(pri.part2 != NULL && pri.part2.examEndDate != NULL) {
                    pri.part2.hasBenchPrepAccess = False;
                    pri.part2.hasPracticeExamAccess = False;
                    Boolean isDeferred = (pri.part2.programPartState == 'DEFERRED');
                    
                   /* System.debug('examEndDate:' + pri.part2.examEndDate);
                    System.debug('isDeferred:' + isDeferred); */
                
                    if(tdy <= pri.part2.examEndDate || isDeferred) {
                        // No BenchPrep for Part II yet
                        //pri.part1.hasBenchPrepAccess = True;
                        pri.part2.hasPracticeExamAccess = True;
                    }                    
                   /* System.debug('hasBenchPrepAccess:' + pri.part2.hasBenchPrepAccess);
                    System.debug('hasPracticeExamAccess:' + pri.part2.hasPracticeExamAccess);*/
                }

                if(programType != 'erp') {
                    if(pri.part1.programPartState == 'RESULTS_AVAILABLE' || (pri.part2 != NULL && pri.part2.programPartState == 'RESULTS_AVAILABLE')) {
                        if((pri.part1.result != NULL && pri.part1.result == 'Pass') && pri.part2 != NULL && pri.part2.examRegId == NULL) {
                            pri.examResultState = 'REGISTER_NEXT';
                        } else if((pri.part1.result != NULL && pri.part1.result != 'Pass') || (pri.part2 != NULL && pri.part2.result != 'Pass')) {
                            pri.examResultState = 'REGISTER_AGAIN';
                        }
                    }
                }
            }            
            
        }        
        
        return pri;
    }

    static public void updateOSTAIDInfo(Id contactId, String idType, String idNumber, String idLocation, Date expDate) {
        
        DateTime now = DateTime.now();
        List<Contact> lstCont = [select Id, ID_Type__c, ID_Number__c, ID_Expiration_Date__c, OSTA_Consent__c, OSTA_Full_ID__c, OSTA_ID_Location__c from Contact where id = :contactId];
        if(lstCont != NULL && lstCont.size() > 0) {
            Contact contact = lstCont[0];
            if(idType.indexOf('Driver') > -1) {
                contact.ID_Type__c = 'Driver\'s License';
            } else {
                contact.ID_Type__c = idType;    
            }
            contact.ID_Number__c = idNumber.right(5);
            contact.OSTA_ID_Location__c = idLocation;
            contact.OSTA_Full_ID__c = idNumber;
            contact.ID_Expiration_Date__c = expDate;
            contact.OSTA_Consent__c = now;
            update contact;
        }
        
        programInfo pi = getProgramData('frm','');

        Set<String> regIDs = new Set<String>();
        if(pi.part1.isOSTA) {
            regIDs.add(pi.part1.examRegId);
        }
        if(pi.part2.isOSTA) {
            regIDs.add(pi.part2.examRegId);
        }
        
        if(!regIDs.isEmpty()) {
            List<Exam_Attempt__c> eas = [select id, OSTA_Consent__c from Exam_Attempt__c where id in :regIDs];
            if(!eas.isEmpty()) {
                for(Exam_Attempt__c ea :eas) {
                    ea.OSTA_Consent__c = now;
                }
                update eas;
            }
        }

    }
    
    static public void clearCBTIntegrationAuthorization(String examRegId) {
        List<Exam_Attempt__c> lstEA = [select Id, RPT_Exam_Provider__c, Integration_Type__c, Outbound_Type__c, ATA_PSI_Is_Override__c, 
                                       Pearson_Member_First_Name__c, Pearson_Member_Middle_Name__c, Pearson_Member_Last_Name__c, Pearson_Phone_No__c, Pearson_Email__c,
                                       Billing_Street__c, Billing_City__c, Billing_State__c, Billing_Country__c, Billing_Postal_Code__c,
                                       Member__r.Email, Member__r.First_Name_as_it_Appears_on_ID__c, Member__r.Middle_Name_as_it_Appears_on_ID__c, Member__r.Last_Name_as_it_Appears_on_ID__c, 
                                       Member__r.HomePhone, Member__r.Phone, Member__r.Account.BillingStreet, Member__r.Account.BillingCity, Member__r.Account.BillingCountry,  
                                       Member__r.Account.BillingPostalCode, Member__r.Account.BillingState
                                       from Exam_Attempt__c where id = :examRegId];
        if(lstEA != NULL && lstEA.size() > 0) {
            Exam_Attempt__c ea = lstEA[0];
            
            Boolean isUpdate = False;
            if(ea.Outbound_Type__c != NULL) {
                ea.Outbound_Type__c = NULL;
                ea.Integration_Type__c = NULL;
                isUpdate = True;
            }
            
            if(ea.Pearson_Member_First_Name__c == NULL || ea.Pearson_Member_Last_Name__c == NULL) {
                ea.Pearson_Member_First_Name__c = ea.Member__r.First_Name_as_it_Appears_on_ID__c;
                ea.Pearson_Member_Middle_Name__c = ea.Member__r.Middle_Name_as_it_Appears_on_ID__c;
                ea.Pearson_Member_Last_Name__c = ea.Member__r.Last_Name_as_it_Appears_on_ID__c;
                isUpdate = True;
            }
            
            if(ea.Pearson_Phone_No__c == NULL) {
                if(ea.Member__r.HomePhone != NULL) {
                    ea.Pearson_Phone_No__c = ea.Member__r.HomePhone;
                } else {
                    ea.Pearson_Phone_No__c = ea.Member__r.Phone;
                }
                isUpdate = True;
            }
            
            if(ea.Pearson_Email__c == NULL) {
                ea.Pearson_Email__c = ea.Member__r.Email;
                isUpdate = True;
            }
            
            if(ea.Billing_Street__c == NULL) {
                GARP_Common.address streets = GARP_Common.parseMultiAddressLine(ea.Member__r.Account.BillingStreet);
                ea.Billing_Street__c = streets.street1;
                ea.Billing_City__c = ea.Member__r.Account.BillingCity;
                ea.Billing_State__c = GARP_Common.convertLongStateToCode(ea.Member__r.Account.BillingState);
                ea.Billing_Postal_Code__c = ea.Member__r.Account.BillingPostalCode;
                ea.Billing_Country__c = ea.Member__r.Account.BillingCountry;
                isUpdate = True;
            }
            
            if(isUpdate) {
                update ea;
            }
        }
    }
    
    static public void createCBTIntegrationAuthorization(String examRegId) {
        List<Exam_Attempt__c> lstEA = [select Id, RPT_Exam_Provider__c, Integration_Type__c, Outbound_Type__c, ATA_PSI_Is_Override__c
                                       from Exam_Attempt__c where id = :examRegId];
        if(lstEA != NULL && lstEA.size() > 0) {
            Exam_Attempt__c ea = lstEA[0];
                        
            if(ea.RPT_Exam_Provider__c == 'PSI') {
                ea.Outbound_Type__c = lstEA[0].RPT_Exam_Provider__c;
                ea.Integration_Type__c = 'Eligibility Lifecycle';
                update lstEA;
            } else if(ea.RPT_Exam_Provider__c == 'ATA') {
                ea.Outbound_Type__c = lstEA[0].RPT_Exam_Provider__c;
                ea.Integration_Type__c = 'Import Registration New';
                update lstEA;            
            } else if(ea.RPT_Exam_Provider__c == 'Pearson') {
                ea.Outbound_Type__c = lstEA[0].RPT_Exam_Provider__c;
                ea.Integration_Type__c = 'Ping Database;CDD;EAD';
                
                update lstEA;            
            }
        }
    }

    static public void logFailedAuthorization(String examRegId) {
        AppError__c ae = new AppError__c(Name='CBT Auth Failed',Message__c=examRegId);
        insert ae;
    }
    
    static public Opportunity findRefundOpp(Exam_Attempt__c ea) {
      
        //System.debug('findRefundOpp In:' + ea);
        
        Set<String> opIDs = new Set<String>();
        
        // Get Main EA
        Exam_Attempt__c mainEA;
        mainEA=fetchExamRegistrationInContext(ea.Id);
        if(mainEA != NULL) {
            opIDs.add(mainEA.Opportunity__c);
            if(mainEA.Opportunity_Line_Items__r != NULL) {
                for(OpportunityLineItem oli :mainEA.Opportunity_Line_Items__r) {
                    opIDs.add(oli.OpportunityId);    
                }
                
            }
        }
        
        //System.debug('opIDs:' + opIDs);
        
        // Find Cloned EA
        Exam_Attempt__c clonedEA;
        if(ea.Cloned_From__c!=NULL) {
            clonedEA=fetchExamRegistrationInContext(ea.Cloned_From__c);
            if(clonedEA != NULL) {
                opIDs.add(clonedEA.Opportunity__c);
                if(clonedEA.Opportunity_Line_Items__r != NULL) {
                    for(OpportunityLineItem oli :clonedEA.Opportunity_Line_Items__r) {
                        opIDs.add(oli.OpportunityId);    
                    }                
                }
            }
        }
        
        /*System.debug('clonedEA:' + clonedEA);
        System.debug('opIDs:' + opIDs); */
        
        // Get all Opps and Refunds
        List<Opportunity> lstOpp = [select Id, Name,
                                    (SELECT Id, ProductCode, Product2Id, Product2.ProductCode, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice FROM OpportunityLineItems)
                                    from Opportunity where ID in :opIDs Order BY CreatedDate DESC];
        MAP<String,Integer> mapOpp = new MAP<String,Integer>();
        for(Opportunity opp :lstOpp) {
            for(OpportunityLineItem ol :opp.OpportunityLineItems) {
                if(ol.ProductCode == 'CHLF') {
                    Integer cnt = mapOpp.get(opp.Id);
                    if(cnt == NULL) {
                        mapOpp.put(opp.Id, 1);    
                    } else {
                        cnt++;
                        mapOpp.put(opp.Id, cnt); 
                    }
                }
            }
        }

       /* System.debug('lstOpp:' + lstOpp);
        System.debug('mapOpp:' + mapOpp);*/

        List<Product_Refunds__c> lstRef = [select Id, Name, Opportunity__c from Product_Refunds__c where Opportunity__c in :opIDs AND Product_Code__c = 'CHLF' AND Status__c != 'Denied'];
        MAP<String,Integer> mapRef = new MAP<String,Integer>();
        for(Product_Refunds__c pr :lstRef) {
            Integer cnt = mapRef.get(pr.Opportunity__c);
            if(cnt == NULL) {
                mapRef.put(pr.Opportunity__c, 1);    
            } else {
                cnt++;
                mapRef.put(pr.Opportunity__c, cnt); 
            }
        }
        
       // System.debug('mapRef:' + mapRef);        

        // Get latest Opp with fee and not all refunded
        for(Opportunity opp :lstOpp) {

            Integer fndOpp = mapOpp.get(opp.Id);
           // System.debug('fndOpp:' + fndOpp ); 
            if(fndOpp != NULL) {
                           
                Integer pr = mapRef.get(opp.Id);
               // System.debug('find pr:' + pr);        
                
                if(pr == NULL || pr < fndOpp ) {
                   // System.debug('return fndOpp:' + fndOpp);    
                    return opp;
                }
            }                
        }
        
        return NULL;
    }
    
    //@future(callout=true)
    static public List<Product_Refunds__c> issueProductRefund(String OppId, String prodCode, Integer part) {
        
        //System.debug('part:' + part);
        
        List<Opportunity> lstOppFnd = [select Id, Name,
                                       (SELECT Id, ProductCode, Product2Id, Product2.ProductCode, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice FROM OpportunityLineItems)
                                       from Opportunity where ID = :OppId];
        
        //System.debug('lstOppFnd:' + lstOppFnd);
        
        Set<Id> opportunityIds = new Set<Id>();
        opportunityIds.add(OppId);
        System.Debug('opportunityIds:' + opportunityIds);
        
        Map<Id, sObject> approvedTransactionByOpportunityId = getApprovedTransactionByOpportunityIdMap(opportunityIds);
        System.Debug('approvedTransactionByOpportunityId:' + approvedTransactionByOpportunityId );
                    
        
        List<Product_Refunds__c> prs = new List<Product_Refunds__c>();
        Integer cnt=1;
        for(OpportunityLineItem ol :lstOppFnd[0].OpportunityLineItems) {
            
            /*System.debug('ol:' + ol);
            System.debug('cnt:' + cnt);*/
            
            if(ol.ProductCode == prodCode) {
            
                if(cnt <= part) {                
                    Product_Refunds__c productRefund = new Product_Refunds__c();
                    
                    productRefund.Payment_Order_Transaction__c    = null;
                    productRefund.Legacy_Transaction__c = null;
                    productRefund.Status__c                 = 'Submitted';
                    productRefund.Product__c                = ol.Product2Id;
                    productRefund.Opportunity__c            = OppId;         
                    productRefund.Reason__c                 = ol.Description;
                    productRefund.Refund_Amount__c          = (ol.UnitPrice*ol.Quantity).setScale(2);
                    productRefund.Sales_Price__c            = (ol.UnitPrice*ol.Quantity).setScale(2);
                    productRefund.Opportunity_Product_ID__c = ol.Id;
                    
                    if(approvedTransactionByOpportunityId.containsKey(OppId)){
                        sObject trans = approvedTransactionByOpportunityId.get(OppId);
                        if(trans.getSobjectType() == orderTransaction){
                            productRefund.Payment_Order_Transaction__c = (Id)trans.get('Id');
                        }else if(trans.getSobjectType() == legacyTransaction){
                            productRefund.Legacy_Transaction__c = (Id)trans.get('Id');
                        }
                    }
                    
                    //System.debug('Add productRefund:' + productRefund);
                    prs.add(productRefund);    
                    }
                
                cnt++;                                
            }
            
        }    
        
        //System.debug('prs:' + prs);
        
        return prs;
    }
    
    static public ostaMaps computeOSTAProgramMoves(Exam_Attempt__c examRegPartI, Exam_Attempt__c examRegPartII, Exam_Sites__c currentSitePartI, Exam_Sites__c currentSitePartII, Exam_Administration__c currentAdminPartI, Exam_Administration__c currentAdminPartII,
                                                   Exam_Sites__c selectedSitePartI, Exam_Sites__c selectedSitePartII, Exam_Administration__c selectedAdminPartI, Exam_Administration__c selectedAdminPartII
                                                  ) {

                                                      
            ostaMaps om = new ostaMaps(); 
                                                      
            /*System.debug('examRegPartI:' + examRegPartI);
            System.debug('examRegPartII:' + examRegPartII);
            System.debug('currentSitePartI:' + currentSitePartI);
            System.debug('currentSitePartII:' + currentSitePartII);
            System.debug('currentAdminPartI:' + currentAdminPartI);
            System.debug('currentAdminPartII:' + currentAdminPartII);
            System.debug('selectedSitePartI:' + selectedSitePartI);
            System.debug('selectedSitePartII:' + selectedSitePartII);
            System.debug('selectedAdminPartI:' + selectedAdminPartI);
            System.debug('selectedAdminPartII:' + selectedAdminPartII); */
            
            om.mapCurrentPartOSTA = new MAP<String,Exam_Part__c>();
            om.mapSelectedPartOSTA = new MAP<String,Exam_Part__c>();
        
            //system.debug('currentSitePartII=========>'+currentSitePartII);
            //system.debug('currentSitePartII.Site__r.Is_OSTA_Information_Required__c=========>'+currentSitePartII.Site__r.Is_OSTA_Information_Required__c);
            //system.debug('currentSitePartII.Site__c=========>'+currentSitePartII.Site__c);
                                                      
            if(currentSitePartII != NULL && currentSitePartII.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapCurrentAdminOSTA.put(currentSitePartII.Exam_Part__r.Exam_Administration__c, currentSitePartII.Exam_Part__r);
                om.mapCurrentPartOSTA.put(currentSitePartII.Exam_Part__c, currentSitePartII.Exam_Part__r);
            }
            if(currentSitePartI != NULL && currentSitePartI.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapCurrentAdminOSTA.put(currentSitePartI.Exam_Part__r.Exam_Administration__c, currentSitePartI.Exam_Part__r);
                om.mapCurrentPartOSTA.put(currentSitePartI.Exam_Part__c, currentSitePartI.Exam_Part__r);
            }
                                                      
            // If Part was deferred out and current site is OSTA, assume they are going to an OSTA site
            if(currentSitePartII == NULL && selectedAdminPartII != NULL && examRegPartII != NULL && examRegPartII.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapCurrentAdminOSTA.put(currentAdminPartII.Id, examRegPartII.Exam_Site__r.Exam_Part__r);
                om.mapCurrentPartOSTA.put(examRegPartII.Exam_Site__r.Exam_Part__c, examRegPartII.Exam_Site__r.Exam_Part__r);
            }
            if(currentSitePartI == NULL && selectedAdminPartI != NULL && examRegPartI != NULL && examRegPartI.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapCurrentAdminOSTA.put(currentAdminPartI.Id, examRegPartI.Exam_Site__r.Exam_Part__r);
                om.mapCurrentPartOSTA.put(examRegPartI.Exam_Site__r.Exam_Part__c, examRegPartI.Exam_Site__r.Exam_Part__r);
            }
            
            if(selectedSitePartII != NULL && selectedSitePartII.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapSelectedAdminOSTA.put(selectedSitePartII.Exam_Part__r.Exam_Administration__c, selectedSitePartII.Exam_Part__r);
                om.mapSelectedPartOSTA.put(selectedSitePartII.Exam_Part__c, selectedSitePartII.Exam_Part__r);
            }
            if(selectedSitePartI != NULL && selectedSitePartI.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapSelectedAdminOSTA.put(selectedSitePartI.Exam_Part__r.Exam_Administration__c, selectedSitePartI.Exam_Part__r);
                om.mapSelectedPartOSTA.put(selectedSitePartI.Exam_Part__c, selectedSitePartI.Exam_Part__r);
            }
            // If Part was deferred out and current site is OSTA, assume they are going to an OSTA site
            if(selectedSitePartII == NULL && selectedAdminPartII != NULL && examRegPartII != NULL && examRegPartII.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapSelectedAdminOSTA.put(selectedAdminPartII.Id, examRegPartII.Exam_Site__r.Exam_Part__r);
                om.mapSelectedPartOSTA.put(examRegPartII.Exam_Site__r.Exam_Part__c, examRegPartII.Exam_Site__r.Exam_Part__r);
            }
            if(selectedSitePartI == NULL && selectedAdminPartI != NULL && examRegPartI != NULL && examRegPartI.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c) {
                //om.mapSelectedAdminOSTA.put(selectedAdminPartI.Id, examRegPartI.Exam_Site__r.Exam_Part__r);
                om.mapSelectedPartOSTA.put(examRegPartI.Exam_Site__r.Exam_Part__c, examRegPartI.Exam_Site__r.Exam_Part__r);
            }
                  
            /*System.debug('mapCurrentPartOSTA:' + om.mapCurrentPartOSTA);
            System.debug('mapSelectedPartOSTA:' + om.mapSelectedPartOSTA);*/
                                                      
            return om;
        
    }
    
    static public OpportunityLineItem createOppLineItem(String oppId, prodLine pl, MAP<String, Product2> mapProdCode, MAP<String, PricebookEntry> mapPrice, String referenceId) {
        
        OpportunityLineItem oppLineItem = new OpportunityLineItem(); 
        
       /* System.Debug('oppId: ' + oppId);
        System.Debug('prodLine: ' + pl);
        System.Debug('mapProdCode: ' + mapProdCode);
        System.Debug('mapPrice: ' + mapPrice);
        System.Debug('referenceId: ' + referenceId);*/
        
        if(pl.prodCode != NULL) {
            
            Product2 fndProd = mapProdCode.get(pl.prodCode+':'+pl.glCode);
            if(fndProd != NULL) {
                PricebookEntry fndPrice = mapPrice.get(fndProd.Id);
                //system.debug('fndProd.Id=========>'+fndProd.Id);
                if(fndPrice != NULL) {
                    oppLineItem.Exam_Registration__c    = pl.examRegId;
                    oppLineItem.Exam_Site__c            = pl.examSiteId;
                    oppLineItem.Description             = pl.description; 
                    oppLineItem.UnitPrice               = pl.amount;
                    oppLineItem.OpportunityId           = oppId;
                    oppLineItem.PricebookEntryId        = fndPrice.Id;
                    oppLineItem.Quantity                = 1;
                    oppLineItem.Reference_Id__c         = referenceId;
                    
                   // System.Debug('insert oppLineItem: ' + oppLineItem);

                    insert oppLineItem;
                }
            }
            
        }
        
        return oppLineItem;
    }
    
    public static Opportunity createExamRescheduleOpp(Contact objContact, TempAccount objData, PricebookEntry mainProduct) {
        Opportunity opp = new Opportunity();
        
        
        //if(!test.isRunningTest()){ 
            
            // AG 5/3/2024 - Use GARP_BC classes
            GARP_BC_Registration.orderCustomerInfo customerInfo = new GARP_BC_Registration.orderCustomerInfo();
            customerInfo.FirstName = objContact.FirstName;
            customerInfo.LastName = objContact.LastName;
            customerInfo.Email = objContact.Email ;
            customerInfo.Phone = objContact.HomePhone;
            customerInfo.LeadId = NULL;
            customerInfo.ContactId = objContact.Id;
            customerInfo.AccountId = objContact.accountId;
            
            GARP_BC_Orders.orderPaymentInfo paymentInfo = new GARP_BC_Orders.orderPaymentInfo();
            paymentInfo.paymentType = 'Credit Card';
            paymentInfo.billingAddress = new GARP_Common.address();
            paymentInfo.billingAddress.country = objContact.Account.BillingCountry;
            paymentInfo.billingAddress.province = objContact.Account.BillingState;
            paymentInfo.billingAddress.postalCode = objContact.Account.BillingPostalCode;
            paymentInfo.billingAddress.phone = objContact.HomePhone;        
            paymentInfo.billingAddress.city = objContact.Account.BillingCity;    
            
            GARP_Common.address streets = GARP_Common.parseMultiAddressLine(objContact.Account.BillingStreet);
            paymentInfo.billingAddress.street1 = streets.street1;
            paymentInfo.billingAddress.street2 = streets.street2;
            paymentInfo.billingAddress.street2 = streets.street3;
            
            GARP_BC_Registration.membershipOptions membershipOptions = new GARP_BC_Registration.membershipOptions();
            membershipOptions.hasSelectedMembership = false;
            
            GARP_BC_Registration.checkAuthentication checkAuth = GARP_BC_Registration.checkAuthentication();
            
            List<GARP_BC_Orders.productInfo> productInfo = new List<GARP_BC_Orders.productInfo>();
            if(mainProduct != NULL) {
                GARP_BC_Orders.productInfo mainProductInfo = new GARP_BC_Orders.productInfo(mainProduct);
                mainProductInfo.isMainProduct = True;
                productInfo.add(mainProductInfo);
            }
            
            opp = GARP_BC_Orders.createOpportunity(checkAuth.user, objContact.accountId, customerInfo, paymentInfo, membershipOptions, productInfo, NULL);
            
            //opp = Registration.CreateOpportunity(objContact, objData);
        //}  
        
        return opp;
        
    }
    
    static public examRescheduleData createExamRescheduleFeesOrderInternal(String examRegId, String selectedAdminPartI, String selectedAdminPartII, String selectedSitePartI, String selectedSitePartII, Id userId, boolean freeDeferral, boolean calledFromMSTool, string subType, boolean doNotCountOneTimeDefrl) {

        /*system.debug('examRegId:' + examRegId);
        system.debug('selectedAdminPartI:' + selectedAdminPartI);
        system.debug('selectedAdminPartII' + selectedAdminPartII);
        system.debug('selectedSitePartI' + selectedSitePartI);
        system.debug('selectedSitePartII' + selectedSitePartII);*/

        
        examRescheduleData erd = getExamRescheduleFeesInternal(examRegId, selectedAdminPartI, selectedAdminPartII, selectedSitePartI, selectedSitePartII, userId, freeDeferral, calledFromMSTool);
        String program = erd.programType;
        
        //system.debug('fees:' + erd.fees);
        
        Decimal totalFees=0;
        for(prodLine pl :erd.fees) {
            if(pl.amount > 0) {
                totalFees=totalFees+pl.amount;    
            }
        }
        //system.debug('totalFees:' + totalFees);
        
        List<Product2> lstProducts = [select Id, Name, ProductCode, GL_Code__c, Description, Image__c from Product2 where IsActive = True];
        MAP<String, Product2> mapProdCode = new MAP<String, Product2>();
        for(Product2 p : lstProducts) {
            mapProdCode.put(p.ProductCode+':'+p.GL_Code__c, p);
        }
        
        // AG 5/3/2024 - New GARP_ classes - More fields needed
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id, Name, Product2.Taxable__c,Product2Id, ProductCode, Unitprice, Product2.Id, Product2.Product_ID__c, Product2.Family,
                                                  Product2.GL_Code__c, Product2.ProductCode, Product2.Name, Product2.Invoice_Name__c, Product2.Customer_Description__c,
                                                  Product2.Is_Shippable__c, Product2.Is_Comped_Registration__c, Product2.Do_Not_Charge_VAT__c, Product2.Is_VAT_Tax__c,Product2.Order_Summary_Product_Category__c,Product2.Do_Not_Charge_VAT_Countries__c,Product2.Alternate_Name__c,Product2.Stripe_Tax_Code__c
                                                  from PriceBookEntry where Pricebook2.Name = 'GARP 2015/2016' AND Product2Id in :lstProducts];
        
        MAP<String, PricebookEntry> mapPrice = new MAP<String, PricebookEntry>();
        MAP<String, PricebookEntry> mapPriceByCode = new MAP<String, PricebookEntry>();
        for(PricebookEntry pe : lstPriceBookEntry) {
            mapPrice.put(pe.Product2Id, pe);
            mapPriceByCode.put(pe.Product2.ProductCode + ':' + pe.Product2.GL_Code__c, pe);
        }
        
        if((erd.fees != NULL && erd.fees.size() > 0 && totalFees > 0) || freeDeferral) {
            TempAccount objData = new TempAccount();
            objData.siteId = selectedAdminPartI != NULL ? selectedAdminPartI : selectedAdminPartII;
            PricebookEntry fndProd;
            if(program == 'frm') {
                fndProd = mapPriceByCode.get('FRM1:4020');
            } else if(program == 'scr') {
                fndProd = mapPriceByCode.get('SCR:4020');
            } else if(program == 'riskai'){
                fndProd = mapPriceByCode.get('RAI:4020');                
            } else if(program == 'raij'){
                fndProd = mapPriceByCode.get('RAIJ:4020');                
            }
            
            erd.opp = createExamRescheduleOpp(erd.contact, objData, fndProd);
        }
       // System.debug('erd.opp:' + erd.opp);
        
        // AG 5/31/2024
        // New Logic for removal of Registration class and Use of GARP Checkout flow
        // >> Do not insert Opp or Create Trans / Close
        // Login for MS Tool
        // >> Create Opp
        
        if(calledFromMSTool == true){
            erd.ExamRegMod.Created_from_MS_Tool__c = true;
        }
        
        erd.ExamRegMod.Deferral_Subtype__c = subtype;
        erd.ExamRegMod.Free_Deferral__c = freeDeferral;
        erd.ExamRegMod.Not_Applicable_to_One_Time_Def__c = doNotCountOneTimeDefrl;
        insert erd.ExamRegMod;
        
        if((erd.fees != NULL && erd.fees.size() > 0 && totalFees > 0) || freeDeferral) {
            erd.opp.Exam_Registration_Modification__c = erd.ExamRegMod.Id;
            
            // Set Opp to Wire if CC not Allowed in these countries
            if(erd.contact.Account.BillingCountry != NULL && (erd.contact.Account.BillingCountry.toLowerCase() == 'ghana' || erd.contact.Account.BillingCountry.toLowerCase() == 'nigeria')) {
                erd.opp.Alternate_Method_of_Payment__c = 'wire'; 
            }
            
            Boolean partIMoved=False;
            Boolean partIIMoved=False;
            
            if(erd.currentAdminPartI != NULL && erd.selectedAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                partIMoved=True;
            }

            if(erd.currentAdminPartII != NULL && erd.selectedAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
                partIIMoved=True;
            }
            
           /* System.debug('***partIMoved:' + partIMoved);
            System.debug('***partIIMoved:' + partIIMoved);*/ 
            
            //system.assert(false, 'BOOM!3'+ partIMoved + ':' + partIIMoved );
            
            String examParts;
            if(program == 'frm') {
                if(partIMoved && partIIMoved) {
                    examParts = 'FRM Exam Part I & FRM Exam Part II';
                } else if(partIMoved) {
                    examParts = 'FRM Exam Part I';
                } else if(partIIMoved) {
                    examParts = 'FRM Exam Part II';
                }
            } else if(program == 'erp') {
                if(partIMoved && partIIMoved) {
                    examParts = 'ERP Exam Part I & ERP Exam Part II';
                } else if(partIMoved) {
                    examParts = 'ERP Exam Part I';
                } else if(partIIMoved) {
                    examParts = 'ERP Exam Part II';
                }                
            } else if(program == 'scr') {
                examParts = 'SCR';
            } else if(program == 'raij'){
                examParts = 'RAIJ';
            }else {
                examParts = 'RiskAI';
            }
            erd.opp.Exam_Emails__c = examParts;
            erd.opp.Deferral_SubType__c = subType;  
            
            String transType;
            if(partIMoved || partIIMoved){
                if(subType == 'Deferral Postponement'){
                    transType = 'Salesforce - Postponed';
                }else{
                    transType = 'Salesforce - Deferral';
                }
            }else{
                transType = 'Salesforce - Sales Invoice';
            }
            erd.opp.ia_crm__Intacct_Transaction__c = transType;
            
            if(!Test.isRunningTest()){
                // AG 5/6/2024 - No longer create opp, using checkout reg flow for portal
                // MS Tool create opp
                if(calledFromMSTool && erd.opp != NULL) {
                    INSERT erd.opp;
                } else {
                    
                    // Instead set properties to pass back
                    erd.examRegistrationModificationId = erd.ExamRegMod.Id;
                    erd.examEmailParts = examParts;
                    erd.deferralSubType = subType;
                    erd.transactionType = transType;
                    
                }
            }
            
            
            if(erd.fees != NULL) {
                erd.productLineItems = erd.fees;
                
                if(calledFromMSTool && erd.opp != NULL && erd.opp.Id != NULL) {
                    for(prodLine pl :erd.fees) {
                        if(pl.amount >= 0) {
                            createOppLineItem(erd.opp.Id, pl, mapProdCode, mapPrice, pl.referenceId);
                        }
                    }
                }
            }
            
            // If MS Tool, has no fees, and is a Free Deferal, close Order to process
            if(calledFromMSTool && freeDeferral && totalFees == 0){
                createTransaction(erd.opp.Id);
            }
        }
        
        return erd;        
    }
    
    static public examRescheduleData getExamRescheduleFeesInternal(String examRegId, String selectedAdminPartI, String selectedAdminPartII, String selectedSitePartI, String selectedSitePartII, Id userId, boolean freeDeferral, boolean calledFromMSTool) {
               
        // AG - Lets use examRegId instead of examGroupId now...this will give us context of the current Exam the user is in
        examRescheduleData erd = getExamRescheduleData(examRegId, selectedAdminPartI, selectedAdminPartII, selectedSitePartI, selectedSitePartII, userId);
        String program = erd.programType;
        
        //system.debug('get fees erd:' + erd);
        
        erd.errMsg = null;
        erd.statusCode = null;
        erd.errorCode = null;
        
        MAP<String,String> mapMonths = new MAP<String,String>();
        mapMonths.put('January','Jan');
        mapMonths.put('February','Feb');
        mapMonths.put('March','Mar');
        mapMonths.put('April','Apr');
        mapMonths.put('May','May');
        mapMonths.put('June','June');
        mapMonths.put('July','July');
        mapMonths.put('August','Aug');
        mapMonths.put('September','Sept');
        mapMonths.put('October','Oct');
        mapMonths.put('November','Nov');
        mapMonths.put('December','Dec');
        
        
        List<Product2> lstProducts = [select Id, Name, ProductCode, GL_Code__c, Description, Image__c, Do_Not_Charge_VAT__c from Product2 where IsActive = True];
        MAP<String, Product2> mapProdCode = new MAP<String, Product2>();
        for(Product2 p : lstProducts) {
            mapProdCode.put(p.ProductCode+':'+p.GL_Code__c, p);
        }
        
        List<PricebookEntry> lstPriceBookEntry = [SELECT Id, Name, Product2Id, ProductCode, Unitprice, Pricebook2.Name from PriceBookEntry where Product2Id in :lstProducts];
        
        MAP<String, PricebookEntry> mapPrice = new MAP<String, PricebookEntry>();
        for(PricebookEntry pe : lstPriceBookEntry) {
            if(Test.isRunningTest() || pe.Pricebook2.Name == 'GARP 2015/2016') {
                mapPrice.put(pe.Product2Id, pe);
            }
        }
        
        MAP<String,Exam_Part__c> mapExamPart = new MAP<String,Exam_Part__c>();
        for(Exam_Part__c ep : erd.examParts) {
            String key = ep.Exam_Part_Number__c + '~' + ep.Exam_Administration__c;
            mapExamPart.put(key, ep);
        }
       // system.debug('get mapExamPart:' + mapExamPart);
        
        // Validation Rules
        Date tdy = Date.today();
        DateTime now = DateTime.now();
        
        // AG Change for new deadlines  
        //if(erd.selectedAdminPartI != NULL && (tdy < erd.examRegPartI.Exam_Administration__r.Exam_Scheduling_Start_Date__c || tdy > erd.examRegPartI.Exam_Administration__r.Exam_Scheduling_End_Date__c)) {    
        //if(tdy > erd.examGroup.Last_Date_To_Request_Exam_Change__c || now < erd.examGroup.Exam_Change_Start_Date_Time__c) {           
        //if(erd.allowAdminModPartI == FALSE
        //        erd.errMsg = 'Exam changes are currently not available';
        //        erd.errorCode = 501;
        //}
                        
        Exam_Part__c fndSelPart1;
        if(erd.selectedAdminPartI != NULL) {
            fndSelPart1 = mapExamPart.get('1~' + erd.selectedAdminPartI.Id);
           // system.debug('get fndSelPart1:' + fndSelPart1);
        }
                
        Exam_Part__c fndSelPart2;
        if(erd.selectedAdminPartII != NULL) {
            fndSelPart2 = mapExamPart.get('2~' + erd.selectedAdminPartII.Id);
           // system.debug('get fndSelPart2:' + fndSelPart2);
        }
        
        // If Part I was moved
        // AG - 10/19/2022 - Exams 2023 
        // Any Move from Admin to new Admnin is now a deferral
        //if(erd.examRegPartI != NULL && erd.currentAdminPartI.Exam_Group__c != erd.selectedAdminPartI.Exam_Group__c && erd.currentSitePartI != NULL && erd.selectedSitePartI == NULL) {
        if(erd.examRegPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {            
            
            //system.debug('Part 1 moved');
            //system.assert(false, 'BOOM!3'+ program);
            
            if(erd.allowAdminModPartI == FALSE) {
                erd.errMsg = 'Exam changes are currently not available';
                erd.errorCode = 501;
            }
            
            // AG 10/19/2022 - Exam 2023
            // We now allow defer out and back
            //if(erd.examRegPartI.Defered__c == 'Pending') {
            //    erd.errMsg = 'You cannot defer Part I because it has already been deferred out into a future exam administration. You can only defer your exam registration once.';
            //    erd.errorCode = 502;
            //}
            if(erd.examRegPartI.Defered__c == 'Approved' && erd.examRegPartI.Allow_Future_Deferral__c == False &&
               (erd.examRegPartI.Deferred_From_Exam_Registration__c == NULL || erd.examRegPartI.Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c == False)
              ) {                
                erd.errMsg = 'You cannot defer Part I because it was deferred in from a previous exam administration. You can only defer your exam registration once.';
                erd.errorCode = 503;
            }
            
            //if(erd.otherProgramExamRegPartI != NULL && erd.otherProgramExamRegPartI.Defered__c == 'Pending') {
            //    erd.errMsg = 'Cannot defer Part I, another program was already deferred out';
            //    erd.errorCode = 504;
            //}
            
            if(erd.examRegPartI.Exam_Part__r.Delivery_Method__c == 'CBT' && erd.examRegPartI.Integration_Data_Exam_Scheduled_Date__c != NULL && (program.ToUpperCase() == 'SCR' || program.ToUpperCase() == 'RISKAI' || program.ToUpperCase() == 'RAIJ')) {
                erd.errMsg = 'To complete your Exam deferral, please go to Pearson and cancel your existing exam appointment. Then, return here to select to your new date.';
                erd.errorCode = 510;
            }
            
            if(fndSelPart1 != NULL) {
                DateTime p1dt = fndSelPart1.Exam_Date__c != NULL ? fndSelPart1.Exam_Date__c : fndSelPart1.Exam_Start_Date__c;    

                if(p1dt > erd.program.Last_Exam_Deferral_Date__c) {
                    erd.errMsg = 'Cannot defer Part I beyond the end of the '+ program.ToUpperCase()  +' Program';
                    erd.errorCode = 505;
                }            
            }
            
        }
        
        // If Part II was moved out
        if(erd.examRegPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
          
            //system.debug('Part 2 moved');
            
            if(erd.allowAdminModPartII == FALSE) {
                erd.errMsg = 'Exam changes are currently not available';
                erd.errorCode = 501;
            }
            
            // AG 10/19/2022 - Exam 2023
            // We now allow defer out and back
            //if(erd.examRegPartII.Defered__c == 'Pending') {
            //    erd.errMsg = 'Cannot defer Part II, it is already deferred out';
            //    erd.errorCode = 506;
            //}
            if(erd.examRegPartII.Defered__c == 'Approved' && erd.examRegPartII.Allow_Future_Deferral__c == False &&
               (erd.examRegPartII.Deferred_From_Exam_Registration__c == NULL || erd.examRegPartII.Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c == False)
              ) {
                erd.errMsg = 'Cannot defer Part II, it was deferred in from the last exam';
                erd.errorCode = 507;
            }

            //if(erd.otherProgramExamRegPartII != NULL && erd.otherProgramExamRegPartII.Defered__c == 'Pending') {
            //    erd.errMsg = 'Cannot defer Part II, another program was already deferred out';
            //    erd.errorCode = 508;
            //}

            Exam_Part__c fndPart2 = mapExamPart.get('2~' + erd.selectedAdminPartII.Id);
            //system.debug('get fndPart2:' + fndPart2);
            
            if(fndSelPart2 != NULL) {
                DateTime p1dt = fndSelPart2.Exam_Date__c != NULL ? fndSelPart2.Exam_Date__c : fndSelPart2.Exam_Start_Date__c;
                if(p1dt > erd.program.Last_Exam_Deferral_Date__c) {
                    erd.errMsg = 'Cannot defer Part II beyond the end of the '+ program.ToUpperCase()  +' Program';
                    erd.errorCode = 509;
                }            
            }
            
        }
        
        // If have Part I and II and move Part I must move both
        //if(erd.examRegPartI != NULL && erd.examRegPartII != NULL && 
        //   erd.currentAdminPartI != NULL && erd.selectedAdminPartI != NULL && erd.currentAdminPartI != erd.selectedAdminPartI &&
        //   erd.currentAdminPartII != NULL && erd.selectedAdminPartII != NULL && erd.currentAdminPartII == erd.selectedAdminPartII
        //  ) {
        //      erd.errMsg = 'Part I cannot be moved without Part II';
        //      erd.statusCode = 510;
        //  }
        
        // Cannot move Part II before Part I
        if(erd.examRegPartI != NULL && erd.examRegPartII != NULL && erd.selectedAdminPartI != NULL && erd.selectedAdminPartII != NULL &&
            fndSelPart1 != NULL && fndSelPart2 != NULL) {
            
            DateTime p1dt = fndSelPart1.Exam_Date__c != NULL ? fndSelPart1.Exam_Date__c : fndSelPart1.Exam_Start_Date__c;
            DateTime p2dt = fndSelPart2.Exam_Date__c != NULL ? fndSelPart2.Exam_Date__c : fndSelPart2.Exam_Start_Date__c;
                
            /*System.debug('p1dt:' + p1dt);
            System.debug('p2dt:' + p2dt);*/
            
            if(p2dt < p1dt) {
                erd.errMsg = 'Part II cannot be taken before Part I';
                erd.errorCode = 511;
            }
        }
        
        //if(erd.statusCode != NULL) {
        //    return erd;
        //}
        
        LIST<Contract> ostaPrograms = [
            SELECT Id, Name, Status, OSTA_Last_Upload_Date__c
            FROM Contract
            WHERE 
            AccountId = :erd.contact.AccountId AND
            RecordType.Name = 'OSTA Program' AND
            Status LIKE 'Activated%'
        ];
        
        // See if fees exist
        List<prodLine> lstProds = new List<prodLine>();
        
        // Admin Switch
        if((erd.currentAdminPartI != NULL && erd.selectedAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) ||
           (erd.currentAdminPartII != NULL && erd.selectedAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id)) {
               prodLine pc = new prodLine();
               
               if(program == 'frm') {
                   pc.prodCode = 'FRM1';
                   if(freeDeferral){
                       pc.amount = 0;
                   }else{
                       pc.amount = 250;
                   }
               } else if(program == 'erp') {
                   pc.prodCode = 'ENC';
                   if(freeDeferral){
                       pc.amount = 0;
                   }else{
                       pc.amount = 250;
                   }
               } else if(program == 'scr') {
                   pc.prodCode = 'SCR';
                   if(freeDeferral){
                       pc.amount = 0;
                   }else{
                       pc.amount = 150;
                   }
               } else {
                   pc.prodCode = 'RAI';
                   if(freeDeferral){
                       pc.amount = 0;
                   }else{
                       pc.amount = 150;
                   }
               }
               
               // Make description
               String descrtipion;
               if(program == 'frm' && erd.currentAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                   descrtipion = 'FRM Part I from ' + mapMonths.get(erd.currentAdminPartI.Month__c) + ' ' + erd.currentAdminPartI.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartI.Month__c) + ' ' + erd.selectedAdminPartI.Year__c;
                   if(erd.currentAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
                       descrtipion += ' and FRM Part II from ' + mapMonths.get(erd.currentAdminPartII.Month__c) + ' ' + erd.currentAdminPartII.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartII.Month__c) + ' ' + erd.selectedAdminPartII.Year__c;
                   }
               } else if(program == 'frm' && erd.currentAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
                   descrtipion = 'FRM Part II from ' + mapMonths.get(erd.currentAdminPartII.Month__c) + ' ' + erd.currentAdminPartII.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartII.Month__c) + ' ' + erd.selectedAdminPartII.Year__c;
               }
               
               if(program == 'erp' && erd.currentAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                   descrtipion = 'of ERP Part I from ' +mapMonths.get(erd.currentAdminPartI.Month__c) + ' ' + erd.currentAdminPartI.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartI.Month__c) + ' ' + erd.selectedAdminPartI.Year__c;
                   
                   if(erd.currentAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
                       descrtipion += ' and ERP Part II from ' + mapMonths.get(erd.currentAdminPartII.Month__c) + ' ' + erd.currentAdminPartII.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartII.Month__c) + ' ' + erd.selectedAdminPartII.Year__c;
                   }
               } else if(program == 'erp' && erd.currentAdminPartII != NULL && erd.currentAdminPartII.Id != erd.selectedAdminPartII.Id) {
                   descrtipion = 'ERP Part II from ' + mapMonths.get(erd.currentAdminPartII.Month__c) + ' ' + erd.currentAdminPartII.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartII.Month__c) + ' ' + erd.selectedAdminPartII.Year__c;
               }
               /*
               if(program == 'scr' && erd.currentAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                   descrtipion = 'SCR from ' + mapMonths.get(erd.currentAdminPartI.Month__c) + ' ' + erd.currentAdminPartI.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartI.Month__c) + ' ' + erd.selectedAdminPartI.Year__c;
               }
               
               if(program == 'riskai' && erd.currentAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                   descrtipion = 'Risk AI from ' + mapMonths.get(erd.currentAdminPartI.Month__c) + ' ' + erd.currentAdminPartI.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartI.Month__c) + ' ' + erd.selectedAdminPartI.Year__c;
               }
               if(program == 'raij' && erd.currentAdminPartI != NULL && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id) {
                   descrtipion = 'Risk and AI in Japanese ' + mapMonths.get(erd.currentAdminPartI.Month__c) + ' ' + erd.currentAdminPartI.Year__c + ' to ' + mapMonths.get(erd.selectedAdminPartI.Month__c) + ' ' + erd.selectedAdminPartI.Year__c;
               }  */  
               if(erd.currentAdminPartI != null && erd.selectedAdminPartI != null && erd.currentAdminPartI.Id != erd.selectedAdminPartI.Id){
                      
                      String p = program=='scr'?'SCR':
                      program=='riskai'?'Risk AI':
                      program=='raij'?'Risk and AI in Japanese':null;
                      
                      if(p!=null)
                          descrtipion = p+' from '+mapMonths.get(erd.currentAdminPartI.Month__c)+' '+erd.currentAdminPartI.Year__c+
                          ' to '+mapMonths.get(erd.selectedAdminPartI.Month__c)+' '+erd.selectedAdminPartI.Year__c;
                  }
               pc.glCode = '4020';
               pc.description = descrtipion;
               pc.examRegId = null;
               pc.examSiteId = selectedSitePartI != NULL ? selectedSitePartI : selectedSitePartII;            
               lstProds.add(pc);
               erd.statusCode = 200;
           }
        
        /*System.Debug('Admin Fee: ' + lstProds);
        
        system.debug('erd.currentSitePartI:' + erd.currentSitePartI);
        system.debug('erd.selectedSitePartI' + erd.selectedSitePartI);
        system.debug('erd.currentSitePartII' + erd.currentSitePartII);
        system.debug('erd.selectedSitePartII' + erd.selectedSitePartII);
        

        system.debug('erd.currentAdminPartI:' + erd.currentAdminPartI);
        system.debug('erd.selectedAdminPartI' + erd.selectedAdminPartI);
        system.debug('erd.currentAdminPartII' + erd.currentAdminPartII);
        system.debug('erd.selectedAdminPartII' + erd.selectedAdminPartII); */

        // Site Switch
        if((erd.currentSitePartI == NULL && erd.selectedSitePartI != NULL) ||
           (erd.currentSitePartI != NULL && erd.selectedSitePartI != NULL && erd.currentSitePartI.Id != erd.selectedSitePartI.Id) ||
           (erd.currentSitePartII != NULL && erd.selectedSitePartII != NULL && erd.currentSitePartII.Id != erd.selectedSitePartII.Id)) {
               
               erd.statusCode = 200; // Changes found but no fees or refunds
           }
        
        
        // Get OSTA Fees
        if(program == 'frm') {
            
            Decimal ostaLocationFee = 40;
            Product2 fndProd = mapProdCode.get('CHLF:2008');
            if(fndProd != NULL) {
                PricebookEntry fndPrice = mapPrice.get(fndProd.Id);
                if(fndPrice != NULL) {
                    ostaLocationFee = fndPrice.Unitprice;
                }
            }
            
            Decimal ostaDataFee = 10;
            fndProd = mapProdCode.get('CHNDF:2009');
            if(fndProd != NULL) {
                PricebookEntry fndPrice = mapPrice.get(fndProd.Id);
                if(fndPrice != NULL) {
                    ostaDataFee = fndPrice.Unitprice;
                }
            }        
            
            // OSTA Fees
            // Setup Admin OSTA Data
            ostaMaps om = computeOSTAProgramMoves(erd.examRegPartI, erd.examRegPartII, erd.currentSitePartI, erd.currentSitePartII, erd.currentAdminPartI, erd.currentAdminPartII, 
                                                  erd.selectedSitePartI, erd.selectedSitePartII, erd.selectedAdminPartI, erd.selectedAdminPartII);


            Decimal totalFee = 0;
            Integer totalCurrentPartWithOSTA = om.mapCurrentPartOSTA.size();
            Integer totalSelectedPartWithOSTA = om.mapSelectedPartOSTA.size();
            
            // Net fee is diff between current distinct admins with OSTA v. selected distinct Admins with OSTA
            totalFee = totalFee + (ostaLocationFee * (totalSelectedPartWithOSTA - totalCurrentPartWithOSTA));
            
            // Find Exam Reg to relate to Fee
            Set<Decimal> partsInvolved = new Set<Decimal>();
            Exam_Attempt__c eaFee;
            for(String selkey :om.mapSelectedPartOSTA.keySet()) {
                
                Exam_Part__c curVal = om.mapCurrentPartOSTA.get(selkey);
                Exam_Part__c selVal = om.mapSelectedPartOSTA.get(selkey);
                
                /*System.debug('curVal:' + curVal);
                System.debug('selVal:' + selVal);*/
                
                if(selVal != NULL && curVal == NULL) {
                    partsInvolved.add(selVal.Exam_Part_Number__c);
                }
            }
            //System.debug('partsInvolved:' + partsInvolved);
            //erd.errMsg = 'Parts Involved:' + partsInvolved;
            if(partsInvolved.contains(1)) {
                eaFee = erd.examRegPartI;
            } else if(partsInvolved.contains(2)) {
                eaFee = erd.examRegPartII;
            }
            
            //System.debug('totalFee:' + totalFee);
            
            // Find Opp Line Items Exam Part Accounting IDs
            String part1AccountingId;
            String part2AccountingId;
            
            // If any fees add them
            if(totalFee > 0) {        
                                
                Set<String> oppIds = new Set<String>();
                String oppPart1Id;
                String oppPart2Id;
                if(partsInvolved.contains(1)) {
                    oppIds.add(erd.examRegPartI.Opportunity__c);
                    oppPart1Id = erd.examRegPartI.Opportunity__c;
                }
                if(partsInvolved.contains(2)) {
                    oppIds.add(erd.examRegPartII.Opportunity__c);
                    oppPart2Id = erd.examRegPartII.Opportunity__c;
                }
                
               /* System.debug('oppIds:' + oppIds);
                System.debug('oppPart1Id:' + oppPart1Id);
                System.debug('oppPart2Id:' + oppPart2Id);*/
                
                List<OpportunityLineItem> lstOppLineItems = [SELECT Id, OpportunityId, Product_ID__c, Product2.ProductCode FROM OpportunityLineItem where OpportunityId in :oppIds];
                //System.debug('lstOppLineItems:' + lstOppLineItems);
                
                if(!lstOppLineItems.IsEmpty()) {
                    for(OpportunityLineItem li :lstOppLineItems) {
                        //System.debug('Loop Opp Lines:' + li);
                        
                        if((li.Product2.ProductCode == 'FRM1E' || li.Product2.ProductCode == 'FRM1S') && li.OpportunityId == oppPart1Id)  {
                            part1AccountingId = li.Product_ID__c;
                        }
                        if((li.Product2.ProductCode == 'FRM2E' || li.Product2.ProductCode == 'FRM2S') && li.OpportunityId == oppPart2Id)  {
                            part2AccountingId = li.Product_ID__c;
                        }
                    }
                }
                /*System.debug('part1AccountingId:' + part1AccountingId);
                System.debug('part2AccountingId:' + part2AccountingId);*/
                
                if(partsInvolved.size() > 0) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHLF';
                    //pc.examRegId = erd.examRegPartI != NULL ? erd.examRegPartI.Id : erd.examRegPartII.Id;
                    //pc.examSiteId = erd.selectedSitePartI != NULL ? erd.selectedSitePartI.Id : erd.selectedSitePartII.Id;
                    pc.glCode = '2008';
                    pc.description = 'OSTA Location Fee';
                    pc.amount = ostaLocationFee;
                    pc.examRegId = eaFee.Id;
                    pc.referenceId = (part1AccountingId != NULL) ? part1AccountingId : part2AccountingId;
                    lstProds.add(pc);                    
                }
                
                if(partsInvolved.size() > 1) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHLF';
                    //pc.examRegId = erd.examRegPartI != NULL ? erd.examRegPartI.Id : erd.examRegPartII.Id;
                    //pc.examSiteId = erd.selectedSitePartI != NULL ? erd.selectedSitePartI.Id : erd.selectedSitePartII.Id;
                    pc.glCode = '2008';
                    pc.description = 'OSTA Location Fee';
                    pc.amount = ostaLocationFee;
                    pc.examRegId = eaFee.Id;
                    pc.referenceId = part2AccountingId;
                    lstProds.add(pc);                    
                }
                //System.debug('lstProds:' + lstProds);
                
                erd.statusCode = 200;
            }
            
            // If have any OSTA Admins
            if(totalSelectedPartWithOSTA > 0) {
                // If no OSTA program exists charge to put them into it
                if(ostaPrograms == NULL || ostaPrograms.size() == 0) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHNDF';
                    //pc.examRegId = erd.examRegPartI != NULL ? erd.examRegPartI.Id : erd.examRegPartII.Id;
                    //pc.examSiteId = erd.selectedSitePartI != NULL ? erd.selectedSitePartI.Id : erd.selectedSitePartII.Id;
                    pc.glCode = '2009';
                    pc.description = 'OSTA Data Fee';
                    pc.amount = ostaDataFee;
                    pc.referenceId = (part1AccountingId != NULL) ? part1AccountingId : part2AccountingId;
                    lstProds.add(pc);
                }
            }
            
            //System.Debug('OSTA Fee In: ' + lstProds);

            // If any Refunds add them
            // Find Exam Reg to relate to Fee
            partsInvolved = new Set<Decimal>();
            eaFee=NULL;
            for(String curkey :om.mapCurrentPartOSTA.keySet()) {
                
                Exam_Part__c curVal = om.mapCurrentPartOSTA.get(curkey);
                Exam_Part__c selVal = om.mapSelectedPartOSTA.get(curkey);
                
               /* System.debug('curVal:' + curVal);
                System.debug('selVal:' + selVal);*/
                
                if(selVal == NULL && curVal != NULL) {
                    if(curVal.Exam_Part_Number__c != NULL) {
                        partsInvolved.add(curVal.Exam_Part_Number__c);    
                    }
                }
            }
           // System.debug('partsInvolved:' + partsInvolved);
            //erd.errMsg += 'Parts Involved refund:' + partsInvolved;
            if(partsInvolved.contains(1)) {
                eaFee = erd.examRegPartI;
            } else if(partsInvolved.contains(2)) {
                eaFee = erd.examRegPartII;
            }
            
            //if(totalRefund < 0) {        
            if(totalFee < 0) {
                if(partsInvolved.size() > 0) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHLF';
                    pc.glCode = '2008';
                    pc.description = 'OSTA Location fee Refund';
                    pc.amount = ostaLocationFee * -1;
                    pc.examRegId = eaFee.Id;
                    lstProds.add(pc);
                }
                if(partsInvolved.size() > 1) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHLF';
                    pc.glCode = '2008';
                    pc.description = 'OSTA Location fee Refund';
                    pc.amount = ostaLocationFee * -1;
                    pc.examRegId = eaFee.Id;
                    lstProds.add(pc);
                }
                erd.statusCode = 200;
            }
            
            // If no Part with OSTA left        
            if(totalSelectedPartWithOSTA == 0) {
                
                // If have OSTA Program but never uploaded data then refund
                if(ostaPrograms != NULL && ostaPrograms.size() > 0 && ostaPrograms[0].OSTA_Last_Upload_Date__c == NULL) {
                    prodLine pc = new prodLine();
                    pc.prodCode = 'CHNDF';
                    pc.glCode = '2008';
                    pc.description = 'OSTA Data fee Refund';
                    pc.amount = ostaDataFee * -1;
                    lstProds.add(pc);
                    erd.statusCode = 200;
                }
                
            }
            //System.Debug('OSTA Fee Out: ' + lstProds);
        }
         /*  #00888059 - Stop India GST on Deferral Invoices in Member Services Tool
        // VAT Tax
        // AG 5/29/2024 - Remove VAT Calc, leave to GARP_BC_Registration to calc all other fees
        if(calledFromMSTool) {
            List<Country_Code__c> countryCodes = [select Id, Country__c, VAT__c, VAT_Product_Code__c 
                                                  from Country_Code__c where VAT__c != NULL];
            MAP<String, Country_Code__c> mapCC = new MAP<String, Country_Code__c>();
            for(Country_Code__c cc :countryCodes) {
                mapCC.put(cc.Country__c, cc);
            }
           // System.debug('Add VAT mapCC:' + mapCC);
            
            List<User> lstUser = [Select Id, ContactId, Email, Contact.MailingCountry, AccountId, Account.BillingCountry from User where Id = :userId];
            //System.debug('Add VAT lstUser:' + lstUser);
            
            if(lstUser != NULL && lstUser.size() > 0) {
                User usr = lstUser[0];
                Decimal taxableSubtotal = 0;
                for(prodLine prod :lstProds) {
                   // System.debug('Add VAT prod:' + prod);
                    Product2 fndProd = mapProdCode.get(prod.prodCode+':'+prod.glCode);
                    //System.debug('Add VAT fndProd:' + fndProd);
                    if(fndProd != NULL && fndProd.Do_Not_Charge_VAT__c != NULL && !fndProd.Do_Not_Charge_VAT__c) {
                        taxableSubtotal+=prod.amount; 
                        //System.debug('Add VAT taxableSubtotal:' + taxableSubtotal);                    
                    }
                }
                
                Integer matchCount=0;
                Decimal vatAmt = 0;
                String vatProductCode;
                
                if(usr.Account.BillingCountry != NULL) {
                    //System.debug('Add VAT BillingCountry:' + usr.Account.BillingCountry);
                    Country_Code__c fndCC = mapCC.get(usr.Account.BillingCountry);
                    if(fndCC != NULL) {
                        matchCount++;
                        vatAmt = fndCC.VAT__c;
                        vatProductCode = fndCC.VAT_Product_Code__c;
                    }
                }
                if(usr.Contact.MailingCountry != NULL) {
                    //System.debug('Add VAT MailingCountry:' + usr.Contact.MailingCountry);
                    Country_Code__c fndCC = mapCC.get(usr.Contact.MailingCountry);
                    if(fndCC != NULL) {
                        matchCount++;
                        vatAmt = fndCC.VAT__c;
                        vatProductCode = fndCC.VAT_Product_Code__c;                    
                    }
                } 
                if(erd.selectedSitePartI != NULL && erd.selectedSitePartI.Site__r.Is_VAT__c) {
                    matchCount++;
                } else if(erd.currentSitePartI != NULL && erd.currentSitePartI.Site__r.Is_VAT__c) {
                    matchCount++;
                } else if(erd.selectedSitePartI != NULL && erd.selectedSitePartI.Site__r.Is_VAT__c) {
                    matchCount++;
                } else if(erd.selectedSitePartII != NULL && erd.selectedSitePartII.Site__r.Is_VAT__c) {
                    matchCount++;
                }
                //System.debug('Add VAT matchCount site:' + matchCount);
                
                if(matchCount > 1) {
                    Product2 fndProd = mapProdCode.get(vatProductCode+':2819');
                    //System.debug('Add VAT fndProd:' + fndProd);
                    
                    if(fndProd != NULL) {                        
                        prodLine pc = new prodLine();
                        pc.prodCode = fndProd.ProductCode;
                        pc.glCode = fndProd.GL_Code__c;
                        pc.description = fndProd.Description;
                        pc.amount = taxableSubtotal * (vatAmt * .01);
                        lstProds.add(pc);
                       // System.debug('Add VAT pc:' + pc);
                    }
                }
            }
        } */
        
        erd.fees = lstProds;
        
        return erd;
    }
                
    static public examRescheduleData getExamRescheduleData(String examRegId, Id selectedAdminPartI, Id selectedAdminPartII, Id selectedSitePartI, Id selectedSitePartII, Id userId) {
        
        String program;
        String examGroupId;
        
        examRescheduleData erd = new examRescheduleData();
        
        //system.debug('GET examGroupId:' + examGroupId);
        /*system.debug('GET selectedAdminPartI:' + selectedAdminPartI);
        system.debug('GET selectedAdminPartII' + selectedAdminPartII);
        system.debug('GET selectedSitePartI' + selectedSitePartI);
        system.debug('GET selectedSitePartII' + selectedSitePartII);*/
        
        erd.allowSchedulingPartI = FALSE;   
        erd.allowAdminModPartI = FALSE; 
        erd.allowSchedulingPartII = FALSE;  
        erd.allowAdminModPartII = FALSE;
        erd.selectedAdminPartI = new Exam_Administration__c();
        erd.selectedAdminPartII = new Exam_Administration__c();
        erd.ExamRegMod = new Exam_Registration_Modification__c();
        
        Set<String> examPartNames;
        Set<String> otherExamPartNames;
        Set<String> examAdminTypeNames;
        
        // Get Context from examRegId
        List<Exam_Attempt__c> examRegs = [select Id, Exam_Administration__c, Exam_Administration__r.Exam_Group__c, 
                                          Exam_Administration__r.Exam_Type__c,
                                          Deferred_Exam_Administration__c,
                                          Original_Exam_Administration__c,Original_Exam_Administration__r.Exam_Group__c
                                          from Exam_Attempt__c where Id = :examRegId];
        if(examRegs.isEmpty()) {
            return erd;
        }
        
        Exam_Attempt__c examReg = examRegs[0];
        program = erd.programType = examReg.Exam_Administration__r.Exam_Type__c.toLowerCase();
        examGroupId = examReg.Exam_Administration__r.Exam_Group__c;
        
        if(program == 'frm') {
            examPartNames = new Set<String>{'FRM Part 1', 'FRM Part 2'};
            otherExamPartNames = new Set<String>{'ERP Exam Part I', 'ERP Exam Part II'};
            examAdminTypeNames = new Set<String>{'FRM','FRM/ERP'};
        } else if(program == 'erp') {
            examPartNames = new Set<String>{'ERP Exam Part I', 'ERP Exam Part II'};
            otherExamPartNames = new Set<String>{'FRM Part 1', 'FRM Part 2'};
            examAdminTypeNames = new Set<String>{'ERP','FRM/ERP'};
        } else if(program == 'scr') {
            examPartNames = new Set<String>{'SCR'};
            examAdminTypeNames = new Set<String>{'SCR'};
        } else if(program == 'raij') {
            examPartNames = new Set<String>{'RAIJ'};
            examAdminTypeNames = new Set<String>{'RAIJ'};
        }else {
            examPartNames = new Set<String>{'RiskAI'};
            examAdminTypeNames = new Set<String>{'RiskAI'};
        }
            
        /*system.debug('examPartNames:' + examPartNames);
        system.debug('examAdminTypeNames:' + examAdminTypeNames); */

        //String userId = UserInfo.getUserId();        
        List<User> lstUser = [Select u.Id,u.ContactId, FullPhotoUrl from User u where u.Id = :userId];
        if( lstUser != null && lstUser.size() > 0 ) {   
            List<Contact> lstCont ;
            if(test.isRunningTest() && userId == NULL) {
              
                lstCont = [Select Id, Name, AccountId,
                                         Email, FirstName, LastName, HomePhone,
                                         Company__c, Account.BillingStreet,
                                         Account.BillingCity,
                                         Account.BillingState,
                                         Account.BillingPostalCode,
                                         Account.BillingCountry
                                         from Contact ];  
                } else {
                lstCont = [Select Id, Name, AccountId,
                                         Email, FirstName, LastName, HomePhone,
                                         Company__c, Account.BillingStreet,
                                         Account.BillingCity,
                                         Account.BillingState,
                                         Account.BillingPostalCode,
                                         Account.BillingCountry
                                         from Contact where Id = :lstUser[0].ContactId];
                }
            if(lstCont != NULL && lstCont.size() > 0) {
                erd.contact = lstCont[0];
            }
            
            String recordTypeName = program.toUpperCase() + ' Program';
            if(program == 'riskai') {
                recordTypeName = 'Risk AI Program';
            }
            LIST<Contract> programs = [
                SELECT Id, Name, Status, RecordType.Name, AccountId,
                Last_Exam_Deferral_Date__c
                FROM Contract
                WHERE 
                AccountId = :erd.contact.AccountId AND
                RecordType.Name = :recordTypeName AND
                (Status LIKE 'Activated%' OR Status = 'Lapsed' OR Status = 'Completed')
            ];
            //System.debug('programs:' + programs);            
            if(programs != NULL && programs.size() > 0) {
                erd.program = programs[0];
            }
        }
        
        
        List<ID> lstExamGroupIDs = new List<ID>();
        lstExamGroupIDs.add(examGroupId);
        //erd.examGroupID = examGroupId;
        
        List<Exam_Group__c> lstExamGroup = [select Id, Name, Next_Exam_Group__c,
                                            Exam_Date__c,
                                            //Last_Date_To_Apply_For_Deferral__c,
                                            //Registration_Start_Date__c, 
                                            //Last_Date_To_Request_Exam_Change__c, 
                                            //Exam_Change_Start_Date_Time__c,
                                            Next_Exam_Group__r.Exam_Date__c
                                            //Next_Exam_Group__r.Registration_Start_Date__c, 
                                            //Next_Exam_Group__r.Last_Date_To_Request_Exam_Change__c 
                                            from Exam_Group__c where ID = :examGroupId];        
        if(lstExamGroup != NULL && lstExamGroup.size() > 0) {
            erd.examGroup = lstExamGroup[0];
            if(lstExamGroup[0].Next_Exam_Group__c != NULL) {
                lstExamGroupIDs.add(lstExamGroup[0].Next_Exam_Group__c);                
                erd.nextExamGroup = lstExamGroup[0].Next_Exam_Group__r;
            }
            
            // AG modify for Deadlines  
            //Date tdy = Date.today();  
            //DateTime now = DateTime.now();    
            //if(now >= erd.examGroup.Exam_Change_Start_Date_Time__c && tdy <= erd.examGroup.Last_Date_To_Request_Exam_Change__c) { 
            //    erd.allowSetup = TRUE;    
            //} 
            //if(now >= erd.examGroup.Exam_Change_Start_Date_Time__c && tdy <= erd.examGroup.Last_Date_To_Apply_For_Deferral__c) {  
            //     erd.allowDeferral = TRUE;    
            //}             
        }
        
       /* system.debug('GET lstExamGroup:' + lstExamGroup);
        system.debug('GET lstExamGroupIDs:' + lstExamGroupIDs);*/
        
        
        erd.examAdmins = [select Id, Name, Exam_Group__c, Exam_Type__c, Month__c, Year__c,
                          Registration_Start_Date__c, Registration_End_Date__c,
                          Exam_Admin_Modifications_Start_Date__c, Exam_Admin_Modifications_End_Date__c,
                          Exam_Scheduling_Start_Date__c, Exam_Scheduling_End_Date__c, Contingency_Administration__c,
                          Is_Scheduling_Open__c, Is_Modification_Open__c
                          from Exam_Administration__c 
                          where Exam_Group__c in :lstExamGroupIDs AND
                                Exam_Type__c in :examAdminTypeNames AND
                                (Registration_End_Date__c >= TODAY OR Id = :examReg.Exam_Administration__c) AND
                                (Contingency_Administration__c = False OR Id = :examReg.Exam_Administration__c)
                          ORDER BY Registration_Start_Date__c limit 3];

        
        //system.debug('GET erd.examAdmins:' + erd.examAdmins);
        
        MAP<String, Exam_Administration__c> mapAdmin = new MAP<String, Exam_Administration__c>();
        Set<String> examAdminWithSchedulingOpen = new Set<String>();
        
        //if(selectedAdminPartI != NULL || selectedAdminPartII != NULL) {
            for(Exam_Administration__c ea :erd.examAdmins) {

                mapAdmin.put(ea.Id, ea);

                if(ea.Id == selectedAdminPartI) {
                    erd.selectedAdminPartI = ea;
                }
                if(ea.Id == selectedAdminPartII) {
                    erd.selectedAdminPartII = ea;
                }
                
                if(ea.Is_Scheduling_Open__c) {
                    examAdminWithSchedulingOpen.add(ea.Id);
                }
            }
        //}
        
        erd.examParts = [select Id, Name, Exam__c, Exam_Administration__c, Delivery_Method__c, Exam_Part_Number__c,
                                Exam_Date__c, Exam_Start_Date__c, Exam_End_Date__c
                         from 
                         Exam_Part__c where 
                         Exam_Administration__c in :erd.examAdmins AND Exam__r.Exam__c in :examPartNames];
        MAP<String,Exam_Part__c> mapPartByAdmin = new MAP<String,Exam_Part__c>();
        if(!erd.examParts.IsEmpty()) {
            for(Exam_Part__c ep :erd.examParts) {
                mapPartByAdmin.put(ep.Exam_Administration__c+':'+ep.Exam_Part_Number__c,ep);
            }
        }
        System.Debug('mapPartByAdmin:' + mapPartByAdmin);
        
        List<Exam_Attempt__c> lstExamReg = [
            SELECT 
            Id, Exam_Site__c, Defered__c, Member_Email__c,
            Deferral_Status__c, 
            Exam_Administration__c,
            Opportunity__c,
            Original_Exam_Administration__c,
            Deferred_Exam_Administration__c,
            Exam_Administration__r.Exam_Scheduling_Start_Date__c,   
            Exam_Administration__r.Exam_Scheduling_End_Date__c, 
            Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,  
            Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
            Original_Exam_Administration__r.Exam_Scheduling_Start_Date__c,
            Original_Exam_Administration__r.Exam_Scheduling_End_Date__c,
            Original_Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
            Original_Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
            Deferred_From_Exam_Registration__c, 
            Deferred_From_Exam_Registration__r.Exam_Administration__c,
            Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Scheduling_Open__c,
            Deferred_From_Exam_Registration__r.Exam_Administration__r.Is_Modification_Open__c,
            RPT_Exam_Part__c,            
            Active_Integration_Data__c,
            Integration_Data_Exam_Scheduled_Date__c,
            Free_Deferral__c,
            Allow_Future_Deferral__c,
            ATA_Name_as_it_appears_on_ID__c,
            Exam_Part__c,
            Exam_Part__r.Exam_Administration__c,
            Exam_Part__r.Exam__r.Exam__c,
            Exam_Part__r.Exam_Part_Number__c,
            Exam_Part__r.Delivery_Method__c,
            Exam_Site__r.Name,
            Exam_Site__r.Country__c,
            Exam_Site__r.Exam_Part__c,
            Exam_Site__r.Exam_Part__r.Exam_Administration__c,
            Exam_Site__r.Exam_Part__r.Exam__r.Exam__c,
            Exam_Site__r.Exam_Part__r.Exam_Part_Number__c,
            Exam_Site__r.Exam_Part__r.Delivery_Method__c,
            Exam_Site__r.Exam_Provider__r.Name,
            Exam_Site__r.Exam__c, 
            Exam_Site__r.Exam__r.Exam__c, 
            Exam_Site__r.Exam__r.Exam_Group__c,
            Exam_Site__r.Site__c, 
            Exam_Site__r.Site__r.Name, 
            Exam_Site__r.Site__r.Is_OSTA_Information_Required__c, 
            Exam_Site__r.Site__r.Is_VAT__c, 
            Exam_Site__r.Site__r.Is_Gender_Required__c, 
            Exam_Site__r.Site__r.AM_Exam_Capacity_Available__c, 
            Exam_Site__r.Site__r.PM_Exam_Capacity_Available__c 
            FROM 
            Exam_Attempt__c 
            WHERE 
            Exam_Part__c in :erd.examParts AND
            Cancelled__c != TRUE AND
            Opportunity__r.StageName = 'Closed' AND
            Member__c = :erd.contact.Id AND
            Result__c = null
            //Exam_Site__r.Exam__r.Exam_Group__c = :examGroupId
        ]; 
        //system.debug('GET lstExamReg:' + lstExamReg);
        
        for(Exam_Attempt__c ea :lstExamReg) {
            
            //system.debug('for ea:' + ea);
            
            if(ea.RPT_Exam_Part__c == 'I' || ea.RPT_Exam_Part__c == 'Full') {
                erd.examRegPartI = ea;
                
                if(ea.Deferred_Exam_Administration__c == NULL) { 
                    erd.currentAdminPartI = mapAdmin.get(ea.Exam_Administration__c);    
                    erd.originalAdminPartI = mapAdmin.get(ea.Exam_Administration__c);
                    erd.currentSitePartI = ea.Exam_Site__r;
                    erd.originalSitePartI = ea.Exam_Site__r;
                } else {
                    erd.originalAdminPartI = mapAdmin.get(ea.Exam_Administration__c);
                    erd.currentAdminPartI = mapAdmin.get(ea.Deferred_Exam_Administration__c);   
                    erd.currentSitePartI = NULL;
                    erd.originalSitePartI = ea.Exam_Site__r;
                }
                
               // system.debug('erd part 1:' + erd);
                
            } else if(ea.RPT_Exam_Part__c == 'II') {
                erd.examRegPartII = ea;
                if(ea.Deferred_Exam_Administration__c == NULL) { 
                    erd.currentAdminPartII = mapAdmin.get(ea.Exam_Administration__c);    
                    erd.originalAdminPartII = mapAdmin.get(ea.Exam_Administration__c);
                    erd.currentSitePartII = ea.Exam_Site__r;
                    erd.originalSitePartII = ea.Exam_Site__r;
                } else {
                    erd.originalAdminPartII = mapAdmin.get(ea.Exam_Administration__c);
                    erd.currentAdminPartII = mapAdmin.get(ea.Deferred_Exam_Administration__c);   
                    erd.currentSitePartII = NULL;
                    erd.originalSitePartII = ea.Exam_Site__r;
                }

                system.debug('erd part 2:' + erd);
            }
        }
        
        /*System.debug('erd.examRegPartI:' + erd.examRegPartI);
        System.debug('erd.examRegPartII:' + erd.examRegPartII);
        
        System.debug('erd.currentSitePartI:' + erd.currentSitePartI);
        System.debug('erd.currentSitePartII:' + erd.currentSitePartII);
        System.debug('erd.currentAdminPartI:' + erd.currentAdminPartI);
        System.debug('erd.currentAdminPartII:' + erd.currentAdminPartII);*/

        List<String> currentSiteIds = new List<String>();
        if(erd.currentSitePartI != NULL) {
            currentSiteIds.add(erd.currentSitePartI.id);
        }
        if(erd.currentSitePartII != NULL) {
            currentSiteIds.add(erd.currentSitePartII.id);
        }
        
        List<String> currentAdminIds = new List<String>();
        if(erd.originalAdminPartI != null) {
            currentAdminIds.add(erd.originalAdminPartI.Id);
        }
        if(erd.originalAdminPartII != null) {
            currentAdminIds.add(erd.originalAdminPartII.Id);
        }
        
        erd.examSites = [               
            SELECT 
            Id, 
            Name,
            Country__c,
            Exam_Part__c,
            Exam_Part__r.Exam_Administration__c, 
            Exam_Part__r.Exam__r.Exam__c,
            Exam_Part__r.Exam_Part_Number__c,
            Exam_Part__r.Delivery_Method__c,
            Exam_Provider__c,
            Exam_Provider__r.Name,
            Exam__c, 
            Exam__r.Exam__c, 
            Exam__r.Exam_Group__c, 
            Site__c, 
            Site__r.Name, 
            Site__r.Is_OSTA_Information_Required__c, 
            Site__r.Is_VAT__c, 
            Site__r.Is_Gender_Required__c, 
            Site__r.AM_Exam_Capacity_Available__c, 
            Site__r.PM_Exam_Capacity_Available__c 
            FROM Exam_Sites__c
            WHERE 
            (Exam_Part__r.Exam_Administration__c in :examAdminWithSchedulingOpen OR Exam_Part__r.Exam_Administration__c in :currentAdminIds)AND
            (Site__r.Active__c = TRUE OR id in :currentSiteIds) AND 
            Site__r.Active__c = TRUE AND 
            Site__r.Non_Selectable__c = FALSE AND 
            Site__r.Name != 'SCR'
            //Exam_Part__r.Exam__r.Exam__c IN :examPartNames AND
            //Exam_Part__c in :erd.examParts AND
            ORDER BY Site__r.Name ASC 
        ];
                    
        //system.debug('GET erd.examSites:' + erd.examSites);
        
        if(selectedSitePartI != NULL || selectedSitePartII != NULL) {
            
            for(Exam_Sites__c es :erd.examSites) {
            
                //System.Debug('es.Id: ' + es.Id);
            
                if(es.Id == selectedSitePartI) {
                    erd.selectedSitePartI = es;
                }
                if(es.Id == selectedSitePartII) {
                    erd.selectedSitePartII = es;
                }
            }
        }
                
        erd.ExamRegMod.User__c = lstUser[0].Id;
        
        Date tdy = Date.today();    
        DateTime now = DateTime.now();  

        
        if(erd.examRegPartI != NULL) {  
            erd.ExamRegMod.Part_I_Exam_Registration__c = erd.examRegPartI.Id;   
            
            if(tdy >= erd.examRegPartI.Exam_Administration__r.Exam_Scheduling_Start_Date__c &&  
               tdy <= erd.examRegPartI.Exam_Administration__r.Exam_Scheduling_End_Date__c)  
                erd.allowSchedulingPartI = TRUE;    
            
            if(tdy >= erd.examRegPartI.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c && 
               tdy <= erd.examRegPartI.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c)             
                erd.allowAdminModPartI = TRUE;  
        }
        
        if(erd.examRegPartII != NULL) { 
            erd.ExamRegMod.Part_II_Exam_Registration__c = erd.examRegPartII.Id; 
                            
            if(tdy >= erd.examRegPartII.Exam_Administration__r.Exam_Scheduling_Start_Date__c && 
               tdy <= erd.examRegPartII.Exam_Administration__r.Exam_Scheduling_End_Date__c) 
                erd.allowSchedulingPartII = TRUE;   
            
            if(tdy >= erd.examRegPartII.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c &&    
               tdy <= erd.examRegPartII.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c)                
                erd.allowAdminModPartII = TRUE; 
                
        }
        
        
        if(erd.currentAdminPartI != NULL)
            erd.ExamRegMod.Part_I_Exam_Admin_From__c = erd.currentAdminPartI.Id;
        
        if(erd.selectedAdminPartI != NULL)
            erd.ExamRegMod.Part_I_Exam_Admin_To__c = erd.selectedAdminPartI.Id;
        
        if(erd.currentAdminPartII != NULL)
            erd.ExamRegMod.Part_II_Exam_Admin_From__c = erd.currentAdminPartII.Id;
        
        if(erd.selectedAdminPartII != NULL)
            erd.ExamRegMod.Part_II_Exam_Admin_To__c = erd.selectedAdminPartII.Id;

        if(erd.currentSitePartI != NULL) {
            erd.ExamRegMod.Part_I_Exam_Site_From__c = erd.currentSitePartI.Id;
            erd.ExamRegMod.Part_I_Exam_Group_From__c = erd.currentSitePartI.Exam__r.Exam_Group__c;
            erd.ExamRegMod.Part_I_Exam_Part_From__c = erd.currentSitePartI.Exam_Part__c;
        } else if(erd.currentAdminPartI != NULL) {
            // AG 2/15/2023 -- Add Part Event if site not selected
            Exam_Part__c fndPart = mapPartByAdmin.get(erd.currentAdminPartI.Id + ':1');
            System.Debug('fndPart :' + fndPart );
            
            if(fndPart != NULL) {
                erd.ExamRegMod.Part_I_Exam_Part_From__c = fndPart.Id;
            }
        }
        System.Debug('erd.selectedAdminPartI:' + erd.selectedAdminPartI);
        
        if(erd.selectedSitePartI != NULL) {
            erd.ExamRegMod.Part_I_Exam_Site_To__c = erd.selectedSitePartI.Id;
            erd.ExamRegMod.Part_I_Exam_Group_To__c = erd.selectedSitePartI.Exam__r.Exam_Group__c;
            erd.ExamRegMod.Part_I_Exam_Part_To__c = erd.selectedSitePartI.Exam_Part__c;
        } else if(erd.selectedAdminPartI != NULL) {
            // AG 2/15/2023 -- Add Part Event if site not selected
            Exam_Part__c fndPart = mapPartByAdmin.get(erd.selectedAdminPartI.Id + ':1');
            System.Debug('fndPart :' + fndPart );
            
            if(fndPart != NULL) {
                erd.ExamRegMod.Part_I_Exam_Part_To__c = fndPart.Id;
            }
        }
            
        
        if(erd.currentSitePartII != NULL) {
            erd.ExamRegMod.Part_II_Exam_Site_From__c = erd.currentSitePartII.Id;
            erd.ExamRegMod.Part_II_Exam_Group_From__c = erd.currentSitePartII.Exam__r.Exam_Group__c;
            erd.ExamRegMod.Part_II_Exam_Part_From__c = erd.currentSitePartII.Exam_Part__c;
        } else if(erd.currentAdminPartII != NULL) {
            // AG 2/15/2023 -- Add Part Event if site not selected
            Exam_Part__c fndPart = mapPartByAdmin.get(erd.currentAdminPartII.Id + ':2');
            System.Debug('fndPart :' + fndPart );
            
            if(fndPart != NULL) {
                erd.ExamRegMod.Part_II_Exam_Part_From__c = fndPart.Id;
            }
        }
            
        
        if(erd.selectedSitePartII != NULL) {
            erd.ExamRegMod.Part_II_Exam_Site_To__c = erd.selectedSitePartII.Id;
            erd.ExamRegMod.Part_II_Exam_Group_To__c = erd.selectedSitePartII.Exam__r.Exam_Group__c;
            erd.ExamRegMod.Part_II_Exam_Part_To__c = erd.selectedSitePartII.Exam_Part__c;
        } else if(erd.selectedAdminPartII != NULL) {
            // AG 2/15/2023 -- Add Part Event if site not selected
            Exam_Part__c fndPart = mapPartByAdmin.get(erd.selectedAdminPartII.Id + ':2');
            if(fndPart != NULL) {
                erd.ExamRegMod.Part_II_Exam_Part_To__c = fndPart.Id;
            }
        }
            
        
        erd.ExamRegMod.Status__c = 'Pending';
        
       /* System.debug('erd.selectedSitePartI:' + erd.selectedSitePartI);
        System.debug('erd.selectedSitePartII:' + erd.selectedSitePartII);
        System.debug('erd.selectedAdminPartI:' + erd.selectedAdminPartI);
        System.debug('erd.selectedAdminPartII:' + erd.selectedAdminPartII);*/
        
        // AG 1/15/2023
        erd.Locations = [select id, Country__c, LetterCode__c, Compliance__c, Is_Billing_Allowed__c, 
                                        Is_Shipping_Allowed__c, Is_Credit_Card_Allowed__c, PhoneCode__c,
                                        Is_Wire_Allowed__c, Is_Check_Allowed__c, Postal_Code_Required__c, 
                                        Provence_Required__c, (select id, name, code__c from Provinces__r Order by Name) 
                                        from Country_Code__c Order By Country__c];
        //System.debug('erd.Locations:' + erd.Locations);
        
        return erd;
    }
    
    /**
     * @description Entry point for performing the exam site switch, and creates a refund if applicable.
     * @param examRegistrationId the Exam Registration which the user is attempting to switch Exam Sites for.
     * @param targetExamSiteId the Exam Site ID the user would like to switch into.
     * @return a Response.Envelope containing the status of the transaction
     */
    public static Response.Envelope changeExamSiteOnExamRegistrations(Id examRegistrationId, Id targetExamSiteId){
        
        Exam_Attempt__c examRegistrationInContext = fetchExamRegistrationInContext(examRegistrationId);
        
        Id siteId = examRegistrationInContext.Exam_Site__r.Site__c;
        Id contactId = examRegistrationInContext.Member__c;

        Exam_Sites__c sourceExamSite = examRegistrationInContext.Exam_Site__r;
        Exam_Sites__c targetExamSite = getNewExamSite(targetExamSiteId);
        
        String sourceExamSiteName = sourceExamSite.Name.toUpperCase();
        String targetExamSiteName = targetExamSite.Name.toUpperCase();
        
        /*System.Debug('changeExamSiteOnExamRegistrations sourceExamSiteName :' + sourceExamSiteName );
        System.Debug('changeExamSiteOnExamRegistrations targetExamSiteName :' + targetExamSiteName );*/
        
        
        Map<Id, Exam_Attempt__c> examRegistrations = getExamRegistrationByContactIdAndTestSiteId(contactId, siteId);
                
        switchExamSites(examRegistrationId, targetExamSiteId);
       
        Set<Id> opportunityIds = getAllOpportunityIdsByExamRegistrations(examRegistrations.values());

        List<Product_Refunds__c> toInsert = new List<Product_Refunds__c>();
        
        if(sourceExamSite.Site__r.Is_OSTA_Information_Required__c && !targetExamSite.Site__r.Is_OSTA_Information_Required__c){
            
            List<Product_Refunds__c> chinaLocationFeeProductRefunds = createChinaLocationFeeProductRefunds(examRegistrations, opportunityIds); 
            List<Product_Refunds__c> chinaDataFeeProductRefunds = createChinaDataFeeProductRefunds(contactId);
            
            toInsert.addAll(chinaLocationFeeProductRefunds);
            toInsert.addAll(chinaDataFeeProductRefunds);
            
        }
        
        //System.Debug('toInsert :' + toInsert);


        Decimal totalPrice = 0.00;        
        for(Product_Refunds__c productRefund: toInsert){
            totalPrice += productRefund.Refund_Amount__c; 
        }
        
        if(!toInsert.isEmpty()){
            
            Response.Detail response = new Response.Detail();
            
            response.status = 200;                    
            
            response.message = 'This is a confirmation of your ' + sourceExamSite.Exam__r.Exam__c + ' exam site location change from ' + sourceExamSite.Site__r.Display_Address__c + ' to ' + targetExamSite.Site__r.Display_Address__c + '.  '; 
            response.message+= 'Due to the Location Fee and Data Fee charge, the member services team will be processing a refund for you in the amount of USD ' + totalPrice + '.  This will take up to (7) seven business days before it will appear within your account.';
            
            INSERT toInsert;
            
            return response;
            
        }else{
            
            Response.Detail response = new Response.Detail();
            
            response.status = 200;                    
            
            response.message = 'This is a confirmation of your ' + sourceExamSite.Exam__r.Exam__c + ' exam site location change from ' + sourceExamSite.Site__r.Display_Address__c + ' to ' + targetExamSite.Site__r.Display_Address__c + '.';
            
            return response;   
            
        }
        
    }

    
     public static ChargentOrders__Transaction__c createTransaction(String oppId) {
        ChargentOrders__ChargentOrder__c order = [Select Id from ChargentOrders__ChargentOrder__c where Opportunity__c =: oppId];
        
        ChargentOrders__Transaction__c trans = new ChargentOrders__Transaction__c();
        if(String.isNotBlank(OppId)){
            trans.Opportunity__c = oppId;
            trans.ChargentOrders__Order__c = order.id;
            trans.ChargentOrders__Amount__c = 0.00;
            trans.ChargentOrders__Response_Message__c = 'Approved';
            trans.ChargentOrders__Response_Status__c = 'Approved';
            trans.ChargentOrders__Type__c = 'Charge';
            trans.ChargentOrders__Payment_Method__c = 'Free';
            trans.ChargentOrders__Gateway_Date__c =system.now();
            
            insert trans;
        }
        return trans;
    } 
    
    public static Boolean isAdminScheduleWindowOpen(Exam_Administration__c examAdmin) {
        Date tdy = Date.today();
        return (tdy >= examAdmin.Exam_Scheduling_Start_Date__c && tdy <= examAdmin.Exam_Scheduling_End_Date__c);
    }
    
    
    public static Boolean isPart1AdminMove(Exam_Registration_Modification__c erm) {
        return (erm.Part_I_Exam_Registration__c != NULL && 
                erm.Part_I_Exam_Admin_From__c != erm.Part_I_Exam_Admin_To__c);
    }

    public static Boolean isPart2AdminMove(Exam_Registration_Modification__c erm) {
        return (erm.Part_II_Exam_Registration__c != NULL && 
                erm.Part_II_Exam_Admin_From__c != erm.Part_II_Exam_Admin_To__c);
    }
    
    public static Boolean isSiteMove(String examRegId, String curSiteId, String siteFromId, String siteToId) {
        return (examRegId != NULL && siteFromId != siteToId && siteToId != curSiteId);
    }
    
    public static Exam_Attempt__c createDeferredExamAttempt(Exam_Attempt__c examReg, String adminToId, String partToId, String siteToId, boolean doNotCountOneTimeDefrl, boolean freeDeferral,string deferralSubType) {
        Exam_Attempt__c newExamReg = new Exam_Attempt__c(
            Deferred_From_Exam_Registration__c = examReg.Id,
            Member__c = examReg.Member__c,
            Exam_Site__c = siteToId,
            Exam_Administration__c = adminToId,
            Exam_Part__c = partToId,
            Other_Exam_Registrations__c = examReg.Other_Exam_Registrations__c,
            RecordTypeId = examReg.RecordTypeId,
            Deferral_Status__c = 'Deferred In',
            Deferral_SubType__c = deferralSubType,
            Original_Exam_Administration__c = adminToId,
            Opportunity__c = examReg.Opportunity__c,
            Candidate_Commitment__c = examReg.Candidate_Commitment__c,
            Candidate_Requirement__c = examReg.Candidate_Requirement__c,
            Original_Exam_Site__c = siteToId,
            Defered__c = 'Approved',
            Allow_Future_Deferral__c = doNotCountOneTimeDefrl,
            Free_Deferral__c = freeDeferral,
            hasViolation__c = false,
            Hide_Exam_Result__c = false,
            Pearson_Member_First_Name__c = examReg.Member__r.First_Name_as_it_Appears_on_ID__c, 
            Pearson_Member_Middle_Name__c = examReg.Member__r.Middle_Name_as_it_Appears_on_ID__c,
            Pearson_Member_Last_Name__c = examReg.Member__r.Last_Name_as_it_Appears_on_ID__c,
            ADA_Status__c = examReg.ADA_Status__c,
            RAD_Status__c = examReg.RAD_Status__c,
            Additional_Accommodations__c = examReg.Additional_Accommodations__c
        );
        return newExamReg;
    }
    
    
    public static void processExamRegMods(Set<Id> setExamRegMods){
        dmlListWrapper dmlList = processExamRegModsBulk(setExamRegMods);
        List<Contract> contractsToUpdate = new List<Contract>();
        List<Contract> insertedContractList = new List<Contract>();
        if(dmlList.contractsToInsert != null && !dmlList.contractsToInsert.isEmpty()){
            insert dmlList.contractsToInsert;
            insertedContractList = [Select Id,Status,AccountId,RecordTypeId from Contract where Id IN: dmlList.contractsToInsert];
        }
        
        for(Contract cont : insertedContractList){
            cont.Status = 'Activated ( Auto-Renew )';
            contractsToUpdate.add(cont);
        }
        if(dmlList.contractsToUpdate != null && !dmlList.contractsToUpdate.isEmpty()){
            contractsToUpdate.addAll(dmlList.contractsToUpdate);
        }
        
        if(!contractsToUpdate.isEmpty()){
            update contractsToUpdate;
            
            
        }
        
        if(dmlList.examRegToUpdate != null && !dmlList.examRegToUpdate.isEmpty()){
            update dmlList.examRegToUpdate;
            
        }
    }
    
    public static dmlListWrapper processExamRegModsBulk(Set<Id> setExamRegMods){
            
        Id OSTARecTypeId = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'OSTA_Program');
        Id frmRecordTypeID = RecordTypeHelper.getRecordTypeIdFromSchema('Contract', 'FRM_Program');
        List<Exam_Attempt__c> eaUpdates = new List<Exam_Attempt__c>();
        List<Product_Refunds__c> productRefunds = new List<Product_Refunds__c>();
        Set<Id> setAccounts = new Set<Id>();
        Set<Id> examRegIds = new Set<Id>();
        Set<Id> oppIds = new Set<Id>();
        List<AppError__c> appErrors = new List<AppError__c>();
        List<Contract> contractsToUpdate = new List<Contract>();
        List<Contract> contractsToInsert = new List<Contract>();
        Map<Id,Contract> accIdToOSTAPrgMap = new Map<Id,Contract>();
        Map<Id,Contract> accIdToFRMPrgMap = new Map<Id,Contract>();
        List<Exam_Registration_Modification__c> examRegModList = [SELECT Id, Customer_Email__c,Created_from_MS_Tool__c,
                                                                  Part_I_Exam_Registration__r.Member__r.First_Name_as_it_Appears_on_ID__c, Part_I_Exam_Registration__r.Member__r.Middle_Name_as_it_Appears_on_ID__c, Part_I_Exam_Registration__r.Member__r.Last_Name_as_it_Appears_on_ID__c,
                                                                  Part_I_Exam_Registration__r.Other_Exam_Registrations__c,
                                                                  Part_I_Exam_Registration__r.RecordTypeId,
                                                                  Part_I_Exam_Registration__r.Candidate_Commitment__c,
                                                                  Part_I_Exam_Registration__r.Candidate_Requirement__c,
                                                                  
                                                                  Part_I_Exam_Registration__r.Exam_Administration__c,
                                                                  Part_I_Exam_Registration__r.Deferred_Exam_Administration__c,
                                                                  Part_I_Exam_Registration__r.Original_Exam_Administration__c,
                                                                  Part_I_Exam_Registration__r.Deferred_From_Exam_Registration__c, Part_I_Exam_Registration__r.Deferred_From_Exam_Registration__r.Exam_Administration__c,
                                                                  Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Group__r.Active__c,Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Group__r.SCR_Active__c,
                                                                  Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Group__r.Active__c,Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Group__r.SCR_Active__c,
                                                                  
                                                                  Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_I_Exam_Registration__r.Exam_Administration__r.Exam_Scheduling_End_Date__c,
                                                                  
                                                                  Part_II_Exam_Registration__r.Member__r.First_Name_as_it_Appears_on_ID__c, Part_II_Exam_Registration__r.Member__r.Middle_Name_as_it_Appears_on_ID__c, Part_II_Exam_Registration__r.Member__r.Last_Name_as_it_Appears_on_ID__c,
                                                                  Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_II_Exam_Registration__r.Exam_Administration__r.Exam_Scheduling_End_Date__c,
                                                                  
                                                                  Part_I_Exam_Registration__c,Part_I_Exam_Registration__r.Member__c,Part_I_Exam_Registration__r.Member_Email__c,Part_I_Exam_Registration__r.Exam_Site__r.Exam__r.Exam_Group__c,Part_I_Exam_Registration__r.Candidate_Commitment__r.AccountId,Part_I_Exam_Registration__r.Defered__c,Part_I_Exam_Registration__r.Deferral_Status__c,Part_I_Exam_Registration__r.Future_Free_Deferral__c,Part_I_Exam_Registration__r.Cloned_From__c,Part_I_Exam_Registration__r.Opportunity__c,Part_I_Exam_Registration__r.Opportunity__r.AccountId,Part_I_Exam_Registration__r.RPT_Exam_Program__c,Part_I_Exam_Registration__r.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,Part_I_Exam_Registration__r.Exam_Site__r.Exam_Part__c,Part_I_Exam_Registration__r.Exam_Site__r.Exam_Part__r.Exam_Part_Number__c,
                                                                  Part_I_Exam_Admin_From__c,Part_I_Exam_Admin_From__r.Exam_Group__c,Part_I_Exam_Admin_From__r.Exam_Group__r.Active__c,Part_I_Exam_Admin_From__r.Exam_Group__r.SCR_Active__c,Part_I_Exam_Admin_From__r.Exam_Type__c, 
                                                                  
                                                                  Part_I_Exam_Admin_From__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_I_Exam_Admin_From__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_I_Exam_Admin_From__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_I_Exam_Admin_From__r.Exam_Scheduling_End_Date__c,

                                                                  Part_II_Exam_Admin_From__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_II_Exam_Admin_From__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_II_Exam_Admin_From__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_II_Exam_Admin_From__r.Exam_Scheduling_End_Date__c,
                                                                  
                                                                  Part_I_Exam_Admin_To__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_I_Exam_Admin_To__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_I_Exam_Admin_To__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_I_Exam_Admin_To__r.Exam_Scheduling_End_Date__c,

                                                                  Part_II_Exam_Admin_To__r.Exam_Admin_Modifications_Start_Date__c,
                                                                  Part_II_Exam_Admin_To__r.Exam_Admin_Modifications_End_Date__c,
                                                                  Part_II_Exam_Admin_To__r.Exam_Scheduling_Start_Date__c,
                                                                  Part_II_Exam_Admin_To__r.Exam_Scheduling_End_Date__c,
                                                                  
                                                                  Part_I_Exam_Part_From__c,
                                                                  Part_II_Exam_Part_From__c,
                                                                  Part_I_Exam_Part_To__c,
                                                                  Part_II_Exam_Part_To__c,
                                                                  
                                                                  Part_I_Exam_Admin_To__c,Part_I_Exam_Admin_To__r.Exam_Group__c,Part_I_Exam_Admin_To__r.Exam_Group__r.Active__c,Part_I_Exam_Admin_To__r.Exam_Group__r.SCR_Active__c,Part_I_Exam_Admin_To__r.Exam_Type__c,
                                                                  Part_I_Exam_Site_From__c,Part_I_Exam_Site_From__r.Exam_Part__c,Part_I_Exam_Site_From__r.Exam_Part__r.Exam__r.Exam__c,Part_I_Exam_Site_From__r.Exam_Part__r.Exam_Administration__c,Part_I_Exam_Site_From__r.Exam_Part__r.Exam_Part_Number__c,Part_I_Exam_Site_From__r.Site__c,Part_I_Exam_Site_From__r.Site__r.Name,Part_I_Exam_Site_From__r.Site__r.Is_OSTA_Information_Required__c,
                                                                  Part_I_Exam_Site_To__c,Part_I_Exam_Site_To__r.Exam_Part__c,Part_I_Exam_Site_To__r.Exam_Part__r.Exam_Administration__c,Part_I_Exam_Site_To__r.Exam_Part__r.Exam__r.Exam__c,Part_I_Exam_Site_To__r.Exam_Part__r.Exam_Part_Number__c,Part_I_Exam_Site_To__r.Site__c,Part_I_Exam_Site_To__r.Site__r.Name,Part_I_Exam_Site_To__r.Site__r.Is_OSTA_Information_Required__c,
                                                                  
                                                                  Part_II_Exam_Registration__r.Other_Exam_Registrations__c,
                                                                  Part_II_Exam_Registration__r.RecordTypeId,
                                                                  Part_II_Exam_Registration__r.Candidate_Commitment__c,
                                                                  Part_II_Exam_Registration__r.Candidate_Requirement__c,

                                                                  Part_II_Exam_Registration__r.Exam_Administration__c,
                                                                  Part_II_Exam_Registration__r.Deferred_Exam_Administration__c,
                                                                  Part_II_Exam_Registration__r.Original_Exam_Administration__c,
                                                                  Part_II_Exam_Registration__r.Deferred_From_Exam_Registration__c, Part_II_Exam_Registration__r.Deferred_From_Exam_Registration__r.Exam_Administration__c,
                                                                  Part_II_Exam_Registration__c,Part_II_Exam_Registration__r.Member__c,Part_II_Exam_Registration__r.Member_Email__c,Part_II_Exam_Registration__r.Exam_Site__r.Exam__r.Exam_Group__c,Part_II_Exam_Registration__r.Candidate_Commitment__r.AccountId,Part_II_Exam_Registration__r.Defered__c,Part_II_Exam_Registration__r.Deferral_Status__c,Part_II_Exam_Registration__r.Future_Free_Deferral__c,Part_II_Exam_Registration__r.Cloned_From__c,Part_II_Exam_Registration__r.Opportunity__c,Part_II_Exam_Registration__r.Opportunity__r.AccountId,Part_II_Exam_Registration__r.RPT_Exam_Program__c,Part_II_Exam_Registration__r.Exam_Site__r.Site__r.Is_OSTA_Information_Required__c,Part_II_Exam_Registration__r.Exam_Site__r.Exam_Part__c,Part_II_Exam_Registration__r.Exam_Site__r.Exam_Part__r.Exam_Part_Number__c,
                                                                  Part_II_Exam_Admin_From__c,Part_II_Exam_Admin_From__r.Exam_Group__c,Part_II_Exam_Admin_From__r.Exam_Group__r.Active__c,Part_II_Exam_Admin_From__r.Exam_Group__r.SCR_Active__c,Part_II_Exam_Admin_From__r.Exam_Type__c,
                                                                  Part_II_Exam_Admin_To__c,Part_II_Exam_Admin_To__r.Exam_Group__c,Part_II_Exam_Admin_To__r.Exam_Group__r.Active__c,Part_II_Exam_Admin_To__r.Exam_Group__r.SCR_Active__c,Part_II_Exam_Admin_To__r.Exam_Type__c,
                                                                  Part_II_Exam_Site_From__c,Part_II_Exam_Site_From__r.Exam_Part__c,Part_II_Exam_Site_From__r.Exam_Part__r.Exam_Administration__c,Part_II_Exam_Site_From__r.Exam_Part__r.Exam__r.Exam__c,Part_II_Exam_Site_From__r.Exam_Part__r.Exam_Part_Number__c,Part_II_Exam_Site_From__r.Site__c,Part_II_Exam_Site_From__r.Site__r.Name,Part_II_Exam_Site_From__r.Site__r.Is_OSTA_Information_Required__c,
                                                                  Part_II_Exam_Site_To__c,Part_II_Exam_Site_To__r.Exam_Part__c,Part_II_Exam_Site_To__r.Exam_Part__r.Exam_Administration__c,Part_II_Exam_Site_To__r.Exam_Part__r.Exam__r.Exam__c,Part_II_Exam_Site_To__r.Exam_Part__r.Exam_Part_Number__c,Part_II_Exam_Site_To__r.Site__c,Part_II_Exam_Site_To__r.Site__r.Name,Part_II_Exam_Site_To__r.Site__r.Is_OSTA_Information_Required__c,
                                                                  Part_I_Exam_Registration__r.Result__c,Part_II_Exam_Registration__r.Result__c,
                                                                  Part_I_Exam_Registration__r.ADA_Status__c,Part_I_Exam_Registration__r.RAD_Status__c,Part_I_Exam_Registration__r.Additional_Accommodations__c,
                                                                  Part_II_Exam_Registration__r.ADA_Status__c,Part_II_Exam_Registration__r.RAD_Status__c,Part_II_Exam_Registration__r.Additional_Accommodations__c,                                                                  
                                                                  Status__c,User__c,Deferral_Subtype__c,
                                                                  Not_Applicable_to_One_Time_Def__c,Free_Deferral__c,
                                                                  (select Id, AccountId from Opportunities__r)
                                                                  FROM Exam_Registration_Modification__c 
                                                                  WHERE Id = :setExamRegMods AND Status__c = 'Pending'];
        
        for(Exam_Registration_Modification__c erm : examRegModList){
            if(erm.Part_I_Exam_Registration__c != NULL){
                setAccounts.add(erm.Part_I_Exam_Registration__r.Candidate_Commitment__r.AccountId);
                examRegIds.add(erm.Part_I_Exam_Registration__c);
                if(erm.Part_I_Exam_Registration__r.Cloned_From__c != null)
                    examRegIds.add(erm.Part_I_Exam_Registration__r.Cloned_From__c);
            }
            if(erm.Part_II_Exam_Registration__c != NULL){
                setAccounts.add(erm.Part_II_Exam_Registration__r.Candidate_Commitment__r.AccountId);
                examRegIds.add(erm.Part_II_Exam_Registration__c);
                if(erm.Part_II_Exam_Registration__r.Cloned_From__c != null)
                    examRegIds.add(erm.Part_II_Exam_Registration__r.Cloned_From__c);
            }
        }
        
        Map<Id,Exam_Attempt__c> examRegMap = new Map<Id,Exam_Attempt__c>([Select Id,Cloned_From__c,Opportunity__c,
                                                                          (SELECT Id, Name, CreatedDate, ProductCode,Exam_Registration__c, OpportunityId
                                                                            FROM Opportunity_Line_Items__r WHERE (ProductCode = 'CHLF' OR ProductCode = 'CHNDF') AND Opportunity.StageName = 'Closed'
                                                                            ORDER BY CreatedDate DESC)  
                                                                          from Exam_Attempt__c where Id IN: examRegIds]);
        
        for(Exam_Attempt__c ea : examRegMap.values()){
            oppIds.add(ea.Opportunity__c);
            if(!ea.Opportunity_Line_Items__r.isEmpty()) {
                for(OpportunityLineItem oli :ea.Opportunity_Line_Items__r) {
                    oppIds.add(oli.OpportunityId);    
                }
            }
        }
        
        LIST<Contract> ostaPrograms = [
            SELECT Id, Name, Status, RecordType.Name, AccountId, OSTA_Last_Upload_Date__c,Opportunity__c
            FROM Contract
            WHERE 
            AccountId in :setAccounts AND
            ((RecordTypeId =: OSTARecTypeId AND Status LIKE 'Activated%') OR
              (RecordTypeId =: frmRecordTypeID AND (Status LIKE 'Activated%' OR Status = 'Draft')))
        ];
        
        for(Contract cont : ostaPrograms){
            if(cont.RecordTypeId == frmRecordTypeID){
                accIdToFRMPrgMap.put(cont.AccountId,cont);
            }else if(cont.RecordTypeId == OSTARecTypeId){
                accIdToOSTAPrgMap.put(cont.AccountId,cont);
                oppIds.add(cont.Opportunity__c);
            }
        }
        
        
        List<Exam_Attempt__c> lstUpdateOtherExamRegistrations = new List<Exam_Attempt__c>();
        List<Exam_Attempt__c> lstAddOtherExamRegistrations = new List<Exam_Attempt__c>();
        
        MAP<Id,Opportunity> mapOpp = new MAP<Id,Opportunity>([select Id, AccountId,Name,
                                                              (SELECT Id, ProductCode, Product2Id, Product2.ProductCode, Description, PricebookEntryId, Quantity, UnitPrice, SortOrder, TotalPrice FROM OpportunityLineItems),
                                                              (SELECT Id, Opportunity__c, Response_Status__c, Amount__c FROM Legacy_Transactions__r 
                                                               WHERE Response_Status__c = 'Approved' ORDER BY Amount__c ASC),
                                                              (SELECT Id, Opportunity__c, ChargentOrders__Response_Status__c, ChargentOrders__Amount__c 
                                                               FROM Transactions__r WHERE Opportunity__c IN :oppIds AND ChargentOrders__Response_Status__c = 'Approved'),
                                                              (select Id, Name, Opportunity__c from Product_Refunds__r where Product_Code__c = 'CHLF' AND Status__c != 'Denied')
                                                              from Opportunity where Exam_Registration_Modification__c in :setExamRegMods OR ID IN: oppIds]);
        
        for(Exam_Registration_Modification__c erm :examRegModList) {
            Boolean updateER1 = false;
            Boolean updateER2 = false;
            Opportunity opp = !erm.Opportunities__r.isEmpty()?erm.Opportunities__r[0]:null;
            String AccountId = (erm.Part_I_Exam_Registration__c != NULL) ? erm.Part_I_Exam_Registration__r.Candidate_Commitment__r.AccountId : erm.Part_II_Exam_Registration__r.Candidate_Commitment__r.AccountId;
            Id contactId = (erm.Part_I_Exam_Registration__c != NULL) ? erm.Part_I_Exam_Registration__r.Member__c : erm.Part_II_Exam_Registration__r.Member__c;
            Exam_Attempt__c er1 = new Exam_Attempt__c(Id = erm.Part_I_Exam_Registration__c);
            Exam_Attempt__c er2 = new Exam_Attempt__c(Id = erm.Part_II_Exam_Registration__c);
            if((erm.Part_I_Exam_Registration__c != NULL && (erm.Part_I_Exam_Admin_From__c == NULL || erm.Part_I_Exam_Admin_To__c == NULL)) 
               || (erm.Part_II_Exam_Registration__c != NULL && (erm.Part_II_Exam_Admin_From__c == NULL || erm.Part_II_Exam_Admin_To__c == NULL))) {
                erm.Status__c = 'Error';
                continue;
            }

            //System.debug('Process Mod:' + erm);
            
            // AG - 1/20/2023 - New Deferral Logic
            // Part I
            //System.debug('isAdminMove 1?');
            
            if(isPart1AdminMove(erm)) {
                
                //System.debug('Yes isAdminMove 1');
                
                // Was Already Deferred?
                if(erm.Part_I_Exam_Registration__r.Deferred_Exam_Administration__c != NULL || erm.Part_I_Exam_Registration__r.Deferred_From_Exam_Registration__c != NULL) {
                    
                    //System.debug('Yes was Deferred Already 1');
                    
                    // Was Classic Deferral?
                    if(erm.Part_I_Exam_Registration__r.Deferred_Exam_Administration__c != NULL) {
                        
                        //System.debug('Was Classic Deferral 1');
                        
                        // Is Going Back To Original?
                        if(erm.Part_I_Exam_Admin_To__c == erm.Part_I_Exam_Registration__r.Original_Exam_Administration__c) {
                            
                           // System.debug('Is Going Back To Original 1');
                            
                            // Remove Deferral
                            er1.Defered__c = NULL;
                            er1.Deferral_Status__c = NULL;
                            er1.Cancelled__c = False;
                            er1.Deferred_Exam_Administration__c = NULL;
                            er1.Deferral_Subtype__c = NULL;
                            er1.Exam_Site__c = erm.Part_I_Exam_Site_To__c;
                            updateER1=True;
                            //System.debug('Remove Deferral 1:' + er1);
                            
                        }
                        
                    } else {
                        
                        //System.debug('Was Instant Deferral 1');
                       
                        // Remove Instant Deferral
                        Exam_Attempt__c updateER = new Exam_Attempt__c(Id=erm.Part_I_Exam_Registration__c);
                        
                        // Cancel Exam Reg
                        updateER.Cancelled__c = True;
                        updateER.Canceled_Reason_Type__c = 'Cancel Deferral';
                        
                        //System.debug('Remove Instant Deferral 1:' + updateER);
                        
                        lstUpdateOtherExamRegistrations.add(updateER);
                        
                        // Set er1 as the original Exam Reg from the instant deferral
                        er1.Id = erm.Part_I_Exam_Registration__r.Deferred_From_Exam_Registration__c;
                        //System.debug('Set er1 as the original Exam Reg from the instant deferral 1:' + er1);

                        // If returning to original Exam Admin
                        if(erm.Part_I_Exam_Admin_To__c == erm.Part_I_Exam_Registration__r.Deferred_From_Exam_Registration__r.Exam_Administration__c) {
                           // System.debug('Is Going Back To Original 1');
                            
                            // Remove Deferral
                            er1.Defered__c = NULL;
                            er1.Deferral_Status__c = NULL;
                            er1.Cancelled__c = False;
                            er1.Deferred_Exam_Administration__c = NULL;
                            er1.Deferral_Subtype__c = NULL;
                            er1.Exam_Site__c = erm.Part_I_Exam_Site_To__c;
                            updateER1=True;
                           // System.debug('Remove Deferral 1:' + er1);
                        }
                    }
                }
                
                // If did not go back to original
                if(!updateER1) {
                    
                    //System.debug('did not go back to original 1');
                    
                    if(isAdminScheduleWindowOpen(erm.Part_I_Exam_Admin_To__r)) {
                        
                        //System.debug('To Admin Scheduling Opened 1');
                        
                        // Update Current Exam Admin
                        er1.Defered__c = 'Approved';
                        er1.Deferral_Status__c = 'Deferred Out';
                        er1.Cancelled__c = True;
                        er1.Deferred_Exam_Administration__c = erm.Part_I_Exam_Admin_To__c;
                        er1.Deferral_Subtype__c = erm.Deferral_Subtype__c;
                        updateER1=True;
                        
                        //System.debug('Set Deferred Out Approved 1:' + er1);
                        
                        // Create new Exam Attempt
                        Exam_Attempt__c addER = createDeferredExamAttempt(erm.Part_I_Exam_Registration__r, erm.Part_I_Exam_Admin_To__c, erm.Part_I_Exam_Part_To__c, erm.Part_I_Exam_Site_To__c, erm.Not_Applicable_to_One_Time_Def__c, erm.Free_Deferral__c,erm.Deferral_SubType__c);
                        
                        //System.debug('Create new Exam Attempt 1:' + addER);
                        
                        lstAddOtherExamRegistrations.add(addER);
                        
                    } else {
                        
                        // Update Current Exam Admin
                        er1.Defered__c = 'Pending';
                        er1.Deferral_Status__c = 'Deferred Out';
                        er1.Cancelled__c = False;
                        er1.Deferred_Exam_Administration__c = erm.Part_I_Exam_Admin_To__c;
                        er1.Deferral_Subtype__c = erm.Deferral_Subtype__c;
                        updateER1=True;
                        
                        //System.debug('Set to Deferred Out Pending 1:' + er1); 
                        
                    }
                    
                }
                
            } else if(isSiteMove(erm.Part_I_Exam_Registration__c, erm.Part_I_Exam_Registration__r.Exam_Site__c, erm.Part_I_Exam_Site_From__c, erm.Part_I_Exam_Site_To__c)) {
                er1.Exam_Site__c = erm.Part_I_Exam_Site_To__c;
                updateER1=True;                
                
                //System.debug('Update Exam Site ER 1:' + er1);
            }
            
            // Part II
            //System.debug('isAdminMove 2?');
            if(isPart2AdminMove(erm)) {
                
               // System.debug('Yes isAdminMove 2');
                
                // Was Already Deferred?
                if(erm.Part_II_Exam_Registration__r.Deferred_Exam_Administration__c != NULL || erm.Part_II_Exam_Registration__r.Deferred_From_Exam_Registration__c != NULL) {
                    
                    //System.debug('Yes was Deferred Already 2');
                    
                    // Was Classic Deferral?
                    if(erm.Part_II_Exam_Registration__r.Deferred_Exam_Administration__c != NULL) {
                        
                        //System.debug('Was Classic Deferral 2');
                        
                        // Is Going Back To Original?
                        if(erm.Part_II_Exam_Admin_To__c == erm.Part_II_Exam_Registration__r.Original_Exam_Administration__c) {
                            
                           // System.debug('Is Going Back To Original 2');
                            
                            // Remove Deferral
                            er2.Defered__c = NULL;
                            er2.Deferral_Status__c = NULL;
                            er2.Cancelled__c = False;
                            er2.Deferred_Exam_Administration__c = NULL;
                            er2.Deferral_Subtype__c = NULL;
                            er2.Exam_Site__c = erm.Part_II_Exam_Site_To__c;
                            updateer2=True;
                           // System.debug('Remove Deferral 2:' + er2);
                            
                        }
                        
                    } else {
                        
                       // System.debug('Was Instant Deferral 2');
                       
                        // Remove Instant Deferral
                        Exam_Attempt__c updateER = new Exam_Attempt__c(Id=erm.Part_II_Exam_Registration__c);
                        
                        // Cancel Exam Reg
                        updateER.Cancelled__c = True;
                        updateER.Canceled_Reason_Type__c = 'Cancel Deferral';
                        
                       // System.debug('Remove Instant Deferral 2:' + updateER);
                        
                        lstUpdateOtherExamRegistrations.add(updateER);
                        
                        // Set er2 as the original Exam Reg from the instant deferral
                        er2.Id = erm.Part_II_Exam_Registration__r.Deferred_From_Exam_Registration__c;
                        //System.debug('Set er2 as the original Exam Reg from the instant deferral 2:' + er2);

                        // If returning to original Exam Admin
                        if(erm.Part_II_Exam_Admin_To__c == erm.Part_II_Exam_Registration__r.Deferred_From_Exam_Registration__r.Exam_Administration__c) {
                            System.debug('Is Going Back To Original 2');
                            
                            // Remove Deferral
                            er2.Defered__c = NULL;
                            er2.Deferral_Status__c = NULL;
                            er2.Cancelled__c = False;
                            er2.Deferred_Exam_Administration__c = NULL;
                            er2.Deferral_Subtype__c = NULL;
                            er2.Exam_Site__c = erm.Part_II_Exam_Site_To__c;
                            updateer2=True;
                           // System.debug('Remove Deferral 2:' + er2);
                        }
                    }
                }
                
                // If did not go back to original
                if(!updateer2) {
                    
                    //System.debug('did not go back to original 2');
                    
                    if(isAdminScheduleWindowOpen(erm.Part_II_Exam_Admin_To__r)) {
                        
                        //System.debug('To Admin Scheduling Opened 2');
                        
                        // Update Current Exam Admin
                        er2.Defered__c = 'Approved';
                        er2.Deferral_Status__c = 'Deferred Out';
                        er2.Cancelled__c = True;
                        er2.Deferred_Exam_Administration__c = erm.Part_II_Exam_Admin_To__c;
                        er2.Deferral_Subtype__c = erm.Deferral_Subtype__c;
                        updateer2=True;
                        
                        //System.debug('Set Deferred Out Approved 2:' + er2);
                        
                        // Create new Exam Attempt
                        Exam_Attempt__c addER = createDeferredExamAttempt(erm.Part_II_Exam_Registration__r, erm.Part_II_Exam_Admin_To__c, erm.Part_II_Exam_Part_To__c, erm.Part_II_Exam_Site_To__c, erm.Not_Applicable_to_One_Time_Def__c, erm.Free_Deferral__c,erm.Deferral_SubType__c);
                        
                       // System.debug('Create new Exam Attempt 2:' + addER);
                        
                        lstAddOtherExamRegistrations.add(addER);
                        
                    } else {
                        
                        // Update Current Exam Admin
                        er2.Defered__c = 'Pending';
                        er2.Deferral_Status__c = 'Deferred Out';
                        er2.Cancelled__c = False;
                        er2.Deferred_Exam_Administration__c = erm.Part_II_Exam_Admin_To__c;
                        er2.Deferral_Subtype__c = erm.Deferral_Subtype__c;
                        updateer2=True;
                        
                        //System.debug('Set to Deferred Out Pending 2:' + er2); 
                        
                    }
                }
                
            } else if(isSiteMove(erm.Part_II_Exam_Registration__c, erm.Part_II_Exam_Registration__r.Exam_Site__c, erm.Part_II_Exam_Site_From__c, erm.Part_II_Exam_Site_To__c)) {
                er2.Exam_Site__c = erm.Part_II_Exam_Site_To__c;
                updateER2=True;                
            }
                
            if(updateER1 || updateER2) {
                erm.Status__c = 'Completed';
                if(erm.Part_I_Exam_Registration__c != NULL) {
                    erm.Customer_Email__c = erm.Part_I_Exam_Registration__r.Member_Email__c;    
                } else if(erm.Part_II_Exam_Registration__c != NULL) {
                    erm.Customer_Email__c = erm.Part_II_Exam_Registration__r.Member_Email__c;    
                }   

                if(updateER1) {
                    // Set Allow Future Deferral & Clean Up Result
                    if(erm.Part_II_Exam_Registration__c != null && erm.Not_Applicable_to_One_Time_Def__c){
                        er1.Selected_To_Allow_Future_Deferral__c = true;
                        if(erm.Part_I_Exam_Registration__r.Result__c != null && erm.Part_I_Exam_Registration__r.Result__c == 'No-Show')
                            er1.Result__c = null;
                        updateER1 = True;
                    }
                    if(erm.Part_I_Exam_Registration__c != null && erm.Free_Deferral__c){
                        er1.Future_Free_Deferral__c = true;
                        if(erm.Part_I_Exam_Registration__r.Result__c != null && erm.Part_I_Exam_Registration__r.Result__c == 'No-Show')
                            er1.Result__c = null;
                        updateER1 = True;
                    }
                    eaUpdates.add(er1);
                }
                if(updateER2) {
                    // Set Allow Future Deferral & Clean Up Result
                    if(erm.Part_II_Exam_Registration__c != null && erm.Not_Applicable_to_One_Time_Def__c){
                        er2.Selected_To_Allow_Future_Deferral__c = true;
                        if(erm.Part_I_Exam_Registration__r.Result__c != null && erm.Part_I_Exam_Registration__r.Result__c == 'No-Show')
                            er2.Result__c = null;
                        updateER2 = True;
                    }
                    if(erm.Part_I_Exam_Registration__c != null && erm.Free_Deferral__c){
                        er2.Future_Free_Deferral__c = true;
                        if(erm.Part_I_Exam_Registration__r.Result__c != null && erm.Part_I_Exam_Registration__r.Result__c == 'No-Show')
                            er2.Result__c = null;
                        updateER2 = True;
                    }
                    eaUpdates.add(er2);
                }                   
            }
            
            // OSTA
            if((erm.Part_I_Exam_Registration__c != NULL && erm.Part_I_Exam_Registration__r.RPT_Exam_Program__c == 'FRM') 
               || (erm.Part_II_Exam_Registration__c != NULL && erm.Part_II_Exam_Registration__r.RPT_Exam_Program__c == 'FRM')){
                   MAP<String,Exam_Part__c> mapCurrentAdminOSTA = new MAP<String,Exam_Part__c>();
                   MAP<String,Exam_Part__c> mapSelectedAdminOSTA = new MAP<String,Exam_Part__c>();
                   ostaMaps om = computeOSTAProgramMoves(erm.Part_I_Exam_Registration__r, erm.Part_II_Exam_Registration__r, erm.Part_I_Exam_Site_From__r, erm.Part_II_Exam_Site_From__r, erm.Part_I_Exam_Admin_From__r, erm.Part_II_Exam_Admin_From__r, erm.Part_I_Exam_Site_To__r, erm.Part_II_Exam_Site_To__r, erm.Part_I_Exam_Admin_To__r, erm.Part_II_Exam_Admin_To__r);
                   Integer totalCurrentPartWithOSTA = om.mapCurrentPartOSTA.size();
                   Integer totalSelectedPartWithOSTA = om.mapSelectedPartOSTA.size();
                   // If no OSTA program exists and have any OSTA Admins, create one 
                   if(!accIdToOSTAPrgMap.containskey(accountId) && totalSelectedPartWithOSTA > 0 && opp != NULL) {
                       Contract ostaContract = opportunityTriggerUtils_New.getNewOSTAContract(accountId,opp.Id,contactId,OSTARecTypeId,accIdToFRMPrgMap.get(accountId).Id);
                       contractsToInsert.add(ostaContract);
                   }
                   if(totalSelectedPartWithOSTA < totalCurrentPartWithOSTA) {
                      // system.debug('Inside here');
                       // If have OSTA Program and not uploaded data and now no Admins with OSTA then cancel program and refund
                       if(accIdToOSTAPrgMap.containskey(accountId) && accIdToOSTAPrgMap.get(accountId).OSTA_Last_Upload_Date__c == NULL && totalSelectedPartWithOSTA == 0) {
                           //system.debug('Inside here 2');
                           Contract ostaProgram = accIdToOSTAPrgMap.get(accountId);
                           ostaProgram.Status = 'Canceled';
                           contractsToUpdate.add(ostaProgram);
                           if(ostaProgram.Opportunity__c != NULL) {
                               //system.debug('Inside here 3');
                               List<Product_Refunds__c> prs = issueProductRefund(mapOpp.get(ostaProgram.Opportunity__c), 'CHNDF',1);
                               productRefunds.addAll(prs);
                           }
                       }
                       
                       Set<Decimal> partsInvolved = new Set<Decimal>();
                       Set<String> oppsInvolved = new Set<String>();
                       Id eaRefund=NULL;
                       Id eaRefundOther=NULL;
                       for(String curkey :om.mapCurrentPartOSTA.keySet()) {
                           
                           Exam_Part__c curVal = om.mapCurrentPartOSTA.get(curkey);
                           Exam_Part__c selVal = om.mapSelectedPartOSTA.get(curkey);
                           
                           /*System.debug('curVal:' + curVal);
                           System.debug('selVal:' + selVal);*/
                           
                           if(selVal == NULL && curVal != NULL) {
                               partsInvolved.add(curVal.Exam_Part_Number__c);
                               if(curVal.Exam_Part_Number__c == 1) {
                                   oppsInvolved.add(er1.Opportunity__c);
                               } else {
                                   oppsInvolved.add(er2.Opportunity__c);
                               }
                           }
                       }
                       //System.debug('partsInvolved:' + partsInvolved);
                       
                       Integer numberOfLocationRefunds = (totalCurrentPartWithOSTA - totalSelectedPartWithOSTA);
                       //System.debug('numberOfLocationRefunds :' + numberOfLocationRefunds);
                       if(partsInvolved.contains(1)) {
                           eaRefund = erm.Part_I_Exam_Registration__c;
                           if(erm.Part_II_Exam_Registration__c != NULL) {
                               eaRefundOther = erm.Part_II_Exam_Registration__c;
                           }
                       } else if(partsInvolved.contains(2)) {
                           eaRefund = erm.Part_II_Exam_Registration__c;
                           if(erm.Part_I_Exam_Registration__c != NULL) {
                               eaRefundOther = erm.Part_I_Exam_Registration__c;
                           }
                       }
                       
                       
                       /*system.debug('check this map'+examRegMap);
                       system.debug('check this map'+mapOpp);
                       system.debug('check this reg'+eaRefund);*/
                       // Issue Refund for eaRefund
                       if(eaRefund != NULL) {
                           Opportunity oppRefund = findRefundOpp(examRegMap.get(eaRefund),mapOpp,examRegMap);    
                          // System.debug('findRefundOpp:' + oppRefund);
                           
                           if(oppRefund == NULL && eaRefundOther != NULL) {                        
                               oppRefund = findRefundOpp(examRegMap.get(eaRefundOther),mapOpp,examRegMap);    
                              // System.debug('findRefundOpp Other:' + oppRefund);                        
                           }
                           
                           if(oppRefund != NULL) {
                               List<Product_Refunds__c> prs = issueProductRefund(oppRefund, 'CHLF',numberOfLocationRefunds);
                               productRefunds.addAll(prs);
                           } else {
                               AppError__c appError = new AppError__c();
                               appError.Error__c = 'No OSTA fee found to refund';
                               appError.Contact__c = contactID;
                               appError.Message__c = 'No OSTA fee found to refund';
                               appErrors.add(appError);
                           }
                           
                       }
                       
                       if(oppsInvolved.size() == 2 && numberOfLocationRefunds == 2) {
                           if(eaRefundOther != NULL) {  
                               Opportunity oppRefund = findRefundOpp(examRegMap.get(eaRefundOther),mapOpp,examRegMap);    
                               //System.debug('findRefundOpp Other:' + oppRefund);
                               
                               if(oppRefund != NULL) {
                                   List<Product_Refunds__c> prs = issueProductRefund(oppRefund.Id, 'CHLF',numberOfLocationRefunds);
                                   productRefunds.addAll(prs);
                               }
                           }
                       }
                   }
               }                   
        }
        
        if(!productRefunds.isEmpty()){
            insert productRefunds;
        }
        if(!appErrors.isEmpty()){
            insert appErrors;
        }
        if(!examRegModList.isEmpty()){
            update examRegModList;
        }
        
        if(!lstUpdateOtherExamRegistrations.isEmpty()) {
            update lstUpdateOtherExamRegistrations;
        }
        if(!lstAddOtherExamRegistrations.isEmpty()) {
            insert lstAddOtherExamRegistrations;
        }
        
        dmlListWrapper dmls = new dmlListWrapper();
        if(!contractsToInsert.isEmpty())
            dmls.contractsToInsert = contractsToInsert;
        if(!contractsToUpdate.isEmpty())
            dmls.contractsToUpdate = contractsToUpdate;
        if(!eaUpdates.isEmpty())
            dmls.examRegToUpdate = eaUpdates;
        return dmls;
    }
    
    
    public static List<Exam_Attempt__c > getExamResults(String contactId, String closedKey) {
    
        List<Exam_Attempt__c > examRegs = [
            SELECT 
            Id, 
            Name, 
            Cancelled__c,
            Opportunity__r.StageName,
            Attending_Exam_Name__c, 
            Other_Exam_Registrations__r.hasViolation__c, 
            Section__c,
            Section_Exam_Name__c, 
            Result__c, 
            Exam_Date__c, 
            Category_1__c, 
            hasViolation__c, 
            Quartile_1__c, 
            Category_2__c, 
            Quartile_2__c, 
            Category_3__c, 
            Quartile_3__c, 
            Category_4__c, 
            Quartile_4__c, 
            Category_5__c, 
            Quartile_5__c, 
            Category_6__c,
            Quartile_6__c, 
            Category_7__c, 
            Quartile_7__c, 
            Category_8__c, 
            Quartile_8__c, 
            Category_9__c, 
            Quartile_9__c,
            Re_score_Status__c,
            RPT_Exam_Mode__c,
            //Exam_Site__r.Exam__r.Exam_Group__r.Exam_Results_Available_Date__c,
            //Exam_Site__r.Exam__r.Exam_Group__r.Loading_Exam_Results__c,
            Exam_Administration__c,
            Exam_Administration__r.Exam_Results_Loading__c,
            Exam_Administration__r.Exam_Results_Release_Date__c,  
            Exam_Part__r.Exam_Results_Release_Date__c,
            RPT_Administration_Month__c,
            RPT_Administration_Year__c,
            RPT_Exam_Program__c,
            RPT_Exam_Part__c,
            Hide_Exam_Result__c
            FROM Exam_Attempt__c 
            WHERE 
            //Id = :examAttemptId AND 
            Member__c = :contactId AND
            Hide_Exam_Result__c = False AND
            Result__c != null AND Cancelled__c != TRUE AND
            Section__c in ('SCR','ERP','ERP1','ERP2','FRM Part 1','FRM Part 2','FRM Full Program','ERP Exam Part I','ERP Exam Part II')
        ];
        
        List<Exam_Attempt__c> returnExamRegs = new List<Exam_Attempt__c>();
        
        DateTime tdy = DateTime.Now();
        
        for(Exam_Attempt__c ea :examRegs) {
            
            // Get Exam Results Release Date        
            DateTime examResultsReleaseDate = ea.Exam_Administration__r.Exam_Results_Release_Date__c;
            if(ea.Exam_Part__r.Exam_Results_Release_Date__c != NULL) {
                examResultsReleaseDate = ea.Exam_Part__r.Exam_Results_Release_Date__c;
            }
            
            if((ea.Exam_Administration__c != NULL && !isLoadingResults(ea.Exam_Administration__r.Exam_Results_Loading__c, closedKey) &&
               (examResultsReleaseDate == NULL || tdy >= examResultsReleaseDate)) ||
               ea.Exam_Administration__c == NULL
            ) {
                returnExamRegs.add(ea);
            }
        }
        
        return returnExamRegs;
    }
    
    public static List<Product_Refunds__c> issueProductRefund(Opportunity opp, String prodCode, Integer part) {
        
        ChargentOrders__Transaction__c paymentTransaction = !opp.Transactions__r.isEmpty()?opp.Transactions__r[0]:null;
        Legacy_Transaction__c paymentLegacyTransaction = !opp.Legacy_Transactions__r.isEmpty()?opp.Legacy_Transactions__r[0]:null;
        List<Product_Refunds__c> prs = new List<Product_Refunds__c>();
        Integer cnt=1;
        for(OpportunityLineItem ol :opp.OpportunityLineItems) {
            if(ol.ProductCode == prodCode) {
                if(cnt <= part) {
                    Product_Refunds__c productRefund = new Product_Refunds__c();
                    productRefund.Payment_Order_Transaction__c    = null;
                    productRefund.Legacy_Transaction__c    = null;
                    productRefund.Status__c                 = 'Submitted';
                    productRefund.Product__c                = ol.Product2Id;
                    productRefund.Opportunity__c            = opp.Id;         
                    productRefund.Reason__c                 = ol.Description;
                    productRefund.Refund_Amount__c          = (ol.UnitPrice*ol.Quantity).setScale(2);
                    productRefund.Sales_Price__c            = (ol.UnitPrice*ol.Quantity).setScale(2);
                    productRefund.Opportunity_Product_ID__c = ol.Id;
                    if(paymentTransaction != null){
                        productRefund.Payment_Order_Transaction__c = paymentTransaction.Id;
                    }else if(paymentLegacyTransaction != null){
                        productRefund.Legacy_Transaction__c = paymentLegacyTransaction.Id;
                    }
                    prs.add(productRefund);                                    
                }
                cnt++;
            }
                
        }    
        return prs;
    }
    
    public static Opportunity findRefundOpp(Exam_Attempt__c ea,MAP<Id,Opportunity> mapOpp,Map<Id,Exam_Attempt__c> examRegMap) {
      
        Set<String> opIDs = new Set<String>();
        
        Exam_Attempt__c mainEA;
        mainEA=fetchExamRegistrationInContext(ea.Id);
        opIDs.add(mainEA.Opportunity__c);
        if(mainEA.Opportunity_Line_Items__r != NULL) {
            for(OpportunityLineItem oli :mainEA.Opportunity_Line_Items__r) {
                opIDs.add(oli.OpportunityId);    
            }
        }
        
        // Find Cloned EA
        Exam_Attempt__c clonedEA;
        if(ea.Cloned_From__c!=NULL) {
            clonedEA=examRegMap.get(ea.Cloned_From__c);
            if(clonedEA != NULL) {
                opIDs.add(clonedEA.Opportunity__c);
                if(clonedEA.Opportunity_Line_Items__r != NULL) {
                    for(OpportunityLineItem oli :clonedEA.Opportunity_Line_Items__r) {
                        opIDs.add(oli.OpportunityId);    
                    }                
                }
            }
        }
        
        for(Id oppId :opIDs) {
            Opportunity fndOpp = mapOpp.containsKey(oppId)?mapOpp.get(oppId):null;
            if(fndOpp != NULL) {
                for(OpportunityLineItem oli : fndOpp.OpportunityLineItems){
                    if(oli.ProductCode == 'CHLF' && fndOpp.Product_Refunds__r.isEmpty()){
                        return fndOpp;
                    }
                }
            }                
        }
        
        return NULL;
    }
    
    public class dmlListWrapper {
        public List<Contract> contractsToInsert;
        public List<Contract> contractsToUpdate;
        public List<Exam_Attempt__c> examRegToUpdate;
    } 
    
    public ExamManagementController(){}
    
}