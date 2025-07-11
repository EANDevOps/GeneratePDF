/**
    * @author Rory Figgins (Datacom)
    * @date 03/06/2021
    * @description a test helper class which assists in populating SObjects for unit tests
    * This class should never be used to perform DML activities and only populating SObjects
**/

public class TestDataFactory {
    
    //Consumer Test Data ====================
    public class ConsumerParams{
        public String name;
        public String icp;
        public String retailer;
        public String edb_Customer;
    }

    public static List<Consumer__c> createConsumers(Integer numOfRecords,ConsumerParams conParams){     
        //Fetch record types
        List<Consumer__c> consumerRecords = new List<Consumer__c>();
        for(Integer count=0;count<numOfRecords;count++){
            Consumer__c consumerObj = new Consumer__c();
            consumerObj.ICP__c = conParams.icp;
            consumerObj.Retailer__c = conParams.retailer;
            consumerObj.EDB_Customer__c = conParams.edb_Customer;
            consumerObj.Name = conParams.name;
            consumerRecords.add(consumerObj);
        }
        return consumerRecords;
    }
    
    public static eaapi__c createEAapi_ConfigSetting(){
        eaapi__c configRec = new eaapi__c();
        configRec.api_key__c = 'e81ab238c53e4748a2bb09bee8f3f2c3';
        configRec.Name = 'API Key';     
        return configRec;  
    }

    /**
     * @description populates a consumer sObject which is identifiable as an electricity consumer
     *
     * @param edbCustomerAccount - The account which is of record type electricity customer
     *
     * @return returns a consumer record populated with the data required to be identified as an electricity consumer
    **/
    public static Consumer__c createConsumerAsEDBCustomer(Account edbCustomerAccount) {
        Consumer__c consumer = new Consumer__c();
        consumer.Retailer_Customer_Id__c = '1300109777';
        consumer.Retailer_Consumer_Id__c = '1300109777';
        consumer.Retailer_Short_Code__c = 'CTCT';
        consumer.EDB_Customer__c = edbCustomerAccount.Id;
        return consumer;
    }

    /**
     * @description populates a ICP_Config__c custom setting record
     *
     * @return returns a ICP Config custom setting record
    **/
    public static ICP_Config__c createICPConfig() {
        return new ICP_Config__c(
            connection_sequence__c =  6,
            network_code__c = 'TS',
            Name = 'Test'
        );
    }

    /**
     * @description populates a User record with all of the required base fields excluding profile
     *
     * @return returns a user record
    **/
    public static User createUser() {
        User u = new User();
        u.Alias = 'Test001';
        u.LastName = 'Test001';
        u.Email = 'UnitTest001@unittest.com';
        u.Username = 'UnitTest001@unittest.com';
        u.LanguageLocaleKey = 'en_US';
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'Pacific/Auckland';
        u.EmailEncodingKey = 'ISO-8859-1';
        u.ProfileId = null;

        return u;
    }
    
   //Account Test Data ====================

    public class AccountParams{
        public String Name;
        public String recordType;
    }
    
    public static List<Account> createTestAccounts(Integer numOfRecords,AccountParams accParams){
        //Fetch record types
        Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get(accParams.recordType).getRecordTypeId();
        List<Account> accountRecords = new List<Account>();

        for(Integer count=0;count<numOfRecords;count++){
            Account accObj = new Account();
            accObj.Name = accParams.Name;
            accObj.RecordTypeId = accRecordTypeId;
           accountRecords.add(accObj);
        }
        return accountRecords;
    }

    /**
     * @description populates an Account record which is of type Retailer
     *
     * @return returns an account record
    **/
    public static Account createAccountAsRetailer() {
        return new Account(
            Name = 'Test Retailer',
            Retailer_Code__c = 'CTCT',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Retailer').getRecordTypeId()
        );
    }

    /**
     * @description populates an Account record which is of type Electricity Customer
     *
     * @return returns an account record
    **/
    public static Account createAccountAsElectricityCustomer() {
        return new Account(
            Name = 'Mrs SAbbott ',
            Retailer_Code__c = 'CTCT',
            Mobile__c = '0274539457',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Customer').getRecordTypeId()
        );
    }
    
      /**
     * @description populates an Account record which is of type Electricity Customer
     *
     * @return returns an account record
    **/
    public static Account createAccountAsElectricity() {
        return new Account(
            Name = 'Mrs SAbbott ',
            Retailer_Code__c = 'CTCT',
            Mobile__c = '0274539457',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Electricity_Customer').getRecordTypeId()
        );
    }
    
    //Contact Test Data ====================
    public class ContactParams{
        public String accountId;
        public String firstName;
        public String email;
        public String lastName;
        public String recordType;
    }

    public static List<Contact> createTestContacts(Integer numOfRecords,ContactParams conParams){
        //Fetch record types
        List<Contact> contactRecords = new List<Contact>();
        for(Integer count=0;count<numOfRecords;count++){
            Contact conObj = new Contact();
            conObj.AccountId = conParams.AccountId;
            conObj.FirstName = conParams.firstName;
            conObj.LastName = conParams.LastName;
            conObj.Email = conParams.email;
            contactRecords.add(conObj);
        }
        return contactRecords;
    }

    /**
     * @description populates a base Contact record
     *
     * @return returns a contact record
    **/
    public static Contact createContact() {
        return new Contact(
            LastName = 'Test'
        );
    }

    /**
     * @description populates a eaapi__c custom setting record
     *
     * @return returns a EA API custom setting record
    **/
    public static eaapi__c createEAAPIConfig() {
        return new eaapi__c(
            Name = 'EA Networks',
            api_key__c = 'TEST0001'
        );
    }

    /**
     * @description populates an ICP_Registry_Inbound_Outbound_Event__c record which is of type Inbound
     *
     * @return returns an ICP_Registry_Inbound_Outbound_Event__c record
    **/
    public static ICP_Registry_Inbound_Outbound_Event__c createICPRegistryEventAsInboundMessageType() {
        return new ICP_Registry_Inbound_Outbound_Event__c(
            ICP_Identifier__c = '0000324375AD61F',
            Message_Type__c = 'Inbound',
            Processing_Status__c = 'Created',
            Status_Changed__c = true,
            ICP_JSON__c = '{"ICP Identifier":"0000324375AD61F","Registry Status":"002 - active","Connection Number":"324375","Energisation Status":"Energised","Status Reason":"","Fuse Size":"","Transformer":"","Feeder":"","Irrigation Pump Size":"","Number of phases":"3","Installation Number":"","Cert Date":"","Highest Metering Category":"","Cert Type":"F","Location Code":"BG - BACK OF GARAGE","Cert Expiry Date":"","Type":"NON","Control Device Cert Flag":false,"Certification Number":"","Cert Variations":"","Generation Capacity":"","Reconcilliation Type":"GN - grid connected network","Proposed Retailer":"","Installation Type":"L - load","Current Trader":"","Initial Energisation Date":"","Fuel Type":"","Direct Billed Status":"NULL","Direct Billed Details":"","POC":"","Dedicated NSP":false,"Chargeable Capacity":"","Customer Group":"No Customer Group","Distributor Price Category Code":"","Distributor Loss Category Code":"","Distributor Installation Details":"","Address Property Name":"","GPS Easting":"","GPS Northing":"","Latitude":"","Longitude":"","Access Address Unit":"","Access Address Street":"","Access Address Suburb":"","Access Address Town":"","Access Address Post Code":"","Access Address Region":"","Access Address Number/ RAPID Number":""}'
        );
    }

    /**
     * @description populates an ICP_Registry_Inbound_Outbound_Event__c record which is of type Outbound
     *
     * @return returns an ICP_Registry_Inbound_Outbound_Event__c record
    **/
    public static ICP_Registry_Inbound_Outbound_Event__c createICPRegistryEventAsOutboundMessageType() {
        return new ICP_Registry_Inbound_Outbound_Event__c(
            ICP_Identifier__c = '0000324375AD61F',
            Message_Type__c = 'Outbound',
            Processing_Status__c = 'Created',
            Status_Changed__c = true,
            ICP_JSON__c = '{"ICP Identifier":"0000324375AD61F","Registry Status":"002 - active","Connection Number":"324375","Energisation Status":"Energised","Status Reason":"","Fuse Size":"","Transformer":"","Feeder":"","Irrigation Pump Size":"","Number of phases":"3","Installation Number":"","Cert Date":"","Highest Metering Category":"","Cert Type":"F","Location Code":"BG - BACK OF GARAGE","Cert Expiry Date":"","Type":"NON","Control Device Cert Flag":false,"Certification Number":"","Cert Variations":"","Generation Capacity":"","Reconcilliation Type":"GN - grid connected network","Proposed Retailer":"","Installation Type":"L - load","Current Trader":"","Initial Energisation Date":"","Fuel Type":"","Direct Billed Status":"NULL","Direct Billed Details":"","POC":"","Dedicated NSP":false,"Chargeable Capacity":"","Customer Group":"No Customer Group","Distributor Price Category Code":"","Distributor Loss Category Code":"","Distributor Installation Details":"","Address Property Name":"","GPS Easting":"","GPS Northing":"","Latitude":"","Longitude":"","Access Address Unit":"","Access Address Street":"","Access Address Suburb":"","Access Address Town":"","Access Address Post Code":"","Access Address Region":"","Access Address Number/ RAPID Number":""}'
        );
    }

        //Asset Test Data ====================
    public class ICP_Params{
        public String accountId;
        public String name;
    }
    
    public static List<Asset> createTestAssets(Integer numOfRecords,ICP_Params icpParams){     
        //Fetch record types
        List<Asset> icpRecords = new List<Asset>();
        for(Integer count=0;count<numOfRecords;count++){
            Asset icpObj = new Asset();
            icpObj.AccountId = icpParams.accountId;
            icpObj.Name = icpParams.name;
            icpRecords.add(icpObj);
        }
        return icpRecords;
    }
    
    public static ICP_Config__c createICP_ConfigSetting(){
        ICP_Config__c configRec = new ICP_Config__c();
        configRec.Connection_Sequence__c = 109090;
        configRec.network_code__c = 'MP';
        configRec.Name = 'ICP Number';     
        return configRec;  
    }
    
    /**
     * @description populates an asset record which has a predefined system ID
     *
     * @return returns an asset record
    **/
    public static Asset createAssetAsICPWithSystemId() {
        return new Asset(
            System_icp_Identifier__c = '0000020972EA3DD',
            Name = 'dummy',
            POC_Status__c = 'Permanent'
        );
    }

    /**
     * @description populates an asset record without a predefined system ID
     *
     * @return returns an asset record
    **/
    public static Asset createAssetAsICPWithoutSystemId() {
        return new Asset(
            Name='10',
            Energisation_Status__c = '',
            Status = 'Proposed',
            Address_Property_Name__c = 'Any Test Address',
            POC_Status__c = 'Permanent'
        );
    }

    /**
     * @description populates a EIEP4 Staging record which contains an error
     *
     * @return returns a EIEP4 Staging record with an error
    **/
    public static EIEP4_Staging__c createEIEPStagingRecordWithError() {
        return new EIEP4_Staging__c(
            ICP_Number__c = '100002',
            Customer_Name__c = 'davaError',
            Trader__c = 'Trader'
        );
    }

    /**
     * @description populates a EIEP4 Staging record which is identifiable as a consumer
     *
     * @return returns a EIEP4 Staging record
    **/
    public static EIEP4_Staging__c createEIEPStagingRecordAsConsumer() {
        return new EIEP4_Staging__c(
            ICP_Number__c ='0000020972EA3DD',
            Retailer_Customer_Id__c  = '1000428422',
            Retailer_Consumer_Id__c  = '1300109777',
            Customer_Name__c = 'MrsSAbbott',
            Trader__c = 'CTCT',
            Processing_Status__c = 'New',
            Customer_Title__c = 'Mrs',
            First_name__c = 'Sherry',
            Surname__c = 'Abbott',
            Street_Number__c = '9',
            Town__c = 'Rangiora',
            Country__c = 'NZ',
            Email__c = 'sherryabb@xtra.co.nz',
            Postcode__c = '7400',
            Disconnection_restriction__c = 'N',
            Work_Phone__c = '033480860',
            Phone__c = '033106211',
            Mobile_Phone__c = '0274539457',
            EIEP4rawrecord__c = 'DET,0000020972EA3DD,MrsSAbbott,033106211,033480860,0274539457,,sherryabb@xtra.co.nz,,,9,Wairepo Close,,,Rangiora,7400,NZ,21/09/2012,N,,1000428422,1300109777,Mrs,Abbott,Sherry,'
        );
    }

    /**
     * @description populates a FeedItem record
     *
     * @return returns a FeedItem record
    **/
    public static FeedItem createFeedItem(SObject sObj) {

        //create and insert the feed item
        FeedItem item = new FeedItem();
        item.Body = 'Test Comment';
        item.ParentId = sObj.Id;

        return item;
    }

    /**
     * @description populates a generic Case record
     *
     * @return returns a Case record
    **/
    public static Case createCase() {
        Case c = new Case();
        c.Subject = 'Test Case';
        c.Status = 'Approval Pending';
        c.SuppliedEmail = 'test@test.com';
        c.SuppliedName = 'Test Name';
        c.Origin = 'Web';

        return c;
    }
    
    //Case Test Data
	public class CaseParams{
        public String Status;
        public String recordType;
    }
    
    public static List<Case> createTestCases(Integer numOfRecords,CaseParams caseParams){
        //Fetch record types
        Id caseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(caseParams.recordType).getRecordTypeId();
        List<Case> caseRecords = new List<Case>();

        for(Integer count=0;count<numOfRecords;count++){
            Case caseObj = new Case();
            caseObj.Status = caseParams.Status;
            caseObj.RecordTypeId = caseRecordTypeId;
            caseRecords.add(caseObj);
        }
        return caseRecords;
    }

     /**
     * @description populates a generic Case record with number specified
     *
     * @return returns Case records
    **/
    public static List<Case> createTestCases(Integer numOfRecords){
        List<Case> caseRecords = new List<Case>();
        for(Integer count=0;count<numOfRecords;count++){
            Case caseObj = new Case();
           	caseRecords.add(caseObj);
        }
        return caseRecords;
    }

     /**
     * @description populates a generic Location record
     *
     * @return returns a Locatio record
    **/
     public static Schema.Location createLocation() {
        Schema.Location locRecord = new Schema.Location();
        locRecord.Name = 'Placeholder Location';

        return locRecord;
    }
}