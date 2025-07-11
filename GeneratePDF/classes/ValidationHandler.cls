/***************************************************************************
Name : Validation Handler
Created By : Stuart Alexandre 
Created Date : June 28, 2018
Description : Validation Handler class handle to check for validation and return custom message
***************************************************************************/
global class ValidationHandler {
    
    //List of custom attributes that we want to check the status of the org
    public Boolean Pass {get; set;}
    public string Message {get;set;}
    
}