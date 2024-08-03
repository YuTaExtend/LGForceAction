global class LGF_Action {

    private class LGFActionException extends Exception {}

    global class LGFAParam {
        @AuraEnabled
        global Id recordId { get; set; }
        @AuraEnabled
        global Id templateId { get; set; }
    }

    global class LGFAResult {
        @AuraEnabled
        global String pdfData { get; set; }
        @AuraEnabled
        global String outputFileName { get; set; }
    }

    @AuraEnabled
    global static LGFAResult convertExcelToPDF(LGFAParam param) {

        system.debug(param);
        Id recordId;
        Id templateId;
        try {
            recordId = Id.valueOf(param.recordId);
            templateId = Id.valueOf(param.templateId);
        } catch (Exception e) {
            throw new LGFActionException(Label.LGF_ERR_S001);
        }

        LGF_Template__c template;
        List<LGF_FieldMapping__c> fieldMappings;
        String versionNumber;
        Blob templateData;
        try {
            String soql = 'SELECT Id ';
            soql += ', ObjectApiName__c ';
            soql += ', ContentDocumentId__c ';
            soql += ', OutputFileName__c ';
            soql += 'FROM LGF_Template__c ';
            soql += 'WHERE IsActive__c = true ';
            soql += 'AND Id = \'' + String.escapeSingleQuotes(templateId) + '\' ';
            soql += 'ORDER BY CreatedDate DESC ';
            soql += 'LIMIT 1';
            System.debug(soql);
            List<LGF_Template__c> templates = Database.query(soql);
            template = templates[0];
            ContentDocument cd = 
                [SELECT Id
                    , LatestPublishedVersion.VersionNumber
                    , LatestPublishedVersion.VersionData
                    FROM ContentDocument
                    WHERE Id = :template.ContentDocumentId__c
                    LIMIT 1];
            versionNumber = cd.LatestPublishedVersion.VersionNumber;
            templateData = cd.LatestPublishedVersion.VersionData;
            if(templateData == null) {
                throw new LGFActionException();
            }
            fieldMappings = 
                [SELECT Id
                    , Name
                    , FieldApiName__c
                    FROM LGF_FieldMapping__c
                    WHERE LGF_Template__c = :template.Id];
        } catch (Exception e) {
            throw new LGFActionException(Label.LGF_ERR_S002);
        }

        String body;
        try {
            String soql = 'SELECT Id ';
            for(LGF_FieldMapping__c fieldMapping : fieldMappings) {
                soql += ', ' + fieldMapping.FieldApiName__c + ' ';
            }
            soql += 'FROM ' + String.escapeSingleQuotes(template.ObjectApiName__c) + ' ';
            soql += 'WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\' ';
            soql += 'LIMIT 1';
            System.debug(soql);
            List<SObject> records = Database.query(soql);
            body = '{';
            body += '"fieldMappings":' + JSON.serialize(fieldMappings) + ',';
            body += '"record":' + JSON.serialize(records[0]) + ',';
            body += '"fileName":' + JSON.serialize(template.OutputFileName__c) + ',';
            body += '"templateData":' + JSON.serialize(EncodingUtil.base64Encode(templateData)) + ',';
            body += '"organizationId":' + JSON.serialize(UserInfo.getOrganizationId()) + ',';
            body += '"apiKey":' + JSON.serialize(Label.LGF_API_KEY);
            body += '}';
            System.debug(body);
        } catch (Exception e) {
            throw new LGFActionException(Label.LGF_ERR_S003);
        }

        LGFAResult result;
        try {
            Http h = new Http();
            HttpRequest req = new HttpRequest();
            req.setEndpoint(Label.LGF_ENDPOINT_URL);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json;charset=UTF-8');
            req.setBody(body);
            req.setTimeout(60000);
            System.debug('callout start: ' + req);
            System.debug(req.getBody());
            HttpResponse res = h.send(req);
            System.debug('callout done: ' + res);
            if(res.getStatusCode() == 200) {
                result = (LGFAResult) JSON.deserialize(res.getBody(), LGFAResult.class);
            } else if(res.getStatusCode() == 404) {
                throw new LGFActionException(res.getBody());
            } else {
                throw new LGFActionException('An unexpected error has occurred. Status code: ' + res.getStatusCode());
            }
            System.debug(result);
        } catch (Exception e) {
            throw new LGFActionException(Label.LGF_ERR_S004 + e.getMessage());
        }

        return result;
    }
}