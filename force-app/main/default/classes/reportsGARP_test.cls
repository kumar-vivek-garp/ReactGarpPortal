@isTest
private class reportsGARP_test{
    
    static Product2 prod;
    static Product2 prod1;
    static Product2 prod2;
    static Product2 prod3;
    
    static testMethod void myUnitTest_2() {
        
        Date start1Date = System.today(); //.addDays(-5);
        Date end1Date = System.today(); //addDays(2);
        
        datetime start1DateTime = datetime.newInstance(start1Date.year(), start1Date.month(),start1Date.day());
        datetime end1DateTime = datetime.newInstance(end1Date.year(), end1Date.month(),end1Date.day());
        
        Long startDateLong = start1DateTime.getTime() /1000;
        Long endDateLong = end1DateTime.getTime() /1000;
        
        String startDate = String.valueOf(startDateLong);
        String endDate = String.valueOf(endDateLong);
        
        Deployment__c lstDply = new Deployment__c(Name='Dply', Target_Deployment_Date__c=start1Date, Target_Deployment_Time__c=null, Type__c='Email');
        insert lstDply;
        
        
        test.startTest();
        reportsGARP.getDeploymentData(start1Date.month(), start1Date.year());
        reportsGARP.getDeploymentData(-1, start1Date.year());
        reportsGARP.getDeploymentData(start1Date.month(), -1);
        //reportsGARP.getDeploymentData(-1, -1);        
        
        test.stopTest();
        
    }
    
}