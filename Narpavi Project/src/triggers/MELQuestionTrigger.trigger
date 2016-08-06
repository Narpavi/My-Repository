trigger MELQuestionTrigger on MEL_Question__c (After Insert,After Delete) {
    MELQuestionTriggerHandler.getHandler().execute();
}