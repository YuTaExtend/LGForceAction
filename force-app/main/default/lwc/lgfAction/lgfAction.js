import { LightningElement, wire, api } from "lwc";
import { CloseActionScreenEvent } from "lightning/actions";
import { CurrentPageReference } from "lightning/navigation";
import convertExcelToPDF from "@salesforce/apex/LGF_Action.convertExcelToPDF";

export default class LgforceAction extends LightningElement {
  @api
  recordId;

  @api
  objectApiName;

  @api
  templateId;

  errorMessage;

  @wire(CurrentPageReference)
  async getStateParameters(currentPageReference) {
    if (currentPageReference && !this.recordId) {
      this.recordId = currentPageReference.state.recordId;
      const backgroundContext = currentPageReference.state.backgroundContext;
      this.objectApiName = backgroundContext.split("/")[3];
      await this.init();
    }
  }

  async init() {
    const result = await convertExcelToPDF({
      param: {
        recordId: this.recordId,
        objectApiName: this.objectApiName,
        templateId: this.templateId
      }
    }).catch((error) => {
      this.errorMessage = error.body.message;
    });
    if (result && !this.errorMessage) {
      const linkSource = `data:application/octet-stream;base64,${result.pdfData}`;
      const downloadLink = document.createElement("a");
      downloadLink.href = linkSource;
      downloadLink.download = result.outputFileName;
      downloadLink.click();
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        this.dispatchEvent(new CloseActionScreenEvent());
      }, 1000);
    }
  }
}