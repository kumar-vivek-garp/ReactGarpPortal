public class HubSpotClass {

    public class contactProperties {
        String property;
        String value;
    }
    
    public class reqUpdateContact {
        List<contactProperties> properties;
    }
    
    public class respUpdateContact {
        
    }
    
    public class returnSendUpdateContact {
        public API_Transaction__c apiTrans;
        public Integer statusCode;
        public String message;
    }
    
    public static returnSendUpdateContact sendUpdateContactEmail(String contactId, String email, String salesforceContactId) {
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','contactId',contactId);
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','email',email);

        returnSendUpdateContact returnSendUpdateContact = new returnSendUpdateContact();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_HubSpot_Endpoint;
        endpoint += '/contacts/v1/contact/vid/' + contactId + '/profile';
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','endpoint',endpoint);
        
        reqUpdateContact req = new reqUpdateContact();
        req.properties = new List<contactProperties>();
        
        contactProperties cprop = new contactProperties();
        cprop.property = 'email';
        cprop.value = email;
        
        req.properties.add(cprop);
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','jsonBody',jsonBody);
        
        request.setEndPoint(endpoint);
        System.debug('HubSpot endpoint: ' + endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + Label.GARP_HubSpot_Access_Token;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        System.debug('HubSpot statusCode: ' + statusCode);
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','statusCode',statusCode);
        
        returnSendUpdateContact.statusCode = statusCode;
                
        returnSendUpdateContact.apitrans = new API_Transaction__c (
            COntact__c = salesforceContactId,
            Type__c = 'Hubspot',
            Description__c = 'sendUpdateContact',
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','returnSendUpdateContact',returnSendUpdateContact);
        
        return returnSendUpdateContact;
    }
    
    public class respGetContactResultsProperties {
        public String email;
        public String salesforcecontactid;
        public String garpMemberIdSTR;
        public String lifecyclestage;
    }
    
    public class respGetContactResults {
        public String id;
        public respGetContactResultsProperties properties;
    }
    
    public class respGetContact {
        public Integer total;
        public List<respGetContactResults> results;
    }
    
    public class reqGetContactFilterGroupsFilters {
        public string propertyName;
        public string operator;
        public string value;
    }

    /** Filter with values array for IN operator (batch search by GARP Member ID). */
    public class reqGetContactFilterGroupsFiltersWithValues {
        public String propertyName;
        public String operator;
        public List<String> values;
    }

    public class reqGetContactFilterGroups {
        List<reqGetContactFilterGroupsFilters> filters;
    }

    public class reqGetContactFilterGroupsWithValues {
        List<reqGetContactFilterGroupsFiltersWithValues> filters;
    }

    public class reqGetContact {
        List<reqGetContactFilterGroups> filterGroups;
        List<String> properties;
    }

    /** Request body for search by multiple GARP Member IDs (one filter group, IN operator). */
    public class reqGetContactsByGarpMemberIds {
        public List<reqGetContactFilterGroupsWithValues> filterGroups;
        public List<String> properties;
    }
    
    public class returnGetContact {
        public API_Transaction__c apiTrans;
        public respGetContact respGetContact;
        public Integer statusCode;
        public String message;
    }

    /** Result of batch search by GARP Member IDs: which IDs were found in HubSpot. */
    public class returnGetContactsByGarpMemberIds {
        public Integer statusCode;
        public String message;
        /** GARP Member IDs that had a matching HubSpot contact. */
        public Set<String> garpMemberIdsFound;
    }

    /** Result of batch search by email: which emails were found in HubSpot. */
    public class returnGetContactsByEmails {
        public Integer statusCode;
        public String message;
        /** Emails (normalized lowercase) that had a matching HubSpot contact. */
        public Set<String> emailsFound;
    }

    /** Result of single search by email OR GARP Member ID (one callout). */
    public class returnGetContactsByEmailOrGarpId {
        public Integer statusCode;
        public String message;
        public Set<String> emailsFound;
        public Set<String> garpMemberIdsFound;
        /** Email (lowercase) -> HubSpot contact id. */
        public Map<String, String> emailToHubSpotId;
        /** GARP Member ID -> HubSpot contact id. */
        public Map<String, String> garpIdToHubSpotId;
        /** Email (lowercase) -> Lifecycle Stage. */
        public Map<String, String> emailToLifecycleStage;
        /** GARP Member ID -> Lifecycle Stage. */
        public Map<String, String> garpIdToLifecycleStage;
    }

    public static returnGetContact sendGetContact(String salesforceContactId) {
        GARP_Common.debugLog('HubSpotClass','sendGetContact','garpId',salesforceContactId);

        returnGetContact returnGetContact = new returnGetContact();
                
        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();
        
        String endpoint = Label.GARP_HubSpot_Endpoint;
        endpoint += '/crm/v3/objects/contacts/search';
        GARP_Common.debugLog('HubSpotClass','sendGetContact','endpoint',endpoint);
        
        reqGetContact req = new reqGetContact();
        req.properties = new List<String>{'email','garp_member_id__c','salesforcecontactid'}; 
        req.filterGroups = new List<reqGetContactFilterGroups>();
        
        reqGetContactFilterGroups filterGroup = new reqGetContactFilterGroups();
        filterGroup.filters = new List<reqGetContactFilterGroupsFilters>();
        
        reqGetContactFilterGroupsFilters filter = new reqGetContactFilterGroupsFilters();
        filter.propertyName = 'salesforcecontactid';
        filter.operator = 'EQ';
        filter.value = salesforceContactId;
        
        filterGroup.filters.add(filter);
        req.filterGroups.add(filterGroup);
        
        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        GARP_Common.debugLog('HubSpotClass','sendGetContact','jsonBody',jsonBody);
        
        request.setEndPoint(endpoint);
        System.debug('HubSpot endpoint: ' + endpoint);
        request.setMethod('POST');        
        request.setHeader('content-type', 'application/json');
        
        String authorizationHeader = 'Bearer ' + Label.GARP_HubSpot_Access_Token;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');
        
        HttpResponse response;
        Integer statusCode;
        if(!Test.isRunningTest()){
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        System.debug('HubSpot statusCode: ' + statusCode);
        GARP_Common.debugLog('HubSpotClass','sendGetContact','statusCode',statusCode);
        
        String respbody;
        if(!Test.isRunningTest()){
            respbody = response.getBody();
        } else {
            respbody = '{"total":1,"results":[{"id":"39385683206","properties":{"createdate":"2024-07-15T17:54:27.299Z","email":"garcia.alberto.crespo@gmail.com","firstname":"Alberto","garp_member_id__c":"857362","hs_object_id":"39385683206","lastmodifieddate":"2025-09-23T10:02:38.277Z","lastname":"GarciaCrespo"},"createdAt":"2024-07-15T17:54:27.299Z","updatedAt":"2025-09-23T10:02:38.277Z","archived":false}]}';
        }
        GARP_Common.debugLog('AWSSecureFileClass','sendGetContact','respbody',respbody);

        respbody = respbody.replace('garp_member_id__c','garpMemberIdSTR');
        
        respGetContact respGetContact = (respGetContact)JSON.deserialize(respbody, respGetContact.class);
        GARP_Common.debugLog('AWSSecureFileClass','sendGetContact','respGetContact',respGetContact);
        
        returnGetContact.respGetContact = respGetContact;
        
        returnGetContact.statusCode = statusCode;
                
        returnGetContact.apitrans = new API_Transaction__c (
            Contact__c = salesforceContactId,
            Type__c = 'Hubspot',
            Description__c = 'sendGetContact',
            Response_Body__c = respbody,
            Request__c = GARP_Common.limitSize(endpoint, 255),
            Request_Body__c = jsonBody,
            Response_Code__c = String.ValueOf(statusCode)
        );
        
        GARP_Common.debugLog('HubSpotClass','sendUpdateContact','returnGetContact',returnGetContact);

        return returnGetContact;
    }

    /**
     * Search HubSpot contacts by GARP Member ID (custom field garp_member_id__c).
     * Uses CRM v3 search with IN operator for batch lookup. Returns the set of GARP Member IDs that were found.
     */
    public static returnGetContactsByGarpMemberIds sendGetContactsByGarpMemberIds(List<String> garpMemberIds) {
        returnGetContactsByGarpMemberIds result = new returnGetContactsByGarpMemberIds();
        result.garpMemberIdsFound = new Set<String>();

        if (garpMemberIds == null || garpMemberIds.isEmpty()) {
            result.statusCode = 200;
            result.message = 'No IDs to search';
            return result;
        }

        // HubSpot may limit request size; chunk to stay safe (e.g. 100 IDs per request)
        final Integer chunkSize = 100;
        for (Integer i = 0; i < garpMemberIds.size(); i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, garpMemberIds.size());
            List<String> chunk = new List<String>();
            for (Integer j = i; j < endIdx; j++) {
                String gid = garpMemberIds[j];
                if (gid != null && gid.length() > 0) {
                    chunk.add(gid.trim());
                }
            }
            if (chunk.isEmpty()) {
                continue;
            }

            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();

            String endpoint = Label.GARP_HubSpot_Endpoint;
            endpoint += '/crm/v3/objects/contacts/search';
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByGarpMemberIds', 'endpoint', endpoint);

            reqGetContactsByGarpMemberIds req = new reqGetContactsByGarpMemberIds();
            req.properties = new List<String>{ 'email', 'garp_member_id__c', 'salesforcecontactid' };
            req.filterGroups = new List<reqGetContactFilterGroupsWithValues>();
            reqGetContactFilterGroupsWithValues filterGroup = new reqGetContactFilterGroupsWithValues();
            filterGroup.filters = new List<reqGetContactFilterGroupsFiltersWithValues>();
            reqGetContactFilterGroupsFiltersWithValues filter = new reqGetContactFilterGroupsFiltersWithValues();
            filter.propertyName = 'garp_member_id__c';
            filter.operator = 'IN';
            filter.values = chunk;
            filterGroup.filters.add(filter);
            req.filterGroups.add(filterGroup);

            String jsonBody = JSON.serialize(req);
            request.setBody(jsonBody);
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByGarpMemberIds', 'jsonBody', jsonBody);

            request.setEndPoint(endpoint);
            System.debug('HubSpot endpoint: ' + endpoint);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            String authorizationHeader = 'Bearer ' + Label.GARP_HubSpot_Access_Token;
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Auth-Type', 'system user');

            HttpResponse response;
            Integer statusCode;
            if (!Test.isRunningTest()) {
                response = httpProtocol.send(request);
                statusCode = response.getStatusCode();
            } else {
                response = new HttpResponse();
                statusCode = 200;
            }
            System.debug('HubSpot statusCode: ' + statusCode);
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByGarpMemberIds', 'statusCode', statusCode);

            String respbody;
            if (!Test.isRunningTest()) {
                respbody = response.getBody();
            } else {
                respbody = '{"total":2,"results":[{"id":"1","properties":{"garp_member_id__c":"857362"}},{"id":"2","properties":{"garp_member_id__c":"999"}}]}';
            }

            if (statusCode != 200) {
                result.statusCode = statusCode;
                result.message = respbody != null ? respbody.abbreviate(255) : 'Request failed';
                return result;
            }

            respbody = respbody.replace('garp_member_id__c', 'garpMemberIdSTR');
            respGetContact resp = (respGetContact) JSON.deserialize(respbody, respGetContact.class);
            if (resp != null && resp.results != null) {
                for (respGetContactResults r : resp.results) {
                    if (r.properties != null && r.properties.garpMemberIdSTR != null && r.properties.garpMemberIdSTR.length() > 0) {
                        result.garpMemberIdsFound.add(r.properties.garpMemberIdSTR.trim());
                    }
                }
            }
        }

        result.statusCode = 200;
        result.message = 'Found ' + result.garpMemberIdsFound.size() + ' contacts in HubSpot';
        GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByGarpMemberIds', 'garpMemberIdsFound', result.garpMemberIdsFound);
        return result;
    }

    /**
     * Search HubSpot contacts by email (batch).
     * Uses CRM v3 search with IN operator. Returns the set of emails (lowercase) that were found.
     */
    public static returnGetContactsByEmails sendGetContactsByEmails(List<String> emails) {
        returnGetContactsByEmails result = new returnGetContactsByEmails();
        result.emailsFound = new Set<String>();

        if (emails == null || emails.isEmpty()) {
            result.statusCode = 200;
            result.message = 'No emails to search';
            return result;
        }

        List<String> normalized = new List<String>();
        for (String e : emails) {
            if (e != null && String.isNotBlank(e)) {
                normalized.add(e.trim().toLowerCase());
            }
        }
        if (normalized.isEmpty()) {
            result.statusCode = 200;
            result.message = 'No valid emails to search';
            return result;
        }

        final Integer chunkSize = 100;
        for (Integer i = 0; i < normalized.size(); i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, normalized.size());
            List<String> chunk = new List<String>();
            for (Integer j = i; j < endIdx; j++) {
                chunk.add(normalized[j]);
            }

            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();

            String endpoint = Label.GARP_HubSpot_Endpoint;
            endpoint += '/crm/v3/objects/contacts/search';
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByEmails', 'endpoint', endpoint);

            reqGetContactsByGarpMemberIds req = new reqGetContactsByGarpMemberIds();
            req.properties = new List<String>{ 'email', 'garp_member_id__c', 'salesforcecontactid' };
            req.filterGroups = new List<reqGetContactFilterGroupsWithValues>();
            reqGetContactFilterGroupsWithValues filterGroup = new reqGetContactFilterGroupsWithValues();
            filterGroup.filters = new List<reqGetContactFilterGroupsFiltersWithValues>();
            reqGetContactFilterGroupsFiltersWithValues filter = new reqGetContactFilterGroupsFiltersWithValues();
            filter.propertyName = 'email';
            filter.operator = 'IN';
            filter.values = chunk;
            filterGroup.filters.add(filter);
            req.filterGroups.add(filterGroup);

            String jsonBody = JSON.serialize(req);
            request.setBody(jsonBody);
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByEmails', 'jsonBody', jsonBody);

            request.setEndPoint(endpoint);
            System.debug('HubSpot endpoint: ' + endpoint);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            String authorizationHeader = 'Bearer ' + Label.GARP_HubSpot_Access_Token;
            request.setHeader('Authorization', authorizationHeader);
            request.setHeader('Auth-Type', 'system user');

            HttpResponse response;
            Integer statusCode;
            if (!Test.isRunningTest()) {
                response = httpProtocol.send(request);
                statusCode = response.getStatusCode();
            } else {
                response = new HttpResponse();
                statusCode = 200;
            }
            System.debug('HubSpot statusCode: ' + statusCode);
            GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByEmails', 'statusCode', statusCode);

            String respbody;
            if (!Test.isRunningTest()) {
                respbody = response.getBody();
            } else {
                respbody = '{"total":2,"results":[{"id":"1","properties":{"email":"a@b.com"}},{"id":"2","properties":{"email":"c@d.com"}}]}';
            }

            if (statusCode != 200) {
                result.statusCode = statusCode;
                result.message = respbody != null ? respbody.abbreviate(255) : 'Request failed';
                return result;
            }

            respbody = respbody.replace('garp_member_id__c', 'garpMemberIdSTR');
            respGetContact resp = (respGetContact) JSON.deserialize(respbody, respGetContact.class);
            if (resp != null && resp.results != null) {
                for (respGetContactResults r : resp.results) {
                    if (r.properties != null && r.properties.email != null && r.properties.email.length() > 0) {
                        result.emailsFound.add(r.properties.email.trim().toLowerCase());
                    }
                }
            }
        }

        result.statusCode = 200;
        result.message = 'Found ' + result.emailsFound.size() + ' contacts by email in HubSpot';
        GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByEmails', 'emailsFound', result.emailsFound);
        return result;
    }

    /**
     * Single callout: search HubSpot by (email IN emails OR garp_member_id__c IN garpMemberIds).
     * Use for contexts with a 1-callout limit (e.g. batch execute). Capped at 100 emails and 100 GARP IDs per request.
     */
    public static returnGetContactsByEmailOrGarpId sendGetContactsByEmailOrGarpId(List<String> emails, List<String> garpMemberIds) {
        returnGetContactsByEmailOrGarpId result = new returnGetContactsByEmailOrGarpId();
        result.emailsFound = new Set<String>();
        result.garpMemberIdsFound = new Set<String>();
        result.emailToHubSpotId = new Map<String, String>();
        result.garpIdToHubSpotId = new Map<String, String>();
        result.emailToLifecycleStage = new Map<String, String>();
        result.garpIdToLifecycleStage = new Map<String, String>();

        List<String> emailList = new List<String>();
        if (emails != null) {
            for (String e : emails) {
                if (e != null && String.isNotBlank(e)) {
                    emailList.add(e.trim().toLowerCase());
                }
            }
        }
        List<String> garpList = new List<String>();
        if (garpMemberIds != null) {
            for (String g : garpMemberIds) {
                if (g != null && String.isNotBlank(g)) {
                    garpList.add(g.trim());
                }
            }
        }
        if (emailList.isEmpty() && garpList.isEmpty()) {
            result.statusCode = 200;
            result.message = 'No emails or GARP IDs to search';
            return result;
        }

        final Integer maxPerFilter = 100;
        if (emailList.size() > maxPerFilter) {
            List<String> trimmed = new List<String>();
            Set<String> seen = new Set<String>();
            for (String e : emailList) {
                if (seen.add(e) && trimmed.size() < maxPerFilter) {
                    trimmed.add(e);
                }
            }
            emailList = trimmed;
        }
        if (garpList.size() > maxPerFilter) {
            List<String> trimmed = new List<String>();
            Set<String> seen = new Set<String>();
            for (String g : garpList) {
                if (seen.add(g) && trimmed.size() < maxPerFilter) {
                    trimmed.add(g);
                }
            }
            garpList = trimmed;
        }

        Http httpProtocol = new Http();
        HttpRequest request = new HttpRequest();

        String endpoint = Label.GARP_HubSpot_Endpoint;
        endpoint += '/crm/v3/objects/contacts/search';
        GARP_Common.debugLog('HubSpotClass', 'sendGetContactsByEmailOrGarpId', 'endpoint', endpoint);

        reqGetContactsByGarpMemberIds req = new reqGetContactsByGarpMemberIds();
        req.properties = new List<String>{ 'email', 'garp_member_id__c', 'salesforcecontactid', 'lifecyclestage' };
        req.filterGroups = new List<reqGetContactFilterGroupsWithValues>();

        if (!emailList.isEmpty()) {
            reqGetContactFilterGroupsWithValues fgEmail = new reqGetContactFilterGroupsWithValues();
            fgEmail.filters = new List<reqGetContactFilterGroupsFiltersWithValues>();
            reqGetContactFilterGroupsFiltersWithValues fEmail = new reqGetContactFilterGroupsFiltersWithValues();
            fEmail.propertyName = 'email';
            fEmail.operator = 'IN';
            fEmail.values = emailList;
            fgEmail.filters.add(fEmail);
            req.filterGroups.add(fgEmail);
        }
        if (!garpList.isEmpty()) {
            reqGetContactFilterGroupsWithValues fgGarp = new reqGetContactFilterGroupsWithValues();
            fgGarp.filters = new List<reqGetContactFilterGroupsFiltersWithValues>();
            reqGetContactFilterGroupsFiltersWithValues fGarp = new reqGetContactFilterGroupsFiltersWithValues();
            fGarp.propertyName = 'garp_member_id__c';
            fGarp.operator = 'IN';
            fGarp.values = garpList;
            fgGarp.filters.add(fGarp);
            req.filterGroups.add(fgGarp);
        }

        String jsonBody = JSON.serialize(req);
        request.setBody(jsonBody);
        request.setEndPoint(endpoint);
        System.debug('HubSpot endpoint: ' + endpoint);
        request.setMethod('POST');
        request.setHeader('content-type', 'application/json');
        String authorizationHeader = 'Bearer ' + Label.GARP_HubSpot_Access_Token;
        request.setHeader('Authorization', authorizationHeader);
        request.setHeader('Auth-Type', 'system user');

        HttpResponse response;
        Integer statusCode;
        if (!Test.isRunningTest()) {
            response = httpProtocol.send(request);
            statusCode = response.getStatusCode();
        } else {
            response = new HttpResponse();
            statusCode = 200;
        }
        System.debug('HubSpot statusCode: ' + statusCode);

        String respbody;
        if (!Test.isRunningTest()) {
            respbody = response.getBody();
        } else {
            respbody = '{"total":2,"results":[{"id":"1","properties":{"email":"a@b.com","garp_member_id__c":"857362"}},{"id":"2","properties":{"email":"c@d.com","garp_member_id__c":"999"}}]}';
        }

        if (statusCode != 200) {
            result.statusCode = statusCode;
            result.message = respbody != null ? respbody.abbreviate(255) : 'Request failed';
            return result;
        }

        respbody = respbody.replace('garp_member_id__c', 'garpMemberIdSTR');
        respGetContact resp = (respGetContact) JSON.deserialize(respbody, respGetContact.class);
        if (resp != null && resp.results != null) {
            for (respGetContactResults r : resp.results) {
                String hubSpotId = (r != null && r.id != null) ? idToString(r.id) : null;
                String lifecycleStage = (r != null && r.properties != null && r.properties.lifecyclestage != null) ? r.properties.lifecyclestage.trim() : null;
                if (r.properties != null) {
                    if (r.properties.email != null && String.isNotBlank(r.properties.email)) {
                        String e = r.properties.email.trim().toLowerCase();
                        result.emailsFound.add(e);
                        if (hubSpotId != null) {
                            result.emailToHubSpotId.put(e, hubSpotId);
                        }
                        if (lifecycleStage != null) {
                            result.emailToLifecycleStage.put(e, lifecycleStage);
                        }
                    }
                    if (r.properties.garpMemberIdSTR != null && String.isNotBlank(r.properties.garpMemberIdSTR)) {
                        String g = r.properties.garpMemberIdSTR.trim();
                        result.garpMemberIdsFound.add(g);
                        if (hubSpotId != null) {
                            result.garpIdToHubSpotId.put(g, hubSpotId);
                        }
                        if (lifecycleStage != null) {
                            result.garpIdToLifecycleStage.put(g, lifecycleStage);
                        }
                    }
                }
            }
        }

        result.statusCode = 200;
        result.message = 'Found ' + result.emailsFound.size() + ' by email, ' + result.garpMemberIdsFound.size() + ' by GARP ID';
        return result;
    }

    /** Request body for batch update: one input per contact. */
    public class batchUpdateContactInput {
        public String id;
        public Map<String, String> properties;
    }
    public class batchUpdateContactsRequest {
        public List<batchUpdateContactInput> inputs;
    }

    /** Batch update a single property on multiple contacts. Uses POST /crm/v3/objects/contacts/batch/update. Chunks to 100 per callout. */
    public static Integer updateContactsBatchProperty(List<String> hubspotContactIds, String propertyName, String propertyValue) {
        if (hubspotContactIds == null || hubspotContactIds.isEmpty() || String.isBlank(propertyName)) {
            return 200;
        }
        final Integer chunkSize = 100;
        Integer lastStatusCode = 200;
        for (Integer i = 0; i < hubspotContactIds.size(); i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, hubspotContactIds.size());
            List<batchUpdateContactInput> inputs = new List<batchUpdateContactInput>();
            for (Integer j = i; j < endIdx; j++) {
                String hid = hubspotContactIds[j];
                if (hid != null && String.isNotBlank(hid)) {
                    batchUpdateContactInput input = new batchUpdateContactInput();
                    input.id = hid.trim();
                    input.properties = new Map<String, String>{ propertyName => (propertyValue != null ? propertyValue : '') };
                    inputs.add(input);
                }
            }
            if (inputs.isEmpty()) {
                continue;
            }
            batchUpdateContactsRequest req = new batchUpdateContactsRequest();
            req.inputs = inputs;
            String jsonBody = JSON.serialize(req);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = Label.GARP_HubSpot_Endpoint;
            endpoint += '/crm/v3/objects/contacts/batch/update';
            request.setEndPoint(endpoint);
            System.debug('HubSpot endpoint: ' + endpoint);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + Label.GARP_HubSpot_Access_Token);
            request.setHeader('Auth-Type', 'system user');
            request.setBody(jsonBody);
            HttpResponse response;
            Integer statusCode;
            if (!Test.isRunningTest()) {
                response = httpProtocol.send(request);
                statusCode = response.getStatusCode();
            } else {
                statusCode = 200;
            }
            System.debug('HubSpot statusCode: ' + statusCode);
            lastStatusCode = statusCode;
            if (statusCode != 200) {
                GARP_Common.debugLog('HubSpotClass', 'updateContactsBatchProperty', 'statusCode', statusCode);
                return statusCode;
            }
        }
        return lastStatusCode;
    }

    /** Search deals by Display Invoice Number (property display_invoice_number__c). Returns invoice number -> deal id. */
    public static Map<String, String> sendGetDealsByInvoiceNumbers(List<String> invoiceNumbers) {
        Map<String, String> invoiceToDealId = new Map<String, String>();
        if (invoiceNumbers == null || invoiceNumbers.isEmpty()) {
            return invoiceToDealId;
        }
        List<String> cleaned = new List<String>();
        for (String inv : invoiceNumbers) {
            if (inv != null && String.isNotBlank(inv)) {
                cleaned.add(inv.trim());
            }
        }
        if (cleaned.isEmpty()) {
            return invoiceToDealId;
        }
        final Integer chunkSize = 100;
        for (Integer i = 0; i < cleaned.size(); i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, cleaned.size());
            List<String> chunk = new List<String>();
            for (Integer j = i; j < endIdx; j++) {
                chunk.add(cleaned[j]);
            }
            // HubSpot IN filter for string properties requires lowercase values
            List<String> chunkLower = new List<String>();
            for (String s : chunk) {
                chunkLower.add(s != null ? s.toLowerCase() : '');
            }
            reqGetContactsByGarpMemberIds req = new reqGetContactsByGarpMemberIds();
            req.properties = new List<String>{ 'display_invoice_number__c' };
            req.filterGroups = new List<reqGetContactFilterGroupsWithValues>();
            reqGetContactFilterGroupsWithValues fg = new reqGetContactFilterGroupsWithValues();
            fg.filters = new List<reqGetContactFilterGroupsFiltersWithValues>();
            reqGetContactFilterGroupsFiltersWithValues f = new reqGetContactFilterGroupsFiltersWithValues();
            f.propertyName = 'display_invoice_number__c';
            f.operator = 'IN';
            f.values = chunkLower;
            fg.filters.add(f);
            req.filterGroups.add(fg);
            String afterCursor = null;
            do {
                Map<String, Object> body = new Map<String, Object>();
                body.put('filterGroups', req.filterGroups);
                body.put('properties', req.properties);
                body.put('limit', 100);
                if (afterCursor != null) {
                    body.put('after', afterCursor);
                }
                String jsonBody = JSON.serialize(body);
                Http httpProtocol = new Http();
                HttpRequest request = new HttpRequest();
                String endpoint = Label.GARP_HubSpot_Endpoint;
                endpoint += '/crm/v3/objects/deals/search';
                request.setEndPoint(endpoint);
                System.debug('HubSpot endpoint: ' + endpoint);
                request.setMethod('POST');
                request.setHeader('content-type', 'application/json');
                request.setHeader('Authorization', 'Bearer ' + Label.GARP_HubSpot_Access_Token);
                request.setHeader('Auth-Type', 'system user');
                request.setBody(jsonBody);
                HttpResponse response;
                Integer statusCode;
                if (!Test.isRunningTest()) {
                    response = httpProtocol.send(request);
                    statusCode = response.getStatusCode();
                } else {
                    statusCode = 200;
                }
                System.debug('HubSpot statusCode: ' + statusCode);
                if (statusCode != 200) {
                    break;
                }
                String respbody = Test.isRunningTest() ? '{"total":1,"results":[{"id":"deal1","properties":{"display_invoice_number__c":"INV001"}}]}' : response.getBody();
                respbody = respbody.replace('display_invoice_number__c', 'displayInvoiceNumber');
                DealSearchResult resp = (DealSearchResult) JSON.deserialize(respbody, DealSearchResult.class);
                if (resp != null && resp.results != null) {
                    for (DealSearchResultItem r : resp.results) {
                        if (r.id != null && r.properties != null && r.properties.displayInvoiceNumber != null && String.isNotBlank(r.properties.displayInvoiceNumber)) {
                            String key = r.properties.displayInvoiceNumber.trim().toLowerCase();
                            invoiceToDealId.put(key, r.id);
                        }
                    }
                }
                afterCursor = null;
                if (resp != null && resp.paging != null && resp.paging.next != null && String.isNotBlank(resp.paging.next.after)) {
                    afterCursor = resp.paging.next.after;
                }
            } while (afterCursor != null);
        }
        return invoiceToDealId;
    }

    public class DealSearchResultProperties {
        public String displayInvoiceNumber;
    }
    public class DealSearchResultItem {
        public String id;
        public DealSearchResultProperties properties;
    }
    public class DealSearchResult {
        public List<DealSearchResultItem> results;
        public DealSearchPaging paging;
    }
    public class DealSearchPaging {
        public DealSearchPagingNext next;
    }
    public class DealSearchPagingNext {
        public String after;
    }

    /** Batch read deal-to-contact associations. Returns deal id -> list of associated contact ids. */
    public static Map<String, List<String>> getDealToContactAssociations(List<String> dealIds) {
        Map<String, List<String>> dealIdToContactIds = new Map<String, List<String>>();
        if (dealIds == null || dealIds.isEmpty()) {
            return dealIdToContactIds;
        }
        List<String> cleaned = new List<String>();
        for (String d : dealIds) {
            if (d != null && String.isNotBlank(d)) {
                cleaned.add(d.trim());
            }
        }
        if (cleaned.isEmpty()) {
            return dealIdToContactIds;
        }
        final Integer batchSize = 100;
        for (Integer i = 0; i < cleaned.size(); i += batchSize) {
            Integer endIdx = Math.min(i + batchSize, cleaned.size());
            List<Map<String, String>> inputs = new List<Map<String, String>>();
            for (Integer j = i; j < endIdx; j++) {
                inputs.add(new Map<String, String>{ 'id' => cleaned[j] });
            }
            Map<String, Object> req = new Map<String, Object>{ 'inputs' => inputs };
            String jsonBody = JSON.serialize(req);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = Label.GARP_HubSpot_Endpoint;
            endpoint += '/crm/v4/associations/deals/contacts/batch/read';
            request.setEndPoint(endpoint);
            System.debug(LoggingLevel.INFO, 'getDealToContactAssociations endpoint: ' + endpoint);
            System.debug(LoggingLevel.INFO, 'getDealToContactAssociations body: ' + jsonBody);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + Label.GARP_HubSpot_Access_Token);
            request.setHeader('Auth-Type', 'system user');
            request.setBody(jsonBody);
            HttpResponse response;
            Integer statusCode;
            if (!Test.isRunningTest()) {
                response = httpProtocol.send(request);
                statusCode = response.getStatusCode();
                System.debug(LoggingLevel.INFO, 'getDealToContactAssociations statusCode: ' + statusCode);
                System.debug(LoggingLevel.INFO, 'getDealToContactAssociations raw response: ' + (response.getBody() != null ? response.getBody() : 'null'));
            } else {
                statusCode = 200;
            }
            // 207 Multi-Status = batch succeeded; body contains results (HubSpot uses this for batch read)
            if (statusCode != 200 && statusCode != 207) {
                continue;
            }
            String respbody = Test.isRunningTest() ? '{"results":[{"from":{"id":123},"to":[{"toObjectId":456}]}]}' : response.getBody();
            respbody = respbody.replace('"from":', '"fromObj":');
            AssocBatchReadResult assocResp = (AssocBatchReadResult) JSON.deserialize(respbody, AssocBatchReadResult.class);
            if (assocResp != null && assocResp.results != null) {
                for (AssocBatchReadItem item : assocResp.results) {
                    String dealId = item.fromObj != null ? idToString(item.fromObj.id) : null;
                    if (dealId == null) {
                        continue;
                    }
                    List<String> contactIds = new List<String>();
                    if (item.to != null) {
                        for (AssocTo to : item.to) {
                            String cid = idToString(to.toObjectId);
                            if (cid != null) {
                                contactIds.add(cid);
                            }
                        }
                    }
                    dealIdToContactIds.put(dealId, contactIds);
                }
            }
        }
        return dealIdToContactIds;
    }

    /**
     * Create default deal-to-contact associations in HubSpot (batch).
     * @param dealIds List of HubSpot deal IDs (same length as contactIds).
     * @param contactIds List of HubSpot contact IDs (same length as dealIds); pair by index.
     * @return Number of associations successfully requested (per chunk 200); or -1 on request failure.
     */
    public static Integer associateDealsToContactsBatch(List<String> dealIds, List<String> contactIds) {
        if (dealIds == null || contactIds == null || dealIds.size() != contactIds.size() || dealIds.isEmpty()) {
            return 0;
        }
        List<Map<String, Map<String, String>>> allInputs = new List<Map<String, Map<String, String>>>();
        for (Integer i = 0; i < dealIds.size(); i++) {
            String d = dealIds[i] != null ? dealIds[i].trim() : null;
            String c = contactIds[i] != null ? contactIds[i].trim() : null;
            if (String.isNotBlank(d) && String.isNotBlank(c)) {
                allInputs.add(new Map<String, Map<String, String>>{
                    'from' => new Map<String, String>{ 'id' => d },
                    'to' => new Map<String, String>{ 'id' => c }
                });
            }
        }
        if (allInputs.isEmpty()) {
            return 0;
        }
        final Integer chunkSize = 100;
        Integer totalRequested = 0;
        for (Integer i = 0; i < allInputs.size(); i += chunkSize) {
            Integer endIdx = Math.min(i + chunkSize, allInputs.size());
            List<Map<String, Map<String, String>>> chunk = new List<Map<String, Map<String, String>>>();
            for (Integer j = i; j < endIdx; j++) {
                chunk.add(allInputs[j]);
            }
            Map<String, Object> req = new Map<String, Object>{ 'inputs' => chunk };
            String jsonBody = JSON.serialize(req);
            Http httpProtocol = new Http();
            HttpRequest request = new HttpRequest();
            String endpoint = Label.GARP_HubSpot_Endpoint;
            endpoint += '/crm/v4/associations/deals/contacts/batch/associate/default';
            request.setEndPoint(endpoint);
            request.setMethod('POST');
            request.setHeader('content-type', 'application/json');
            request.setHeader('Authorization', 'Bearer ' + Label.GARP_HubSpot_Access_Token);
            request.setHeader('Auth-Type', 'system user');
            request.setBody(jsonBody);
            HttpResponse response;
            Integer statusCode;
            if (!Test.isRunningTest()) {
                response = httpProtocol.send(request);
                statusCode = response.getStatusCode();
            } else {
                statusCode = 200;
            }
            if (statusCode != 200 && statusCode != 207) {
                return -1;
            }
            totalRequested += chunk.size();
        }
        return totalRequested;
    }

    /** HubSpot may return IDs as number or string in JSON; normalize to string for comparison. */
    private static String idToString(Object idVal) {
        if (idVal == null) { return null; }
        if (idVal instanceof String) { return (String) idVal; }
        return String.valueOf(idVal);
    }

    public class AssocTo {
        /** HubSpot returns toObjectId as number; Long supports JSON number. Apex cannot deserialize into Object. */
        public Long toObjectId;
    }
    public class AssocBatchReadItem {
        public AssocFrom fromObj;
        public List<AssocTo> to;
    }
    public class AssocFrom {
        /** HubSpot returns id as number; Long supports JSON number. */
        public Long id;
    }
    public class AssocBatchReadResult {
        public List<AssocBatchReadItem> results;
    }

    public class returnUpdateContactEmail {
        public Integer statusCode;
        public String message;
        public List<API_Transaction__c> apiTrans;
    }
    
    @future (callout=true)
    public static void updateContactEmailAsync(String salesforceContactId, String email) {
        returnUpdateContactEmail ret = updateContactEmail(salesforceContactId, email);
        
        if(!ret.apiTrans.IsEmpty()) {
            insert ret.apiTrans;
        }
    }
    
    public static returnUpdateContactEmail updateContactEmail(String salesforceContactId, String email) {
        GARP_Common.debugLog('HubSpotClass','updateContactEmail','salesforceContactId',salesforceContactId);
        GARP_Common.debugLog('HubSpotClass','updateContactEmail','email',email);
        
        returnUpdateContactEmail ret = new returnUpdateContactEmail();
        
        if(salesforceContactId == NULL || email == NULL) {
            ret.statusCode = 501;
            ret.message = 'Missing required params';
            return ret;
        }
        
        ret.apiTrans = new List<API_Transaction__c>();
        
        returnGetContact returnGetContact = sendGetContact(salesforceContactId);
        if(returnGetContact.apiTrans != NULL) {
            ret.apiTrans.add(returnGetContact.apiTrans);
        }
        
        if(returnGetContact.statusCode != 200) {
            ret.statusCode = 502;
            ret.message = 'Error in get contact API call';
            return ret;            
        }
        
        String contactId;
        if(returnGetContact.respGetContact != NULL && returnGetContact.respGetContact.total > 0 && returnGetContact.respGetContact.results != NULL && !returnGetContact.respGetContact.results.IsEmpty()) {
            respGetContactResults result = returnGetContact.respGetContact.results[0];
            if(result.id != NULL) {
            	contactId = result.id;
            }
        }
        
        if(contactId != NULL) {
            
            returnSendUpdateContact returnSendUpdateContact = sendUpdateContactEmail(contactId, email, salesforceContactId);

            if(returnSendUpdateContact.apiTrans != NULL) {
                ret.apiTrans.add(returnSendUpdateContact.apiTrans);
            }
            
            if(returnSendUpdateContact.statusCode != 204) {
                ret.statusCode = 503;
                ret.message = 'Error in update contact API call';
                return ret;            
            }
            
        } else {
            ret.statusCode = 401;
            ret.message = 'Contact Not Found';
            return ret;            
        }
        
        
        ret.statusCode = 200;
        ret.message = 'Contact Upodated';
        
        GARP_Common.debugLog('HubSpotClass','updateContactEmail','ret',ret);
        return ret;
        
    }
    
}