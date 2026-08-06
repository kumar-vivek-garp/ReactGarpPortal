public class ATA_SSOIntegrationClass{
    public Static String currentRrecId;
    public ATA_SSOIntegrationClass(){
       currentRrecId = apexpages.currentpage().getparameters().get('id');//'a1aq0000003maFn';
    }
    
    public  pagereference getATASSOjwtResponse(){
        List<Exam_Attempt__c>  examattempt = [Select Id,Garp_Id__c,ATA_Cert_id__c,Exam_Part__r.ATA_Batch_Code__c from Exam_Attempt__c where Id =:currentRrecId and ATA_Cert_id__c != null and Exam_Part__r.ATA_Batch_Code__c != null]; 
        List<ATA_Scheduling_Interface__mdt> ataMtd = [Select Id,App_Id__c,Private_Key__c,Batch_No__c,SSO_URL__c from ATA_Scheduling_Interface__mdt where DeveloperName ='ATA_Scheduling_Interface_Setting'];
        if(!ataMtd.isEmpty() && !examattempt.isEmpty()){ 
            string clientid = ataMtd[0].App_Id__c;
            string oauthurl = ataMtd[0].SSO_URL__c;
            string aud = 'ATA_USP.'+examattempt[0].Exam_Part__r.ATA_Batch_Code__c;
            string uid = examattempt[0].Garp_Id__c; 
            string key = ataMtd[0].Private_Key__c.trim();
            string header = '{"alg": "RS256","typ": "JWT"}';
            string Header_Encode = EncodingUtil.base64Encode(blob.valueof(header)); 
          	long dttime = getUTCDateTime(3);
          	 string exptime1 = string.valueOf(dttime);
            //string exptime1 = string.valueOf('1598901600');
            string claim_set = '{"iss":"' + clientid + '"'; 
            claim_set += ',"uid":"' + uid + '"'; 
            claim_set += ',"aud":"' + aud + '"'; 
            claim_set += ',"exp":' + exptime1 + '}';
            string claim_set_Encode = EncodingUtil.base64Encode(blob.valueof(claim_set));
            string Singature_Encode = Header_Encode + '.' + claim_set_Encode; 
            Singature_Encode = Singature_Encode.replaceAll('=', '');
            blob privateKey = EncodingUtil.base64Decode(key);
            string Singature_Encode_Url = EncodingUtil.urlEncode(Singature_Encode, 'UTF-8');
            blob Signature_b = blob.valueof(Singature_Encode_Url);
            string Sinatute_blob;
            if(!test.isRunningTest()){
            	Sinatute_blob = base64(Crypto.sign('RSA-SHA256', Signature_b, privateKey));
            }else{
                Sinatute_blob = base64(blob.valueof('testBlob'));
            }
            //system.debug(Sinatute_blob);
            string JWT = Singature_Encode_Url + '.' + Sinatute_blob;
            JWT = JWT.replaceAll('=', '');
            //system.debug(JWT); 
            String s = oauthurl+JWT;
            //system.debug(s);
            pagereference page = new pagereference(s);
            return page;

        }
        return null;
    }
    
    public static string base64(Blob b)
    {
        string ret = EncodingUtil.base64Encode(b);
        ret = ret.replaceAll('\\+', '-');
        ret = ret.replaceAll('/', '_');
        ret = ret.replaceAll('=', '');
        return ret;
    }
    
    
    public Static long getUTCDateTime(Integer hrs){
        DateTime dt = DateTime.now().addHours(hrs); 
        Long epochDate = dt.getTime()/1000;
        //system.debug(epochDate);
        return epochDate;
    }

}