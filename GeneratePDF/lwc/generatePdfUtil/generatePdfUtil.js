const util = {
    messages: {
        BLANK_TEMPLATE: 'No template selected, please select a template',
        CARD_ACTION_ERROR: 'Action failed, please contact your system administrator',
        CARD_ACTION_PDF_SUCCESS: 'Success! Your file is generated and attached to the record',
        CARD_ACTION_EMAIL_SUCCESS: 'Success! Your file is generated and the email was sent',
    },
    // the app is dependent on the order of this array
    preference: [
        'PDF', 'Email'
    ],
    iconMap: {
        'PDF': 'utility:attach',
        'Email': 'utility:send'
    },
    buttonLabelMap: {
        'PDF': 'Generate PDF',
        'Email': 'Send Email'
    },
    typeOptions: [
        {label: 'PDF', value: 'PDF'},
        {label: 'Email', value: 'Email'}
    ]
}

export { util };