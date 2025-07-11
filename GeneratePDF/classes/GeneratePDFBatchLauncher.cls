public with sharing class GeneratePDFBatchLauncher {
    @InvocableMethod(label='Launch PDF Batch Generation')
    public static void launchBatch(List<BatchParams> paramsList) {
        for (BatchParams params : paramsList) {
            Database.executeBatch(
                new GeneratePDFFlowHandlerBulk(
                    params.sObjectType,
                    params.fileTemplateId,
                    params.fileNameFields,
                    params.parentField,
                    params.recordIds,
                    params.emailTemplateId,
                    params.orgWideEmailAddressId,
                    params.targetObjectField,
                    params.emailField
                ),
                200
            );
        }
    }

    public class BatchParams {
        @InvocableVariable(label='SObject Type' required=true)
        public String sObjectType;
        @InvocableVariable(label='File Template ID' required=true)
        public String fileTemplateId;
        @InvocableVariable(label='File Name Fields (comma separated)' description='API names of fields to use in file name, e.g. Name,MailingStreet')
        public String fileNameFields;
        @InvocableVariable(label='Parent Field')
        public String parentField;
        @InvocableVariable(label='Record Ids')
        public List<Id> recordIds; 
 
        @InvocableVariable(label='Email Template ID')
        public String emailTemplateId;
        @InvocableVariable(label='Org Wide Email Address ID')
        public String orgWideEmailAddressId;
        @InvocableVariable(label='Target Object Field (User/Lead/Contact lookup)')
        public String targetObjectField;
        @InvocableVariable(label='Email Field (API name)')
        public String emailField;
    }
}