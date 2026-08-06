public class SendCPDAttendanceEmailsCntrlr {
	@AuraEnabled
    public static string sendEmailBatch(){
        String returnMessage;
        try{
            sendCertificateOfAttendanceBatch emailBatch = new sendCertificateOfAttendanceBatch();
            database.executeBatch(emailBatch);
            returnMessage = 'Email process started successfully';
        }catch(exception e){
            returnMessage = e.getMessage();        
        }
        return returnMessage;
    }
}