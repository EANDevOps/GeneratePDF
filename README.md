# Generate PDF Lightning Web Component Suite

## Introduction

The Generate PDF application is a comprehensive Salesforce Lightning Web Component (LWC) solution designed to automate PDF generation from email templates with advanced merge field capabilities.

Built for the EA Network by Datacom and later enhanced by EA Networks, this solution addresses the business challenge of manually creating Cost Agreements, Quotes, and other documents by providing an intuitive, component-based approach to document generation.

## Application Capabilities

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
- **Standard Salesforce merge fields**: `{!FieldName__c}`
- **Custom merge syntax**: `{{Field__c}}`
- **Child record iteration**: `{{#ChildRelationship__r}} content {{/ChildRelationship__r}}`
- **Parent field traversal**: `{{Account.Owner.Name}}`
- **Validation framework**: Ensures field and relationship integrity

---

## Technical Architecture

### System Overview
The Generate PDF application follows a modular architecture with clear separation of concerns, organized into distinct layers for scalability and maintainability.

### Component Architecture

#### Lightning Web Components
- **generatePdf**: Main component orchestrator
- **generatePdfDoc**: Template selection interface
- **generatePdfHistory**: History display and tracking
- **generatePdfPreview**: Modal preview functionality
- **generatePdfUtil**: Shared utilities and constants
- **combobox**: Reusable dropdown component

#### Apex Controllers
- **GeneratePDFController**: Main business logic and API endpoints
- **GeneratePDFFlowHandler**: Flow/Process Builder integration
- **GeneratePDFFlowHandlerBulk**: Bulk processing optimization
- **GeneratePDFSelector**: Data access layer and caching
- **GeneratePDFBatchLauncher**: Batch job coordination

#### Validation Framework
- **IMergeFieldValidator**: Validation interface contract
- **ChildMergeFieldValidator**: Child field validation logic
- **IRelationshipValidator**: Relationship validation interface
- **ChildRelationshipValidator**: Relationship validation implementation
- **ValidationHandler**: General validation coordination
- **FieldValidationResult**: Validation result container
- **ValidationResult**: General validation results
- **IValidationResult**: Result interface contract
- **MergeFieldParser**: Core merge field parsing engine

#### Supporting Services
- **GeneratePDFLargeTextBodyHandler**: Large content processing
- **Guard**: Parameter validation and null checking
- **TestDataFactory**: Centralized test data creation

#### Presentation Layer
- **GeneratePDFPreview.page**: Visualforce PDF rendering engine

#### Data Layer
- **Generate_PDF__c**: History and audit trail storage
- **GeneratePDF_Config__c**: Configuration management
- **EmailTemplate**: Standard Salesforce templates
- **ContentDocument/ContentVersion/ContentDocumentLink**: File storage and management

#### Integration Layer
- **Flow/Process Builder**: External automation integration
- **Messaging.SingleEmailMessage**: Email service integration
- **SOQL**: Dynamic data query capabilities

**✅ All dependencies are included in the codebase.**

---

## Core Components

### Lightning Web Components (LWC)

#### 1. generatePdf (Main Component)
- **File**: `force-app/main/default/lwc/generatePdf/`
- **Purpose**: Primary UI component orchestrating the entire PDF generation process
- **Key Features**:
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

#### 2. generatePdfDoc (Template Selection)
- **File**: `force-app/main/default/lwc/generatePdfDoc/`
- **Purpose**: Template selection and preview interface
- **Key Features**:
  - Dynamic template dropdown population
  - Preview functionality integration
  - Template validation

#### 3. generatePdfHistory (History Management)
- **File**: `force-app/main/default/lwc/generatePdfHistory/`
- **Purpose**: Display generation history and download links
- **Key Features**:
  - Tabular history view with pagination
  - Download navigation and file access
  - Responsive design for various screen sizes

#### 4. generatePdfPreview (Preview Modal)
- **File**: `force-app/main/default/lwc/generatePdfPreview/`
- **Purpose**: Modal preview of generated PDF content
- **Key Features**:
  - Live template rendering with actual data
  - Modal display with proper styling
  - Preview without file generation

#### 5. generatePdfUtil (Shared Utilities)
- **File**: `force-app/main/default/lwc/generatePdfUtil/`
- **Purpose**: Shared utilities and constants
- **Contents**:
  - Message constants and labels
  - UI configuration maps
  - Common type definitions

#### 6. combobox (Reusable Component)
- **File**: `force-app/main/default/lwc/combobox/`
- **Purpose**: Reusable dropdown component
- **Key Features**:
  - Custom styling and theming
  - Event handling and propagation
  - Accessibility compliance

### Apex Classes

#### Controller Layer

#### 1. GeneratePDFController (Main Controller)
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

#### 2. GeneratePDFFlowHandler (Flow Integration)
- **File**: `force-app/main/default/classes/GeneratePDFFlowHandler.cls`
- **Purpose**: Flow/Process Builder integration for automated PDF generation
- **Key Features**:
  - `@InvocableMethod` for Flow integration
  - Bulk processing support
  - Email sending capabilities
  - Error handling and response management
- **Input/Output Classes**:
  - `GeneratePdfRequest`: Input parameters
  - `GeneratePdfResponse`: Output results

#### 3. GeneratePDFFlowHandlerBulk (Bulk Processing)
- **File**: `force-app/main/default/classes/GeneratePDFFlowHandlerBulk.cls`
- **Purpose**: Handles bulk PDF generation scenarios
- **Key Features**:
  - Optimized for high-volume processing
  - Governor limit management
  - Batch processing coordination

#### 4. GeneratePDFSelector (Data Access Layer)
- **File**: `force-app/main/default/classes/GeneratePDFSelector.cls`
- **Purpose**: Data access layer for templates and configurations
- **Key Features**:
  - SOQL optimization and caching
  - Template retrieval and management
  - Configuration data access

#### Validation Framework

The application includes a sophisticated validation framework to ensure merge field integrity:

#### 1. IMergeFieldValidator (Interface)
- **File**: `force-app/main/default/classes/IMergeFieldValidator.cls`
- **Purpose**: Contract for field validation implementations

#### 2. MergeFieldValidator (Standard Fields)
- **File**: `force-app/main/default/classes/MergeFieldValidator.cls`
- **Purpose**: Validates standard merge fields against sObject schema
- **Key Features**:
  - Field existence verification
  - Data type checking
  - Accessibility validation

#### 3. MergeFieldParser (Core Engine)
- **File**: `force-app/main/default/classes/MergeFieldParser.cls`
- **Purpose**: Core engine for parsing and processing merge field syntax
- **Key Features**:
  - Parses custom `{{field}}` syntax
  - Handles child relationship iterations `{{#Child}} {{/Child}}`
  - Coordinates with validation framework
  - Processes parent field traversal
- **Dependencies**: IMergeFieldValidator, IRelationshipValidator

#### 4. ChildMergeFieldValidator (Child Fields)
- **File**: `force-app/main/default/classes/ChildMergeFieldValidator.cls`
- **Purpose**: Validates child relationship merge fields
- **Key Features**:
  - Relationship traversal validation
  - Nested field checking
  - Child object schema validation
- **Dependencies**: IRelationshipValidator, IMergeFieldValidator, Guard

#### 5. ChildRelationshipValidator (Relationships)
- **File**: `force-app/main/default/classes/ChildRelationshipValidator.cls`
- **Purpose**: Validates child relationship definitions
- **Key Features**:
  - Relationship existence verification
  - Cardinality checking
  - Schema compliance validation

#### 6. Result Classes
- **FieldValidationResult**: Field validation outcomes
- **ValidationResult**: General validation results
- **IValidationResult**: Validation result interface

### Data Layer

#### Custom Objects

#### 1. Generate_PDF__c (Audit Trail)
- **File**: `force-app/main/default/objects/Generate_PDF__c/`
- **Purpose**: Stores PDF generation history and audit trail
- **Key Fields**:
  - Dynamic lookup fields to parent objects
  - `Status__c`: Generation status (Generated/Failed/Processing)
  - `Type__c`: Operation type (PDF/Email)
  - `Download_Path__c`: File access URL
  - `Email_Template__c`: Template name used
  - `File_Template__c`: File template used
  - Timestamp fields for audit trail

#### 2. GeneratePDF_Config__c (Configuration)
- **File**: `force-app/main/default/objects/GeneratePDF_Config__c/`
- **Purpose**: Application configuration storage (Custom Setting)
- **Key Fields**:
  - `Enabled_Folders__c`: Default template folders

### Supporting Components

#### 1. GeneratePDFLargeTextBodyHandler (Text Processing)
- **File**: `force-app/main/default/classes/GeneratePDFLargeTextBodyHandler.cls`
- **Purpose**: Handles large text processing for templates
- **Key Features**:
  - Large content optimization
  - Memory management
  - Performance optimization

#### 2. GeneratePDFBatchLauncher (Batch Coordination)
- **File**: `force-app/main/default/classes/GeneratePDFBatchLauncher.cls`
- **Purpose**: Batch processing coordination
- **Key Features**:
  - Asynchronous processing management
  - Job scheduling and monitoring

#### 3. Guard (Validation Utility)
- **File**: `force-app/main/default/classes/Guard.cls`
- **Purpose**: Utility class providing null checking and validation
- **Key Features**:
  - `againstNull(Object, String)`: Validates non-null parameters
  - Parameter validation with descriptive error messages
  - Used throughout validation framework

#### 4. TestDataFactory (Test Utility)
- **File**: `force-app/main/default/classes/TestDataFactory.cls`
- **Purpose**: Centralized test data creation utility
- **Key Features**:
  - `createAccountAsElectricityCustomer()`: Creates test Account records
  - Standardized test data patterns
  - Used across all test classes

### Presentation Layer

#### Visualforce Pages

#### 1. GeneratePDFPreview (PDF Rendering Engine)
- **File**: `force-app/main/default/pages/GeneratePDFPreview.page`
- **Purpose**: Renders email templates as PDF documents
- **Key Features**:
  - Converts HTML email templates to PDF format
  - Handles merge field processing
  - Template styling preservation
  - CSS extraction and application
- **Controller**: GeneratePDFController
- **Usage**: Called by GeneratePDFController.createDocument() method

---

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

---

## Usage and User Guide

### Template Creation and Merge Field Syntax

The application leverages Salesforce's standard template merging capabilities and extends them with custom functionalities to support complex data merging scenarios. Administrators can use both standard Salesforce syntax (`{!FieldName__c}`) and the application's custom syntax in combination.

#### Merge Field Syntax Reference

##### Standard Salesforce Syntax
- `{!FieldName}` - Standard field merge
- `{!RelatedObject.Field}` - Related object field  
- `{!TODAY()}` - Formula functions (limited support)

##### Custom Enhanced Syntax
- `{{FieldName}}` - Custom field merge with validation
- `{{Parent.Field}}` - Parent object traversal (up to 5 levels)
- `{{#ChildRelation}} content {{/ChildRelation}}` - Child record iteration

#### Sample Email Template

```html
<!-- Account Template Example -->
<p>Hi {!Name},</p>
<p>Thank you for contacting support. Below are all your open cases:</p>

<table border="1" style="border-collapse: collapse; width: 100%;">
  <thead>
    <tr>
      <th>Case Number</th>
      <th>Contact Name</th>
      <th>Status</th>
    </tr>
  </thead>
  <tbody>
    {{#Cases}}
    <tr>
      <td>{{CaseNumber}}</td>
      <td>{{Contact.Name}}</td>
      <td>{{Status}}</td>
    </tr>
    {{/Cases}}
  </tbody>
</table>
```

### Custom Merge Syntax Rules and Limitations

#### Important Rules
1. **Formula Expression Limitation**: Formula expressions are not supported in custom merge fields (`{{}}` syntax)
   - **Solution**: Use custom formula fields and reference them, or use standard Salesforce syntax for formulas

2. **Top-Level Object Fields**: Fields on the primary object should be referenced without the object prefix
   - ✅ **Correct**: `{{FirstName}}` (for Contact object)
   - ❌ **Incorrect**: `{{Contact.FirstName}}`

3. **Child Relations**: Only direct children from the top-level object are supported
   - ✅ **Valid**: Account → Cases or Contacts
   - ❌ **Invalid**: Nested child iterations (Cases → Child Cases)

4. **Parent Traversal Limit**: Maximum 5 levels up the object hierarchy
   - ✅ **Valid**: `{{Account.Owner.Manager.Name}}` (3 levels)
   - ❌ **Invalid**: More than 5 relationship traversals

5. **Mixed Syntax in Child Blocks**: Parent fields can be referenced within child iteration blocks
   - ✅ **Valid**: `{{#Contacts}} {{Account.Owner.Name}} {{/Contacts}}`
   - **Note**: Maximum traversal rule still applies

---

## User Interface Guide

### Component Layout and Features

#### 1. Action Preference Selection
- **PDF Mode**: Generate and attach PDF to record
- **Email Mode**: Generate PDF and send via email (Coming Soon)

#### 2. Generation Button
- **PDF Mode**: Displays "Generate PDF" button
- **Email Mode**: Displays "Send Email" button  
- **Note**: No confirmation popup on click

#### 3. Preview Functionality
- Opens modal with live preview of merged template
- Shows actual data merged into template
- **Requirement**: Template must be selected first

#### 4. Generation History
- Displays recent 10 generation attempts
- Shows status, template used, timestamps
- Provides download links for successful generations
- **Error Handling**: Shows error popup if no template selected

#### 5. Full History Access
- "View All History" link for complete audit trail
- Redirects to comprehensive generation history

---

## Complete Component Reference

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

---

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
- Test utility class: `TestDataFactory`

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
All core dependencies are included in the codebase:

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
