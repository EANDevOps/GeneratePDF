# Generate PDF Lightning Web Component Suite

## Introduction
The Generate PDF application is a comprehensive Salesforce Lightning Web Component (LWC) solution designed to automate PDF generation from email templates with advanced merge field capabilities. 

Built for the EA Network by Datacom and later more functionality has been added by EA Networks, this solution addresses the business challenge of manually creating Cost Agreements, Quotes and other documents by providing an intuitive, component-based approach to document generation.

## Application Capabilities

The Generate PDF suite provides the following comprehensive features:

### Core Features
- **Dynamic Template Selection**: Folder-based template organization and selection
- **Multi-Object Support**: Works with any Salesforce sObject through configuration
- **Advanced Merge Field Processing**: Custom syntax supporting complex data scenarios
- **Parent/Child Relationship Traversal**: Navigate up to 5 levels in object hierarchy
- **Repeatable Child Record Merging**: Dynamic iteration through related records
- **PDF Preview**: Live template preview with merged data
- **PDF Generation & Attachment**: Create and attach PDFs to records automatically
- **Generation History Tracking**: Complete audit trail of PDF generation attempts
- **Email Integration**: Send generated PDFs via email (in development)

### Advanced Merge Field Capabilities
- Standard Salesforce merge fields: `{!FieldName__c}`
- Custom merge syntax: `{{Field__c}}`
- Child record iteration: `{{#ChildRelationship__r}} content {{/ChildRelationship__r}}`
- Parent field traversal: `{{Account.Owner.Name}}`
- Validation framework for field and relationship integrity

## Technical Architecture

### System Overview
The Generate PDF application follows a modular architecture with clear separation of concerns:

### Component Architecture

#### Lightning Web Components
- **generatePdf** (Main component)
- **generatePdfDoc** (Template selection)
- **generatePdfHistory** (History display)
- **generatePdfPreview** (Modal preview)
- **generatePdfUtil** (Shared utilities)
- **combobox** (Reusable dropdown)

#### Apex Controllers
- **GeneratePDFController** (Main business logic)
- **GeneratePDFFlowHandler** (Flow integration)
- **GeneratePDFFlowHandlerBulk** (Bulk processing)
- **GeneratePDFSelector** (Data access layer)
- **GeneratePDFBatchLauncher** (Batch coordination)

#### Validation Framework
- **IMergeFieldValidator** (Interface)
- **ChildMergeFieldValidator** (Child field validation)
- **IRelationshipValidator** (Interface)
- **ChildRelationshipValidator** (Relationship validation)
- **ValidationHandler** (General validation)
- **FieldValidationResult** (Result container)
- **ValidationResult** (General results)
- **IValidationResult** (Interface)
- **MergeFieldParser** (Core merge field parser)

#### Supporting Services
- **GeneratePDFLargeTextBodyHandler** (Large text processing)
- **Guard** (Null checking utility)
- **TestDataFactory** (Test data creation)

#### Presentation Layer
- **GeneratePDFPreview.page** (Visualforce PDF renderer)

#### Data Layer
- **Generate_PDF__c** (History and audit trail)
- **GeneratePDF_Config__c** (Configuration storage)
- **EmailTemplate** (Salesforce standard)
- **ContentDocument** (File storage)
- **ContentVersion** (File versioning)
- **ContentDocumentLink** (File associations)

#### Integration Layer
- **Flow/Process Builder** (External automation)
- **Messaging.SingleEmailMessage** (Email services)
- **SOQL** (Data queries)

**All dependencies are now included in the codebase.**

### Core Components

#### Lightning Web Components (LWC)

1. **generatePdf** (Main Component)
   - **File**: `force-app/main/default/lwc/generatePdf/`
   - **Purpose**: Primary UI component orchestrating the entire PDF generation process
   - **Features**:
     - Template selection interface
     - PDF/Email mode switching
     - Generation triggers and progress indicators
     - Error handling and user feedback
   - **Dependencies**: All other LWC components, GeneratePDFController
   - **API Properties**:
     - `@api recordId`: Current record ID
     - `@api parentField`: Lookup field API name
     - `@api enabledFolders`: Comma-separated folder names
     - `@api isOnSidebar`: UI layout flag
     - `@api disableEmail`: Feature toggle

2. **generatePdfDoc**
   - **File**: `force-app/main/default/lwc/generatePdfDoc/`
   - **Purpose**: Template selection and preview interface
   - **Features**: Dynamic template dropdown, preview functionality

3. **generatePdfHistory**
   - **File**: `force-app/main/default/lwc/generatePdfHistory/`
   - **Purpose**: Display generation history and download links
   - **Features**: Tabular history view, download navigation, responsive design

4. **generatePdfPreview**
   - **File**: `force-app/main/default/lwc/generatePdfPreview/`
   - **Purpose**: Modal preview of generated PDF content
   - **Features**: Live template rendering with actual data

5. **generatePdfUtil**
   - **File**: `force-app/main/default/lwc/generatePdfUtil/`
   - **Purpose**: Shared utilities and constants
   - **Contents**:
     - Message constants
     - UI configuration maps
     - Type definitions

6. **combobox**
   - **File**: `force-app/main/default/lwc/combobox/`
   - **Purpose**: Reusable dropdown component
   - **Features**: Custom styling, event handling

#### Apex Classes

### Controller Layer

1. **GeneratePDFController**
   - **File**: `force-app/main/default/classes/GeneratePDFController.cls`
   - **Purpose**: Main controller handling UI interactions and PDF generation
   - **Key Methods**:
     - `validateConfig()`: Validates component configuration
     - `generatePdfFile()`: Orchestrates PDF creation process
     - `getTableData()`: Retrieves history data for UI
     - `emailTemplateOptions()`: Provides template selection options
     - `createDocument()`: Handles PDF rendering and storage
     - `renderTemplate()`: Processes merge fields using validation framework
   - **Dependencies**: GeneratePDFSelector, Validation Framework, VF Page

2. **GeneratePDFFlowHandler**
   - **File**: `force-app/main/default/classes/GeneratePDFFlowHandler.cls`
   - **Purpose**: Flow/Process Builder integration for automated PDF generation
   - **Features**:
     - `@InvocableMethod` for Flow integration
     - Bulk processing support
     - Email sending capabilities
     - Error handling and response management
   - **Input/Output Classes**:
     - `GeneratePdfRequest`: Input parameters
     - `GeneratePdfResponse`: Output results

3. **GeneratePDFFlowHandlerBulk**
   - **File**: `force-app/main/default/classes/GeneratePDFFlowHandlerBulk.cls`
   - **Purpose**: Handles bulk PDF generation scenarios
   - **Features**: Optimized for high-volume processing

4. **GeneratePDFSelector**
   - **File**: `force-app/main/default/classes/GeneratePDFSelector.cls`
   - **Purpose**: Data access layer for templates and configurations
   - **Features**: SOQL optimization, caching, template retrieval

### Validation Framework

The application includes a sophisticated validation framework to ensure merge field integrity:

1. **IMergeFieldValidator** (Interface)
   - **File**: `force-app/main/default/classes/IMergeFieldValidator.cls`
   - **Purpose**: Contract for field validation implementations

2. **MergeFieldValidator** 
   - **File**: `force-app/main/default/classes/MergeFieldValidator.cls`
   - **Purpose**: Validates standard merge fields against sObject schema
   - **Features**: Field existence verification, type checking

3. **MergeFieldParser**
   - **File**: `force-app/main/default/classes/MergeFieldParser.cls`
   - **Purpose**: Core engine for parsing and processing merge field syntax
   - **Features**: 
     - Parses custom {{field}} syntax
     - Handles child relationship iterations {{#Child}} {{/Child}}
     - Coordinates with validation framework
     - Processes parent field traversal
   - **Dependencies**: IMergeFieldValidator, IRelationshipValidator

4. **ChildMergeFieldValidator**
   - **File**: `force-app/main/default/classes/ChildMergeFieldValidator.cls`
   - **Purpose**: Validates child relationship merge fields
   - **Features**: Relationship traversal validation, nested field checking
   - **Dependencies**: IRelationshipValidator, IMergeFieldValidator

4. **ChildMergeFieldValidator**
   - **File**: `force-app/main/default/classes/ChildMergeFieldValidator.cls`
   - **Purpose**: Validates child relationship merge fields
   - **Features**: Relationship traversal validation, nested field checking
   - **Dependencies**: IRelationshipValidator, IMergeFieldValidator, Guard

5. **ChildRelationshipValidator**
   - **File**: `force-app/main/default/classes/ChildRelationshipValidator.cls`
   - **Purpose**: Validates child relationship definitions
   - **Features**: Relationship existence verification, cardinality checking

5. **Result Classes**:
   - `FieldValidationResult`: Field validation outcomes
   - `ValidationResult`: General validation results
   - `IValidationResult`: Validation result interface

### Data Layer

#### Custom Objects

1. **Generate_PDF__c**
   - **File**: `force-app/main/default/objects/Generate_PDF__c/`
   - **Purpose**: Stores PDF generation history and audit trail
   - **Key Fields**:
     - Dynamic lookup fields to parent objects
     - `Status__c`: Generation status (Generated/Failed)
     - `Type__c`: Operation type (PDF/Email)
     - `Download_Path__c`: File access URL
     - `Email_Template__c`: Template name used
     - `File_Template__c`: File template used
     - Timestamp fields for audit trail

2. **GeneratePDF_Config__c** (Custom Setting)
   - **File**: `force-app/main/default/objects/GeneratePDF_Config__c/`
   - **Purpose**: Application configuration storage
   - **Key Fields**:
     - `Enabled_Folders__c`: Default template folders

### Supporting Components

1. **GeneratePDFLargeTextBodyHandler**
   - **File**: `force-app/main/default/classes/GeneratePDFLargeTextBodyHandler.cls`
   - **Purpose**: Handles large text processing for templates

2. **GeneratePDFBatchLauncher**
   - **File**: `force-app/main/default/classes/GeneratePDFBatchLauncher.cls`
   - **Purpose**: Batch processing coordination

3. **Guard**
   - **File**: `force-app/main/default/classes/Guard.cls`
   - **Purpose**: Utility class providing null checking and validation
   - **Features**:
     - `againstNull(Object, String)`: Validates non-null parameters
     - Parameter validation with descriptive error messages
     - Used throughout validation framework

4. **TestDataFactory**
   - **File**: `force-app/main/default/classes/TestDataFactory.cls`
   - **Purpose**: Centralized test data creation utility
   - **Features**:
     - `createAccountAsElectricityCustomer()`: Creates test Account records
     - Standardized test data patterns
     - Used across all test classes

### Presentation Layer

#### Visualforce Pages

1. **GeneratePDFPreview**
   - **File**: `force-app/main/default/pages/GeneratePDFPreview.page`
   - **Purpose**: Renders email templates as PDF documents
   - **Features**:
     - Converts HTML email templates to PDF format
     - Handles merge field processing
     - Template styling preservation
     - CSS extraction and application
   - **Controller**: GeneratePDFController
   - **Usage**: Called by GeneratePDFController.createDocument() method

## Setup and Configuration
The application requires the following steps for it to work on a Salesforce record.

Steps

Description

Create a lookup relationship

Create a lookup relationship field on Generate_PDF__c custom object that lookup to the target object, i.e. Contract__c

Exposed the related list on the parent record

After creating the lookup relationship field, the Generate PDF related list will be available on the target object, expose this on the page layout and add the desired field columns

Set the permission

Ensure that the user who will use the application has the Read and Create permission on the Generate_PDF__c object.

Create custom setting

Defined the folders of the templates you want to expose for the particular target object.

Go to Setup > Custom Settings > GeneratePDF Config > Manage
Populate the Enabled Folders field with the api name of the template folders that will be set as the default folders for the application

Add the component in the page

Open a record where you want to expose the app and click “Edit Page”

Search for the component “Generate PDF” and drag and drop it on the desired place, tick the “On Sidebar” checkbox if you place the component on the side bar.

Ensure that the Parent Field is populated with the API name of the custom field that was created on step 1.

If you wish to use the default folder listed on the custom settings, leave the Enabled folders blank otherwise populate it with the API name of the folders you want to use for that object, comma-separated

## Setup and Configuration

### Prerequisites
- Salesforce Lightning Experience enabled
- Email templates created in designated folders
- Appropriate user permissions configured

### Installation Steps

#### Step 1: Data Model Setup
Create a lookup relationship field on the `Generate_PDF__c` custom object targeting your desired parent object:

```apex
// Example: For Contract object integration
Generate_PDF__c.Contract__c (Lookup to Contract)
```

#### Step 2: Page Layout Configuration
1. Navigate to the target object's page layout
2. Add the "Generate PDF" related list
3. Configure visible columns:
   - Name
   - Status__c
   - Type__c
   - Email_Template__c
   - File_Template__c
   - CreatedDate

#### Step 3: Permission Configuration
Ensure users have the following permissions on `Generate_PDF__c`:
- **Read**: View generation history
- **Create**: Generate new PDFs
- **Delete**: Remove history records (optional)

#### Step 4: Custom Settings Configuration
1. Navigate to **Setup > Custom Settings > GeneratePDF Config > Manage**
2. Create a new record (Organization or User level)
3. Populate `Enabled_Folders__c` with comma-separated template folder API names:
   ```
   Fibre_App_Templates,Contract_Templates,Cost_Agreement_Templates
   ```

#### Step 5: Lightning Page Integration
1. Open the target record page in Lightning App Builder
2. Drag and drop the **"Generate PDF"** component
3. Configure component properties:
   - **Parent Field**: API name of the lookup field created in Step 1
   - **Enabled Folders**: Override default folders (optional)
   - **On Sidebar**: Check if placing in sidebar
   - **Disable Email**: Check to hide email functionality

### Component Configuration Properties

| Property | Type | Required | Description |
|----------|------|----------|-------------|
| `recordId` | String | Auto | Current record ID (auto-populated) |
| `parentField` | String | Yes | API name of lookup field (e.g., "Contract__c") |
| `enabledFolders` | String | No | Comma-separated folder names to override defaults |
| `isOnSidebar` | Boolean | No | Adjusts UI for sidebar placement |
| `disableEmail` | Boolean | No | Hides email functionality |
| `communityPath` | String | No | Community URL path for external access |

## Application Screens
image-20240404-230311.png
image-20240404-230314.png
image-20240404-230318.png
image-20240404-230326.png
 

## Usage and Definitions
The application leverage Salesforce’s standard out of the box template merging capabilities and extends custom functionalities to support complex scenarios on data merging. This means the admin can use the standard merging syntax i.e., “{!FieldName__c}” in combination with the custom merging syntax the app provides.

The custom syntax uses double parenthesis {{Field__c}} for merge fields and the following format for child records: {{#Childrelationship__r}} <content> {{/Childrelationship__r}}. For child records <content> is repeated a number of times depending on how many child records there are.

Below is a sample email template:



<!-- Account -->
<p>Hi {!Name},</p>
<p>Thank you for contacting support, below are are the list of all your open cases.</p>
<table>
  {{#Cases}}
  <tr>
    <td>Case Number</td>
    <td>{!CaseNumber}</td>
  </tr>
  <tr>
    <td>Contact Name/td>
    <td>{{Contact.Name}}</td>
  </tr>
  {{/Cases}}
</table>
Custom Merge Syntax Tips/Limitations
Formula expressions in merge fields are not supported. Either use custom formula fields and reference those fields in the custom merge syntax or use the standard salesforce merge fields in which formulas are supported.

Fields on the related to object (the top level) should be referred to without their object name. E.g. if the related to object is the Contact and you wish to merge in the value of the First Name field then the appropriate syntax is {{FirstName}} not {{Contact.FirstName}}.

Child relations may only be defined from the related to (the top level) object. E.g. if the related to object is the Account then you can refer to its children Cases or Contacts. However, you can not refer to the children cases' related children objects.

You can refer to a parent object at most 5 levels away. E.g. if the related object (the top level) is the Contact then the following expression is valid as it traverses upwards 2 levels {{Account.Owner.Name}}. {{Relationship__r.Relationship__r.Relationship__r.Relationship__r.Relationship__r.Relationship__r.Relationship__r.Name}} is not valid as refers to an ancestor record more than 5 levels away.

You can refer to parent, grandparent, etc fields in a child expression block. E.g. {{#Contacts}} {{Account.Name.Owner}} {{/Contacts} is valid, however the maximum traversal rule from the preceding point still applies.

## Component Layout
image-20240404-230501.png
Item

Description

1

the preference action;

PDF only allows the user to generate, download and attach a PDF to a record
Email allows the user to generate and send the file via email as attachments to a contact or email address

2

the action button;

PDF preference displays the action button as Generate PDF
Email preference displays the action button as Send Email

Note: the buttons doesn’t have an warning popup when clicked

3

allows the user to preview the template with merge data without downloading it, a popup that shows the pdf preview appears on click of this button

4

when the action button is clicked, it generates a history of document that was attempted to be generated, it shows an error pop if no template is selected

Note: this table only displays the most recent 10 history of pdf generation

5

this button redirects the user to all the all the pdf generation history of the record

## ## Complete Component Reference

### Lightning Web Components

| Component | Purpose | Key Features | Dependencies |
|-----------|---------|--------------|--------------|
| **generatePdf** | Main UI orchestrator | Template selection, generation triggers, mode switching | All other LWCs, GeneratePDFController |
| **generatePdfDoc** | Template selection interface | Dynamic dropdown, preview integration | combobox |
| **generatePdfHistory** | History display and downloads | Tabular view, navigation, responsive design | GeneratePDFController.getTableData |
| **generatePdfPreview** | Live template preview | Modal display, merge field rendering | GeneratePDFController |
| **generatePdfUtil** | Shared utilities | Constants, messages, type definitions | None |
| **combobox** | Reusable dropdown | Custom styling, event handling | None |

### Apex Classes

| Class | Type | Purpose | Key Methods |
|-------|------|---------|-------------|
| **GeneratePDFController** | Controller | Main business logic | `validateConfig()`, `generatePdfFile()`, `renderTemplate()` |
| **GeneratePDFFlowHandler** | Flow Integration | Process Builder/Flow support | `generatePdf()` (InvocableMethod) |
| **GeneratePDFFlowHandlerBulk** | Bulk Processor | High-volume processing | Bulk operation optimization |
| **GeneratePDFSelector** | Data Access | Template and config retrieval | `getTemplateById()`, caching |
| **GeneratePDFLargeTextBodyHandler** | Utility | Large content processing | Text handling optimization |
| **GeneratePDFBatchLauncher** | Batch | Batch job coordination | Async processing |
| **MergeFieldParser** | Validation | Core merge field parsing | `parse()`, field processing |
| **ChildMergeFieldValidator** | Validation | Child field validation | `validate()` |
| **ChildRelationshipValidator** | Validation | Relationship validation | `validate()` |
| **FieldValidationResult** | Data | Validation result container | Result encapsulation |
| **ValidationHandler** | Utility | General validation support | Validation coordination |
| **Guard** | Utility | Null checking and validation | `againstNull()` |
| **TestDataFactory** | Test Utility | Test data creation | `createAccountAsElectricityCustomer()` |

### Test Classes

| Test Class | Coverage Target | Key Scenarios |
|------------|-----------------|---------------|
| **GeneratePDFControllerTest** | GeneratePDFController | PDF generation, validation, error handling |
| **GeneratePDFFlowHandlerTest** | GeneratePDFFlowHandler | Flow integration, email sending, bulk processing |
| **GeneratePDFFlowHandlerBulkTest** | GeneratePDFFlowHandlerBulk | High-volume scenarios |
| **ChildMergeFieldValidatorTest** | ChildMergeFieldValidator | Field validation logic |
| **ChildRelationshipValidatorTest** | ChildRelationshipValidator | Relationship validation |
| **GeneratePDFLargeTextBodyHandlerTest** | GeneratePDFLargeTextBodyHandler | Large content handling |
| **GeneratePDFSelectorTest** | GeneratePDFSelector | Data access patterns |

### Interfaces

| Interface | Purpose | Implementations |
|-----------|---------|-----------------|
| **IMergeFieldValidator** | Field validation contract | MergeFieldValidator, ChildMergeFieldValidator |
| **IRelationshipValidator** | Relationship validation contract | ChildRelationshipValidator |
| **IFieldValidationResult** | Validation result contract | FieldValidationResult |
| **IRelationshipValidationResult** | Relationship result contract | Custom implementations |
| **IValidationResult** | General validation contract | ValidationResult |

### Visualforce Pages

| Page | Purpose | Controller | Key Features |
|------|---------|------------|--------------|
| **GeneratePDFPreview** | PDF rendering engine | GeneratePDFController | HTML to PDF conversion, merge field processing, styling |

### Utility Classes

| Class | Purpose | Key Methods | Used By |
|-------|---------|-------------|---------|
| **Guard** | Parameter validation | `againstNull()` | ChildMergeFieldValidator, validation framework |
| **TestDataFactory** | Test data creation | `createAccountAsElectricityCustomer()` | All test classes |

### Data Model

#### Generate_PDF__c Object
```apex
// Core fields
Name (Auto Number: PDF-{00000})
Status__c (Picklist: Generated, Failed, Processing)
Type__c (Picklist: PDF, Email)
Download_Path__c (Text: File download URL)

// Template references
Email_Template__c (Text: Email template name)
Email_TemplateId__c (Text: Email template ID)
File_Template__c (Text: File template name)  
File_TemplateId__c (Text: File template ID)

// Dynamic lookup fields (created per implementation)
Contract__c (Lookup to Contract)
Account__c (Lookup to Account)
// ... additional lookups as needed

// Audit fields
CreatedById, CreatedDate, LastModifiedById, LastModifiedDate
```

#### GeneratePDF_Config__c Custom Setting
```apex
Name (Text: Configuration name)
Enabled_Folders__c (Text Area: Comma-separated folder API names)
```

## API Documentation

### LWC Component APIs

#### generatePdf Component
```javascript
// Public Properties
@api recordId;           // Current record ID
@api parentField;        // Lookup field API name (required)
@api enabledFolders;     // Override default folders
@api isOnSidebar;        // UI layout adjustment
@api disableEmail;       // Hide email functionality
@api communityPath;      // Community URL base

// Public Methods
// None - all interactions through UI events

// Events Dispatched
// 'preview' - Template preview requested
// Toast events for user feedback
```

### Apex Controller APIs

#### GeneratePDFController
```apex
// AuraEnabled Methods
@AuraEnabled
public static Boolean validateConfig(String recordId, String parentField)

@AuraEnabled  
public static String generatePdfFile(String fileTemplateId, String recordId, 
                                   String parentField, String fileName)

@AuraEnabled
public static Map<String, Object> getTableData(String recordId, String parentField)

@AuraEnabled
public static List<Object> emailTemplateOptions(String enabledFolders)

// Page Controller Methods (for VF page)
public void renderTemplate()
public String fileTemplateBody { get; set; }
public String extractedStyles { get; set; }
```

#### GeneratePDFFlowHandler
```apex
@InvocableMethod(label='Generate PDF, Attach to Record, and Send Email')
public static List<GeneratePdfResponse> generatePdf(List<GeneratePdfRequest> requests)

// Inner Classes
public class GeneratePdfRequest {
    @InvocableVariable(required=true) public String fileTemplateId;
    @InvocableVariable(required=true) public String recordId;
    @InvocableVariable(required=true) public String parentField;
    @InvocableVariable(required=true) public String sObjectType;
    @InvocableVariable public String fileName;
    @InvocableVariable public String emailTemplateId;
    @InvocableVariable public String emailTo;
    @InvocableVariable public String leadOrContactId;
    @InvocableVariable public String fromAddressId;
}

public class GeneratePdfResponse {
    @InvocableVariable public String fileId;
    @InvocableVariable public String errorMessage;
}
```

---

## Summary

The Generate PDF Lightning Web Component Suite is a comprehensive Salesforce solution that provides:

1. **Rich UI Components**: Modern Lightning Web Components with responsive design
2. **Robust Backend**: Well-architected Apex classes with proper separation of concerns  
3. **Advanced Validation**: Sophisticated merge field and relationship validation framework
4. **Flow Integration**: Seamless Process Builder and Flow compatibility
5. **Audit Trail**: Complete generation history with download capabilities
6. **Extensible Design**: Configurable templates and flexible object integration

### Current Status
- ✅ **Core Functionality**: PDF generation and attachment working
- ✅ **UI Components**: Complete Lightning Web Component suite
- ✅ **Validation Framework**: Advanced merge field validation
- ✅ **Flow Integration**: InvocableMethod for automation
- ✅ **All Dependencies**: Complete codebase with all required components
- 🔄 **Email Feature**: Marked as "Coming Soon"

### Next Steps
1. Complete email functionality development
2. Enhance error handling and user feedback
3. Optimize performance for large templates
4. Add additional template format support
5. Implement advanced merge field features

This documentation provides the complete technical reference for implementing, configuring, and maintaining the Generate PDF application in Salesforce environments.

## Usage Guide

### Template Creation Best Practices

#### Email Template Setup
1. Create email templates in designated folders
2. Use HTML format for rich formatting support
3. Include both standard and custom merge syntax:

```html
<!-- Standard Salesforce merge fields -->
<p>Dear {!Contact.FirstName} {!Contact.LastName},</p>

<!-- Custom merge syntax for complex scenarios -->
<p>Account Name: {{Account.Name}}</p>
<p>Account Owner: {{Account.Owner.Name}}</p>

<!-- Child record iteration -->
<table>
  <thead>
    <tr>
      <th>Case Number</th>
      <th>Subject</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    {{#Cases}}
    <tr>
      <td>{{CaseNumber}}</td>
      <td>{{Subject}}</td>
      <td>{{Status}}</td>
    </tr>
    {{/Cases}}
  </tbody>
</table>
```

### Merge Field Syntax Reference

#### Standard Salesforce Syntax
- `{!FieldName}` - Standard field merge
- `{!RelatedObject.Field}` - Related object field
- `{!TODAY()}` - Formula functions (limited support)

#### Custom Enhanced Syntax
- `{{FieldName}}` - Custom field merge with validation
- `{{Parent.Field}}` - Parent object traversal (up to 5 levels)
- `{{#ChildRelation}} content {{/ChildRelation}}` - Child record iteration

#### Syntax Rules and Limitations
1. **Field References**: Top-level object fields don't require object prefix
   - ✅ Correct: `{{FirstName}}` (for Contact object)
   - ❌ Incorrect: `{{Contact.FirstName}}`

2. **Parent Traversal**: Maximum 5 levels up the hierarchy
   - ✅ Valid: `{{Account.Owner.Manager.Name}}`
   - ❌ Invalid: `{{Object.Parent.Parent.Parent.Parent.Parent.Name}}`

3. **Child Relations**: Only direct children from top-level object
   - ✅ Valid: `{{#Contacts}} {{Account.Name}} {{/Contacts}}`
   - ❌ Invalid: Nested child iterations

4. **Formula Fields**: Not supported in custom syntax
   - Use standard Salesforce syntax for formulas
   - Or create custom formula fields and reference them

### User Interface Guide

#### Component Layout Elements

1. **Preference Selection** (Radio Buttons)
   - **PDF**: Generate and attach PDF to record
   - **Email**: Generate PDF and send via email (Coming Soon)

2. **Action Button**
   - **Generate PDF**: Creates PDF and attaches to record
   - **Send Email**: Generates and emails PDF (Future feature)

3. **Preview Button**
   - Opens modal with live preview of merged template
   - Shows actual data merged into template
   - No template selection = error message

4. **Generation History Table**
   - Displays recent 10 generation attempts
   - Shows status, template used, timestamps
   - Download links for successful generations

5. **"View All History" Link**
   - Redirects to complete generation history
   - Provides full audit trail

### PDF Generation Process

#### Step-by-Step Workflow
1. **Template Selection**: Choose from configured folder templates
2. **Data Validation**: System validates merge fields against object schema
3. **Template Rendering**: Merge fields populated with actual record data
4. **PDF Creation**: HTML template converted to PDF format
5. **Storage**: PDF stored as ContentDocument in Salesforce
6. **Attachment**: PDF linked to source record and history record
7. **History Logging**: Generation attempt logged with status

#### Error Handling
- **No Template Selected**: User feedback prevents action
- **Invalid Merge Fields**: Validation errors displayed
- **Generation Failure**: Error logged in history with details
- **Permission Issues**: Appropriate error messages shown

## Development and Testing

### Test Coverage
The application includes comprehensive test coverage across all components:

#### Test Classes
- `GeneratePDFControllerTest.cls` - Tests main controller functionality
- `GeneratePDFFlowHandlerTest.cls` - Tests Flow integration
- `GeneratePDFFlowHandlerBulkTest.cls` - Tests bulk processing
- `ChildMergeFieldValidatorTest.cls` - Tests child field validation
- `ChildRelationshipValidatorTest.cls` - Tests relationship validation
- `GeneratePDFLargeTextBodyHandlerTest.cls` - Tests large text handling
- `GeneratePDFSelectorTest.cls` - Tests data access layer

#### Test Data Requirements
Tests require the following setup:
- Email templates in configured folders
- Sample Account/Contact/Contract records
- Org-Wide Email Address: `noreply@eanetworks.co.nz`
- Test utility class: `TestDataFactory` (missing dependency)

### Build and Deployment

#### Package Dependencies
```json
{
  "devDependencies": {
    "@lwc/eslint-plugin-lwc": "^2.2.0",
    "@salesforce/eslint-config-lwc": "^3.7.2",
    "@salesforce/sfdx-lwc-jest": "^7.0.1",
    "prettier": "^3.5.3",
    "prettier-plugin-apex": "^2.2.6"
  }
}
```

#### Development Commands
```bash
# Install dependencies
npm install

# Run linting
npm run lint

# Run unit tests
npm run test:unit

# Run tests with coverage
npm run test:unit:coverage

# Format code
npm run prettier
```

#### Deployment Checklist
1. ✅ All Apex classes deployed
2. ✅ Lightning Web Components deployed
3. ✅ Custom objects and fields deployed
4. ✅ All dependencies included:
   - `MergeFieldParser.cls`
   - `Guard.cls`
   - `TestDataFactory.cls`
   - `GeneratePDFPreview.page`
5. ✅ Custom settings configured
6. ✅ Permission sets assigned
7. ✅ Email templates created
8. ✅ Page layouts updated

### Known Issues and Limitations

#### Current Limitations
1. **Email Functionality**: Currently marked "Coming Soon" in UI
2. **Formula Field Support**: Limited to standard Salesforce syntax
3. **Child Iteration Depth**: Single level only (no nested child iterations)
4. **Parent Traversal Limit**: Maximum 5 levels up hierarchy
5. **Template Size**: Large templates may require optimization

#### Implementation Notes
All core dependencies are now included in the codebase:

1. **MergeFieldParser.cls**
   ```apex
   // Core parsing engine for merge field syntax
   // Handles {{field}} and {{#Child}} {{/Child}} syntax
   // Coordinates with validation framework
   ```

2. **Guard.cls**
   ```apex
   // Parameter validation utility
   // Provides null checking: Guard.againstNull(Object, String)
   // Used throughout validation framework
   ```

3. **TestDataFactory.cls**
   ```apex
   // Centralized test data creation
   // Standardizes test record creation patterns
   // Used across all test classes
   ```

4. **GeneratePDFPreview.page**
   ```xml
   <!-- Visualforce page for PDF rendering -->
   <!-- Converts HTML templates to PDF format -->
   <!-- Controlled by GeneratePDFController -->
   ```

### Performance Considerations

#### Optimization Guidelines
1. **Template Caching**: Templates cached in selector layer
2. **Bulk Processing**: Use GeneratePDFFlowHandlerBulk for volume
3. **Governor Limits**: Monitor SOQL queries in child relationship traversal
4. **File Size Management**: Large PDFs handled by specialized handler
5. **Error Recovery**: Savepoint/rollback pattern prevents partial failures

#### Monitoring and Debugging
- Enable debug logs for `GeneratePDFController` class
- Monitor `Generate_PDF__c` records for failure patterns
- Use Lightning Web Component browser debugging
- Check ContentDocument storage utilization

