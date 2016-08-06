trigger ResultsFrameworkResponseTrigger on Results_Framework_Form_Response__c (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
    ResultsFrameworkResponseTriggerHandler.getHandler().execute(); 
}