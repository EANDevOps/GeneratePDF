/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Validates a set of merge fields against an sObject
 */
public inherited sharing class MergeFieldValidator implements IMergeFieldValidator {
    /**
     * @description The delimiter between fields
     */
    private static final String PATH_DELIMITER = '.';
    /**
     * @description The maximum number of upwards traversals allowed
     * Note: `5` is the maximum imposed by Salesforce
     */
    private static final Integer MAXIMUM_CHILD_TO_PARENT_TRAVERSALS = 5;

    /**
     * @description A map of field describes by SObject
     */
    private Map<String, Map<String, Schema.SObjectField>> fieldsMapByObject =
        new Map<String, Map<String, Schema.SObjectField>>();

    /**
     * @description Validates a set of merge fields against an sObject
     * @param relatedTo The related sObject to validate the merge fields against
     * @param mergeFields The merge fields to validate
     * @return The result of the validation
     * @example
     * IFieldValidationResult validator = new MergeFieldValidator();
     * IFieldValidationResult isValid = validator.validate('Account', new Set<String> { 'Account.Owner.Name'});
     */
    public IFieldValidationResult validate(String relatedTo, Set<String> mergeFields) {
        if (mergeFields == null || mergeFields.isEmpty()) { return new FieldValidationResult.Ok(); }

        Schema.DescribeSObjectResult relatedToDescribe;
        try {
            relatedToDescribe = getDescribe(relatedTo);
        } catch (NullPointerException e) {
            return new FieldValidationResult.Error(
                String.format('\'\'{0}\'\' is not a valid object',
                    new List<String> { relatedTo })
            );
        }

        return validateFields(relatedToDescribe, mergeFields);
    }

    /**
     * @description Validates a set of merge fields against an sObject
     * @param relatedToDescribe The related sObject described used in validation
     * @param mergeFields The merge fields to validate against the related sObject
     * @return The result of the validation
     */
    private IFieldValidationResult validateFields(Schema.DescribeSObjectResult relatedToDescribe, Set<String> mergeFields) {
        FieldValidationErrors validationErrors = new FieldValidationErrors();
        for (String fieldPath : new List<String>(mergeFields)) {
            IValidationResult isMergeFieldValid = validateField(relatedToDescribe, fieldPath);
            if (!isMergeFieldValid.isSuccess()) { 
                validationErrors.add(isMergeFieldValid, fieldPath);
            }
        }

        if (validationErrors.hasErrors()) {
            String errorMessage = 'Validation was unsuccessful. The following errors were encountered: ' + '\n';
            errorMessage += validationErrors.getErrorsAsString();
            return new FieldValidationResult.Error(errorMessage, validationErrors.getInvalidFields());
        }

        return new FieldValidationResult.Ok(); 
    }

    /**
     * @description Recursively validates a field path e.g. 'Account.Owner.Id' against an sObject
     * @param objectDescribe The describe of the current sObject during field path traversal
     * @param fieldPath The remaining section of the path to validate
     * @return The result of the validation
     */
    private IValidationResult validateField(Schema.DescribeSObjectResult objectDescribe, String fieldPath) {
        if (String.isBlank(fieldPath)) { return new ValidationResult.Ok(); }

        // Ensure we're not exceeding the maximum traversal limit
        if (isTooFarAway(fieldPath)) { 
            return new ValidationResult.Error(
                String.format('No more than {0} child-to-parent traversals are allowed',
                    new List<Object> { MAXIMUM_CHILD_TO_PARENT_TRAVERSALS})
            );
        }

        // Validate the first chunk
        Map<String, Schema.SObjectField> fieldsMap = getFieldsMap(objectDescribe);
        String pathFragment = fieldPath.substringBefore(PATH_DELIMITER);

        // Ensure the first chunk is a field on the current sObject
        if (isNotField(pathFragment, fieldsMap)) {
            return new ValidationResult.Error(
                String.format('\'\'{0}\'\' is not a field of \'\'{1}\'\'',
                    new List<String> { pathFragment, objectDescribe.getName() })
            );
        }

        // Field is valid and is terminal
        if (!refersToRelatedObjects(fieldPath)) {
            return new ValidationResult.Ok();
        }

        // Field is valid but is not terminal and is not a reference field
        Schema.SObjectField field = fieldsMap.get(pathFragment.toLowerCase());
        if (isNotReference(field)) {
            return new ValidationResult.Error(
                String.format('Unable to traverse non-reference field \'\'{0}\'\'',
                    new List<String> { pathFragment })
            );
        }

        // Field is valid, is not terminal, and is a reference field
        if (isReference(field)) {
            return validateField(getDesribeOfReference(field), fieldPath.substringAfter(PATH_DELIMITER));
        }

        // The supplied field path was valid
        return new ValidationResult.Ok(); 
    }

    /**
     * @description Whether or not the the field path refers to other objects
     * determined by having one or more path delimiters
     * @param fieldPath The field path to check
     * @return Whether or not the field path refers to other objects
     */
    private Boolean refersToRelatedObjects(String fieldPath) {
        return fieldPath.countMatches(PATH_DELIMITER) > 0;
    }

    /**
     * @description Whether or not the field path exceeds the maximum distance
     * from the base object
     * @param fieldPath The field path to check
     * @return Whether or not the field path exceeds the maximum distance from the base object
     */
    private Boolean isTooFarAway(String fieldPath) {
        return fieldPath.countMatches(PATH_DELIMITER) >= MAXIMUM_CHILD_TO_PARENT_TRAVERSALS;
    }

    /**
     * @description Whether the field name is an invalid field for a particular sObject
     * @param fieldName the field name to determine the invalidity for
     * @param fieldsMap the map of fields for a particular sObject
     * @return Whether or not the field name is an invalid field for a particular sObject
     */
    private Boolean isNotField(String fieldName, Map<String, Schema.SObjectField> fieldsMap) {
        return !isField(fieldName, fieldsMap);
    }

    /**
     * @description Whether the field name is a valid field for a particular sObject
     * @param fieldName the field name to determine the validity for
     * @param fieldsMap the map of fields for a particular sObject
     * @return Whether or not the field name is a valid field for a particular sObject
     */
    private Boolean isField(String fieldName, Map<String, Schema.SObjectField> fieldsMap) {
        return fieldsMap.containsKey(fieldName.toLowerCase());
    }

    /**
     * @description Whether the field is not a reference field
     * @param field The field to determine whether it is not a reference field
     * @return Whether the field is not a reference field
     */
    private Boolean isNotReference(Schema.SObjectField field) {
        return !isReference(field);
    }

    /**
     * @description Whether the field is a reference field
     * @param field The field to determine whether it is a reference field
     * @return Whether the field is a reference field
     */
    private Boolean isReference(Schema.SObjectField field) {
        return field.getDescribe().getType().equals(Schema.DisplayType.REFERENCE);
    }

    /**
     * @description Gets the describe for a sObject name
     * @param sObjectName The name of the sObject to obtain the describe for
     * @return The describe for the sObject referred to
     * @throws NullPointerException When the sObject name does not refer to a valid sObject
     */
    private Schema.DescribeSObjectResult getDescribe(String sObjectName) {
        return ((SObject) Type.forName('Schema', sObjectName).newInstance()).getSObjectType().getDescribe();
    }

    /**
     * @description Gets the describe of the sObject the reference field points to
     * NOTE: probably does not work well with polymorphic fields
     * @param referenceField The reference field to obtain the describe of the object referred to by it
     */
    private Schema.DescribeSObjectResult getDesribeOfReference(Schema.SObjectField referenceField) {
        return referenceField.getDescribe().getReferenceTo()[0].getDescribe();
    }

    /**
     * @description Gets the map of fields from the sObject describe result
     * NOTE: Returns a cached result if present instead of describing again
     * @param sObjectDescribe the sObject describe result to obtain the fields map from
     * @return The map of fields for the object
     */
    private Map<String, Schema.SObjectField> getFieldsMap(Schema.DescribeSObjectResult sObjectDescribe) {
        if (!this.fieldsMapByObject.containsKey(sObjectDescribe.getName().toLowerCase())) {
            this.fieldsMapByObject.put(sObjectDescribe.getName().toLowerCase(), fieldsByNameOrReferenceName(sObjectDescribe));
        }

        return this.fieldsMapByObject.get(sObjectDescribe.getName().toLowerCase());
    }

    /**
     * @description Constructs a map of fields by their name and/or relationship name
     * @param sObjectDescribe The describe result to construct the field map from
     * @return The map of fields by their name and/or relationship name
     */
    private Map<String, Schema.SObjectField> fieldsByNameOrReferenceName(Schema.DescribeSObjectResult sObjectDescribe) {
        Map<String, Schema.SObjectField> fieldsByNameOrReferenceName = new Map<String, Schema.SObjectField>();
        for (Schema.SObjectField field : sObjectDescribe.fields.getMap().values()) {
            if (isReference(field)) {
                // add the relationship name as an acceptable mappable key for the field
                // (i.e. field 'ContactId' on a case has the relationship name of 'Contact')
                if (field.getDescribe().getRelationshipName() != null) {
                    fieldsByNameOrReferenceName.put(field.getDescribe().getRelationshipName().toLowerCase(), field);
                }
            }
            // add the field name as an acceptable mappable key for the field
            fieldsByNameOrReferenceName.put(field.getDescribe().getName().toLowerCase(), field);
        }
        return fieldsByNameOrReferenceName;
    }

    /**
     * @description Wrapper class used to store validation errors encountered
     * @author Stewart McDiarmid
     * @date September 2021
     */
    private class FieldValidationErrors {
        /**
         * @description The validation errors encountered during validation
         */
        private List<IValidationResult> validationErrors = new List<IValidationResult>();

        /**
         * @description The fields that failed validation
         */
        private Set<String> invalidFields = new Set<String>();

        /**
         * @description Records a validation error and the associated invalid field
         * @param validationError The validation error to record
         * @param invalidField The `full path` of the invalid field e.g. Account.Name if the base object is a Contact for example
         */
        public void add(IValidationResult validationError, String invalidField) {
            this.validationErrors.add(validationError);
            this.invalidFields.add(invalidField);
        }

        /**
         * @description Whether or not there have been any errors recorded
         * @return Whether or not there have been errors recorded
         */
        public Boolean hasErrors() {
            return !this.validationErrors.isEmpty();
        }

        /**
         * @description Gets the errors that have been recorded
         * @return The list of errors that have been recorded
         */
        public List<IValidationResult> getErrors() {
            return this.validationErrors;
        }

         /**
         * @description Gets the errors that have been recorded
         * NOTE: Concatenates them together into a single string separated by new lines
         * @return The list of errors that have been recorded
         */
        public String getErrorsAsString() {
            List<String> errors = new List<String>();
            for (IValidationResult error : this.validationErrors) {
                errors.add(error.getMessage());
            }

            return String.join(errors, '\n');
        }

        /**
         * @description Gets the invalid fields that have been identified
         * @return The invalid fields that have been identified
         */
        public Set<String> getInvalidFields() {
            return this.invalidFields;
        }
    }
}