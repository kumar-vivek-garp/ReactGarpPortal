global class SendCertificateXML {
  WebService static void invokeSendCertificateXML (){
    ID batchprocessid = Database.executeBatch(new shippingcertBatchclass());
  }
 }