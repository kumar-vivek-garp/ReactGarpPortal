@isTest
public class MaintenanceController_test{
    static testMethod void test1(){
        ApexPages.currentPage().getParameters().put('action', 'jobtarget');
        MaintenanceController controller1 = new MaintenanceController();        
        controller1.init();
    }
}