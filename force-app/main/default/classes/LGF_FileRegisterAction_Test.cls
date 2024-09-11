@isTest
global with sharing class LGF_FileRegisterAction_Test {
  @isTest
  static void testLGFFileRegisterAction() {
    LGF_FileRegisterAction.createContentVersion(null);
    List<LGF_FileRegisterAction.Request> requests = new List<LGF_FileRegisterAction.Request>();
    LGF_FileRegisterAction.Request request = new LGF_FileRegisterAction.Request();
    request.fileData = 'XXXXXX';
    request.fileName = 'test.xlsx';
    requests.add(request);
    LGF_FileRegisterAction.createContentVersion(requests);
  }
}
