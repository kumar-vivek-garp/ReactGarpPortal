public class SurveyRegistrationController {

    @RemoteAction
    public static Response.Detail getSurvey(String surveyId){
        
        try{
            
            if(surveyId == null){
                throw new Response.ResponseException(
                    'No survey ID provided.', 400,
                    new List<String>{'No survey ID provided.'}
                );
            }
            
            surveyId = (Id)surveyId;
            
            List<GARP_Survey__c> garpSurveys = [
                SELECT Id, Name, Survey_Name__c, End_Date_Time__c, Start_Date_Time__c, Description__c, GRI_Domain__c
                FROM GARP_Survey__c
                WHERE Id = :surveyId AND Start_Date_Time__c <= :System.now() AND End_Date_Time__c >= :System.now()
            ];
            
            if(garpSurveys.isEmpty()){
                throw new Response.ResponseException(
                    'Invalid Survey ID.', 404,
                    new List<String>{'Invalid Survey ID.'}
                );
            }
            
            Response.Detail res = new Response.Detail();
            
            res.data = garpSurveys[0];
            res.status = 200;
            
            return res;
            
        }catch(Response.ResponseException e){
            
            return new Response.Detail(e.getMessage(), e.status, e.errors);
            
        }catch(Exception e){
            
            return new Response.Detail(null, 400, new List<Object>{
                e.getMessage(),
                e.getLineNumber(),
                e.getStackTraceString()
            });
            
        } 
        
    }
    
    @RemoteAction
    public static Response.Detail createSurveyParticipants(String surveyId, List<GARP_Survey_Participant__c> surveyParticipants){
		
        try{
            
           if(surveyId == null){
                throw new Response.ResponseException(
                    'No survey ID provided.', 404,
                    new List<String>{'No survey ID provided.'}
                );
            }
            
            surveyId = (Id)surveyId;
            
            List<GARP_Survey__c> garpSurveys = [
                SELECT Id
                FROM GARP_Survey__c
                WHERE Id = :surveyId AND Start_Date_Time__c <= :System.now() AND End_Date_Time__c >= :System.now()
            ];
            
            if(garpSurveys.isEmpty()){
                throw new Response.ResponseException(
                    'Invalid Survey ID.', 404,
                    new List<String>{'Invalid Survey ID.'}
                );
            }
            
       		List<GARP_Survey_Participant__c> toInsert = new List<GARP_Survey_Participant__c>();
            for(GARP_Survey_Participant__c surveyParticipant: surveyParticipants){
                if(surveyParticipant != null){
                    surveyParticipant.GARP_Survey__c = surveyId;
                    toInsert.add(surveyParticipant);
                }
            }
            
            INSERT toInsert;
            
            Response.Detail res = new Response.Detail();
                
            res.status = 200;
            
            return res;
            
        }catch(Response.ResponseException e){

            return new Response.Detail(e.getMessage(), e.status, e.errors);

        }catch(Exception e){

            return new Response.Detail(null, 400, new List<Object>{
                e.getMessage(),
                e.getLineNumber(),
                e.getStackTraceString()
            });

        }  
        
    }
    
    public SurveyRegistrationController(sfdcAppRemoter ctrl){}
    
}