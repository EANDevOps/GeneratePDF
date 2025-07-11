/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Holds a validation result
 */
public interface IValidationResult {
    /**
     * @description Whether the validation was a success or not
     * @return Whether the validation was a success or not
     */
    Boolean isSuccess();

    /**
     * @description <Optional> The message related to the validation
     * @return <Optional> The message related to the validation
     */
    String getMessage();
}