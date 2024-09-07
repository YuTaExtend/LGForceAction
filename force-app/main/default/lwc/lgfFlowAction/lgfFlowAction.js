import { LightningElement, api } from "lwc";
import convertExcelToPDF from "@salesforce/apex/LGF_Action.convertExcelToPDF";

export default class LgfFlowAction extends LightningElement {
  @api recordId;
  @api templateId;
  @api outputFileName;
  @api pdfData;
  @api requireDownload;
  message;
  showSpinner = false;

  async connectedCallback() {
    this.showSpinner = true;
    try {
      const result = await convertExcelToPDF({
        param: {
          recordId: this.recordId,
          templateId: this.templateId
        }
      });
      if (result && !this.message) {
        if (this.requireDownload) {
          const linkSource = `data:application/octet-stream;base64,${result.pdfData}`;
          const downloadLink = document.createElement("a");
          downloadLink.href = linkSource;
          downloadLink.download = result.outputFileName;
          downloadLink.click();
          this.message = "PDF の出力が完了しました。";
        }
        this.outputFileName = result.outputFileName;
        this.pdfData = result.pdfData;
      }
    } catch (e) {
      this.message = e?.body?.message
        ? JSON.stringify(e.body.message)
        : JSON.stringify(e);
    }
    this.showSpinner = false;
  }
}
