@isTest
public with sharing class ChildMergeFieldValidatorTest {

    @isTest
    static void validateTest() {
        
        IMergeFieldValidator mergeValidator = new MergeFieldValidator();
        IRelationshipValidator relationValidator = new ChildRelationshipValidator();

        Test.startTest();

        ChildMergeFieldValidator validator = new ChildMergeFieldValidator('Account', relationValidator, mergeValidator);
        IFieldValidationResult result = validator.validate('Contacts', new Set<String>{'FirstName', 'LastName'});

        // Relationship is Good
        System.assertEquals(false, result.hasInvalidFields());

        // relationship not good;
        result = validator.validate('Invalid__r', new Set<String>{'FirstName', 'LastName'});
        System.assert(result.getMessage().contains('is not a valid child relationship'));
        
        Test.stopTest();
    }
}