global with sharing class QualtricsApiRequestMock implements HttpCalloutMock {

    public String json { get; set; }

    global Enum QualtricsApiRequestType { 
        CREATE_MAILING_LIST, 
        CREATE_CONTACT_IN_MAILING_LIST,
        GENERATE_DISTRIBUTION_LINKS,
        GET_DISTRIBUTION_LINKS
    }
    
	global HttpResponse respond(HttpRequest req){
         
		HttpResponse res = new HttpResponse();
		req.setHeader('Content-Type', 'application/json');
		res.setBody(this.json);
		return res;
        
    }
    
    global QualtricsApiRequestMock(QualtricsApiRequestMock.QualtricsApiRequestType qualtricsApiRequestType){

        switch on qualtricsApiRequestType {
            when CREATE_MAILING_LIST {
                this.json = '{"result":{"id":"CG_0SAbnbKkh6L2h7b"},"meta":{"httpStatus":"200 - OK","requestId":"9d169c69-d291-4258-9454-de8f1d907256","notice":"Request proxied. For faster response times, use this host instead: az1.qualtrics.com"}}';
            }	
            when CREATE_CONTACT_IN_MAILING_LIST {
                this.json = '{"result":{"id":"CID_1js5Gg3UueFIEPb","contactLookupId":"CGC_oSMOdhyRQPZlXq8"},"meta":{"httpStatus":"200 - OK","requestId":"35fcbd83-13c2-4ee0-b4ba-cefe408ddedd"}}';
            }
            when GENERATE_DISTRIBUTION_LINKS {
                this.json = '{"result":{"id":"EMD_cb4DKHaNHGtKVSY"},"meta":{"httpStatus":"200 - OK","requestId":"e3631d54-33bc-4291-8b2f-bcf21fb1896e"}}';    
            }
            when GET_DISTRIBUTION_LINKS {
                this.json = '{"result":{"elements":[{"contactId":"CID_3f87MJH1P9szlbf","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_poAf7pIuVBsAJwM","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"exampleLast","firstName":"exampleFirst","externalDataReference":"0031W00002PC0Ox","email":"example@example.com","unsubscribed":false},{"contactId":"CID_2WuqznYPt0LETyi","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_Luq44pyFh1ACYin","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"Lappert2","firstName":"David1!(*&^%$#@!@#$%^&*(","externalDataReference":"0031W00002PC0Ox","unsubscribed":false},{"contactId":"CID_RdVyXFlcJwbhQtz","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_7fiq6DJVJT07k1f","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"Lappert2","firstName":"David1!(*&^%$#@!@#$%^&*(","externalDataReference":"0031W00002PC0Ox","email":"dclappert@gmail.com","unsubscribed":false},{"contactId":"CID_2aieWx5gGZ8LcnH","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_rmmtmGuPtimNDBT","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"exampleLast","firstName":"exampleFirst","externalDataReference":"0031W00002PC0Lx","email":"example@example.com","unsubscribed":false},{"contactId":"CID_1N55h7VqGzXYtZS","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_GaBF5kXe9ayuEW1","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"Lappert2","firstName":"David1!(*&^%$#@!@#$%^&*(","externalDataReference":"0031W00002PC0Ox","unsubscribed":false},{"contactId":"CID_3s46XTr9PZwwldc","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_ksj29FyPgjgnGYX","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"Lappert2","firstName":"David1","externalDataReference":"0031W00002PC0Ox","email":"dclappert@gmail.com","unsubscribed":false},{"contactId":"CID_e4YUVhDlxr5rF1r","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_1HimcOJDwLkihFX","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"exampleLast","firstName":"exampleFirst","externalDataReference":"0031W00002PC0Ox","email":"example@example.com","unsubscribed":false},{"contactId":"CID_2zFNstnGzliIZ48","link":"https://garp.az1.qualtrics.com/jfe/form/SV_b76TGKe2PrEZGG9?Q_CHL=gl&Q_DL=cb4DKHaNHGtKVSY_b76TGKe2PrEZGG9_CGC_VROTCapnMHx0Ioo","exceededContactFrequency":false,"linkExpiration":"13 Mar 2020 09:11 PM GMT","status":"Email not sent","lastName":"Lappert","firstName":"David","externalDataReference":"0031W00002PC0Ox","email":"dclappert@gmail.com","unsubscribed":false}],"nextPage":null},"meta":{"httpStatus":"200 - OK","requestId":"bfb1009b-e677-4caa-88f5-8173e0dad4cb"}}'; 
            }
        }

    }

}