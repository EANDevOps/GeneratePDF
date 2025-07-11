/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Holds a field validation result
 */
public abstract class FieldValidationResult extends ValidationResult implements IFieldValidationResult {
    /**
     * @description Constructor for FieldValidationResult
     * @param result The field validation result
     * @param message <Optional> The field validation message
     */
    public FieldValidationResult(Boolean result, String message) {
        super(result, message);
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Represents a successful field validation
     */
    public class Ok extends FieldValidationResult {
        /**
         * @description Constructor for Ok
         */
        public Ok() {
            super(true, null);
        }

        /**
         * @description If the validation was successful then there were no invalid fields
         * @return An empty set of strings
         */
        public Set<String> getInvalidFields() {
            return new Set<String>();
        }

         /**
         * @description If the validation was successful then there were no invalid fields
         * @return false
         */
        public Boolean hasInvalidFields() {
            return false;
        }
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Represents an unsuccessful field validation
     */
    public class Error extends FieldValidationResult {
        /**
         * @description The invalid fields that were identified during validation
         * @return The invalid fields identified
         */
        private final Set<String> invalidFields { get; private set; }

        /**
         * @description Constructor for Error
         * @param message The error message 
         */
        public Error(String message, Set<String> invalidFields) {
            super(false, message);
            this.invalidFields = invalidFields;
        }

        /**
         * @description Constructor for Error
         * @param message The error message
         */
        public Error(String message) {
            super(false, message);
            this.invalidFields = new Set<String>();
        }

        /**
         * @description Whether there are any invalid fields associated with the failed validation result
         * NOTE: This might not be the case for example if the object attempting to be verified against is not valid
         * @return Whether there are any invalid fields associated with the failed validation result
         */
        public Boolean hasInvalidFields() {
            return !this.invalidFields.isEmpty();
        }

        /**
         * @description Gets the invalid fields associated with the failed validation result if present
         * @return The invalid fields associated with the failed validation results if present
         */
        public Set<String> getInvalidFields() {
            return this.invalidFields;
        }
    }
}