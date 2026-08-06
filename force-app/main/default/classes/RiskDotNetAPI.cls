/**
 * Class to create Risk.net User creation JSON structure.
 */
public with sharing class RiskDotNetAPI {

    public class JSONBody {
    public String id {get;set;} 
	public String name {get;set;} 
	public String org_size {get;set;} 
	public String org_industry {get;set;} 
    public List<Companies> companies {get;set;} 
    
        // class constructor
        public JSONBody() {
            this.id = '';
            this.name = '';
            this.org_size = '';
            this.org_industry = '';
            this.companies = new List<Companies>();
        }
    }

        // class Companies 
        public class Companies {
            public String id {get;set;} 
            public String name {get;set;} 
            public String org_phone {get;set;} 
            public List<Users> users {get;set;} 
                public Companies() {
                    this.id = '';
                    this.name = '';
                    this.org_phone = '';
                    this.users = new List<Users>();
                }
        }

        // class Users
        public class Users {
            public String id {get;set;} 
            public String name_id {get;set;} 
            public String email {get;set;} 
            public String email_hash {get;set;} 
            public String first_name {get;set;} 
            public String surname {get;set;} 
            public String job_title {get;set;} 
            public String department {get;set;} 
            public String delivery_address1 {get;set;} 
            public String delivery_address2 {get;set;} 
            public String delivery_address3 {get;set;} 
            public String delivery_address4 {get;set;} 
            public String delivery_address5 {get;set;} 
            public String delivery_country {get;set;} 
            public String postcode {get;set;} 
            public String telephone {get;set;} 
            public String mobile {get;set;} 
            public List<Subscriptions> subscriptions {get;set;} 
                public Users() {
                    this.id = '';
                    this.name_id = '';
                    this.email = '';
                    
                    //value to process
                    this.email_hash  = '';
                    this.first_name = '';
                    this.surname = '';
                    this.job_title = '';
                    this.department = '';
                    this.delivery_address1 = '';
                    this.delivery_address2 = '';
                    this.delivery_address3 = '';
                    this.delivery_address4 = '';
                    this.delivery_address5 = '';
                    this.delivery_country = '';
                    this.telephone = '';
                    this.mobile = '';
                    this.subscriptions = new List<Subscriptions>();
                }
        }

        // class Subscriptions
        public class Subscriptions {
            public String id {get;set;} 
            public String order_header {get;set;} 
            public String price {get;set;} 
            public String vat {get;set;} 
            // public String currency {get;set;} 
            public String order_date {get;set;} 
            public String payment_date {get;set;} 
            public String start_date {get;set;} 
            public String end_date {get;set;} 
            public Integer seats {get;set;} 
            public String type{get;set;} // in json: type
            public String subscription_type {get;set;} 
            public String status {get;set;} 
            public String ka_id {get;set;} 
            public Integer active {get;set;} 
            public Integer paid {get;set;} 
            public Integer suspended {get;set;} 
            public Integer canceled {get;set;} 
            public Integer corp_offer {get;set;} 
            public Integer trial {get;set;} 
            public String source {get;set;} 
            public String campaign_list_desc {get;set;} 
            public String ra_list_reference {get;set;} 
            public String tracking_code {get;set;} 
            public Integer email_suppress {get;set;} 
            public Product product {get;set;} 
                public Subscriptions() {
                    this.id = '';
                    this.order_header = '';
                    this.price = '';
                    this.vat = '';
                    // currency = '';
                    this.order_date = '';
                    this.payment_date = '';
                    this.start_date = '';
                    this.end_date = '';
                    this.seats = null;
                    this.type = '';
                    this.subscription_type = '';
                    this.status = '';
                    this.ka_id = '';
                    this.active = null;
                    this.paid = null;
                    this.suspended = null;
                    this.canceled = null;
                    this.corp_offer = null;
                    this.trial = null;
                    this.source = '';
                    this.campaign_list_desc = '';
                    this.ra_list_reference = '';
                    this.tracking_code = '';
                    this.email_suppress = null;
                }
        }

        // class Product
        public class Product {
            public String id {get;set;} 
            public String BB8_id {get;set;} 
            public String name {get;set;} 
            public String family {get;set;} 
            public String type {get;set;} // in json: type
                public Product(){
                    this.id = '';
                    this.BB8_id = '';
                    this.name = '';
                    this.family = '';
                    this.type = '';
                }
        }
    
}