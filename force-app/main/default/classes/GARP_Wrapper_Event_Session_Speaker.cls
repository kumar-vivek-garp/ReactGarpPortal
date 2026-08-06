public class GARP_Wrapper_Event_Session_Speaker{
    public cls_response[] response;
    public Integer count;   //3
    public cls_pagination pagination;
    public class cls_response {
        public Integer id;  //445
        public String title;    //Early Badge Pickup
        public Integer duration;    //120
        public String created_at;   //2019-02-19T18:02:19-05:00
        public Datetime updated_at; //2019-02-19T18:02:41-05:00
        public string parent_id;
        public boolean is_break;
        public String visibility_id;   //85
        public datetime start_time; //2019-02-25T15:00:00-05:00
        public datetime end_time;   //2019-02-25T17:00:00-05:00
        public Integer[] child_ids;
        public cls_ticket_type_ids[] ticket_type_ids;
        public boolean requires_signup;
        public Integer card_size;   //1
        public string  description;
        public cls_base_tags[] base_tags;
        public String visibility_name;  //Public
        public cls_theme_names[] theme_names;
        public cls_format format;
        public cls_sorted_published_item_assignments[] sorted_published_item_assignments;
        public cls_published_room published_room;
        public cls_images[] images;
        public cls_public_documents[] public_documents;
    }
    class cls_parent_id {
    }
    class cls_child_ids {
    }
    class cls_ticket_type_ids {
    }
    
    class cls_base_tags {
        public Integer id;  //185
        public String name; //MID
        public Integer taggings_count;  //2
    }
    class cls_theme_names {
        public integer id;
        public String name;
    }
    class cls_format {
        public Integer id;  //39
        public String name; //Registration
        public cls_images[] images;
    }
    class cls_images {
    }
    public class cls_sorted_published_item_assignments {
        public Integer sort_order;
        public String person_role;
        public Person person;
    }
    public class Person {
        public String details;
        public Integer id;
        public String company;
        public String job_title;
        public String full_publication_name;
    }
    class cls_published_room {
        public Integer id;  //33
        public String name; //Empire Ballroom IV-V Foyer
        public Integer published_venue_id;  //4
    }
    class cls_public_documents {
    }
    class cls_pagination {
        public cls_previous previous;
        public cls_next next;
        public Integer current; //1
        public Integer per_page;    //50
        public Integer count;   //3
        public Integer pages;   //1
    }
    class cls_previous {
    }
    class cls_next {
    }
    public static GARP_Wrapper_Event_Session_Speaker parse(String json){
        return (GARP_Wrapper_Event_Session_Speaker) System.JSON.deserialize(json, GARP_Wrapper_Event_Session_Speaker.class);
    }
}