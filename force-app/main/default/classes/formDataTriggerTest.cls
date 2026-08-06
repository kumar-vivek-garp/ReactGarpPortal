@isTest
public class formDataTriggerTest {
    public static testmethod void formDataTriggerCoverage(){
        
        SubscriptionManagement__c fdSetting = new SubscriptionManagement__c();
        fdSetting.Name ='FRM Exam Updates'; // form.Subscriptions value
        fdSetting.Contact_Field_Mapping__c = 'test1__c,test2__c'; 
        fdSetting.Lead_Field_Maapping__c = 'Email_FRM__c';	 
        insert fdSetting;
        
         account acc = new account(Name ='test');
       insert acc;
        Default_Record_References__c dr = new Default_Record_References__c(Record_Reference_ID__c=acc.id,name ='UNMATCHED-BUSINESS-ACCOUNT', sObjectType__c='account');
        insert dr;
        
       
       
        Lead ld1 = new Lead();
        ld1.LastName = 'Test Lead Data';
        ld1.Company = 'Test Lead Company';
        ld1.FirstName = 'Test First Name';
        ld1.Status = 'Open - Not Contacted'; 
        ld1.Email = 'testLead1@test.com'; 
        ld1.Mobile_Phone__c = '1234567890';
        insert ld1;
        
        
        Lead ld = new Lead();
        ld.LastName = 'Test Lead Data';
        ld.Company = 'Test Lead Company';
        ld.FirstName = 'Test First Name';
        ld.Status = 'Open - Not Contacted'; 
        ld.Email = 'testLead@test.com'; 
        ld.Mobile_Phone__c = '1234567890';
       // Id.Industry = 'Banking';
        insert ld;
        
        Contact c = new Contact();
        c.LastName = 'Test data';
        c.Email = 'testConEmail@test.com';
        insert c;
        
        Form__c fromobj1 = new Form__c();
        fromobj1.Name = 'Test Form Data1';
        fromobj1.Form_Name__c ='Test Form Data1';
        fromobj1.Subscriptions__c = 'FRM Exam Updates1';
        insert fromobj1;
        
        campaign camp1 = new campaign();
        camp1.Name = 'Test Campaign';
        camp1.IsActive = true;
        camp1.Conversion_Form__c = fromobj1.id;
        insert camp1;
        
        fromobj1.Campaign__c = camp1.id;
        update fromobj1;
        
        campaign camp = new campaign();
        camp.Name = 'Test Campaign';
        camp.IsActive = true;
        insert camp;
        
        Form__c fromobj = new Form__c();
        fromobj.Name = 'Test Form Data';
        fromobj.Form_Name__c ='Test Form Data';
        fromobj.Subscriptions__c = 'FRM Exam Updates';
        fromobj.Campaign__c = camp.id;
        insert fromobj;
        
        CampaignMember campMem = new CampaignMember();
        campMem.LeadId = ld.Id;
        campmem.CampaignId = camp.Id;
        // camp.Conversion_Form__c = fromobj.Id;
        insert campMem;
        
        List<Form_Data__c> formList = new  List<Form_Data__c>();
        
        Form_Data__c fd7 = new Form_Data__c();
        fd7.Form__c = fromobj.id; 
        fd7.lead__c = ld.id;
        fd7.Email__c = ld.Email;
        fd7.Subscription__c = 'No';
        fd7.Last_Name__c = 'TestLname';
        fd7.First_Name__c = 'TestLname';
        fd7.Status__c ='Completed';
        fd7.Subscriptions__c = 'FRM Exam Updates';
        formList.add(fd7);
        
        Form_Data__c fd = new Form_Data__c();
        fd.Form__c = fromobj.id; 
        fd.contact__c = c.id;
        fd.Email__c = ld.Email;
        fd.Subscription__c = 'Yes';
        fd.Last_Name__c = 'TestLname';
        fd.First_Name__c = 'TestLname';
        fd.Status__c ='Completed';
        fd.Subscriptions__c = 'FRM Exam Updates';
        formList.add(fd);
        
        Form_Data__c fd6 = new Form_Data__c();
        fd6.Form__c = fromobj.id; 
        fd6.Email__c = 'testLead1@test.com'; 
        fd6.Subscription__c ='Yes';
        fd6.Status__c ='completed';
        fd6.Overwrite_Lead__c = true;
        fd6.First_Name__c ='test';
        fd6.Last_Name__c = 'test';
        fd6.Mailing_Street__c= 'test';
        fd6.Mailing_City__c= 'test';
        fd6.Mailing_State_Province__c= 'test';
        fd6.Mailing_Zip_Postal_Code__c= '078946';
        fd6.Mailing_Country__c= 'test';
        fd6.Title__c= 'test';
        fd6.Company__c= 'test';
        fd6.Phone__c= '8609874562';
        formList.add(fd6); 
        
        
        
        Form_Data__c fd3 = new Form_Data__c();
        
        fd3.Form__c = fromobj.id; 
        fd3.Email__c = 'testdata@tst.com'; 
        fd3.Subscription__c ='No';
        fd3.Status__c ='completed';
        formList.add(fd3); 
        
        Form_Data__c fd1 = new Form_Data__c();
        fd1.Form__c = fromobj.id; 
        fd1.Email__c = 'testdata@tst.com'; 
        fd1.Subscription__c ='Do Not Email';
        fd1.Status__c ='Completed';
        formList.add(fd1); 
        
        Form_Data__c fd2 = new Form_Data__c();
        fd2.Form__c = fromobj.id; 
        fd2.Contact__c = c.Id; 
        fd2.Overwrite_Contact__c = true;
        fd2.Email__c = 'testdata123@tst.com'; 
        fd2.Last_Name__c = 'TestLname';
        fd2.First_Name__c = 'TestLname';
        fd2.Subscription__c = 'Do Not Email'; 
        fd2.Mailing_Street__c ='xeerer';
        fd2.Mailing_City__c ='xeerer';
        fd2.Mailing_State_Province__c ='xeerer';
        fd2.Mailing_Zip_Postal_Code__c ='xeerer';
        fd2.Mailing_Country__c  ='xeerer';
        fd2.Title__c ='xeerer';
        fd2.Status__c ='Completed';
        fd2.Company__c ='xeerer';
        fd2.Phone__c ='xeerer';
        
        formList.add(fd2);
        
        
        Form_Data__c fd4 = new Form_Data__c();
        fd4.Form__c = fromobj.id; 
        fd4.Contact__c = c.Id; 
        fd4.Overwrite_Lead__c = true;
        fd4.Email__c = 'testConEmail@test.com'; 
        fd4.Last_Name__c = 'TestLname';
        fd4.First_Name__c = 'TestLname';
        fd4.Subscription__c = 'Yes'; 
        fd4.Mailing_Street__c ='xeerer';
        fd4.Mailing_City__c ='xeerer';
        fd4.Mailing_State_Province__c ='xeerer';
        fd4.Mailing_Zip_Postal_Code__c ='xeerer';
        fd4.Mailing_Country__c  ='xeerer';
        fd4.Title__c ='xeerer';
        fd4.Company__c ='xeerer';
        fd4.Phone__c ='xeerer';
        fd4.Status__c ='Completed';
        formList.add(fd4);
        
        Form_Data__c fd5 = new Form_Data__c();
        fd5.Form__c = fromobj.id; 
        fd5.Lead__c = ld.Id; 
        fd5.Email__c = 'testConEmail@test.com'; 
        fd5.Last_Name__c = 'TestLname';
        fd5.First_Name__c = 'TestLname';
        fd5.Subscription__c = 'No'; 
        fd5.Mailing_Street__c ='xeerer';
        fd5.Mailing_City__c ='xeerer';
        fd5.Mailing_State_Province__c ='xeerer';
        fd5.Mailing_Zip_Postal_Code__c ='xeerer';
        fd5.Mailing_Country__c  ='xeerer';
        fd5.Title__c ='xeerer';
        fd5.Company__c ='xeerer';
        fd5.Phone__c ='xeerer';
        fd5.Status__c ='Completed';
        fd5.Subscriptions__c = 'FRM Exam Updates';
        formList.add(fd5);
         
        insert formList; 
        
    }
}