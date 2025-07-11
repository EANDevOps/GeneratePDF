/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Validates a child relationship's merge fields against an the child sObject
 */
public inherited sharing class ChildMergeFieldValidator implements IMergeFieldValidator {
    /**
     * @description The parent sObject name to validate against
     */
    private final String parent { get; private set; }
    
    /**
     * @description Validates a set of merge fields against an sObject
     * Used to validate the child's merge field's against the child sObject
     */
    private final IMergeFieldValidator mergeFieldValidator { get; private set; }

    /**
     * @description Validates the child relationship against an sObject
     */
    private final IRelationshipValidator relationshipValidator { get; private set; }

    /**
     * @description Constructor for ChildMergeFieldValidator
     * @param parent The parent sObject name of whose child relationship's merge fields will be validated
     * @param relationshipValidator The validator used to validate the child relationship
     * @param mergeFieldValidator The validator used to validate the child relationship's merge fields
     */
    public ChildMergeFieldValidator(String parent, IRelationshipValidator relationshipValidator, IMergeFieldValidator mergeFieldValidator) {
        Guard.againstNull(relationshipValidator, 'relationshipValidator');
        Guard.againstNull(mergeFieldValidator, 'mergeFieldValidator');
        Guard.againstNull(parent, 'parent');
        this.parent = parent;
        this.relationshipValidator = relationshipValidator;
        this.mergeFieldValidator = mergeFieldValidator;
    }

    /**
     * @description Validates child relationship and the merge fields of the child pointed to by the child relationship
     * @param childRelationshipName The child relationship name whose merge fields will be validated
     * @param mergeFields The merge fields of the child sObject who will be validated
     * @return The result of the validation
     * @example
     * IFieldValidationResult validator = new ChildMergeFieldValidator(//see constructors);
     * IFieldValidationResult isValid = validator.validate('Contacts', new Set<String> { 'Contact.LastName'});
     */
    public IFieldValidationResult validate(String childRelationshipName, Set<String> mergeFields) {
        IRelationshipValidationResult relationshipValidation = this.relationshipValidator.validate(parent, childRelationshipName);
        if (!relationshipValidation.isSuccess()) {
            return new FieldValidationResult.Error(relationshipValidation.getMessage());
        }

        return this.mergeFieldValidator.validate(relationshipValidation.getRelatedObject(), mergeFields);
    }
}