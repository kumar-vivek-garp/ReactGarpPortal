public class GARP_Wrapper_response_People_Information{
	public cls_response response;
	public class cls_response {
		public Integer id;	//295
		public String company;	//GARP
        public string job_title;
		public cls_publication_name publication_name;
		public String full_publication_name;
		public String public_image_url;	
		public cls_real_name real_name;
		public cls_phone_numbers[] phone_numbers;
		public cls_email_addresses[] email_addresses;
		public cls_registrationDetail registrationDetail;
		public cls_edited_bio edited_bio;
		public cls_image image;
		public cls_publishedProgrammeItemAssignments[] publishedProgrammeItemAssignments;
	}
	public class cls_publication_name {
		public String prefix;	//
		public String first;	//Beth
		public String last;	//Gould Creller
		public String suffix;	//
	}
	public class cls_real_name {
		public String prefix;	//
		public String first;	//Beth
		public String last;	//Gould Creller
		public String suffix;	//
	}
	public class cls_phone_numbers {
		public Integer id;	//163
		public String numbe;	//201-205-1767
		public String phone_type;
	}
	public class cls_phone_type {
		public String name;	//Work
	}
	public class cls_email_addresses {
		public Integer id;	//442
		public String email;	//Beth.Creller@garp.com
		public boolean isdefault;
		public String label;	//
	}
	public class cls_registrationDetail {
		public Integer id;	//70
		public String registration_number;	//
		public String registration_type;	//Event Staff
		public boolean registered;
	}
	public class cls_edited_bio {
		public Integer id;	//114
		public Integer person_id;	//295
		public String website;	//
		public String twitterinfo;	//
		public String othersocialmedia;	//
		public String facebook;	//
		public String linkedin;	//
		public String twitch;	//
		public String youtube;	//
		public String instagram;	//
		public String flickr;	//
		public String reddit;	//
		public String bio;	//Alexander Kazan is Eurasia Group's lead emerging markets strategist and also directs the firm's comparative research, including quantitative approaches to political risk. Alex led the development of Eurasia Group's Political Risk Country Portfolio, a systematic comparative framework for analyzing the market pricing of political risk across emerging markets. He also directs the firm's collaboration with Nikko Asset Management to develop investment products formally incorporating political risk in portfolio construction and risk management.<br> <br>Before joining Eurasia Group, Alex worked as a market strategist at Goldman Sachs, Daiwa Asset Management, and Bear Stearns. Earlier in his career, he worked at the G7 Group, an economic and policy research consultancy, and the Inter-American Development Bank. He holds degrees from the University of California, Davis, and Georgetown University. Alex was born in San Francisco and now lives in New York. While Alex once travelled widely, he now spends his downtime playing with his two sons, attempting to build furniture, and making bathtub gin
		public String facebookid;	//
		public String twitterid;	//
		public String linkedinid;	//
		public String youtubeid;	//
		public String twitchid;	//
		public String instagramid;	//
		public String flickrid;	//
		public String redditid;	//
	}
	public class cls_image {
		public String public_image_url;	//https://cust-images.grenadine.co/grenadine/image/upload/c_fill,f_jpg,g_face,h_368,w_368/v0/GlobalAssociationofRiskProfessionals%28GARP%29/vgEA_295.jpg
	}
	public class cls_publishedProgrammeItemAssignments {
		public Integer published_programme_item_id;	//433
		public Integer person_id;	//295
		public String person_name;	//Beth Gould Creller
		public Integer sort_order;	//1431655766
		public String person_role;	//OtherParticipant
		public String time_stamp;	//2019-08-22T17:28:16Z
		public cls_published_programme_item published_programme_item;
	}
	public class cls_published_programme_item {
		public Integer id;	//433
		public String title;	//Town Square
	}
	public static GARP_Wrapper_response_People_Information parse(String json){
		return (GARP_Wrapper_response_People_Information) System.JSON.deserialize(json, GARP_Wrapper_response_People_Information.class);
	}

	
}