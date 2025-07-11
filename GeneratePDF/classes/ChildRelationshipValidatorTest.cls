@isTest
public with sharing class ChildRelationshipValidatorTest {

    @isTest
    static void validateTest() {
        ChildRelationshipValidator validator = new ChildRelationshipValidator();

        Test.startTest();
        // good relationship
        String relatedObject = validator.validate('Account', 'Contacts').getRelatedObject();
        System.assertEquals('Contact', relatedObject);

        // invalid object
        try {
            relatedObject = validator.validate('InvalidObject', 'Contacts').getRelatedObject();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('not a valid object'));
        }

        // invalid relationship
        try {
            relatedObject = validator.validate('OrderItem', 'Contacts').getRelatedObject();
        } catch (Exception e) {
            System.assert(e.getMessage().contains('is not a valid child relationship'));
        }
    }
}