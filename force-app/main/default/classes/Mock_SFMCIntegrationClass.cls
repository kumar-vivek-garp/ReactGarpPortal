global class Mock_SFMCIntegrationClass implements HttpCalloutMock{

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        //System.assertEquals('https://onlinetools.ups.com/ups.app/xml/XAV', req.getEndpoint());
        //System.assertEquals('GET', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjEiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJaNVBQV1VSU3BmQmN6bWFhMW1NUGFHc2MiLCJjbGllbnRfaWQiOiJ1bjBiYzU3MHVnYWFsMnRoM2VoaGNnZnYiLCJlaWQiOjEwMDAyNjY0NCwic3RhY2tfa2V5IjoiUzEwIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.KZ0I4Abo66VtUfm_nZpsfDlK8a3LiBC7kMp8qTama-0.dBR9VkUxB2sMo7iIBMR77OzI0RAsvbsNPAeFCvkKXO87ce9t14jGZ17_Cg0goaDfGu9j45ZpqbZYbxo-rPxxAUfJTJLUDhRkAWqyLLOu7Zpmpu8KpnlY0sg5FWdtiLthjQjGVlQOCgza_-EstnwDqoJ_2AYMZ1vOcHrJm_is9nmuUJ-r55Z","token_type":"Bearer","expires_in":1079,"scope":"offline audiences_write list_and_subscribers_write","soap_instance_url":"https://mc50vhgyl-pn1kqqp-ywmr256hy4.soap.marketingcloudapis.com/","rest_instance_url":"https://mc50vhgyl-pn1kqqp-ywmr256hy4.rest.marketingcloudapis.com/"}');
        res.setStatusCode(200);
        return res;
    }
}