@isTest
public with sharing class GuardTest {

    @isTest
    static void guardTest() {
        try {
            Guard.againstNull(null, 'param');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('param cannot be null'));
        }

        try {
            Guard.againstBlank('', 'param');
        } catch (Exception e) {
            System.assert(e.getMessage().contains('param cannot be blank'));
        }
    }
}