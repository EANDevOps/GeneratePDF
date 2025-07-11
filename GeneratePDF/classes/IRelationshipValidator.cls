/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Validates child relationship against a parent sObject
 */
public interface IRelationshipValidator {
    /**
     * @description Validates the child relationship against the parent sObject
     * @param parentName The name of the parent sObject
     * @param childRelationshipName The name of the child relationship
     * @return The result of the validation
     * @example
     * IRelationshipValidationResult validationResult = validate('Account', 'Contacts');
     */
    IRelationshipValidationResult validate(String parentName, String childRelationshipName);
}