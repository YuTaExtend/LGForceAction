global class LGF_FileRegisterAction {
  @InvocableMethod
  public static List<Result> createContentVersion(List<Request> requests) {
    List<Result> results = new List<Result>();
    try {
      List<ContentVersion> cvs = new List<ContentVersion>();
      for (Request request : requests) {
        ContentVersion cv = new ContentVersion();
        cv.Title = request.fileName;
        cv.PathOnClient = request.fileName;
        cv.VersionData = EncodingUtil.Base64Decode(request.fileData);
        cv.IsMajorVersion = true;
        cvs.add(cv);
      }
      insert cvs;

      List<ContentVersion> createdCvs = [
        SELECT Id, ContentDocumentId
        FROM ContentVersion
        WHERE Id IN :cvs
      ];
      for (ContentVersion createdCv : createdCvs) {
        Result result = new Result();
        result.contentVersionId = createdCv.Id;
        result.contentDocumentId = createdCv.ContentDocumentId;
        result.hasError = false;
        result.errorMessage = '';
        results.add(result);
      }
    } catch (Exception e) {
      Result result = new Result();
      result.hasError = true;
      result.errorMessage = e.getMessage();
      results.add(result);
    }
    return results;
  }

  global class Request {
    @InvocableVariable(label='ファイルデータ(base64)')
    global String fileData;
    @InvocableVariable(label='ファイル名')
    global String fileName;
  }

  global class Result {
    @InvocableVariable(label='Content Version ID')
    global Id contentVersionId;
    @InvocableVariable(label='Content Document ID')
    global Id contentDocumentId;
    @InvocableVariable(label='true: エラーあり')
    global Boolean hasError;
    @InvocableVariable(label='エラーメッセージ')
    global String errorMessage;
  }
}
