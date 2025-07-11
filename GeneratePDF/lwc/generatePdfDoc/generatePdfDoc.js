import { LightningElement, api, wire, track} from 'lwc';

export default class GeneratePDFDoc extends LightningElement {
    @api recordId;
    @api options;
    @track template;

    get templateSelected() {
        return this.template ? this.template.label : '--None--';
    }

    handleTemplateSelect(event) {
        this.template = event.detail.value;
    }

    handlePreview(event) {
        this.dispatchEvent(new CustomEvent('preview', {
            detail: this.template
        }));
    }
}