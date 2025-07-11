/** 
  * @author Jayson Faderanga (jayson.faderanga@datacom.co.nz) 
  * @date September 2021
  * @test GeneratePDFControllerTest
 **/
public with sharing class GeneratePDFController {
    public String recordId;
    public String fileTemplateId;
    public String fileName;
    public String fileTemplateBody {get; set;}
    public String extractedStyles { get; set; }

    public GeneratePDFController() {
        this.fileTemplateId = ApexPages.currentPage().getParameters().get('tid');
        this.recordId = ApexPages.currentPage().getParameters().get('recid');

        if (fileTemplateId == null || recordId == null) return;

        this.renderTemplate();
    }

    public void renderTemplate() {
        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(this.fileTemplateId, null, this.recordId);

        String relatedTo = Id.valueOf(this.recordId)
            .getSobjectType()
            .getDescribe()
            .getName();

        IMergeFieldValidator validator = new MergeFieldValidator();
        IRelationshipValidator childRelationshipValidator = new ChildRelationshipValidator();
        IMergeFieldValidator childValidator = new ChildMergeFieldValidator(relatedTo, childRelationshipValidator, validator);
        MergeFieldParser parser = new MergeFieldParser(validator, childValidator, childRelationshipValidator);
        
        String rendered = message.getHtmlBody() != null ? message.getHtmlBody() : message.getPlainTextBody();
        this.fileTemplateBody = parser.parse(rendered, Id.valueOf(this.recordId));
        this.extractedStyles = extractStyles(fileTemplateBody);
    }
    
    private String extractStyles(String htmlContent) {
        String styles = '';
        Integer startIndex = htmlContent.indexOf('<style');
        while (startIndex != -1) {
            Integer endIndex = htmlContent.indexOf('</style>', startIndex);
            if (endIndex == -1) break;
            endIndex += '</style>'.length();
            styles += htmlContent.substring(startIndex, endIndex);
            startIndex = htmlContent.indexOf('<style', endIndex);
        }
        return styles;
    }   

    @AuraEnabled
    public static Boolean validateConfig(String recordId, String parentField) {

        try {
            // We expect inputs are valid - if not then we don't display the component
            SObjectType parentSObjectType = SObjectType.Generate_PDF__c.fields.getMap().get(parentField).getDescribe().getReferenceTo()[0];
            SObjectType recordSObjectType = Id.valueOf(recordId).getSObjectType();

            return parentSObjectType == recordSObjectType;
        } catch (Exception e) {
            System.debug('Error: Component validity error ' + e.getStackTraceString());
        }

        return false;
    }

    @AuraEnabled
    public static String generatePdfFile(String fileTemplateId, String recordId, String parentField, string fileName) {

        Savepoint savepoint = Database.setSavepoint();
        EmailTemplate pdfTemplate = GeneratePDFSelector.getTemplateById(fileTemplateId);

        try {
            Id contentDocumentId = createDocument(fileTemplateId, recordId, pdfTemplate, fileName);
            
            // STEP 4: Create the Generate PDF record for History
            Generate_PDF__c pdfHistory = createPdfHistory('Generated', 'PDF', null, null, pdfTemplate.Name, pdfTemplate.Id);
            pdfHistory.put(parentfield, recordId);
            pdfHistory.put('Download_Path__c', '/sfc/servlet.shepherd/document/download/' + contentDocumentId);

            insert pdfHistory;

            createDocumentLink(contentDocumentId, recordId);
            createDocumentLink(contentDocumentId, pdfHistory.Id);
            
            return contentDocumentId;

        } catch (Exception e) {
            Database.rollback(savepoint);

            Generate_PDF__c pdfHistory = createPdfHistory('Failed', 'PDF', null, null, pdfTemplate.Name, pdfTemplate.Id);
            pdfHistory.put(parentfield, recordId);

            insert pdfHistory;

            throw new AuraException(e.getMessage());
        }
    }

    public static Generate_PDF__c createPdfHistory(String status, String historyType,
        String templateName, Id templateId, String fileTemplateName, Id fileTemplateId) {

        Generate_PDF__c pdfHistory = new Generate_PDF__c(
            Email_Template__c = templateName,
            Email_TemplateId__c = templateId,
            File_Template__c = fileTemplateName,
            File_TemplateId__c = fileTemplateId,
            Status__c = status,
            Type__c = historyType
        );

        return pdfHistory;
    }

    public static void createDocumentLink(Id contentDocumentId, String recordId) {
        
        ContentDocumentLink contentLink = new ContentDocumentLink(
            ContentDocumentId = contentDocumentId,
            LinkedEntityId = recordId,
            ShareType = 'V'
        );

        insert contentLink;
    }

    public static Id createDocument(Id fileTemplateId, String recordId, EmailTemplate pdfTemplate, string fileName) {

        Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(fileTemplateId, null, recordId);
        
        // TODO replace this with the actual PDF

        // STEP 1: Render using PageReference
        PageReference renderer = Page.GeneratePDFPreview;

        renderer.getParameters().put('tid', fileTemplateId);
        renderer.getParameters().put('recid', recordId);

        Blob pageBody = Test.isRunningTest() ? Blob.valueOf('Test') : renderer.getContentAsPDF();
        String pdfFileName = (pdfTemplate.Name + '.pdf').replace(' ', '');
        if (fileName != null) {
            pdfFileName = (fileName + '.pdf').replace(' ', '');
        }  

        // STEP 2: Create the Content Version from Page Blob
        ContentVersion content = new ContentVersion(
            Title = pdfFileName,
            VersionData = pageBody,
            PathOnClient = pdfFileName
        );

        insert content;
        
        // STEP 3: Link the File to the Record
        content = GeneratePdfSelector.getContentById(content.Id);

        return content.ContentDocumentId;
    }
    
    @AuraEnabled
    public static List<Object> emailTemplateOptions(String enabledFolders) {
        List<Map<String, Object>> templateOptions = new List<Map<String, Object>>();
        
        List<String> folderOptions = String.isBlank(enabledFolders)
            ? GeneratePDF_Config__c.getOrgDefaults().Enabled_Folders__c.split(',') : enabledFolders.split(',');
        
        for (Integer i = 0; i < folderOptions.size(); i++) {
            folderOptions[i] = folderOptions[i].trim();
        }

        List<EmailTemplate> templates = GeneratePDFSelector.getTemplatesByFolderName(folderOptions);

        for (EmailTemplate template : templates) {
            
            templateOptions.add(new Map<String, Object>{
                'label' => template.Name,
                'value' => template.Id,
                'selected' => false,
                'group' => template.FolderName
            });
        }

        return templateOptions;
    }
    
    @AuraEnabled
    public static Map<String, Object> getTableData(String recordId, String parentField) {
        
        List<FieldSetMember> members;
        
        try {
            members = SObjectType.Generate_PDF__c.FieldSets.Generate_PDF_List.getFields();
        } catch (Exception e) { throw new AuraException('Fieldset does not exist'); }

        // ordered as defined in fieldset
        List<String> fieldNames = new List<String>();
        List<String> fieldLabels = new List<String>();
        Map<String, String> fieldTypes = new Map<String, String>();

        for (FieldSetMember member : members) {

            String apiName = member.getFieldPath();
            String label = member.getLabel();
            label = label == 'Download Path' ? '' : label;

            fieldNames.add(apiName);
            fieldLabels.add(label);

            fieldTypes.put(apiName, String.valueOf(member.getType()));
        }

        List<Generate_PDF__c> records = GeneratePDFSelector.getGeneratedPdfs(
            recordId, parentField, String.join(fieldNames, ','));

        SObjectType sObjectType = Id.valueOf(recordId).getSObjectType();
        List<Schema.ChildRelationship> relationships = sObjectType.getDescribe().getChildRelationships();

        String relationshipUrl = '/lightning/r/{0}/{1}/related/{2}/view';

        for (ChildRelationship relationship : relationships) {
            
            if (String.valueOf(relationship.getChildSObject()) == 'Generate_PDF__c') {
                
                relationshipUrl = String.format(
                    relationshipUrl,
                    new List<String>{sObjectType.getDescribe().getName(), recordId, relationship.getRelationshipName()});

                break;
            }
        }

        return new Map<String, Object>{
            'fieldNames' => fieldNames,
            'fieldLabels' => fieldLabels,
            'fieldTypes' => fieldTypes,
            'records' => records,
            'relationshipUrl' => relationshipUrl
        };
    }
}