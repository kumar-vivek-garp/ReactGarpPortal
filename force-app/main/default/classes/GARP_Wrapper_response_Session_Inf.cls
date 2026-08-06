public class GARP_Wrapper_response_Session_Inf{
	public cls_response response;
	class cls_response {
		public Integer id;	//445
		public String title;	//Early Badge Pickup
		public Integer duration;	//120
		public String created_at;	//2019-02-19T18:02:19-05:00
		public String updated_at;	//2019-02-19T18:02:41-05:00
		public cls_parent_id parent_id;
		public boolean is_break;
		public Integer visibility_id;	//85
		public String start_time;	//2019-02-25T15:00:00-05:00
		public String end_time;	//2019-02-25T17:00:00-05:00
		public cls_child_ids[] child_ids;
		public cls_ticket_type_ids[] ticket_type_ids;
		public boolean requires_signup;
		public Integer card_size;	//1
		public cls_description description;
		public cls_base_tags[] base_tags;
		public String visibility_name;	//Public
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
	class cls_description {
	}
	class cls_base_tags {
		public Integer id;	//185
		public String name;	//MID
		public Integer taggings_count;	//2
	}
	class cls_theme_names {
	}
	class cls_format {
		public Integer id;	//39
		public String name;	//Registration
		public cls_images[] images;
	}
	class cls_images {
	}
	class cls_sorted_published_item_assignments {
	}
	class cls_published_room {
		public Integer id;	//33
		public String name;	//Empire Ballroom IV-V Foyer
		public Integer published_venue_id;	//4
	}
	class cls_public_documents {
	}
	public static GARP_Wrapper_response_Session_Inf parse(String json){
		return (GARP_Wrapper_response_Session_Inf) System.JSON.deserialize(json, GARP_Wrapper_response_Session_Inf.class);
	}
}