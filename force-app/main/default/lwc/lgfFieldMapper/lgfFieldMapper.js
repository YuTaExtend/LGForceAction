import { LightningElement, api, wire } from "lwc";
import getFieldMappings from "@salesforce/apex/LGF_FieldMappingController.getFieldMappings";
import deleteAndInsertFieldMappings from "@salesforce/apex/LGF_FieldMappingController.deleteAndInsertFieldMappings";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import FIELD_MAPPING_OBJECT from "@salesforce/schema/LGF_FieldMapping__c";
import ToastContainer from "lightning/toastContainer";
import Toast from "lightning/toast";

export default class LgfFieldMapper extends LightningElement {
  @api
  recordId;
  fieldMappings = [];
  showSpinner = false;

  @wire(getObjectInfo, { objectApiName: FIELD_MAPPING_OBJECT })
  fieldMappingObjectInfo;

  async connectedCallback() {
    const toastContainer = ToastContainer.instance();
    toastContainer.maxToasts = 5;
    toastContainer.toastPosition = "top-center";

    this.showSpinner = true;
    this.fieldMappings = await getFieldMappings({ recordId: this.recordId });
    this.showSpinner = false;
  }

  handleChangeField(event) {
    this.fieldMappings.forEach((fieldMapping) => {
      if (fieldMapping.Id === event.target.dataset.id) {
        fieldMapping[event.target.dataset.field] = event.target.value;
      }
    });
  }

  handleClickDelete(event) {
    this.fieldMappings = this.fieldMappings.filter((fieldMapping) => {
      return fieldMapping.Id !== event.target.dataset.info;
    });
  }

  handleClickAdd() {
    this.fieldMappings.push({
      Id: String(this.fieldMappings.length + 1),
      Template__c: this.recordId,
      Name: "",
      FieldApiName__c: ""
    });
    this.fieldMappings = [...this.fieldMappings];
  }

  async handleClickReload() {
    await this.connectedCallback();
  }

  async handleClickSave() {
    this.showSpinner = true;
    try {
      await deleteAndInsertFieldMappings({
        fieldMappings: this.fieldMappings,
        templateId: this.recordId
      });
    } catch (e) {
      Toast.show(
        {
          label: "ERROR",
          message: e?.body?.message ? JSON.stringify(e.body.message) : JSON.stringify(e),
          variant: "error"
        },
        this
      );
    }
    await this.connectedCallback();
    this.showSpinner = false;
  }
}