import { LightningElement, api, wire, track} from 'lwc';

export default class GenerateNotification extends LightningElement {
    @api options;
    @api label;
    @api value;
    @api required = false;

    @track selected;

    get selectOptions() {
        // just return on init
        if (!this.options) return [];

        var theOptions = [];
        var theUngrouped = [];

        for (var key in this.options) {
            var option = Object.assign({}, this.options[key]);

            // mark selected option if an item is selected
            option.selected = this.selected && option.value === this.selected.value ? this.selected.selected : option.selected;

            // find the group of the option, not yet grouped if empty
            var theGroup = theOptions.filter(theOption => {
                return theOption.group && option.group && theOption.group == option.group;
            });
            
            if (theGroup.length) {
                theGroup[0].items.push(option);
            } else {
                if (option.group && option.group.length > 0) {
                    theOptions.push({hasgroup: true, group: option.group, items: [option]});
                } else {
                    theUngrouped.push({hasgroup: false, group: '', items: [option]});
                }
            }
        }
        theOptions = theOptions.concat(theUngrouped);

        return theOptions;
    }

    handleToggle(event) {
        event.currentTarget.classList.toggle('active');
    }

    preventDefault(event) {
        event.preventDefault();
    }

    handleSelect(event) {
        // find the selected option from the main list
        var selected = this.options.filter(option => {
            return option.value === event.currentTarget.dataset.value;
        });

        this.selected = selected.length ? Object.assign({}, selected[0]) : null;
        
        // Mark as selected
        if (this.selected) {
            this.selected.selected = true;
        }

        // dispatch to parent
        this.dispatchEvent(new CustomEvent('select', {
            detail: {value: this.selected},
            bubbles: true,
            composed: true
        }));

        this.validate();
        this.template.querySelector('.slds-input').classList.remove('active');
    }

    handleBlur(event) {
        setTimeout(function(event) {
            this.template.querySelector('.slds-input').classList.remove('active');
            this.validate();
        }.bind(this), 100);
    }

    validate() {
        var combobox = this.template.querySelector('.custom-combobox');

        if (this.required && this.selected == null) {
            combobox.classList.add('slds-has-error');
        } else {
            combobox.classList.remove('slds-has-error');
        }
    }
}