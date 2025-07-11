public class Guard {
    public static void againstNull(Object input, String parameterName) {
        if (input == null) {
            throw new IllegalArgumentException(parameterName + ' cannot be null');
        }
    }

    public static void againstBlank(String input, String parameterName) {
        if (String.isBlank(input)) {
            throw new IllegalArgumentException(parameterName + ' cannot be blank');
        }
    }
}