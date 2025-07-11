/**
 * @author Stewart McDiarmid
 * @date September 2021
 * @description Holds a relationship validation result
 */
public interface IRelationshipValidationResult extends IValidationResult {
    /**
     * @description Gets the name related object
     * @return The name of the related object
     */
    String getRelatedObject();
}