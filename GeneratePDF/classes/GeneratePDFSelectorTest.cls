@isTest
public with sharing class GeneratePDFSelectorTest {

    @isTest
    static void selectorTest() {
        System.assert(GeneratePDFSelector.getTemplatesByFolderName(new List<String>{'Non_Existent_Folder'}).isEmpty());
        System.assertEquals(null, GeneratePDFSelector.getTemplateById('00l0I0000000034'));
        System.assert(GeneratePDFSelector.getGeneratedPdfs('00l0I0000000034', 'Contract__c', 'Contract__c').isEmpty());
        System.assertEquals(null, GeneratePDFSelector.getContentById('00l0I0000000034'));
    }
}