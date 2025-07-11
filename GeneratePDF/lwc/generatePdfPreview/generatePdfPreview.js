import { LightningElement, api, wire, track} from 'lwc';

export default class GeneratePDFPreview extends LightningElement {

    @api recordId;
    @api communityPath;

    modalClass = {
        modal: 'slds-modal',
        backdrop: 'slds-backdrop',
        modalOpen: 'slds-fade-in-open',
        backdropOpen: 'slds-backdrop_open',
    }

    @track theTemplate
    @track previewUrl;
    @track isFrameLoading;

    @api init(template) {
        this.theTemplate = template;
        this.previewUrl = `${this.communityPath ? `/${this.communityPath}` : ''}/apex/GeneratePdfPreview?tid=${this.theTemplate.value}&recid=${this.recordId}`;
        this.toggleOpen();
    }

    handleLoadStart() {
        this.isFrameLoading = true;
    }

    handleLoad() {
        this.isFrameLoading = false;
    }

    get templateLabel() {
        return this.theTemplate ? this.theTemplate.label : '';
    }
    
    get iframeClass() {
        return this.isFrameLoading ? 'slds-hide' : '';
    }

    toggleOpen() {
        this.template.querySelector(`.${this.modalClass.modal}`)
            .classList.add(this.modalClass.modalOpen);

        this.template.querySelector(`.${this.modalClass.backdrop}`)
            .classList.add(this.modalClass.backdropOpen);
    }

    toggleClose() {
        this.template.querySelector(`.${this.modalClass.modal}`)
            .classList.remove(this.modalClass.modalOpen);

        this.template.querySelector(`.${this.modalClass.backdrop}`)
            .classList.remove(this.modalClass.backdropOpen);
    }
}