Global class PearsonInboundRequestJsonHelper{

    
    
    public static blob formatResponsedata(ResponseBase ResponseBaseObj){
        String response;
         response = serializeRespinseBaseXmlDate(ResponseBaseObj);
        return blob.valueOf(response);
    }
      /*
    *************************************************************************
    * @description: This function is used to send the response in XML
    * @return: string  
    *************************************************************************
    */ 

   public static string serializeRespinseBaseXmlDate(ResponseBase ResponseBaseObj ){
       String responseXML = '<?xml version="1.0" encoding="UTF-8"?>'+
           '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:sch="http://ws.pearsonvue.com/rteAppointment/schema">'+
           '<soapenv:Header/>'+
           '<soapenv:Body>';
           if(ResponseBaseObj.eventType == 'cancelAppointmentRequest'){
               responseXML += '<appointmentNotificationResponse>';
           }else if(ResponseBaseObj.eventType == 'ModifyAppointmentRequest'){
               responseXML +=  '<sch:appointmentNotificationResponse>';
           }else if(ResponseBaseObj.eventType =='ResultNotificationRequest'){
               responseXML +=  '<resultNotificationResponse>';
           }
       responseXML +='<status>'+ResponseBaseObj.Status+'</status>';
       if(ResponseBaseObj.Status == 'Failure'){
           responseXML += '<errorType>InvalidData</errorType>'+
               '<errorCode>100003</errorCode>'+
               '<errorMessage>'+ResponseBaseObj.Message+'</errorMessage>';
       }
       if(ResponseBaseObj.eventType == 'cancelAppointmentRequest'){
           responseXML +='</appointmentNotificationResponse>';
       }else if(ResponseBaseObj.eventType == 'ModifyAppointmentRequest'){
           responseXML +=  '</sch:appointmentNotificationResponse>';
       }else if(ResponseBaseObj.eventType =='ResultNotificationRequest'){
           responseXML +=  '</resultNotificationResponse>';
       }
       responseXML +=  '</soapenv:Body>'+
           '</soapenv:Envelope>';        
       return responseXML ;
    }
    
    global class ResponseBase {
        global String eventType;
        global Boolean Success;
        global String Message;
        global String Status; 
    }
}