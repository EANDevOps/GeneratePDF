import { LightningElement, api, wire, track} from 'lwc';
import templateOptions from '@salesforce/apex/GeneratePDFController.emailTemplateOptions';
import generatePdf from '@salesforce/apex/GeneratePDFController.generatePdfFile';
import validateConfig from '@salesforce/apex/GeneratePDFController.validateConfig';

import { util } from 'c/generatePdfUtil';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

export default class GeneratePDF extends LightningElement {
    @api recordId;
    @api communityPath;
    @api parentField;
    @api isOnSidebar;
    @api disableEmail;
    @api enabledFolders;
    
    @track type = util.preference[0];
    @track validConfig = false;
    @track isLoading = false;

    options;
    fileTemplate;

    get typeOptions() {
        return util.typeOptions.filter(option => {
            if (this.disableEmail) {
                return option.label != 'Email';
            }
            return option;
        });
    }

    connectedCallback() {

        this.getTemplateOptions();
        this.checkComponentValidity();
    }

    checkComponentValidity() {
        validateConfig({recordId: this.recordId, parentField: this.parentField })
            .then(result => {
                this.validConfig = result;
            });
    }

    getTemplateOptions() {
        templateOptions({enabledFolders: this.enabledFolders})
            .then(result => {
                this.options = result;
            })
            .catch(error => {
                console.log(error);
            });
    }
    
    handlePdfFileSelect(event) {
        event.stopPropagation();

        this.fileTemplate = event.detail.value;
    }

    handlePreview(event) {
        if (this.fileTemplate == null) {
            this.showToast('Error', util.messages.BLANK_TEMPLATE, 'error');
            return;
        }
        
        this.template.querySelector('c-generate-pdf-preview')
            .init(this.fileTemplate);
    }

    handleTypeChange(event) {
        this.type = event.detail.value;
        this.fileTemplate = null;
    }

    handleCardAction(event) {

        if (this.fileTemplate == null) {
            this.showToast('Error', util.messages.BLANK_TEMPLATE, 'error');
            return;
        }

        // PDF
        if (this.type == util.preference[0]) {

            this.isLoading = true;

            generatePdf({fileTemplateId: this.fileTemplate.value, recordId: this.recordId, parentField : this.parentField})
                .then(result => {

                    this.isLoading = false;
                    this.showToast('Success!', util.messages.CARD_ACTION_PDF_SUCCESS, 'success');
                    this.template.querySelector('c-generate-pdf-history').getTableData();
                })
                .catch(error => {
                    this.showToast('Error!', util.messages.CARD_ACTION_ERROR, 'error');
                });
        }
    }
    
    get buttonLabel() {
        return util.buttonLabelMap[this.type];
    }
    get iconName() {
        return util.iconMap[this.type];
    }
    get isPDF() {
        return this.type == util.preference[0];
    }
    get isEmail() {
        return this.type == util.preference[1];
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            variant: variant,
            title: title,
            message: message
        });
        this.dispatchEvent(event);
    }
}