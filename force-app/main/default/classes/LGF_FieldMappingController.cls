public with sharing class LGF_FieldMappingController {

    private class LGForceFieldMappingException extends Exception {}

    @AuraEnabled
    public static List<LGF_FieldMapping__c> getFieldMappings(Id recordId) {
    
        if(recordId == null) {
            return null;
        }
        List<LGF_FieldMapping__c> fieldMappings = 
            [SELECT Id
                , LGF_Template__c
                , Name
                , FieldApiName__c
                FROM LGF_FieldMapping__c
                WHERE LGF_Template__c = :recordId
                ORDER BY Name ASC];
        
        return fieldMappings;
    }
    
    @AuraEnabled
    public static void deleteAndInsertFieldMappings(
        List<LGF_FieldMapping__c> fieldMappings
        , Id templateId) {
        
        Savepoint sp = Database.setSavepoint();
        try {
            List<LGF_FieldMapping__c> deleteList = 
                [SELECT Id
                    FROM LGF_FieldMapping__c
                    WHERE LGF_Template__c = :templateId];
            
            delete deleteList;
            
            List<LGF_FieldMapping__c> insertList = new List<LGF_FieldMapping__c>();
            for(LGF_FieldMapping__c record : fieldMappings) {
                if(String.isBlank(record.Name)) {
                    throw new LGForceFieldMappingException(Label.LGF_ERR_F001);
                }
                insertList.add(
                    new LGF_FieldMapping__c(
                        LGF_Template__c = templateId
                        , Name = record.Name
                        , FieldApiName__c = record.FieldApiName__c));
            }
            insert insertList;
            
        } catch (Exception e) {
            Database.rollback(sp);
            System.debug(e.getMessage());
            throw new LGForceFieldMappingException(e.getMessage());
        }
    }
}