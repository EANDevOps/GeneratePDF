import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import tableData from '@salesforce/apex/GeneratePDFController.getTableData';

export default class GeneratePDFHistory extends NavigationMixin(LightningElement) {
    @api recordId;
    @api parentField;
    @api isOnSidebar;
    @api communityPath;

    @track data;
    @track isLoading;

    connectedCallback() {
        this.isLoading = true;
        this.getTableData();
    }

    @api getTableData() {
        tableData({ recordId: this.recordId, parentField: this.parentField })
            .then(result => {
                this.data = result;
                this.isLoading = false;
            })
            .catch(error => {
                console.log(error);
                this.isLoading = false;
            });
    }

    handleDownload(event) {

        var url = `${this.communityPath ? `/${this.communityPath}` : ''}${event.currentTarget.dataset.ref}`;

        if (this.communityPath) {
            this[NavigationMixin.GenerateUrl]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            })
            .then(generatedUrl => {
                window.open(generatedUrl.replace('/s/', '/'), '_blank');
            });
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: url
                }
            }, false);
        }
    }

    handlePreview(event) {

        if (this.communityPath) {
            this[NavigationMixin.Navigate]({
                type: 'standard__webPage',
                attributes: {
                    url: '/contentdocument/' + event.currentTarget.dataset.ref.substring(event.currentTarget.dataset.ref.length - 18)
                }
            }, false);
        } else {
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'filePreview'
                },
                state: {
                    selectedRecordId: event.currentTarget.dataset.ref.substring(event.currentTarget.dataset.ref.length - 18)
                }
            })
        }
    }

    get headers() {
        return this.data ? this.data.fieldLabels : [];
    }

    get histories() {

        if (!this.data || !this.data.fieldNames.length || !this.data.records.length) return [];

        var histories = [];
        var rowCount = 0;

        for (var key1 in this.data.records) {
            var record = Object.assign({}, this.data.records[key1]);
            var recordValues = [];

            for (var key2 in this.data.fieldNames) {

                var fieldName = this.data.fieldNames[key2];
                var fieldType = this.data.fieldTypes[fieldName];

                var recordValue = this.transformData(fieldName, fieldType, record[fieldName]);
                var valueLabel = recordValue;
                var elClass = fieldType;

                if (fieldType == 'ID') {
                    recordValue = `/${recordValue}`;
                }

                if (fieldName == 'Name') {
                    valueLabel = recordValue;
                    recordValue = `/${record['Id']}`;
                    elClass = 'URL';
                }

                if (fieldName == 'Download_Path__c') {
                    valueLabel = '';
                    elClass = 'DOWNLOAD';
                }

                recordValues.push({ label: valueLabel, value: recordValue, class: `slds-truncate ${elClass}` });
            }

            histories.push({ row: recordValues, rowCount: rowCount });
            rowCount++;
        }

        return histories;
    }

    transformData(fieldName, fieldType, value) {

        if (!value) return '';

        switch (fieldType) {

            case 'DATE':
                new Date(value).toLocaleString('en-NZ').substring(0, 10);

            case 'DATETIME':
                return new Date(value).toLocaleString('en-NZ').substring(0, 10).replace(',', '');

            default:
                return value;
        }
    }

    get noHistory() {
        return (!this.data || !this.data.records.length) && !this.isLoading;
    }

    get hasHistory() {
        return this.data && this.data.records.length && !this.isLoading;
    }

    get containerClass() {
        return `${this.isOnSidebar ? 'onsidebar' : ''}`;
    }

    get viewAllUrl() {
        return this.data && this.data.relationshipUrl ? this.data.relationshipUrl : '';
    }
}