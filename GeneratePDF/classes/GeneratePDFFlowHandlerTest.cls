@isTest
public with sharing class GeneratePDFFlowHandlerTest{
    
    @isTest
    static void generatePdfFileTest() { 
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];
        
        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;
        
        GeneratePDFFlowHandler.GeneratePdfRequest request = new GeneratePDFFlowHandler.GeneratePdfRequest();
        request.fileTemplateId = template.Id;
        request.recordId = contract.Id;
        request.parentField = 'Contract__c';
        request.sObjectType = 'Contract';
        request.emailTemplateId = template.Id;  
        
        List<GeneratePDFFlowHandler.GeneratePdfRequest> requests = new List<GeneratePDFFlowHandler.GeneratePdfRequest>{request};
            
        Test.startTest();
        List<GeneratePDFFlowHandler.GeneratePdfResponse> responses = GeneratePDFFlowHandler.generatePdf(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size());
        System.assertNotEquals(null, responses[0].fileId);
        System.assertEquals(null, responses[0].errorMessage);
        
        List<Generate_PDF__c> pdfs = [SELECT Id, Status__c FROM Generate_PDF__c WHERE Contract__c = :contract.Id];
        System.assertEquals(1, pdfs.size());
        System.assertEquals('Generated', pdfs[0].Status__c);
    }
    
    @isTest
    static void generatePdfFileTestWithLeadAndOrgWideEmail() { 
        Lead lead = new Lead(LastName='Test Lead', Company='Test Company', Email='testlead@example.com.invalid');
        insert lead;
        
        OrgWideEmailAddress owea = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'noreply@eanetworks.co.nz' LIMIT 1];
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];
        
        GeneratePDFFlowHandler.GeneratePdfRequest request = new GeneratePDFFlowHandler.GeneratePdfRequest();
        request.fileTemplateId = template.Id;
        request.recordId = lead.Id;
        request.parentField = 'Lead__c';
        request.sObjectType = 'Lead';
        request.emailTo = lead.Email;
        request.leadOrContactId = lead.Id;
        request.fromAddressId = owea.Id;
        request.emailTemplateId = template.Id;  
        
        List<GeneratePDFFlowHandler.GeneratePdfRequest> requests = new List<GeneratePDFFlowHandler.GeneratePdfRequest>{request};
            
        Test.startTest();
        List<GeneratePDFFlowHandler.GeneratePdfResponse> responses = GeneratePDFFlowHandler.generatePdf(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size());
        System.assertNotEquals(null, responses[0].fileId);
        
        System.assert(
            responses[0].errorMessage == null ||
            responses[0].errorMessage.contains('Single email is not enabled'),
            'Should not get WhatId/saveAsActivity error for Lead'
        );
    }
    
    @isTest
    static void generatePdfFileTestWithInvalidId() { 
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];
        
        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;
        
        GeneratePDFFlowHandler.GeneratePdfRequest request = new GeneratePDFFlowHandler.GeneratePdfRequest();
        request.fileTemplateId = template.Id;
        request.recordId = 'invalidid';
        request.parentField = 'Contract__c';
        request.sObjectType = 'Contract';
        request.emailTemplateId = template.Id;  
        
        List<GeneratePDFFlowHandler.GeneratePdfRequest> requests = new List<GeneratePDFFlowHandler.GeneratePdfRequest>{request};
            
        Test.startTest();
        List<GeneratePDFFlowHandler.GeneratePdfResponse> responses = GeneratePDFFlowHandler.generatePdf(requests);
        Test.stopTest(); 
        
        System.assertEquals(2, responses.size());
        System.assertEquals(null, responses[0].fileId);
        System.assertNotEquals(null, responses[0].errorMessage);
    }  
    
    @isTest
    static void coverNonLeadOrContactTemplateBranch() { 
        Account acc = new Account(Name='Test Account');
        insert acc; 
        
        GeneratePDFFlowHandler.GeneratePdfRequest req = new GeneratePDFFlowHandler.GeneratePdfRequest();
        req.fileTemplateId = 'dummyTemplateId';
        req.recordId = acc.Id;
        req.parentField = 'AccountId';
        req.sObjectType = 'Account';
        req.fileName = 'TestFile';
        req.emailTemplateId = 'dummyEmailTemplateId';  
        req.emailTo = 'test@example.com';
        req.leadOrContactId = ''; 
        
        Test.startTest();
        GeneratePDFFlowHandler.generatePdf(new List<GeneratePDFFlowHandler.GeneratePdfRequest>{ req });
        Test.stopTest();
    }
    
    @isTest
    static void generatePdfFileTestWithNonLeadOrContactId() { 
        Account account = new Account(Name='Test Account');
        insert account;
        
        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;
        
        EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Folder.Name != null LIMIT 1];
        
        GeneratePDFFlowHandler.GeneratePdfRequest request = new GeneratePDFFlowHandler.GeneratePdfRequest();
        request.fileTemplateId = template.Id;
        request.recordId = contract.Id;
        request.parentField = 'Contract__c';
        request.sObjectType = 'Contract';
        request.emailTo = 'someone@example.com.invalid';
        request.leadOrContactId = contract.Id;  
        request.emailTemplateId = template.Id;  
        
        List<GeneratePDFFlowHandler.GeneratePdfRequest> requests = new List<GeneratePDFFlowHandler.GeneratePdfRequest>{request};
            
        Test.startTest();
        List<GeneratePDFFlowHandler.GeneratePdfResponse> responses = GeneratePDFFlowHandler.generatePdf(requests);
        Test.stopTest();
        
        System.assertEquals(1, responses.size()); 
    }
    
}