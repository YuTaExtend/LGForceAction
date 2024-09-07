@isTest
global class LGF_Action_Test {
  @isTest
  static void testLGFAction() {
    LGF_Template__c template = new LGF_Template__c(
      Name = 'TEST_TEMPLATE',
      ContentDocumentId__c = '123456789012345678',
      ObjectApiName__c = 'Template__c',
      OutputFileName__c = 'TEST_OUTPUT',
      IsActive__c = true
    );
    insert template;
    LGF_FieldMapping__c fieldMapping = new LGF_FieldMapping__c(
      Name = 'TEST',
      FieldApiName__c = 'TEST_NAME',
      LGF_Template__c = template.Id
    );
    insert fieldMapping;

    ContentVersion contentVersion = new ContentVersion();
    contentVersion.Title = 'TEST_CONTENT';
    contentVersion.PathOnClient = '/' + contentVersion.Title + '.jpg';
    Blob bodyBlob = Blob.valueOf('Unit Test ContentVersion Body');
    contentVersion.VersionData = bodyBlob;
    contentVersion.origin = 'H';
    insert contentVersion;
    contentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion LIMIT 1];

    LGF_Action.LGFAParam param = new LGF_Action.LGFAParam();
    param.recordId = template.Id;

    Test.startTest();
    try {
      LGF_Action.convertExcelToPDF(param);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
    param.templateId = template.Id;
    try {
      LGF_Action.convertExcelToPDF(param);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
    System.debug(contentVersion);
    template.ContentDocumentId__c = contentVersion.ContentDocumentId;
    update template;
    try {
      LGF_Action.convertExcelToPDF(param);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
    fieldMapping.FieldApiName__c = 'Name';
    update fieldMapping;

    callApi(template.Id, 404);
    callApi(template.Id, 500);
    callApi(template.Id, 200);

    Test.stopTest();
  }

  @Future(callout=true)
  static void callApi(Id templateId, Integer statusCode) {
    LGF_Action.LGFAParam param = new LGF_Action.LGFAParam();
    param.recordId = templateId;
    param.templateId = templateId;
    Test.setMock(
      HttpCalloutMock.class,
      new MockHttpResponseGenerator(statusCode)
    );
    try {
      LGF_Action.LGFAResult result = LGF_Action.convertExcelToPDF(param);
      System.assertEquals('TEST_PDF_DATA', result.pdfData);
      System.assertEquals('TEST_OUTPUT_FILE_NAME', result.outputFileName);
    } catch (Exception e) {
      System.debug(e.getMessage());
    }
  }

  global class MockHttpResponseGenerator implements HttpCalloutMock {
    public Integer statusCode { get; set; }
    public MockHttpResponseGenerator(Integer statusCode) {
      this.statusCode = statusCode;
    }
    global HTTPResponse respond(HTTPRequest req) {
      HttpResponse res = new HttpResponse();
      res.setHeader('Content-Type', 'application/json');
      res.setBody(
        '{"pdfData":"TEST_PDF_DATA","outputFileName":"TEST_OUTPUT_FILE_NAME"}'
      );
      res.setStatusCode(this.statusCode);
      return res;
    }
  }
}
