/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Validates child relationship against a parent sObject
 */
public inherited sharing class ChildRelationshipValidator implements IRelationshipValidator {
    /**
     * @description Holds the describes for child relationships of a sObject
     */
    private Map<Schema.DescribeSObjectResult, Map<String, Schema.ChildRelationship>> childRelationshipsByNameByParentDescribe
        = new Map<Schema.DescribeSObjectResult, Map<String, Schema.ChildRelationship>>();

    /**
     * @description Holds the describes for each sObject
     */
    private Map<String, Schema.DescribeSObjectResult> parentDescribeByName =
        new Map<String, Schema.DescribeSObjectResult>();
    
    /**
     * @description Validates the child relationship against the parent sObject
     * @param parentName The name of the parent sObject
     * @param childRelationshipName The name of the child relationship
     * @return The result of the validation
     * @example
     * IRelationshipValidationResult validationResult = validate('Account', 'Contacts');
     * Boolean isValid = validationResult.isSuccess()
     * 
     * // isValid
     * true
     */
    public IRelationshipValidationResult validate(String parentName, String childRelationshipName) {
        Schema.DescribeSObjectResult parentDescribe;
        try {
            parentDescribe = describe(parentName);
        } catch (NullPointerException e) {
            return new RelationshipValidationResult.Error(
                String.format('\'\'{0}\'\' is not a valid object',
                    new List<String> { parentName })
            );
        }

        if (isInvalidChildRelationship(parentDescribe, childRelationshipName)) {
            return new RelationshipValidationResult.Error(
                String.format('\'\'{0}\'\' is not a valid child relationship of \'\'{1}\'\'',
                    new List<String> { childRelationshipName, parentName })
            );
        }

        return new RelationshipValidationResult.Ok(getChildObjectName(parentDescribe, childRelationshipName));
    }

    /**
     * @description Lazily describes the sObject referred to by the sObject name
     * @param sObjectName The name of the sObject to describe
     * @return The describe result for the sObject referred to by the sObject name
     * @throws NullPointerException If the sObject name does not refer to a valid sObject
     */
    public Schema.DescribeSObjectResult describe(String sObjectName) {
        if (!this.parentDescribeByName.containsKey(sObjectName)) {
            Schema.DescribeSObjectResult describe = ((SObject) Type.forName('Schema', sObjectName).newInstance())
                .getSObjectType()
                .getDescribe();
            this.parentDescribeByName.put(sObjectName, describe);
        }

        return this.parentDescribeByName.get(sObjectName);
    }

    /**
     * @description Determines whether the child relationship name is an invalid child relationship
     * for the parent sObject
     * @param parentDescribe The describe of the parent sObject
     * @param childRelationshipName The child relationship name to determine whether is invalid or not
     * @return Whether the child relationship name is an invalid child relationship for the parent sObject
     */
    private Boolean isInvalidChildRelationship(Schema.DescribeSObjectResult parentDescribe, String childRelationshipName) {
        return !isValidChildRelationship(parentDescribe, childRelationshipName);
    }

    /**
     * @description Determines whether the child relationship name is a valid child relationship
     * for the parent sObject
     * @param parentDescribe The describe of the parent sObject
     * @param childRelationshipName The child relationship name to determine whether is valid or not
     * @return Whether the child relationship name is a valid child relationship for the parent sObject
     */
    private Boolean isValidChildRelationship(Schema.DescribeSObjectResult parentDescribe, String childRelationshipName) {
        return getChildRelationshipsByName(parentDescribe).containsKey(childRelationshipName.toLowerCase());
    }

    /**
     * @description Gets the name of the sObject referred to by the child relationship name
     * @param parentDescribe The describe of the parent sObject
     * @param childRelationshipName The relationship name to obtain the referred to sObject for
     * @return The name of the sObject referred to by the child relationship name
     */
    private String getChildObjectName(Schema.DescribeSObjectResult parentDescribe, String childRelationshipName) {
        return getChildRelationshipsByName(parentDescribe)
            .get(childRelationshipName.toLowerCase())
            .getChildSObject()
            .getDescribe()
            .getName();
    }

    /**
     * @description Lazily gets Gets the child relationship names for the parent SObject describe
     * @param parentDescribe The describe of the parent sObject
     * @return The child relationships by name
     */
    private Map<String, Schema.ChildRelationship> getChildRelationshipsByName(Schema.DescribeSObjectResult parentDescribe) {
        if (!this.childRelationshipsByNameByParentDescribe.containsKey(parentDescribe)) {
            Map<String, Schema.ChildRelationship> childRelationshipsByName = new Map<String, Schema.ChildRelationship>();
            for (Schema.ChildRelationship childRelationship : parentDescribe.getChildRelationships()) {
                if (childRelationship.getRelationshipName() != null) {
                    childRelationshipsByName.put(childRelationship.getRelationshipName().toLowerCase(), childRelationship);
                }
            }

            this.childRelationshipsByNameByParentDescribe.put(parentDescribe, childRelationshipsByName);
        }

        return this.childRelationshipsByNameByParentDescribe.get(parentDescribe);
    }
}