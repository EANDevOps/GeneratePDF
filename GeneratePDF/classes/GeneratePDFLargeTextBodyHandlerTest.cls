@isTest
private class GeneratePDFLargeTextBodyHandlerTest {
    @isTest
    static void testProcessLargeTextFromFlow() { 
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        Contract contract = new Contract(Name = 'Test Contract', AccountId = account.Id);
        insert contract;
        
        String textPayload = 'This is a test payload that will be split across multiple fields. '
            + 'Each field will hold a portion of this text, and the remaining fields will be cleared if not needed.';
        
        GeneratePDFLargeTextBodyHandler.FlowInput input = new GeneratePDFLargeTextBodyHandler.FlowInput();
        input.textPayload = textPayload;
        input.recordId = contract.Id;
        input.objectApiName = 'Contract';
        input.fieldApiNames = 'Body_1__c,Body_2__c,Body_3__c,Body_4__c,Body_5__c'; 
        
        List<GeneratePDFLargeTextBodyHandler.FlowInput> inputs = new List<GeneratePDFLargeTextBodyHandler.FlowInput>{input};
            List<GeneratePDFLargeTextBodyHandler.FlowOutput> outputs = GeneratePDFLargeTextBodyHandler.processLargeTextFromFlow(inputs);
        
        System.assertEquals(1, outputs.size());
        System.assert(outputs[0].success, 'The operation should succeed');
        System.assert(outputs[0].recordId != null, 'The record ID should not be null');
        
        Contract updatedContract = [SELECT Body_1__c, Body_2__c, Body_3__c, Body_4__c, Body_5__c FROM Contract WHERE Id = :contract.Id]; 
    }
    
    @isTest
    static void testFindSafeBreakPoint_WithBreakTag() {  
        String textPayload = 'This is a test payload with a break tag </p> in the middle.';
        Integer startIndex = 0;
        Integer maxLength = 50;
        
        Integer breakPoint = GeneratePDFLargeTextBodyHandler.findSafeBreakPoint(textPayload, startIndex, maxLength);
        
        System.assertEquals(44, breakPoint, 'The break point should account for the </p> tag');
    } 

    @isTest
    static void testUpsertDynamicRecord_NewSObject() {  
        Account account = new Account(Name = 'Test Account');
        insert account;
        
        String textPayload = 'Test payload for new SObject';
        String objectApiName = 'Contract';
        String fieldApiNames = 'Body_1__c,Body_2__c'; 
        
        Contract contract = new Contract(AccountId = account.Id);
        insert contract;
        
        Id recordId = GeneratePDFLargeTextBodyHandler.upsertDynamicRecord(textPayload, contract.Id, objectApiName, fieldApiNames);
        
        Contract updatedContract = [SELECT Body_1__c, Body_2__c FROM Contract WHERE Id = :recordId];
        
        System.assertEquals('Test payload for new SObject', updatedContract.Body_1__c);
        System.assert(updatedContract.Body_2__c == null, 'Unused fields should be null');
    }
}