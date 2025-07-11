@isTest
public with sharing class MergeFieldValidatorTest {

    @isTest
    static void validateTest() {

        MergeFieldValidator validator = new MergeFieldValidator();
        IFieldValidationResult result = validator.validate('Contact', new Set<String>{'FirstName', 'LastName', 'Account.Name'});

        // Good result - Good Field and Good traversal
        System.assertEquals(false, result.hasInvalidFields());

        // invalid object  
        result = validator.validate('Invalid_Object__c', new Set<String>{'FirstName', 'LastName'});
        System.assert(result.getMessage().contains('is not a valid object'));

        // has invalid fields
        result = validator.validate('Contact', new Set<String>{'FirstName', 'Invalid_Field__c'});
        System.assertEquals(true, result.hasInvalidFields());
        System.assert(result.getInvalidFields().contains('Invalid_Field__c'));

        // too many traversals
        result = validator.validate('Contact', new Set<String>{'FirstName', 'Field__r.Field__r.Field__r.Field__r.Filed__r.Name'});
        System.assert(result.getMessage().contains('child-to-parent traversals are allowed'));

        // Field is not a reference (lookup/master-detail) field
        result = validator.validate('Contact', new Set<String>{'FirstName', 'LastName.Name'});
        System.assert(result.getMessage().contains('Unable to traverse non-reference field'));
    }
}