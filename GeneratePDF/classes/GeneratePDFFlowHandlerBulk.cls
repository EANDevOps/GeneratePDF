public with sharing class GeneratePDFFlowHandlerBulk implements Database.Batchable<SObject>, Database.Stateful {
    private String sObjectType;
    private String fileTemplateId;
    private String fileNameFields;
    private String parentField;
    private List<Id> recordIds;
 
    private String emailTemplateId;
    private String orgWideEmailAddressId;
    private String targetObjectField;
    private String emailField;

    public GeneratePDFFlowHandlerBulk(
        String sObjectType,
        String fileTemplateId,
        String fileNameFields,
        String parentField,
        List<Id> recordIds,
        String emailTemplateId,
        String orgWideEmailAddressId,
        String targetObjectField,
        String emailField
    ) {
        this.sObjectType = sObjectType;
        this.fileTemplateId = fileTemplateId;
        this.fileNameFields = fileNameFields;
        this.parentField = parentField;
        this.recordIds = recordIds;
        this.emailTemplateId = emailTemplateId;
        this.orgWideEmailAddressId = orgWideEmailAddressId;
        this.targetObjectField = targetObjectField;
        this.emailField = emailField;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        String query = 'SELECT Id'; 
         
        if (String.isNotBlank(fileNameFields)) {
            for (String field : fileNameFields.split(',')) {
                field = field.trim();
                if (field != 'Id' && String.isNotBlank(field)) {
                    query += ', ' + field;
                }
            }
        }
 
        if (String.isNotBlank(targetObjectField)) {
            query += ', ' + targetObjectField;
        }
        if (String.isNotBlank(emailField)) {
            query += ', ' + emailField;
        }
        query += ' FROM ' + sObjectType;
        if (recordIds != null && !recordIds.isEmpty()) {
            query += ' WHERE Id IN :recordIds';
        }
        return Database.getQueryLocator(query);
    }

    public void execute(Database.BatchableContext bc, List<SObject> scope) {
        for (SObject record : scope) {
            try {
                String resolvedFileName = buildFileName(fileNameFields, record);
                System.debug('Generating PDF for record: ' + record.get('Id') + ' with file name: ' + resolvedFileName);
                String fileId = GeneratePDFController.generatePdfFile(
                    fileTemplateId,
                    (String)record.get('Id'),
                    parentField,
                    resolvedFileName
                );
                System.debug('Generated PDF fileId: ' + fileId + ' for record: ' + record.get('Id'));
 
                if (String.isNotBlank(emailTemplateId)) {
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTemplateId(emailTemplateId);
                    mail.setSaveAsActivity(true);
 
                    Id targetId = null;
                    if (sObjectType == 'Contact' || sObjectType == 'Lead' || sObjectType == 'User') {
                        targetId = (Id)record.get('Id');
                    } else if (String.isNotBlank(targetObjectField)) {
                        targetId = (Id)record.get(targetObjectField);
                    }
                    if (targetId != null) {
                        mail.setTargetObjectId(targetId);
                    } else if (String.isNotBlank(emailField)) {
                        String emailAddr = (String)record.get(emailField);
                        if (emailAddr != null) {
                            mail.setToAddresses(new List<String>{emailAddr});
                        }
                    }
 
                    if (String.isNotBlank(orgWideEmailAddressId)) {
                        mail.setOrgWideEmailAddressId(orgWideEmailAddressId);
                    }
 
                    if (fileId != null) {
                        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE ContentDocumentId = :fileId ORDER BY CreatedDate DESC LIMIT 1];
                        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
                        attachment.setFileName(resolvedFileName);
                        attachment.setBody(cv.VersionData);
                        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
                    }

                    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
                }
            } catch (Exception e) {
                System.debug('Error generating PDF or sending email for record: ' + record.get('Id') + ' - ' + e.getMessage());
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        System.debug('Batch PDF generation complete.');
    }
 
    public static String buildFileName(String fileNameFields, SObject record) {
        if (String.isBlank(fileNameFields) || record == null) return 'PDF_' + record.get('Id') + '.pdf';
        List<String> parts = new List<String>();
        for (String field : fileNameFields.split(',')) {
            field = field.trim();
            Object value = record.get(field);
            parts.add(value != null ? String.valueOf(value) : '');
        }
        return String.join(parts, '-') + '.pdf';
    }
}