/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Holds a validation result
 */
public abstract class ValidationResult implements IValidationResult {
    /**
     * @description The validation result
     */
    private final Boolean result { get; private set; }

    /**
     * @description <Optional> The validation message
     */
    private final String message { get; private set; }

    /**
     * @description Constructor for ValidationResult
     * @param result The validation result
     * @param message <Optional> The validation message
     */
    public ValidationResult(Boolean result, String message) {
        this.result = result;
        this.message = message;
    }

    /**
     * @description Whether the validation was a success or not
     * @return Whether the validation was a success or not
     */
    public Boolean isSuccess() {
        return this.result;
    }

    /**
     * @description <Optional> The message related to the validation
     * @return <Optional> The message related to the validation
     */
    public String getMessage() {
        return this.message;
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Represents a successful validation
     */
    public class Ok extends ValidationResult {
        /**
         * @description Constructor for Ok
         */
        public Ok() {
            super(true, null);
        }
    }

    /**
     * @author Stewart McDiarmid
     * @date September 2021
     * @description Represents an unsuccessful validation
     */
    public class Error extends ValidationResult {
        /**
         * @description Constructor for Error
         * @param message The error message 
         */
        public Error(String message) {
            super(false, message);
        }
    }
}