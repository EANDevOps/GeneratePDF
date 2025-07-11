public with sharing class GeneratePDFFlowHandler {

    @InvocableMethod(label='Generate PDF, Attach to Record, and Send Email' description='Generates a PDF from a template, attaches it to the specified record, and sends it via email (email template is required).')
    public static List<GeneratePdfResponse> generatePdf(List<GeneratePdfRequest> requests) {
        List<GeneratePdfResponse> responses = new List<GeneratePdfResponse>();
        System.debug('Starting generatePdf with ' + requests.size() + ' requests');
 
        List<String> fileIds = new List<String>();
        Map<Integer, String> requestIdxToFileId = new Map<Integer, String>();
        for (Integer i = 0; i < requests.size(); i++) {
            GeneratePdfRequest request = requests[i];
            try {
                String fileId = GeneratePDFController.generatePdfFile(request.fileTemplateId, request.recordId, request.parentField, request.fileName);
                if (String.isNotBlank(fileId)) {
                    fileIds.add(fileId);
                    requestIdxToFileId.put(i, fileId);
                }
            } catch (Exception e) { 
                GeneratePdfResponse errorResponse = new GeneratePdfResponse();
                errorResponse.fileId = null;
                errorResponse.errorMessage = 'Error generating PDF: ' + e.getMessage();
                responses.add(errorResponse);
            }
        }
 
        Map<String, ContentVersion> fileIdToContentVersion = new Map<String, ContentVersion>();
        if (!fileIds.isEmpty()) {
            for (ContentVersion cv : [
                SELECT Id, Title, VersionData, FileType, ContentDocumentId
                FROM ContentVersion
                WHERE ContentDocumentId IN :fileIds
                ORDER BY CreatedDate DESC
            ]) {
                fileIdToContentVersion.put(cv.ContentDocumentId, cv);
            }
        }
 
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Map<Integer, Integer> requestIdxToEmailIdx = new Map<Integer, Integer>();

        for (Integer i = 0; i < requests.size(); i++) {
            GeneratePdfRequest request = requests[i];
            GeneratePdfResponse response = new GeneratePdfResponse();
            String fileId = requestIdxToFileId.get(i);
            response.fileId = fileId;

            if (String.isNotBlank(fileId)) {
                ContentVersion cv = fileIdToContentVersion.get(fileId);
                if (cv == null) {
                    response.errorMessage = 'Could not find ContentVersion for fileId: ' + fileId;
                } else if (String.isNotBlank(request.emailTo)) {
                    try {
                        Messaging.SingleEmailMessage mail = buildEmail(request, cv);
                        emailsToSend.add(mail);
                        requestIdxToEmailIdx.put(i, emailsToSend.size() - 1);
                    } catch (Exception e) {
                        response.errorMessage = 'Error preparing email: ' + e.getMessage();
                    }
                }
            } else if (String.isBlank(response.errorMessage)) {
                response.errorMessage = 'PDF generation failed, no fileId returned.';
            }
            responses.add(response);
        }
 
        if (!emailsToSend.isEmpty()) {
            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend, false);
            for (Integer i = 0; i < requests.size(); i++) {
                if (requestIdxToEmailIdx.containsKey(i)) {
                    Integer emailIdx = requestIdxToEmailIdx.get(i);
                    if (results != null && results.size() > emailIdx && !results[emailIdx].isSuccess()) {
                        GeneratePdfResponse resp = responses[i];
                        resp.errorMessage = 'Email failed: ' + results[emailIdx].getErrors()[0].getMessage();
                    }
                }
            }
        }

        System.debug('Returning responses: ' + JSON.serialize(responses));
        return responses;
    }
    
    @TestVisible 
    private static Messaging.SingleEmailMessage buildEmail(GeneratePdfRequest request, ContentVersion cv) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { request.emailTo });

        if (String.isNotBlank(request.fromAddressId)) {
            mail.setOrgWideEmailAddressId(request.fromAddressId);
        }
 
        mail.setTemplateId(request.emailTemplateId);

        Boolean isLeadOrContact = String.isNotBlank(request.leadOrContactId) &&
            (request.leadOrContactId.startsWith('00Q') || request.leadOrContactId.startsWith('003'));

        if (isLeadOrContact) {
            mail.setTargetObjectId(request.leadOrContactId);
            mail.setSaveAsActivity(true);
        } else {
            if (String.isNotBlank(request.leadOrContactId)) {
                mail.setTargetObjectId(request.leadOrContactId);
            }
            mail.setSaveAsActivity(false);
            if (String.isNotBlank(request.recordId)) {
                mail.setWhatId(request.recordId);
            }
        }

        Messaging.EmailFileAttachment attachment = new Messaging.EmailFileAttachment();
        attachment.setFileName(cv.Title + '.' + cv.FileType);
        attachment.setBody(cv.VersionData);
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attachment });
        return mail;
    }

    public class GeneratePdfRequest {
        @InvocableVariable(label='File Template ID' description='The ID of the file template to use for generating the PDF' required=true)
        public String fileTemplateId;

        @InvocableVariable(label='Record ID' description='The ID of the record to attach the generated PDF to' required=true)
        public String recordId;

        @InvocableVariable(label='Parent Field' description='The lookup field on the Generate PDF to the parent SObject type' required=true)
        public String parentField;

        @InvocableVariable(label='SObject Type' description='The API name of the parent SObject type' required=true)
        public String sObjectType;

        @InvocableVariable(label='File Name' description='The File Name - defaults is the name of used Template name')
        public String fileName;

        @InvocableVariable(label='Email Template ID' description='The ID of the email template to use (required for sending email)')
        public String emailTemplateId;

        @InvocableVariable(label='Email To' description='The email address to send the PDF to (optional)')
        public String emailTo;

        @InvocableVariable(label='Lead or Contact ID' description='The Lead or Contact Id for template merge (optional)')
        public String leadOrContactId;

        @InvocableVariable(label='From Address Id' description='The OrgWideEmailAddress Id to use as the from address (optional)')
        public String fromAddressId;
    }

    public class GeneratePdfResponse {
        @InvocableVariable(label='File ID' description='The ID of the generated PDF file')
        public String fileId;

        @InvocableVariable(label='Error Message' description='Error message if PDF generation or email failed')
        public String errorMessage;
    }
}