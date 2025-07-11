/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Parses merge fields in the specified input against some sObject
 */
public inherited sharing class MergeFieldParser {
    /**
     * @description The delimiter between fields
     */
    private static final String PATH_DELIMITER = '.';

    /**
     * @description The symbol used to denote the start of a block expression
     */
    private static final String BLOCK_START = '#';

    /**
     * @description The symbol used to denote the end of a block expression
     */
    private static final String BLOCK_END = '/';

    /**
     * @description Escaped block end expression
     */
    private static final String BLOCK_END_ESCAPED = '\\' + BLOCK_END;

    /**
     * @description The symbol used to denote the start of a merge field
     */
    private static final String DELIM_START = '{{';

    /**
     * @description The symbol used to denote the end of a merge field
     */
    private static final String DELIM_END = '}}';

    /**
     * @description Escaped merge field start symbol
     */
    private static final String DELIM_START_ESCAPED = '\\' + String.join(DELIM_START.split(''), '\\');

    /**
     * @description Escaped merge field end symbol
     */
    private static final String DELIM_END_ESCAPED = '\\' + String.join(DELIM_END.split(''), '\\');
    
    /**
     * @description Lazily compiles the pattern that identifies a merge field
     */
    private static final Pattern MERGE_FIELD_PATTERN {
        get {
            if (MERGE_FIELD_PATTERN == null) {
                MERGE_FIELD_PATTERN = Pattern.compile(DELIM_START_ESCAPED + '(.*?)' + DELIM_END_ESCAPED);
            }
            return MERGE_FIELD_PATTERN;
        } 
        private set;
    }

    /**
     * @description Lazily compiles the pattern that identifies a block expression
     */
    private static final Pattern BLOCK_PATTERN {
        get {
            if (BLOCK_PATTERN == null) {
                String startBlock = '(?s)' + DELIM_START_ESCAPED + BLOCK_START + '(.*?)' + DELIM_END_ESCAPED;
                String endBlock = DELIM_START_ESCAPED + BLOCK_END_ESCAPED + '\\1' + DELIM_END_ESCAPED;
                BLOCK_PATTERN = Pattern.compile(startBlock + '(.*?)' + endBlock);
            }
            return BLOCK_PATTERN;
        }
        private set;
    }

    /**
     * @description Used to validate the parent sObject's merge fields
     */
    private final IMergeFieldValidator validator { get; private set; }

    /**
     * @description Used to validate the parent sObject's children's merge fields
     */
    private final IMergeFieldValidator childValidator { get; private set; }

    /**
     * @description Used to validate the children relationships to the parent sObject
     */
    private final IRelationshipValidator childRelationshipValidator { get; private set; }

    /**
     * @description A map of fields by SObjectType
     */
    private Map<Schema.SObjectType, Map<String, Schema.SObjectField>> fieldsMapBySObjectType =
        new Map<Schema.SObjectType, Map<String, Schema.SObjectField>>();

    /**
     * @description A map of field describes by SObjectType
     */
    private Map<Schema.SObjectType, Map<Schema.SObjectField, Schema.DescribeFieldResult>> fieldDescribeMapBySObjectType =
        new Map<Schema.SObjectType, Map<Schema.SObjectField, Schema.DescribeFieldResult>>();

    /**
     * @description Constructor for MergeFieldParser
     * @param validator The validator used to validate the parent sObject's merge fields
     * @param childValidator The validator used to validate the parent sObject's children's merge fields
     * @param childRelationshipValidator The validator used to validate the child relationships against the parent sObject
     */
    public MergeFieldParser(IMergeFieldValidator validator, IMergeFieldValidator childValidator, IRelationshipValidator childRelationshipValidator) {
        Guard.againstNull(validator, 'validator');
        Guard.againstNull(childValidator, 'childValidator');
        Guard.againstNull(childRelationshipValidator, 'childRelationshipValidator');
        this.validator = validator;
        this.childValidator = childValidator;
        this.childRelationshipValidator = childRelationshipValidator;
    }

    /**
     * @description Parses the merge fields of the input with respect to the related sObject with the specified Id
     * @param input The input to parse
     * @param relatedToId The Id of the parent sObject to parse the merge fields against
     * @return The parsed input with merge fields filled in with their corresponding values
     * 
     * @example
     * MergeFieldParser parser = new MergeFieldParser(validator, childValidator);
     * String parsedText = parser.parser(unparsedText, Id.valueOf('001xa000003DIlo'));
     */
    public String parse(String input, Id relatedToId) {
        Guard.againstNull(relatedToId, 'relatedToId');
    
        // If there is no input, or there are no merge fields then we're done
        if (String.isBlank(input) || collectMergeFields(input).isEmpty()) { return input; }

        String relatedToName = getSObjectName(relatedToId);
               
        // Validate children expressions first
        Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = validateChildExpressions(input);
        
        // Validate parent expressions next
        Map<String, Boolean> validityByField = validateParentExpressions(input, relatedToName);

        // Retrieve all field values
        SObject relatedTo = retrieveFieldValues(relatedToName, relatedToId, validityByField, validityByFieldByChildRelationship);

        // Merge children first followed by parent
        input = doChildMerges(input, relatedToName, relatedTo, validityByFieldByChildRelationship);
        return doMerge(input, relatedTo, validityByField);
    }

    /**
     * @description Validates `children` relationships and merge fields
     * @param input The input to validate `child` expressions from
     * @return The validity of the merge fields of the `child` sObjects by their name by their parent child relationship
     */
    public Map<String, Map<String, Boolean>> validateChildExpressions(String input) {
        Map<String, Set<String>> mergeFieldsByChildRelationship = collectChildMergeFields(input);

        Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>>();
        for (String childRelationship : mergeFieldsByChildRelationship.keySet()) {
            Set<String> mergeFields = mergeFieldsByChildRelationship.get(childRelationship); 
            IFieldValidationResult validationResult = validateChildMergeFields(childRelationship, mergeFields);
            if (!validationResult.isSuccess() && !validationResult.hasInvalidFields()) {
                Map<String, Boolean> validityByField = new Map<String, Boolean>();
                for (String mergeField : new List<String>(mergeFields)) {
                    validityByField.put(mergeField, false);
                }
                validityByFieldByChildRelationship.put(childRelationship, validityByField);
                continue;
            }
            
            Set<String> invalidMergeFields = validationResult.getInvalidFields();
            Map<String, Boolean> validityByField = new Map<String, Boolean>();
            for (String mergeField : new List<String>(mergeFields)) {
                validityByField.put(mergeField, !invalidMergeFields.contains(mergeField));
            }
            validityByFieldByChildRelationship.put(childRelationship, validityByField);
        }

        return validityByFieldByChildRelationship;
    }

    /**
     * @description Validates the `parent` level merge fields
     * @param input The input to validate `parent` expressions from
     * @param parentName The name of the `parent` sObject
     * @return The validity of the merge fields of the `parent` sObject by their names
     */
    public Map<String, Boolean> validateParentExpressions(String input, String parentName) {
        Set<String> mergeFields = collectMergeFields(removeBlocks(input));
    
        IFieldValidationResult validationResult = validateMergeFields(parentName, mergeFields);
        Set<String> invalidMergeFields = validationResult.getInvalidFields();
        Map<String, Boolean> validityByField = new Map<String, Boolean>();
        for (String mergeField : mergeFields) {
            validityByField.put(mergeField, !invalidMergeFields.contains(mergeField));
        }

        return validityByField;
    }

    /**
     * @description Returns a copy of input with all block expressions removed
     * @param input The input to remove block expressions from
     * @return A copy of the input with all block expressions removed
     */
    private String removeBlocks(String input) {
        return input.replaceAll(BLOCK_PATTERN.pattern(), '');
    }

    /**
     * @description Returns the sObject name of the record Id
     * @param recordId The record id to return the sObject name of
     * @return The sObject name of the record id
     */
    private String getSObjectName(Id recordId) {
        return recordId.getSobjectType().getDescribe().getName();
    }

    /**
     * @description Collects the merge fields from the input
     * NOTE: Does not include the merge field syntax itself only the value inside
     * @param input The input to parse the merge fields out of
     * @return The merge fields that were parsed from the input
     */
    private Set<String> collectMergeFields(String input) {
        Matcher mergeFieldMatcher = MERGE_FIELD_PATTERN.matcher(input);
        Set<String> mergeFields = new Set<String>();
        while (mergeFieldMatcher.find()) {
            // --|group 1|-- --|group 1|--
            // {{FirstName}} {{LastName}}
            mergeFields.add(mergeFieldMatcher.group(1));
        }
        return mergeFields;
    }

    /**
     * @description Collects the child merge fields from the input 
     * with respect to the child relationship they belong to
     * NOTE: Does not include the merge field syntax itself only the value inside
     * @param input The input to parse the child merge fields out of
     * @return The child merge fields parsed from the input by their respective child relationship name
     */
    private Map<String, Set<String>> collectChildMergeFields(String input) {
        Map<String, Set<String>> childRelationshipMap = new Map<String, Set<String>>();
        Matcher childRelationshipMatcher = BLOCK_PATTERN.matcher(input);
        while (childRelationshipMatcher.find()) {
            // ---|group 1|---------------------------
            // {{#Contacts}} {{FirstName}} {{LastName}} {{/Contacts}}
            String childRelationshipName = childRelationshipMatcher.group(1);
            if (!childRelationshipMap.containsKey(childRelationshipName)) {
                childRelationshipMap.put(childRelationshipName, new Set<String>());
            }

            // -------------|          group 2          |------------
            // {{#Contacts}} {{FirstName}} {{LastName}} {{/Contacts}}
            childRelationshipMap
                .get(childRelationshipName)
                .addAll(collectMergeFields(childRelationshipMatcher.group(2)));
        }

        return childRelationshipMap;
    }

    /**
     * @description Validates a set of merge fields against the sObject with the specified name
     * @param relatedToName The name of the sObject to validate the merge fields against
     * @param mergeFields The merge fields to validate
     * @return The result of the validation
     * 
     * @example
     * IFieldValidationResult isValid = validateMergeFields('Account', new Set<String> { Name, Owner.Name });
     */
    private IFieldValidationResult validateMergeFields(String relatedToName, Set<String> mergeFields) {
        return validate(relatedToName, mergeFields, this.validator);
    }

    /**
     * @description Validates a set of merge fields against the sObject which is referred to by the child relationship name
     * @param childRelationshipName The child relationship name which refers to the child sObject whose merge fields will be validated against
     * @param mergeFields The merge fields to validate
     * @return The result of the validation
     * 
     * @example
     * IFieldValidationResult isValid = validateChildMergeFields('Contacts', new Set<String> { LastName, Account.Name });
     */
    private IFieldValidationResult validateChildMergeFields(String childRelationshipName, Set<String> mergeFields) {
        return validate(childRelationshipName, mergeFields, this.childValidator);
    }

    /**
     * @description Validates a set of merge fields against the sObject with the specified name
     * or that is referenced to by the child relationship name
     * @param relation The name of the sObject `OR` the child relationship name to validate the merge fields against
     * @param mergeFields The merge fields to validate
     * @param validator The validator that will perform the validation
     * @return The result of the validation
     * 
     * @example
     * // Validates the merge fields against the Account object
     * IFieldValidationResult isValid = validate('Account', new Set<String> { Name, Owner.Name }, validator);
     * // Validates the merge fields against the Contact object
     * IFieldValidationResult isValid = validate('Contacts', new Set<String> { LastName, Account.Name }, childValidator);
     */
    private IFieldValidationResult validate(String relation, Set<String> mergeFields, IMergeFieldValidator validator) {
        return validator.validate(relation, mergeFields);
    }

    /**
     * @description Retrieves merge values for the parent sObject and all specified child sObjects
     * @param relatedToName The name of the `parent` sObject
     * @param relatedToId The id of the `parent` sObject
     * @param validityByField The validity of the merge fields of the `parent` sObject by their names
     * @param validityByFieldByChildRelationship The validity of the merge fields of the `child` sObjects by their name by their parent child relationship
     * @return The `parent` sObject which contains values for all merge fields and also has all specified child objects populated
     * with the respective values for their merge fields
     * 
     * @example
     * Map<String, Boolean> validityByField = new Map<String, Boolean> { 'Name' => true 'Owner.Name' => true };
     * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'LastName '=> true, 'Account.Name' => true};
     * Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>> { 'Contacts' => contactsValidityByField};
     * SObject acc = retrieveFieldValues('Account', '001...', validityByField, validityByFieldByChildRelationship);
     * @throws MergeFieldParserException When the parent sObject identified by the record id cannot be found
     */
    private SObject retrieveFieldValues(
        String relatedToName, 
        Id relatedToId, 
        Map<String, Boolean> validityByField, 
        Map<String, Map<String, Boolean>> validityByFieldByChildRelationship) 
    {
        List<SObject> relatedTo = new WithSharing()
            .retrieveFieldValues(relatedToName, relatedToId, validityByField, validityByFieldByChildRelationship);
        if (relatedTo.isEmpty()) {
            throw new MergeFieldParserException('Record ' + relatedToId + ' to perform merge against cannot be found');
        }
        return relatedTo[0];
    }

    /**
     * @description Performs `all` child merges, `repeated n times` for each child record returned
     * NOTE: The block expression is replaced with the empty string in the case of no records being returned
     * @param input The input text to replace the child merge blocks with their merged values
     * @param relatedToName The name of the `parent` sObject
     * @param relatedTo The `parent` sObject
     * @param validityByFieldByChildRelationship The validity of the merge fields of the `child` sObjects by their name by their parent child relationship
     * @return The merged text
     * 
     * @example
     * String input = '{{#Contacts}} Hi {{FirstName}} {{LastName}}! {{/Contacts}}';
     * SObject relatedTo = new Account(// with populated fields and child relationships and their fields);
     * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'FirstName '=> true, 'LastName' => true};
     * Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>> { 'Contacts' => contactsValidityByField};
     * String merged = doChildMerges(input, 'Account', relatedTo, validityByFieldByChildRelationship);
     *
     * // Assuming 2 Contacts exist then the result is as below
     * Hi Bob Smith!
     * Hi Jeremy Clark!
     */
    private String doChildMerges(
        String input, 
        String relatedToName, 
        SObject relatedTo, 
        Map<String, Map<String, Boolean>> validityByFieldByChildRelationship) 
    {
        Matcher childRelationshipMatcher = BLOCK_PATTERN.matcher(input);
        while (childRelationshipMatcher.find()) {
            // ---|group 1|---------------------------
            // {{#Contacts}} {{FirstName}} {{LastName}} {{/Contacts}}
            String childRelationship = childRelationshipMatcher.group(1);
            Map<String, Boolean> validityByField = validityByFieldByChildRelationship.get(childRelationship);

            // If the child relationship is invalid then replace all inner merge fields with the empty string
            if (isInvalidChildRelationship(relatedToName, childRelationship)) {
                relatedTo = null;
            }

            // -------------|          group 2          |------------
            // {{#Contacts}} {{FirstName}} {{LastName}} {{/Contacts}}
            String merged = doChildInnerMerges(childRelationshipMatcher.group(2), relatedTo, childRelationship, validityByField); 
            input = childRelationshipMatcher.replaceFirst(merged);
        }

        return input;
    }

    /**
     * @description Determines whether or not the child expression refers to an invalid relationship
     * for the related to sObject's name
     * @param relatedToName The name of the `parent` sObject
     * @param childRelationshipName The name of `child` relationship to test for invalidity
     * @return Whether the child relationship name is invalid for the related `parent` sObject
     */
    public Boolean isInvalidChildRelationship(String relatedToName, String childRelationshipName) {
        return !validateChildRelationship(relatedToName, childRelationshipName).isSuccess();
    }

    /**
     * @description Determines whether or not the child expression refers to a valid relationship
     * for the related to sObject's name
     * @param relatedToName The name of the `parent` sObject
     * @param childRelationshipName The name of `child` relationship to test for validity
     * @return Whether the child relationship name valid or not for the related `parent` sObject
     */
    public IRelationshipValidationResult validateChildRelationship(String relatedToName, string childRelationshipName) {
        return this.childRelationshipValidator.validate(relatedToName, childRelationshipName);
    }

    /**
     * @description Merges `all` inner merge fields across `all` occurrences of the child expressions blocks with the specified child relationship name
     * with their resulting merged input `repeated n times` for each child record returned.
     * NOTE: Each repletion is separated by a new line
     * 
     * @example
     * String input = 'Hi {{FirstName}} {{LastName}}!';
     * SObject relatedTo = new Account(// with populated fields and child relationships and their fields);
     * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'FirstName '=> true, 'LastName' => true};
     * String merged = doChildInnerMerges(input, relatedTo, 'Contacts', validityByFieldByChildRelationship);
     * 
     * // Assuming 2 Contacts exist then the result is as below
     * Hi Bob Smith!
     * Hi Jeremy Clark!
     */
    private String doChildInnerMerges(String input, SObject relatedTo, String childRelationship, Map<String, Boolean> validityByField) {
        List<String> merges = new List<String>();  
        
        // getSObjects return null if no records match
        if (relatedTo == null || relatedTo.getSObjects(childRelationship) == null) {
            merges.add(doMerge(input, null, validityByField));
        } else {
            for (SObject childRecord : relatedTo.getSObjects(childRelationship)) {
                merges.add(doMerge(input, childRecord, validityByField));
            }
        }

        return String.join(merges, '\n');
    }

    /**
     * @description Merges `all` occurrences of each merge field in the input with the corresponding value
     * invalid fields related to the parent sObject or fields that have no value are replaced with the empty string
     * @param input The input text to merge
     * @param relatedTo The sObject whose values to use to perform the merge
     * @param validityByMergeField The merge fields to be filled in during the merge by their validity status
     * 
     * @example 
     * String input = 'Hi {{Owner.Name}} how is {{Name}} doing?';
     * SObject relatedTo = new Account(Name = 'Tesla', Owner.Name = 'Elon');
     * Map<String, Boolean> validityByMergeField = new Map<String, Boolean>{ Name => true, Owner.Name => false };
     * String merged = doMerge(input, relatedTo,  mergeFields);
     * 
     * // merged
     * Hi Elon how is doing?
     */
    private String doMerge(String input, SObject relatedTo, Map<String, Boolean> validityByMergeField) {
        for (String mergeField : validityByMergeField.keySet()) {
            Boolean isValid = validityByMergeField.get(mergeField);
            input = relatedTo == null || !isValid
                ? input.replace(DELIM_START + mergeField + DELIM_END, '')
                : doMerge(input, relatedTo, mergeField);
        }

        return input;
    }

    /**
     * @description Merges `all` occurrences of each merge field in the input with the corresponding value
     * @param input The input text to merge
     * @param relatedTo The sObject whose values to use to perform the merge
     * @param mergeField The merge field to be merged
     * 
     * @example 
     * String input = 'Hi {{FirstName}} how are you?';
     * SObject relatedTo = new Contact(FirstName = 'Elon');
     * String mergeField = 'FirstName';
     * String merged = doMerge(input, relatedTo,  mergeField);
     * 
     * // merged
     * Hi Elon how are you?
     */
    private String doMerge(String input, SObject relatedTo, String mergeField) {
        Object fieldValue = getFieldValue(relatedTo, mergeField);
        return fieldValue == null
            ? input.replace(DELIM_START + mergeField + DELIM_END, '')
            : input.replace(DELIM_START + mergeField + DELIM_END, String.valueOf(fieldValue));
    }

    /**
     * @description Gets the value of the field specified by the field path
     * @param sObj The sObj to retrieve the value from or the base object in the path
     * @param fieldRef The path to the value desired
     * @return The value of the field at the specified path
     * 
     * @example
     * String name = (String) getFieldValue(account, 'Account.Owner.Name');
     */
    private Object getFieldValue(SObject sObj, String fieldRef) {
        if (sObj == null) { return null; }
        
        if (fieldRef.contains(PATH_DELIMITER)) {
            sObj = sObj.getSObject(fieldRef.subStringBefore(PATH_DELIMITER));
            fieldRef = fieldRef.subStringAfter(PATH_DELIMITER);
            return getFieldValue(sObj, fieldRef);
        }

        return formatValue(sObj, fieldRef);
    }

    //TODO: Think about introducing a configuration object that would hold formatting rules per data type
    /**
     * @description Formats the value that is held by the field on the sObject
     * formats according to the display type of the field
     * @param sObj The sObject whose field value will be formatted
     * @param fieldName The name of the field whose value will be formatted
     * @return The formatted value according to the `DisplayType` of the field
     * 
     * @example
     * Account acc = new Account(Type = 'Big Company') // picklist api value
     * Object fieldValue = formatValue(acc, 'Type', 'Big Company');
     * 
     * // fieldValue with picklist label for api value returned
     * Enterprise
     */
    private Object formatValue(SObject sObj, String fieldName) {
        if (String.isBlank(String.valueOf(sObj.get(fieldName)))) { return null; }
        
        Object value = sObj.get(fieldName.trim());
        Schema.SObjectType sObjectType = sObj.getSObjectType();
        Schema.SObjectField field = getFieldsMap(sObjectType).get(fieldName);
        Schema.DescribeFieldResult fieldDescribe = getFieldsDescribeMap(sObjectType, field).get(field);

        switch on fieldDescribe.getType() {
            when BOOLEAN {
                return Boolean.valueOf(value);
            }
            when CURRENCY {
                return formatCurrency((Decimal) value);
            }
            when DATE {
                return Date.valueOf(value).format();
            }
            when DATETIME {
                return DateTime.valueOf(value).format();
            }
            when DOUBLE {
                return Double.valueOf(value).format();
            }
            when INTEGER {
                return Integer.valueOf(value).format();
            }
            when LONG {
                return Long.valueOf(String.valueOf(value)).format();
            }
            when PICKLIST {
                return getPicklistLabel(sObj, fieldName, fieldDescribe);
            }
            when TIME {
                List<String> tokens = ((String) value).split(':');
                return Time.newInstance(
                    Integer.valueOf(tokens[0]), 
                    Integer.valueOf(tokens[1]), 
                    Integer.valueOf(tokens[2]), 0);
            }
            when else {
                return String.valueOf(value);
            }
        }
    }

    /**
     * @description Formats the decimal as currency
     * https://salesforce.stackexchange.com/a/17125
     * @param The currency field to format as a currency
     * @return String the formatted amount
     */
    private String formatCurrency(Decimal i) {
        if (i == null) { return '\\$0.00'; }
        i = Decimal.valueOf(Math.roundToLong(i * 100)) / 100;
        String s = (i.setScale(2) + (i >= 0 ? 0.001 : -0.001)).format();
        return ('\\$' + s.substring(0, s.length() - 1));
    }

    /**
     * @description Gets the map of field describe results for a sObject type and its associated field
     * NOTE: Returns a cached result if present instead of describing again
     * @param sObjectType the sObject type to obtain the fields describe map from
     * @param field The sObject field to retrieve field describe results for
     * @return The map of field describes for the sObject type's field
     */
    private Map<Schema.SObjectField, Schema.DescribeFieldResult> getFieldsDescribeMap(Schema.SObjectType sObjectType, Schema.SObjectField field) {
        // Have not described this object's fields previously
        if (!this.fieldDescribeMapBySObjectType.containsKey(sObjectType)) {
            Map<Schema.SObjectField, Schema.DescribeFieldResult> fieldsDescribeMap = 
                new Map<Schema.SObjectField, Schema.DescribeFieldResult>();
            
            this.fieldDescribeMapBySObjectType.put(sObjectType, new Map<Schema.SObjectField, Schema.DescribeFieldResult>());
        }

        // We have described this object's fields previously but potentially not this particular field
        if (!this.fieldDescribeMapBySObjectType.get(sObjectType).containsKey(field)) {
            this.fieldDescribeMapBySObjectType.get(sObjectType).put(field, field.getDescribe());
        }

        return this.fieldDescribeMapBySObjectType.get(sObjectType);
    }

    /**
     * @description Gets the map of fields for a sObject type
     * NOTE: Returns a cached result if present instead of describing again
     * @param sObjectType the sObject type to obtain the fields map from
     * @return The map of fields for the sObject type
     */
    private Map<String, Schema.SObjectField> getFieldsMap(Schema.SObjectType sObjectType) {
        if (!this.fieldsMapBySObjectType.containsKey(sObjectType)) {
            this.fieldsMapBySObjectType.put(sObjectType, sObjectType.getDescribe().fields.getMap());
        }

       return this.fieldsMapBySObjectType.get(sObjectType);
    }

    /**
     * @description Returns the picklist entry label associated with its value
     * @param sObj The sObj to retrieve the label of the picklist field from
     * @param picklistField The picklist field
     * @param picklistDescribe The describe result of the picklist field
     * @return The label of the picklist or the string value of the field if it was not found
     */
    public String getPicklistLabel(SObject sObj, String picklistField, Schema.DescribeFieldResult picklistDescribe) {
        for (Schema.PicklistEntry entry : picklistDescribe.getPicklistValues()) {
            if (entry.getValue() == sObj.get(picklistField)) {
                return entry.getLabel();
            }
        }

        // Value not found default back to unformatted value
        return String.valueOf(sObj.get(picklistField));
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Inner class used to perform the SOQL query to retrieve field values
     * ensures that this query runs in a with sharing context, preventing users accessing
     * records they shouldn't be able to
     */
    private with sharing class WithSharing {
        /**
         * @description Retrieves merge values for the parent sObject and all specified child sObjects
         * @param relatedToName The name of the `parent` sObject
         * @param relatedToId The id of the `parent` sObject
         * @param validityByField The validity of the merge fields of the `parent` sObject by their names
         * @param validityByFieldByChildRelationship The validity of the merge fields of the `child` sObjects by their name by their parent child relationship
         * @return The `parent` sObject which contains values for all merge fields and also has all specified child objects populated
         * with the respective values for their merge fields
         * 
         * @example
         * Map<String, Boolean> validityByField = new Map<String, Boolean> { 'Name' => true 'Owner.Name' => true };
         * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'LastName '=> true, 'Account.Name' => true};
         * Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>> { 'Contacts' => contactsValidityByField};
         * SObject acc = new WithSharing().retrieveFieldValues('Account', '001...', validityByField, validityByFieldByChildRelationship);
         */
        private List<SObject> retrieveFieldValues(
            String relatedTo, 
            Id relatedToId, 
            Map<String, Boolean> validityByField, 
            Map<String, Map<String, Boolean>> validityByFieldByChildRelationship) 
        {   
            return Database.query(buildQuery(relatedTo, relatedToId, validityByField, validityByFieldByChildRelationship));
        }

        /**
         * @description Retrieves merge values for the parent sObject and all specified child sObjects
         * @param relatedToName The name of the `parent` sObject
         * @param relatedToId The id of the `parent` sObject
         * @param validityByField The validity of the merge fields of the `parent` sObject by their names
         * @param validityByFieldByChildRelationship The validity of the merge fields of the `child` sObjects by their name by their parent child relationship
         * @return The `parent` sObject which contains values for all merge fields and also has all specified child objects populated
         * with the respective values for their merge fields
         * 
         * @example
         * Map<String, Boolean> validityByField = new Map<String, Boolean> { 'Name' => true 'Owner.Name' => true };
         * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'LastName '=> true, 'Account.Name' => true};
         * Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>> { 'Contacts' => contactsValidityByField};
         * SObject acc = new WithSharing().buildQuery('Account', '001...', validityByField, validityByFieldByChildRelationship);
         */
        private String buildQuery(
            String relatedTo, 
            Id relatedToId, 
            Map<String, Boolean> validityByField, 
            Map<String, Map<String, Boolean>> validityByFieldByChildRelationship) 
        {
            List<String> parentFields = getValidFields(validityByField);
            List<String> childQueries = buildChildQueries(validityByFieldByChildRelationship);

            return String.format('SELECT {0} {1} FROM {2} WHERE Id =: relatedToId', 
                new List<String> { 
                    parentFields.isEmpty()
                        ? ''
                        : childQueries.isEmpty() 
                            ? String.escapeSingleQuotes(String.join(parentFields, ', '))
                            : String.escapeSingleQuotes(String.join(parentFields, ', ')) + ', ', 
                    String.join(childQueries, ', '),
                    String.escapeSingleQuotes(relatedTo) 
                }
            );
        }

        /**
         * @description Builds a list of child queries to retrieve the required information
         * @param validityByFieldByChildRelationship The validity of child fields by their field name by their child relationship name
         * @return The child queries for all child relationships
         * 
         * @example
         * Map<String, Boolean> contactsValidityByField = new Map<String, Boolean> { 'Name' => true 'Ownerx' => false };
         * Map<String, Boolean> casesValidityByField = new Map<String, Boolean> { 'Name' => true 'Account.Name' => true };
         * Map<String, Map<String, Boolean>> validityByFieldByChildRelationship = new Map<String, Map<String, Boolean>> { 
         *     'Contacts' => contactsValidityByField,
         *     'Cases' => casesValidityByField
         * };
         * List<String> childQueries = buildChildQueries(validityByFieldByChildRelationship);
         * 
         * // childQueries
         * [(SELECT Name FROM Contacts), (SELECT Name, Account.Name FROM Cases)];
         */
        private List<String> buildChildQueries(Map<String, Map<String, Boolean>> validityByFieldByChildRelationship) {
            List<String> childQueries = new List<String>();
            for (String childRelationship : validityByFieldByChildRelationship.keySet()) {
                List<String> validFields = getValidFields(validityByFieldByChildRelationship.get(childRelationship));
                if (!validFields.isEmpty()) {
                    childQueries.add(buildChildQuery(childRelationship, validFields));
                }
            }

            return childQueries;
        }

        /**
         * @description Builds a parent-to-child sub query to retrieve the valid fields from the child relationship name
         * @param childRelationship The child relationship name to be specified in the sub query
         * @param validFields The valid fields to retrieve from the child object
         * @return The child subquery
         * 
         * @example
         * String childQuery = buildChildQuery('Contacts', new List<String> { FirstName, LastName });
         * 
         * // childQuery
         * (SELECT FirstName, LastName FROM Contacts)
         */
        private String buildChildQuery(String childRelationship, List<String> validFields) {
            String childRelationshipQuery = String.format('(SELECT {0} FROM {1})',
                new List<String> { 
                    String.escapeSingleQuotes(String.join(validFields, ', ')), 
                    String.escapeSingleQuotes(childRelationship) 
                }
            );

            return childRelationshipQuery;
        }

       /**
        * @description Gets a list of valid fields
        * @param validityByField The map of fields by their validity
        * @return The valid fields
        */
        private List<String> getValidFields(Map<String, Boolean> validityByField) {
            List<String> validFields = new List<String>();
            for (String field : validityByField.keySet()) {
                if (validityByField.get(field)) { 
                    validFields.add(field);
                }
            }

            return validFields;
        }
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Exception class used by MergeFieldParser
     */
    public class MergeFieldParserException extends Exception {

    }
}