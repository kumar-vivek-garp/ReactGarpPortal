public without sharing class DeferralExtensionRequestCtrl {

    public Contact contact { get; set; }
    public Form__c form { get; set; }
    public Boolean submitted { get; set; }
    public String message { get; set; }
    public String examDeferralDate { get; set; }
    public List<SelectOption> options { get; set; }
    
    public ApexPage submit(){
        
        submitted = true;
        
        Form_Data__c formData = new Form_Data__c();
        
        formData.Form__c = form.Id;
        formData.Contact__c = contact.Id;
        formData.Message__c = examDeferralDate;
        
        INSERT formData;

        return null;
        
    }
    
    public DeferralExtensionRequestCtrl(){
        
        Id contactId = ApexPages.currentPage().getParameters().get('id');
        
        submitted = false;
        
        options = new List<SelectOption>();
        options.add(new SelectOption('May 2026','May 2026'));
        options.add(new SelectOption('August 2026','August 2026'));

        examDeferralDate = 'May 2026';
        
        List<Form__c> forms = [SELECT Id, Status__c, Form_Name__c FROM Form__c WHERE Form_Name__c = 'deferral-frm-nov-2025'];
        if(forms.isEmpty()){
            message = 'Please create a form for this page with the Form_Name__c of "deferral-frm-nov-2025".';
            return;
        }else{
            form = forms[0];
        }
        
        if(form.Status__c != 'Active'){
            message = 'The deferral extension request period has ended.';
            return;
        }

        List<Contact> contacts = [
            SELECT Id, Name, Email
            FROM Contact
            WHERE Id = :contactId
            LIMIT 1
        ];  
       
        if(contacts.isEmpty()){
            message = 'There is no account associated with this ID.';
            return;
        }else{
            System.debug(contacts[0]);
            contact = contacts[0];
        }
        
        List<Form_Data__c> formData = [
            SELECT Id, Form__c, Contact__c 
            FROM Form_Data__c 
            WHERE Contact__c = :contacts[0].Id AND Form__c = :form.Id
        ];
        
        if(!formData.isEmpty()){
            contact = null;
            message = 'You have already made your selection.';
            return;
        }

    }
    
}