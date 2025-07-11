public with sharing class GeneratePDFSelector {

    public static List<EmailTemplate> getTemplatesByFolderName(List<String> folderNames) {
        
        return [SELECT Id, Name, DeveloperName, FolderId, FolderName, Subject, HtmlValue, Body
                  FROM EmailTemplate 
                 WHERE Folder.DeveloperName IN :folderNames];
    }

    public static EmailTemplate getTemplateById(String templateId) {

        List<EmailTemplate> templates = [
            SELECT Id, Name, DeveloperName, FolderId, FolderName, Subject, HtmlValue, Body, Markup
              FROM EmailTemplate 
             WHERE Id = :templateId];

        return templates.isEmpty() ? null : templates[0];
    }

    public static List<Generate_PDF__c> getGeneratedPdfs(String parentId, String field, String fields) {
        return Database.query('SELECT Id, ' + fields + ' FROM Generate_PDF__c WHERE ' + field + ' = :parentId ORDER BY CreatedDate DESC LIMIT 10');
    }

    public static ContentVersion getContentById(String contentId) {

        List<ContentVersion> version = [SELECT Id, VersionData, ContentDocumentId
            FROM ContentVersion WHERE Id = :contentId LIMIT 1];
            
        return version.isEmpty() ? null : version[0];
    }
}