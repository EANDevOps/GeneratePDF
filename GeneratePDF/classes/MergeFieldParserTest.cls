@isTest
public with sharing class MergeFieldParserTest {

    @isTest
    static void parserTest() {
        Account account = TestDataFactory.createAccountAsElectricityCustomer();
        insert account;

        Contract contract = new Contract(AccountId = account.Id, Status = 'New');
        insert contract;

        insert new Task(WhatId = contract.Id, Subject = 'Subject Test', ActivityDate = Date.today());
        
        IMergeFieldValidator validator = new MergeFieldValidator();
        IRelationshipValidator childRelationshipValidator = new ChildRelationshipValidator();
        IMergeFieldValidator childValidator = new ChildMergeFieldValidator('Contract', childRelationshipValidator, validator);

        MergeFieldParser parser = new MergeFieldParser(validator, childValidator, childRelationshipValidator);
        String parsedText = parser.parse(textToParse(), contract.Id);

        // custom merged field are replaced, invalid fields are removed
        System.assert(!parsedText.contains('{{'));
        System.assert(parsedText.contains('Subject Test'));
        System.assert(parsedText.contains(contract.Id));
    }

    private static String textToParse() {
        return
            + '<div>'
            +     '<div>Hello World</div>'
            +     '<div>{{ContractNumber}}</div>'
            +     '<div>{{Id}}</div>'
            +     '<div>{{Account.Name}}</div>'
            +     '<div>{{InvalidField__c}}</div>'
            +     '{{#Tasks}}'
            +     '<div>{{Subject}}</div>'
            +     '<div>{{Status}}</div>'
            +     '<div>{{InvalidField__c}}</div>'
            +     '{{/Tasks}}'
            + '</div>';
    }
}