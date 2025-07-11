/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Validates a set of merge fields against an sObject
 */
public interface IMergeFieldValidator {
    /**
     * @description Validates a set of merge fields against an sObject
     * @param relatedTo The related sObject to validate the merge fields against
     * @param mergeFields The merge fields to validate
     * @return The result of the validation
     * @example
     * IFieldValidationResult validator = new SomeValidator();
     * IFieldValidationResult isValid = validator.validate('Account', new Set<String> { 'Account.Owner.Name'});
     */
    IFieldValidationResult validate(String relatedTo, Set<String> mergeFields);
}