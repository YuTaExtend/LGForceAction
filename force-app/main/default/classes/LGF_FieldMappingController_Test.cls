@isTest
private class LGF_FieldMappingController_Test {

    @isTest
    static void testFieldMappings() {
        LGF_Template__c template = 
            new LGF_Template__c(
                Name = 'TEST_TEMPLATE'
                , ContentDocumentId__c = '123456789012345678'
                , ObjectApiName__c = 'Account'
                , OutputFileName__c = 'TEST_OUTPUT'
                , IsActive__c = true
            );
        insert template;

        Test.startTest();
        List<LGF_FieldMapping__c> fieldMappings;
        fieldMappings = LGF_FieldMappingController.getFieldMappings(null);
        System.assertEquals(null, fieldMappings);
        fieldMappings = LGF_FieldMappingController.getFieldMappings(template.Id);
        System.assertEquals(0, fieldMappings.size());
        LGF_FieldMappingController.deleteAndInsertFieldMappings(fieldMappings, template.Id);
        System.assertEquals(0, fieldMappings.size());
        fieldMappings.add(new LGF_FieldMapping__c(Name = 'TEST_1', FieldApiName__c = 'TEST_001', LGF_Template__c = template.Id));
        fieldMappings.add(new LGF_FieldMapping__c(Name = 'TEST_2', FieldApiName__c = 'TEST_002', LGF_Template__c = template.Id));
        LGF_FieldMappingController.deleteAndInsertFieldMappings(fieldMappings, template.Id);
        fieldMappings = LGF_FieldMappingController.getFieldMappings(template.Id);
        System.assertEquals(2, fieldMappings.size());
        try{
            fieldMappings.add(new LGF_FieldMapping__c(FieldApiName__c = 'TEST_001', LGF_Template__c = template.Id));
            LGF_FieldMappingController.deleteAndInsertFieldMappings(fieldMappings, template.Id);
            System.assert(false);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        fieldMappings.remove(fieldMappings.size() - 1);
        try{
            fieldMappings.add(new LGF_FieldMapping__c(Name = 'TEST_1', FieldApiName__c = 'TEST_001', LGF_Template__c = template.Id));
            LGF_FieldMappingController.deleteAndInsertFieldMappings(fieldMappings, template.Id);
            System.assert(false);
        }catch(Exception e){
            System.debug(e.getMessage());
        }
        Test.stopTest();
    }
}