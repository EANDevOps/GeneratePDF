@isTest
public with sharing class GeneratePDFFlowHandlerBulkTest {

    @testSetup
    static void setupData() { 
        Account acc = new Account(Name = 'BulkTestAccount');
        insert acc;

        Contract contract = new Contract(AccountId = acc.Id, Status = 'New', Name = 'Test Contract');
        insert contract;
 
        Contact contact = new Contact(LastName = 'BulkTestContact', Email = 'casecontact@example.com');
        insert contact;

        Case caseRec = new Case(ContactId = contact.Id, Subject = 'BulkTestCase', Status = 'New', Origin = 'Web'); 
        caseRec.put('SuppliedEmail', contact.Email);
        insert caseRec;
    }

    @isTest
    static void testBulkWithContracts() {
        List<Contract> contracts = [SELECT Id, Name FROM Contract];
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];

        List<Id> contractIds = new List<Id>();
        for (Contract c : contracts) contractIds.add(c.Id);

        Test.startTest();
        GeneratePDFFlowHandlerBulk batch = new GeneratePDFFlowHandlerBulk(
            'Contract',
            template.Id,
            'Name',        
            'Contract__c',   
            contractIds,
            template.Id,
            null,            
            null,            
            null            
        );
        Database.executeBatch(batch, 2);
        Test.stopTest();

        System.assertEquals(contracts.size(), [SELECT count() FROM Contract WHERE Id IN :contractIds]);
    }

    @isTest
    static void testBulkWithCases() {
        List<Case> cases = [SELECT Id, CaseNumber, ContactId, SuppliedEmail FROM Case WHERE ContactId != null];
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];

        List<Id> caseIds = new List<Id>();
        for (Case c : cases) caseIds.add(c.Id);

        Test.startTest();
        GeneratePDFFlowHandlerBulk batch = new GeneratePDFFlowHandlerBulk(
            'Case',
            template.Id,
            'CaseNumber',           
            'Case__c',        
            caseIds,
            template.Id,
            null,            
            'ContactId',      
            'SuppliedEmail'   
        );
        Database.executeBatch(batch, 2);
        Test.stopTest();

        System.assertEquals(cases.size(), [SELECT count() FROM Case WHERE Id IN :caseIds]);
    }

    @isTest
    static void testBatchLauncherInvocableWithCase() {
        List<Case> cases = [SELECT Id, CaseNumber, ContactId, SuppliedEmail FROM Case WHERE ContactId != null LIMIT 2];
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];

        List<Id> caseIds = new List<Id>();
        for (Case c : cases) caseIds.add(c.Id);

        GeneratePDFBatchLauncher.BatchParams params = new GeneratePDFBatchLauncher.BatchParams();
        params.sObjectType = 'Case';
        params.fileTemplateId = template.Id;
        params.fileNameFields = 'CaseNumber';
        params.parentField = 'Case__c';
        params.recordIds = caseIds;
        params.emailTemplateId = template.Id;
        params.orgWideEmailAddressId = null;
        params.targetObjectField = 'ContactId';
        params.emailField = 'SuppliedEmail';

        Test.startTest();
        GeneratePDFBatchLauncher.launchBatch(new List<GeneratePDFBatchLauncher.BatchParams>{params});
        Test.stopTest();

        System.assertEquals(caseIds.size(), [SELECT count() FROM Case WHERE Id IN :caseIds]);
    }

    @isTest
    static void testBulkWithCasesMissingContact() { 
        Case caseRec = new Case(Subject = 'NoContactCase', Status = 'New', Origin = 'Web');
        insert caseRec;

        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];

        Test.startTest();
        GeneratePDFFlowHandlerBulk batch = new GeneratePDFFlowHandlerBulk(
            'Case',
            template.Id,
            'CaseNumber',
            'Case__c',
            new List<Id>{caseRec.Id},
            template.Id,
            null,
            'ContactId',
            'SuppliedEmail'
        );
        Database.executeBatch(batch, 1);
        Test.stopTest();

        System.assertEquals(1, [SELECT count() FROM Case WHERE Id = :caseRec.Id]);
    }
}