public interface IFieldValidationResult extends IValidationResult {
    /**
     * @description Whether there are any invalid fields associated with the failed validation result
     * @return Whether there are any invalid fields associated with the failed validation result
     */
    Boolean hasInvalidFields();

    /**
     * @description Gets the invalid fields associated with the failed validation
     * @return The invalid fields associated with the failed validation
     */
    Set<String> getInvalidFields();
}