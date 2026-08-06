/* Apex Controller for Accounting Export Page
 * General products are grouped by Company - GARP or GRA. Shipping Products will be split into specific items for accounting
 * 02/15/2019 Xiang - [US-17392] Seperate Individual Membership by Transaction Gateway
 * 03/04/2019 Xiang - Add Accounting GL Code, update Product Key logic, include transactions with no credit card type
 * 03/13/2019 Xiang - Add sorting to ExportData
 * 04/22/2019 Xiang - Change to use transaction gateway as company globally
 */
public without sharing class AccountingExportCtrl {
    
    // Data to be exported
    public List<ExportData> dataRows {get; private set;}
    public transient String csvString {get; set;}
    public Decimal creditTotal {get; private set;}
    public Decimal debitTotal {get; private set;}
    public Decimal netTotal {get; private set;}
    
    // Input dates
    public Date inptStDate {get; set;}
    public Date inptEdDate {get; set;}
    
    // Company Filter
    public String selectCompany {get; set;}
    public List<SelectOption> getCompanies() {
        List<SelectOption> options = new List<SelectOption>{new SelectOption('All', 'All'), new SelectOption('GARP', 'GARP'), new SelectOption('GRA', 'GRA')};
        return options;
    }
    
    // Indicators for user changed input without Refresh
    public Date lastStDate {get; set;}
    public Date lastEdDate {get; set;}
    public String lastCompany {get; set;}
    
    // Helper methods
    public static DateTime convertDate(Date inptDt) {
        return DateTime.newInstance(inptDt.year(), inptDt.month(), inptDt.day());
    }
    
    public static Date toDate(DateTime inptDt) {
        // formatGMT keeps the GMT date, format return locale date
        return Date.parse(inptDt.format('MM/dd/yyyy'));
    }
    
    // For debugging Product Key
    public Boolean getRenderKey() {
        return Default_Settings__c.getAll().get('EnableAcctExpProdKey') != null;
    }
    
    // Constructor
    // https://garp--preprod.cs66.my.salesforce.com/apex/AccountingExport
    public AccountingExportCtrl() {
        // Upon page load, display today's date with all company
        inptStDate = System.today();
        inptEdDate = System.today();
        
        selectCompany = lastCompany = 'All';
    }
    
    // Page action - Refresh
    public void refreshPage() {
        dataRows = new List<ExportData>();
        fetchDataByDate(inptStDate, inptEdDate, selectCompany);

        lastStDate = inptStDate; lastEdDate = inptEdDate;
        lastCompany = selectCompany;
    }
    
    // Page action - Export CSV
    public void exportCsv() {
        if(!lastStDate.isSameDay(inptStDate) || !lastEdDate.isSameDay(inptEdDate) || lastCompany != selectCompany) {
            refreshPage();
        }
        
        String csvStr = '"Effective Date","Name","Document Number","Transaction Description","Company Code","Department","Product Code","GL Code","GL Title","Amount","D/C"';
        
        if(!dataRows.isEmpty()) {
            // Line break delimiter to be replaced in Js base on OS
            csvStr += '_LB_';
            
            for(Integer i=0; i<dataRows.size(); i++) {
                ExportData row = dataRows[i];
                csvStr += ('"' + row.effectiveDate + '","' + row.name + '","' + row.documentNumber + '","' + row.transactionDescription + '","' + row.companyCode + '","' + row.department + '","' + row.productCode + '","' + row.GLCode + '","' + row.GLTitle + '","' + row.amount + '","' + row.amountType + '"');
            
                if(i != dataRows.size() - 1) csvStr += '_LB_';
            }
        }
        csvStr = csvStr.replaceAll('null', '');
        
        csvString = csvStr;
    }
    
    // Main method for exporting
    public void fetchDataByDate(Date stDate, Date edDate, String compFilter) {
        if(null != stDate && null != edDate && null != compFilter) {
           
           // this is to get the end of the month in days
         
           Integer numberOfDays = Date.daysInMonth(edDate.year(), edDate.month());
           string getDate = string.valueof(Date.newInstance(edDate.year(), edDate.month(), numberOfDays).day());
           //system.debug('getDate:'+getDate); 

            string edDateStr=null;
            
            String stDateStr = string.valueof( date.newinstance(stDate.year(), stDate.month(), stDate.day())) + 'T04:00:00z';
            edDateStr = string.valueof( date.newinstance(edDate.year(), edDate.month(), edDate.adddays(1).day())) + 'T05:00:00z';
          
            // this is for the end of the month 
            if(  string.valueof(edDate.day())==getDate && edDate.month()!=12)
           
            edDateStr = string.valueof( date.newinstance(edDate.year(), edDate.addMonths(1).month(), edDate.adddays(1).day())) + 'T05:00:00z';  
          
           // this is if it is end of the year date
            if( edDate.month()==12&& edDate.day()==31)
           
            edDateStr = string.valueof( date.newinstance(edDate.addyears(1).year(), edDate.addMonths(1).month(), edDate.adddays(1).day())) + 'T05:00:00z';           
            
            //system.debug('stDateStrvivek:'+stDateStr);
            //system.debug('edDateStrvivek:'+edDateStr);
            
            String transQry = 'FROM ChargentOrders__Transaction__c ' +
                              'WHERE ChargentOrders__Response_Status__c = \'Approved\' AND ChargentOrders__Type__c IN (\'Charge\', \'Refund\') AND ChargentOrders__Payment_Method__c IN (\'Credit Card\') ' +
                              'AND ChargentOrders__Gateway_Date__c >= ' + stDateStr + ' AND ChargentOrders__Gateway_Date__c <= ' + edDateStr;
            AggregateResult[] ar = (AggregateResult[])Database.query('SELECT COUNT(Id) c ' + transQry);
            Integer transCount = (Integer)ar[0].get('c');
            
            
            
            // With 5k transactions total 30k rows are fetched. Over 9k transactions will very likely exceed 50k rows limit
            if(transCount > 9000 && !stDate.isSameDay(edDate)) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'Too many records have been selected. Please narrow the date range and try again.'));
                return;
            }
            
            // Get approved credit card transactions within input date range - Credit Card By Fax not inlcuded
            List<ChargentOrders__Transaction__c> trans = (List<ChargentOrders__Transaction__c>)Database.query('SELECT Id,Opportunity__c, ChargentOrders__Type__c, ChargentOrders__Gateway__r.Name, ChargentOrders__Gateway_Date__c, ChargentOrders__Credit_Card_Type__c, ChargentOrders__Amount__c ' + transQry);
            
            creditTotal = debitTotal = netTotal = 0;
            
            if(trans.size() > 0) {
               // System.debug('Queried Transaction size: ' + trans.size());
                
                // Final results for export
                dataRows = new List<ExportData>();
                
                Set<String> compNames = compFilter == 'All' ?  new Set<String>{'GARP', 'GRA'} : new Set<String>{compFilter};
                
                // Get targeted Transaction Ids and Opportuntiy Ids
                Set<Id> chargeOppIds = new Set<Id>();
                Map<Id, List<ChargentOrders__Transaction__c>> oppIdToChargeTrans = new Map<Id, List<ChargentOrders__Transaction__c>>();
                Set<Id> refundTransIds = new Set<Id>(); Set<Id> refundOppIds = new Set<Id>();
                
                Integer targetTransSize = 0;
                
                // Type can be: Charge, Refund, Credit, Debit (Credit/Debit not included in this report)
                for(ChargentOrders__Transaction__c oneTran : trans) {
                    Date transDate = oneTran.ChargentOrders__Gateway_Date__c.date();
                    
                    //system.debug('transDate:'+transDate);
                    
                    // Filter only targeted transactions
                    if(transDate >= stDate && transDate <= edDate) {
                        if(oneTran.ChargentOrders__Type__c == 'Charge') {
                            Id tranOppId = oneTran.Opportunity__c;
                            chargeOppIds.add(tranOppId);
                            
                            List<ChargentOrders__Transaction__c> transOnOpp = oppIdToChargeTrans.get(tranOppId);
                            if(null == transOnOpp) {
                                oppIdToChargeTrans.put(tranOppId, new List<ChargentOrders__Transaction__c>{oneTran});
                            }else {
                                transOnOpp.add(oneTran);
                            }
                        }else if(oneTran.ChargentOrders__Type__c == 'Refund') {
                            refundTransIds.add(oneTran.Id);
                            refundOppIds.add(oneTran.Opportunity__c);
                        }
                        
                        targetTransSize++;
                    }
                }
                
                //System.debug('Targeted Transaction size: ' + targetTransSize);
                
                // Query Data
                Id autoRecId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('Automated').getRecordTypeId();
                
                List<Opportunity> oppty = [SELECT Id, Amount,
                                           (SELECT Id, TotalPrice, Description, OpportunityId, Product2Id, Product2.ProductCode, Product2.Company__c, Product2.GL_Code__c, Product2.Acct_Sort_Order__c,
                                           Product2.Acct_Dept_Code__c, Product2.Acct_Prod_Code__c, Product2.Acct_GL_Code__c, Product2.Acct_GL_Short_Title__c FROM OpportunityLineItems ORDER BY Product2.Name ASC)
                                           FROM Opportunity WHERE Id IN :chargeOppIds AND RecordTypeId = :autoRecId AND Inst_Sale_Opp__c = null ORDER BY CloseDate ASC NULLS LAST];
                //System.debug('oppty size: ' + oppty.size());
                
                List<Product_Refunds__c> refunds = [SELECT Id, Refund_amount__c, Opportunity__c, Product__c, Payment_Order_Transaction__c, Payment_Order_Transaction__r.ChargentOrders__Gateway__r.Name, Payment_Order_Transaction__r.ChargentOrders__Gateway_Date__c, Payment_Order_Transaction__r.ChargentOrders__Credit_Card_Type__c, 
                                                    Product__r.ProductCode, Product__r.Company__c, Product__r.GL_Code__c, Product__r.Acct_Sort_Order__c, Product__r.Acct_Dept_Code__c, Product__r.Acct_Prod_Code__c, Product__r.Acct_GL_Code__c, Product__r.Acct_GL_Short_Title__c,
                                                    Product__r.Refund_GL_Code__c, Product__r.Refund_Product_Code__c
                                                    FROM Product_Refunds__c WHERE Payment_Order_Transaction__c IN :refundTransIds ORDER BY CreatedDate ASC];
                //System.debug('refunds size: ' + refunds.size());
                                                    
                Map<Id, Opportunity> refundOpps = new Map<Id, Opportunity>([SELECT Id, (SELECT Id, Product2Id, Product2.ProductCode, Description FROM OpportunityLineItems) FROM Opportunity WHERE Id IN :refundOppIds]);
                
                // Use Gateway info on transaction to determin which report should Membership product display
                Map<Id, String> opptyIdToGateway = new Map<Id, String>();
                // Group Opportunity by Transaction Gateway Date (CloseDate can also be used with real data)
                Map<Date, List<Opportunity>> dateToOppty = new Map<Date, List<Opportunity>>();
                
                for(Opportunity oneOpp : oppty) {
                    List<ChargentOrders__Transaction__c> oppTrans = oppIdToChargeTrans.get(oneOpp.Id);
                    
                    // Only when in same period multiple approved charge Transaction appeared on one Opportunity
                    if(oppTrans.size() > 1) {
                        //System.debug(oneOpp.Id + ' - ' + oppTrans);
                        // Get the total transaction amounts and multiple the ratio to all items
                        Decimal transAmt = 0;
                        for(ChargentOrders__Transaction__c oneTran : oppTrans) {
                            transAmt += oneTran.ChargentOrders__Amount__c;
                        }
                        
                        Decimal ratio = (transAmt/oneOpp.Amount).setScale(2);
                        for(OpportunityLineItem oli : oneOpp.OpportunityLineItems) {
                            oli.TotalPrice = oli.TotalPrice * ratio;
                        }
                    }
                    
                    ChargentOrders__Transaction__c tran = oppTrans[0];
                    
                    String gatewayName = tran.ChargentOrders__Gateway__r.Name;
                    opptyIdToGateway.put(oneOpp.Id, gatewayName == 'paypal gra' ? 'GRA' : 'GARP');
                    
                    Date tranDate = tran.ChargentOrders__Gateway_Date__c.date();
                    //system.debug('tranDate:'+tranDate);
                    List<Opportunity> oppOnDate = dateToOppty.get(tranDate);
                    if(null == oppOnDate) {
                        dateToOppty.put(tranDate, new List<Opportunity>{oneOpp});
                    }else {
                        oppOnDate.add(oneOpp);
                    }
                }
                
                // Group Refund by Transaction Gateway Date
                Map<Date, List<Product_Refunds__c>> dateToRefunds = new Map<Date, List<Product_Refunds__c>>();
                for(Product_Refunds__c oneRefund : refunds) {
                    Date refundDate = oneRefund.Payment_Order_Transaction__r.ChargentOrders__Gateway_Date__c.date();
                    //system.debug('refundDate:'+refundDate);
                    List<Product_Refunds__c> refundOnDate = dateToRefunds.get(refundDate);
                    
                    if(null == refundOnDate) {
                        dateToRefunds.put(refundDate, new List<Product_Refunds__c>{oneRefund});
                    }else {
                        refundOnDate.add(oneRefund);
                    }
                }
                
                // Get all Dates and sort in ASC order
                Set<Date> allDates = new Set<Date>(dateToOppty.keySet());
                allDates.addAll(dateToRefunds.keySet());
                List<Date> transDateList = new List<Date>(allDates);
                transDateList.sort();
                
                for(Date effDate : transDateList) {
                    List<Opportunity> oppsInOneDate = dateToOppty.get(effDate);
                    List<Product_Refunds__c> refundsInOneDate = dateToRefunds.get(effDate);
                    
                    // On one date, group Products (Including specified shipping products) by Card Type
                    Map<String, List<ProductInfo>> cardNameToItems = new Map<String, List<ProductInfo>>{'American Express'=>new List<ProductInfo>(), 'First Data'=>new List<ProductInfo>(), 'Other'=>new List<ProductInfo>()};
                    if(null != oppsInOneDate) {                    
                        for(Opportunity opp : oppsInOneDate) {
                            // Usually One Charge Transaction per Invoice (Opportunity) - Besides Refund/Error/Decline...
                            String cardName = getCardName(oppIdToChargeTrans.get(opp.Id)[0].ChargentOrders__Credit_Card_Type__c);

                            cardNameToItems.get(cardName).addAll(processProducts(opp.OpportunityLineItems, compNames, opptyIdToGateway));
                        }
                    }
                    
                    // On one date, group Refunds by Card Type
                    Map<String, List<ProductInfo>> cardNameToRefunds = new Map<String, List<ProductInfo>>{'American Express'=>new List<ProductInfo>(), 'First Data'=>new List<ProductInfo>(), 'Other'=>new List<ProductInfo>()};
                    if(null != refundsInOneDate) {
                        for(Product_Refunds__c refundOnDate : refundsInOneDate) {
                            String cardName = getCardName(refundOnDate.Payment_Order_Transaction__r.ChargentOrders__Credit_Card_Type__c);
                            
                            cardNameToRefunds.get(cardName).addAll(processRefund(refundOnDate, refundOpps, compNames));
                        }
                    }
                    
                    // Aggregate Products
                    for(String cardName : new List<String>{'American Express', 'First Data', 'Other'}) {
                        //System.debug(effDate + ' - ' + cardName + ' - Product size: ' + cardNameToItems.get(cardName).size());
                        //System.debug(effDate + ' - ' + cardName + ' - Refund size: ' + cardNameToRefunds.get(cardName).size());
                        
                        // Adding all Line Items
                        Map<String, LineItemInfo> prodKeyToAmount = new Map<String, LineItemInfo>();
                        for(ProductInfo prodItem : cardNameToItems.get(cardName)) {
                            String itemKey;
                            
                            if(!prodItem.isShipping) {
                                // Regular Products - Use OpportunityLineItem
                                OpportunityLineItem item = prodItem.lineItem;
                                
                                itemKey = getProductKey(item, null, prodItem.compName);
                                
                                LineItemInfo prodInfo = prodKeyToAmount.get(itemKey);
                                if(null == prodInfo) {
                                    prodKeyToAmount.put(itemKey, new LineItemInfo(item, item.TotalPrice, prodItem.compName));
                                }else {
                                    prodInfo.totalAmount += item.TotalPrice;
                                }
                            }else {
                                // Shipping Products - Use Inner Class
                                itemKey = prodItem.productKey + '_' + prodItem.compName;

                                LineItemInfo prodInfo = prodKeyToAmount.get(itemKey);
                                if(null == prodInfo) {
                                    prodKeyToAmount.put(itemKey, new LineItemInfo(prodItem, prodItem.shippingSplit));
                                }else {
                                    prodInfo.totalAmount += prodItem.shippingSplit;
                                }
                            }
                        }
                        
                        for(String prodKey : prodKeyToAmount.keySet()) {
                            LineItemInfo oneItem = prodKeyToAmount.get(prodKey);
                            
                            if(oneItem.totalAmount != 0) {
                                ExportData dataRow = new ExportData(effDate, cardName, oneItem);
                                dataRow.prodKey = prodKey;
                                dataRows.add(dataRow);
                                
                                if(null != oneItem.lineItem && scholarshipProdCodes.contains(oneItem.lineItem.Product2.ProductCode)) {
                                    debitTotal += Math.abs(oneItem.totalAmount);
                                }else {
                                    creditTotal += oneItem.totalAmount;
                                }
                            }
                        }
                        
                        // Adding all Refunds
                        Map<String, LineItemInfo> prodKeyToRefundAmt = new Map<String, LineItemInfo>();
                        for(ProductInfo refundItem : cardNameToRefunds.get(cardName)) {
                            String refundKey;
                            
                            if(!refundItem.isShipping) {
                                Product_Refunds__c refund = refundItem.refund;
                                
                                refundKey = getProductKey(null, refund, refundItem.compName);
                                
                                LineItemInfo refundInfo = prodKeyToRefundAmt.get(refundKey);
                                if(null == refundInfo) {
                                    prodKeyToRefundAmt.put(refundKey, new LineItemInfo(refund, refund.Refund_amount__c, refundItem.compName));
                                }else {
                                    refundInfo.totalAmount += refund.Refund_amount__c;
                                }
                            }else {
                                // Shipping Products - Use Inner Class
                                refundKey = refundItem.productKey + '_' + refundItem.compName;
                                
                                LineItemInfo refundInfo = prodKeyToRefundAmt.get(refundKey);
                                if(null == refundInfo) {
                                    prodKeyToRefundAmt.put(refundKey, new LineItemInfo(refundItem, refundItem.shippingSplit));
                                }else {
                                    refundInfo.totalAmount += refundItem.shippingSplit;
                                }
                            }
                        }
                        
                        for(String refundKey : prodKeyToRefundAmt.keySet()) {
                            LineItemInfo oneRefund = prodKeyToRefundAmt.get(refundKey);
                            if(oneRefund.totalAmount != 0) {
                                ExportData dataRow = new ExportData(effDate, cardName, oneRefund);
                                dataRow.prodKey = refundKey;
                                dataRows.add(dataRow);
                                
                                debitTotal += oneRefund.totalAmount;
                            }
                        }

                        dataRows.sort();
                    }
                }

                netTotal = creditTotal - debitTotal;
            }
        }
    }
    
    // For Grouping Products with different ProductCode but are identical Products in Accounting System
    @TestVisible private String getProductKey(OpportunityLineItem oli, Product_Refunds__c refund, String company) {
        Product2 prod; 
        String productKey;
        
        // Default Key: Product2 Id
        if(null != oli) {
            prod = oli.Product2;
            productKey = oli.Product2Id;
        }else if(null != refund) {
            prod = refund.Product__r;
            productKey = refund.Product__c;
        }
        
        // When having Accounting GL Code, use combined Acct GL/Prod Code for merging
        if(null != prod.Acct_GL_Code__c && null != prod.Acct_Prod_Code__c) {
            productKey = prod.Acct_GL_Code__c + '_' + prod.Acct_Prod_Code__c;
        }

        // Indicates transaction company
        productKey += '_' + company;

        return productKey;
    }
    
    // Setup Products from Custom Metadata
    public static Map<String, Temp_Product__mdt> tmpProdMap {
        get {
            if(null == tmpProdMap) {
                tmpProdMap = new Map<String, Temp_Product__mdt>();
                for(Temp_Product__mdt tmpProd : [SELECT DeveloperName, Company__c, Department__c, GL_Code__c, Product_Code__c, GL_Short_Title__c, Refund_GL_Code__c, Refund_Product_Code__c, Sort_Order__c FROM Temp_Product__mdt]) {
                    tmpProdMap.put(tmpProd.DeveloperName, tmpProd);
                }
            }
            return tmpProdMap;
        }
        private set;
    }
    
    // Exam/Book's ProductCode to Shipping Product
    // Key - Book/Exam Product's ProductCode, Value - Shipping Product with Acct_Prod_Code__c
    @TestVisible private static ProductInfo newShipProd(String prodCode) {
        switch on prodCode {
            when 'ENC1B'
                {return new ProductInfo(tmpProdMap.get('ERP_1_Book_Ship'));}     // ERP Exam Part I Books
            when 'ENC2B'
                {return new ProductInfo(tmpProdMap.get('ERP_2_Book_Ship'));}     // ERP Exam Part II Books
            when 'FCBR', 'FBRNM', 'FBRHB'
                {return new ProductInfo(tmpProdMap.get('FFR_ExamBook_Ship'));}   // (FFR) Foundations of Financial Risk, Foundations of Financial Risk (Non Member), Foundations of Financial Risk Handbook
            when 'FRM1H', 'FRM1N'
                {return new ProductInfo(tmpProdMap.get('FRM_1_Book_Ship'));}     // FRM Exam Part I Books
            when 'FRM2H', 'FRM2N'
                {return new ProductInfo(tmpProdMap.get('FRM_2_Book_Ship'));}     // FRM Exam Part II Books
            when 'CBR', 'CBRNM', 'CBR2A', 'CBRHB'
                {return new ProductInfo(tmpProdMap.get('FRR_ExamBook_Ship'));}   // (FRR) Risk & Regulations, Risk & Regulations (Non Member), Risk & Regulations (2nd Attempt, maybe deprecated), Risk & Regulations Handbooks
            when 'SCRH'
                {return new ProductInfo(tmpProdMap.get('SCR_ExamBook_Ship'));}
            when else
                {return null;}
        }
    }
    
    // Exam/Book's ProductCode to Weight
    @TestVisible private static Map<String, Decimal> prodToWeightMap {
        get {
            if(prodToWeightMap == null) {
                prodToWeightMap = new Map<String, Decimal>();
                List<Product2> shipProds = [SELECT ProductCode, Weight__c FROM Product2 WHERE ProductCode IN ('ENC1B', 'ENC2B','SCRH' ,'FCBR', 'FBRNM', 'FBRHB', 'FRM1H', 'FRM1N', 'FRM2H', 'FRM2N', 'CBR', 'CBRNM', 'CBR2A', 'CBRHB')];
                for(Product2 oneProd : shipProds) {
                    prodToWeightMap.put(oneProd.ProductCode, oneProd.Weight__c);
                }
            }
            return prodToWeightMap;
        }
        set;
    }
    
    // Free Products to Skip
    private static Set<String> freeProdsForGarp = new Set<String>{'MEMF','MEMx','AFREE'};

    // Scholarship Products
    private static Set<String> scholarshipProdCodes = new Set<String>{'SAERP1','SAERP2','SAFRM1','SAFRM2'};

    // Certifiate/Individual/Student Membership Products
    private static Set<String> memberProdCodes = new Set<String>{'MEMC','MEMI','MEMS'};
    
    // Wrap LineItem into ProductInfo. Split general Shipping Product into specific Shipping Products base on sibling products.
    private List<ProductInfo> processProducts(List<OpportunityLineItem> oliList, Set<String> compNames, Map<Id, String> oppIdtoGateway) {
        List<ProductInfo> allProds = new List<ProductInfo>();
        List<ProductInfo> shippingProds = new List<ProductInfo>();
        OpportunityLineItem shippingItem = null;
        
        for(OpportunityLineItem oneItem : oliList) {
            String prodCode = oneItem.Product2.ProductCode;

            if(prodCode != 'SHIP') {
                // Skip Free Products
                if(!freeProdsForGarp.contains(prodCode)) {
                    // Gateway on transaction. Use as package (Opportunity) Company
                    String transComp = oppIdtoGateway.get(oneItem.OpportunityId);

                    if('MISC' == prodCode) {
                        allProds.addAll(processMiscProd(oneItem, oliList, compNames, transComp));
                    }else {
                        if(compNames.contains(transComp)) {
                            ProductInfo oneProd = new ProductInfo(oneItem);
                            oneProd.compName = transComp;
                            allProds.add(oneProd);
                        
                            getShipProductByCode(prodCode, shippingProds, transComp);
                        }
                    }
                }
            }else {
                // Usually only one shipping product per Opportunity (Invoice)
                shippingItem = oneItem;
            }
        }
        
        if(null != shippingItem) {
            String shippingCompany = oppIdtoGateway.get(shippingItem.OpportunityId);
            
            if(compNames.contains(shippingCompany)) {
                if(!shippingProds.isEmpty()) {
                    calculateShipping(shippingProds, shippingItem, null);
                    allProds.addAll(shippingProds);
                }else {
                    ProductInfo unknownShip = new ProductInfo(shippingItem);
                    unknownShip.compName = shippingCompany;
                    allProds.add(unknownShip);
                }
            }
        }
        
        return allProds;
    }
    
    // Process and divide MISC Product base on description - Sort Order for Miscellaneous is 54
    private static List<ProductInfo> processMiscProd(OpportunityLineItem oli, List<OpportunityLineItem> oliList, Set<String> compNames, String gateway) {
        List<ProductInfo> prods = new List<ProductInfo>();
        
        if(compNames.contains(gateway)) {
            String prodDesc = oli.Description;

            switch on prodDesc {
                when 'FRM Certificate Replacement', 'ERP Certificate Replacement' {
                    // When ERP Certificate, actual product is MISC and Company is GARP, charges to GARP paypal gateway
                    ProductInfo miscCert = new ProductInfo(tmpProdMap.get('MISC_FRM_Cert'), oli.TotalPrice, false);
                    miscCert.compName = gateway;
                    prods.add(miscCert);
                }
                when 'Canadian Customs Duty' {
                    // Add duty amount to shipping amount, shipping product is filtered and processed later.
                    for(OpportunityLineItem oneItem : oliList) {
                        if(oneItem.Product2.ProductCode == 'SHIP') {
                            oneItem.TotalPrice += oli.TotalPrice;
                            break;
                        }
                    }
                }
                when else {
                    // No related Product found
                    ProductInfo miscOther = new ProductInfo(tmpProdMap.get('MISC_Other'), oli.TotalPrice, false);
                    miscOther.compName = gateway;
                    prods.add(miscOther);
                }
            }
        }

        return prods;
    }
    
    // If refund is for shipping, get OpportunityLineItems from refund's Opportunity and decide Product Codes, then split shipping refund.
    private static List<ProductInfo> processRefund(Product_Refunds__c refund, Map<Id, Opportunity> refundOpps, Set<String> compNames) {
        String prodCode = refund.Product__r.ProductCode;
        String gwName = refund.Payment_Order_Transaction__r.ChargentOrders__Gateway__r.Name == 'paypal gra' ? 'GRA' : 'GARP';
        
        if(prodCode != 'SHIP') {
            if(prodCode == 'MISC') {
                return processRefundMisc(refund, refundOpps, compNames, gwName);
            }else {
                List<ProductInfo> prods = new List<ProductInfo>();

                // Skip Free Products
                if(!freeProdsForGarp.contains(prodCode)) {
                    if(compNames.contains(gwName)) {
                        ProductInfo oneRefund = new ProductInfo(refund);
                        oneRefund.compName = gwName;
                        prods.add(oneRefund);
                    }
                }
                
                return prods;
            }
        }else {
            List<ProductInfo> shippingProds = new List<ProductInfo>();
            
            if(compNames.contains(gwName)) {
                for(OpportunityLineItem lineItem : refundOpps.get(refund.Opportunity__c).OpportunityLineItems) {
                    String sibProdCode = lineItem.Product2.ProductCode;
                    if(sibProdCode != 'SHIP') {
                        getShipProductByCode(sibProdCode, shippingProds, gwName);
                    }
                }
                
                calculateShipping(shippingProds, null, refund);
            }
            
            return shippingProds;
        }
    }

    private static List<ProductInfo> processRefundMisc(Product_Refunds__c refund, Map<Id, Opportunity> refundOpps, Set<String> compNames, String gwName) {
        List<ProductInfo> miscProds = new List<ProductInfo>();
        
        if(compNames.contains(gwName)) {
            for(OpportunityLineItem refundItem : refundOpps.get(refund.Opportunity__c).OpportunityLineItems) {
                if(refundItem.Product2Id == refund.Product__c) {
                    String prodDesc = refundItem.Description;

                    switch on prodDesc {
                        when 'FRM Certificate Replacement', 'ERP Certificate Replacement' {
                            ProductInfo miscCert = new ProductInfo(tmpProdMap.get('MISC_FRM_Cert'), refund.Refund_amount__c, true);
                            miscCert.compName = gwName;
                            miscProds.add(miscCert);
                        }
                        when 'Canadian Customs Duty' {
                            for(OpportunityLineItem lineItem : refundOpps.get(refund.Opportunity__c).OpportunityLineItems) {
                                String sibProdCode = lineItem.Product2.ProductCode;
                                if(sibProdCode != 'SHIP') {
                                    getShipProductByCode(sibProdCode, miscProds, gwName);
                                }
                            }
                            calculateShipping(miscProds, null, refund);
                        }
                        when else {
                            ProductInfo miscOther = new ProductInfo(tmpProdMap.get('MISC_Other'), refund.Refund_amount__c, true);
                            miscOther.compName = gwName;
                            miscProds.add(miscOther);
                        }
                    }
                }
            }
        }
        
        return miscProds;
    }
    
    // Use sibling products to decide which shipping product to use
    private static void getShipProductByCode(String prodCode, List<ProductInfo> shippingProds, String company) {
        ProductInfo tmpShip = newShipProd(prodCode);
        
        if(null != tmpShip) {
            tmpShip.weight = prodToWeightMap.get(prodCode);
            tmpShip.compName = company;
            shippingProds.add(tmpShip);
        }
    }
    
    // Calculate amount base on weight. All shipping ProductInfo point to same OpportunityLineItem/Product_Refunds.
    private static void calculateShipping(List<ProductInfo> shippingProds, OpportunityLineItem shippingItem, Product_Refunds__c refund) {
        Decimal totalWeight = 0;
        for(ProductInfo oneShip : shippingProds) { totalWeight += oneShip.weight; }
        
        Decimal shipTotalAmt = shippingItem != null ? shippingItem.TotalPrice : refund.Refund_amount__c;
        
        for(ProductInfo oneShip : shippingProds) {
            oneShip.shippingSplit = (shipTotalAmt * oneShip.weight / totalWeight).setScale(2);
            oneShip.lineItem = shippingItem;
            oneShip.refund = refund;
            oneShip.isRefund = (refund != null);
        }
    }
    
    // Inner class for data grouping
    // For coordinating Regular Product and Shipping Product
    public class ProductInfo {
        // All ProductInfo need to set this to indicate on which report (GARP/GRA) to show, base on transaction gateway
        public String compName {get; private set;}

        public OpportunityLineItem lineItem {get; private set;}
        public Product_Refunds__c refund {get; private set;}

        // For tmp Products only
        public String productKey {get; private set;}
        public String productComp {get; private set;}
        public String departCode {get; private set;}
        public String glCode {get; private set;}
        public String prodCode {get; private set;}
        public String glTitle {get; private set;}
        public String refundGLCode {get; private set;}
        public String refundProdCode {get; private set;}
        public Integer sortOrder {get; private set;}
        
        // For shipping Products
        public Boolean isShipping {get; private set;}
        public Decimal weight {get; private set;}
        public Decimal shippingSplit {get; private set;}
        
        // Needed only when LineItemInfo is using values from ProductInfo
        public Boolean isRefund {get; private set;}
        
        public ProductInfo(OpportunityLineItem lineItem) {
            this.lineItem = lineItem;
            this.isShipping = false;
            this.isRefund = false;
        }
        
        public ProductInfo(Product_Refunds__c refund) {
            this.refund = refund;
            this.isShipping = false;
            this.isRefund = true;
        }
        
        // This approach is for Shipping Products only
        public ProductInfo(Temp_Product__mdt shipProd) {
            this.productKey = shipProd.DeveloperName;
            
            this.productComp = shipProd.Company__c;
            this.departCode = shipProd.Department__c;
            this.glCode = shipProd.GL_Code__c;
            this.prodCode = shipProd.Product_Code__c;
            this.glTitle = shipProd.GL_Short_Title__c;
            this.refundGLCode = shipProd.Refund_GL_Code__c;
            this.refundProdCode = shipProd.Refund_Product_Code__c;
            this.sortOrder = (Integer)shipProd.Sort_Order__c;
            
            this.isShipping = true;
        }
        
        // This approach is for Misc Products only - handled as shipping products
        public ProductInfo(Temp_Product__mdt tmpProd, Decimal split, Boolean isRefund) {
            this.productKey = tmpProd.DeveloperName;
            
            this.productComp = tmpProd.Company__c;
            this.departCode = tmpProd.Department__c;
            this.glCode = tmpProd.GL_Code__c;
            this.prodCode = tmpProd.Product_Code__c;
            this.glTitle = tmpProd.GL_Short_Title__c;
            this.refundGLCode = tmpProd.Refund_GL_Code__c;
            this.refundProdCode = tmpProd.Refund_Product_Code__c;
            this.sortOrder = (Integer)tmpProd.Sort_Order__c;
            
            this.shippingSplit = split;
            this.isRefund = isRefund;
            
            this.isShipping = true;
        }
    }
    
    // For holding product info and total amount
    public class LineItemInfo {
        public OpportunityLineItem lineItem {get; private set;}
        public Product_Refunds__c refund {get; private set;}
        public ProductInfo prodInfo {get; private set;}
        
        public String transCompany {get; private set;}
        public Decimal totalAmount {get; private set;}
        
        public LineItemInfo(OpportunityLineItem lineItem, Decimal totalAmount, String compName) {
            this.lineItem = lineItem;
            this.totalAmount = totalAmount;
            this.transCompany = compName;
        }
        
        public LineItemInfo(Product_Refunds__c refund, Decimal totalAmount, String compName) {
            this.refund = refund;
            this.totalAmount = totalAmount;
            this.transCompany = compName;
        }
        
        // This approach is for Shipping Products only
        public LineItemInfo(ProductInfo prodInfo, Decimal totalAmount) {
            this.prodInfo = prodInfo;
            this.totalAmount = totalAmount;
            this.transCompany = prodInfo.compName;
        }
    }
    
    public class ExportData implements Comparable {
        public String prodKey {get; private set;}
        
        public String effectiveDate {get; private set;}
        public String name {get; private set;}
        public String documentNumber {get; private set;}
        public String transactionDescription {get; private set;}
        public String companyCode {get; private set;}
        public String department {get; private set;}
        public String productCode {get; private set;}
        public String GLCode {get; private set;}
        public String GLTitle {get; private set;}
        public Decimal amount {get; private set;}
        public String amountType {get; private set;}
        
        public Integer sortCode {get; private set;}
        
        public ExportData(Date effDate, String cardName, LineItemInfo oneItem) {
            DateTime effDateTime = convertDate(effDate);
            
            this.effectiveDate = effDateTime.format('MM/dd/yyyy');
            this.name = cardName;
            
            OpportunityLineItem oli = oneItem.lineItem;
            ProductInfo prodInfo = oneItem.prodInfo;
            Product_Refunds__c refund = oneItem.refund;
            
            String transComp = oneItem.transCompany;
            Boolean isRefund = false;

            if(oli != null) {
                this.department = oli.Product2.Acct_Dept_Code__c;
                this.productCode = oli.Product2.Acct_Prod_Code__c;
                this.GLCode = null != oli.Product2.Acct_GL_Code__c ? oli.Product2.Acct_GL_Code__c : oli.Product2.GL_Code__c;
                this.GLTitle = oli.Product2.Acct_GL_Short_Title__c;

                // Always treat Scholarship as Debit
                if(scholarshipProdCodes.contains(oli.Product2.ProductCode)) {
                    this.amount = Math.abs(oneItem.totalAmount);
                    this.amountType = 'D';
                }else {
                    this.amount = oneItem.totalAmount;
                    this.amountType = 'C';
                }
                
                this.sortCode = null != oli.Product2.Acct_Sort_Order__c ? oli.Product2.Acct_Sort_Order__c.intValue() : 1000;
            }else if(refund != null) {
                isRefund = true;

                this.department = refund.Product__r.Acct_Dept_Code__c;
                // Refund Product Code/GL Code override. Override priority: Refund GL Code > Acct GL Code > GL Code.
                this.productCode = null != refund.Product__r.Refund_Product_Code__c ? refund.Product__r.Refund_Product_Code__c : refund.Product__r.Acct_Prod_Code__c;
                String refundGLCode = refund.Product__r.Refund_GL_Code__c;
                if(null == refundGLCode) {
                    refundGLCode = null != refund.Product__r.Acct_GL_Code__c ? refund.Product__r.Acct_GL_Code__c : refund.Product__r.GL_Code__c;
                }
                this.GLCode = refundGLCode;
                this.GLTitle = getRefundMemberGLTitle(refund);

                this.amount = oneItem.totalAmount;
                this.amountType = 'D';
                
                this.sortCode = null != refund.Product__r.Acct_Sort_Order__c ? refund.Product__r.Acct_Sort_Order__c.intValue() : 1000;
            }else if(prodInfo != null) {
                // This approach is for Shipping/MISC Products only, currently not supporting refund GL/Product code override
                isRefund = prodInfo.isRefund;

                this.department = prodInfo.departCode;
                this.productCode = prodInfo.prodCode;
                this.GLCode = prodInfo.glCode;
                this.GLTitle = prodInfo.glTitle;
                
                this.amount = oneItem.totalAmount;
                if(isRefund) {
                    this.amountType = 'D';

                    if(null != prodInfo.refundProdCode) { this.productCode = prodInfo.refundProdCode; }
                    if(null != prodInfo.refundGLCode) { this.GLCode = prodInfo.refundGLCode; }
                }else {
                    this.amountType = 'C';
                }
                
                this.sortCode = prodInfo.sortOrder;
            }

            this.documentNumber = getDocNumber(effDateTime, cardName, isRefund, transComp == 'GRA');
            this.companyCode = getCompanyCode(transComp);
            this.transactionDescription = (this.companyCode == '12' ? 'GRA' : 'GARP') + ' Daily Report - ' + effDateTime.format('MM/dd/yyyy');
            
            if(null == this.sortCode) this.sortCode = 1000;
        }
        
        // Compare With: Date - Card - Charge/Refund - Acct_Sort_Order__c
        public Integer compareTo(Object compareTo) {
            ExportData compData = (ExportData)compareTo;
            
            if(this.effectiveDate == compData.effectiveDate) {
                if(this.name == compData.name) {
                    if(this.amountType == compData.amountType) {
                        if(this.sortCode == compData.sortCode && compData.GLCode != null && this.GLCode != null) {
                            return this.GLCode.compareTo(compData.GLCode);
                        }else {
                            return this.sortCode - compData.sortCode;
                        }
                    }else {
                        return this.amountType.compareTo(compData.amountType);
                    }
                }else {
                    return this.name.compareTo(compData.name);
                }
            }else {
                return this.effectiveDate.compareTo(compData.effectiveDate);
            }
        }
    }
    
    // Util Methods for report data construction
    public static String getCardName(String inptCardType) {
        String cardName = null;
        
        if(inptCardType == 'AMEX' || inptCardType == 'American Express') {
            cardName = 'American Express';   
        }else if(inptCardType == 'Visa' || inptCardType == 'Mastercard' || inptCardType == 'MC'|| inptCardType == 'DC'|| inptCardType == 'DS') {
            cardName = 'First Data';
        }else {
            cardName = 'Other';
        }
        
        return cardName;
    }
    
    public static String getDocNumber(DateTime efDateTime, String cardName, Boolean isRefund, Boolean isGRA) {
        String docNumber = null;
        
        if(cardName == 'American Express') {
            docNumber = 'AE' + efDateTime.format('MMddYY') + (isRefund ? 'R' : '');
        }else if(cardName == 'First Data') {
            docNumber = 'FD' + efDateTime.format('MMddYY') + (isRefund ? 'R' : '');
        }else if(cardName == 'Other') {
            docNumber = efDateTime.format('MMddYY') + (isRefund ? 'R' : '');
        }
        
        if(null != docNumber && isGRA) docNumber = 'GRA' + docNumber;
        
        return docNumber;
    }
    
    public static String getCompanyCode(String compName) {
        String compCode = null;
        
        if(compName == 'GARP') {
            compCode = '10';
        }else if(compName == 'GRA') {
            compCode = '12';
        }
        
        return compCode;
    }

    public static String getRefundMemberGLTitle(Product_Refunds__c refund) {
        String title = refund.Product__r.Acct_GL_Short_Title__c;

        if(memberProdCodes.contains(refund.Product__r.ProductCode)) {
            title = 'Refunds - ' + title;
        }

        return title;
    }
    
}