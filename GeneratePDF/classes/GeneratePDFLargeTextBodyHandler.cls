public with sharing class GeneratePDFLargeTextBodyHandler { 
 
    public class FlowInput {
        @InvocableVariable(label='Text Payload' required=false)
        public String textPayload;
        
        @InvocableVariable(label='Record Id' description='Optional ID of the existing record to update' required=false)
        public Id recordId;
        
        @InvocableVariable(label='Object API Name' required=true)
        public String objectApiName;
        
        @InvocableVariable(label='Field API Names' description='Comma-separated list of long text field API names' required=true)
        public String fieldApiNames;
    }
 
    public class FlowOutput {
        @InvocableVariable(label='Success' description='Whether the operation succeeded')
        public Boolean success;
        
        @InvocableVariable(label='Message' description='Result message or error details')
        public String message;
        
        @InvocableVariable(label='Record Id' description='ID of the created or updated record')
        public Id recordId;
    }
    
    @InvocableMethod(label='Generate PDF from Large Text' description='Splits large text content into multiple fields on a record')
    public static List<FlowOutput> processLargeTextFromFlow(List<FlowInput> flowInputs) {
        List<FlowOutput> results = new List<FlowOutput>();
        
        for (FlowInput input : flowInputs) {
            FlowOutput result = new FlowOutput();
            try {
                result.recordId = upsertDynamicRecord(input.textPayload, input.recordId, input.objectApiName, input.fieldApiNames);
                result.success = true;
                result.message = 'Successfully processed text payload';
            } catch (Exception e) {
                result.success = false;
                result.message = e.getMessage();
            }
            results.add(result);
        }
        
        return results;
    }
    
    public static Id upsertDynamicRecord(String textPayload, Id recordId, String objectApiName, String fieldApiNames) {
        try { 
            SObject record = (recordId != null) ? 
                Schema.getGlobalDescribe().get(objectApiName.toLowerCase()).newSObject(recordId) : 
            Schema.getGlobalDescribe().get(objectApiName.toLowerCase()).newSObject();
            
            List<String> fields = fieldApiNames.split(',');
            
            if (String.isBlank(textPayload)) { 
                for (String field : fields) {
                    record.put(field.trim(), null);
                }
            } else {
                Integer textStringLength = textPayload.length();
                Integer startIndex = 0;
                
                for (Integer i = 0; i < fields.size(); i++) {
                    String field = fields[i].trim();
                    Integer characterLimit = (i == 0) ? 2500 : 3500; 
                    
                    if (startIndex < textStringLength) {
                        Integer endIndex = findSafeBreakPoint(textPayload, startIndex, characterLimit);
                        record.put(field, textPayload.substring(startIndex, endIndex));
                        startIndex = endIndex;
                    } else { 
                        record.put(field, null);
                    }
                }
                
                if (startIndex < textStringLength) {
                    throw new OMSCustomException('Text Payload received has exceeded maximum allowed length');
                }
            }
            
            upsert record;
            return (Id) record.get('Id');
        } catch (Exception e) {
            throw e;
        }
    }
    
    @TestVisible
    private static Integer findSafeBreakPoint(String text, Integer startIndex, Integer maxLength) {
        Integer endPos = startIndex + maxLength;
        if (endPos >= text.length()) {
            return text.length();
        } 
        
        String textPortion = text.substring(startIndex, endPos); 
        List<String> breakTags = new List<String>{'</p>', '</div>', '</li>', '</h1>', '</h2>', '</h3>', '<br>', '<br/>', '<hr>', '<hr/>'};
            
            for (String tag : breakTags) {
                Integer lastTagPos = textPortion.lastIndexOf(tag);
                if (lastTagPos != -1) { 
                    return startIndex + lastTagPos + tag.length();
                }
            }
        
        Integer lastSpacePos = textPortion.lastIndexOf(' ');
        if (lastSpacePos != -1) {
            return startIndex + lastSpacePos + 1;
        } 
        return endPos;
    }
    
    public class OMSCustomException extends Exception {}
}