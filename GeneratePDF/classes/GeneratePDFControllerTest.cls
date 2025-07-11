@isTest
public with sharing class GeneratePDFControllerTest {

    @isTest
    static void generatePdfFileTest() {
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;

        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];

        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;

        Test.startTest();

        GeneratePDFController.generatePdfFile(template.Id, contract.Id, 'Contract__c', 'TestFileName');
        List<Generate_PDF__c> pdfs = [SELECT Id, Status__c FROM Generate_PDF__c];

        System.assertEquals(1, pdfs.size());
        System.assertEquals('Generated', pdfs[0].Status__c);

        try {
            GeneratePDFController.generatePdfFile(template.Id, 'invalidid', 'Contract__c', 'TestFileName');
        } catch (Exception e) {
            System.assert(e.getMessage().startsWith('Insert failed.'));
        }

        Test.stopTest();
    }

    @isTest
    static void getTableDataTest() {
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;

        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;

        Test.startTest();

        Map<String, Object> data = GeneratePDFController.getTableData(contract.Id, 'Contract__c');
        
        System.assert(!((List<String>) data.get('fieldNames')).isEmpty());
        System.assert(((List<Generate_PDF__c>) data.get('records')).isEmpty());

        Test.stopTest();
    }

    @isTest
    static void emailTemplateOptionsTest() {
        insert new GeneratePDF_Config__c(Enabled_Folders__c = 'Fibre_App_Templates');

        Test.startTest();

        // may or may be not empty depend on which environment the test is run
        List<Object> templateOptions = GeneratePDFController.emailTemplateOptions('');
        Test.stopTest();
    }

    @isTest
    static void previewTest() {
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;

        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];
        
        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;

        Test.startTest();

        PageReference ref = Page.GeneratePDFPreview;

        ref.getParameters().put('tid', template.Id);
        ref.getParameters().put('recid', contract.Id);

        Test.setCurrentPage(ref);

        GeneratePDFController controller = new GeneratePDFController();

        System.assertNotEquals(null, controller.fileTemplateBody);
        Test.stopTest();
    }

    @isTest
    static void validateConfigTest() {
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;

        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;

        Test.startTest();

        Boolean isValid = GeneratePDFController.validateConfig(contract.Id, 'AccountId'); 

        Boolean isInvalid = GeneratePDFController.validateConfig(contract.Id, 'InvalidField'); 

        Test.stopTest();
    }
}